----------------------------------------------------------------------------------
-- Engineer: Nils Einfeldt <n.einfeldt@campus.tu-berlin.de>
-- 
-- Create Date: 06/10/2023 07:08:52 PM
-- Module Name: Rainbow - Behavioral
-- Project Name: AEP Project 2023 - Train Display
-- Target Devices: Zedboard
-- Description: Module generating a rainbow pattern
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity Rainbow is
    generic(
        h_coordinate_width : integer := 10;
        v_coordinate_width : integer := 10
        );
    port (
        blank        : in  std_logic;
        h_coordinate : in  std_logic_vector (h_coordinate_width-1 downto 0);
        v_coordinate : in  std_logic_vector (v_coordinate_width-1 downto 0);
        VGA_R        : out std_logic_vector(3 downto 0);
        VGA_G        : out std_logic_vector(3 downto 0);
        VGA_B        : out std_logic_vector(3 downto 0));
end Rainbow;

architecture Behavioral of Rainbow is
begin
    process(blank, h_coordinate, v_coordinate)
    begin
        if blank = '0' then
            VGA_R <= v_coordinate(9) & v_coordinate(6) & v_coordinate(3) & v_coordinate(0);
            VGA_G <= v_coordinate(8) & v_coordinate(5) & v_coordinate(2) & '0';
            VGA_B <= v_coordinate(7) & v_coordinate(4) & v_coordinate(1) & '0';
        else
            VGA_R <= (others => '0');
            VGA_G <= (others => '0');
            VGA_B <= (others => '0');
        end if;
    end process;
end Behavioral;
