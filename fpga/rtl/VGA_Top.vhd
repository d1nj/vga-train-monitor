----------------------------------------------------------------------------------
-- Engineer: Nils Einfeldt <n.einfeldt@campus.tu-berlin.de>
-- 
-- Create Date: 06/10/2023 07:08:52 PM
-- Module Name: VGA_Top - structural
-- Project Name: AEP Project 2023 - Train Display
-- Target Devices: Zedboard
-- Description: VGA Top Level Module
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity VGA_Top is
    generic(
        h_coordinate_width : integer := 10;
        v_coordinate_width : integer := 10
        );
    port (
        VGA_B  : out std_logic_vector(3 downto 0);
        VGA_G  : out std_logic_vector(3 downto 0);
        VGA_R  : out std_logic_vector(3 downto 0);
        VGA_HS : out std_logic;
        VGA_VS : out std_logic;
        GCLK   : in  std_logic;
        RESET  : in  std_logic);
end VGA_Top;

architecture structural of VGA_Top is
    signal VGA_blank_Picture : std_ulogic;
    signal clock_signal      : std_logic;
    signal h_coordinate      : std_logic_vector(h_coordinate_width-1 downto 0);
    signal v_coordinate      : std_logic_vector(v_coordinate_width-1 downto 0);
begin

    clock : entity work.clk_wiz_0
        port map(
            clk_out1 => clock_signal,
            reset    => RESET,
            clk_in1  => GCLK
            );

    vga_controller : entity work.VGA
        port map(
            clk          => clock_signal,
            reset        => RESET,
            blank        => VGA_blank_Picture,
            hsync        => VGA_HS,
            vsync        => VGA_VS,
            h_coordinate => h_coordinate,
            v_coordinate => v_coordinate);

    picture_generator : entity work.PictureGenerator
        port map(
            blank        => VGA_blank_Picture,
            VGA_R        => VGA_R,
            VGA_G        => VGA_G,
            VGA_B        => VGA_B,
            h_coordinate => h_coordinate,
            v_coordinate => v_coordinate);

end structural;
