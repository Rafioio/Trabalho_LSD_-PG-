library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Types.all;

entity LFSR_3bits is
    port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        enable_lfsr   : in  std_logic;
        load_seed     : in  std_logic;
        seed          : in  std_logic_vector(2 downto 0);
        indice_vector : out array_3X7bits;
        indice_vector_ready : out std_logic
    );
end LFSR_3bits;

architecture rtl of LFSR_3bits is

    signal reg        : std_logic_vector(2 downto 0) := "001";
    signal results    : array_3X7bits := (others => "000");
    signal count      : integer range 0 to 7 := 0;
    signal running    : std_logic := '0';
    signal prev_enable : std_logic := '0';

begin

process(clk, rst)
    variable temp : std_logic_vector(2 downto 0);
    variable newbit : std_logic;
begin
    if rst = '1' then
        reg     <= "001";
        results <= (others => "000");
        count      <= 0;
        running    <= '0';
        prev_enable <= '0';
        indice_vector_ready <= '0';

    elsif rising_edge(clk) then
        prev_enable <= enable_lfsr;
        indice_vector_ready <= '0';

        -- Detecta borda de subida do enable
        if enable_lfsr = '1' and prev_enable = '0' then
            running <= '1';
            count <= 0;
            results(0) <= reg;
        end if;

        if load_seed = '1' then
            if seed /= "000" then
                reg <= seed;
            else
                reg <= "001";
            end if;

        elsif running = '1' then
            -- Lógica LFSR: polinômio x³ + x² + 1
            newbit := reg(2) xor reg(1);
            temp := reg(1 downto 0) & newbit;
            
            reg <= temp;
            
            if count < 6 then
                count <= count + 1;
                results(count + 1) <= temp;
            else
                running <= '0';
                indice_vector_ready <= '1';
            end if;
        end if;
    end if;
end process;

indice_vector <= results;

end rtl;