library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Types.all;

entity Reorder_Vector is
    Port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        enable        : in  std_logic;
        indice_vector : in  array_3X7bits;
        random_vector : out array_3X7bits;
        ready         : out std_logic
    );
end Reorder_Vector;

architecture Behavioral of Reorder_Vector is
    
    signal base_in : array_3X7bits := ("001", "010", "011", "100", "101", "110", "111");
    signal ready_int : std_logic := '0';
    
begin

    process(clk, rst)
        variable temp_base : array_3X7bits;
        variable index : integer;
    begin
        if rst = '1' then
            base_in <= ("001", "010", "011", "100", "101", "110", "111");
            random_vector <= (others => "000");
            ready_int <= '0';
            
        elsif rising_edge(clk) then
            ready_int <= '0';  -- Reset ready a cada ciclo
            
            if enable = '1' then
                -- Reordena o vetor base usando os índices
                for i in 0 to 6 loop
                    index := to_integer(unsigned(indice_vector(i))) - 1;
                    if index >= 0 and index <= 6 then
                        temp_base(i) := base_in(index);
                    else
                        temp_base(i) := "000";  -- Fallback para evitar erro
                    end if;
                end loop;
                
                -- Atualiza as saídas
                random_vector <= temp_base;
                base_in <= temp_base;
                ready_int <= '1';
                
                report "Embaralhamento concluído";
            end if;
        end if;
    end process;

    ready <= ready_int;

end Behavioral;