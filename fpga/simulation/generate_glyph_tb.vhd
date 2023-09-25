----------------------------------------------------------------------------------
-- Engineer: Jakob Arndt
-- 
-- Create Date: 07/11/2023
-- Module Name: generate_glyph_tb - Behavioral

-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use std.env.stop;

library work;
use work.vga_configuration.all;

entity generate_glyph_tb is
end generate_glyph_tb;

architecture test of generate_glyph_tb is
    signal clk           : std_logic := '0';
    constant clk_period  : time      := 20 ns;
    constant half_period : time      := 10 ns;

    signal tb_reset : std_logic := '0';

    -- position of the glyph on the frame
    signal tb_glyph_start_pos_x : std_logic_vector(11 downto 0) := (others => '0');
    signal tb_glyph_start_pos_y : std_logic_vector(11 downto 0) := (others => '0');

    -- char address in the glyph bram
    signal tb_char_bitmap : std_logic_vector(PSF_BITMAP_SIZE-1 downto 0) := (others => '0');
    -- scale of the glyph
    signal tb_scale       : std_logic_vector(1 downto 0) := (others => '0');
    -- glyph color
    signal tb_char_color  : std_logic_vector(11 downto 0) := (others => '0');

    -- signal whether a new char is incoming
    signal tb_new_char : std_logic := '0';

    -- output signals
    -- finished writing the glyph
    signal tb_glyph_done : std_logic := '0';

    -- position of the pixel
    signal tb_x_pos       : std_logic_vector(11 downto 0) := (others => '0');
    signal tb_y_pos       : std_logic_vector(11 downto 0) := (others => '0');
    -- color of the pixel
    signal tb_pixel_color : std_logic_vector(11 downto 0) := (others => '0');


    type test_glyph is array (0 to 1) of std_logic_vector(PSF_BITMAP_SIZE-1 downto 0);
    constant test_glyphs : test_glyph := (x"a5007c829ea2a2a2a69a807e00000000",  -- A
                                          x"00003c424242427e4242424200000000");  -- B
begin
    clk <= not clk after half_period;
    tb_reset <= '1', '0' after 20 ns;

    dut : entity work.generate_glyph
        port map(
            clk           => clk,
            reset        => tb_reset,
            glyph_start_pos_x => tb_glyph_start_pos_x,
            glyph_start_pos_y => tb_glyph_start_pos_y,
            char_bitmap   => tb_char_bitmap,
            scale         => tb_scale,
            char_color    => tb_char_color,
            new_char      => tb_new_char,
            glyph_done    => tb_glyph_done,
            x_pos         => tb_x_pos,
            y_pos         => tb_y_pos,
            pixel_color   => tb_pixel_color
        );

    -- test process
    stimulus : process
    begin
        wait until tb_reset = '0';

        -- first glyph
        tb_glyph_start_pos_x <= (others => '0');
        tb_glyph_start_pos_y <= (others => '0');
        tb_char_bitmap       <= test_glyphs(0);
        tb_scale             <= (others => '0');
        tb_char_color        <= (others => '1');
        tb_new_char          <= '1';

        wait until tb_glyph_done = '0';
        wait until tb_glyph_done = '1';
        stop;
    end process stimulus;

end architecture;
