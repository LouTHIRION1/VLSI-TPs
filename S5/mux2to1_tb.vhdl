library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux2to1_tb is
  -- empty (test bench)
end mux2to1_tb;

architecture behavior of mux2to1_tb is

  -- Component Declaration for the Unit Under Test (UUT)
  -- unit under test
  component mux2to1
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
  end component;

  --Inputs
  signal a_s   : std_logic_vector(31 downto 0) := x"00000000";
  signal b_s   : std_logic_vector(31 downto 0) := x"00000000";
  signal cmd_s : std_logic                     := '0';
  signal vdd_s : bit;
  signal vss_s : bit;

  --Outputs
  signal s_s : std_logic_vector(31 downto 0)
  ;
begin

  -- Instantiate the Unit Under Test (UUT)
  uut : mux2to1 port map
  (
    a   => a_s,
    b   => b_s,
    cmd => cmd_s,
    s   => s_s,
    vdd => vdd_s,
    vss => vss_s
  );
  process
  begin
    a_s   <= x"00000001";
    b_s   <= x"10000000";
    cmd_s <= '0';
    wait for 1 ns;
    assert(s_s = x"00000001") report "Error, expected 0x00000001, s = 0x" & to_hstring(s_s) severity error;

    a_s   <= x"00000001";
    b_s   <= x"10000000";
    cmd_s <= '1';
    wait for 1 ns;
    assert(s_s = x"10000000") report "Error, expected 0x10000000, s = 0x" & to_hstring(s_s) severity error;

    report "Tests done." severity note;
    wait;
  end process;
end;