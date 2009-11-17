library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity rs232ctb is
end rs232ctb;

architecture Behavioral of rs232ctb is
  component echo
  Port (
    RSRXD : in STD_LOGIC;
    RSTXD : out STD_LOGIC;

    clkin : in STD_LOGIC;
    ledout : out STD_LOGIC_VECTOR(7 downto 0)
    );
  end component;
  
  signal clk : std_logic;
  signal reset : std_logic;
  
  signal ledout : std_logic_vector(7 downto 0);
  
  signal RSRXD : STD_LOGIC;
  signal RSTXD : STD_LOGIC;
  
  constant BITLEN : integer := 54;
  constant BITLENTH : integer := BITLEN -1;
  
  constant BUFSIZE : integer := 275;
  constant SENDDATA : STD_LOGIC_VECTOR(0 to (BUFSIZE-1)) :=
  "111"&
  "0"&"00000001"&"11"&
  "0"&"00000011"&"11"&
  "0"&"00000101"&"11"&
  "0"&"00001001"&"1111"&
  "0"&"00010001"&"11"&
  "0"&"00100001"&"11"&
  "0"&"00000001"&"11"&
  "0"&"00000011"&"11"&
  "0"&"00000101"&"11"&
  "0"&"00001001"&"1111"&
  "0"&"00010001"&"11"&
  "0"&"00100001"&"11"&
  "0"&"00000001"&"11"&
  "0"&"00000011"&"11"&
  "0"&"00000101"&"11"&
  "0"&"00001001"&"1111"&
  "0"&"00010001"&"11"&
  "0"&"00100001"&"11"&
  "0"&"00000001"&"11"&
  "0"&"00000011"&"11"&
  "0"&"00000101"&"11"&
  "0"&"00001001"&"1111"&
  "0"&"00010001"&"11"&
  "0"&"00100001"&"11"
  ;
  signal sendpos : integer range 0 to BUFSIZE := 0;
  signal timecounter : integer := 0;
  
  constant recvmargin : integer := 50;
  signal RECVDATA : STD_LOGIC_VECTOR(0 to (BUFSIZE+recvmargin-1));
  signal recvpos : integer range 0 to BUFSIZE+recvmargin := 0;
  
  
begin
  --ibufg_inst : ibufg port map (I => clkin,O => clk);
  roc_inst : roc port map (O => reset);
  test_inst : echo port map(
    RSRXD => RSRXD,
    RSTXD => RSTXD,
    ledout => ledout,
    clkin => clk
  );
  
  process
  begin
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
  end process;
  
  process(clk)
  begin
    if reset = '1' then                 -- asynchronous reset (active low)
      timecounter <= 0;
      sendpos <= 0;
      recvpos <= 0;
      RSRXD<='1';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if sendpos >= BUFSIZE then
        RSRXD<='1';
        if recvpos < (BUFSIZE+recvmargin) then
          RECVDATA(recvpos) <= RSTXD;
          recvpos <= recvpos + 1;
        end if;
      else
        if timecounter = BITLENTH then
          RSRXD <= SENDDATA(sendpos);
          RECVDATA(recvpos) <= RSTXD;
          timecounter <= 0;
          sendpos <= sendpos + 1;
          recvpos <= recvpos + 1;
        else
          timecounter <= timecounter + 1;
        end if;
      end if;
    end if;
  end process;
end Behavioral;


