library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Seed_generator is
  Port (
    clk        : in  std_logic;
    rst        : in  std_logic;
    start      : in  std_logic;
    save_seed  : in  std_logic;
    seed       : out std_logic_vector(2 downto 0)
  );
end Seed_generator;

architecture rtl of Seed_generator is
  signal lfsr_r     : std_logic_vector(2 downto 0) := "001"; -- estado atual da LFSR
  signal saved_seed : std_logic_vector(2 downto 0) := "001"; -- valor salvo
begin

  ------------------------------------------------------------------
  --  LFSR 3 bits (x^3 + x + 1)
  ------------------------------------------------------------------
  process(clk)
    variable newbit : std_logic;
  begin
    if rising_edge(clk) then
      if rst = '1' then
        lfsr_r <= "001";  -- reset volta para 001
      elsif start = '1' then
        newbit := lfsr_r(2) xor lfsr_r(0);
        lfsr_r <= newbit & lfsr_r(2 downto 1);  -- gira LFSR
      end if;
    end if;
  end process;

  ------------------------------------------------------------------
  --  Atualiza a seed salva (somente quando save_seed = '1')
  ------------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        saved_seed <= "001";
      elsif save_seed = '1' then
        saved_seed <= lfsr_r;
      end if;
    end if;
  end process;

  ------------------------------------------------------------------
  --  Saída da seed (a última salva)
  ------------------------------------------------------------------
  seed <= saved_seed;

end rtl;
