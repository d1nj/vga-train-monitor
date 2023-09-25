----------------------------------------------------------------------------------
-- Engineer: Jakob Arndt
-- 
-- Create Date: 06/10/2023 06:49:07 PM
-- Module Name: reduction_nor - Behavioral
-- Project Name: AEP Project 2023 - Train Display
-- Target Devices: ZedBoard
-- Description: reduction_nor for n inputs
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_misc.or_reduce;

entity reduction_nor is
    generic ( N : integer := 8);
    Port ( a : in  STD_LOGIC_VECTOR (N-1 downto 0);
           y : out  STD_LOGIC);
end reduction_nor;

architecture Behavioral of reduction_nor is
begin
    y <= not or_reduce(a);
end Behavioral;