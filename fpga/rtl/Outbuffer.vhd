----------------------------------------------------------------------------------
-- Engineer: Nils Einfeldt <n.einfeldt@campus.tu-berlin.de>
-- 
-- Create Date: 06/10/2023 07:08:52 PM
-- Module Name: Outbuffer - Behavioral
-- Project Name: AEP Project 2023 - Train Display
-- Target Devices: Zedboard
-- Description: Module outputs the framebuffer onto the VGA port
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity Outbuffer is
    generic(
        h_coordinate_width : integer := 10;
        v_coordinate_width : integer := 10;
        h_visible_area     : integer := 640);
    port (
        blank               : in  std_logic;
        h_coordinate        : in  std_logic_vector (h_coordinate_width-1 downto 0);
        v_coordinate        : in  std_logic_vector (v_coordinate_width-1 downto 0);
        VGA_R               : out std_logic_vector(3 downto 0);
        VGA_G               : out std_logic_vector(3 downto 0);
        VGA_B               : out std_logic_vector(3 downto 0);
        framebuffer_address : out std_logic_vector(18 downto 0);
        framebuffer_data    : in  std_logic_vector(11 downto 0)
        );
end Outbuffer;

architecture Behavioral of Outbuffer is
    signal fb_addr : std_logic_vector(19 downto 0);
begin
    process(blank, h_coordinate, v_coordinate, framebuffer_data)
    begin
        if blank = '0' then
            fb_addr <= std_logic_vector(unsigned(v_coordinate) * to_unsigned(h_visible_area, 10) + unsigned(h_coordinate));
            VGA_R               <= framebuffer_data(11 downto 8);
            VGA_G               <= framebuffer_data(7 downto 4);
            VGA_B               <= framebuffer_data(3 downto 0);
        else
            VGA_R               <= (others => '0');
            VGA_G               <= (others => '0');
            VGA_B               <= (others => '0');
            fb_addr <= (others => '0');
        end if;
    end process;

    framebuffer_address <= fb_addr(18 downto 0);
end Behavioral;
