-------------------------------------------------------
--! @file       sync_fifo.vhd
--! @brief      synchronous fifo (1clock domain)
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

use work.common_functions_pkg.all;

entity sync_fifo is
  generic (
    DW : positive := 16;
    AW : positive := 3
  );
  port (
    clk_i   : in  std_logic;
    rst_ni  : in  std_logic;
    --
    wen_i   : in  std_logic;
    data_i  : in  std_logic_vector(DW-1 downto 0);
    full_o  : out std_logic;
    --
    ren_i   : in  std_logic;
    data_o  : out std_logic_vector(DW-1 downto 0);
    empty_o : out std_logic
  );
end entity sync_fifo;

architecture rtl of sync_fifo is
  type Memory is array (0 to 2**AW-1) of std_logic_vector(DW-1 downto 0);
  signal mem : Memory := (others => (others => '0'));

  type RegType is record
    empty : std_logic;
    full  : std_logic;
    widx  : unsigned(AW-1 downto 0);
    ridx  : unsigned(AW-1 downto 0);
    bvalid : std_logic;
    bdata  : std_logic_vector(DW-1 downto 0);
  end record;

  constant C_REG_INIT : RegType := (
    empty => '1',
    full  => '0',
    widx  => (others => '0'),
    ridx  => (others => '0'),
    bvalid => '0',
    bdata => (others => '0')
  );

  signal r   : RegType := C_REG_INIT;
  signal rin : RegType;

  signal mem_data_q : std_logic_vector(DW-1 downto 0) := (others => '0');

  signal push, pop : std_logic;
  signal widx_suc, ridx_suc : unsigned(AW-1 downto 0);
begin
  push <= wen_i and not r.full;
  pop  <= ren_i and not r.empty;

  widx_suc <= r.widx + 1;
  ridx_suc <= r.ridx + 1;

  comb: process (data_i, mem_data_q, pop, push, r, ren_i, ridx_suc, wen_i,
                 widx_suc) is
    variable v : RegType;
  begin
    v := r;

    ---- [NEXT LOGIC] -----------------------------------------------------[--
    if push = '1' then
      v.widx := widx_suc;
    end if;
    if pop = '1' then
      v.ridx := ridx_suc;
    end if;

    if (push or pop) = '1' then
      v.full  := not pop and to_logic(widx_suc = r.ridx);
      v.empty := not push and to_logic(ridx_suc = r.widx);
    end if;

    v.bvalid := r.empty;
    if (v.empty or (ren_i and to_logic(ridx_suc = r.widx))) = '1' then
      v.bvalid := '1';
    elsif wen_i = '0' then
      v.bvalid := '0';
    end if;

    v.bdata := data_i;
    --]------------------------------------------------------------------------

    ---- [OUTPUTS] ------------------------------------------------------------
    full_o  <= r.full;
    empty_o <= r.empty;
    if r.bvalid = '1' then
      data_o <= r.bdata;
    else
      data_o <= mem_data_q;
    end if;
    ---------------------------------------------------------------------------

    rin <= v;
  end process comb;

  ff: process (clk_i, rst_ni) is
    variable idx : integer;
  begin
    if rst_ni = '0' then
      r <= C_REG_INIT;
    elsif rising_edge(clk_i) then
      r <= rin;

      if push = '1' then
        mem(to_integer(r.widx)) <= data_i;
      end if;

      if ren_i = '1' then
        idx := to_integer(ridx_suc);
      else
        idx := to_integer(r.ridx);
      end if;

      mem_data_q <= mem(idx);
    end if;
  end process ff;
end architecture rtl;
