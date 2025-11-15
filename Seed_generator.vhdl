library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Seed_generator is
  Port (
    clk        : in  std_logic;
    rst        : in  std_logic;
    start      : in  std_logic;  -- captura seed
    seed_ready : in  std_logic;  -- avança LFSR
    seed       : out std_logic_vector(2 downto 0)
  );
end Seed_generator;

architecture rtl of Seed_generator is
  signal lfsr_r     : std_logic_vector(2 downto 0) := "001";
  signal saved_seed : std_logic_vector(2 downto 0) := "001";
begin

  process(clk)
    variable newbit : std_logic;
    variable next_state : std_logic_vector(2 downto 0);
  begin
    if rising_edge(clk) then

      if rst = '1' then
        lfsr_r     <= "001";
        saved_seed <= "001";

      else

        -- Avança LFSR somente quando seed_ready = '1'
        if seed_ready = '1' then
          newbit := lfsr_r(2) xor lfsr_r(0);
          next_state := newbit & lfsr_r(2 downto 1);

          lfsr_r <= next_state;
        end if;

        -- Captura seed quando start = '1'
        if start = '1' then
          if lfsr_r = "000" then
            saved_seed <= "110";
            report "SEED CAPTURADA COM PROTECAO: 0 -> 110";
          else
            saved_seed <= lfsr_r;
            report "SEED CAPTURADA: " &
                   integer'image(to_integer(unsigned(lfsr_r)));
          end if;
        end if;

      end if;

    end if;
  end process;

  seed <= saved_seed;

end rtl;
