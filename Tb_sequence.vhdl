library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use IEEE.STD_LOGIC_TEXTIO.ALL;

use work.Reorder_Types.all;

entity Tb_sequence is
end Tb_sequence;

architecture sim of Tb_sequence is
    constant CLK_PERIOD : time := 10 ns;

    -- 🔹 Sinais globais (entradas do Sequence_design)
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal start    : std_logic := '0';

    -- 🔹 Vetores de entrada e saída
    signal base_vec   : integer_vector(0 to 6) := (1,2,3,4,5,6,7);
    signal result_vec : integer_vector(0 to 6);

    -- 🔹 Arquivo de saída
    file results_file : text open write_mode is "topwire_results.txt";

begin
    --------------------------------------------------------------------------
    -- Instancia o design de interconexão (Sequence_design)
    --------------------------------------------------------------------------
    uut: entity work.Sequence_design
        port map (
            clk      => clk,
            rst      => rst,
            start    => start,
            base_in  => base_vec,
            base_out => result_vec
        );

    --------------------------------------------------------------------------
    -- Clock
    --------------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    --------------------------------------------------------------------------
    -- Estímulos
    --------------------------------------------------------------------------
    stim_proc : process
        variable L : line;
    begin
        -- Reset inicial
        rst <= '1';
        wait for 30 ns;
        rst <= '0';
        wait for 20 ns;

        ----------------------------------------------------------------------
        -- Simula o “tempo de reação” do usuário (start com delays variados)
        ----------------------------------------------------------------------
        for rodada in 1 to 3 loop
            -- Espera um tempo aleatório entre ativações do start
            wait for (50 ns + rodada * 30 ns);

            start <= '1';
            wait for 10 ns;       -- pulso de start
            start <= '0';

            wait for 100 ns;      -- espera a propagação interna

            -- Grava o vetor resultante no arquivo
            write(L, string'("Rodada "));
            write(L, rodada);
            write(L, string'(": "));
            for i in 0 to 6 loop
                write(L, result_vec(i));
                write(L, string'(" "));
            end loop;
            writeline(results_file, L);
        end loop;

        ----------------------------------------------------------------------
        report "Simulação concluída com sucesso!" severity note;
        wait;
    end process;
end sim;
