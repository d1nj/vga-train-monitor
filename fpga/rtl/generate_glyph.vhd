----------------------------------------------------------------------------------
-- Engineer: Jakob Arndt <jakob.arndt@campus.tu-berlin.de>
-- 
-- Create Date: 07/11/2023 06:49:07 PM
-- Module Name: generate_glyph - Behavioral
-- Project Name: AEP Project 2023 - Train Display
-- Target Devices: Zedboard
-- Description: This module generates the glyph for the train monitor 
--              and writes it into the frame buffer.
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.vga_configuration.all;

use ieee.numeric_std.all;

entity generate_glyph is
    generic (
        -- The number of pixels in a row of the glyph
        GLYPH_WIDTH        : integer := PSF_BITMAP_WIDTH;
        -- The number of pixels in a column of the glyph
        GLYPH_HEIGHT       : integer := PSF_BITMAP_HEIGHT;
        -- The total number of pixels in the glyph
        GLYPH_PIXEL_SIZE   : integer := PSF_BITMAP_SIZE;
        -- The number of pixels in a row of the frame buffer
        COLOR_SIGNAL_WIDTH : integer := 12;
        -- The number of pixels in a column of the frame buffer
        PIXEL_SIGNAL_WIDTH : integer := 12
        );
    port (
        -- clock and reset
        clk   : in std_logic;
        reset : in std_logic;

        -- position of the glyph on the frame
        glyph_start_pos_x : in std_logic_vector(PIXEL_SIGNAL_WIDTH-1 downto 0);
        glyph_start_pos_y : in std_logic_vector(PIXEL_SIGNAL_WIDTH-1 downto 0);

        -- char address in the glyph bram
        char_bitmap : in std_logic_vector(PSF_BITMAP_SIZE-1 downto 0);
        -- scale of the glyph
        scale       : in std_logic_vector(1 downto 0);
        -- glyph color
        char_color  : in std_logic_vector(COLOR_SIGNAL_WIDTH-1 downto 0);

        -- signal whether a new char is incoming
        new_char : in std_logic;

        -- output signals
        -- finished writing the glyph
        glyph_done : out std_logic;

        -- position of the pixel
        x_pos       : out std_logic_vector(PIXEL_SIGNAL_WIDTH-1 downto 0);
        y_pos       : out std_logic_vector(PIXEL_SIGNAL_WIDTH-1 downto 0);
        -- color of the pixel
        pixel_color : out std_logic_vector(COLOR_SIGNAL_WIDTH-1 downto 0)

        );
end generate_glyph;

architecture Behavioral of generate_glyph is
    type state_type is (start, idle, write_glyph);
    signal state      : state_type := start;
    signal next_state : state_type := start;

    signal bitmap_counter_x : integer := 0;
    signal bitmap_counter_y : integer := 0;
    signal bitmap_counter   : integer := 0;

begin

    set_state : process(clk, reset)
    begin
        if reset = '1' then
            state <= start;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process set_state;

    set_next_state : process(reset, state, new_char, bitmap_counter)
    begin
        if reset = '1' then
            next_state       <= start;
            glyph_done       <= '1';
        else
            case state is
                -- first state after boot
                when start =>
                    -- wait for first char
                    if new_char = '1' then
                        next_state <= write_glyph;
                        glyph_done <= '0';
                    else
                        next_state <= start;
                        glyph_done <= '1';
                    end if;

                -- state to wait for new char
                when idle =>
                    -- wait for new char
                    if new_char = '1' then
                        next_state <= write_glyph;
                        glyph_done <= '0';
                    else
                        next_state <= idle;
                        glyph_done <= '1';
                    end if;

                -- write the glyph into the frame buffer
                when write_glyph =>
                    if bitmap_counter = 0 then
                        next_state <= idle;
                        glyph_done <= '1';
                    else
                        next_state <= write_glyph;
                        glyph_done <= '0';
                    end if;
            end case;
        end if;
    end process set_next_state;

    count_through_bitmap : process(clk, reset)
    begin
        if rising_edge(clk) then
            if reset = '1' or state = start or state = idle then
                bitmap_counter_x <= 0;
                bitmap_counter_y <= 0;
                bitmap_counter   <= GLYPH_PIXEL_SIZE-1;
            else
                -- go through bitmap with x,y counter
                if (bitmap_counter_x + 1 < GLYPH_WIDTH) then
                    bitmap_counter_x <= bitmap_counter_x + 1;
                    bitmap_counter   <= bitmap_counter - 1;

                else
                    -- end of line: increase y counter and reset x counter
                    bitmap_counter_x <= 0;
                    if (bitmap_counter_y + 1 < GLYPH_HEIGHT) then
                        bitmap_counter_y <= bitmap_counter_y + 1;
                        bitmap_counter   <= bitmap_counter - 1;
                    else
                        -- end of bitmap: reset bitmap counter and wait for new char
                        bitmap_counter_y <= 0;
                        bitmap_counter   <= GLYPH_PIXEL_SIZE-1;
                    end if;
                end if;
            end if;
        end if;
    end process count_through_bitmap;

    x_pos       <= std_logic_vector(to_unsigned(to_integer(unsigned(glyph_start_pos_x)) + bitmap_counter_x, PIXEL_SIGNAL_WIDTH));
    y_pos       <= std_logic_vector(to_unsigned(to_integer(unsigned(glyph_start_pos_y)) + bitmap_counter_y, PIXEL_SIGNAL_WIDTH));
    pixel_color <= char_color when char_bitmap(bitmap_counter) = '1' else (others => '0');


end architecture;
