library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Declaration de l'interface
entity mux2to1 is
  port
  (
    a   : in std_logic_vector(31 downto 0);
    b   : in std_logic_vector(31 downto 0);
    cmd : in std_logic;
    s   : out std_logic_vector(31 downto 0);
    -- Global interface
    vdd : in bit;
    vss : in bit
  );
end mux2to1;

-- Description de l'alu
architecture Behavioral of mux2to1 is

begin

  process (a, b, cmd)
  begin
    if (cmd = '0') then
      s <= a;
    else
      s <= b;
    end if;
  end process;
end Behavioral;