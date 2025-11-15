library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.Types.all; 

entity tb_LFSR_3bits is
end tb_LFSR_3bits;

architecture sim of tb_LFSR_3bits is

    -- Componente sendo testado (DUT)
    component LFSR_3bits is
        port (
            clk                 : in  std_logic;
            rst                 : in  std_logic;
            enable_lfsr         : in  std_logic;
            load_seed           : in  std_logic;
            seed                : in  std_logic_vector(2 downto 0);
            indice_vector       : out array_3X7bits;
            indice_vector_ready : out std_logic
        );
    end component;

    -- Sinais locais
    signal clk                 : std_logic := '0';
    signal rst                 : std_logic := '0';
    signal enable_lfsr         : std_logic := '0';
    signal load_seed           : std_logic := '0';
    signal seed                : std_logic_vector(2 downto 0) := "001";
    signal indice_vector       : array_3X7bits;
    signal indice_vector_ready : std_logic;

    constant CLK_PERIOD : time := 10 ns;

    -- Arquivo para saída dos resultados
    file arq : text open write_mode is "saida.txt";

    -- Função auxiliar para converter std_logic_vector em string
    function slv_to_string(slv : std_logic_vector) return string is
        variable s : string(1 to slv'length);
    begin
        for i in 0 to slv'length - 1 loop
            if slv(slv'left - i) = '1' then
                s(i + 1) := '1';
            else
                s(i + 1) := '0';
            end if;
        end loop;
        return s;
    end function;

begin

    -- Instância do DUT
    uut: LFSR_3bits
        port map (
            clk                 => clk,
            rst                 => rst,
            enable_lfsr         => enable_lfsr,
            load_seed           => load_seed,
            seed                => seed,
            indice_vector       => indice_vector,
            indice_vector_ready => indice_vector_ready
        );

    -- Geração do clock
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Estímulos da simulação
    stim_proc : process
    begin
        -- reset inicial
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 10 ns;

        -- define o valor da seed
        seed <= "100";
        wait for 5 ns;

        -- dá o pulso de load_seed
        load_seed <= '1';
        wait for CLK_PERIOD;
        load_seed <= '0';

        -- ativa a LFSR para gerar os 7 valores
        enable_lfsr <= '1';
        wait for 80 ns;  -- tempo suficiente pra 7 ciclos
        enable_lfsr <= '0';

        -- espera um pouco e termina
        wait for 40 ns;
    end process;

    -- Processo para imprimir o vetor final no terminal e no arquivo
    monitor : process
        variable L : line;
    begin
        wait until indice_vector_ready = '1';

        report "==== Valores gerados pela LFSR ====";

        for i in indice_vector'range loop
            report "indice_vector(" & integer'image(i) & ") = " & slv_to_string(indice_vector(i));

            write(L, string'("indice_vector(" & integer'image(i) & "): "));
            write(L, slv_to_string(indice_vector(i)));
            writeline(arq, L);
        end loop;

        report "==== Fim da listagem ====";
        wait;
    end process;

end sim;
