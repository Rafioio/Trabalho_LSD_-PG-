library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- 🔹 O tipo precisa estar declarado ANTES da entity
package Reorder_Types is
    type integer_vector is array (natural range <>) of integer;
end package;

use work.Reorder_Types.all;

entity Reorder_Vector is
    Port (
        indices  : in  integer_vector(0 to 6);
        base_in  : in  integer_vector(0 to 6);
        base_out : out integer_vector(0 to 6)
    );
end Reorder_Vector;

architecture Behavioral of Reorder_Vector is
begin
    process(indices, base_in)
    begin
        for i in 0 to 6 loop
            base_out(i) <= base_in(indices(i) - 1);
            
        end loop;
    end process;
end Behavioral;
