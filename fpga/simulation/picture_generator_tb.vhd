----------------------------------------------------------------------------------
-- Engineer: Jakob Arndt
-- 
-- Create Date: 07/02/2023
-- Module Name: picture_generator_tb - Behavioral

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

entity picture_generator_tb is
end picture_generator_tb;

architecture test of picture_generator_tb is
    signal pg_clk                 : std_logic                                    := '0';
    signal pg_rst                 : std_logic                                    := '0';
    signal pg_pixel_x             : std_logic_vector(11 downto 0)                := (others => '0');
    signal pg_pixel_y             : std_logic_vector(11 downto 0)                := (others => '0');
    signal pg_pixel_color         : std_logic_vector(11 downto 0)                := (others => '0');
    signal pg_train_data_char     : std_logic_vector(7 downto 0)                 := (others => '0');
    signal pg_ready               : std_logic                                    := '0';
    signal pg_train_data_new_char : std_logic                                    := '0';
    signal pg_train_data_type     : std_logic_vector(1 downto 0)                 := (others => '0');
    signal pg_char_bitmap         : std_logic_vector(PSF_BITMAP_SIZE-1 downto 0) := (others => '0');
    signal pg_glyph_br_addr       : std_logic_vector (PSF_CHAR_WIDTH-1 downto 0) := (others => '0');
    signal pg_glyph_done          : std_logic                                    := '0';
    signal pg_bitmap_output       : std_logic_vector(PSF_BITMAP_SIZE-1 downto 0) := (others => '0');

    signal clk           : std_logic := '0';
    constant clk_period  : time      := 20 ns;
    constant half_period : time      := 10 ns;

    -- test glyphs
    type test_glyph is array (0 to 1) of std_logic_vector(PSF_BITMAP_SIZE-1 downto 0);
    constant test_glyphs : test_glyph := (x"a5007c829ea2a2a2a69a807e00000000",  -- A
                                          x"00003c424242427e4242424200000000");  -- B

    -- TODO add test array with different glyphs, try to generate those glyphs at different positions
    -- TODO maybe check if the glyphs are generated correctly -- when there is time left

begin

    clk    <= not clk  after 10 ns;
    pg_rst <= '1', '0' after 5 ns;
    pg_clk <= clk;

    -- Instantiate the Design Under Test (DUT)
    dut : entity work.picture_generator
        port map (train_data_char => pg_train_data_char,
                  ready           => pg_ready,
                  train_data_type => pg_train_data_type,
                  train_data_new_char => pg_train_data_new_char,
                  glyph_done => pg_glyph_done,

                  clk             => pg_clk,
                  reset           => pg_rst,

                  pixel_x       => pg_pixel_x,
                  pixel_y       => pg_pixel_y,
                  color         => pg_pixel_color,
                  glyph_bitmap_in   => pg_char_bitmap,
                  glyph_br_addr => pg_glyph_br_addr,
                  glyph_bitmap_out  => pg_bitmap_output);

    stimulus : process
    begin
        wait until pg_rst = '0';

        -- test glyph A as station name
        pg_train_data_char <= x"41";
        pg_train_data_type <= "00";
        pg_char_bitmap     <= test_glyphs(0);
        pg_train_data_new_char <= '1';

        wait for 2 * clk_period;

        pg_glyph_done <= '1';
        pg_train_data_new_char <= '0';

        wait for 1 * clk_period;

        pg_glyph_done <= '0';
        pg_char_bitmap     <= test_glyphs(1);

        wait for 10 * clk_period;

        pg_glyph_done <= '1';

        wait for 1 * clk_period;

        pg_glyph_done <= '0';

        wait for 128 * clk_period;
        stop;
    end process;

end architecture;
