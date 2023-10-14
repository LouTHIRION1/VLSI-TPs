-- Testbench for adder
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adder_tb is
  -- empty (test bench)
end adder_tb;

architecture testbench of adder_tb is

  -- DUT component
  component adder32 is
    port
    (
      a, b : in std_logic_vector(31 downto 0);
      cin  : in std_logic;

      sum  : out std_logic_vector(31 downto 0);
      cout : out std_logic
    );
  end component;

  signal a_s    : std_logic_vector(31 downto 0);
  signal b_s    : std_logic_vector(31 downto 0);
  signal cin_s  : std_logic;
  signal sum_s  : std_logic_vector(31 downto 0);
  signal cout_s : std_logic;

begin
  -- Connect DUT
  DUT : adder32 port map
    (a_s, b_s, cin_s, sum_s, cout_s);
  process
  begin

    -- Sum nothing
    a_s   <= x"00000000";
    b_s   <= x"00000000";
    cin_s <= '0';
    wait for 1 ns;
    assert(sum_s = x"00000000") report "Incorrect sum" severity error;
    assert(cout_s = '0') report "Incorrect carry out" severity error;

    -- Sum without Cin
    a_s   <= x"00000001";
    b_s   <= x"00000001";
    cin_s <= '0';
    wait for 1 ns;
    assert(sum_s = x"00000002") report "Incorrect sum" severity error;
    assert(cout_s = '0') report "Incorrect carry out" severity error;

    -- Sum without Cin and overflow (Cout)
    a_s   <= x"80000001";
    b_s   <= x"80000001";
    cin_s <= '0';
    wait for 1 ns;
    assert(sum_s = x"00000002") report "Incorrect sum" severity error;
    assert(cout_s = '1') report "Incorrect carry out" severity error;

    -- Sum only Cin
    a_s   <= x"00000000";
    b_s   <= x"00000000";
    cin_s <= '1';
    wait for 1 ns;
    assert(sum_s = x"00000001") report "Incorrect sum" severity error;
    assert(cout_s = '0') report "Incorrect carry out" severity error;

    -- Sum with Cin and overflow (Cout)
    a_s   <= x"FFFFFFFF";
    b_s   <= x"00000000";
    cin_s <= '1';
    wait for 1 ns;
    assert(sum_s = x"00000000") report "Incorrect sum" severity error;
    assert(cout_s = '1') report "Incorrect carry out" severity error;

    -- Clear inputs
    a_s <= x"00000000";
    b_s <= x"00000000";

    report "Test done." severity note;
    wait;
  end process;
end testbench;