--の

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity usb2 is
	Port (
		CLK : in  STD_LOGIC
		
		;do : in STD_LOGIC
		;read_write : in STD_LOGIC
		;data_write : in STD_LOGIC_VECTOR (7 downto 0)
		;data_read : out STD_LOGIC_VECTOR (7 downto 0)
		
		;status : out STD_LOGIC_VECTOR (2 downto 0)
		
		;USBWR : out  STD_LOGIC
		;USBRDX : out  STD_LOGIC
		
		;USBTXEX : in  STD_LOGIC
		;USBSIWU : out  STD_LOGIC
		
		;USBRXFX : in  STD_LOGIC
		;USBRSTX : out  STD_LOGIC
		
		;USBD		: inout  STD_LOGIC_VECTOR (7 downto 0)
		);
end usb2;

architecture Behavioral of usb2 is
	signal RXF : STD_LOGIC := '0';
	signal TXE : STD_LOGIC := '0';
	
	type USB_STATE is ( IDLE,R1,R2,R3,R4,R5 ,W1,W2,W3,W4,W5,W6,W7,E);
	--IDLE	アイドル
	--R1	読み込み準備
	--R2	wait
	--R3	読み込み
	--R4	読み込み終了
	--R5	wait
	--W1	書き込み待ち
	--W2	書き込み開始
	--W3	書き込みwait
	--W4	書き込みwait
	--W5	書き込みwait
	--W6	書き込み終了
	--W7	wait IDLEへ
	
	signal ustate : USB_STATE := IDLE;
	signal datain	: STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal dataout	: STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	
	signal error	: STD_LOGIC := '0';
	
	COMPONENT dff is
		Port (
			D : in  STD_LOGIC
			;CLK : in  STD_LOGIC
			;Q : out  STD_LOGIC
		);
	end COMPONENT;
begin

	RXFBUF : DFF port map(USBRXFX,clk,RXF);
	TXEBUF : DFF port map(USBTXEX,clk,TXE);
	

  R: for I IN datain'range generate 
	R : DFF port map(datain(I),clk,dataout(I));
  end generate;	
	
	USBRSTX <= '1';
	USBSIWU <= '0';

	with ustate select
	USBRDX <= '0' when R1 | R2 | R3,
	'1' when others;
	
	with ustate select
	USBWR <= '1' when W2 | W3 | W4 | W5,
	'0' when others;

	with ustate select
	USBD <= dataout when W2 | W3 | W4 | W5,
	(others=>'Z') when others;
	
	datain <= USBD when ustate = R3 else
	data_write when ustate = IDLE and read_write = '1' else
	dataout;
	
	data_read <= dataout;
	
	status(0) <= '1' when do = '1' and read_write = '0' else
	'0' when ustate = IDLE else
	 '1';
	 
	--ミスったかどうか
	status(1) <= '0' when ustate = IDLE else
	 '1';
	status(2) <= error;
	 
	process (CLK) begin
		if (CLK'event and CLK='1') then
			case ustate is
				when IDLE =>
					if do = '1' then
						if (RXF = '0' and read_write = '0') then--読み込み
							ustate <= R1;
							error <= '0';
						elsif (TXE = '0'and read_write = '1') then
							ustate <= W2;
							error <= '0';
						else
							ustate <= IDLE;
							error <= '1';
						end if;
					else
						ustate <= IDLE;
						error <= '0';
					end if;
				when R1 => ustate <= R2;
				when R2 => ustate <= R3;
				when R3 => ustate <= R4;
				when R4 => ustate <= R5;
				when R5 => ustate <= E;
				when E => ustate <= IDLE;
				when W1 =>  ustate <= IDLE;
				when W2 => ustate <= W3;
				when W3 => ustate <= W4;
				when W4 => ustate <= W5;
				when W5 => ustate <= W6;
				when W6 => ustate <= W7;
				when W7 => ustate <= IDLE;
				when others => ustate <= IDLE;
			end case;
		end if;
	end process;


end Behavioral;

