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
    
    constant BASE_ORIGINAL : array_3X7bits :=
        ("001", "010", "011", "100", "101", "110", "111");

    -- Registro PRINCIPAL que sobrevive aos resets
    signal current_base : array_3X7bits := BASE_ORIGINAL;
    signal cycle_count  : integer range 0 to 7 := 0;
    signal ready_int    : std_logic := '0';
    
    -- Registro de BACKUP que mantém o estado entre resets
    signal backup_base  : array_3X7bits := BASE_ORIGINAL;
    signal backup_count : integer range 0 to 7 := 0;

begin

    process(clk)
        variable new_base : array_3X7bits;
        variable index : integer;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- RESET: Restaura do BACKUP em vez de voltar ao original
                current_base <= backup_base;
                cycle_count <= backup_count;
                ready_int <= '0';
                report "Reorder_Vector: RESET - restaurando backup (cycle_count = " & integer'image(backup_count) & ")";
            else
                ready_int <= '0';
                if enable = '1' then

                    -- USA current_base atual (que pode ser do backup)
                    for i in 0 to 6 loop
                        index := to_integer(unsigned(indice_vector(i))) - 1;
                        if index >= 0 and index <= 6 then
                            new_base(i) := current_base(index);
                        else
                            new_base(i) := "000";
                        end if;
                    end loop;

                    -- Atualiza saída
                    random_vector <= new_base;
                    ready_int <= '1';

                    -- Atualiza estado PRINCIPAL
                    current_base <= new_base;
                    
                    -- Atualiza BACKUP (sobrevive aos resets)
                    backup_base <= new_base;
                    
                    if cycle_count = 6 then
                        cycle_count <= 0;
                        backup_count <= 0;
                        report "Reorder_Vector: CICLO COMPLETO - resetando para BASE_ORIGINAL";
                    else
                        cycle_count <= cycle_count + 1;
                        backup_count <= backup_count + 1;
                        report "Reorder_Vector: Operação " & integer'image(cycle_count + 1) & "/7 - base ATUALIZADO e salvo no BACKUP";
                    end if;

                end if;
            end if;
        end if;
    end process;

    ready <= ready_int;

end Behavioral;