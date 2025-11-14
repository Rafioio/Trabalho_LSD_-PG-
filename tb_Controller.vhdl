library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_Controller is
end tb_Controller;

architecture Behavioral of tb_Controller is
    component Controller
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            start : in STD_LOGIC;
            sw_usuario : in STD_LOGIC_VECTOR(6 downto 0);
            ativado : in STD_LOGIC_VECTOR(2 downto 0);
            sw_out : out STD_LOGIC_VECTOR(6 downto 0);
            inicia_Input : out STD_LOGIC
        );
    end component;
    
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
    signal start : STD_LOGIC := '0';
    signal sw_usuario : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
    signal ativado : STD_LOGIC_VECTOR(2 downto 0);
    signal sw_out : STD_LOGIC_VECTOR(6 downto 0);
    signal inicia_Input : STD_LOGIC;
    
    constant CLK_PERIOD : time := 10 ns;
    
begin
    -- Controller (DUT principal)
    dut_controller: Controller
    port map (
        clk => clk,
        reset => reset,
        start => start,
        sw_usuario => sw_usuario,
        ativado => ativado,
        sw_out => sw_out,
        inicia_Input => inicia_Input
    );
    
    -- Input (conectado à saída da controller)
    dut_input: Input
    port map (
        clk => clk,
        reset => reset,
        inicia_Input => inicia_Input,
        sw => sw_out,  -- Recebe switches da controller
        ativado => ativado  -- Envia para controller
    );
    
    -- Clock
    clk <= not clk after CLK_PERIOD/2;
    
    process
    begin
        -- Reset
        reset <= '1';
        wait for 50 ns;
        reset <= '0';
        wait for 50 ns;
        
        -- Inicia captura
        report "=== Iniciando captura com START ===";
        start <= '1';
        wait for 30 ns;
        start <= '0';
        wait for 50 ns;
        
        -- Simula usuário ativando switches em ordem
        report "Usuario ativa: SW2";
        sw_usuario <= "0000100";  -- SW2
        wait for 100 ns;
        report "Ativado detectado: " & integer'image(to_integer(unsigned(ativado)));
        
        report "Usuario ativa: SW5";
        sw_usuario <= "0010100";  -- SW2 + SW5
        wait for 100 ns;
        report "Ativado detectado: " & integer'image(to_integer(unsigned(ativado)));
        
        report "Usuario ativa: SW1";
        sw_usuario <= "0010110";  -- SW2 + SW5 + SW1
        wait for 100 ns;
        report "Ativado detectado: " & integer'image(to_integer(unsigned(ativado)));
        
        report "Usuario ativa: SW0";
        sw_usuario <= "0010111";  -- SW2 + SW5 + SW1 + SW0
        wait for 100 ns;
        report "Ativado detectado: " & integer'image(to_integer(unsigned(ativado)));
        
        report "Usuario ativa: SW6";
        sw_usuario <= "1010111";  -- SW2 + SW5 + SW1 + SW0 + SW6
        wait for 100 ns;
        report "Ativado detectado: " & integer'image(to_integer(unsigned(ativado)));
        
        report "Usuario ativa: SW4";
        sw_usuario <= "1011111";  -- SW2 + SW5 + SW1 + SW0 + SW6 + SW4
        wait for 100 ns;
        report "Ativado detectado: " & integer'image(to_integer(unsigned(ativado)));
        
        report "Usuario ativa: SW3";
        sw_usuario <= "1111111";  -- Todos (SW3 por último)
        wait for 100 ns;
        report "Ativado detectado: " & integer'image(to_integer(unsigned(ativado)));
        
        wait for 200 ns;
        assert false report "=== Teste Controller concluido ===" severity note;
        wait;
    end process;
end Behavioral;