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
            inicia_Input : out STD_LOGIC;
            enable_led : out STD_LOGIC;
            vetor_resultado : out std_logic_vector(20 downto 0);
            leds_out : out STD_LOGIC_VECTOR(6 downto 0)
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
    signal enable_led : STD_LOGIC;
    signal vetor_resultado : std_logic_vector(20 downto 0);
    signal leds_out : STD_LOGIC_VECTOR(6 downto 0);
    
    constant CLK_PERIOD : time := 10 ns;
    
begin
    -- Controller (DUT principal com lógica completa)
    dut_controller: Controller
    port map (
        clk => clk,
        reset => reset,
        start => start,
        sw_usuario => sw_usuario,
        ativado => ativado,
        sw_out => sw_out,
        inicia_Input => inicia_Input,
        enable_led => enable_led,
        vetor_resultado => vetor_resultado,
        leds_out => leds_out
    );
    
    -- Input (conectado à saída da controller)
    dut_input: Input
    port map (
        clk => clk,
        reset => reset,
        inicia_Input => inicia_Input,
        sw => sw_out,
        ativado => ativado
    );
    
    -- Clock
    clk <= not clk after CLK_PERIOD/2;
    
    -- Processo de estímulo
    process
    begin
        -- Reset inicial
        reset <= '1';
        wait for 50 ns;
        reset <= '0';
        wait for 50 ns;
        
        -- Inicia captura
        report "=== INICIANDO CAPTURA ===";
        start <= '1';
        wait for 30 ns;
        start <= '0';
        wait for 50 ns;
        
        -- Sequência completa: SW2, SW5, SW1, SW0, SW6, SW4, SW3
        report ">>> Usuario ativa SW2 (011) -> deve acender LED2";
        sw_usuario <= "0000100";  -- SW2
        wait for 100 ns;
        
        report ">>> Usuario ativa SW5 (110) -> deve acender LED5";
        sw_usuario <= "0010100";  -- SW2 + SW5
        wait for 100 ns;
        
        report ">>> Usuario ativa SW1 (010) -> deve acender LED1";
        sw_usuario <= "0010110";  -- SW2 + SW5 + SW1
        wait for 100 ns;
        
        report ">>> Usuario ativa SW0 (001) -> deve acender LED0";
        sw_usuario <= "0010111";  -- SW2 + SW5 + SW1 + SW0
        wait for 100 ns;
        
        report ">>> Usuario ativa SW6 (111) -> deve acender LED6";
        sw_usuario <= "1010111";  -- SW2 + SW5 + SW1 + SW0 + SW6
        wait for 100 ns;
        
        report ">>> Usuario ativa SW4 (101) -> deve acender LED4";
        sw_usuario <= "1011111";  -- SW2 + SW5 + SW1 + SW0 + SW6 + SW4
        wait for 100 ns;
        
        report ">>> Usuario ativa SW3 (100) -> deve acender LED3";
        sw_usuario <= "1111111";  -- Todos (SW3 último)
        wait for 200 ns;
        
        -- Verificação final
        report "=== VERIFICACAO FINAL ===";
        report "LEDs esperados: TODOS ACESOS (1111111)";
        report "LEDs obtidos: " & integer'image(to_integer(unsigned(leds_out))) & 
               " (bin: " & 
               integer'image(to_integer(unsigned(leds_out(6 downto 6)))) &
               integer'image(to_integer(unsigned(leds_out(5 downto 5)))) &
               integer'image(to_integer(unsigned(leds_out(4 downto 4)))) &
               integer'image(to_integer(unsigned(leds_out(3 downto 3)))) &
               integer'image(to_integer(unsigned(leds_out(2 downto 2)))) &
               integer'image(to_integer(unsigned(leds_out(1 downto 1)))) &
               integer'image(to_integer(unsigned(leds_out(0 downto 0)))) & ")";
        
        report "Vetor resultado: " & integer'image(to_integer(unsigned(vetor_resultado)));
        report "Sequência armazenada: 2-5-1-0-6-4-3";
        
        wait for 100 ns;
        assert false report "=== TESTE GERAL CONCLUIDO ===" severity note;
        wait;
    end process;
    
    -- Processo para monitorar LEDs em tempo real
    process(clk)
        variable last_leds : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
        variable last_ativado : STD_LOGIC_VECTOR(2 downto 0) := "000";
    begin
        if rising_edge(clk) then
            -- Monitora mudanças nos LEDs
            if leds_out /= last_leds then
                report "LEDs: " & integer'image(to_integer(unsigned(leds_out))) &
                       " | Mudança: " & 
                       integer'image(to_integer(unsigned(leds_out xor last_leds)));
                last_leds := leds_out;
            end if;
            
            -- Monitora código ativado
            if ativado /= "000" and ativado /= last_ativado then
                report "Codigo ativado: " & integer'image(to_integer(unsigned(ativado))) &
                       " -> deve acender LED" & integer'image(to_integer(unsigned(ativado)) - 1);
                last_ativado := ativado;
            end if;
        end if;
    end process;
    
end Behavioral;