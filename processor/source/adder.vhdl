library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity adder is
  port
  (
    a, b : in std_logic_vector(31 downto 0);
    cin  : in std_logic;

    sum  : out std_logic_vector(31 downto 0);
    cout : out std_logic
  );
end adder;

architecture behavioural of adder is
  signal temp : std_logic_vector(32 downto 0);
begin
  -- Convert signals to 33 bits for carry in
  temp <= std_logic_vector(unsigned('0' & a) + unsigned('0' & b) + unsigned'('0' & cin));
  sum  <= temp(31 downto 0);
  cout <= temp(32);
end behavioural;