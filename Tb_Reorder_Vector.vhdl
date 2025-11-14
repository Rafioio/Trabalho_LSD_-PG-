library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Types.all;

entity tb_Reorder_Vector is
end tb_Reorder_Vector;

architecture Behavioral of tb_Reorder_Vector is

    component Reorder_Vector is
        Port (
            clk           : in  std_logic;
            rst           : in  std_logic;
            enable        : in  std_logic;
            indice_vector : in  array_3X7bits;
            random_vector : out array_3X7bits;
            ready         : out std_logic
        );
    end component;

    -- Signals
    signal clk, rst : std_logic := '0';
    signal enable : std_logic := '0';
    signal indice_vector : array_3X7bits := (others => "000");
    signal random_vector : array_3X7bits;
    signal ready : std_logic;

    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

begin

    -------------------------------------------------------------------------
    -- Clock generation
    -------------------------------------------------------------------------
    clk_process : process
    begin
        while now < 2000 ns loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -------------------------------------------------------------------------
    -- DUT instantiation
    -------------------------------------------------------------------------
    DUT: Reorder_Vector
        port map (
            clk => clk,
            rst => rst,
            enable => enable,
            indice_vector => indice_vector,
            random_vector => random_vector,
            ready => ready
        );

    -------------------------------------------------------------------------
    -- Stimulus process
    -------------------------------------------------------------------------
    stimulus: process
    begin
        -- Reset
        rst <= '1';
        enable <= '0';
        wait for 40 ns;
        rst <= '0';
        wait for 20 ns;

        ---------------------------------------------------------------------
        -- TEST CASE 1
        ---------------------------------------------------------------------
        report "=== TEST CASE 1: Inverter vetor ===";
        indice_vector <= ("111","110","101","100","011","010","001");  -- 7 6 5 4 3 2 1

        enable <= '1';
        wait until rising_edge(clk);
        enable <= '0';

        wait until ready = '1';
        wait for 1 ns;

        report "Resultado Caso 1:";
        for i in 0 to 6 loop
            report "Pos " & integer'image(i) & ": " &
                integer'image(to_integer(unsigned(random_vector(i))));
        end loop;

        wait for 40 ns;


        ---------------------------------------------------------------------
        -- TEST CASE 2
        ---------------------------------------------------------------------
        report "=== TEST CASE 2: Embaralhamento específico ===";
        indice_vector <= ("011","001","111","010","101","100","110"); -- 3 1 7 2 5 4 6

        enable <= '1';
        wait until rising_edge(clk);
        enable <= '0';

        wait until ready = '1';
        wait for 1 ns;

        report "Resultado Caso 2:";
        for i in 0 to 6 loop
            report "Pos " & integer'image(i) & ": " &
                integer'image(to_integer(unsigned(random_vector(i))));
        end loop;

        wait for 40 ns;


        ---------------------------------------------------------------------
        -- TEST CASE 3
        ---------------------------------------------------------------------
        report "=== TEST CASE 3: Ordem aleatória ===";
        indice_vector <= ("010","101","001","111","011","110","100"); -- 2 5 1 7 3 6 4

        enable <= '1';
        wait until rising_edge(clk);
        enable <= '0';

        wait until ready = '1';
        wait for 1 ns;

        report "Resultado Caso 3:";
        for i in 0 to 6 loop
            report "Pos " & integer'image(i) & ": " &
                integer'image(to_integer(unsigned(random_vector(i))));
        end loop;

        wait for 40 ns;


        ---------------------------------------------------------------------
        -- TEST CASE 4 (embaralhamento sobre base já modificada)
        ---------------------------------------------------------------------
        report "=== TEST CASE 4: Segundo embaralhamento ===";
        indice_vector <= ("001","010","011","100","101","110","111"); -- 1 2 3 4 5 6 7

        enable <= '1';
        wait until rising_edge(clk);
        enable <= '0';

        wait until ready = '1';
        wait for 1 ns;

        report "Resultado Caso 4:";
        for i in 0 to 6 loop
            report "Pos " & integer'image(i) & ": " &
                integer'image(to_integer(unsigned(random_vector(i))));
        end loop;

        wait for 100 ns;
        report "=== Simulação completa ===";

        wait;
    end process;

end Behavioral;
