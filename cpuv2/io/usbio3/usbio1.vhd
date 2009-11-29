library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--clock = 20ns!!!

entity usbio is
    Port (
           CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           -- �����瑤���g��
           USBIO_RD : in STD_LOGIC;     -- read �����
           USBIO_RData : out STD_LOGIC_VECTOR(7 downto 0);      -- read data
           USBIO_RC : out STD_LOGIC;    -- read ������
           USBIO_WD : in STD_LOGIC;     -- write �����
           USBIO_WData : in STD_LOGIC_VECTOR(7 downto 0);       -- write data
           USBIO_WC : out STD_LOGIC;    -- write ������
			  
			  USBIO_CAN_READ : out STD_LOGIC;    -- read ���S������
			  USBIO_CAN_WRITE : out STD_LOGIC;    -- write ���S������
			  
           --ledout : out STD_LOGIC_VECTOR(7 downto 0);

           -- FT245BM ���ɂȂ�
           USBRD : out  STD_LOGIC;
           USBRXF : in  STD_LOGIC;
           USBWR : out  STD_LOGIC;
           USBTXE : in  STD_LOGIC;
           USBSIWU : out  STD_LOGIC;
           USBD : inout  STD_LOGIC_VECTOR (7 downto 0)
           
           );
end usbio;

architecture Behavioral of usbio is
  --���Ԃ̓N���b�N�Ŋ���
  --states
  constant WAIT_INST :          STD_LOGIC_VECTOR(6 downto 0) := "1111100";

  constant WAIT_RFX :           STD_LOGIC_VECTOR(6 downto 0) := "0101100";
  constant WAIT_AFT_RD_L :      STD_LOGIC_VECTOR(6 downto 0) := "0101000";
  constant WAIT_AFT_READ_D :    STD_LOGIC_VECTOR(6 downto 0) := "0111000";
  constant WAIT_AFT_RD_H :      STD_LOGIC_VECTOR(6 downto 0) := "0111100";

  constant WAIT_TXF :           STD_LOGIC_VECTOR(6 downto 0) := "1010100";
  constant WAIT_AFT_WR_H :      STD_LOGIC_VECTOR(6 downto 0) := "1010111";
  constant WAIT_AFT_WR_L :      STD_LOGIC_VECTOR(6 downto 0) := "1010101";
  constant WAIT_AFT_WRITE :     STD_LOGIC_VECTOR(6 downto 0) := "1010100";
  
  signal state : STD_LOGIC_VECTOR(6 downto 0) := WAIT_INST;
  signal intstate : integer range 8 downto 0 := 0;
  signal timecounter : integer range  7 downto 0;
  signal wdata : STD_LOGIC_VECTOR(7 downto 0);
  signal rdata : STD_LOGIC_VECTOR(7 downto 0);
begin
  --ledout <= not(state & CLK & "1");
  --ledout <= not wdata;

  state <=
    WAIT_INST       when (intstate = 0) else
	 WAIT_RFX        when (intstate = 1) else
	 WAIT_AFT_RD_L   when (intstate = 2) else
	 WAIT_AFT_READ_D when (intstate = 3) else
	 WAIT_AFT_RD_H   when (intstate = 4) else
	 WAIT_TXF        when (intstate = 5) else
	 WAIT_AFT_WR_H   when (intstate = 6) else
	 WAIT_AFT_WR_L   when (intstate = 7) else
	 WAIT_AFT_WRITE;
  USBSIWU<='1';
  USBIO_CAN_READ <= state(6);
  USBIO_CAN_WRITE <= state(5);
  USBIO_RC <= state(4);
  USBIO_WC <= state(3);
  USBRD <= state(2);
  USBWR <= state(1);
  USBD <= (others=>'Z') when state(0) = '0' else wdata;
  USBIO_RData <= rdata;
  
  process (clk, rst)
  begin  -- process
    if rst = '1' then                   -- asynchronous reset
      rdata<="00000000";                -- dummy
      timecounter <= 0;
		intstate <= 0;
      intstate<=0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      case intstate is
        when 0 =>
          if USBIO_RD = '1' then
            if USBRXF = '1' then
              timecounter<=0;
              intstate<=1;
            else
              timecounter<=1;
              intstate<=2;
            end if;
          elsif USBIO_WD = '1' then
            if USBTXE = '1' then
              wdata <= USBIO_WData;
              timecounter<=0;
              intstate<=5;
				else
              wdata <= USBIO_WData;
              timecounter<=1;
              intstate<=6;
				end if;
			 else
            timecounter <= 0;
            intstate <= 0;
          end if;
        when 1 =>
          if USBRXF = '1' then
            timecounter<=0;
            intstate<=1;
          else
            timecounter<=1;
            intstate<=2;
          end if;
        when 2 =>
          if timecounter = 2 then       -- T1
            rdata<=USBD;
            timecounter<=1;
            intstate<=3;
          else
            timecounter <= timecounter + 1;
            intstate<=2;
          end if;
        when 3 =>
          --if timecounter = 1 then     -- T2
            timecounter<=1;
            intstate<=4;
          --else
            --rdata<=rdata;
            --timecounter<=timecounter+1;
            --state<=3;
          --end if;
        when 4 =>
          if timecounter = 2 then       -- T3
            timecounter <= 0;
            intstate <= 0;
          else
            timecounter <= timecounter + 1;
            intstate <= 4;
          end if;
        when 5 =>
          if USBTXE = '1' then
            timecounter <= 0;
            intstate <= 5;
          else
            timecounter <= 1;
            intstate <= 6;
          end if;
        when 6 =>
          if timecounter = 3 then       -- T4
            timecounter <= 1;
            intstate <= 7;
          else
            timecounter <= timecounter + 1;
            intstate <= 6;
          end if;
        when 7 =>
          --if timecounter = 1 then     -- T5
            timecounter <= 1;
            intstate <= 8;
          --else
            --rdata<=rdata;
            --timecounter <= timecounter + 1;
            --state <= 7;
          --end if;
--        when WAIT_AFT_WRITE =>
          --if timecounter = 1 then     -- T6
--            timecounter <= 0;
--            state <= WAIT_INST;
          --else
            --rdata<=rdata;
            --timecounter <= timecounter + 1;
            --state <= WAIT_AFT_WRITE;
          --end if;
        when others =>                  --8
            timecounter <= 0;
            intstate <= 0;
      end case;
    end if;
  end process;
end Behavioral;

