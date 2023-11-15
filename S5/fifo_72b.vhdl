library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fifo is
  port
  (
    din  : in std_logic_vector(71 downto 0);
    dout : out std_logic_vector(71 downto 0);

    -- commands
    push : in std_logic; -- Push data into FIFO
    pop  : in std_logic; -- Pop data from FIFO

    -- Flags
    full  : out std_logic; -- 1 when FIFO is full, 0 otherwise
    empty : out std_logic; -- 1 when FIFO is empty, 0 otherwise

    reset_n : in std_logic; -- Reset (active low)
    ck      : in std_logic; -- Clock
    vdd     : in bit;
    vss     : in bit
  );
end fifo;

architecture dataflow of fifo is

  signal fifo_d : std_logic_vector(71 downto 0); -- FIFO data 
  signal fifo_v : std_logic;                     -- Validité

begin

  process (ck)
  begin
    if rising_edge(ck) then
      report "fifo_v : " & std_logic'image(fifo_v)(2);

      -- Synchronous reset
      if (reset_n = '0') then
        fifo_v <= '0'; -- Empty FIFO
      else
        if (fifo_v = '0') then
          if (push = '1') then
            fifo_v <= '1';
          else
            fifo_v <= '0';
          end if;
        else
          if (pop = '1') then
            if (push = '1') then
              fifo_v <= '1';
            else
              fifo_v <= '0';
            end if;
          else
            fifo_v <= '1';
          end if;
        end if;
      end if;

      -- data
      if (fifo_v = '0') then
        if (push = '1') then
          fifo_d <= din;
        end if;
      elsif (push = '1' and pop = '1') then
        fifo_d <= din;
      end if;
    end if;
  end process;

  full <= '1' when (fifo_v = '1' and pop = '0') else
    '0';
  empty <= not fifo_v;
  dout  <= fifo_d;

end dataflow;