-------------------------------------------------------
--! @file       axi_sram_ip.vhd
--! @brief      instanciation of AXI SRAM modules 
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

use work.AxiPkg.all;
use work.AddrDecoderPkg.all;

entity axi_sram_ip is
  generic (
    ADDR_MAP : AddrMappingTable:=(0 => (start_addr => x"3000_0000", end_addr => x"3000_FFFF"))
  );
  port (
    S_AXI_ACLK     : in  std_logic;             --! AXI clock
    S_AXI_ARESETN  : in  std_logic;             --! Asynchronous reset, active low
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

    SRAM_ADDR      : out   std_logic_vector(15 downto 0);
    SRAM_DATA      : inout std_logic_vector(15 downto 0);
    SRAM_CE_N      : out   std_logic;
    SRAM_WE_N      : out   std_logic;
    SRAM_OE_N      : out   std_logic;
    SRAM_BE_N      : out   std_logic_vector(1 downto 0)
  );
end entity axi_sram_ip;

architecture struct of axi_sram_ip is
  constant AXI_ADDR_WIDTH      : positive := 32;
  constant AXI_DATA_WIDTH      : positive := 64;
  constant AXI_ID_WIDTH        : positive := 4;
	constant AXI_BURST_WIDTH     : integer  := 4;
  constant IPIF_ADDR_WIDTH     : integer  := 17;
  constant BURST_ADDR_WIDTH    : integer  := 8;


  signal BUS2IP_Resetn      : std_logic;
  signal IP2Bus_Data        : std_logic_vector(63 downto 0);
  signal IP2Bus_WrAck       : std_logic;
  signal IP2Bus_RdAck       : std_logic;
  signal IP2Bus_AddrAck     : std_logic;
  signal IP2Bus_Error       : std_logic;
  signal Bus2IP_Addr        : std_logic_vector(16 downto 0);
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
      AXI_BURST_WIDTH     => AXI_BURST_WIDTH,
	  IPIF_ADDR_MAP       => ADDR_MAP,
      IPIF_ADDR_WIDTH     => IPIF_ADDR_WIDTH,
      BURST_ADDR_WIDTH    => BURST_ADDR_WIDTH)
    port map (
      S_AXI_ACLK         => S_AXI_ACLK,
      S_AXI_ARESETN      => S_AXI_ARESETN,
      S_AXI_AWID         => S_AXI_AWID,
      S_AXI_AWADDR       => S_AXI_AWADDR,
      S_AXI_AWLEN        => S_AXI_AWLEN,
      S_AXI_AWSIZE       => S_AXI_AWSIZE,
      S_AXI_AWBURST      => S_AXI_AWBURST,
      S_AXI_AWLOCK       => S_AXI_AWLOCK,
      S_AXI_AWCACHE      => S_AXI_AWCACHE,
      S_AXI_AWPROT       => S_AXI_AWPROT,
      S_AXI_AWVALID      => S_AXI_AWVALID,
      S_AXI_AWREADY      => S_AXI_AWREADY,
      S_AXI_WID          => S_AXI_WID,
      S_AXI_WDATA        => S_AXI_WDATA,
      S_AXI_WSTRB        => S_AXI_WSTRB,
      S_AXI_WLAST        => S_AXI_WLAST,
      S_AXI_WVALID       => S_AXI_WVALID,
      S_AXI_WREADY       => S_AXI_WREADY,
      S_AXI_BID          => S_AXI_BID,
      S_AXI_BRESP        => S_AXI_BRESP,
      S_AXI_BVALID       => S_AXI_BVALID,
      S_AXI_BREADY       => S_AXI_BREADY,
      S_AXI_ARID         => S_AXI_ARID,
      S_AXI_ARADDR       => S_AXI_ARADDR,
      S_AXI_ARLEN        => S_AXI_ARLEN,
      S_AXI_ARSIZE       => S_AXI_ARSIZE,
      S_AXI_ARBURST      => S_AXI_ARBURST,
      S_AXI_ARLOCK       => S_AXI_ARLOCK,
      S_AXI_ARCACHE      => S_AXI_ARCACHE,
      S_AXI_ARPROT       => S_AXI_ARPROT,
      S_AXI_ARVALID      => S_AXI_ARVALID,
      S_AXI_ARREADY      => S_AXI_ARREADY,
      S_AXI_RREADY       => S_AXI_RREADY,
      S_AXI_RID          => S_AXI_RID,
      S_AXI_RDATA        => S_AXI_RDATA,
      S_AXI_RRESP        => S_AXI_RRESP,
      S_AXI_RLAST        => S_AXI_RLAST,
      S_AXI_RVALID       => S_AXI_RVALID,
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

   inst: entity work.SRAM_BUS2IP
     Port map (
       BUS2IP_Clk         => S_AXI_ACLK,
       BUS2IP_Resetn      => BUS2IP_Resetn,
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
       Type_of_xfer       => Type_of_xfer,
		   SRAM_Addr          => sram_addr,
		   SRAM_Data          => sram_data,
		   SRAM_CEn           => sram_ce_n,
		   SRAM_OEn           => sram_oe_n,
		   SRAM_WEn           => sram_we_n,
		   SRAM_LBn           => sram_be_n(0),
		   SRAM_UBn           => sram_be_n(1));
end architecture struct;
