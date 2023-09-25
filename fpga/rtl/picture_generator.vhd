----------------------------------------------------------------------------------
-- Engineer: Jakob Arndt <jakob.arndt@campus.tu-berlin.de>
-- 
-- Create Date: 06/10/2023 06:49:07 PM
-- Module Name: picture_generator - Behavioral
-- Project Name: AEP Project 2023 - Train Display
-- Target Devices: Zedboard
-- Description: State Machine placing the Letters on the Display, and fetching the
--              Bitmaps from the BRAM
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.vga_configuration.all;

use ieee.numeric_std.all;
entity picture_generator is
  generic (COLOR_WIDTH            : integer := 12;
           DISPLAY_WIDTH          : integer := TRAIN_DISPLAY_WIDTH;
           DISPLAY_HIGHT          : integer := TRAIN_DISPLAY_HEIGHT;
           PIXEL_X_ADDR_WITDH     : integer := 12;
           PIXEL_Y_ADDR_WITDH     : integer := 12;
           STATION_NAME_X_POS     : integer := 0;
           STATION_NAME_Y_POS     : integer := 0;
           TIME_X_POS             : integer := TRAIN_DISPLAY_WIDTH - (5*PSF_BITMAP_WIDTH*TIME_SCALE);
           TIME_Y_POS             : integer := 0;
           CONNECTION_X_POS       : integer := 0;
           CONNECTION_Y_POS       : integer := PSF_BITMAP_HEIGHT * (STATION_NAME_SCALE + 1);
           CONNECTION_LINE_HEIGHT : integer := PSF_BITMAP_HEIGHT * (CONNECTION_SCALE + 1);
           CONNECTION_CHAR_WIDTH  : integer := 80;

           GLYPH_BR_ADDR_WIDTH : integer := 8
           );

  port (  
    -- signals from and to the read_train_data module
    -- new char available from read_train_data module
    train_data_new_char : in  std_logic;

    -- char address and type from read_train_data module
    train_data_char     : in  std_logic_vector (PSF_CHAR_WIDTH-1 downto 0);
    train_data_type     : in  std_logic_vector (TRAIN_DATA_CHAR_TYPE_WIDTH-1 downto 0);

    -- '1' if picture_generator is ready to get new char
    ready               : out std_logic;

    -- BRAM connection to get bitmap of glyph
    glyph_br_addr : out std_logic_vector (GLYPH_BR_ADDR_WIDTH-1 downto 0);
    glyph_bitmap_in   : in  std_logic_vector (PSF_BITMAP_SIZE-1 downto 0);

    -- start position of the next character
    pixel_x    : out std_logic_vector (PIXEL_X_ADDR_WITDH-1 downto 0);
    pixel_y    : out std_logic_vector (PIXEL_Y_ADDR_WITDH-1 downto 0);

    -- color of the next character
    color      : out std_logic_vector (COLOR_WIDTH-1 downto 0);

    -- incoming signal, '1' if generate_glyph is done writing glyph bitmap
    glyph_done : in  std_logic;

    -- bitmap of the next character output to the glyph generating module
    glyph_bitmap_out : out std_logic_vector (PSF_BITMAP_SIZE-1 downto 0);

    -- signals whether a new bitmap is available
    output_new_bitmap : out std_logic;

    -- reset + clock signal
    clk   : in std_logic;
    reset : in std_logic);
end picture_generator;

architecture Behavioral of picture_generator is
  -- position for the next character
  signal start_pos_x : std_logic_vector (PIXEL_X_ADDR_WITDH-1 downto 0) := (others => '0');
  signal start_pos_y : std_logic_vector (PIXEL_Y_ADDR_WITDH-1 downto 0) := (others => '0');

  -- saves bitmap for the next character
  signal next_bitmap      : std_logic_vector (PSF_BITMAP_SIZE-1 downto 0)            := (others => '0');

  -- saves bitmap for the current character
  signal output_bitmap    : std_logic_vector (PSF_BITMAP_SIZE-1 downto 0)            := (others => '0');
  signal char_type        : std_logic_vector (TRAIN_DATA_CHAR_TYPE_WIDTH-1 downto 0) := CT_NOT_DEFINED;
  signal new_bitmap      : std_logic                                                 := '0';

  -- number of characters already displayed from the current char type
  signal char_counter     : integer                                                  := 0;

  -- number of connections already displayed !NOTE! not used yet
  signal connection_count : integer                                                  := 0;

  type gen_state is (start, get_char, wait_for_bram, read_char, set_char, wait_for_data);
  signal state      : gen_state := start;

begin

  -- passing char address to the bram if new char is available
  glyph_br_addr <= train_data_char when reset = '0' else (others => '0');

  -- multiplexer determining the start position of the next character based on the char type
  start_pos_x <= std_logic_vector(to_unsigned(STATION_NAME_X_POS, PIXEL_X_ADDR_WITDH)) when char_type = CT_STATION_NAME else
                 std_logic_vector(to_unsigned(TIME_X_POS, PIXEL_X_ADDR_WITDH))       when char_type = CT_CURR_TIME else
                 std_logic_vector(to_unsigned(CONNECTION_X_POS, PIXEL_X_ADDR_WITDH)) when char_type >= CT_CONNECTION else
                 (others => '0');

  start_pos_y <= std_logic_vector(to_unsigned(STATION_NAME_Y_POS, PIXEL_Y_ADDR_WITDH)) when char_type = CT_STATION_NAME else
                 std_logic_vector(to_unsigned(TIME_Y_POS, PIXEL_Y_ADDR_WITDH))       when char_type = CT_CURR_TIME else
                 std_logic_vector(to_unsigned(CONNECTION_Y_POS + connection_count * PSF_BITMAP_HEIGHT, PIXEL_Y_ADDR_WITDH)) when char_type >= CT_CONNECTION else
                 (others => '0');

  connection_count <= to_integer(unsigned(char_type)) - to_integer(unsigned(CT_CONNECTION)) when char_type >= CT_CONNECTION else 0;
  pixel_x <= std_logic_vector(to_unsigned(to_integer(unsigned(start_pos_x)) + char_counter * PSF_BITMAP_WIDTH, PIXEL_X_ADDR_WITDH));
  pixel_y <= std_logic_vector(to_unsigned(to_integer(unsigned(start_pos_y)), PIXEL_Y_ADDR_WITDH));


  -- multiplexer determining the color of the next character based on the char type
  color <= x"DDD" when char_type = CT_STATION_NAME else
           x"FE0"          when char_type = CT_CURR_TIME else
           (others => '1') when char_type >= CT_CONNECTION else
           (others => '0');

  -- signals whether the picture_generator is ready to get new char
  ready <= '1' when state = start else '0';

  -- output bitmap of the next character
  glyph_bitmap_out <= output_bitmap;

  output_new_bitmap <= new_bitmap;

  set_next_state : process (clk, reset)
  begin
    if rising_edge(clk) then
    if (reset = '1') then
      state   <= start;
      new_bitmap <= '0';
      next_bitmap <= (others => '0');
      output_bitmap <= (others => '0');
    else
      case state is
        when start =>
          -- set outputs
          new_bitmap <= '0';
          output_bitmap <= output_bitmap;
          next_bitmap <= next_bitmap;

          -- set next state
          if train_data_new_char = '1' then
            state <= get_char;
          else
            state <= start;
          end if;

        when get_char =>
          -- set outputs
          output_bitmap <= output_bitmap;
          next_bitmap <= next_bitmap;
          new_bitmap <= '0';

          -- set next state
          state     <= wait_for_bram;

        -- wait for BRAM to get the data
        when wait_for_bram =>
          -- set outputs
          new_bitmap <= '0';
          output_bitmap <= output_bitmap;
          next_bitmap <= next_bitmap;

          -- set next state
          state     <= read_char;

        -- read bitmap from BRAM: BRAM needs one cycle to get the data
        when read_char =>
          -- set outputs
          next_bitmap <= glyph_bitmap_in;
          new_bitmap <= '0';
          output_bitmap <= output_bitmap;

          -- set next state
          if glyph_done = '1' then
            state    <= set_char;
          else
            state    <= read_char;
          end if;

        when set_char =>
          -- save bitmap until glyph module is ready
          next_bitmap <= next_bitmap;
          new_bitmap <= '1';
          output_bitmap <= next_bitmap;

          if glyph_done = '0' then
            state    <= wait_for_data;
          else
            state    <= set_char;
          end if;

        when wait_for_data =>
          -- wait for read train data module to get the data
          if train_data_new_char = '0' then
            state <= start;
          else
            state <= wait_for_data;
          end if;
          next_bitmap <= next_bitmap;
          output_bitmap <= output_bitmap;
          new_bitmap <= '0';

        when others =>
          state   <= start;
          new_bitmap <= '0';
          next_bitmap <= (others => '0');
          output_bitmap <= (others => '0');
      end case;
    end if;
    end if;
  end process set_next_state;

  delay_pixel_start_pos : process (new_bitmap)
  begin
    if rising_edge(new_bitmap) then
      char_type <= train_data_type;

      -- calc character number
      if char_type = CT_NOT_DEFINED or char_counter = 80 
        or char_type /= train_data_type then
        char_counter <= 0;
      else
        char_counter <= char_counter + 1;
      end if;
    end if;
  end process;

end Behavioral;
