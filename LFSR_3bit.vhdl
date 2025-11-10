library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LFSR_3bit is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        enable    : in  std_logic;
        load_seed : in  std_logic;
        seed      : in  std_logic_vector(2 downto 0);
        out_val   : out std_logic_vector(2 downto 0)
    );
end LFSR_3bit;

architecture rtl of LFSR_3bit is
    signal reg : std_logic_vector(2 downto 0);
begin
    process(clk, rst)
    begin
        if rst = '1' then
            reg <= (others => '0');
        elsif rising_edge(clk) then
            if load_seed = '1' then
                reg <= seed;
            elsif enable = '1' then
                -- taps em bits 7, 5, 4, 3
                -- reg <= reg(6 downto 0) & (reg(7) xor reg(5) xor reg(4) xor reg(3));
                reg <= reg(1 downto 0) & (reg(2) xor reg(1));
            end if;
        end if;
    end process;

    out_val <= reg;
end rtl;
