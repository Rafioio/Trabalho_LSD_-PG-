library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Led_Input is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        enable_led : in STD_LOGIC;
        ativado : in STD_LOGIC_VECTOR(2 downto 0);
        leds_out : out STD_LOGIC_VECTOR(6 downto 0)
    );
end Led_Input;

architecture Behavioral of Led_Input is
    signal leds_internos : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
    
begin
    process(clk, reset)
    begin
        if reset = '1' then
            leds_internos <= (others => '0');
            leds_out <= (others => '0');
            
        elsif rising_edge(clk) then
            if enable_led = '1' then
                -- Converte o código ativado (3 bits) para acionar o LED correspondente
                case ativado is
                    when "001" =>  -- SW0 -> LED0
                        leds_internos(0) <= '1';
                    when "010" =>  -- SW1 -> LED1
                        leds_internos(1) <= '1';
                    when "011" =>  -- SW2 -> LED2
                        leds_internos(2) <= '1';
                    when "100" =>  -- SW3 -> LED3
                        leds_internos(3) <= '1';
                    when "101" =>  -- SW4 -> LED4
                        leds_internos(4) <= '1';
                    when "110" =>  -- SW5 -> LED5
                        leds_internos(5) <= '1';
                    when "111" =>  -- SW6 -> LED6
                        leds_internos(6) <= '1';
                    when others =>
                        -- Mantém estado atual para códigos inválidos
                        null;
                end case;
            else
                -- Se enable_led = '0', mantém os LEDs (não desliga)
                null;
            end if;
            
            -- Atualiza saída dos LEDs
            leds_out <= leds_internos;
        end if;
    end process;

end Behavioral;