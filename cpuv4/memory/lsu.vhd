
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.util.all; 
use work.instruction.all;
use work.SuperScalarComponents.all; 

entity lsu is
	port  (
		clk,flush,jmp_commit,write : in std_logic;
    	load_end,store_ok,io_ok,io_end,lsu_full : out std_logic;
		storeexec,ioexec : in std_logic;
		pc : in std_logic_vector(13 downto 0);
		op : in std_logic_vector(5 downto 0);
		im : in std_logic_vector(13 downto 0);
    	
    	a,b : in std_logic_vector(31 downto 0);
    	o : out std_logic_vector(31 downto 0);
    	
    	tagin : in std_logic_vector(3 downto 0);
    	tagout : out std_logic_vector(3 downto 0);
    	
    	ls_flg : out std_logic_vector(2 downto 0);
		load_hit : in std_logic;
    	load_data : in std_logic_vector(31 downto 0);
    	ls_addr_out : out std_logic_vector(19 downto 0);
    	store_data : out std_logic_vector(31 downto 0);
    	led : in std_logic_vector(15 downto 0);
    	ledd : in std_logic_vector(7 downto 0);
    	
    	RS_RX : in STD_LOGIC;
	    RS_TX : out STD_LOGIC;
	    outdata0 : out std_logic_vector(7 downto 0);
	    outdata1 : out std_logic_vector(7 downto 0);
	    outdata2 : out std_logic_vector(7 downto 0);
	    outdata3 : out std_logic_vector(7 downto 0);
	    outdata4 : out std_logic_vector(7 downto 0);
	    outdata5 : out std_logic_vector(7 downto 0);
	    outdata6 : out std_logic_vector(7 downto 0);
	    outdata7 : out std_logic_vector(7 downto 0)
	);
end lsu;


architecture arch of lsu is
	--io
   signal leddata,leddata_buf,ld,iou_out : std_logic_vector(31 downto 0):= (others => '0');
   signal leddotdata : std_logic_vector(7 downto 0):= (others => '0');
	signal iou_enable,io_do,ld_valid,load_read,load_full,load_empty,load_issue,loadwait :std_logic:='0';
	signal io_read_buf_overrun :std_logic;
	signal io : std_logic_vector(38 downto 0) := (others => '0');
	
	
	signal store,storeinst,load_write,io_write,store_write,load_retry : std_logic := '0';
	signal addr,saddr : std_logic_vector(16 downto 0) := (others => '0');
	signal store_buf0,store_buf1 : std_logic_vector(53 downto 0) := (others => '0');
	signal load_buf0 : std_logic_vector(57 downto 0) := (others => '0');
	signal load_next : std_logic_vector(57 downto 0) := (others => '0');

	type s_t is array (0 to 7) of std_logic_vector (57 downto 0);
	signal load_buf : s_t := (others => (others => '0'));
	signal rp,wp : std_logic_vector(2 downto 0) := (others => '0');
	signal rsrp,rswp : std_logic_vector(7 downto 0) := (others => '0');
	signal jmp_miss_counter : std_logic_vector(31 downto 0) := (others=>'0');
	signal jmp_counter : std_logic_vector(31 downto 0) := (others=>'0');
begin
	-- store,io優先
	-- storeとioは重ならない
	lsu_full <= io(38) or io_do or
	 (store_buf0(53) and store_buf1(53)) or storeexec or
	  load_full;

	with op select
	 load_write <= '1' when "000000"|"000100"|"010000"|"010100"|"001100"|"011100",
	 '0' when others;
	with op select
	 io_write <= '1' when "100001"|"101001"|"110001"|"111001",
	 '0' when others;
	 store_write <= op(5);
	 
	 
	load_full <= '1' when (rp = (wp + '1')) or (rp = (wp + "10")) else '0';
	load_empty <= '1' when rp = wp else '0';
	
	tagout <= io(37 downto 34) when io_do = '1' else load_next(55 downto 52);
	io_ok <= io(38);
	io_end <= io_do;
	
	o <= iou_out when io_do = '1' else 
	load_next(31 downto 0) when load_next(56) = '1' else
	load_data;
	
	store_ok <= store_buf0(53);
	load_buf0 <= load_buf(conv_integer(rp));
	ls_addr_out <= "000"&saddr when (store = '1') or (storeinst = '1') else "000"&load_buf0(48 downto 32);
	
	
	ls_flg(0) <= store;
	ls_flg(1) <= load_issue;
	ls_flg(2) <= storeinst;
	load_retry <= (((not load_hit) and (not load_next(56))) or io_do) and (loadwait);

	load_issue <= (not store) and (not storeinst) and (not load_empty) and (not load_buf0(56));
	load_read <= (not store) and (not storeinst) and (not load_empty);
	
	load_end <= (load_hit or load_next(56)) and (not io_do) and (loadwait);

	--アドレス計算
	addr <= a(16 downto 0) + b(16 downto 0) when op(2) = '1' else a(16 downto 0) + sign_extention17(im);


	ld_valid <= '1' when (store_buf0(48 downto 32) = addr)  and (store_buf0(53) = '1')else
	'1' when (store_buf1(48 downto 32) = addr)  and (store_buf1(53) = '1') else
	op(3) and op(2);
	
	ld <= b when op(3 downto 2) = "11" else
	store_buf0(31 downto 0) when (store_buf0(48 downto 32) = addr) and (store_buf0(53) = '1') else
	store_buf1(31 downto 0) when (store_buf1(48 downto 32) = addr) and (store_buf1(53) = '1') else
	b;
	
	LOADPROC:process(clk)
	begin
		if rising_edge(clk) then
			if flush = '1' then
				rp <= (others => '0');
				wp <= (others => '0');
				loadwait <= '0';
				load_next<= (others => '0');
			else
				if load_read = '1' then
					rp <= rp + '1';
					loadwait <= '1';
					load_next <= load_buf0;
				else
					load_next<= (others => '0');
					loadwait <= '0';
				end if;
				if load_retry = '1' then
					if (write = '1') and (load_write = '1') then
						load_buf(conv_integer(wp)) <= '1'&ld_valid&tagin&"000"&addr&ld;
						load_buf(conv_integer(wp + '1')) <= load_next;
						wp <= wp + "10";
					else
						load_buf(conv_integer(wp)) <= load_next;
						wp <= wp + '1';
					end if;
				else
					if (write = '1') and (load_write = '1') then
						load_buf(conv_integer(wp)) <= '1'&ld_valid&tagin&"000"&addr&ld;
						wp <= wp + '1';
					end if;
				end if;
			end if;
		end if;
	end process;
		
	STOREPROC:process(clk)
	begin
		if rising_edge(clk) then
			if flush = '1' then
				store_buf0(53) <= '0';
				store_buf1(53) <= '0';
				store <= '0';
				storeinst <= '0';
			else
				if (storeexec = '1') and (store_buf0(53) = '1') then
					store <= not store_buf0(52);
					storeinst <= store_buf0(52);
				else
					store <= '0';
					storeinst <= '0';
				end if;
			
				if (storeexec = '1') and (store_buf0(53) = '1') then
					saddr <= store_buf0(48 downto 32);
					store_data <= store_buf0(31 downto 0);
					store_buf0 <= store_buf1;
					store_buf1(53) <= '0';
				elsif (write = '1') and ((op(5 downto 2) = "0010") or (op(5 downto 2) = "0110")) then 
					if store_buf0(53) = '0' then
						store_buf0 <= '1'&op(1)&"000"&addr&b;
					else
						store_buf1 <= '1'&op(1)&"000"&addr&b;
					end if;
				end if;
			end if;
		end if;
	end process;
	
process(clk)
  begin
	if rising_edge(clk) then
		if (pc(12 downto 8) /= "00000") and (flush = '1') then
			jmp_miss_counter <= jmp_miss_counter + '1';
		end if;
		if (pc(12 downto 8) /= "00000") and (jmp_commit = '1') then
			jmp_counter <= jmp_counter + '1';
		end if;
	end if;
  end process;
	
	
	leddotdata <= ledd;
	leddata <= jmp_miss_counter(31 downto 16)&jmp_counter(31 downto 16);
	
--	leddotdata <= ledd;
--	leddata <= led&io_read_buf_overrun&'0'&pc;
 
  led_inst : ledextd2 port map (
      leddata,
      leddotdata,
      outdata0,
      outdata1,
      outdata2,
      outdata3,
      outdata4,
      outdata5,
      outdata6,
      outdata7
    );
    IOU0 : IOU port map (
		clk,iou_enable,
		io(33 downto 32),io(31 downto 0),
		iou_out,RS_RX,RS_TX,
		io_read_buf_overrun,rsrp,rswp
	);
	iou_enable <= ioexec and io(38) and (not flush);
	IOPROC:process(clk)
	begin
		if rising_edge(clk) then
			io_do <= iou_enable;
			if flush = '1' then
				io(38) <= '0';
			elsif iou_enable = '1' then
				io(38) <= '0';
				if io(33) = '1' then--led
  					leddata_buf <= io(31 downto 0);
  				end if;
			elsif (write = '1') and (op(5 downto 3) = "111") then--ledi
				io <= '1'&tagin&op(4 downto 3)&x"000000"&im(7 downto 0);
			elsif (write = '1') and (op(5 downto 3) = "110") then--led
				io <= '1'&tagin&op(4 downto 3)&a;
			elsif (write = '1') and (op(5) = '1') then--io
				io <= '1'&tagin&op(4 downto 3)&a;
			end if;
		end if;
	end process;
		

end arch;

