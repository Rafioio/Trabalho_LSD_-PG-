library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use IEEE.STD_LOGIC_TEXTIO.ALL;

use work.Reorder_Types.all;

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

    signal indices   : integer_vector(0 to 6) := (others => 1);
    signal base_vec  : integer_vector(0 to 6) := (1,2,3,4,5,6,7);
    signal result_vec: integer_vector(0 to 6);

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

    reorder_inst: entity work.Reorder_Vector
    port map (
        indices  => indices,
        base_in  => base_vec,
        base_out => result_vec
    );

        -- Estímulos
    stim_proc: process
        variable L : line;
        variable val_int : integer;
        variable seed_int : integer;
    begin
        -- Reset inicial
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 10 ns;

        -- Loop de 3 execuções com seeds diferentes
        for s in 0 to 2 loop
            -- Define a seed da rodada
            seed_int := s + 1;  -- pode ajustar a fórmula se quiser seeds específicas
            seed <= std_logic_vector(to_unsigned(seed_int, 3));

            -- Carrega nova seed
            load_seed <= '1';
            wait for CLK_PERIOD;
            load_seed <= '0';

            enable <= '1';

            -- Gera os índices com a LFSR
            for i in 0 to 6 loop
                wait until rising_edge(clk);
                val_int := to_integer(unsigned(out_val));
                indices(i) <= val_int;

                write(L, string'("Seed "));
                write(L, seed_int);
                write(L, string'(" | Iter "));
                write(L, i);
                write(L, string'(" | Out "));
                write(L, val_int);
                writeline(results_file, L);
            end loop;

            -- Verifica faixa válida dos índices
            for k in 0 to 6 loop
                assert (indices(k) >= 1 and indices(k) <= 7)
                report "indices(" & integer'image(k) & ") out of range: " & integer'image(indices(k))
                severity error;
            end loop;

            wait for CLK_PERIOD;

            -- Mostra resultado da rodada
            write(L, string'("Nova ordem (seed "));
            write(L, seed_int);
            write(L, string'("): "));
            for i in 0 to 6 loop
                write(L, result_vec(i));
                write(L, string'(" "));
            end loop;
            writeline(results_file, L);

            -- Atualiza vetor base para próxima rodada
            base_vec <= result_vec;

            wait for 50 ns;
        end loop;

        enable <= '0';
        report "Simulação finalizada com sucesso!" severity note;
        wait;
        
    end process;
end sim;