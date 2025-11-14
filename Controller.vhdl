library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Controller is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        start : in STD_LOGIC;
        sw_usuario : in STD_LOGIC_VECTOR(6 downto 0);
        ativado : in STD_LOGIC_VECTOR(2 downto 0);
        sw_out : out STD_LOGIC_VECTOR(6 downto 0);
        inicia_Input : out STD_LOGIC
    );
end Controller;

architecture Behavioral of Controller is
    -- Tipo para armazenar a sequência do usuário
    type array_resposta is array (0 to 6) of std_logic_vector(2 downto 0);
    signal resposta_usuario : array_resposta;
    
    -- Máquina de estados
    type estado_type is (AGUARDA_START, CAPTURANDO, COMPLETO);
    signal estado : estado_type := AGUARDA_START;
    
    -- Contador de inputs recebidos
    signal contador_inputs : integer range 0 to 7 := 0;
    
    -- Sinais de debug
    signal debug_resposta_0, debug_resposta_1, debug_resposta_2 : std_logic_vector(2 downto 0);
    signal debug_resposta_3, debug_resposta_4, debug_resposta_5, debug_resposta_6 : std_logic_vector(2 downto 0);
    
begin
    -- Conexões de debug
    debug_resposta_0 <= resposta_usuario(0);
    debug_resposta_1 <= resposta_usuario(1);
    debug_resposta_2 <= resposta_usuario(2);
    debug_resposta_3 <= resposta_usuario(3);
    debug_resposta_4 <= resposta_usuario(4);
    debug_resposta_5 <= resposta_usuario(5);
    debug_resposta_6 <= resposta_usuario(6);

    process(clk, reset)
    begin
        if reset = '1' then
            estado <= AGUARDA_START;
            contador_inputs <= 0;
            inicia_Input <= '0';
            sw_out <= (others => '0');
            -- Limpa array de resposta
            for i in 0 to 6 loop
                resposta_usuario(i) <= "000";
            end loop;
            
        elsif rising_edge(clk) then
            -- Passa os switches do usuário direto para o input
            sw_out <= sw_usuario;
            
            case estado is
                when AGUARDA_START =>
                    inicia_Input <= '0';
                    contador_inputs <= 0;
                    if start = '1' then
                        estado <= CAPTURANDO;
                        inicia_Input <= '1';
                    end if;
                    
                when CAPTURANDO =>
                    inicia_Input <= '1';
                    
                    -- Quando recebe um novo input do módulo Input
                    if ativado /= "000" then
                        -- Armazena no array na ordem de chegada
                        resposta_usuario(contador_inputs) <= ativado;
                        contador_inputs <= contador_inputs + 1;
                        
                        -- Verifica se já recebeu todos os 7 inputs
                        if contador_inputs = 6 then
                            estado <= COMPLETO;
                            inicia_Input <= '0';
                        end if;
                    end if;
                    
                when COMPLETO =>
                    inicia_Input <= '0';
                    -- Permanece neste estado até reset
                    if reset = '1' then
                        estado <= AGUARDA_START;
                    end if;
                    
            end case;
        end if;
    end process;

end Behavioral;