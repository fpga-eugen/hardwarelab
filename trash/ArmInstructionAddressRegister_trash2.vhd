--------------------------------------------------------------------------------
--	Instruktionsadressregister-Modul fuer den HWPR-Prozessor
--------------------------------------------------------------------------------
--	Datum:		29.10.2013
--	Version:	0.1
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ArmTypes.INSTRUCTION_ID_WIDTH;
use work.ArmTypes.VCR_RESET;

entity ArmInstructionAddressRegister is
	port(
		IAR_CLK 	: in std_logic;
		IAR_RST 	: in std_logic;
		IAR_INC		: in std_logic;
		IAR_LOAD 	: in std_logic;
		IAR_REVOKE	: in std_logic;
		IAR_UPDATE_HB	: in std_logic;
--------------------------------------------------------------------------------
--	INSTRUCTION_ID_WIDTH  ist ein globaler Konfigurationsparameter
--	zur Einstellung der Breite der Instruktions-IDs und damit der Tiefe
--	der verteilten Puffer. Eine Breite von 3 Bit genuegt fuer die
--	fuenfstufige Pipeline definitiv.
--------------------------------------------------------------------------------
		IAR_HISTORY_ID	: in std_logic_vector(INSTRUCTION_ID_WIDTH-1 downto 0);
		IAR_ADDR_IN 	: in std_logic_vector(31 downto 2);
		IAR_ADDR_OUT 	: out std_logic_vector(31 downto 2);
		IAR_NEXT_ADDR_OUT : out std_logic_vector(31 downto 2)
	    );

end entity ArmInstructionAddressRegister;

architecture behave of ArmInstructionAddressRegister is

	component ArmRamBuffer
	generic(
		ARB_ADDR_WIDTH : natural range 1 to 4 := 3;
		ARB_DATA_WIDTH : natural range 1 to 64 := 32
	       );
	port(
		ARB_CLK 	: in std_logic;
		ARB_WRITE_EN	: in std_logic;
		ARB_ADDR	: in std_logic_vector(ARB_ADDR_WIDTH-1 downto 0);
		ARB_DATA_IN	: in std_logic_vector(ARB_DATA_WIDTH-1 downto 0);
		ARB_DATA_OUT	: out std_logic_vector(ARB_DATA_WIDTH-1 downto 0)
		);
	end component ArmRamBuffer;

signal	IAR_LOAD_IN_B  : std_logic_vector(31 downto 2);
signal	IAR_LOAD_OUT  : std_logic_vector(31 downto 2);
signal	IAR_INC_OUT  : std_logic_vector(31 downto 2);
signal	IAR_REVOKE_OUT : std_logic_vector(31 downto 2);
signal	ArmRamBuffer_OUT : std_logic_vector(31 downto 0);--ARB_DATA_WIDTH not def?
signal	IAR_ADDR_IN_plus1 : std_logic_vector(29 downto 0);

begin

	IAR_HISTORY_BUFFER: ArmRamBuffer
	generic map(
			ARB_ADDR_WIDTH => INSTRUCTION_ID_WIDTH,
			ARB_DATA_WIDTH => 30
		)
		port map(
			ARB_CLK		=> IAR_CLK, --rly????
			ARB_WRITE_EN	=> IAR_UPDATE_HB,
			ARB_ADDR	=> IAR_HISTORY_ID,
			ARB_DATA_IN	=> IAR_ADDR_OUT,
			ARB_DATA_OUT	=> ArmRamBuffer_OUT
		);


			process(IAR_CLK)--same as ARB_CLK ???

			begin




				if( rising_edge(IAR_CLK) and IAR_RST = '0') then
					case( IAR_LOAD ) is
						when '0' => IAR_LOAD_OUT <= IAR_INC_OUT;
						when '1' => IAR_LOAD_OUT <= IAR_ADDR_IN;
						when others => IAR_LOAD_OUT <= (others 'X');
					end case;
					 IAR_ADDR_IN_plus1 <= std_logic_vector(unsigned(IAR_LOAD_MUX2_OUT) + 1);
					 case( IAR_INC ) is
							when '0' => IAR_LOAD_OUT <= IAR_INC_OUT;
 							when '1' => IAR_LOAD_OUT <= IAR_ADDR_IN;
							when others => IAR_INC_OUT <= (others 'X');
					 end case;
					IAR_ADDR_OUT <= IAR_LOAD_OUT;
					case( IAR_REVOKE ) is
						when '0' => IAR_REVOKE_OUT <= IAR_ADDR_IN_plus1;
						when '1' => IAR_REVOKE_OUT <= ArmRamBuffer_OUT;
						when others => IAR_REVOKE_OUT <= (others 'X');
					end case;




			end process;

end architecture behave;
