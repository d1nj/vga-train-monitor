library ieee;
use ieee.std_logic_1164.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;

use std.env.stop;

library work;
use work.vga_configuration.all;

entity vga_top_tb is
end entity vga_top_tb;

architecture rtl of vga_top_tb is
  -- clock and reset
  signal top_clk       : std_logic := '0';
  signal top_rst       : std_logic := '0';
  signal clk           : std_logic := '0';
  constant clk_period  : time      := 20 ns;
  constant half_period : time      := 10 ns;


  -- signals between picture generator and generate_glyph module
  signal pg_pixel_x          : std_logic_vector(11 downto 0)                := (others => '0');
  signal pg_pixel_y          : std_logic_vector(11 downto 0)                := (others => '0');
  signal pg_char_color       : std_logic_vector(11 downto 0)                := (others => '0');
  signal pg_glyph_bitmap_out : std_logic_vector(PSF_BITMAP_SIZE-1 downto 0) := (others => '0');
  signal pg_glyph_done       : std_logic                                    := '0';
  signal pg_output_new_bitmap: std_logic                                    := '0';

  -- signals between picture generator and read train data module
  signal pg_train_data_char     : std_logic_vector(7 downto 0) := (others => '0');
  signal pg_train_data_type     : std_logic_vector(TRAIN_DATA_CHAR_TYPE_WIDTH-1 downto 0) := (others => '0');
  signal rtd_new_char_avail : std_logic                    := '0';
  signal send_next_char               : std_logic                    := '0';

  -- read train data enable
  signal rtd_enable : std_logic := '0';

  -- signals between picture generator and glyph bram
  signal pg_glyph_br_addr : std_logic_vector (PSF_CHAR_WIDTH-1 downto 0) := (others => '0');
  signal pg_char_bitmap   : std_logic_vector(PSF_BITMAP_SIZE-1 downto 0) := (others => '0');

  -- generate_glyph output signals
  signal gg_x_pos : std_logic_vector(11 downto 0) := (others => '0');
  signal gg_y_pos : std_logic_vector(11 downto 0) := (others => '0');
  signal gg_color : std_logic_vector(11 downto 0) := (others => '0');


  -- signals connecting train data module with axi bram
  signal axi_br_addr  : std_logic_vector(7 downto 0)  := (others => '0');
  signal axi_br_rdata : std_logic_vector(31 downto 0) := (others => '0');
  signal axi_br_rden  : std_logic                    := '0';

  signal rtd_char : std_logic_vector(15 downto 0) := (others => '0');


  COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
  );
END COMPONENT;

  component vga_design_blk_mem_gen_0_0 is
    port (
      clka  : in  std_logic;
      addra : in  std_logic_vector (7 downto 0);
      douta : out std_logic_vector (127 downto 0)
      );
  end component vga_design_blk_mem_gen_0_0;


begin

  clk     <= not clk  after half_period;
  top_rst <= '1', '0' after 10 ns;
  top_clk <= clk;

  -- Instantiate Picture Generator (DUT)
  dut : entity work.picture_generator
    port map (
      -- signals between picture generator and generate_glyph module
      pixel_x          => pg_pixel_x,
      pixel_y          => pg_pixel_y,
      color            => pg_char_color,
      glyph_done       => pg_glyph_done,
      glyph_bitmap_out => pg_glyph_bitmap_out,
      output_new_bitmap=> pg_output_new_bitmap,

      -- signals between picture generator and read train data module
      train_data_char     => pg_train_data_char,
      ready               => send_next_char,
      train_data_type     => pg_train_data_type,
      train_data_new_char => rtd_new_char_avail,

      -- clock and reset
      clk   => top_clk,
      reset => top_rst,

      -- signals between picture generator and glyph bram
      glyph_bitmap_in => pg_char_bitmap,
      glyph_br_addr   => pg_glyph_br_addr
      );


  -- Instantiate generate_glyph module
  glyph_generator : entity work.generate_glyph
    port map (
      -- input from the picture generator
      glyph_start_pos_x => pg_pixel_x,
      glyph_start_pos_y => pg_pixel_y,
      char_color        => pg_char_color,
      char_bitmap       => pg_glyph_bitmap_out,
      scale             => "00",
      new_char          => pg_output_new_bitmap,
      glyph_done        => pg_glyph_done,

      -- output to the framebuffer gen
      x_pos       => gg_x_pos,
      y_pos       => gg_y_pos,
      pixel_color => gg_color,

      -- clock and reset
      clk         => top_clk,
      reset       => top_rst);

  -- Instantiate Framebuffer gen
  fb_gen : entity work.framebuffer_gen
    port map (pixel_x => gg_x_pos,
              pixel_y => gg_y_pos,
              color   => gg_color,
              clk     => top_clk,
              reset   => top_rst);

  -- Instantiate read train data module
  read_train_data : entity work.read_train_data
    port map (clk            => top_clk,
              reset          => top_rst,
              enable         => rtd_enable,

              -- AXI BRAM signals
              axi_br_addr    => axi_br_addr,
              axi_br_data    => axi_br_rdata,
              axi_br_rden    => axi_br_rden,

              -- signals between read train data and picture generator
              new_char_available => rtd_new_char_avail,
              send_next_char => send_next_char,
              char           => rtd_char,
              char_type      => pg_train_data_type);

  -- Instantiate get char address module
  get_char_addr : entity work.get_char_addr
    port map (char_addr_out => pg_train_data_char,
              char_addr_in  => rtd_char);

  -- Instantiate train data bram
  axi_bram : blk_mem_gen_0
  PORT MAP (
    clka => top_clk,
    ena => axi_br_rden,
    wea => (others => '0'),
    addra => axi_br_addr,
    dina => (others => '0'),
    douta => axi_br_rdata
  );

  -- Instantiate glyph bram
  glyph_bram : component vga_design_blk_mem_gen_0_0
    port map (addra => pg_glyph_br_addr,
              clka  => top_clk,
              douta => pg_char_bitmap);


  stimulus : process
  begin
    rtd_enable <= '1';
    wait until top_rst = '0';
    wait for 3000 * clk_period;

    rtd_enable <= '0';
    wait for 1000 * clk_period;
    rtd_enable <= '1';
    wait for 3000 * clk_period;

    stop;
  end process;


end architecture rtl;
