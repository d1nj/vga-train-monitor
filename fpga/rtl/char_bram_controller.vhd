----------------------------------------------------------------------------------
-- Engineer: Jakob Arndt <jakob.arndt@campus.tu-berlin.de>
-- 
-- Create Date: 06/10/2023 06:55:46 PM
-- Module Name: char_bram_controller - Behavioral
-- Project Name: AEP Project 2023 - Train Display
-- Target Devices: ZedBoard
-- Description: Module for fetching character bitmaps from BRAM
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

library work;
use work.vga_configuration.all;

entity char_bram_controller is
    generic (CHAR_ADDR_WIDTH  : integer := 8;
             CHAR_BITMAP_SIZE : integer := 128;
             BRAM_ADDR_WIDTH  : integer := 9;
             BRAM_DATA_WIDTH  : integer := 128
             );

    port (br_addr : out std_logic_vector (BRAM_ADDR_WIDTH-1 downto 0);
          br_clk  : out std_logic;
          br_data : in  std_logic_vector(BRAM_DATA_WIDTH-1 downto 0);
          br_rst  : out std_logic;
          br_en   : out std_logic;

          char_bitmap : out std_logic_vector (CHAR_BITMAP_SIZE-1 downto 0);
          char        : in  std_logic_vector (CHAR_ADDR_WIDTH-1 downto 0);

          clk   : in std_logic;
          reset : in std_logic);
end char_bram_controller;

architecture Behavioral of char_bram_controller is
    -- constant UNICODETABLEOFFSET  : integer := (BYTESPERGLYPH * NUMGLYPHS) + HEADERSIZE;

    attribute X_INTERFACE_INFO            : string;
    attribute X_INTERFACE_INFO of br_addr : signal is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
    attribute X_INTERFACE_INFO of br_clk  : signal is "xilinx.com:interface:bram:1.0 BRAM_PORT CLK";
    attribute X_INTERFACE_INFO of br_data : signal is "xilinx.com:interface:bram:1.0 BRAM_PORT DOUT";
    attribute X_INTERFACE_INFO of br_rst  : signal is "xilinx.com:interface:bram:1.0 BRAM_PORT RST";
    attribute X_INTERFACE_INFO of br_en   : signal is "xilinx.com:interface:bram:1.0 BRAM_PORT CLK";
begin

    br_addr <= '0' & char;
    br_clk  <= clk;

    char_bitmap <= br_data;

end Behavioral;
