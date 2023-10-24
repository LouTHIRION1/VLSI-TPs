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
    s   : out std_logic_vector(31 downto 0)
  );
end mux2to1;

-- Description de l'alu structurelle (parallele)
architecture Behavioral of mux2to1 is
begin
  s <= a when (cmd = '0') else
    b;
end Behavioral;

-- Process (sequentielle)
-- architecture Behavioral_process of mux2to1 is
-- begin
--   process (a, b, cmd)
--   begin
--     if (cmd = '0') then
--       s <= a;
--     else
--       s <= b;
--     end if;
--   end process;
-- end Behavioral_process;