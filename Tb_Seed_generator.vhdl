library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Tb_Seed_generator is
end Tb_Seed_generator;

architecture sim of Tb_Seed_generator is
    constant CLK_PERIOD : time := 10 ns;

    signal clk       : std_logic := '0';
    signal rst       : std_logic := '0';
    signal start     : std_logic := '0';
    signal save_seed : std_logic := '0';
    signal seed  : std_logic_vector(2 downto 0);
begin
    --------------------------------------------------------------------
    -- DUT (Design Under Test)
    --------------------------------------------------------------------
    uut: entity work.Seed_generator
        port map (
            clk       => clk,
            rst       => rst,
            start     => start,
            save_seed => save_seed,
            seed  => seed
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
        report "=== Teste Seed_generator iniciado ===" severity note;

        -- Reset inicial
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;

        -- 1️⃣ Inicia geração com start
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';

        -- deixa o LFSR rodar um pouco
        wait for 100 ns;

        -- 2️⃣ Salva a seed atual
        save_seed <= '1';
        wait for CLK_PERIOD;
        save_seed <= '0';
        wait for 30 ns;

        -- 3️⃣ Dá reset pra ver se volta pra seed salva
        rst <= '1';
        wait for 20 ns;
        rst <= '0';

        -- 4️⃣ Espera um pouco e termina
        wait for 100 ns;
        report "=== Simulação encerrada ===" severity note;
        wait;
    end process;

end sim;
