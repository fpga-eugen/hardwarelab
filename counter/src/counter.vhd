library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
  port(
    EXT_RST : in std_logic;
    EXT_CLK : in std_logic;
    EXT_LED : out std_logic_vector(7 downto 0)
  );
end entity counter;

architecture fast of counter is
  signal counter : unsigned(7 downto 0):=(others => '0');
begin
  ff:process (EXT_CLK, EXT_RST)
  begin
    if (EXT_RST = '1') then
      counter <=  "00000000";
    else --(EXT_CLK = '1')
      counter <= counter + 1 ;
    end if;
  end process ff;
  EXT_LED <= std_logic_vector(counter);
end fast;
