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
use work.armtypes.all;


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

	component mux2
	port (s : in std_logic;
	      a,b : in std_logic_vector (29 downto 0);
	      y   : out std_logic_vector (29 downto 0)
	      );
	end component mux2;


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

	signal	IAR_LOAD_MUX2_OUT  : std_logic_vector(31 downto 2);
	signal	inital_Instruktionsadressregister : std_logic_vector(31 downto 2);
	signal	IAR_INC_MUX2_OUT  : std_logic_vector(31 downto 2);
	signal	ArmRamBuffer_OUT : std_logic_vector(29 downto 0);
	signal	IAR_ADDR_IN_plus1 : std_logic_vector(29 downto 0);
	signal	Instruktionsadressregister : std_logic_vector(29 downto 0);
	signal	ENABLE_Instruktionsadressregister : std_logic := '0';

	--	generic(
		--IAR_LOAD_MUX2_OUT : std_logic_vector(31 downto 2);
		--IAR_INC_MUX2_OUT : std_logic_vector(31 downto 2);
		-- std_logic_vector(ARB_DATA_WIDTH-1 downto 0);--ARB_DATA_WIDTH not def?
		--ArmRamBuffer_IN std_logic_vector(ARB_DATA_WIDTH-1 downto 0);
	--	IAR_ADDR_IN_plus1 std_logic_vector(29 downto 0)
begin


	IAR_LOAD_MUX2 : mux2
	port map(
		a => IAR_INC_MUX2_OUT,
		b => IAR_ADDR_IN,
		s => IAR_LOAD,
		y => IAR_LOAD_MUX2_OUT
	);

	IAR_INC_MUX2 : MUX2
	port map(
		a => Instruktionsadressregister,
		b => IAR_ADDR_IN_plus1,
		s => IAR_INC,
		y => IAR_INC_MUX2_OUT
	);

	IAR_REVOKE_MUX2 : MUX2
	port map(
		a => IAR_ADDR_IN_plus1,
		b => ArmRamBuffer_OUT,
		s => IAR_REVOKE,
		y => IAR_NEXT_ADDR_OUT
	);

	IAR_HISTORY_BUFFER: ArmRamBuffer
	generic map(
			ARB_ADDR_WIDTH => INSTRUCTION_ID_WIDTH,
			ARB_DATA_WIDTH => 30
		)
	port map(
		ARB_CLK		=> IAR_CLK,
		ARB_WRITE_EN	=> IAR_UPDATE_HB,
		ARB_ADDR	=> IAR_HISTORY_ID,
		ARB_DATA_IN	=> Instruktionsadressregister,
		ARB_DATA_OUT	=> ArmRamBuffer_OUT
	);

	IAR_ADDR_OUT <= Instruktionsadressregister;
	IAR_ADDR_IN_plus1 <= std_logic_vector(unsigned(Instruktionsadressregister) + 1);
	process(IAR_CLK)
		begin
			if( rising_edge(IAR_CLK)) then
				if (IAR_RST = '1') then
						Instruktionsadressregister <= (others=>'0');
						ENABLE_Instruktionsadressregister <= '1';
				else
					if (ENABLE_Instruktionsadressregister = '1') then
						Instruktionsadressregister <= IAR_LOAD_MUX2_OUT;
					end if;
				end if;
			end if;

		end process;



end architecture behave;
