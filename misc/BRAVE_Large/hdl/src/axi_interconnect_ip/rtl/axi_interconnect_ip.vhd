-------------------------------------------------------
--! @file       axi_interconnect_ip.vhd
--! @brief      AXI interconnect 
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
--! This IP is described in details in the [markdown readme file](../doc/user_guide.md)
--!
--! Limitations : None
--!
-------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use work.AddrDecoderPkg.all;
use work.AxiPkg.all;

entity axi_interconnect_ip is
  generic (
    --! Address mapping table (one address range per ports)
    ADDR_MAP_TABLE : AddrMappingTable     := C_ADDR_MAPPING_TABLE_DEFAULT(0 to 3);
    --! MSB position used to decode address
    ADDR_DEC_MSB : positive             := 31;
    --! LSB position used to decode address
    ADDR_DEC_LSB : natural              := 28 
  );
  port (
    S_AXI_ACLK     : in  std_logic;
    S_AXI_ARESETN  : in  std_logic;
    --
    S_AXI_AWID     : in  std_logic_vector(3 downto 0);
    S_AXI_AWADDR   : in  std_logic_vector(31 downto 0);
    S_AXI_AWLEN    : in  std_logic_vector(3 downto 0);
    S_AXI_AWSIZE   : in  std_logic_vector(2 downto 0);
    S_AXI_AWBURST  : in  std_logic_vector(1 downto 0);
    S_AXI_AWLOCK   : in  std_logic_vector(1 downto 0);
    S_AXI_AWCACHE  : in  std_logic_vector(3 downto 0);
    S_AXI_AWPROT   : in  std_logic_vector(2 downto 0);
    S_AXI_AWVALID  : in  std_logic;
    S_AXI_AWREADY  : out std_logic;
    S_AXI_WID      : in  std_logic_vector(3 downto 0);
    S_AXI_WDATA    : in  std_logic_vector(63 downto 0);
    S_AXI_WSTRB    : in  std_logic_vector(7 downto 0);
    S_AXI_WLAST    : in  std_logic;
    S_AXI_WVALID   : in  std_logic;
    S_AXI_WREADY   : out std_logic;
    S_AXI_BID      : out std_logic_vector(3 downto 0);
    S_AXI_BRESP    : out std_logic_vector(1 downto 0);
    S_AXI_BVALID   : out std_logic;
    S_AXI_BREADY   : in  std_logic;
    S_AXI_ARID     : in  std_logic_vector(3 downto 0);
    S_AXI_ARADDR   : in  std_logic_vector(31 downto 0);
    S_AXI_ARLEN    : in  std_logic_vector(3 downto 0);
    S_AXI_ARSIZE   : in  std_logic_vector(2 downto 0);
    S_AXI_ARBURST  : in  std_logic_vector(1 downto 0);
    S_AXI_ARLOCK   : in  std_logic_vector(1 downto 0);
    S_AXI_ARCACHE  : in  std_logic_vector(3 downto 0);
    S_AXI_ARPROT   : in  std_logic_vector(2 downto 0);
    S_AXI_ARVALID  : in  std_logic;
    S_AXI_ARREADY  : out std_logic;
    S_AXI_RREADY   : in  std_logic;
    S_AXI_RID      : out std_logic_vector(3 downto 0);
    S_AXI_RDATA    : out std_logic_vector(63 downto 0);
    S_AXI_RRESP    : out std_logic_vector(1 downto 0);
    S_AXI_RLAST    : out std_logic;
    S_AXI_RVALID   : out std_logic;
    --
    M0_AXI_AWID    : out std_logic_vector(3 downto 0);
    M0_AXI_AWADDR  : out std_logic_vector(31 downto 0);
    M0_AXI_AWLEN   : out std_logic_vector(3 downto 0);
    M0_AXI_AWSIZE  : out std_logic_vector(2 downto 0);
    M0_AXI_AWBURST : out std_logic_vector(1 downto 0);
    M0_AXI_AWLOCK  : out std_logic_vector(1 downto 0);
    M0_AXI_AWCACHE : out std_logic_vector(3 downto 0);
    M0_AXI_AWPROT  : out std_logic_vector(2 downto 0);
    M0_AXI_AWVALID : out std_logic;
    M0_AXI_AWREADY : in  std_logic;
    M0_AXI_WID     : out std_logic_vector(3 downto 0);
    M0_AXI_WDATA   : out std_logic_vector(63 downto 0);
    M0_AXI_WSTRB   : out std_logic_vector(7 downto 0);
    M0_AXI_WLAST   : out std_logic;
    M0_AXI_WVALID  : out std_logic;
    M0_AXI_WREADY  : in  std_logic;
    M0_AXI_BID     : in  std_logic_vector(3 downto 0);
    M0_AXI_BRESP   : in  std_logic_vector(1 downto 0);
    M0_AXI_BVALID  : in  std_logic;
    M0_AXI_BREADY  : out std_logic;
    M0_AXI_ARID    : out std_logic_vector(3 downto 0);
    M0_AXI_ARADDR  : out std_logic_vector(31 downto 0);
    M0_AXI_ARLEN   : out std_logic_vector(3 downto 0);
    M0_AXI_ARSIZE  : out std_logic_vector(2 downto 0);
    M0_AXI_ARBURST : out std_logic_vector(1 downto 0);
    M0_AXI_ARLOCK  : out std_logic_vector(1 downto 0);
    M0_AXI_ARCACHE : out std_logic_vector(3 downto 0);
    M0_AXI_ARPROT  : out std_logic_vector(2 downto 0);
    M0_AXI_ARVALID : out std_logic;
    M0_AXI_ARREADY : in  std_logic;
    M0_AXI_RREADY  : out std_logic;
    M0_AXI_RID     : in  std_logic_vector(3 downto 0);
    M0_AXI_RDATA   : in  std_logic_vector(63 downto 0);
    M0_AXI_RRESP   : in  std_logic_vector(1 downto 0);
    M0_AXI_RLAST   : in  std_logic;
    M0_AXI_RVALID  : in  std_logic;
    --
    M1_AXI_AWID    : out std_logic_vector(3 downto 0);
    M1_AXI_AWADDR  : out std_logic_vector(31 downto 0);
    M1_AXI_AWLEN   : out std_logic_vector(3 downto 0);
    M1_AXI_AWSIZE  : out std_logic_vector(2 downto 0);
    M1_AXI_AWBURST : out std_logic_vector(1 downto 0);
    M1_AXI_AWLOCK  : out std_logic_vector(1 downto 0);
    M1_AXI_AWCACHE : out std_logic_vector(3 downto 0);
    M1_AXI_AWPROT  : out std_logic_vector(2 downto 0);
    M1_AXI_AWVALID : out std_logic;
    M1_AXI_AWREADY : in  std_logic;
    M1_AXI_WID     : out std_logic_vector(3 downto 0);
    M1_AXI_WDATA   : out std_logic_vector(63 downto 0);
    M1_AXI_WSTRB   : out std_logic_vector(7 downto 0);
    M1_AXI_WLAST   : out std_logic;
    M1_AXI_WVALID  : out std_logic;
    M1_AXI_WREADY  : in  std_logic;
    M1_AXI_BID     : in  std_logic_vector(3 downto 0);
    M1_AXI_BRESP   : in  std_logic_vector(1 downto 0);
    M1_AXI_BVALID  : in  std_logic;
    M1_AXI_BREADY  : out std_logic;
    M1_AXI_ARID    : out std_logic_vector(3 downto 0);
    M1_AXI_ARADDR  : out std_logic_vector(31 downto 0);
    M1_AXI_ARLEN   : out std_logic_vector(3 downto 0);
    M1_AXI_ARSIZE  : out std_logic_vector(2 downto 0);
    M1_AXI_ARBURST : out std_logic_vector(1 downto 0);
    M1_AXI_ARLOCK  : out std_logic_vector(1 downto 0);
    M1_AXI_ARCACHE : out std_logic_vector(3 downto 0);
    M1_AXI_ARPROT  : out std_logic_vector(2 downto 0);
    M1_AXI_ARVALID : out std_logic;
    M1_AXI_ARREADY : in  std_logic;
    M1_AXI_RREADY  : out std_logic;
    M1_AXI_RID     : in  std_logic_vector(3 downto 0);
    M1_AXI_RDATA   : in  std_logic_vector(63 downto 0);
    M1_AXI_RRESP   : in  std_logic_vector(1 downto 0);
    M1_AXI_RLAST   : in  std_logic;
    M1_AXI_RVALID  : in  std_logic;
    --
    M2_AXI_AWID    : out std_logic_vector(3 downto 0);
    M2_AXI_AWADDR  : out std_logic_vector(31 downto 0);
    M2_AXI_AWLEN   : out std_logic_vector(3 downto 0);
    M2_AXI_AWSIZE  : out std_logic_vector(2 downto 0);
    M2_AXI_AWBURST : out std_logic_vector(1 downto 0);
    M2_AXI_AWLOCK  : out std_logic_vector(1 downto 0);
    M2_AXI_AWCACHE : out std_logic_vector(3 downto 0);
    M2_AXI_AWPROT  : out std_logic_vector(2 downto 0);
    M2_AXI_AWVALID : out std_logic;
    M2_AXI_AWREADY : in  std_logic;
    M2_AXI_WID     : out std_logic_vector(3 downto 0);
    M2_AXI_WDATA   : out std_logic_vector(63 downto 0);
    M2_AXI_WSTRB   : out std_logic_vector(7 downto 0);
    M2_AXI_WLAST   : out std_logic;
    M2_AXI_WVALID  : out std_logic;
    M2_AXI_WREADY  : in  std_logic;
    M2_AXI_BID     : in  std_logic_vector(3 downto 0);
    M2_AXI_BRESP   : in  std_logic_vector(1 downto 0);
    M2_AXI_BVALID  : in  std_logic;
    M2_AXI_BREADY  : out std_logic;
    M2_AXI_ARID    : out std_logic_vector(3 downto 0);
    M2_AXI_ARADDR  : out std_logic_vector(31 downto 0);
    M2_AXI_ARLEN   : out std_logic_vector(3 downto 0);
    M2_AXI_ARSIZE  : out std_logic_vector(2 downto 0);
    M2_AXI_ARBURST : out std_logic_vector(1 downto 0);
    M2_AXI_ARLOCK  : out std_logic_vector(1 downto 0);
    M2_AXI_ARCACHE : out std_logic_vector(3 downto 0);
    M2_AXI_ARPROT  : out std_logic_vector(2 downto 0);
    M2_AXI_ARVALID : out std_logic;
    M2_AXI_ARREADY : in  std_logic;
    M2_AXI_RREADY  : out std_logic;
    M2_AXI_RID     : in  std_logic_vector(3 downto 0);
    M2_AXI_RDATA   : in  std_logic_vector(63 downto 0);
    M2_AXI_RRESP   : in  std_logic_vector(1 downto 0);
    M2_AXI_RLAST   : in  std_logic;
    M2_AXI_RVALID  : in  std_logic;
    --
    M3_AXI_AWID    : out std_logic_vector(3 downto 0);
    M3_AXI_AWADDR  : out std_logic_vector(31 downto 0);
    M3_AXI_AWLEN   : out std_logic_vector(3 downto 0);
    M3_AXI_AWSIZE  : out std_logic_vector(2 downto 0);
    M3_AXI_AWBURST : out std_logic_vector(1 downto 0);
    M3_AXI_AWLOCK  : out std_logic_vector(1 downto 0);
    M3_AXI_AWCACHE : out std_logic_vector(3 downto 0);
    M3_AXI_AWPROT  : out std_logic_vector(2 downto 0);
    M3_AXI_AWVALID : out std_logic;
    M3_AXI_AWREADY : in  std_logic;
    M3_AXI_WID     : out std_logic_vector(3 downto 0);
    M3_AXI_WDATA   : out std_logic_vector(63 downto 0);
    M3_AXI_WSTRB   : out std_logic_vector(7 downto 0);
    M3_AXI_WLAST   : out std_logic;
    M3_AXI_WVALID  : out std_logic;
    M3_AXI_WREADY  : in  std_logic;
    M3_AXI_BID     : in  std_logic_vector(3 downto 0);
    M3_AXI_BRESP   : in  std_logic_vector(1 downto 0);
    M3_AXI_BVALID  : in  std_logic;
    M3_AXI_BREADY  : out std_logic;
    M3_AXI_ARID    : out std_logic_vector(3 downto 0);
    M3_AXI_ARADDR  : out std_logic_vector(31 downto 0);
    M3_AXI_ARLEN   : out std_logic_vector(3 downto 0);
    M3_AXI_ARSIZE  : out std_logic_vector(2 downto 0);
    M3_AXI_ARBURST : out std_logic_vector(1 downto 0);
    M3_AXI_ARLOCK  : out std_logic_vector(1 downto 0);
    M3_AXI_ARCACHE : out std_logic_vector(3 downto 0);
    M3_AXI_ARPROT  : out std_logic_vector(2 downto 0);
    M3_AXI_ARVALID : out std_logic;
    M3_AXI_ARREADY : in  std_logic;
    M3_AXI_RREADY  : out std_logic;
    M3_AXI_RID     : in  std_logic_vector(3 downto 0);
    M3_AXI_RDATA   : in  std_logic_vector(63 downto 0);
    M3_AXI_RRESP   : in  std_logic_vector(1 downto 0);
    M3_AXI_RLAST   : in  std_logic;
    M3_AXI_RVALID  : in  std_logic
  );
end entity axi_interconnect_ip;

architecture wrapper of axi_interconnect_ip is
  constant NR_MASTERS : natural := ADDR_MAP_TABLE'length;

  signal s_axi_master  : AxiMasterType;
  signal s_axi_slave   : AxiSlaveType;
  signal m_axi_masters : AxiMasterArray(NR_MASTERS - 1 downto 0);
  signal m_axi_slaves  : AxiSlaveArray(NR_MASTERS - 1 downto 0);
begin
  axi_slave_if_0: entity work.axi_slave_if
    port map (
      S_AXI_AWID    => S_AXI_AWID,
      S_AXI_AWADDR  => S_AXI_AWADDR,
      S_AXI_AWLEN   => S_AXI_AWLEN,
      S_AXI_AWSIZE  => S_AXI_AWSIZE,
      S_AXI_AWBURST => S_AXI_AWBURST,
      S_AXI_AWLOCK  => S_AXI_AWLOCK,
      S_AXI_AWCACHE => S_AXI_AWCACHE,
      S_AXI_AWPROT  => S_AXI_AWPROT,
      S_AXI_AWVALID => S_AXI_AWVALID,
      S_AXI_AWREADY => S_AXI_AWREADY,
      S_AXI_WID     => S_AXI_WID,
      S_AXI_WDATA   => S_AXI_WDATA,
      S_AXI_WSTRB   => S_AXI_WSTRB,
      S_AXI_WLAST   => S_AXI_WLAST,
      S_AXI_WVALID  => S_AXI_WVALID,
      S_AXI_WREADY  => S_AXI_WREADY,
      S_AXI_BID     => S_AXI_BID,
      S_AXI_BRESP   => S_AXI_BRESP,
      S_AXI_BVALID  => S_AXI_BVALID,
      S_AXI_BREADY  => S_AXI_BREADY,
      S_AXI_ARID    => S_AXI_ARID,
      S_AXI_ARADDR  => S_AXI_ARADDR,
      S_AXI_ARLEN   => S_AXI_ARLEN,
      S_AXI_ARSIZE  => S_AXI_ARSIZE,
      S_AXI_ARBURST => S_AXI_ARBURST,
      S_AXI_ARLOCK  => S_AXI_ARLOCK,
      S_AXI_ARCACHE => S_AXI_ARCACHE,
      S_AXI_ARPROT  => S_AXI_ARPROT,
      S_AXI_ARVALID => S_AXI_ARVALID,
      S_AXI_ARREADY => S_AXI_ARREADY,
      S_AXI_RREADY  => S_AXI_RREADY,
      S_AXI_RID     => S_AXI_RID,
      S_AXI_RDATA   => S_AXI_RDATA,
      S_AXI_RRESP   => S_AXI_RRESP,
      S_AXI_RLAST   => S_AXI_RLAST,
      S_AXI_RVALID  => S_AXI_RVALID,
      s_axi_master  => s_axi_master,
      s_axi_slave   => s_axi_slave);

  axi_interconnect_inst : entity work.axi_interconnect
    generic map (
      NR_MASTERS     => NR_MASTERS,
      ADDR_MAP_TABLE => ADDR_MAP_TABLE,
      ADDR_DEC_MSB   => ADDR_DEC_MSB,
      ADDR_DEC_LSB   => ADDR_DEC_LSB)
    port map (
      s_axi_aclk    => S_AXI_ACLK,
      s_axi_aresetn => S_AXI_ARESETN,
      s_axi_master  => s_axi_master,
      s_axi_slave   => s_axi_slave,
      m_axi_masters => m_axi_masters(NR_MASTERS - 1 downto 0),
      m_axi_slaves  => m_axi_slaves(NR_MASTERS -1 downto 0));

  gen_0 : if NR_MASTERS > 0 generate 
    axi_master_if_0: entity work.axi_master_if
      port map (
        M_AXI_AWID    => M0_AXI_AWID,
        M_AXI_AWADDR  => M0_AXI_AWADDR,
        M_AXI_AWLEN   => M0_AXI_AWLEN,
        M_AXI_AWSIZE  => M0_AXI_AWSIZE,
        M_AXI_AWBURST => M0_AXI_AWBURST,
        M_AXI_AWLOCK  => M0_AXI_AWLOCK,
        M_AXI_AWCACHE => M0_AXI_AWCACHE,
        M_AXI_AWPROT  => M0_AXI_AWPROT,
        M_AXI_AWVALID => M0_AXI_AWVALID,
        M_AXI_AWREADY => M0_AXI_AWREADY,
        M_AXI_WID     => M0_AXI_WID,
        M_AXI_WDATA   => M0_AXI_WDATA,
        M_AXI_WSTRB   => M0_AXI_WSTRB,
        M_AXI_WLAST   => M0_AXI_WLAST,
        M_AXI_WVALID  => M0_AXI_WVALID,
        M_AXI_WREADY  => M0_AXI_WREADY,
        M_AXI_BID     => M0_AXI_BID,
        M_AXI_BRESP   => M0_AXI_BRESP,
        M_AXI_BVALID  => M0_AXI_BVALID,
        M_AXI_BREADY  => M0_AXI_BREADY,
        M_AXI_ARID    => M0_AXI_ARID,
        M_AXI_ARADDR  => M0_AXI_ARADDR,
        M_AXI_ARLEN   => M0_AXI_ARLEN,
        M_AXI_ARSIZE  => M0_AXI_ARSIZE,
        M_AXI_ARBURST => M0_AXI_ARBURST,
        M_AXI_ARLOCK  => M0_AXI_ARLOCK,
        M_AXI_ARCACHE => M0_AXI_ARCACHE,
        M_AXI_ARPROT  => M0_AXI_ARPROT,
        M_AXI_ARVALID => M0_AXI_ARVALID,
        M_AXI_ARREADY => M0_AXI_ARREADY,
        M_AXI_RREADY  => M0_AXI_RREADY,
        M_AXI_RID     => M0_AXI_RID,
        M_AXI_RDATA   => M0_AXI_RDATA,
        M_AXI_RRESP   => M0_AXI_RRESP,
        M_AXI_RLAST   => M0_AXI_RLAST,
        M_AXI_RVALID  => M0_AXI_RVALID,
        m_axi_master  => m_axi_masters(0),
        m_axi_slave   => m_axi_slaves(0));
  end generate; 

  gen_1 : if NR_MASTERS > 1 generate 
    axi_master_if_1: entity work.axi_master_if
      port map (
        M_AXI_AWID    => M1_AXI_AWID,
        M_AXI_AWADDR  => M1_AXI_AWADDR,
        M_AXI_AWLEN   => M1_AXI_AWLEN,
        M_AXI_AWSIZE  => M1_AXI_AWSIZE,
        M_AXI_AWBURST => M1_AXI_AWBURST,
        M_AXI_AWLOCK  => M1_AXI_AWLOCK,
        M_AXI_AWCACHE => M1_AXI_AWCACHE,
        M_AXI_AWPROT  => M1_AXI_AWPROT,
        M_AXI_AWVALID => M1_AXI_AWVALID,
        M_AXI_AWREADY => M1_AXI_AWREADY,
        M_AXI_WID     => M1_AXI_WID,
        M_AXI_WDATA   => M1_AXI_WDATA,
        M_AXI_WSTRB   => M1_AXI_WSTRB,
        M_AXI_WLAST   => M1_AXI_WLAST,
        M_AXI_WVALID  => M1_AXI_WVALID,
        M_AXI_WREADY  => M1_AXI_WREADY,
        M_AXI_BID     => M1_AXI_BID,
        M_AXI_BRESP   => M1_AXI_BRESP,
        M_AXI_BVALID  => M1_AXI_BVALID,
        M_AXI_BREADY  => M1_AXI_BREADY,
        M_AXI_ARID    => M1_AXI_ARID,
        M_AXI_ARADDR  => M1_AXI_ARADDR,
        M_AXI_ARLEN   => M1_AXI_ARLEN,
        M_AXI_ARSIZE  => M1_AXI_ARSIZE,
        M_AXI_ARBURST => M1_AXI_ARBURST,
        M_AXI_ARLOCK  => M1_AXI_ARLOCK,
        M_AXI_ARCACHE => M1_AXI_ARCACHE,
        M_AXI_ARPROT  => M1_AXI_ARPROT,
        M_AXI_ARVALID => M1_AXI_ARVALID,
        M_AXI_ARREADY => M1_AXI_ARREADY,
        M_AXI_RREADY  => M1_AXI_RREADY,
        M_AXI_RID     => M1_AXI_RID,
        M_AXI_RDATA   => M1_AXI_RDATA,
        M_AXI_RRESP   => M1_AXI_RRESP,
        M_AXI_RLAST   => M1_AXI_RLAST,
        M_AXI_RVALID  => M1_AXI_RVALID,
        m_axi_master  => m_axi_masters(1),
        m_axi_slave   => m_axi_slaves(1));
  end generate; 

  gen_2 : if NR_MASTERS > 2 generate 
    axi_master_if_2: entity work.axi_master_if
      port map (
        M_AXI_AWID    => M2_AXI_AWID,
        M_AXI_AWADDR  => M2_AXI_AWADDR,
        M_AXI_AWLEN   => M2_AXI_AWLEN,
        M_AXI_AWSIZE  => M2_AXI_AWSIZE,
        M_AXI_AWBURST => M2_AXI_AWBURST,
        M_AXI_AWLOCK  => M2_AXI_AWLOCK,
        M_AXI_AWCACHE => M2_AXI_AWCACHE,
        M_AXI_AWPROT  => M2_AXI_AWPROT,
        M_AXI_AWVALID => M2_AXI_AWVALID,
        M_AXI_AWREADY => M2_AXI_AWREADY,
        M_AXI_WID     => M2_AXI_WID,
        M_AXI_WDATA   => M2_AXI_WDATA,
        M_AXI_WSTRB   => M2_AXI_WSTRB,
        M_AXI_WLAST   => M2_AXI_WLAST,
        M_AXI_WVALID  => M2_AXI_WVALID,
        M_AXI_WREADY  => M2_AXI_WREADY,
        M_AXI_BID     => M2_AXI_BID,
        M_AXI_BRESP   => M2_AXI_BRESP,
        M_AXI_BVALID  => M2_AXI_BVALID,
        M_AXI_BREADY  => M2_AXI_BREADY,
        M_AXI_ARID    => M2_AXI_ARID,
        M_AXI_ARADDR  => M2_AXI_ARADDR,
        M_AXI_ARLEN   => M2_AXI_ARLEN,
        M_AXI_ARSIZE  => M2_AXI_ARSIZE,
        M_AXI_ARBURST => M2_AXI_ARBURST,
        M_AXI_ARLOCK  => M2_AXI_ARLOCK,
        M_AXI_ARCACHE => M2_AXI_ARCACHE,
        M_AXI_ARPROT  => M2_AXI_ARPROT,
        M_AXI_ARVALID => M2_AXI_ARVALID,
        M_AXI_ARREADY => M2_AXI_ARREADY,
        M_AXI_RREADY  => M2_AXI_RREADY,
        M_AXI_RID     => M2_AXI_RID,
        M_AXI_RDATA   => M2_AXI_RDATA,
        M_AXI_RRESP   => M2_AXI_RRESP,
        M_AXI_RLAST   => M2_AXI_RLAST,
        M_AXI_RVALID  => M2_AXI_RVALID,
        m_axi_master  => m_axi_masters(2),
        m_axi_slave   => m_axi_slaves(2));
  end generate;

  gen_3 : if NR_MASTERS > 3 generate 
    axi_master_if_3: entity work.axi_master_if
      port map (
        M_AXI_AWID    => M3_AXI_AWID,
        M_AXI_AWADDR  => M3_AXI_AWADDR,
        M_AXI_AWLEN   => M3_AXI_AWLEN,
        M_AXI_AWSIZE  => M3_AXI_AWSIZE,
        M_AXI_AWBURST => M3_AXI_AWBURST,
        M_AXI_AWLOCK  => M3_AXI_AWLOCK,
        M_AXI_AWCACHE => M3_AXI_AWCACHE,
        M_AXI_AWPROT  => M3_AXI_AWPROT,
        M_AXI_AWVALID => M3_AXI_AWVALID,
        M_AXI_AWREADY => M3_AXI_AWREADY,
        M_AXI_WID     => M3_AXI_WID,
        M_AXI_WDATA   => M3_AXI_WDATA,
        M_AXI_WSTRB   => M3_AXI_WSTRB,
        M_AXI_WLAST   => M3_AXI_WLAST,
        M_AXI_WVALID  => M3_AXI_WVALID,
        M_AXI_WREADY  => M3_AXI_WREADY,
        M_AXI_BID     => M3_AXI_BID,
        M_AXI_BRESP   => M3_AXI_BRESP,
        M_AXI_BVALID  => M3_AXI_BVALID,
        M_AXI_BREADY  => M3_AXI_BREADY,
        M_AXI_ARID    => M3_AXI_ARID,
        M_AXI_ARADDR  => M3_AXI_ARADDR,
        M_AXI_ARLEN   => M3_AXI_ARLEN,
        M_AXI_ARSIZE  => M3_AXI_ARSIZE,
        M_AXI_ARBURST => M3_AXI_ARBURST,
        M_AXI_ARLOCK  => M3_AXI_ARLOCK,
        M_AXI_ARCACHE => M3_AXI_ARCACHE,
        M_AXI_ARPROT  => M3_AXI_ARPROT,
        M_AXI_ARVALID => M3_AXI_ARVALID,
        M_AXI_ARREADY => M3_AXI_ARREADY,
        M_AXI_RREADY  => M3_AXI_RREADY,
        M_AXI_RID     => M3_AXI_RID,
        M_AXI_RDATA   => M3_AXI_RDATA,
        M_AXI_RRESP   => M3_AXI_RRESP,
        M_AXI_RLAST   => M3_AXI_RLAST,
        M_AXI_RVALID  => M3_AXI_RVALID,
        m_axi_master  => m_axi_masters(3),
        m_axi_slave   => m_axi_slaves(3));
  end generate;
end architecture wrapper;
