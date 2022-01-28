-------------------------------------------------------
--! @file       axi_filter.vhd
--! @brief      out of range address management for AXI
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
use work.AxiPkg.all;
use work.AddrDecoderPkg.all;

entity axi_filter is
  generic (
    AXI_MIN_AXSIZE        : natural range 0 to 3 := 0;
    AXI_MAX_AXSIZE        : natural range 0 to 3 := 3;
    AXI_MIN_AXLEN         : natural range 0 to 3 := 0;
    AXI_MAX_AXLEN         : natural range 0 to 3 := 3;
    AXI_ALLOW_FIXED_BURST : boolean              := false;
    AXI_ALLOW_INCR_BURST  : boolean              := true;
    AXI_ALLOW_WRAP_BURST  : boolean              := true;
    ADDR_MAP              : AddrMappingTable;
    ADDR_MSB              : natural;
    ADDR_LSB              : natural
  );
  port (
    s_axi_aclk    : in  std_logic;
    s_axi_aresetn : in  std_logic;
    s_axi_master  : in  AxiMasterType;
    s_axi_slave   : out AxiSlaveType;
    m_axi_master  : out AxiMasterType;
    m_axi_slave   : in  AxiSlaveType;
    r_index       : out natural;
    w_index       : out natural
  );
end entity axi_filter;

architecture rtl of axi_filter is

  signal awsel, arsel : std_logic_vector(0 downto 0);

  signal axi_masters : AxiMasterArray(1 downto 0);
  signal axi_slaves  : AxiSlaveArray(1 downto 0);


  procedure filter(signal ax  : in  AxiAddrChannelType;
                   signal sel : out std_logic_vector(0 downto 0);
                   signal ind : out natural) is
    constant axsize : natural := to_integer(unsigned(ax.size));
    constant axlen  : natural := to_integer(unsigned(ax.len));
    constant axaddr : std_logic_vector := ax.addr;
    variable index  : natural range 0 to ADDR_MAP'length;
  begin
    sel <= "1";

    if axsize < AXI_MIN_AXSIZE or AXI_MAX_AXSIZE < axsize then
      sel <= "0";
    end if;

    if axlen < AXI_MIN_AXLEN or AXI_MAX_AXLEN < axlen then
      sel <= "0";
    end if;

    if not AXI_ALLOW_FIXED_BURST and (ax.burst(0) or ax.burst(1)) = '0' then
      sel <= "0";
    end if;

    if not AXI_ALLOW_INCR_BURST and ax.burst(0) = '1' then
      sel <= "0";
    end if;

    if not AXI_ALLOW_WRAP_BURST and ax.burst(1) = '1' then
      sel <= "0";
    end if;

    addr_map_decode(ADDR_MAP, ADDR_MSB, ADDR_LSB, axaddr, index);

    if index = ADDR_MAP'length then
      sel <= "0";
    end if;

    ind <= index;

  end procedure filter;

begin
  filter(s_axi_master.aw, awsel, w_index);
  filter(s_axi_master.ar, arsel, r_index);

  axi_demux_inst: entity work.axi_demux
    generic map (NM => 2)
    port map (
      s_axi_aclk    => s_axi_aclk,
      s_axi_aresetn => s_axi_aresetn,
      awsel         => awsel,
      arsel         => arsel,
      s_axi_master  => s_axi_master,
      s_axi_slave   => s_axi_slave,
      m_axi_masters => axi_masters,
      m_axi_slaves  => axi_slaves);

  axi_slave_err_1: entity work.axi_slave_err
    generic map (
      AXI_ERR_RESP => C_AXI_RESP_SLVERR)
    port map (
      s_axi_aclk    => s_axi_aclk,
      s_axi_aresetn => s_axi_aresetn,
      s_axi_master  => axi_masters(0),
      s_axi_slave   => axi_slaves(0));

      m_axi_master <= axi_masters(1);
      axi_slaves(1) <= m_axi_slave;

end architecture rtl;
