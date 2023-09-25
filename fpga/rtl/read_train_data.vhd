----------------------------------------------------------------------------------
-- Engineer: Jakob Arndt <jakob.arndt@campus.tu-berlin.de>
-- 
-- Create Date: 06/10/2023 06:02:31 PM
-- Module Name: read_train_data - Behavioral
-- Project Name: AEP Project 2023 - Train Display
-- Target Devices: ZedBoard
-- Description: This module reads data from the Block RAM connected to the AXI interface.
--              The data in the BRAM is written by the PS in the following way:
--              | -- 50 Bytes Station Name -- | -- 4 Bytes Time -- |
--              | -- 80 Bytes per Connection -- |
--              The module gets the char number and the type of the char (station name, time, connection)
--              from that it determines the read address and returns the char at this address.
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.vga_configuration.all;

entity read_train_data is
  generic (CHAR_WIDTH       : integer := 16;
           BRAM_ADDR_WIDTH  : integer := 32;
           BRAM_DATA_WIDTH  : integer := 32;
           BRAM_FIRST_ADDR  : integer := 0;
           BRAM_LAST_ADDR   : integer := 500;
           LEN_STATION_NAME : integer := 25;
           LEN_CURR_TIME    : integer := 2;
           LEN_CONN         : integer := 40;
           NUM_CONN         : integer := 5
           );
  port (
    -- signals to the AXI BRAM
    axi_br_addr : out std_logic_vector (BRAM_ADDR_WIDTH-1 downto 0);
    axi_br_data : in  std_logic_vector (BRAM_DATA_WIDTH-1 downto 0);  -- this module only reads from the BRAM
    axi_br_rden : out std_logic;

    -- signals to the picture generator
    -- char read from the bram
    char : out std_logic_vector (CHAR_WIDTH-1 downto 0);

    -- char type of the current char
    char_type : out std_logic_vector (TRAIN_DATA_CHAR_TYPE_WIDTH-1 downto 0);

    -- signal to output the next char
    send_next_char : in std_logic;

    -- signals whether a new char is available
    new_char_available : out std_logic;

    -- singal from the ps to enable module
    enable : in std_logic;

    clk   : in std_logic;
    reset : in std_logic);

end read_train_data;

architecture Behavioral of read_train_data is

  -- constants where to find the data in the bram
  constant STATION_NAME_START_ADDR : integer := BRAM_FIRST_ADDR;
  constant TIME_START_ADDR         : integer := BRAM_FIRST_ADDR + LEN_STATION_NAME;
  constant CONN_START_ADDR         : integer := TIME_START_ADDR + LEN_CURR_TIME;

  -- signals storing the char read from the bram
  signal out_char        : std_logic_vector (CHAR_WIDTH-1 downto 0) := (others => '0');
  signal first_char      : std_logic_vector (CHAR_WIDTH-1 downto 0) := (others => '0');
  signal second_char     : std_logic_vector (CHAR_WIDTH-1 downto 0) := (others => '0');
  signal new_out_char    : std_logic_vector (CHAR_WIDTH-1 downto 0) := (others => '0');
  signal new_first_char  : std_logic_vector (CHAR_WIDTH-1 downto 0) := (others => '0');
  signal new_second_char : std_logic_vector (CHAR_WIDTH-1 downto 0) := (others => '0');

  -- signals storing the char types
  signal out_char_type        : std_logic_vector (TRAIN_DATA_CHAR_TYPE_WIDTH-1 downto 0) := (others => '0');
  signal first_char_type      : std_logic_vector (TRAIN_DATA_CHAR_TYPE_WIDTH-1 downto 0) := (others => '0');
  signal second_char_type     : std_logic_vector (TRAIN_DATA_CHAR_TYPE_WIDTH-1 downto 0) := (others => '0');
  signal new_out_char_type    : std_logic_vector (TRAIN_DATA_CHAR_TYPE_WIDTH-1 downto 0) := (others => '0');
  signal new_first_char_type  : std_logic_vector (TRAIN_DATA_CHAR_TYPE_WIDTH-1 downto 0) := (others => '0');
  signal new_second_char_type : std_logic_vector (TRAIN_DATA_CHAR_TYPE_WIDTH-1 downto 0) := (others => '0');

  -- address of the char to read from the bram
  signal addr     : integer := 0;
  signal new_addr : integer := 0;

  signal data_is_zero : boolean := false;

  -- signal indicating the type of the char, by counting the zero words
  signal zero_count     : integer := 0;
  signal new_zero_count : integer := 0;


  type read_state is (start, get_data, wait_for_bram, parse_data, output_first_char,
                      output_second_char, wait_for_pg, finished_reading);
  signal state      : read_state := get_data;
  signal next_state : read_state := get_data;

  -- function checks if input is zero
  function is_zero(input : std_logic_vector; length : integer) return std_logic is
    variable zero : std_logic_vector(length-1 downto 0) := (others => '0');
  begin
    if input = zero then
      return '1';
    else
      return '0';
    end if;
  end function is_zero;

begin

  set_state : process(clk, reset, enable)
  begin
    if reset = '1' or enable = '0' then
      state      <= start;
      addr       <= 0;
      zero_count <= 0;

      first_char       <= (others => '0');
      second_char      <= (others => '0');
      out_char         <= (others => '0');
      first_char_type  <= (others => '0');
      second_char_type <= (others => '0');
      out_char_type    <= (others => '0');
    elsif rising_edge(clk) then
      state      <= next_state;
      addr       <= new_addr;
      zero_count <= new_zero_count;

      first_char       <= new_first_char;
      second_char      <= new_second_char;
      out_char         <= new_out_char;
      first_char_type  <= new_first_char_type;
      second_char_type <= new_second_char_type;
      out_char_type    <= new_out_char_type;
    end if;
  end process set_state;

  -- A process outputting the next char to the picture generator
  set_next_state : process(reset, state, enable, send_next_char, addr, first_char, second_char, out_char, zero_count, first_char_type, second_char_type, out_char_type, axi_br_data)
  begin
    if reset = '1' or enable = '0' then
      next_state           <= start;

      new_first_char       <= (others => '0');
      new_second_char      <= (others => '0');
      new_out_char         <= (others => '0');
      new_first_char_type  <= (others => '0');
      new_second_char_type <= (others => '0');
      new_out_char_type    <= (others => '0');

      new_char_available   <= '0';
      new_addr             <= 0;
      new_zero_count       <= 0;
      axi_br_rden         <= '0';
    else
      case state is
        -- initial state
        when start =>
          -- set outputs
          new_first_char       <= (others => '0');
          new_second_char      <= (others => '0');
          new_out_char         <= (others => '0');
          new_first_char_type  <= (others => '0');
          new_second_char_type <= (others => '0');
          new_out_char_type    <= (others => '0');
          new_addr             <= 0;
          new_char_available   <= '0';
          new_zero_count       <= 0;
          axi_br_rden         <= '1';

          -- calc next state
          if BRAM_LAST_ADDR <= addr then
            next_state <= finished_reading;
          else
            next_state <= wait_for_bram;
          end if;

        -- set next bram address
        when get_data =>
          -- set outputs
          new_first_char       <= first_char;
          new_second_char      <= second_char;
          new_out_char         <= out_char;
          new_out_char_type    <= out_char_type;
          new_first_char_type  <= first_char_type;
          new_second_char_type <= second_char_type;
          new_zero_count       <= zero_count;
          -- increment address
          new_addr             <= addr + 1;
          new_char_available   <= '0';
          axi_br_rden         <= '1';

          -- calc next state
          if BRAM_LAST_ADDR <= addr then
            next_state <= finished_reading;
          else
            next_state <= wait_for_bram;
          end if;

        -- wait for the bram to return the data
        when wait_for_bram =>
          -- set outputs
          new_addr             <= addr;
          new_first_char       <= first_char;
          new_second_char      <= second_char;
          new_out_char         <= out_char;
          new_first_char_type  <= first_char_type;
          new_second_char_type <= second_char_type;
          new_out_char_type        <= out_char_type;
          new_zero_count       <= zero_count;
          new_char_available   <= '0';
          axi_br_rden         <= '1';

          -- calc next state
          next_state <= parse_data;

        -- parse the data
        when parse_data =>
          -- set outputs
          new_addr             <= addr;
          new_first_char       <= axi_br_data(CHAR_WIDTH-1 downto 0);
          new_second_char      <= axi_br_data(BRAM_DATA_WIDTH-1 downto CHAR_WIDTH);
          new_out_char         <= out_char;
          new_first_char_type  <= std_logic_vector(to_unsigned(zero_count, TRAIN_DATA_CHAR_TYPE_WIDTH));
          new_second_char_type <= second_char_type;
          new_out_char_type    <= out_char_type;
          new_char_available   <= '0';
          axi_br_rden         <= '1';

          -- calc next state
          -- if data is zero get next address
          if (is_zero(axi_br_data, BRAM_DATA_WIDTH) = '1') then
            next_state     <= finished_reading;
            new_zero_count <= 0;

          -- if first char is zero, output second char
          elsif (is_zero(axi_br_data(CHAR_WIDTH-1 downto 0), CHAR_WIDTH) = '1')
            and send_next_char = '1' then
            next_state     <= output_second_char;
            new_zero_count <= zero_count + 1;

          -- if picture generator requests next char, output it
          elsif send_next_char = '1' then
            next_state     <= output_first_char;
            new_zero_count <= zero_count;
          else
            next_state     <= parse_data;
            new_zero_count <= zero_count;
          end if;

        -- output the first char
        when output_first_char =>
          -- set outputs
          new_addr             <= addr;
          new_first_char       <= first_char;
          new_second_char      <= second_char;
          new_out_char         <= first_char;
          new_first_char_type  <= first_char_type;
          new_second_char_type <= second_char_type;
          new_out_char_type    <= first_char_type;
          new_char_available   <= '1';
          axi_br_rden         <= '1';

          -- calc next state
          if (is_zero(second_char, CHAR_WIDTH) = '1') then
            next_state     <= get_data;
            new_zero_count <= zero_count + 1;
          elsif send_next_char = '0' then
            next_state     <= wait_for_pg;
            new_zero_count <= zero_count;
          else
            next_state     <= output_first_char;
            new_zero_count <= zero_count;
          end if;

        -- wait for picture generator
        when wait_for_pg =>
          -- set outputs
          new_addr             <= addr;
          new_first_char       <= first_char;
          new_second_char      <= second_char;
          new_out_char         <= first_char;
          new_out_char_type    <= out_char_type;
          new_first_char_type  <= first_char_type;
          new_second_char_type <= second_char_type;
          new_char_available   <= '0';
          new_zero_count       <= zero_count;
          axi_br_rden         <= '1';

          -- calc next state
          if send_next_char = '1' then
            next_state <= output_second_char;
          else
            next_state <= wait_for_pg;
          end if;

        -- output the second char
        when output_second_char =>
          -- set outputs
          new_addr             <= addr;
          new_first_char       <= first_char;
          new_second_char      <= second_char;
          new_out_char         <= second_char;
          new_out_char_type    <= second_char_type;
          new_first_char_type  <= first_char_type;
          new_second_char_type <= std_logic_vector(to_unsigned(zero_count, TRAIN_DATA_CHAR_TYPE_WIDTH));
          new_char_available   <= '1';
          new_zero_count       <= zero_count;
          axi_br_rden         <= '1';

          -- calc next state
          if send_next_char = '0' then
            next_state <= get_data;
          else
            next_state <= output_second_char;
          end if;

        -- finished reading
        when finished_reading =>
          next_state           <= finished_reading;
          new_first_char       <= (others => '0');
          new_second_char      <= (others => '0');
          new_out_char         <= (others => '0');
          new_first_char_type  <= (others => '0');
          new_second_char_type <= (others => '0');
          new_out_char_type    <= (others => '0');
          new_char_available   <= '0';
          new_addr             <= 0;
          new_zero_count       <= 0;
          axi_br_rden         <= '0';

        when others =>
          next_state           <= start;
          new_first_char       <= (others => '0');
          new_second_char      <= (others => '0');
          new_out_char         <= (others => '0');
          new_first_char_type  <= (others => '0');
          new_second_char_type <= (others => '0');
          new_out_char_type    <= (others => '0');
          new_char_available   <= '0';
          new_addr             <= 0;
          new_zero_count       <= 0;
          axi_br_rden         <= '0';
      end case;
    end if;
  end process set_next_state;

  -- Output to the bram
  axi_br_addr <= std_logic_vector(to_unsigned(BRAM_FIRST_ADDR + (addr*4), BRAM_ADDR_WIDTH));

  -- Output to the picture generator
  char      <= out_char;
  char_type <= out_char_type;

end Behavioral;
