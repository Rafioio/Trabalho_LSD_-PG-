library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity Sequence_design is
    Port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        start    : in  std_logic;

        base_out : out std_logic_vector(0 to 6)
    );
end Sequence_design;

architecture wiring of Sequence_design is

    -- sinais internos para conectar os componentes
    signal seed          : std_logic_vector(2 downto 0);
    signal save_seed     : std_logic;
    signal enable_lsfr   : std_logic;
    signal load_seed     : std_logic;
    signal indice_vector : std_logic_vector(0 to 6);
    signal randow_vector : std_logic_vector(0 to 6);

begin

    ------------------------------------------------------------------
    -- LFSR 3 bits
    ------------------------------------------------------------------
    u_lfsr: entity work.LFSR_3bits
        port map (
            clk         => clk,
            rst         => rst,
            load_seed   => load_seed,
            enable_lsfr => enable_lsfr,
            seed        => seed,
            indice_vector => indice_vector
        );

    ------------------------------------------------------------------
    -- Reordenação
    ------------------------------------------------------------------
    u_reorder: entity work.Reorder_Vector
        port map (
            indice_vector => indice_vector,
            randow_vector => randow_vector
        );

    ------------------------------------------------------------------
    -- Gerador de semente
    ------------------------------------------------------------------
    u_seed: entity work.Seed_generator
        port map (
            clk        => clk,
            rst        => rst,
            start      => start,
            save_seed  => save_seed,

            seed       => seed
        );

    ------------------------------------------------------------------
    -- Saída final
    ------------------------------------------------------------------
    base_out <= randow_vector;

end wiring;
