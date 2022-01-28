-------------------------------------------------------
--! @file       axi_apb_IP.vhd
--! @brief      AXI3 to 8 APB peripheral Bridge
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
use ieee.numeric_std.all;

use work.AxiPkg.all;
use work.ApbPkg.all;
use work.AddrDecoderPkg.all;

--! @brief AXI3 to 8 APB peripheral Bridge
entity axi_apb_IP is
  generic (
    --! @brief APB address range configurations.
    --! @details Any address that is outside of the configuration range generates a `DECERR` on the
    --! AXI Interface port.
    ADDR_MAP            : AddrMappingTable := (
      0 => (start_addr => X"0000_1000", end_addr => X"0000_1FFF"),
      1 => (start_addr => X"0000_2000", end_addr => X"0000_2FFF"),
      2 => (start_addr => X"0000_6000", end_addr => X"0000_7FFF"),
      3 => (start_addr => X"0000_8000", end_addr => X"0000_8FFF"));
    --! Address MSB used by the decoder 
    MSB_DECODER         : natural := 15
  );
  port (
    S_AXI_ACLK     : in std_logic;             --! AXI clock
    S_AXI_ARESETN  : in std_logic;             --! Asynchronous reset, active low
    --! AXI Interface -> SLAVE
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
    --! APB interface
    --! To APB Slave 0
    M0_APB_PADDR    : out std_logic_vector(31 downto 0);
    M0_APB_PSEL     : out std_logic;
    M0_APB_PENABLE  : out std_logic;
    M0_APB_PWRITE   : out std_logic;
    M0_APB_PWDATA   : out std_logic_vector(31 downto 0);
    M0_APB_PSTRB    : out std_logic_vector(3 downto 0);
    M0_APB_PPROT    : out std_logic_vector(2 downto 0);
    M0_APB_PREADY   : in  std_logic;
    M0_APB_PRDATA   : in  std_logic_vector(31 downto 0);
    M0_APB_PSLVERR  : in  std_logic;
    --! To APB Slave 1
    M1_APB_PADDR    : out std_logic_vector(31 downto 0);
    M1_APB_PSEL     : out std_logic;
    M1_APB_PENABLE  : out std_logic;
    M1_APB_PWRITE   : out std_logic;
    M1_APB_PWDATA   : out std_logic_vector(31 downto 0);
    M1_APB_PSTRB    : out std_logic_vector(3 downto 0);
    M1_APB_PPROT    : out std_logic_vector(2 downto 0);
    M1_APB_PREADY   : in  std_logic;
    M1_APB_PRDATA   : in  std_logic_vector(31 downto 0);
    M1_APB_PSLVERR  : in  std_logic;
    --! To APB Slave 2
    M2_APB_PADDR    : out std_logic_vector(31 downto 0);
    M2_APB_PSEL     : out std_logic;
    M2_APB_PENABLE  : out std_logic;
    M2_APB_PWRITE   : out std_logic;
    M2_APB_PWDATA   : out std_logic_vector(31 downto 0);
    M2_APB_PSTRB    : out std_logic_vector(3 downto 0);
    M2_APB_PPROT    : out std_logic_vector(2 downto 0);
    M2_APB_PREADY   : in  std_logic;
    M2_APB_PRDATA   : in  std_logic_vector(31 downto 0);
    M2_APB_PSLVERR  : in  std_logic;
    --! To APB Slave 3
    M3_APB_PADDR    : out std_logic_vector(31 downto 0);
    M3_APB_PSEL     : out std_logic;
    M3_APB_PENABLE  : out std_logic;
    M3_APB_PWRITE   : out std_logic;
    M3_APB_PWDATA   : out std_logic_vector(31 downto 0);
    M3_APB_PSTRB    : out std_logic_vector(3 downto 0);
    M3_APB_PPROT    : out std_logic_vector(2 downto 0);
    M3_APB_PREADY   : in  std_logic;
    M3_APB_PRDATA   : in  std_logic_vector(31 downto 0);
    M3_APB_PSLVERR  : in  std_logic;
    --! To APB Slave 4
    M4_APB_PADDR    : out std_logic_vector(31 downto 0);
    M4_APB_PSEL     : out std_logic;
    M4_APB_PENABLE  : out std_logic;
    M4_APB_PWRITE   : out std_logic;
    M4_APB_PWDATA   : out std_logic_vector(31 downto 0);
    M4_APB_PSTRB    : out std_logic_vector(3 downto 0);
    M4_APB_PPROT    : out std_logic_vector(2 downto 0);
    M4_APB_PREADY   : in  std_logic;
    M4_APB_PRDATA   : in  std_logic_vector(31 downto 0);
    M4_APB_PSLVERR  : in  std_logic;
    --! To APB Slave 5
    M5_APB_PADDR    : out std_logic_vector(31 downto 0);
    M5_APB_PSEL     : out std_logic;
    M5_APB_PENABLE  : out std_logic;
    M5_APB_PWRITE   : out std_logic;
    M5_APB_PWDATA   : out std_logic_vector(31 downto 0);
    M5_APB_PSTRB    : out std_logic_vector(3 downto 0);
    M5_APB_PPROT    : out std_logic_vector(2 downto 0);
    M5_APB_PREADY   : in  std_logic;
    M5_APB_PRDATA   : in  std_logic_vector(31 downto 0);
    M5_APB_PSLVERR  : in  std_logic;
    --! To APB Slave 6
    M6_APB_PADDR    : out std_logic_vector(31 downto 0);
    M6_APB_PSEL     : out std_logic;
    M6_APB_PENABLE  : out std_logic;
    M6_APB_PWRITE   : out std_logic;
    M6_APB_PWDATA   : out std_logic_vector(31 downto 0);
    M6_APB_PSTRB    : out std_logic_vector(3 downto 0);
    M6_APB_PPROT    : out std_logic_vector(2 downto 0);
    M6_APB_PREADY   : in  std_logic;
    M6_APB_PRDATA   : in  std_logic_vector(31 downto 0);
    M6_APB_PSLVERR  : in  std_logic;
    --! To APB Slave 7
    M7_APB_PADDR    : out std_logic_vector(31 downto 0);
    M7_APB_PSEL     : out std_logic;
    M7_APB_PENABLE  : out std_logic;
    M7_APB_PWRITE   : out std_logic;
    M7_APB_PWDATA   : out std_logic_vector(31 downto 0);
    M7_APB_PSTRB    : out std_logic_vector(3 downto 0);
    M7_APB_PPROT    : out std_logic_vector(2 downto 0);
    M7_APB_PREADY   : in  std_logic;
    M7_APB_PRDATA   : in  std_logic_vector(31 downto 0);
    M7_APB_PSLVERR  : in  std_logic
  );
end axi_apb_IP;

architecture wrapper of axi_apb_IP is
  signal s_axi_master : AxiMasterType;
  signal s_axi_slave  : AxiSlaveType;

  signal m_apb_master : ApbMasterArray(7 downto 0);
  signal m_apb_slave  : ApbSlaveArray(7 downto 0);
begin
  ----------------------------------------------------------------------------
  --                           SIGNAL MAPPING                               --
  ----------------------------------------------------------------------------
  --! AXI Interface
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

  --! APB interfaces
  apb_0: entity work.apb_master_if
  port map(
    M_APB_PADDR   => M0_APB_PADDR,
    M_APB_PSEL    => M0_APB_PSEL,
    M_APB_PENABLE => M0_APB_PENABLE,
    M_APB_PWRITE  => M0_APB_PWRITE,
    M_APB_PWDATA  => M0_APB_PWDATA,
    M_APB_PSTRB   => M0_APB_PSTRB,
    M_APB_PPROT   => M0_APB_PPROT,
    M_APB_PREADY  => M0_APB_PREADY,
    M_APB_PRDATA  => M0_APB_PRDATA,
    M_APB_PSLVERR => M0_APB_PSLVERR,

    m_apb_master  => m_apb_master(0),
    m_apb_slave   => m_apb_slave(0)
  );

  apb_1: entity work.apb_master_if
  port map(
    M_APB_PADDR   => M1_APB_PADDR,
    M_APB_PSEL    => M1_APB_PSEL,
    M_APB_PENABLE => M1_APB_PENABLE,
    M_APB_PWRITE  => M1_APB_PWRITE,
    M_APB_PWDATA  => M1_APB_PWDATA,
    M_APB_PSTRB   => M1_APB_PSTRB,
    M_APB_PPROT   => M1_APB_PPROT,
    M_APB_PREADY  => M1_APB_PREADY,
    M_APB_PRDATA  => M1_APB_PRDATA,
    M_APB_PSLVERR => M1_APB_PSLVERR,

    m_apb_master  => m_apb_master(1),
    m_apb_slave   => m_apb_slave(1)
  );

  apb_2: entity work.apb_master_if
  port map(
    M_APB_PADDR   => M2_APB_PADDR,
    M_APB_PSEL    => M2_APB_PSEL,
    M_APB_PENABLE => M2_APB_PENABLE,
    M_APB_PWRITE  => M2_APB_PWRITE,
    M_APB_PWDATA  => M2_APB_PWDATA,
    M_APB_PSTRB   => M2_APB_PSTRB,
    M_APB_PPROT   => M2_APB_PPROT,
    M_APB_PREADY  => M2_APB_PREADY,
    M_APB_PRDATA  => M2_APB_PRDATA,
    M_APB_PSLVERR => M2_APB_PSLVERR,

    m_apb_master  => m_apb_master(2),
    m_apb_slave   => m_apb_slave(2)
  );

  apb_3: entity work.apb_master_if
  port map(
    M_APB_PADDR   => M3_APB_PADDR,
    M_APB_PSEL    => M3_APB_PSEL,
    M_APB_PENABLE => M3_APB_PENABLE,
    M_APB_PWRITE  => M3_APB_PWRITE,
    M_APB_PWDATA  => M3_APB_PWDATA,
    M_APB_PSTRB   => M3_APB_PSTRB,
    M_APB_PPROT   => M3_APB_PPROT,
    M_APB_PREADY  => M3_APB_PREADY,
    M_APB_PRDATA  => M3_APB_PRDATA,
    M_APB_PSLVERR => M3_APB_PSLVERR,

    m_apb_master  => m_apb_master(3),
    m_apb_slave   => m_apb_slave(3)
  );

  apb_4: entity work.apb_master_if
  port map(
    M_APB_PADDR   => M4_APB_PADDR,
    M_APB_PSEL    => M4_APB_PSEL,
    M_APB_PENABLE => M4_APB_PENABLE,
    M_APB_PWRITE  => M4_APB_PWRITE,
    M_APB_PWDATA  => M4_APB_PWDATA,
    M_APB_PSTRB   => M4_APB_PSTRB,
    M_APB_PPROT   => M4_APB_PPROT,
    M_APB_PREADY  => M4_APB_PREADY,
    M_APB_PRDATA  => M4_APB_PRDATA,
    M_APB_PSLVERR => M4_APB_PSLVERR,

    m_apb_master  => m_apb_master(4),
    m_apb_slave   => m_apb_slave(4)
  );

  apb_5: entity work.apb_master_if
  port map(
    M_APB_PADDR   => M5_APB_PADDR,
    M_APB_PSEL    => M5_APB_PSEL,
    M_APB_PENABLE => M5_APB_PENABLE,
    M_APB_PWRITE  => M5_APB_PWRITE,
    M_APB_PWDATA  => M5_APB_PWDATA,
    M_APB_PSTRB   => M5_APB_PSTRB,
    M_APB_PPROT   => M5_APB_PPROT,
    M_APB_PREADY  => M5_APB_PREADY,
    M_APB_PRDATA  => M5_APB_PRDATA,
    M_APB_PSLVERR => M5_APB_PSLVERR,

    m_apb_master  => m_apb_master(5),
    m_apb_slave   => m_apb_slave(5)
  );

  apb_6: entity work.apb_master_if
  port map(
    M_APB_PADDR   => M6_APB_PADDR,
    M_APB_PSEL    => M6_APB_PSEL,
    M_APB_PENABLE => M6_APB_PENABLE,
    M_APB_PWRITE  => M6_APB_PWRITE,
    M_APB_PWDATA  => M6_APB_PWDATA,
    M_APB_PSTRB   => M6_APB_PSTRB,
    M_APB_PPROT   => M6_APB_PPROT,
    M_APB_PREADY  => M6_APB_PREADY,
    M_APB_PRDATA  => M6_APB_PRDATA,
    M_APB_PSLVERR => M6_APB_PSLVERR,

    m_apb_master  => m_apb_master(6),
    m_apb_slave   => m_apb_slave(6)
  );

  apb_7: entity work.apb_master_if
  port map(
    M_APB_PADDR   => M7_APB_PADDR,
    M_APB_PSEL    => M7_APB_PSEL,
    M_APB_PENABLE => M7_APB_PENABLE,
    M_APB_PWRITE  => M7_APB_PWRITE,
    M_APB_PWDATA  => M7_APB_PWDATA,
    M_APB_PSTRB   => M7_APB_PSTRB,
    M_APB_PPROT   => M7_APB_PPROT,
    M_APB_PREADY  => M7_APB_PREADY,
    M_APB_PRDATA  => M7_APB_PRDATA,
    M_APB_PSLVERR => M7_APB_PSLVERR,

    m_apb_master  => m_apb_master(7),
    m_apb_slave   => m_apb_slave(7)
  );

  ----------------------------------------------------------------------------
  --                           BRIDGE LOGIC                                 --
  ----------------------------------------------------------------------------
  axi_apb_bridge_inst : entity work.axi_apb_bridge
  generic map (
    ADDR_MAP            => ADDR_MAP,
    APB_ADDR_DECODE_MSB => MSB_DECODER,
    APB_ADDR_DECODE_LSB => 0,
    NR_APB_MASTERS      => 8
  )
  port map(
    s_axi_aclk    => S_AXI_ACLK,
    s_axi_aresetn => S_AXI_ARESETN,

    s_axi_master  => s_axi_master,
    s_axi_slave   => s_axi_slave,

    m_apb_master  => m_apb_master,
    m_apb_slave   => m_apb_slave
  );
end wrapper;
