library ieee;
use ieee.std_logic_1164.all;

entity or_gate is
	port(
		INPUT_1 : in std_logic;
		INPUT_2 : in std_logic;
		OUTPUT : out std_logic);
end entity or_gate;

architecture structure of or_gate is
begin
    OUTPUT <= INPUT_1 or INPUT_2 ;
end architecture structure;
