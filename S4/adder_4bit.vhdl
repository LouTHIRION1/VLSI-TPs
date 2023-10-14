library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity adder4 is
  port
  (
    a, b : in std_logic_vector(3 downto 0);
    cin  : in std_logic;

    sum  : out std_logic_vector(3 downto 0);
    cout : out std_logic
  );
end adder4;

architecture behavioural of adder4 is
  signal temp : std_logic_vector(4 downto 0);
begin
  -- Convert signals to 33 bits for carry in
  temp <= std_logic_vector(unsigned('0' & a) + unsigned('0' & b) + unsigned'('0' & cin));
  sum  <= temp(3 downto 0);
  cout <= temp(4);
end behavioural;