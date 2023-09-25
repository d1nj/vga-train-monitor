----------------------------------------------------------------------------------
-- Engineer: Nils Einfeldt <n.einfeldt@campus.tu-berlin.de>
-- 
-- Create Date: 06/10/2023 07:08:52 PM
-- Module Name: VGA - Behavioral
-- Project Name: AEP Project 2023 - Train Display
-- Target Devices: Zedboard
-- Description: Module generates VGA signals
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity VGA is
    generic (
        h_visible_area     : integer := 640;
        h_front_porch      : integer := 16;
        h_sync             : integer := 96;
        h_back_porch       : integer := 48;
        v_visible_area     : integer := 480;
        v_front_porch      : integer := 10;
        v_sync             : integer := 2;
        v_back_porch       : integer := 33;
        h_coordinate_width : integer := 10;
        v_coordinate_width : integer := 10);

    port (
        clk          : in  std_logic;
        reset        : in  std_logic;
        blank        : out std_logic;
        hsync        : out std_logic;
        vsync        : out std_logic;
        h_coordinate : out std_logic_vector (h_coordinate_width-1 downto 0);
        v_coordinate : out std_logic_vector (v_coordinate_width-1 downto 0));

end VGA;

architecture Behavioral of VGA is
    constant h_line : integer := h_back_porch + h_visible_area + h_front_porch + h_sync;
    constant v_line : integer := v_back_porch + v_visible_area + v_front_porch + v_sync;
begin
    process (clk)
        variable h_counter : integer range 0 to h_line - 1 := 0;
        variable v_counter : integer range 0 to v_line - 1 := 0;
    begin
        if rising_edge(clk) then
            if reset = '1' then
                hsync        <= '1';
                vsync        <= '1';
                blank        <= '0';
                h_coordinate <= (others => '0');
                v_coordinate <= (others => '0');
                h_counter    := 0;
                v_counter    := 0;

            else
                if h_counter + 1 < h_line then
                    h_counter := h_counter + 1;
                else
                    h_counter := 0;
                    if v_counter + 1 < v_line then
                        v_counter := v_counter + 1;
                    else
                        v_counter := 0;
                    end if;
                end if;

                if h_counter < h_visible_area and v_counter < v_visible_area then
                    blank <= '0';
                else
                    blank <= '1';
                end if;

                if h_counter >= h_visible_area + h_front_porch and h_counter < h_visible_area + h_front_porch + h_sync then
                    hsync <= '0';
                else
                    hsync <= '1';
                end if;

                if v_counter >= v_visible_area + v_front_porch and v_counter < v_visible_area + v_front_porch + v_sync then
                    vsync <= '0';
                else
                    vsync <= '1';
                end if;

                h_coordinate <= std_logic_vector(to_unsigned(h_counter, h_coordinate'length));
                v_coordinate <= std_logic_vector(to_unsigned(v_counter, v_coordinate'length));
            end if;
        end if;
    end process;
end Behavioral;
