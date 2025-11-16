library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Package para tipos personalizados
package Types is
    type array_3X7bits is array (0 to 6) of std_logic_vector(2 downto 0);
end package Types;

package body Types is
end package body Types;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Types.all;

entity Controller is
    Port ( 
        clk           : in std_logic;
        rst           : in std_logic;
        start         : in std_logic;
        seed_ready    : out std_logic;
        indice_ready  : in std_logic;
        reorder_ready : in std_logic;
        load_seed     : out std_logic;
        enable_lfsr   : out std_logic;
        global_ready  : out std_logic
    );
end Controller;

architecture Behavioral of Controller is
    type state_type is (S_IDLE, S_LOAD_SEED, S_RUN_LFSR, S_REORDER, S_DONE);
    signal state : state_type := S_IDLE;
    signal prev_start : std_logic := '0';
    
begin
    process(clk, rst)
    begin
        if rst = '1' then
            state <= S_IDLE;
            seed_ready <= '0';
            load_seed <= '0';
            enable_lfsr <= '0';
            global_ready <= '0';
            prev_start <= '0';
        elsif rising_edge(clk) then
            prev_start <= start;
            
            -- Valores padrão
            load_seed <= '0';
            enable_lfsr <= '0';
            global_ready <= '0';
            seed_ready <= '0';
            
            case state is
                when S_IDLE =>
                    if start = '1' and prev_start = '0' then
                        state <= S_LOAD_SEED;
                        load_seed <= '1';
                        seed_ready <= '1';
                        report "Controller: Capturando seed atual";
                    end if;
                    
                when S_LOAD_SEED =>
                    state <= S_RUN_LFSR;
                    enable_lfsr <= '1';
                    report "Controller: Iniciando LFSR principal";
                    
                when S_RUN_LFSR =>
                    enable_lfsr <= '1';
                    if indice_ready = '1' then
                        state <= S_REORDER;
                        report "Controller: LFSR terminou, iniciando reordenamento";
                    end if;
                    
                when S_REORDER =>
                    if reorder_ready = '1' then
                        state <= S_DONE;
                        report "Controller: Reordenamento concluído";
                    end if;
                    
                when S_DONE =>
                    global_ready <= '1';
                    seed_ready <= '1';
                    report "Controller: Processamento completo";
                    if start = '0' then
                        state <= S_IDLE;
                    end if;
            end case;
        end if;
    end process;
end Behavioral;