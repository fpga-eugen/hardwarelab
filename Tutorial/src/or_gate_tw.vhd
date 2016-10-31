library ieee ;
use ieee.std_logic_1164.all;

entity or_gate_tw is

end or_gate_tw ;

architecture testbench of or_gate_tw is

	signal A : std_logic := '0';
	signal B : std_logic := '0';
	signal C : std_logic;

	component or_gate
		port ( INPUT_1 : in std_logic;
		INPUT_2 : in std_logic;
		OUTPUT : out std_logic );
	end component;

begin

	A <= '1' after 20 ns, '0' after 60 ns;
	B <= '1' after 40 ns, '0' after 80 ns;

	uut : or_gate
		port map ( INPUT_1 => A,
		INPUT_2 => B,
		OUTPUT => C );

end testbench ;