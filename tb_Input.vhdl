library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_Input is
end tb_Input;

architecture Behavioral of tb_Input is
    component Input
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            inicia_Input : in STD_LOGIC;
            sw : in STD_LOGIC_VECTOR(6 downto 0);
            ativado : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;
    
    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '1';
    signal inicia_Input : STD_LOGIC := '0';
    signal sw : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
    signal ativado : STD_LOGIC_VECTOR(2 downto 0);
    
    constant CLK_PERIOD : time := 10 ns;
    
begin
    dut: Input
    port map (
        clk => clk,
        reset => reset,
        inicia_Input => inicia_Input,
        sw => sw,
        ativado => ativado
    );
    
    -- Clock
    clk <= not clk after CLK_PERIOD/2;
    
    process
    begin
        -- Reset
        reset <= '1';
        wait for 50 ns;
        reset <= '0';
        inicia_Input <= '1';
        wait for 50 ns;
        
        -- Teste 1: Ativa SW0
        report "=== Teste 1: Ativando SW0 ===";
        sw <= "0000001";  -- SW0
        wait for 50 ns;
        report "Ativado = " & integer'image(to_integer(unsigned(ativado)));
        
        -- Teste 2: Ativa SW3 (mantém SW0)
        report "=== Teste 2: Ativando SW3 ===";
        sw <= "0001001";  -- SW0 + SW3
        wait for 50 ns;
        report "Ativado = " & integer'image(to_integer(unsigned(ativado)));
        
        -- Teste 3: Ativa SW6 (mantém anteriores)
        report "=== Teste 3: Ativando SW6 ===";
        sw <= "1001001";  -- SW0 + SW3 + SW6
        wait for 50 ns;
        report "Ativado = " & integer'image(to_integer(unsigned(ativado)));
        
        -- Teste 4: Mantém o mesmo estado - não deve detectar nada
        report "=== Teste 4: Mantendo estado ===";
        sw <= "1001001";  -- Mesmo estado
        wait for 50 ns;
        report "Ativado = " & integer'image(to_integer(unsigned(ativado)));
        
        -- Teste 5: Ativa SW1
        report "=== Teste 5: Ativando SW1 ===";
        sw <= "1001011";  -- SW0 + SW1 + SW3 + SW6
        wait for 50 ns;
        report "Ativado = " & integer'image(to_integer(unsigned(ativado)));
        
        -- Teste 6: Desativa captura
        report "=== Teste 6: Desativando captura ===";
        inicia_Input <= '0';
        wait for 50 ns;
        report "Ativado = " & integer'image(to_integer(unsigned(ativado)));
        
        wait for 100 ns;
        assert false report "=== Teste Input concluido ===" severity note;
        wait;
    end process;
end Behavioral;