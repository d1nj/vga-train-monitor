----------------------------------------------------------------------------------
-- Engineer: Jakob Arndt <jakob.arndt@campus.tu-berlin.de>
-- 
-- Create Date: 06/10/2023 06:55:46 PM
-- Module Name: vga_configuration - package body
-- Project Name: AEP Project 2023 - Train Display
-- Target Devices: ZedBoard
-- Description: Defines for the picture generating hardware
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package vga_configuration is

    constant TRAIN_DISPLAY_WIDTH : integer := 640;
    constant TRAIN_DISPLAY_HEIGHT : integer := 480;

    constant STATION_NAME_SCALE : integer := 2;
    constant TIME_SCALE : integer := 1;
    constant CONNECTION_SCALE : integer := 1;

    constant UNICODE_CHAR_WIDTH : integer := 16;
    constant PSF_CHAR_WIDTH : integer := 8;
    constant PSF_BITMAP_SIZE : integer := 128;
    constant PSF_BITMAP_HEIGHT : integer := 16;
    constant PSF_BITMAP_WIDTH : integer := 8;

    constant TRAIN_DATA_CHAR_TYPE_WIDTH : integer := 8;
    subtype TRAIN_DATA_CHAR_TYPE is std_logic_vector(TRAIN_DATA_CHAR_TYPE_WIDTH-1 downto 0);
    constant CT_STATION_NAME : TRAIN_DATA_CHAR_TYPE := x"00";
    constant CT_CURR_TIME : TRAIN_DATA_CHAR_TYPE := x"01";
    constant CT_CONNECTION : TRAIN_DATA_CHAR_TYPE := x"02";
    constant CT_NOT_DEFINED : TRAIN_DATA_CHAR_TYPE := (others => '1');

    constant STATION_NAME_LEN : integer := 50;
    constant CURR_TIME_LEN : integer := 5;
    constant CONNECTION_LEN : integer := 80;


end package vga_configuration;