-------------------------------------------------------
--! @file       axi_slave_if.vhd
--! @brief      wrapper for AXI custom types
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

entity axi_slave_if is
  port (
    S_AXI_AWID    : in  std_logic_vector(3 downto 0);
    S_AXI_AWADDR  : in  std_logic_vector(31 downto 0);
    S_AXI_AWLEN   : in  std_logic_vector(3 downto 0);
    S_AXI_AWSIZE  : in  std_logic_vector(2 downto 0);
    S_AXI_AWBURST : in  std_logic_vector(1 downto 0);
    S_AXI_AWLOCK  : in  std_logic_vector(1 downto 0);
    S_AXI_AWCACHE : in  std_logic_vector(3 downto 0);
    S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
    S_AXI_AWVALID : in  std_logic;
    S_AXI_AWREADY : out std_logic;
    S_AXI_WID     : in  std_logic_vector(3 downto 0);
    S_AXI_WDATA   : in  std_logic_vector(63 downto 0);
    S_AXI_WSTRB   : in  std_logic_vector(7 downto 0);
    S_AXI_WLAST   : in  std_logic;
    S_AXI_WVALID  : in  std_logic;
    S_AXI_WREADY  : out std_logic;
    S_AXI_BID     : out std_logic_vector(3 downto 0);
    S_AXI_BRESP   : out std_logic_vector(1 downto 0);
    S_AXI_BVALID  : out std_logic;
    S_AXI_BREADY  : in  std_logic;
    S_AXI_ARID    : in  std_logic_vector(3 downto 0);
    S_AXI_ARADDR  : in  std_logic_vector(31 downto 0);
    S_AXI_ARLEN   : in  std_logic_vector(3 downto 0);
    S_AXI_ARSIZE  : in  std_logic_vector(2 downto 0);
    S_AXI_ARBURST : in  std_logic_vector(1 downto 0);
    S_AXI_ARLOCK  : in  std_logic_vector(1 downto 0);
    S_AXI_ARCACHE : in  std_logic_vector(3 downto 0);
    S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
    S_AXI_ARVALID : in  std_logic;
    S_AXI_ARREADY : out std_logic;
    S_AXI_RREADY  : in  std_logic;
    S_AXI_RID     : out std_logic_vector(3 downto 0);
    S_AXI_RDATA   : out std_logic_vector(63 downto 0);
    S_AXI_RRESP   : out std_logic_vector(1 downto 0);
    S_AXI_RLAST   : out std_logic;
    S_AXI_RVALID  : out std_logic;

    s_axi_master : out AxiMasterType;
    s_axi_slave  : in  AxiSlaveType
    );
end entity axi_slave_if;

architecture wrapper of axi_slave_if is
begin
  s_axi_master.aw.id    <= S_AXI_AWID;
  s_axi_master.aw.addr  <= S_AXI_AWADDR;
  s_axi_master.aw.len   <= S_AXI_AWLEN;
  s_axi_master.aw.size  <= S_AXI_AWSIZE;
  s_axi_master.aw.burst <= S_AXI_AWBURST;
  s_axi_master.aw.lock  <= S_AXI_AWLOCK;
  s_axi_master.aw.cache <= S_AXI_AWCACHE;
  s_axi_master.aw.prot  <= S_AXI_AWPROT;
  s_axi_master.awvalid  <= S_AXI_AWVALID;
  s_axi_master.w.id     <= S_AXI_WID;
  s_axi_master.w.data   <= S_AXI_WDATA;
  s_axi_master.w.strb   <= S_AXI_WSTRB;
  s_axi_master.w.last   <= S_AXI_WLAST;
  s_axi_master.wvalid   <= S_AXI_WVALID;
  s_axi_master.bready   <= S_AXI_BREADY;
  s_axi_master.ar.id    <= S_AXI_ARID;
  s_axi_master.ar.addr  <= S_AXI_ARADDR;
  s_axi_master.ar.len   <= S_AXI_ARLEN;
  s_axi_master.ar.size  <= S_AXI_ARSIZE;
  s_axi_master.ar.burst <= S_AXI_ARBURST;
  s_axi_master.ar.lock  <= S_AXI_ARLOCK;
  s_axi_master.ar.cache <= S_AXI_ARCACHE;
  s_axi_master.ar.prot  <= S_AXI_ARPROT;
  s_axi_master.arvalid  <= S_AXI_ARVALID;
  s_axi_master.rready   <= S_AXI_RREADY;

  S_AXI_AWREADY <= s_axi_slave.awready;
  S_AXI_WREADY  <= s_axi_slave.wready;
  S_AXI_BID     <= s_axi_slave.b.id;
  S_AXI_BRESP   <= s_axi_slave.b.resp;
  S_AXI_BVALID  <= s_axi_slave.bvalid;
  S_AXI_ARREADY <= s_axi_slave.arready;
  S_AXI_RID     <= s_axi_slave.r.id;
  S_AXI_RDATA   <= s_axi_slave.r.data;
  S_AXI_RRESP   <= s_axi_slave.r.resp;
  S_AXI_RLAST   <= s_axi_slave.r.last;
  S_AXI_RVALID  <= s_axi_slave.rvalid;
end architecture wrapper;
