--CPU�̃e�X�g���x���`


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity cpu_sram_usb_test is
end cpu_sram_usb_test;

architecture Behavioral of cpu_sram_usb_test is
	signal CLK,RST : STD_LOGIC := '0';
	
	component sram_model is
    Port (
		SRAMAA : in  STD_LOGIC_VECTOR (19 downto 0)	--�A�h���X
		;SRAMIOA : inout  STD_LOGIC_VECTOR (31 downto 0)	--�f�[�^
		;SRAMIOPA : inout  STD_LOGIC_VECTOR (3 downto 0) --�p���e�B�[
		
		;SRAMRWA : in  STD_LOGIC	--read=>1,write=>0
		;SRAMBWA : in  STD_LOGIC_VECTOR (3 downto 0)--�������݃o�C�g�̎w��

		;SRAMCLKMA0 : in  STD_LOGIC	--SRAM�N���b�N
		;SRAMCLKMA1 : in  STD_LOGIC	--SRAM�N���b�N
		
		;SRAMADVLDA : in  STD_LOGIC	--�o�[�X�g�A�N�Z�X
		;SRAMCEA : in  STD_LOGIC --clock enable
		
		;SRAMCELA1X : in  STD_LOGIC	--SRAM�𓮍삳���邩�ǂ���
		;SRAMCEHA1X : in  STD_LOGIC	--SRAM�𓮍삳���邩�ǂ���
		;SRAMCEA2X : in  STD_LOGIC	--SRAM�𓮍삳���邩�ǂ���
		;SRAMCEA2 : in  STD_LOGIC	--SRAM�𓮍삳���邩�ǂ���

		;SRAMLBOA : in  STD_LOGIC	--�o�[�X�g�A�N�Z�X��
		;SRAMXOEA : in  STD_LOGIC	--IO�o�̓C�l�[�u��
		;SRAMZZA : in  STD_LOGIC	--�X���[�v���[�h�ɓ���
	);
	end component;
	
	component cpu_top is
	    Port (

    RS_RX : in STD_LOGIC;
    RS_TX : out STD_LOGIC;
    outdata0 : out std_logic_vector(7 downto 0);
    outdata1 : out std_logic_vector(7 downto 0);
    outdata2 : out std_logic_vector(7 downto 0);
    outdata3 : out std_logic_vector(7 downto 0);
    outdata4 : out std_logic_vector(7 downto 0);
    outdata5 : out std_logic_vector(7 downto 0);
    outdata6 : out std_logic_vector(7 downto 0);
    outdata7 : out std_logic_vector(7 downto 0);

    XE1 : out STD_LOGIC; -- 0
    E2A : out STD_LOGIC; -- 1
    XE3 : out STD_LOGIC; -- 0
    ZZA : out STD_LOGIC; -- 0
    XGA : out STD_LOGIC; -- 0
    XZCKE : out STD_LOGIC; -- 0
    ADVA : out STD_LOGIC; -- we do not use (0)
    XLBO : out STD_LOGIC; -- no use of ADV, so what ever
    ZCLKMA : out STD_LOGIC_VECTOR(1 downto 0); -- clk
    XFT : out STD_LOGIC; -- FT(0) or pipeline(1)
    XWA : out STD_LOGIC; -- read(1) or write(0)
    XZBE : out STD_LOGIC_VECTOR(3 downto 0); -- write pos
    ZA : out STD_LOGIC_VECTOR(19 downto 0); -- Address
    ZDP : inout STD_LOGIC_VECTOR(3 downto 0); -- parity
    ZD : inout STD_LOGIC_VECTOR(31 downto 0); -- bus

    -- CLK_48M : in STD_LOGIC;
    CLK_RST : in STD_LOGIC;
    CLK_66M : in STD_LOGIC
		);
		end component;
	
	component usb_sim
	Port (
		USBWR : in  STD_LOGIC
		;USBRDX : in  STD_LOGIC
		
		;USBTXEX : out  STD_LOGIC
		;USBSIWU : in  STD_LOGIC
		
		;USBRXFX : out  STD_LOGIC
		;USBRSTX : in  STD_LOGIC
		
		;USBD		: inout  STD_LOGIC_VECTOR (7 downto 0)
		);
		end component;

	signal USBWR,USBRDX,USBTXEX,USBSIWU,USBRXFX,USBRSTX : std_logic := '0';
	signal USBD :STD_LOGIC_VECTOR (7 downto 0);	--�A�h���X
	
		
	signal SRAMAA :STD_LOGIC_VECTOR (19 downto 0);	--�A�h���X
	signal SRAMIOA : STD_LOGIC_VECTOR (31 downto 0);	--�f�[�^
	signal SRAMIOPA : STD_LOGIC_VECTOR (3 downto 0); --�p���e�B�[
		
	signal SRAMRWA : STD_LOGIC;	--read=>1,write=>0
	signal SRAMBWA : STD_LOGIC_VECTOR (3 downto 0);--�������݃o�C�g�̎w��

	signal SRAMCLKMA0 : STD_LOGIC;	--SRAM�N���b�N
	signal SRAMCLKMA1 : STD_LOGIC;	--SRAM�N���b�N
	
	signal SRAMCLK :std_logic_vector(1 downto 0) := (others => '0');
		
	signal SRAMADVLDA : STD_LOGIC;	--�o�[�X�g�A�N�Z�X
	signal SRAMCEA : STD_LOGIC; --clock enable
		
	signal SRAMCELA1X : STD_LOGIC;	--SRAM�𓮍삳���邩�ǂ���
	signal SRAMCEHA1X : STD_LOGIC;	--SRAM�𓮍삳���邩�ǂ���
	signal SRAMCEA2X : STD_LOGIC;	--SRAM�𓮍삳���邩�ǂ���
	signal SRAMCEA2 : STD_LOGIC;	--SRAM�𓮍삳���邩�ǂ���
		
	signal SRAMLBOA : STD_LOGIC;	--�o�[�X�g�A�N�Z�X��
	signal SRAMXOEA : STD_LOGIC;	--IO�o�̓C�l�[�u��
	signal SRAMZZA : STD_LOGIC;	--�X���[�v���[�h�ɓ���
	

	signal XFT : STD_LOGIC;	--�X���[�v���[�h�ɓ���
	signal RX,TX : STD_LOGIC;	--RS232C
	signal outdata0,outdata1,outdata2,outdata3,outdata4,outdata5,outdata6,outdata7 : std_logic_vector(7 downto 0) := (others => '0');
begin
	RST <= '0';
	process 
	begin
		CLK <= not CLK;
		wait for 10 ns;
	end process;

	CPU_TOP0 : cpu_top port map(
		RX,TX,
		outdata0,outdata1,outdata2,outdata3,outdata4,outdata5,outdata6,outdata7
		
		--SRAM
		
		,SRAMADVLDA
		,SRAMCELA1X
		,SRAMCEHA1X
		,SRAMCEA
		,SRAMCEA2X
		,SRAMCEA2
		
		,SRAMLBOA
		,SRAMXOEA
		
		,SRAMCLK
		,XFT
		
		,SRAMRWA
		,SRAMBWA
		
		,SRAMAA
		,SRAMIOPA
		,SRAMIOA
		
		,RST,CLK
	);

	SRAM : sram_model  port map(
		SRAMAA
		,SRAMIOA
		,SRAMIOPA
		
		,SRAMRWA
		,SRAMBWA

		,SRAMCLK(1)
		,SRAMCLK(0)
		
		,SRAMADVLDA
		,SRAMCEA
		
		,SRAMCELA1X
		,SRAMCEHA1X
		,SRAMCEA2X
		,SRAMCEA2
		
		,SRAMLBOA
		,SRAMXOEA
		,SRAMZZA

	);
--	USB : usb_sim port map (
--		USBWR,USBRDX,USBTXEX,USBSIWU,USBRXFX,USBRSTX,USBD
--	);

end Behavioral;



