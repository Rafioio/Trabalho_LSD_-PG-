library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Types.all;

-- =====================================================
-- 🌱 Seed Generator
-- =====================================================
entity Seed_generator is
    Port ( 
        clk       : in std_logic;
        rst       : in std_logic;
        start     : in std_logic;
        save_seed : in std_logic;
        seed      : out std_logic_vector(2 downto 0)
    );
end Seed_generator;

architecture rtl of Seed_generator is
    signal lfsr_r    : std_logic_vector(2 downto 0);
    signal saved_seed : std_logic_vector(2 downto 0);
begin
    process(clk, rst)
        variable newbit : std_logic;
        variable next_state : std_logic_vector(2 downto 0);
    begin
        if rst = '1' then
            lfsr_r <= "001";
            saved_seed <= "001";
        elsif rising_edge(clk) then
            if save_seed = '1' then
                newbit := lfsr_r(2) xor lfsr_r(0);
                next_state := newbit & lfsr_r(2 downto 1);
                lfsr_r <= next_state;
                report "Seed_generator: LFSR avançado para " & 
                       integer'image(to_integer(unsigned(next_state)));
            end if;

            if start = '1' then
                if lfsr_r = "000" then
                    saved_seed <= "110";
                    report "SEED CAPTURADA COM PROTECAO: 0 -> 110";
                else
                    saved_seed <= lfsr_r;
                    report "SEED CAPTURADA: " & 
                           integer'image(to_integer(unsigned(lfsr_r)));
                end if;
            end if;
        end if;
    end process;
    seed <= saved_seed;
end rtl;

-- =====================================================
-- 🔄 LFSR 3 bits
-- =====================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Types.all;

entity LFSR_3bits is
    port (
        clk                 : in std_logic;
        rst                 : in std_logic;
        enable_lfsr         : in std_logic;
        load_seed           : in std_logic;
        seed                : in std_logic_vector(2 downto 0);
        indice_vector       : out array_3X7bits;
        indice_vector_ready : out std_logic
    );
end LFSR_3bits;

architecture rtl of LFSR_3bits is
    signal reg : std_logic_vector(2 downto 0) := "001";
    signal results : array_3X7bits := (others => "000");
    signal count : integer range 0 to 7 := 0;
    signal running : std_logic := '0';
    signal prev_enable : std_logic := '0';
begin
    process(clk, rst)
        variable temp : std_logic_vector(2 downto 0);
        variable newbit : std_logic;
    begin
        if rst = '1' then
            reg <= "001";
            results <= (others => "000");
            count <= 0;
            running <= '0';
            prev_enable <= '0';
            indice_vector_ready <= '0';
        elsif rising_edge(clk) then
            prev_enable <= enable_lfsr;
            indice_vector_ready <= '0';

            if enable_lfsr = '1' and prev_enable = '0' then
                running <= '1';
                count <= 0;
                results(0) <= reg;
            end if;

            if load_seed = '1' then
                if seed /= "000" then
                    reg <= seed;
                else
                    reg <= "001";
                end if;
            elsif running = '1' then
                newbit := reg(2) xor reg(1);
                temp := reg(1 downto 0) & newbit;
                reg <= temp;
                if count < 6 then
                    count <= count + 1;
                    results(count + 1) <= temp;
                else
                    running <= '0';
                    indice_vector_ready <= '1';
                end if;
            end if;
        end if;
    end process;
    indice_vector <= results;
end rtl;

-- =====================================================
-- 🔀 Reorder Vector
-- =====================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Types.all;

entity Reorder_Vector is
    Port (
        clk           : in std_logic;
        rst           : in std_logic;
        enable        : in std_logic;
        indice_vector : in array_3X7bits;
        random_vector : out array_3X7bits;
        ready         : out std_logic
    );
end Reorder_Vector;

architecture Behavioral of Reorder_Vector is
    constant BASE_ORIGINAL : array_3X7bits := ("001", "010", "011", "100", "101", "110", "111");
    signal current_base : array_3X7bits := BASE_ORIGINAL;
    signal cycle_count : integer range 0 to 7 := 0;
    signal ready_int : std_logic := '0';
    signal backup_base : array_3X7bits := BASE_ORIGINAL;
    signal backup_count : integer range 0 to 7 := 0;
begin
    process(clk)
        variable new_base : array_3X7bits;
        variable index : integer;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_base <= backup_base;
                cycle_count <= backup_count;
                ready_int <= '0';
                report "Reorder_Vector: RESET - restaurando backup (cycle_count = " & integer'image(backup_count) & ")";
            else
                ready_int <= '0';
                if enable = '1' then
                    for i in 0 to 6 loop
                        index := to_integer(unsigned(indice_vector(i))) - 1;
                        if index >= 0 and index <= 6 then
                            new_base(i) := current_base(index);
                        else
                            new_base(i) := "000";
                        end if;
                    end loop;
                    
                    random_vector <= new_base;
                    ready_int <= '1';
                    current_base <= new_base;
                    backup_base <= new_base;
                    
                    if cycle_count = 6 then
                        cycle_count <= 0;
                        backup_count <= 0;
                        report "Reorder_Vector: CICLO COMPLETO - resetando para BASE_ORIGINAL";
                    else
                        cycle_count <= cycle_count + 1;
                        backup_count <= backup_count + 1;
                        report "Reorder_Vector: Operacao " & integer'image(cycle_count + 1) & "/7 - base ATUALIZADO e salvo no BACKUP";
                    end if;
                end if;
            end if;
        end if;
    end process;
    ready <= ready_int;
end Behavioral;

-- =====================================================
-- 🎯 Sequence Design (Sistema Completo)
-- =====================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Types.all;

entity Sequence_design is
    Port (
        clk       : in std_logic;
        rst       : in std_logic;
        start     : in std_logic;
        base_out  : out array_3X7bits;
        ready_out : out std_logic
    );
end Sequence_design;

architecture wiring of Sequence_design is
    signal seed              : std_logic_vector(2 downto 0);
    signal seed_ready_ctrl   : std_logic;
    signal load_seed         : std_logic;
    signal enable_lfsr       : std_logic;
    signal indice_vector     : array_3X7bits;
    signal indice_ready      : std_logic;
    signal random_vector     : array_3X7bits;
    signal reorder_ready     : std_logic;
begin
    u_controller: entity work.Controller
        port map (
            clk           => clk,
            rst           => rst,
            start         => start,
            indice_ready  => indice_ready,
            reorder_ready => reorder_ready,
            seed_ready    => seed_ready_ctrl,
            load_seed     => load_seed,
            enable_lfsr   => enable_lfsr,
            global_ready  => ready_out
        );

    u_seed: entity work.Seed_generator
        port map (
            clk       => clk,
            rst       => rst,
            start     => load_seed,
            save_seed => seed_ready_ctrl,
            seed      => seed
        );

    u_lfsr: entity work.LFSR_3bits
        port map (
            clk                 => clk,
            rst                 => rst,
            enable_lfsr         => enable_lfsr,
            load_seed           => load_seed,
            seed                => seed,
            indice_vector       => indice_vector,
            indice_vector_ready => indice_ready
        );

    u_reorder: entity work.Reorder_Vector
        port map (
            clk           => clk,
            rst           => rst,
            enable        => indice_ready,
            indice_vector => indice_vector,
            random_vector => random_vector,
            ready         => reorder_ready
        );

    base_out <= random_vector;
end wiring;