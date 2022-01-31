-------------------------------------------------------
--! @file       axi_master_if.vhd
--! @brief      AXI master wrapper to custom type
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

use work.AxiPkg.all;

--! @brief AXI Master interface wrapper
entity axi_master_if is
  port (
    M_AXI_AWID    : out std_logic_vector(3 downto 0);
    M_AXI_AWADDR  : out std_logic_vector(31 downto 0);
    M_AXI_AWLEN   : out std_logic_vector(3 downto 0);
    M_AXI_AWSIZE  : out std_logic_vector(2 downto 0);
    M_AXI_AWBURST : out std_logic_vector(1 downto 0);
    M_AXI_AWLOCK  : out std_logic_vector(1 downto 0);
    M_AXI_AWCACHE : out std_logic_vector(3 downto 0);
    M_AXI_AWPROT  : out std_logic_vector(2 downto 0);
    M_AXI_AWVALID : out std_logic;
    M_AXI_AWREADY : in  std_logic;
    M_AXI_WID     : out std_logic_vector(3 downto 0);
    M_AXI_WDATA   : out std_logic_vector(63 downto 0);
    M_AXI_WSTRB   : out std_logic_vector(7 downto 0);
    M_AXI_WLAST   : out std_logic;
    M_AXI_WVALID  : out std_logic;
    M_AXI_WREADY  : in  std_logic;
    M_AXI_BID     : in  std_logic_vector(3 downto 0);
    M_AXI_BRESP   : in  std_logic_vector(1 downto 0);
    M_AXI_BVALID  : in  std_logic;
    M_AXI_BREADY  : out std_logic;
    M_AXI_ARID    : out std_logic_vector(3 downto 0);
    M_AXI_ARADDR  : out std_logic_vector(31 downto 0);
    M_AXI_ARLEN   : out std_logic_vector(3 downto 0);
    M_AXI_ARSIZE  : out std_logic_vector(2 downto 0);
    M_AXI_ARBURST : out std_logic_vector(1 downto 0);
    M_AXI_ARLOCK  : out std_logic_vector(1 downto 0);
    M_AXI_ARCACHE : out std_logic_vector(3 downto 0);
    M_AXI_ARPROT  : out std_logic_vector(2 downto 0);
    M_AXI_ARVALID : out std_logic;
    M_AXI_ARREADY : in  std_logic;
    M_AXI_RREADY  : out std_logic;
    M_AXI_RID     : in  std_logic_vector(3 downto 0);
    M_AXI_RDATA   : in  std_logic_vector(63 downto 0);
    M_AXI_RRESP   : in  std_logic_vector(1 downto 0);
    M_AXI_RLAST   : in  std_logic;
    M_AXI_RVALID  : in  std_logic;

    m_axi_master : in  AxiMasterType;
    m_axi_slave  : out AxiSlaveType
  );
end entity axi_master_if;

architecture wrapper of axi_master_if is
begin
  M_AXI_AWID    <= m_axi_master.aw.id;
  M_AXI_AWADDR  <= m_axi_master.aw.addr;
  M_AXI_AWLEN   <= m_axi_master.aw.len;
  M_AXI_AWSIZE  <= m_axi_master.aw.size;
  M_AXI_AWBURST <= m_axi_master.aw.burst;
  M_AXI_AWLOCK  <= m_axi_master.aw.lock;
  M_AXI_AWCACHE <= m_axi_master.aw.cache;
  M_AXI_AWPROT  <= m_axi_master.aw.prot;
  M_AXI_AWVALID <= m_axi_master.awvalid;
  M_AXI_WID     <= m_axi_master.w.id;
  M_AXI_WDATA   <= m_axi_master.w.data;
  M_AXI_WSTRB   <= m_axi_master.w.strb;
  M_AXI_WLAST   <= m_axi_master.w.last;
  M_AXI_WVALID  <= m_axi_master.wvalid;
  M_AXI_BREADY  <= m_axi_master.bready;
  M_AXI_ARID    <= m_axi_master.ar.id;
  M_AXI_ARADDR  <= m_axi_master.ar.addr;
  M_AXI_ARLEN   <= m_axi_master.ar.len;
  M_AXI_ARSIZE  <= m_axi_master.ar.size;
  M_AXI_ARBURST <= m_axi_master.ar.burst;
  M_AXI_ARLOCK  <= m_axi_master.ar.lock;
  M_AXI_ARCACHE <= m_axi_master.ar.cache;
  M_AXI_ARPROT  <= m_axi_master.ar.prot;
  M_AXI_ARVALID <= m_axi_master.arvalid;
  M_AXI_RREADY  <= m_axi_master.rready;

  m_axi_slave.awready <= M_AXI_AWREADY;
  m_axi_slave.wready  <= M_AXI_WREADY;
  m_axi_slave.b.id     <= M_AXI_BID;
  m_axi_slave.b.resp   <= M_AXI_BRESP;
  m_axi_slave.bvalid  <= M_AXI_BVALID;
  m_axi_slave.arready <= M_AXI_ARREADY;
  m_axi_slave.r.id     <= M_AXI_RID;
  m_axi_slave.r.data   <= M_AXI_RDATA;
  m_axi_slave.r.resp   <= M_AXI_RRESP;
  m_axi_slave.r.last   <= M_AXI_RLAST;
  m_axi_slave.rvalid  <= M_AXI_RVALID;
end architecture wrapper;
