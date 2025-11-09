library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_LFSR is
end tb_LFSR;

architecture sim of tb_LFSR is
    constant CLK_PERIOD : time := 10 ns;

    signal clk       : std_logic := '0';
    signal rst       : std_logic := '1';
    signal enable    : std_logic := '0';
    signal load_seed : std_logic := '0';
    signal seed      : std_logic_vector(7 downto 0) := x"AD";
    signal out_val   : std_logic_vector(7 downto 0);
begin
    uut: entity work.LFSR_8bit
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
    begin
        rst <= '1';
        wait for 20 ns;
        rst <= '0';

        load_seed <= '1';
        wait for CLK_PERIOD;
        load_seed <= '0';

        enable <= '1';
        wait for 200 ns;

        enable <= '0';
        wait for 20 ns;

        report "Simulação finalizada com sucesso!" severity note;
        wait for 10 ns;
        wait;
    end process;
end sim;
