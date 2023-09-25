----------------------------------------------------------------------------------
-- Engineer: Jakob Arndt <jakob.arndt@campus.tu-berlin.de>
-- 
-- Create Date: 06/10/2023 06:55:46 PM
-- Module Name: get_char_addr - Behavioral
-- Project Name: AEP Project 2023 - Train Display
-- Target Devices: ZedBoard
-- Description: Multiplexer mapping unicode characters to bram addresses
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

library work;
use work.vga_configuration.all;

entity get_char_addr is
  generic (CHAR_IN_ADDR_WIDTH  : integer := UNICODE_CHAR_WIDTH;
           CHAR_OUT_ADDR_WIDTH : integer := PSF_CHAR_WIDTH);

  port (char_addr_out : out std_logic_vector (CHAR_OUT_ADDR_WIDTH-1 downto 0);
        char_addr_in  : in  std_logic_vector (CHAR_IN_ADDR_WIDTH-1 downto 0)
        );
end get_char_addr;

architecture Behavioral of get_char_addr is

begin

  -- get character address from lookup table
  char_addr_out <= x"00" when char_addr_in = x"00a9" else  -- ©
                   x"01" when char_addr_in = x"00ae" else  -- ®
                   x"02" when char_addr_in = x"00d8" else  -- Ø
                   x"03" when char_addr_in = x"0104" else  -- Ą
                   x"04" when char_addr_in = x"2666" else  -- ♦
                   x"05" when char_addr_in = x"0105" else  -- ą
                   x"06" when char_addr_in = x"0118" else  -- Ę
                   x"07" when char_addr_in = x"0173" else  -- ų
                   x"08" when char_addr_in = x"2022" else  -- •
                   x"09" when char_addr_in = x"2122" else  -- ™
                   x"0a" when char_addr_in = x"00a4" else  -- ¤
                   x"0b" when char_addr_in = x"00a6" else  -- ¦
                   x"0c" when char_addr_in = x"00a8" else  -- ¨
                   x"0d" when char_addr_in = x"00af" else  -- ¯
                   x"0e" when char_addr_in = x"00b3" else  -- ³
                   x"0f" when char_addr_in = x"00b4" else  -- ´
                   x"10" when char_addr_in = x"00b8" else  -- ¸
                   x"11" when char_addr_in = x"00b9" else  -- ¹
                   x"12" when char_addr_in = x"00be" else  -- ¾
                   x"13" when char_addr_in = x"00d3" else  -- Ó
                   x"14" when char_addr_in = x"00b6" else  -- ¶
                   x"15" when char_addr_in = x"00a7" else  -- §
                   x"16" when char_addr_in = x"00d5" else  -- Õ
                   x"17" when char_addr_in = x"00d7" else  -- ×
                   x"18" when char_addr_in = x"2191" else  -- ↑
                   x"19" when char_addr_in = x"2193" else  -- ↓
                   x"1a" when char_addr_in = x"2192" else  -- →
                   x"1b" when char_addr_in = x"2190" else  -- ←
                   x"1c" when char_addr_in = x"00f5" else  -- õ
                   x"1d" when char_addr_in = x"00f8" else  -- ø
                   x"1e" when char_addr_in = x"0100" else  -- Ā
                   x"1f" when char_addr_in = x"0101" else  -- ā
                   x"20" when char_addr_in = x"0020" else  --  
                   x"21" when char_addr_in = x"0021" else  -- !
                   x"22" when char_addr_in = x"0022" else  -- "
                   x"23" when char_addr_in = x"0023" else  -- #
                   x"24" when char_addr_in = x"0024" else  -- $
                   x"25" when char_addr_in = x"0025" else  -- %
                   x"26" when char_addr_in = x"0026" else  -- &
                   x"27" when char_addr_in = x"0027" else  -- '
                   x"28" when char_addr_in = x"0028" else  -- (
                   x"29" when char_addr_in = x"0029" else  -- )
                   x"2a" when char_addr_in = x"002a" else  -- *
                   x"2b" when char_addr_in = x"002b" else  -- +
                   x"2c" when char_addr_in = x"002c" else  -- ,
                   x"2d" when char_addr_in = x"002d" else  -- -
                   x"2e" when char_addr_in = x"002e" else  -- .
                   x"2f" when char_addr_in = x"002f" else  -- /
                   x"30" when char_addr_in = x"0030" else  -- 0
                   x"31" when char_addr_in = x"0031" else  -- 1
                   x"32" when char_addr_in = x"0032" else  -- 2
                   x"33" when char_addr_in = x"0033" else  -- 3
                   x"34" when char_addr_in = x"0034" else  -- 4
                   x"35" when char_addr_in = x"0035" else  -- 5
                   x"36" when char_addr_in = x"0036" else  -- 6
                   x"37" when char_addr_in = x"0037" else  -- 7
                   x"38" when char_addr_in = x"0038" else  -- 8
                   x"39" when char_addr_in = x"0039" else  -- 9
                   x"3a" when char_addr_in = x"003a" else  -- :
                   x"3b" when char_addr_in = x"003b" else  -- ;
                   x"3c" when char_addr_in = x"003c" else  -- <
                   x"3d" when char_addr_in = x"003d" else  -- =
                   x"3e" when char_addr_in = x"003e" else  -- >
                   x"3f" when char_addr_in = x"003f" else  -- ?
                   x"40" when char_addr_in = x"0040" else  -- @
                   x"41" when char_addr_in = x"0041" else  -- A
                   x"42" when char_addr_in = x"0042" else  -- B
                   x"43" when char_addr_in = x"0043" else  -- C
                   x"44" when char_addr_in = x"0044" else  -- D
                   x"45" when char_addr_in = x"0045" else  -- E
                   x"46" when char_addr_in = x"0046" else  -- F
                   x"47" when char_addr_in = x"0047" else  -- G
                   x"48" when char_addr_in = x"0048" else  -- H
                   x"49" when char_addr_in = x"0049" else  -- I
                   x"4a" when char_addr_in = x"004a" else  -- J
                   x"4b" when char_addr_in = x"004b" else  -- K
                   x"4c" when char_addr_in = x"004c" else  -- L
                   x"4d" when char_addr_in = x"004d" else  -- M
                   x"4e" when char_addr_in = x"004e" else  -- N
                   x"4f" when char_addr_in = x"004f" else  -- O
                   x"50" when char_addr_in = x"0050" else  -- P
                   x"51" when char_addr_in = x"0051" else  -- Q
                   x"52" when char_addr_in = x"0052" else  -- R
                   x"53" when char_addr_in = x"0053" else  -- S
                   x"54" when char_addr_in = x"0054" else  -- T
                   x"55" when char_addr_in = x"0055" else  -- U
                   x"56" when char_addr_in = x"0056" else  -- V
                   x"57" when char_addr_in = x"0057" else  -- W
                   x"58" when char_addr_in = x"0058" else  -- X
                   x"59" when char_addr_in = x"0059" else  -- Y
                   x"5a" when char_addr_in = x"005a" else  -- Z
                   x"5b" when char_addr_in = x"005b" else  -- [
                   x"5c" when char_addr_in = x"005c" else  -- \
                   x"5d" when char_addr_in = x"005d" else  -- ]
                   x"5e" when char_addr_in = x"005e" else  -- ^
                   x"5f" when char_addr_in = x"005f" else  -- _
                   x"60" when char_addr_in = x"0060" else  -- `
                   x"61" when char_addr_in = x"0061" else  -- a
                   x"62" when char_addr_in = x"0062" else  -- b
                   x"63" when char_addr_in = x"0063" else  -- c
                   x"64" when char_addr_in = x"0064" else  -- d
                   x"65" when char_addr_in = x"0065" else  -- e
                   x"66" when char_addr_in = x"0066" else  -- f
                   x"67" when char_addr_in = x"0067" else  -- g
                   x"68" when char_addr_in = x"0068" else  -- h
                   x"69" when char_addr_in = x"0069" else  -- i
                   x"6a" when char_addr_in = x"006a" else  -- j
                   x"6b" when char_addr_in = x"006b" else  -- k
                   x"6c" when char_addr_in = x"006c" else  -- l
                   x"6d" when char_addr_in = x"006d" else  -- m
                   x"6e" when char_addr_in = x"006e" else  -- n
                   x"6f" when char_addr_in = x"006f" else  -- o
                   x"70" when char_addr_in = x"0070" else  -- p
                   x"71" when char_addr_in = x"0071" else  -- q
                   x"72" when char_addr_in = x"0072" else  -- r
                   x"73" when char_addr_in = x"0073" else  -- s
                   x"74" when char_addr_in = x"0074" else  -- t
                   x"75" when char_addr_in = x"0075" else  -- u
                   x"76" when char_addr_in = x"0076" else  -- v
                   x"77" when char_addr_in = x"0077" else  -- w
                   x"78" when char_addr_in = x"0078" else  -- x
                   x"79" when char_addr_in = x"0079" else  -- y
                   x"7a" when char_addr_in = x"007a" else  -- z
                   x"7b" when char_addr_in = x"007b" else  -- {
                   x"7c" when char_addr_in = x"007c" else  -- |
                   x"7d" when char_addr_in = x"007d" else  -- }
                   x"7e" when char_addr_in = x"007e" else  -- ~
                   x"7f" when char_addr_in = x"0106" else  -- Ć
                   x"80" when char_addr_in = x"00c7" else  -- Ç
                   x"81" when char_addr_in = x"00fc" else  -- ü
                   x"82" when char_addr_in = x"00e9" else  -- é
                   x"83" when char_addr_in = x"00e2" else  -- â
                   x"84" when char_addr_in = x"00e4" else  -- ä
                   x"85" when char_addr_in = x"00e0" else  -- à
                   x"86" when char_addr_in = x"00e5" else  -- å
                   x"87" when char_addr_in = x"00e7" else  -- ç
                   x"88" when char_addr_in = x"00ea" else  -- ê
                   x"89" when char_addr_in = x"00eb" else  -- ë
                   x"8a" when char_addr_in = x"00e8" else  -- è
                   x"8b" when char_addr_in = x"0107" else  -- ć
                   x"8c" when char_addr_in = x"010c" else  -- Č
                   x"8d" when char_addr_in = x"010d" else  -- č
                   x"8e" when char_addr_in = x"00c4" else  -- Ä
                   x"8f" when char_addr_in = x"00c5" else  -- Å
                   x"90" when char_addr_in = x"00c9" else  -- É
                   x"91" when char_addr_in = x"00e6" else  -- æ
                   x"92" when char_addr_in = x"00c6" else  -- Æ
                   x"93" when char_addr_in = x"0112" else  -- Ē
                   x"94" when char_addr_in = x"00f6" else  -- ö
                   x"95" when char_addr_in = x"0113" else  -- ē
                   x"96" when char_addr_in = x"0116" else  -- Ė
                   x"97" when char_addr_in = x"0117" else  -- ė
                   x"98" when char_addr_in = x"0119" else  -- ę
                   x"99" when char_addr_in = x"00d6" else  -- Ö
                   x"9a" when char_addr_in = x"00dc" else  -- Ü
                   x"9b" when char_addr_in = x"00a2" else  -- ¢
                   x"9c" when char_addr_in = x"00a3" else  -- £
                   x"9d" when char_addr_in = x"0122" else  -- Ģ
                   x"9e" when char_addr_in = x"0123" else  -- ģ
                   x"9f" when char_addr_in = x"012a" else  -- Ī
                   x"a0" when char_addr_in = x"00e1" else  -- á
                   x"a1" when char_addr_in = x"00ed" else  -- í
                   x"a2" when char_addr_in = x"00f3" else  -- ó
                   x"a3" when char_addr_in = x"00fa" else  -- ú
                   x"a4" when char_addr_in = x"00f1" else  -- ñ
                   x"a5" when char_addr_in = x"00d1" else  -- Ñ
                   x"a6" when char_addr_in = x"012b" else  -- ī
                   x"a7" when char_addr_in = x"012e" else  -- Į
                   x"a8" when char_addr_in = x"00bf" else  -- ¿
                   x"a9" when char_addr_in = x"012f" else  -- į
                   x"aa" when char_addr_in = x"00ac" else  -- ¬
                   x"ab" when char_addr_in = x"00bd" else  -- ½
                   x"ac" when char_addr_in = x"00bc" else  -- ¼
                   x"ad" when char_addr_in = x"00a1" else  -- ¡
                   x"ae" when char_addr_in = x"00ab" else  -- «
                   x"af" when char_addr_in = x"00bb" else  -- »
                   x"b0" when char_addr_in = x"2591" else  -- ░
                   x"b1" when char_addr_in = x"2592" else  -- ▒
                   x"b2" when char_addr_in = x"0136" else  -- Ķ
                   x"b3" when char_addr_in = x"2502" else  -- │
                   x"b4" when char_addr_in = x"2524" else  -- ┤
                   x"b5" when char_addr_in = x"0137" else  -- ķ
                   x"b6" when char_addr_in = x"013b" else  -- Ļ
                   x"b7" when char_addr_in = x"013c" else  -- ļ
                   x"b8" when char_addr_in = x"0141" else  -- Ł
                   x"b9" when char_addr_in = x"0142" else  -- ł
                   x"ba" when char_addr_in = x"0143" else  -- Ń
                   x"bb" when char_addr_in = x"0144" else  -- ń
                   x"bc" when char_addr_in = x"0145" else  -- Ņ
                   x"bd" when char_addr_in = x"0146" else  -- ņ
                   x"be" when char_addr_in = x"014c" else  -- Ō
                   x"bf" when char_addr_in = x"2510" else  -- ┐
                   x"c0" when char_addr_in = x"2514" else  -- └
                   x"c1" when char_addr_in = x"2534" else  -- ┴
                   x"c2" when char_addr_in = x"252c" else  -- ┬
                   x"c3" when char_addr_in = x"251c" else  -- ├
                   x"c4" when char_addr_in = x"2500" else  -- ─
                   x"c5" when char_addr_in = x"253c" else  -- ┼
                   x"c6" when char_addr_in = x"014d" else  -- ō
                   x"c7" when char_addr_in = x"0156" else  -- Ŗ
                   x"c8" when char_addr_in = x"0157" else  -- ŗ
                   x"c9" when char_addr_in = x"015a" else  -- Ś
                   x"ca" when char_addr_in = x"015b" else  -- ś
                   x"cb" when char_addr_in = x"0160" else  -- Š
                   x"cc" when char_addr_in = x"0161" else  -- š
                   x"cd" when char_addr_in = x"016a" else  -- Ū
                   x"ce" when char_addr_in = x"016b" else  -- ū
                   x"cf" when char_addr_in = x"0172" else  -- Ų
                   x"d0" when char_addr_in = x"0179" else  -- Ź
                   x"d1" when char_addr_in = x"017a" else  -- ź
                   x"d2" when char_addr_in = x"017b" else  -- Ż
                   x"d3" when char_addr_in = x"017c" else  -- ż
                   x"d4" when char_addr_in = x"017d" else  -- Ž
                   x"d5" when char_addr_in = x"017e" else  -- ž
                   x"d6" when char_addr_in = x"02c7" else  -- ˇ
                   x"d7" when char_addr_in = x"02d9" else  -- ˙
                   x"d8" when char_addr_in = x"02db" else  -- ˛
                   x"d9" when char_addr_in = x"2518" else  -- ┘
                   x"da" when char_addr_in = x"250c" else  -- ┌
                   x"db" when char_addr_in = x"2588" else  -- █
                   x"dc" when char_addr_in = x"2014" else  -- —
                   x"dd" when char_addr_in = x"2018" else  -- ‘
                   x"de" when char_addr_in = x"2019" else  -- ’
                   x"df" when char_addr_in = x"201a" else  -- ‚
                   x"e0" when char_addr_in = x"201c" else  -- “
                   x"e1" when char_addr_in = x"00df" else  -- ß
                   x"e2" when char_addr_in = x"201d" else  -- ”
                   x"e3" when char_addr_in = x"03c0" else  -- π
                   x"e4" when char_addr_in = x"201e" else  -- „
                   x"e5" when char_addr_in = x"2020" else  -- †
                   x"e6" when char_addr_in = x"00b5" else  -- µ
                   x"e7" when char_addr_in = x"2021" else  -- ‡
                   x"e8" when char_addr_in = x"2026" else  -- …
                   x"e9" when char_addr_in = x"2030" else  -- ‰
                   x"ea" when char_addr_in = x"2039" else  -- ‹
                   x"eb" when char_addr_in = x"203a" else  -- ›
                   x"ec" when char_addr_in = x"20ac" else  -- €
                   x"ed" when char_addr_in = x"2260" else  -- ≠
                   x"ee" when char_addr_in = x"2116" else  -- №
                   x"ef" when char_addr_in = x"00c1" else  -- Á
                   x"f0" when char_addr_in = x"00cd" else  -- Í
                   x"f1" when char_addr_in = x"00b1" else  -- ±
                   x"f2" when char_addr_in = x"2265" else  -- ≥
                   x"f3" when char_addr_in = x"2264" else  -- ≤
                   x"f4" when char_addr_in = x"00da" else  -- Ú
                   x"f5" when char_addr_in = x"00c0" else  -- À
                   x"f6" when char_addr_in = x"00f7" else  -- ÷
                   x"f7" when char_addr_in = x"2248" else  -- ≈
                   x"f8" when char_addr_in = x"00b0" else  -- °
                   x"f9" when char_addr_in = x"00c2" else  -- Â
                   x"fa" when char_addr_in = x"00b7" else  -- ·
                   x"fb" when char_addr_in = x"00c8" else  -- È
                   x"fc" when char_addr_in = x"00ca" else  -- Ê
                   x"fd" when char_addr_in = x"00b2" else  -- ²
                   x"fe" when char_addr_in = x"25a0" else  -- ■
                   x"ff" when char_addr_in = x"00cb" else  -- Ë
                   x"3f";                                  -- ?

end Behavioral;
