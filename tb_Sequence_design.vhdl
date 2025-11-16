library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Types.all;

entity tb_Sequence_design is
end tb_Sequence_design;

architecture behavior of tb_Sequence_design is
    -- Constantes
    constant CLK_PERIOD : time := 10 ns;
    
    -- Sinais do DUT
    signal clk       : std_logic := '0';
    signal rst       : std_logic := '0';
    signal start     : std_logic := '0';
    signal base_out  : array_3X7bits;
    signal ready_out : std_logic;
    
    -- Controle de simulação
    signal simulation_running : boolean := true;
    
begin
    -- =====================================================
    -- DUT (Design Under Test)
    -- =====================================================
    DUT: entity work.Sequence_design
        port map (
            clk       => clk,
            rst       => rst,
            start     => start,
            base_out  => base_out,
            ready_out => ready_out
        );

    -- =====================================================
    -- Geração de Clock
    -- =====================================================
    clk_process : process
    begin
        while simulation_running loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- =====================================================
    -- Processo de Estímulos
    -- =====================================================
    stim_proc : process
        procedure apply_reset is
        begin
            report "Aplicando RESET...";
            rst <= '1';
            wait for CLK_PERIOD * 2;
            rst <= '0';
            wait for CLK_PERIOD;
        end procedure;
        
        procedure start_sequence is
        begin
            report " Iniciando sequencia...";
            start <= '1';
            wait for CLK_PERIOD;
            start <= '0';
            wait until ready_out = '1';
            wait for CLK_PERIOD;
            report "Sequencia completada!";
        end procedure;
        
        procedure print_vector(vector_name : string; vector : array_3X7bits) is
        begin
            report vector_name & ": " &
                   integer'image(to_integer(unsigned(vector(0)))) & " " &
                   integer'image(to_integer(unsigned(vector(1)))) & " " &
                   integer'image(to_integer(unsigned(vector(2)))) & " " &
                   integer'image(to_integer(unsigned(vector(3)))) & " " &
                   integer'image(to_integer(unsigned(vector(4)))) & " " &
                   integer'image(to_integer(unsigned(vector(5)))) & " " &
                   integer'image(to_integer(unsigned(vector(6))));
        end procedure;
        
    begin
        report " ===========================================" severity note;
        report " Iniciando Testbench do Sequence Design" severity note;
        report " ===========================================" severity note;
        
        -- Reset inicial
        apply_reset;
        
        -- Aguarda estabilização
        wait for CLK_PERIOD * 5;
        
        -- =====================================================
        -- TESTE 1: Primeira execução
        -- =====================================================
        report "TESTE 1: Primeira execucao apos reset" severity note;
        start_sequence;
        print_vector("Vetor de saida 1", base_out);
        wait for CLK_PERIOD * 10;
        
        -- =====================================================
        -- TESTE 2: Segunda execução (seed diferente)
        -- =====================================================
        report "TESTE 2: Segunda execucao" severity note;
        start_sequence;
        print_vector("Vetor de saida 2", base_out);
        wait for CLK_PERIOD * 10;
        
        -- =====================================================
        -- TESTE 3: Terceira execução
        -- =====================================================
        report "TESTE 3: Terceira execucao" severity note;
        start_sequence;
        print_vector("Vetor de saida 3", base_out);
        wait for CLK_PERIOD * 10;
        
        -- =====================================================
        -- TESTE 4: Reset e nova execução
        -- =====================================================
        report "TESTE 4: Reset e nova execucao" severity note;
        apply_reset;
        wait for CLK_PERIOD * 5;
        start_sequence;
        print_vector("Vetor de saida apos reset", base_out);
        wait for CLK_PERIOD * 10;
        
        -- =====================================================
        -- TESTE 5: Múltiplas execuções rápidas
        -- =====================================================
        report "TESTE 5: Execucoes consecutivas" severity note;
        for i in 1 to 3 loop
            start_sequence;
            print_vector("Vetor execucao " & integer'image(i), base_out);
            wait for CLK_PERIOD * 5;
        end loop;
        
        -- =====================================================
        -- TESTE 6: Verificação de ready_out
        -- =====================================================
        report "TESTE 6: Verificação do sinal ready_out" severity note;
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        
        -- Monitora ready_out
        wait until ready_out = '1';
        report "ready_out detectado - sistema pronto!" severity note;
        print_vector("Vetor final", base_out);
        
        -- Aguarda e finaliza
        wait for CLK_PERIOD * 20;
        
        report " ===========================================" severity note;
        report " Testbench concluido com sucesso!" severity note;
        report " ===========================================" severity note;
        
        simulation_running <= false;
        wait;
    end process;

    -- =====================================================
    -- Processo de Monitoramento
    -- =====================================================
    monitor_proc : process(clk)
        variable start_count : integer := 0;
        variable ready_count : integer := 0;
    begin
        if rising_edge(clk) then
            -- Monitora pulso de start
            if start = '1' then
                start_count := start_count + 1;
                report "START detectado - total: " & integer'image(start_count);
            end if;
            
            -- Monitora ready_out
            if ready_out'event and ready_out = '1' then
                ready_count := ready_count + 1;
                report "READY_OUT detectado - total: " & integer'image(ready_count);
            end if;
        end if;
    end process;

    -- =====================================================
    -- Verificação de Assertions
    -- =====================================================
    assertions_proc : process
    begin
        -- Verifica se ready_out nunca fica ativo por mais de 1 ciclo consecutivo
        wait until ready_out = '1';
        wait for CLK_PERIOD;
        assert ready_out = '0' 
            report "ERRO: ready_out ativo por mais de 1 ciclo!" 
            severity error;
        
        -- Verifica se o vetor de saída não contém valores inválidos
        for i in 0 to 6 loop
            wait until base_out'event;
            assert base_out(i) /= "000" and base_out(i) /= "UUU"
                report "ERRO: Valor inválido no vetor de saida: " & 
                       integer'image(to_integer(unsigned(base_out(i))))
                severity error;
        end loop;
        
        wait;
    end process;

end behavior;