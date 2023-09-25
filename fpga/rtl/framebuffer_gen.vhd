----------------------------------------------------------------------------------
-- Engineer: Jakob Arndt <jakob.arndt@campus.tu-berlin.de>
-- 
-- Create Date: 06/10/2023 07:08:52 PM
-- Module Name: framebuffer_gen - Behavioral
-- Project Name: AEP Project 2023 - Train Display
-- Target Devices: Zedboard
-- Description: Module writing to the framebuffer
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity framebuffer_gen is
    generic (DISPLAY_WIDTH : integer := 640;
             FB_ADDR_WIDTH : integer := 19;
             FB_DATA_WIDTH : integer := 12);
    port (pixel_x : in std_logic_vector (11 downto 0);
          pixel_y : in std_logic_vector (11 downto 0);
          color   : in std_logic_vector (11 downto 0);

          fb_addr : out std_logic_vector (FB_ADDR_WIDTH-1 downto 0);
          fb_data : out std_logic_vector (FB_DATA_WIDTH-1 downto 0);
          fb_wen  : out std_logic;
          clk     : in  std_logic;
          reset   : in  std_logic);
end framebuffer_gen;

architecture Behavioral of framebuffer_gen is
    signal fb_addr_c : integer := 0;
    signal fb_data_c : std_logic_vector (FB_DATA_WIDTH-1 downto 0) := (others => '0');
    signal fb_wen_c  : std_logic := '0';

begin

    fb_addr <= std_logic_vector(to_unsigned(fb_addr_c, FB_ADDR_WIDTH));
    fb_data <= fb_data_c;
    fb_wen  <= fb_wen_c;

    process (clk, reset)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                fb_addr_c <= 0;
                fb_data_c <= (others => '0');
                fb_wen_c  <= '0';
            else
                fb_addr_c <= to_integer(unsigned(pixel_y(11 downto 0))) * DISPLAY_WIDTH + to_integer(unsigned(pixel_x(11 downto 0)));
                fb_data_c <= color;
                fb_wen_c  <= '1';
            end if;
        end if;
    end process;


end Behavioral;
