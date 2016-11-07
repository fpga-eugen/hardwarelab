library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_tw is
end counter_tw;

architecture testbench of counter_tw is

  signal A : std_logic := '0';
  signal B : std_logic := '0';
  signal C : std_logic_vector(7 downto 0) := "00000000";

  component counter
    port (
    EXT_RST : in std_logic;
    EXT_CLK : in std_logic;
    EXT_LED : out std_logic_vector (7 downto 0));
  end component;

begin

  A <= '1' after 20 ns, '0' after 20 ns;
	B <= '1' after 0 ns, '0' after 40 ns;

  uut : counter
		port map (
    EXT_RST => A,
		EXT_CLK => B,
		EXT_LED => C );

end testbench ;
