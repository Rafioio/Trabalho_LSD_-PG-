library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity tb_LFSR is
end tb_LFSR;

architecture sim of tb_LFSR is
    constant CLK_PERIOD : time := 10 ns;

    signal clk       : std_logic := '0';
    signal rst       : std_logic := '1';
    signal enable    : std_logic := '0';
    signal load_seed : std_logic := '0';
    signal seed      : std_logic_vector(2 downto 0) := "010";  -- altere aqui a seed
    signal out_val   : std_logic_vector(2 downto 0);

    file results_file : text open write_mode is "lfsr_results.txt";

begin
    uut: entity work.LFSR_3bit
        port map (
            clk       => clk,
            rst       => rst,
            enable    => enable,
            load_seed => load_seed,
            seed      => seed,
            out_val   => out_val
        );

    -- Clock
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Estímulos
    stim_proc: process
        variable L : line;
        variable val_int : integer;
    begin
        -- Reset
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 10 ns;

        -- Carrega seed inicial
        load_seed <= '1';
        wait for CLK_PERIOD;
        load_seed <= '0';

        enable <= '1';

        -- Roda por 255 ciclos (tamanho máximo do ciclo pra 3 bits)
        for i in 0 to 6 loop
            wait until rising_edge(clk);
            val_int := to_integer(unsigned(out_val));

            write(L, string'("Iter "));
            write(L, i);
            write(L, string'(" | Out "));
            write(L, val_int);
            writeline(results_file, L);
        end loop;

        enable <= '0';
        wait for 50 ns;

        report "Simulação finalizada com sucesso!" severity note;
        wait;
    end process;
end sim;
