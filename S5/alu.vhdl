library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Declaration de l'interface
entity Alu is
  port
  (
    ---- Inputs
    -- Operandes + Retenue Carry in
    op1 : in std_logic_vector(31 downto 0);
    op2 : in std_logic_vector(31 downto 0);
    cin : in std_logic;
    -- Commande pour le mux
    cmd : in std_logic_vector(1 downto 0);

    ---- Output
    -- Resultat + retenue Carry out
    res  : out std_logic_vector(31 downto 0);
    cout : out std_logic;
    -- Flags
    z : out std_logic; -- Zero (1 if zero, 0 otherwise)
    n : out std_logic; -- Negative (1 if negative, 0 if positive)
    v : out std_logic; -- Overflow (1 if overflow, 0 otherwise)

    ---- 
    -- Tensions
    vdd : in bit;
    vss : in bit
  );
end Alu;

-- Description de l'alu
architecture Behavioral of alu is

  component adder32 is
    port
    (
      -- Inputs
      a, b : in std_logic_vector(31 downto 0);
      cin  : in std_logic;
      -- Outputs
      sum  : out std_logic_vector(31 downto 0);
      cout : out std_logic
    );
  end component;

  signal adder_out  : std_logic_vector(31 downto 0); -- sortie du adder
  signal adder_cout : std_logic;                     -- retenue du adder
  signal res_s      : std_logic_vector(31 downto 0); -- sortie du adder

  signal cmd_s  : std_logic_vector(1 downto 0);
  signal cout_s : std_logic;
  signal z_f    : std_logic;
  signal n_f    : std_logic;
  signal v_f    : std_logic;

begin

  addr : adder32 port map
  (
    a    => op1,
    b    => op2,
    cin  => cin,
    sum  => adder_out,
    cout => adder_cout);

  process (cmd, res_s, z_f, n_f, v_f, adder_out, adder_cout) is
  begin
    ---- Multiplexor selector
    case cmd is
        -- Add avec Cin
      when "00" =>
        res_s  <= adder_out;
        cout_s <= adder_cout;

        -- AND
      when "01" =>
        res_s <= op1 and op2;

        -- OR
      when "10" =>
        res_s <= op1 or op2;

        -- XOR
      when "11" =>
        res_s <= op1 xor op2;

      when others =>
        null;
    end case;

    ---- Flag tests
    -- Zero flag
    if (res_s = x"00000000") then -- Don't forget to include all zeroes, checking for "0" won't work!
      z_f <= '1';
    else
      z_f <= '0';
    end if;

    -- Negative flag
    if (res_s(31) = '1') then
      n_f <= '1';
    else
      n_f <= '0';
    end if;

    -- Overflow flag (Does not matter for unsigned arithmetic)
    -- More info : http://teaching.idallen.com/dat2343/11w/notes/040_overflow.txt
    -- Positive sum
    if (((op1(31) = '0') and (op2(31) = '0') and (res_s(31) = '1'))
      or ((op1(31) = '1') and (op2(31) = '1') and (res_s(31) = '0'))) then
      v_f <= '1';
    else
      v_f <= '0';
    end if;
  end process;

  -- Affect signals
  res  <= res_s;  -- Result
  cout <= cout_s; -- Carry out
  z    <= z_f;    -- Zero flag
  n    <= n_f;    -- Negative flag
  v    <= v_f;    -- Overflow flag

end Behavioral;