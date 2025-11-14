library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Input is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        inicia_Input : in STD_LOGIC;
        sw : in STD_LOGIC_VECTOR(6 downto 0);
        ativado : out STD_LOGIC_VECTOR(2 downto 0)
    );
end Input;

architecture Behavioral of Input is
    signal sw_anterior : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
    signal sw_atual : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
    
begin
    process(clk, reset)
    begin
        if reset = '1' then
            sw_anterior <= (others => '0');
            sw_atual <= (others => '0');
            ativado <= "000";
            
        elsif rising_edge(clk) then
            if inicia_Input = '1' then
                -- Atualiza registradores
                sw_anterior <= sw_atual;
                sw_atual <= sw;
                
                -- Detecta QUALQUER mudança e identifica qual switch foi ativado
                if (sw_atual /= sw_anterior) then
                    -- Verifica qual bit mudou de 0 para 1
                    for i in 0 to 6 loop
                        if sw_atual(i) = '1' and sw_anterior(i) = '0' then
                            -- Converte posição do switch para código 3 bits
                            case i is
                                when 0 => ativado <= "001";  -- SW0
                                when 1 => ativado <= "010";  -- SW1
                                when 2 => ativado <= "011";  -- SW2
                                when 3 => ativado <= "100";  -- SW3
                                when 4 => ativado <= "101";  -- SW4
                                when 5 => ativado <= "110";  -- SW5
                                when 6 => ativado <= "111";  -- SW6
                                when others => ativado <= "000";
                            end case;
                            exit;  -- Pega apenas o primeiro switch ativado
                        end if;
                    end loop;
                else
                    ativado <= "000";  -- Nenhuma mudança
                end if;
            else
                -- Reset quando não está capturando
                ativado <= "000";
                sw_anterior <= (others => '0');
                sw_atual <= (others => '0');
            end if;
        end if;
    end process;

end Behavioral;