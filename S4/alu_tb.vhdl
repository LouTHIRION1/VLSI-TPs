-- Testbench for adder
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu_tb is
  -- empty (test bench)
end alu_tb;

architecture testbench of alu_tb is

  -- DUT component
  component Alu is
    port
    (
      -- Operandes + Retenue Carry in
      op1 : in std_logic_vector(31 downto 0);
      op2 : in std_logic_vector(31 downto 0);
      cin : in std_logic;

      -- Commande pour le mux
      cmd : in std_logic_vector(1 downto 0);

      -- Resultat + retenue Carry out
      res  : out std_logic_vector(31 downto 0);
      cout : out std_logic;

      -- Flags
      z : out std_logic; -- Zero
      n : out std_logic; -- Negative
      v : out std_logic; -- Overflow

      -- Tensions
      vdd : in bit;
      vss : in bit
    );
  end component;

  -- Operandes + Retenue Carry in
  signal op1_s : std_logic_vector(31 downto 0);
  signal op2_s : std_logic_vector(31 downto 0);
  signal cin_s : std_logic;

  -- Commande pour le mux
  signal cmd_s : std_logic_vector(1 downto 0);

  -- Resultat + retenue Carry out
  signal res_s  : std_logic_vector(31 downto 0);
  signal cout_s : std_logic;

  -- Flags
  signal z_s : std_logic; -- Zero
  signal n_s : std_logic; -- Negative
  signal v_s : std_logic; -- Overflow

  -- Tensions
  signal vdd_s : bit;
  signal vss_s : bit;

begin
  -- Connect DUT (Device Under Test) / UUT (Unit Under Test)
  DUT : Alu port map
  (
    -- Operandes + Retenue Carry in
    op1 => op1_s,
    op2 => op2_s,
    cin => cin_s,

    -- Commande pour le mux
    cmd => cmd_s,

    -- Resultat + retenue Carry out
    res  => res_s,
    cout => cout_s,

    -- Flags
    z => z_s,
    n => n_s,
    v => v_s,

    -- Tensions
    vdd => vdd_s,
    vss => vss_s
  );
  process
  begin

    ---- SUM TESTS
    report "Sum tests" severity note;

    -- Sum nothing
    op1_s <= x"00000000";
    op2_s <= x"00000000";
    cin_s <= '0';

    cmd_s <= "00"; -- ADD
    wait for 1 ns;
    assert(res_s = x"00000000") report "Incorrect sum" severity error;
    assert(cout_s = '0') report "Incorrect carry out" severity error;
    assert(z_s = '1') report "Zero flag should be '1'" severity error;
    assert(n_s = '0') report "Negative flag should be '0'" severity error;

    -- Sum without Cin
    op1_s <= x"00000001";
    op2_s <= x"00000001";
    cin_s <= '0';

    cmd_s <= "00"; -- ADD
    wait for 1 ns;
    assert(res_s = x"00000002") report "Incorrect sum" severity error;
    assert(cout_s = '0') report "Incorrect carry out" severity error;
    assert(z_s = '0') report "Zero flag should be '0'" severity error;
    assert(n_s = '0') report "Negative flag should be '0'" severity error;

    -- Sum with Cin
    op1_s <= x"00000000";
    op2_s <= x"00000000";
    cin_s <= '1';

    cmd_s <= "00"; -- ADD
    wait for 1 ns;
    assert(res_s = x"00000001") report "Incorrect sum" severity error;
    assert(cout_s = '0') report "Incorrect carry out" severity error;
    assert(z_s = '0') report "Zero flag should be '0'" severity error;
    assert(n_s = '0') report "Negative flag should be '0'" severity error;

    -- Sum without Cin and overflow (Cout)
    op1_s <= x"80000001";
    op2_s <= x"80000001";
    cin_s <= '0';

    cmd_s <= "00"; -- ADD
    wait for 1 ns;
    assert(res_s = x"00000002") report "Incorrect sum" severity error;
    assert(cout_s = '1') report "Incorrect carry out" severity error;
    assert(z_s = '0') report "Zero flag should be '0'" severity error;
    assert(n_s = '0') report "Negative flag should be '0'" severity error;

    -- Sum with Cin and overflow (Cout)
    op1_s <= x"FFFFFFFF";
    op2_s <= x"00000000";
    cin_s <= '1';

    cmd_s <= "00"; -- ADD
    wait for 1 ns;
    assert(res_s = x"00000000") report "Incorrect sum" severity error;
    assert(cout_s = '1') report "Incorrect carry out" severity error;
    assert(z_s = '1') report "Zero flag should be '1'" severity error;
    assert(n_s = '0') report "Negative flag should be '0'" severity error;

    -- Clear inputs
    op1_s <= x"00000000";
    op2_s <= x"00000000";
    wait for 1 ns;

    report "Sum tests completed" severity note;

    ---- LOGIC TESTS
    report "Logic tests" severity note;

    op1_s <= x"FFFFFFFF";
    op2_s <= x"00000000";
    cin_s <= '0';

    cmd_s <= "01"; -- AND
    wait for 1 ns;
    assert(res_s = x"00000000") report "Incorrect sum" severity error;
    assert(cout_s = '0') report "Incorrect carry out" severity error;
    assert(z_s = '1') report "Zero flag should be '1'" severity error;
    assert(n_s = '0') report "Negative flag should be '0'" severity error;

    cmd_s <= "10"; -- OR
    wait for 1 ns;
    assert(res_s = x"FFFFFFFF") report "Incorrect sum" severity error;
    assert(cout_s = '0') report "Incorrect carry out" severity error;
    assert(z_s = '0') report "Zero flag should be '1'" severity error;
    assert(n_s = '0') report "Negative flag should be '0'" severity error;

    cmd_s <= "11"; -- XOR
    wait for 1 ns;
    assert(res_s = x"FFFFFFFF") report "Incorrect sum" severity error;
    assert(cout_s = '0') report "Incorrect carry out" severity error;
    assert(z_s = '0') report "Zero flag should be '1'" severity error;
    assert(n_s = '0') report "Negative flag should be '0'" severity error;

    op1_s <= x"10101010";
    op2_s <= x"01010101";
    cin_s <= '0';

    cmd_s <= "01"; -- AND
    wait for 1 ns;
    assert(res_s = x"00000000") report "Incorrect sum" severity error;
    assert(cout_s = '0') report "Incorrect carry out" severity error;
    assert(z_s = '1') report "Zero flag should be '1'" severity error;
    assert(n_s = '0') report "Negative flag should be '0'" severity error;

    cmd_s <= "10"; -- OR
    wait for 1 ns;
    assert(res_s = x"11111111") report "Incorrect sum" severity error;
    assert(cout_s = '0') report "Incorrect carry out" severity error;
    assert(z_s = '0') report "Zero flag should be '1'" severity error;
    assert(n_s = '0') report "Negative flag should be '0'" severity error;

    cmd_s <= "11"; -- XOR
    wait for 1 ns;
    assert(res_s = x"11111111") report "Incorrect sum" severity error;
    assert(cout_s = '0') report "Incorrect carry out" severity error;
    assert(z_s = '0') report "Zero flag should be '1'" severity error;
    assert(n_s = '0') report "Negative flag should be '0'" severity error;

    op1_s <= x"10101010";
    op2_s <= x"10101010";
    cin_s <= '0';

    cmd_s <= "01"; -- AND
    wait for 1 ns;
    assert(res_s = x"10101010") report "Incorrect sum" severity error;
    assert(cout_s = '0') report "Incorrect carry out" severity error;
    assert(z_s = '0') report "Zero flag should be '1'" severity error;
    assert(n_s = '0') report "Negative flag should be '0'" severity error;

    cmd_s <= "10"; -- OR
    wait for 1 ns;
    assert(res_s = x"10101010") report "Incorrect sum" severity error;
    assert(cout_s = '0') report "Incorrect carry out" severity error;
    assert(z_s = '0') report "Zero flag should be '1'" severity error;
    assert(n_s = '0') report "Negative flag should be '0'" severity error;

    cmd_s <= "11"; -- XOR
    wait for 1 ns;
    assert(res_s = x"00000000") report "Incorrect sum" severity error;
    assert(cout_s = '0') report "Incorrect carry out" severity error;
    assert(z_s = '1') report "Zero flag should be '1'" severity error;
    assert(n_s = '0') report "Negative flag should be '0'" severity error;

    report "Logic tests completed" severity note;

    -- Clear inputs
    op1_s <= x"00000000";
    op2_s <= x"00000000";
    wait for 1 ns;

    report "All tests done." severity note;
    wait;
  end process;
end testbench;