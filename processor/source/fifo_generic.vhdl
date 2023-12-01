library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fifo is
  generic
    (N : integer); -- FIFO Size
  port
  (
    din  : in std_logic_vector(N - 1 downto 0);
    dout : out std_logic_vector(N - 1 downto 0);

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

  signal fifo_d : std_logic_vector(N - 1 downto 0); -- FIFO data 
  signal fifo_v : std_logic;                        -- Validité

begin

  process (ck)
  begin
    if rising_edge(ck) then
      -- Synchronous reset (active low)
      if (reset_n = '0') then
        -- Invalid FIFO
        fifo_v <= '0';
      else
        -- If FIFO is invalid 
        if (fifo_v = '0') then
          -- and we Push contents into it
          if (push = '1') then
            fifo_v <= '1'; -- FIFO is valid once there is data inside
            fifo_d <= din; -- FIFO data <- Data In
          end if;
        else
          -- If FIFO is valid
          -- we Pop the contents from it
          if (pop = '1') then
            -- And immediately push new data in
            if (push = '1') then
              fifo_v <= '1'; -- FIFO is valid once there is data inside
              fifo_d <= din; -- FIFO data <- Data In
            else
              fifo_v <= '0'; -- FIFO is invalid because there is no more data inside
            end if;
          else
            fifo_v <= '1'; -- FIFO is still valid because there is data inside
          end if;
        end if;
      end if; -- Reset
    end if; -- Rising edge
  end process;

  ---- Assign outputs
  -- FIFO is full when valid (data inside) and there hasn't been a pop yet
  full <= '1' when (fifo_v = '1' and pop = '0') else
    '0';
  -- FIFO is empty when invalid
  empty <= not fifo_v;
  -- Data out <- FIFO Data
  dout <= fifo_d;

end dataflow;