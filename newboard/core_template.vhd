library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity core_template is
  Port (
      leddata   : out std_logic_vector(31 downto 0);
      leddotdata: out std_logic_vector(7 downto 0);

      sramreadmode : out STD_LOGIC; -- 
      sramwritemode : out STD_LOGIC; -- read Ç™óDêÊ
      sramaddr : out STD_LOGIC_VECTOR(19 downto 0);
      sramwritedata : out STD_LOGIC_VECTOR(31 downto 0);
      sramwritedatap : out STD_LOGIC_VECTOR(3 downto 0);
      sramreadcmp : in STD_LOGIC;
      sramreadretaddr : in STD_LOGIC_VECTOR(19 downto 0); -- return address
      sramreaddata : in STD_LOGIC_VECTOR(31 downto 0); -- 
      sramreaddatap : in STD_LOGIC_VECTOR(3 downto 0); -- 

      RSIO_RD : out STD_LOGIC;     -- read êßå‰ê¸
      RSIO_RData : in STD_LOGIC_VECTOR(7 downto 0);  -- read data
      RSIO_RC : in STD_LOGIC;    -- read äÆóπê¸
      RSIO_OVERRUN : in STD_LOGIC;    -- OVERRUNéû1
      RSIO_WD : out STD_LOGIC;     -- write êßå‰ê¸
      RSIO_WData : out STD_LOGIC_VECTOR(7 downto 0);   -- write data
      RSIO_WC : in STD_LOGIC;    -- write äÆóπê¸
      clk66 : in  STD_LOGIC;
      clk133 : in  STD_LOGIC;
      rst : in  STD_LOGIC
    );
end core_template;

architecture Behavioral of core_template is
begin
  RSIO_RD<='0';
  RSIO_WD<= '0';
  RSIO_WData<=(others=>'0');
  
  sramreadmode<='0';
  sramwritemode<='0';
  sramaddr<=(others=>'0');
  sramwritedata<=(others=>'0');
  sramwritedatap<=(others=>'0');
  
  leddata<=(others=>'0');
  leddotdata<=not ("00000000");

  process (clk133, rst)
  begin  -- process
    if rst = '1' then                   -- asynchronous reset
    elsif clk133'event and clk133 = '1' then  -- rising clock edge
    end if;
  end process;

end Behavioral;

