-------------------------------------------------------
--! @file       async_fifo.vhd
--! @brief      fifo with 2 different clocks
--! @author     Régis Spadotti (Scalian) 
--! @author     Michel Francis (Scalian)
--! @author     F.Manni (Cnes)
--!
--!-----------------------------------------------------------------------------------------------
--! @copyright  CNES   
--! @verbatim
--! This File is licensed as MIT license
--! Permission is hereby granted, free of charge, to any person obtaining a copy
--! of this software and associated documentation files (the "Software"), to deal
--! in the Software without restriction, including without limitation the rights
--! to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--! copies of the Software, and to permit persons to whom the Software is
--! furnished to do so, subject to the following conditions:
--! 
--! The above copyright notice and this permission notice shall be included in all
--! copies or substantial portions of the Software.
--! 
--! THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--! IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--! FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--! AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--! LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--! OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--! SOFTWARE.
--! @endverbatim
--!
--!-----------------------------------------------------------------------------------------------
--! * Version         : V1.1
--! * Version history : 
--!    * V1 :  2021-03-08 : Scalian : Creation
--!    * V2 :  2021-05-19 : F.Manni (CNES) : 
--!                         * Improve documentation
--! 
--!-----------------------------------------------------------------------------------------------
--! File Creation date : 2021-03-08
--! Project name       : R5 reference Design
--! 
--!-----------------------------------------------------------------------------------------------
--! Softwares             :  
--!     * PC          : Linux Ubuntu 20.04LTS 
--!     * Editor      : Visual studio code 2021-05 + Eclipse 2019-12
--!     * Synthetizer : Nxmap 3.5.0.4 (29th march 2021)
--!     * P&R         : Nxmap 3.5.0.4 (29th march 2021)
--! Automatic VHDL coding :  NO 
--! 
--!-----------------------------------------------------------------------------------------------
--! @details  
--!  
--! @todo provide a detailed description and comments tag for this entity for doxygen
--!
--! Limitations : None
--!
-------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity async_fifo is
  generic (
      -- DW: Data Width (in bits)
    DW : positive := 16;
      -- AW: Address Width (in bits), depth of FIFO is 2**AW
    AW : positive := 3
  );
  port (
    -- WRITE CLOCK DOMAIN
    wr_clk_i  : in  std_logic;
    wr_rst_ni : in  std_logic;
    wr_en_i   : in  std_logic;
    full_o    : out std_logic;
    data_i    : in  std_logic_vector(DW-1 downto 0);
    -- READ  CLOCK DOMAIN
    rd_clk_i  : in  std_logic;
    rd_rst_ni : in  std_logic;
    rd_en_i   : in  std_logic;
    empty_o   : out std_logic;
    data_o    : out std_logic_vector(DW-1 downto 0)
  );
end entity async_fifo;

architecture rtl of async_fifo is
  type Memory is array (0 to 2**AW-1) of std_logic_vector(DW-1 downto 0);
  signal mem : Memory := (others => (others => '0'));

  signal wr_widx_gray : std_logic_vector(AW downto 0);
  signal rd_ridx_gray : std_logic_vector(AW downto 0);

  type CDCSyncReg is array (1 downto 0) of std_logic_vector(AW downto 0);
begin
  wr_clk_dom: block is
    type RegType is record
      widx          : unsigned(AW downto 0);
      widx_gray     : unsigned(AW downto 0);
      ridx_gray_cdc : CDCSyncReg;
      full          : std_logic;
    end record;

    constant C_REG_INIT : RegType := (
      widx          => (others => '0'),
      widx_gray     => (others => '0'),
      ridx_gray_cdc => (others => (others => '0')),
      full          => '0'
    );

    signal r : RegType := C_REG_INIT;
    signal rin : RegType;

    signal ridx_gray : unsigned(AW downto 0);
    signal push : std_logic;

    signal widx_suc : unsigned(AW downto 0);
  begin
    push      <= not r.full and wr_en_i;
    ridx_gray <= unsigned(r.ridx_gray_cdc(1));
    widx_suc  <= r.widx + 1;

    process (push, r, rd_ridx_gray, ridx_gray, widx_suc) is
      variable v : RegType;
    begin
      v := r;

      if ridx_gray(AW) /= r.widx_gray(AW)
          and ridx_gray(AW-1) /= r.widx_gray(AW-1)
          and ridx_gray(AW-2 downto 0) = r.widx_gray(AW-2 downto 0)
      then v.full := '1';
      else v.full := '0';
      end if;

      if push = '1' then
        v.widx      := widx_suc;
        v.widx_gray := widx_suc xor shift_right(widx_suc, 1);

        if ridx_gray(AW) /= v.widx_gray(AW)
          and ridx_gray(AW-1) /= v.widx_gray(AW-1)
          and ridx_gray(AW-2 downto 0) = v.widx_gray(AW-2 downto 0)
        then v.full := '1';
        else v.full := '0';
        end if;
      end if;

      v.ridx_gray_cdc := r.ridx_gray_cdc(0) & std_logic_vector(rd_ridx_gray);

      rin <= v;

      wr_widx_gray <= std_logic_vector(r.widx_gray);
      full_o <= r.full;
    end process;


    process (wr_clk_i, wr_rst_ni) is
    begin
      if wr_rst_ni = '0' then
        r <= C_REG_INIT;
      elsif rising_edge(wr_clk_i) then
        r <= rin;

        if push = '1' then
          mem(to_integer(r.widx(AW-1 downto 0))) <= data_i;
        end if;
      end if;
    end process;
  end block wr_clk_dom;

  rd_clk_dom: block is
    type RegType is record
      ridx          : unsigned(AW downto 0);
      ridx_gray     : unsigned(AW downto 0);
      widx_gray_cdc : CDCSyncReg;
      empty         : std_logic;
      data          : std_logic_vector(DW-1 downto 0);
    end record;

    constant C_REG_INIT : RegType := (
      ridx          => (others => '0'),
      ridx_gray     => (others => '0'),
      widx_gray_cdc => (others => (others => '0')),
      empty         => '1',
      data          => (others => '0')
    );

    signal r : RegType := C_REG_INIT;
    signal rin : RegType;

    signal widx_gray : unsigned(AW downto 0);
    signal pop : std_logic;

    signal ridx_suc : unsigned(AW downto 0);
  begin
    pop <= not r.empty and rd_en_i;
    widx_gray <= unsigned(r.widx_gray_cdc(1));
    ridx_suc <= r.ridx + 1;

    process (pop, r, ridx_suc, widx_gray, wr_widx_gray) is
      variable v : RegType;
    begin
      v := r;

      if r.ridx_gray = widx_gray then
        v.empty := '1';
      else
        v.empty := '0';
      end if;

      if pop = '1' then
        v.ridx      := ridx_suc;
        v.ridx_gray := ridx_suc xor shift_right(ridx_suc, 1);

        if v.ridx_gray = widx_gray then
          v.empty := '1';
        else
          v.empty := '0';
        end if;
      end if;

      v.widx_gray_cdc := v.widx_gray_cdc(0) & wr_widx_gray;

      rin <= v;

      rd_ridx_gray <= std_logic_vector(r.ridx_gray);
      empty_o <= r.empty;
      data_o <= r.data;
    end process;

    process (rd_clk_i, rd_rst_ni) is
      variable idx : integer;
    begin
      if rd_rst_ni = '0' then
        r <= C_REG_INIT;
      elsif rising_edge(rd_clk_i) then
        r <= rin;

        if (r.empty or pop) = '1' then
          if r.empty = '1' then
            idx := to_integer(r.ridx(AW-1 downto 0));
          else
            idx := to_integer(ridx_suc(AW-1 downto 0));
          end if;
          r.data <= mem(idx);
        end if;
      end if;
    end process;
  end block rd_clk_dom;
end architecture rtl;
