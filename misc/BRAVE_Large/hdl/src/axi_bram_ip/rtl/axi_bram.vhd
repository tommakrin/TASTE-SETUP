-------------------------------------------------------
--! @file       axi_bram.vhd
--! @brief      wrapper from aXI to custom bus
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
use work.AddrDecoderPkg.all;

entity axi_bram is
  generic (
  	ADDR_MAP : AddrMappingTable:=(0 => (start_addr => x"1000_0000", end_addr => x"1000_FFFF"))
  );
   port (
    s_axi_aclk    : in std_logic;
    s_axi_aresetn : in std_logic;

    s_axi_master : in  AxiMasterType;
    s_axi_slave  : out AxiSlaveType
  );
end entity axi_bram;

architecture struct of axi_bram is
  constant AXI_ADDR_WIDTH      : positive := 32;
  constant AXI_DATA_WIDTH      : positive := 64;
  constant AXI_ID_WIDTH        : positive := 4;

  signal BUS2IP_Resetn      : std_logic;
  signal IP2Bus_Data        : std_logic_vector(63 downto 0);
  signal IP2Bus_WrAck       : std_logic;
  signal IP2Bus_RdAck       : std_logic;
  signal IP2Bus_AddrAck     : std_logic;
  signal IP2Bus_Error       : std_logic;
  signal Bus2IP_Addr        : std_logic_vector(11 downto 0);
  signal Bus2IP_Data        : std_logic_vector(63 downto 0);
  signal Bus2IP_RNW         : std_logic;
  signal Bus2IP_BE          : std_logic_vector(7 downto 0);
  signal Bus2IP_Burst       : std_logic;
  signal Bus2IP_BurstLength : std_logic_vector(3 downto 0);
  signal Bus2IP_WrReq       : std_logic;
  signal Bus2IP_RdReq       : std_logic;
  signal Bus2IP_RdCE        : std_logic;
  signal Bus2IP_WrCE        : std_logic;
  signal Bus2IP_CS          : std_logic;
  signal Type_of_xfer       : std_logic;
begin
  AXI_Slave_1: entity work.AXI_Slave
    generic map (
      AXI_ADDR_WIDTH      => AXI_ADDR_WIDTH,
      AXI_DATA_WIDTH      => AXI_DATA_WIDTH,
      AXI_ID_WIDTH        => AXI_ID_WIDTH,
	    IPIF_ADDR_MAP       => ADDR_MAP,
      IPIF_ADDR_WIDTH     => 12, 
      BURST_ADDR_WIDTH    => 8)
    port map (
      S_AXI_ACLK         => s_axi_aclk,
      S_AXI_ARESETN      => s_axi_aresetn,
      S_AXI_AWID         => s_axi_master.aw.id,
      S_AXI_AWADDR       => s_axi_master.aw.addr,
      S_AXI_AWLEN        => s_axi_master.aw.len,
      S_AXI_AWSIZE       => s_axi_master.aw.size,
      S_AXI_AWBURST      => s_axi_master.aw.burst,
      S_AXI_AWLOCK       => s_axi_master.aw.lock,
      S_AXI_AWCACHE      => s_axi_master.aw.cache,
      S_AXI_AWPROT       => s_axi_master.aw.prot,
      S_AXI_AWVALID      => s_axi_master.awvalid,
      S_AXI_AWREADY      => s_axi_slave.awready,
      S_AXI_WID          => s_axi_master.w.id,
      S_AXI_WDATA        => s_axi_master.w.data,
      S_AXI_WSTRB        => s_axi_master.w.strb,
      S_AXI_WLAST        => s_axi_master.w.last,
      S_AXI_WVALID       => s_axi_master.wvalid,
      S_AXI_WREADY       => s_axi_slave.wready,
      S_AXI_BID          => s_axi_slave.b.id,
      S_AXI_BRESP        => s_axi_slave.b.resp,
      S_AXI_BVALID       => s_axi_slave.bvalid,
      S_AXI_BREADY       => s_axi_master.bready,
      S_AXI_ARID         => s_axi_master.ar.id,
      S_AXI_ARADDR       => s_axi_master.ar.addr,
      S_AXI_ARLEN        => s_axi_master.ar.len,
      S_AXI_ARSIZE       => s_axi_master.ar.size,
      S_AXI_ARBURST      => s_axi_master.ar.burst,
      S_AXI_ARLOCK       => s_axi_master.ar.lock,
      S_AXI_ARCACHE      => s_axi_master.ar.cache,
      S_AXI_ARPROT       => s_axi_master.ar.prot,
      S_AXI_ARVALID      => s_axi_master.arvalid,
      S_AXI_ARREADY      => s_axi_slave.arready,
      S_AXI_RID          => s_axi_slave.r.id,
      S_AXI_RDATA        => s_axi_slave.r.data,
      S_AXI_RRESP        => s_axi_slave.r.resp,
      S_AXI_RLAST        => s_axi_slave.r.last,
      S_AXI_RVALID       => s_axi_slave.rvalid,
      S_AXI_RREADY       => s_axi_master.rready,
      Bus2IP_Resetn      => Bus2IP_Resetn,
      IP2Bus_Data        => IP2Bus_Data,
      IP2Bus_WrAck       => IP2Bus_WrAck,
      IP2Bus_RdAck       => IP2Bus_RdAck,
      IP2Bus_AddrAck     => IP2Bus_AddrAck,
      IP2Bus_Error       => IP2Bus_Error,
      Bus2IP_Addr        => Bus2IP_Addr,
      Bus2IP_Data        => Bus2IP_Data,
      Bus2IP_RNW         => Bus2IP_RNW,
      Bus2IP_BE          => Bus2IP_BE,
      Bus2IP_Burst       => Bus2IP_Burst,
      Bus2IP_BurstLength => Bus2IP_BurstLength,
      Bus2IP_WrReq       => Bus2IP_WrReq,
      Bus2IP_RdReq       => Bus2IP_RdReq,
      Bus2IP_CS          => Bus2IP_CS,
      Bus2IP_RdCE        => Bus2IP_RdCE,
      Bus2IP_WrCE        => Bus2IP_WrCE,
      Type_of_xfer       => Type_of_xfer);

   bram_inst: entity work.BRAM_BUS2IP
     Port map (
          BUSA2IP_Clk         => s_axi_aclk,
          BUSA2IP_Resetn      => BUS2IP_Resetn,
          IP2BusA_Data        => IP2Bus_Data,
          IP2BusA_WrAck       => IP2Bus_WrAck,
          IP2BusA_RdAck       => IP2Bus_RdAck,
          IP2BusA_AddrAck     => IP2Bus_AddrAck,
          IP2BusA_Error       => IP2Bus_Error,
          BusA2IP_Addr        => Bus2IP_Addr,
          BusA2IP_Data        => Bus2IP_Data,
          BusA2IP_RNW         => Bus2IP_RNW,
          BusA2IP_BE          => Bus2IP_BE,
          BusA2IP_Burst       => Bus2IP_Burst,
          BusA2IP_BurstLength => Bus2IP_BurstLength,
          BusA2IP_WrReq       => Bus2IP_WrReq,
          BusA2IP_RdReq       => Bus2IP_RdReq,
          BusA2IP_CS          => Bus2IP_CS,
          Type_of_xfer_A      => Type_of_xfer,

          BUSB2IP_Clk         => s_axi_aclk,
          BUSB2IP_Resetn      => s_axi_aresetn,
          IP2BusB_Data        => open,
          IP2BusB_WrAck       => open,
          IP2BusB_RdAck       => open,
          IP2BusB_AddrAck     => open,
          IP2BusB_Error       => open,
          BusB2IP_Addr        => (others => '0'),
          BusB2IP_Data        => (others => '0'),
          BusB2IP_RNW         => '0',
          BusB2IP_BE          => (others => '0'),
          BusB2IP_Burst       => '0',
          BusB2IP_BurstLength => (others => '0'),
          BusB2IP_WrReq       => '0',
          BusB2IP_RdReq       => '0',
          BusB2IP_CS          => '0',
          Type_of_xfer_B      => '0');
end architecture struct;

