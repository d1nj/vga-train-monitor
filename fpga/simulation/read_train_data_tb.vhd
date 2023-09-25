----------------------------------------------------------------------------------
-- Engineer: Jakob Arndt
-- 
-- Create Date: 07/11/2023
-- Module Name: read_train_data_tb - Behavioral

-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.env.stop;

library work;
use work.vga_configuration.all;

entity read_train_data_tb is
end read_train_data_tb;

architecture test of read_train_data_tb is
  signal clk           : std_logic := '0';
  constant clk_period  : time      := 20 ns;
  constant half_period : time      := 10 ns;

  signal tb_reset : std_logic := '0';

  signal tb_axi_br_addr : std_logic_vector (8-1 downto 0);
  signal tb_axi_br_data : std_logic_vector (32-1 downto 0);  -- this module only reads from the BRAM

  -- signals to the picture generator
  -- char read from the bram
  signal tb_char : std_logic_vector (16-1 downto 0);

  -- char type of the current char
  signal tb_char_type : std_logic_vector (TRAIN_DATA_CHAR_TYPE_WIDTH-1 downto 0);

  -- signal to output the next char
  signal tb_send_next_char : std_logic;

  -- signals whether a new char is available
  signal tb_new_char_available : std_logic;

  -- singal from the ps to enable module
  signal tb_enable : std_logic;

  type test_bram_data is array(0 to 4) of std_logic_vector(31 downto 0);
  constant test_data : test_bram_data := (x"61007200", x"62004100", x"00006200", x"62000000", x"00000000");
begin
  clk      <= not clk  after half_period;
  tb_reset <= '1', '0' after 20 ns;

  dut : entity work.read_train_data
    port map (
      -- clock and reset
      clk => clk,
      reset => tb_reset,

      -- enable/disable module
      enable => tb_enable,

      -- axi bram interface
      axi_br_addr => tb_axi_br_addr,
      axi_br_data => tb_axi_br_data,

      -- signals to the picture generator
      char => tb_char,
      char_type => tb_char_type,
      send_next_char => tb_send_next_char,
      new_char_available => tb_new_char_available
    );

  stimulus : process
  begin
    tb_enable <= '0';
    tb_axi_br_data <= (others => '0');
    tb_send_next_char <= '0';

    wait until tb_reset = '0';
    wait until rising_edge(clk);

    tb_enable <= '1';

    wait for clk_period;

    -- check if the first address is zero
    assert tb_axi_br_addr = x"00" report "First address is not zero" severity error;

    wait for clk_period;

    -- set data
    tb_axi_br_data <= test_data(0);
    tb_send_next_char <= '1';

    wait for clk_period;

    tb_send_next_char <= '0';

    wait for clk_period;

        -- check if the first char is 'r'
        assert tb_char = x"7200" 
        report "First char is not 'r', char is " & integer'image(to_integer(unsigned(tb_char))) severity error;

    tb_send_next_char <= '1';

    wait for clk_period;

    tb_send_next_char <= '0';

    wait for clk_period;

    -- check if the second char is 'a'
    assert tb_char = x"6100" report "Second char is not 'a'" severity error;

    wait for clk_period;
    -- set next data
    tb_axi_br_data <= test_data(2);

    wait for clk_period;

    -- check if address is incremented
    assert tb_axi_br_addr = x"01" report "Address is not incremented" severity error;

    wait for clk_period;

    tb_send_next_char <= '1';

    wait for clk_period;

    tb_send_next_char <= '0';

    wait for clk_period;

    -- set next data
    tb_axi_br_data <= test_data(3);

    wait for clk_period;

    -- check if address is incremented
    assert tb_axi_br_addr = x"02" report "Address is not incremented" severity error;

    wait for clk_period;

    tb_send_next_char <= '1';

    wait for clk_period;

    tb_send_next_char <= '0';

    wait for clk_period;

    -- set next data
    tb_axi_br_data <= test_data(4);

    wait for clk_period;

    -- check if address is incremented
    assert tb_axi_br_addr = x"03" report "Address is not incremented" severity error;

    wait for 3*clk_period;

  end process;
end test;
