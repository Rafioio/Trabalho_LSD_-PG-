library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Types.all;

entity tb_Sequence_design is
end tb_Sequence_design;

architecture sim of tb_Sequence_design is

    --------------------------------------------------------------------
    -- Função auxiliar para converter std_logic_vector → string
    --------------------------------------------------------------------
    function slv_to_string(slv: std_logic_vector) return string is
        variable result : string(1 to slv'length);
    begin
        for i in slv'range loop
            case slv(i) is
                when '0' => result(i - slv'low + 1) := '0';
                when '1' => result(i - slv'low + 1) := '1';
                when 'U' => result(i - slv'low + 1) := 'U';
                when 'X' => result(i - slv'low + 1) := 'X';
                when 'Z' => result(i - slv'low + 1) := 'Z';
                when others => result(i - slv'low + 1) := '?';
            end case;
        end loop;
        return result;
    end function;

    --------------------------------------------------------------------
    -- Sinais
    --------------------------------------------------------------------
    constant CLK_PERIOD : time := 10 ns;

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal start    : std_logic := '0';
    signal base_out : array_3X7bits;
    signal done     : std_logic;

begin

    --------------------------------------------------------------------
    -- DUT
    --------------------------------------------------------------------
    uut: entity work.Sequence_design
        port map (
            clk       => clk,
            rst       => rst,
            start     => start,
            base_out  => base_out,
            ready_out => done
        );

    --------------------------------------------------------------------
    -- Clock
    --------------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk <= '0'; wait for CLK_PERIOD/2;
            clk <= '1'; wait for CLK_PERIOD/2;
        end loop;
    end process;

    --------------------------------------------------------------------
    -- Estímulos
    --------------------------------------------------------------------
    stim_proc : process
    begin
        report "=== Teste Sequence_design iniciado ===";

        -- Reset
        rst <= '1';
        wait for 30 ns;
        rst <= '0';
        wait for 7000 ns;

        -- Pulso de start
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';

        wait for 1000 ns;

        -- Reset
        rst <= '1';
        wait for 30 ns;
        rst <= '0';
        wait for 5000 ns;

        -- Pulso de start
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';


        -- Esperar o módulo terminar (com timeout para evitar loop infinito)
        wait until done = '1' for 1000 ns;
        
        if done = '1' then
            -- Impressão do resultado
            report "=== Resultado base_out ===";
            for i in base_out'range loop
                report "base_out(" & integer'image(i) & ") = " &
                       slv_to_string(base_out(i)) & " (" & 
                       integer'image(to_integer(unsigned(base_out(i)))) & ")";
            end loop;
            
            -- Verificação básica
            report "=== Verificação ===";
            for i in base_out'range loop
                if to_integer(unsigned(base_out(i))) >= 1 and 
                   to_integer(unsigned(base_out(i))) <= 7 then
                    report "Pos " & integer'image(i) & ": OK";
                else
                    report "Pos " & integer'image(i) & ": ERRO - valor fora do range 1-7" 
                           severity error;
                end if;
            end loop;
        else
            report "ERRO: Módulo não completou dentro do tempo esperado!" severity error;
        end if;

        report "=== Simulação encerrada ===";
        wait;
    end process;

end sim;