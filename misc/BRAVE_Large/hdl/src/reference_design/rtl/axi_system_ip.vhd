-------------------------------------------------------
--! @file       axi_system_ip.vhd
--! @brief      Implementation of AXI infrastructure with bridges and IPs
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

use work.AddrDecoderPkg.all;

entity axi_system_ip is
  port (
    AXI_ACLK      : in  std_logic;
    AXI_ARESETN   : in  std_logic;
    --
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
    -- 
    APB_CLK       : in  std_logic; 
    APB_ARESETN   : in  std_logic; 
    --
    AHB_CLK       : in  std_logic; 
    AHB_ARESETN   : in  std_logic; 
    --
    UART_TXD_O    : out std_logic;
    UART_RXD_I    : in  std_logic;
    --
    LEDS_N_O      : out std_logic_vector(7 downto 0);
    DBGDONE       : out std_logic;
    DONEBLDBG     : out std_logic;
    STARTDBG      : OUT STD_LOGIC;
    --
    SRAM_ADDR     : out std_logic_vector(15 downto 0);      
    SRAM_DATA     : inout std_logic_vector(15 downto 0);
    SRAM_CE_N     : out std_logic;
    SRAM_WE_N     : out std_logic;
    SRAM_OE_N     : out std_logic;
    SRAM_BE_N     : out std_logic_vector(1 downto 0);
    --
    IRQ_O         : out std_logic
  );
end entity axi_system_ip;

architecture rtl of axi_system_ip is
  ----------------------------------------------------------------
  --                        AXI MAPPING                         --
  ----------------------------------------------------------------
  constant AXI_MSB_DECODER : natural := 31; 
  constant AHB_AXI_NR      : natural := 3;
  constant SRAM_AXI_NR     : natural := 2;
  constant BRAM_AXI_NR     : natural := 1;
  constant APB_AXI_NR      : natural := 0;

  constant AXI_ADDR_MAP   : AddrMappingTable(3 downto 0) := (
    AHB_AXI_NR  => (start_addr => x"3000_0000", end_addr => x"3FFF_FFFF"), -- AHB SPACE
    SRAM_AXI_NR => (start_addr => x"2001_0000", end_addr => x"2001_FFFF"), -- SRAM
    BRAM_AXI_NR => (start_addr => x"2000_0000", end_addr => x"2000_FFFF"), -- BRAM
    APB_AXI_NR  => (start_addr => x"0001_0000", end_addr => x"0001_FFFF")  -- APB SPACE
  );

  constant AHB_MSB_DECODER : natural := 19; 
  constant SLV_0_AHB_NR    : natural := 0; 
  constant SLV_1_AHB_NR    : natural := 1;
  constant AHB_ADDR_MAP   : AddrMappingTable(1 downto 0) := (
    SLV_1_AHB_NR => (start_addr => x"0002_0000", end_addr => x"0002_00FF"), -- AHB REG 1
    SLV_0_AHB_NR => (start_addr => x"0001_0000", end_addr => x"0001_00FF")  -- AHB REG 0
  );

  constant APB_MSB_DECODER : natural := 15; 
  constant UART_APB_NR     : natural := 0;
  constant SLV_1_APB_NR    : natural := 1;
  constant SLV_2_APB_NR    : natural := 2;
  constant APB_ADDR_MAP   : AddrMappingTable(2 downto 0) := (
    SLV_2_APB_NR => (start_addr => x"0000_6000", end_addr => x"0000_7FFF"), -- TASTE REG
    SLV_1_APB_NR => (start_addr => x"0000_2000", end_addr => x"0000_2FFF"), -- APB REG
    UART_APB_NR  => (start_addr => x"0000_1000", end_addr => x"0000_1020")  -- UART
  );
    
  -- AXI -> SRAM
  signal sram_axi_awid    : std_logic_vector(3 downto 0);
  signal sram_axi_awaddr  : std_logic_vector(31 downto 0);
  signal sram_axi_awlen   : std_logic_vector(3 downto 0);
  signal sram_axi_awsize  : std_logic_vector(2 downto 0);
  signal sram_axi_awburst : std_logic_vector(1 downto 0);
  signal sram_axi_awlock  : std_logic_vector(1 downto 0);
  signal sram_axi_awcache : std_logic_vector(3 downto 0);
  signal sram_axi_awprot  : std_logic_vector(2 downto 0);
  signal sram_axi_awvalid : std_logic;
  signal sram_axi_awready : std_logic;
  signal sram_axi_wid     : std_logic_vector(3 downto 0);
  signal sram_axi_wdata   : std_logic_vector(63 downto 0);
  signal sram_axi_wstrb   : std_logic_vector(7 downto 0);
  signal sram_axi_wlast   : std_logic;
  signal sram_axi_wvalid  : std_logic;
  signal sram_axi_wready  : std_logic;
  signal sram_axi_bid     : std_logic_vector(3 downto 0);
  signal sram_axi_bresp   : std_logic_vector(1 downto 0);
  signal sram_axi_bvalid  : std_logic;
  signal sram_axi_bready  : std_logic;
  signal sram_axi_arid    : std_logic_vector(3 downto 0);
  signal sram_axi_araddr  : std_logic_vector(31 downto 0);
  signal sram_axi_arlen   : std_logic_vector(3 downto 0);
  signal sram_axi_arsize  : std_logic_vector(2 downto 0);
  signal sram_axi_arburst : std_logic_vector(1 downto 0);
  signal sram_axi_arlock  : std_logic_vector(1 downto 0);
  signal sram_axi_arcache : std_logic_vector(3 downto 0);
  signal sram_axi_arprot  : std_logic_vector(2 downto 0);
  signal sram_axi_arvalid : std_logic;
  signal sram_axi_arready : std_logic;
  signal sram_axi_rready  : std_logic;
  signal sram_axi_rid     : std_logic_vector(3 downto 0);
  signal sram_axi_rdata   : std_logic_vector(63 downto 0);
  signal sram_axi_rresp   : std_logic_vector(1 downto 0);
  signal sram_axi_rlast   : std_logic;
  signal sram_axi_rvalid  : std_logic;
  -- AXI -> BRAM
  signal bram_axi_awid    : std_logic_vector(3 downto 0);
  signal bram_axi_awaddr  : std_logic_vector(31 downto 0);
  signal bram_axi_awlen   : std_logic_vector(3 downto 0);
  signal bram_axi_awsize  : std_logic_vector(2 downto 0);
  signal bram_axi_awburst : std_logic_vector(1 downto 0);
  signal bram_axi_awlock  : std_logic_vector(1 downto 0);
  signal bram_axi_awcache : std_logic_vector(3 downto 0);
  signal bram_axi_awprot  : std_logic_vector(2 downto 0);
  signal bram_axi_awvalid : std_logic;
  signal bram_axi_awready : std_logic;
  signal bram_axi_wid     : std_logic_vector(3 downto 0);
  signal bram_axi_wdata   : std_logic_vector(63 downto 0);
  signal bram_axi_wstrb   : std_logic_vector(7 downto 0);
  signal bram_axi_wlast   : std_logic;
  signal bram_axi_wvalid  : std_logic;
  signal bram_axi_wready  : std_logic;
  signal bram_axi_bid     : std_logic_vector(3 downto 0);
  signal bram_axi_bresp   : std_logic_vector(1 downto 0);
  signal bram_axi_bvalid  : std_logic;
  signal bram_axi_bready  : std_logic;
  signal bram_axi_arid    : std_logic_vector(3 downto 0);
  signal bram_axi_araddr  : std_logic_vector(31 downto 0);
  signal bram_axi_arlen   : std_logic_vector(3 downto 0);
  signal bram_axi_arsize  : std_logic_vector(2 downto 0);
  signal bram_axi_arburst : std_logic_vector(1 downto 0);
  signal bram_axi_arlock  : std_logic_vector(1 downto 0);
  signal bram_axi_arcache : std_logic_vector(3 downto 0);
  signal bram_axi_arprot  : std_logic_vector(2 downto 0);
  signal bram_axi_arvalid : std_logic;
  signal bram_axi_arready : std_logic;
  signal bram_axi_rready  : std_logic;
  signal bram_axi_rid     : std_logic_vector(3 downto 0);
  signal bram_axi_rdata   : std_logic_vector(63 downto 0);
  signal bram_axi_rresp   : std_logic_vector(1 downto 0);
  signal bram_axi_rlast   : std_logic;
  signal bram_axi_rvalid  : std_logic;
  -- AXI -> APB
  signal apb_axi_awid    : std_logic_vector(3 downto 0);
  signal apb_axi_awaddr  : std_logic_vector(31 downto 0);
  signal apb_axi_awlen   : std_logic_vector(3 downto 0);
  signal apb_axi_awsize  : std_logic_vector(2 downto 0);
  signal apb_axi_awburst : std_logic_vector(1 downto 0);
  signal apb_axi_awlock  : std_logic_vector(1 downto 0);
  signal apb_axi_awcache : std_logic_vector(3 downto 0);
  signal apb_axi_awprot  : std_logic_vector(2 downto 0);
  signal apb_axi_awvalid : std_logic;
  signal apb_axi_awready : std_logic;
  signal apb_axi_wid     : std_logic_vector(3 downto 0);
  signal apb_axi_wdata   : std_logic_vector(63 downto 0);
  signal apb_axi_wstrb   : std_logic_vector(7 downto 0);
  signal apb_axi_wlast   : std_logic;
  signal apb_axi_wvalid  : std_logic;
  signal apb_axi_wready  : std_logic;
  signal apb_axi_bid     : std_logic_vector(3 downto 0);
  signal apb_axi_bresp   : std_logic_vector(1 downto 0);
  signal apb_axi_bvalid  : std_logic;
  signal apb_axi_bready  : std_logic;
  signal apb_axi_arid    : std_logic_vector(3 downto 0);
  signal apb_axi_araddr  : std_logic_vector(31 downto 0);
  signal apb_axi_arlen   : std_logic_vector(3 downto 0);
  signal apb_axi_arsize  : std_logic_vector(2 downto 0);
  signal apb_axi_arburst : std_logic_vector(1 downto 0);
  signal apb_axi_arlock  : std_logic_vector(1 downto 0);
  signal apb_axi_arcache : std_logic_vector(3 downto 0);
  signal apb_axi_arprot  : std_logic_vector(2 downto 0);
  signal apb_axi_arvalid : std_logic;
  signal apb_axi_arready : std_logic;
  signal apb_axi_rready  : std_logic;
  signal apb_axi_rid     : std_logic_vector(3 downto 0);
  signal apb_axi_rdata   : std_logic_vector(63 downto 0);
  signal apb_axi_rresp   : std_logic_vector(1 downto 0);
  signal apb_axi_rlast   : std_logic;
  signal apb_axi_rvalid  : std_logic;
  signal slow_apb_axi_awid    : std_logic_vector(3 downto 0);
  signal slow_apb_axi_awaddr  : std_logic_vector(31 downto 0);
  signal slow_apb_axi_awlen   : std_logic_vector(3 downto 0);
  signal slow_apb_axi_awsize  : std_logic_vector(2 downto 0);
  signal slow_apb_axi_awburst : std_logic_vector(1 downto 0);
  signal slow_apb_axi_awlock  : std_logic_vector(1 downto 0);
  signal slow_apb_axi_awcache : std_logic_vector(3 downto 0);
  signal slow_apb_axi_awprot  : std_logic_vector(2 downto 0);
  signal slow_apb_axi_awvalid : std_logic;
  signal slow_apb_axi_awready : std_logic;
  signal slow_apb_axi_wid     : std_logic_vector(3 downto 0);
  signal slow_apb_axi_wdata   : std_logic_vector(63 downto 0);
  signal slow_apb_axi_wstrb   : std_logic_vector(7 downto 0);
  signal slow_apb_axi_wlast   : std_logic;
  signal slow_apb_axi_wvalid  : std_logic;
  signal slow_apb_axi_wready  : std_logic;
  signal slow_apb_axi_bid     : std_logic_vector(3 downto 0);
  signal slow_apb_axi_bresp   : std_logic_vector(1 downto 0);
  signal slow_apb_axi_bvalid  : std_logic;
  signal slow_apb_axi_bready  : std_logic;
  signal slow_apb_axi_arid    : std_logic_vector(3 downto 0);
  signal slow_apb_axi_araddr  : std_logic_vector(31 downto 0);
  signal slow_apb_axi_arlen   : std_logic_vector(3 downto 0);
  signal slow_apb_axi_arsize  : std_logic_vector(2 downto 0);
  signal slow_apb_axi_arburst : std_logic_vector(1 downto 0);
  signal slow_apb_axi_arlock  : std_logic_vector(1 downto 0);
  signal slow_apb_axi_arcache : std_logic_vector(3 downto 0);
  signal slow_apb_axi_arprot  : std_logic_vector(2 downto 0);
  signal slow_apb_axi_arvalid : std_logic;
  signal slow_apb_axi_arready : std_logic;
  signal slow_apb_axi_rready  : std_logic;
  signal slow_apb_axi_rid     : std_logic_vector(3 downto 0);
  signal slow_apb_axi_rdata   : std_logic_vector(63 downto 0);
  signal slow_apb_axi_rresp   : std_logic_vector(1 downto 0);
  signal slow_apb_axi_rlast   : std_logic;
  signal slow_apb_axi_rvalid  : std_logic;
  -- AXI -> AHB
  signal ahb_axi_awid    : std_logic_vector(3 downto 0);
  signal ahb_axi_awaddr  : std_logic_vector(31 downto 0);
  signal ahb_axi_awlen   : std_logic_vector(3 downto 0);
  signal ahb_axi_awsize  : std_logic_vector(2 downto 0);
  signal ahb_axi_awburst : std_logic_vector(1 downto 0);
  signal ahb_axi_awlock  : std_logic_vector(1 downto 0);
  signal ahb_axi_awcache : std_logic_vector(3 downto 0);
  signal ahb_axi_awprot  : std_logic_vector(2 downto 0);
  signal ahb_axi_awvalid : std_logic;
  signal ahb_axi_awready : std_logic;
  signal ahb_axi_wid     : std_logic_vector(3 downto 0);
  signal ahb_axi_wdata   : std_logic_vector(63 downto 0);
  signal ahb_axi_wstrb   : std_logic_vector(7 downto 0);
  signal ahb_axi_wlast   : std_logic;
  signal ahb_axi_wvalid  : std_logic;
  signal ahb_axi_wready  : std_logic;
  signal ahb_axi_bid     : std_logic_vector(3 downto 0);
  signal ahb_axi_bresp   : std_logic_vector(1 downto 0);
  signal ahb_axi_bvalid  : std_logic;
  signal ahb_axi_bready  : std_logic;
  signal ahb_axi_arid    : std_logic_vector(3 downto 0);
  signal ahb_axi_araddr  : std_logic_vector(31 downto 0);
  signal ahb_axi_arlen   : std_logic_vector(3 downto 0);
  signal ahb_axi_arsize  : std_logic_vector(2 downto 0);
  signal ahb_axi_arburst : std_logic_vector(1 downto 0);
  signal ahb_axi_arlock  : std_logic_vector(1 downto 0);
  signal ahb_axi_arcache : std_logic_vector(3 downto 0);
  signal ahb_axi_arprot  : std_logic_vector(2 downto 0);
  signal ahb_axi_arvalid : std_logic;
  signal ahb_axi_arready : std_logic;
  signal ahb_axi_rready  : std_logic;
  signal ahb_axi_rid     : std_logic_vector(3 downto 0);
  signal ahb_axi_rdata   : std_logic_vector(63 downto 0);
  signal ahb_axi_rresp   : std_logic_vector(1 downto 0);
  signal ahb_axi_rlast   : std_logic;
  signal ahb_axi_rvalid  : std_logic;

  ----------------------------------------------------------------
  --                        APB MAPPING                         --
  ----------------------------------------------------------------
  -- UART
  signal uart_apb_paddr   : std_logic_vector(31 downto 0);
  signal uart_apb_psel    : std_logic;
  signal uart_apb_penable : std_logic;
  signal uart_apb_pwrite  : std_logic;
  signal uart_apb_pwdata  : std_logic_vector(31 downto 0);
  signal uart_apb_pstrb   : std_logic_vector(3 downto 0);
  signal uart_apb_pprot   : std_logic_vector(2 downto 0);
  signal uart_apb_pready  : std_logic;
  signal uart_apb_prdata  : std_logic_vector(31 downto 0);
  signal uart_apb_pslverr : std_logic;
  -- APB SLAVE 1
  signal apb_slv_1_paddr   : std_logic_vector(31 downto 0);
  signal apb_slv_1_psel    : std_logic;
  signal apb_slv_1_penable : std_logic;
  signal apb_slv_1_pwrite  : std_logic;
  signal apb_slv_1_pwdata  : std_logic_vector(31 downto 0);
  signal apb_slv_1_pstrb   : std_logic_vector(3 downto 0);
  signal apb_slv_1_pprot   : std_logic_vector(2 downto 0);
  signal apb_slv_1_pready  : std_logic;
  signal apb_slv_1_prdata  : std_logic_vector(31 downto 0);
  signal apb_slv_1_pslverr : std_logic;
  -- APB SLAVE 2 (TASTE PERIPHERAL)
  signal apb_slv_2_paddr   : std_logic_vector(31 downto 0);
  signal apb_slv_2_psel    : std_logic;
  signal apb_slv_2_penable : std_logic;
  signal apb_slv_2_pwrite  : std_logic;
  signal apb_slv_2_pwdata  : std_logic_vector(31 downto 0);
  signal apb_slv_2_pstrb   : std_logic_vector(3 downto 0);
  signal apb_slv_2_pprot   : std_logic_vector(2 downto 0);
  signal apb_slv_2_pready  : std_logic;
  signal apb_slv_2_prdata  : std_logic_vector(31 downto 0);
  signal apb_slv_2_pslverr : std_logic;

  signal status_leds       : std_logic_vector(7 downto 0);
  signal status_timer      : std_logic_vector(2 downto 0);
  signal status_taste      : std_logic;
  ----------------------------------------------------------------
  --                        AHB MAPPING                         --
  ----------------------------------------------------------------
  -- AHB SLAVE 0
  signal ahb_slv_0_hresetn    : std_logic;
  signal ahb_slv_0_haddr      : std_logic_vector(31 downto 0);
  signal ahb_slv_0_hwrite     : std_logic;
  signal ahb_slv_0_hsize      : std_logic_vector(2 downto 0);
  signal ahb_slv_0_hburst     : std_logic_vector(2 downto 0);
  signal ahb_slv_0_hprot      : std_logic_vector(6 downto 0);
  signal ahb_slv_0_hnonsec    : std_logic;
  signal ahb_slv_0_htrans     : std_logic_vector(1 downto 0);
  signal ahb_slv_0_hmastlock  : std_logic;
  signal ahb_slv_0_hwdata     : std_logic_vector(63 downto 0);
  signal ahb_slv_0_hready     : std_logic;
  signal ahb_slv_0_hrdata     : std_logic_vector(63 downto 0);
  signal ahb_slv_0_hresp      : std_logic;
  signal ahb_slv_0_hsel       : std_logic;
  -- AHB SLAVE 1
  signal ahb_slv_1_hresetn    : std_logic;
  signal ahb_slv_1_haddr      : std_logic_vector(31 downto 0);
  signal ahb_slv_1_hwrite     : std_logic;
  signal ahb_slv_1_hsize      : std_logic_vector(2 downto 0);
  signal ahb_slv_1_hburst     : std_logic_vector(2 downto 0);
  signal ahb_slv_1_hprot      : std_logic_vector(6 downto 0);
  signal ahb_slv_1_hnonsec    : std_logic;
  signal ahb_slv_1_htrans     : std_logic_vector(1 downto 0);
  signal ahb_slv_1_hmastlock  : std_logic;
  signal ahb_slv_1_hwdata     : std_logic_vector(63 downto 0);
  signal ahb_slv_1_hready     : std_logic;
  signal ahb_slv_1_hrdata     : std_logic_vector(63 downto 0);
  signal ahb_slv_1_hresp      : std_logic;
  signal ahb_slv_1_hsel       : std_logic;

begin
  ----------------------------------------------------------------
  --                      AXI INTERCONNECT                      --
  ----------------------------------------------------------------
  axi_interconnect_ip_inst : entity work.axi_interconnect_ip
  generic map (
    ADDR_MAP_TABLE => AXI_ADDR_MAP,
    ADDR_DEC_MSB   => AXI_MSB_DECODER,
    ADDR_DEC_LSB   => 0
  )
  port map(
    S_AXI_ACLK     => AXI_ACLK,
    S_AXI_ARESETN  => AXI_ARESETN,
    --
    S_AXI_AWID     => S_AXI_AWID, 
    S_AXI_AWADDR   => S_AXI_AWADDR, 
    S_AXI_AWLEN    => S_AXI_AWLEN, 
    S_AXI_AWSIZE   => S_AXI_AWSIZE, 
    S_AXI_AWBURST  => S_AXI_AWBURST, 
    S_AXI_AWLOCK   => S_AXI_AWLOCK, 
    S_AXI_AWCACHE  => S_AXI_AWCACHE, 
    S_AXI_AWPROT   => S_AXI_AWPROT, 
    S_AXI_AWVALID  => S_AXI_AWVALID, 
    S_AXI_AWREADY  => S_AXI_AWREADY, 
    S_AXI_WID      => S_AXI_WID, 
    S_AXI_WDATA    => S_AXI_WDATA, 
    S_AXI_WSTRB    => S_AXI_WSTRB, 
    S_AXI_WLAST    => S_AXI_WLAST, 
    S_AXI_WVALID   => S_AXI_WVALID, 
    S_AXI_WREADY   => S_AXI_WREADY, 
    S_AXI_BID      => S_AXI_BID, 
    S_AXI_BRESP    => S_AXI_BRESP, 
    S_AXI_BVALID   => S_AXI_BVALID, 
    S_AXI_BREADY   => S_AXI_BREADY, 
    S_AXI_ARID     => S_AXI_ARID, 
    S_AXI_ARADDR   => S_AXI_ARADDR, 
    S_AXI_ARLEN    => S_AXI_ARLEN, 
    S_AXI_ARSIZE   => S_AXI_ARSIZE, 
    S_AXI_ARBURST  => S_AXI_ARBURST, 
    S_AXI_ARLOCK   => S_AXI_ARLOCK, 
    S_AXI_ARCACHE  => S_AXI_ARCACHE, 
    S_AXI_ARPROT   => S_AXI_ARPROT, 
    S_AXI_ARVALID  => S_AXI_ARVALID, 
    S_AXI_ARREADY  => S_AXI_ARREADY, 
    S_AXI_RREADY   => S_AXI_RREADY, 
    S_AXI_RID      => S_AXI_RID,
    S_AXI_RDATA    => S_AXI_RDATA,
    S_AXI_RRESP    => S_AXI_RRESP,
    S_AXI_RLAST    => S_AXI_RLAST, 
    S_AXI_RVALID   => S_AXI_RVALID, 
    --
    M0_AXI_AWID    => apb_axi_awid, 
    M0_AXI_AWADDR  => apb_axi_awaddr, 
    M0_AXI_AWLEN   => apb_axi_awlen, 
    M0_AXI_AWSIZE  => apb_axi_awsize, 
    M0_AXI_AWBURST => apb_axi_awburst, 
    M0_AXI_AWLOCK  => apb_axi_awlock, 
    M0_AXI_AWCACHE => apb_axi_awcache, 
    M0_AXI_AWPROT  => apb_axi_awprot, 
    M0_AXI_AWVALID => apb_axi_awvalid, 
    M0_AXI_AWREADY => apb_axi_awready, 
    M0_AXI_WID     => apb_axi_wid, 
    M0_AXI_WDATA   => apb_axi_wdata, 
    M0_AXI_WSTRB   => apb_axi_wstrb, 
    M0_AXI_WLAST   => apb_axi_wlast, 
    M0_AXI_WVALID  => apb_axi_wvalid, 
    M0_AXI_WREADY  => apb_axi_wready, 
    M0_AXI_BID     => apb_axi_bid, 
    M0_AXI_BRESP   => apb_axi_bresp, 
    M0_AXI_BVALID  => apb_axi_bvalid, 
    M0_AXI_BREADY  => apb_axi_bready, 
    M0_AXI_ARID    => apb_axi_arid, 
    M0_AXI_ARADDR  => apb_axi_araddr, 
    M0_AXI_ARLEN   => apb_axi_arlen, 
    M0_AXI_ARSIZE  => apb_axi_arsize, 
    M0_AXI_ARBURST => apb_axi_arburst, 
    M0_AXI_ARLOCK  => apb_axi_arlock, 
    M0_AXI_ARCACHE => apb_axi_arcache, 
    M0_AXI_ARPROT  => apb_axi_arprot, 
    M0_AXI_ARVALID => apb_axi_arvalid, 
    M0_AXI_ARREADY => apb_axi_arready, 
    M0_AXI_RREADY  => apb_axi_rready, 
    M0_AXI_RID     => apb_axi_rid,
    M0_AXI_RDATA   => apb_axi_rdata,
    M0_AXI_RRESP   => apb_axi_rresp,
    M0_AXI_RLAST   => apb_axi_rlast, 
    M0_AXI_RVALID  => apb_axi_rvalid, 
    --
    M1_AXI_AWID    => bram_axi_awid, 
    M1_AXI_AWADDR  => bram_axi_awaddr, 
    M1_AXI_AWLEN   => bram_axi_awlen, 
    M1_AXI_AWSIZE  => bram_axi_awsize, 
    M1_AXI_AWBURST => bram_axi_awburst,
    M1_AXI_AWLOCK  => bram_axi_awlock, 
    M1_AXI_AWCACHE => bram_axi_awcache,
    M1_AXI_AWPROT  => bram_axi_awprot, 
    M1_AXI_AWVALID => bram_axi_awvalid,
    M1_AXI_AWREADY => bram_axi_awready,
    M1_AXI_WID     => bram_axi_wid, 
    M1_AXI_WDATA   => bram_axi_wdata, 
    M1_AXI_WSTRB   => bram_axi_wstrb, 
    M1_AXI_WLAST   => bram_axi_wlast, 
    M1_AXI_WVALID  => bram_axi_wvalid, 
    M1_AXI_WREADY  => bram_axi_wready, 
    M1_AXI_BID     => bram_axi_bid, 
    M1_AXI_BRESP   => bram_axi_bresp, 
    M1_AXI_BVALID  => bram_axi_bvalid, 
    M1_AXI_BREADY  => bram_axi_bready, 
    M1_AXI_ARID    => bram_axi_arid, 
    M1_AXI_ARADDR  => bram_axi_araddr, 
    M1_AXI_ARLEN   => bram_axi_arlen, 
    M1_AXI_ARSIZE  => bram_axi_arsize, 
    M1_AXI_ARBURST => bram_axi_arburst,
    M1_AXI_ARLOCK  => bram_axi_arlock, 
    M1_AXI_ARCACHE => bram_axi_arcache,
    M1_AXI_ARPROT  => bram_axi_arprot, 
    M1_AXI_ARVALID => bram_axi_arvalid,
    M1_AXI_ARREADY => bram_axi_arready,
    M1_AXI_RREADY  => bram_axi_rready, 
    M1_AXI_RID     => bram_axi_rid,
    M1_AXI_RDATA   => bram_axi_rdata,
    M1_AXI_RRESP   => bram_axi_rresp,
    M1_AXI_RLAST   => bram_axi_rlast, 
    M1_AXI_RVALID  => bram_axi_rvalid, 
    -- 
    M2_AXI_AWID    => sram_axi_awid, 
    M2_AXI_AWADDR  => sram_axi_awaddr, 
    M2_AXI_AWLEN   => sram_axi_awlen, 
    M2_AXI_AWSIZE  => sram_axi_awsize, 
    M2_AXI_AWBURST => sram_axi_awburst,
    M2_AXI_AWLOCK  => sram_axi_awlock, 
    M2_AXI_AWCACHE => sram_axi_awcache,
    M2_AXI_AWPROT  => sram_axi_awprot, 
    M2_AXI_AWVALID => sram_axi_awvalid,
    M2_AXI_AWREADY => sram_axi_awready,
    M2_AXI_WID     => sram_axi_wid, 
    M2_AXI_WDATA   => sram_axi_wdata, 
    M2_AXI_WSTRB   => sram_axi_wstrb, 
    M2_AXI_WLAST   => sram_axi_wlast, 
    M2_AXI_WVALID  => sram_axi_wvalid, 
    M2_AXI_WREADY  => sram_axi_wready, 
    M2_AXI_BID     => sram_axi_bid, 
    M2_AXI_BRESP   => sram_axi_bresp, 
    M2_AXI_BVALID  => sram_axi_bvalid, 
    M2_AXI_BREADY  => sram_axi_bready, 
    M2_AXI_ARID    => sram_axi_arid, 
    M2_AXI_ARADDR  => sram_axi_araddr, 
    M2_AXI_ARLEN   => sram_axi_arlen, 
    M2_AXI_ARSIZE  => sram_axi_arsize, 
    M2_AXI_ARBURST => sram_axi_arburst,
    M2_AXI_ARLOCK  => sram_axi_arlock, 
    M2_AXI_ARCACHE => sram_axi_arcache,
    M2_AXI_ARPROT  => sram_axi_arprot, 
    M2_AXI_ARVALID => sram_axi_arvalid,
    M2_AXI_ARREADY => sram_axi_arready,
    M2_AXI_RREADY  => sram_axi_rready, 
    M2_AXI_RID     => sram_axi_rid,
    M2_AXI_RDATA   => sram_axi_rdata,
    M2_AXI_RRESP   => sram_axi_rresp,
    M2_AXI_RLAST   => sram_axi_rlast, 
    M2_AXI_RVALID  => sram_axi_rvalid, 
    --
    M3_AXI_AWID    => ahb_axi_awid,
    M3_AXI_AWADDR  => ahb_axi_awaddr,
    M3_AXI_AWLEN   => ahb_axi_awlen,
    M3_AXI_AWSIZE  => ahb_axi_awsize,
    M3_AXI_AWBURST => ahb_axi_awburst,
    M3_AXI_AWLOCK  => ahb_axi_awlock,
    M3_AXI_AWCACHE => ahb_axi_awcache,
    M3_AXI_AWPROT  => ahb_axi_awprot,
    M3_AXI_AWVALID => ahb_axi_awvalid,
    M3_AXI_AWREADY => ahb_axi_awready,
    M3_AXI_WID     => ahb_axi_wid,
    M3_AXI_WDATA   => ahb_axi_wdata,
    M3_AXI_WSTRB   => ahb_axi_wstrb,
    M3_AXI_WLAST   => ahb_axi_wlast,
    M3_AXI_WVALID  => ahb_axi_wvalid,
    M3_AXI_WREADY  => ahb_axi_wready,
    M3_AXI_BID     => ahb_axi_bid,
    M3_AXI_BRESP   => ahb_axi_bresp ,
    M3_AXI_BVALID  => ahb_axi_bvalid,
    M3_AXI_BREADY  => ahb_axi_bready,
    M3_AXI_ARID    => ahb_axi_arid,
    M3_AXI_ARADDR  => ahb_axi_araddr,
    M3_AXI_ARLEN   => ahb_axi_arlen,
    M3_AXI_ARSIZE  => ahb_axi_arsize,
    M3_AXI_ARBURST => ahb_axi_arburst,
    M3_AXI_ARLOCK  => ahb_axi_arlock,
    M3_AXI_ARCACHE => ahb_axi_arcache,
    M3_AXI_ARPROT  => ahb_axi_arprot,
    M3_AXI_ARVALID => ahb_axi_arvalid,
    M3_AXI_ARREADY => ahb_axi_arready,
    M3_AXI_RREADY  => ahb_axi_rready,
    M3_AXI_RID     => ahb_axi_rid,
    M3_AXI_RDATA   => ahb_axi_rdata,
    M3_AXI_RRESP   => ahb_axi_rresp,
    M3_AXI_RLAST   => ahb_axi_rlast,
    M3_AXI_RVALID  => ahb_axi_rvalid
  );
  --------------------
  --   APB DOMAIN   --
  --------------------
  -- CLOCK DOMAIN CROSSING --
  axi_apb_cdc_inst : entity work.axi_cdc_ip
  port map (
    S_AXI_ACLK    => AXI_ACLK,
    S_AXI_ARESETN => AXI_ARESETN,
    S_AXI_AWID    => apb_axi_awid, 
    S_AXI_AWADDR  => apb_axi_awaddr, 
    S_AXI_AWLEN   => apb_axi_awlen, 
    S_AXI_AWSIZE  => apb_axi_awsize, 
    S_AXI_AWBURST => apb_axi_awburst, 
    S_AXI_AWLOCK  => apb_axi_awlock, 
    S_AXI_AWCACHE => apb_axi_awcache, 
    S_AXI_AWPROT  => apb_axi_awprot, 
    S_AXI_AWVALID => apb_axi_awvalid, 
    S_AXI_AWREADY => apb_axi_awready, 
    S_AXI_WID     => apb_axi_wid, 
    S_AXI_WDATA   => apb_axi_wdata, 
    S_AXI_WSTRB   => apb_axi_wstrb, 
    S_AXI_WLAST   => apb_axi_wlast, 
    S_AXI_WVALID  => apb_axi_wvalid, 
    S_AXI_WREADY  => apb_axi_wready, 
    S_AXI_BID     => apb_axi_bid, 
    S_AXI_BRESP   => apb_axi_bresp, 
    S_AXI_BVALID  => apb_axi_bvalid, 
    S_AXI_BREADY  => apb_axi_bready, 
    S_AXI_ARID    => apb_axi_arid, 
    S_AXI_ARADDR  => apb_axi_araddr, 
    S_AXI_ARLEN   => apb_axi_arlen, 
    S_AXI_ARSIZE  => apb_axi_arsize, 
    S_AXI_ARBURST => apb_axi_arburst, 
    S_AXI_ARLOCK  => apb_axi_arlock, 
    S_AXI_ARCACHE => apb_axi_arcache, 
    S_AXI_ARPROT  => apb_axi_arprot, 
    S_AXI_ARVALID => apb_axi_arvalid, 
    S_AXI_ARREADY => apb_axi_arready, 
    S_AXI_RREADY  => apb_axi_rready, 
    S_AXI_RID     => apb_axi_rid,
    S_AXI_RDATA   => apb_axi_rdata,
    S_AXI_RRESP   => apb_axi_rresp,
    S_AXI_RLAST   => apb_axi_rlast, 
    S_AXI_RVALID  => apb_axi_rvalid, 
    --
    M_AXI_ACLK    => APB_CLK,
    M_AXI_ARESETN => APB_ARESETN,
    M_AXI_AWID    => slow_apb_axi_awid, 
    M_AXI_AWADDR  => slow_apb_axi_awaddr, 
    M_AXI_AWLEN   => slow_apb_axi_awlen, 
    M_AXI_AWSIZE  => slow_apb_axi_awsize, 
    M_AXI_AWBURST => slow_apb_axi_awburst, 
    M_AXI_AWLOCK  => slow_apb_axi_awlock, 
    M_AXI_AWCACHE => slow_apb_axi_awcache, 
    M_AXI_AWPROT  => slow_apb_axi_awprot, 
    M_AXI_AWVALID => slow_apb_axi_awvalid, 
    M_AXI_AWREADY => slow_apb_axi_awready, 
    M_AXI_WID     => slow_apb_axi_wid, 
    M_AXI_WDATA   => slow_apb_axi_wdata, 
    M_AXI_WSTRB   => slow_apb_axi_wstrb, 
    M_AXI_WLAST   => slow_apb_axi_wlast, 
    M_AXI_WVALID  => slow_apb_axi_wvalid, 
    M_AXI_WREADY  => slow_apb_axi_wready, 
    M_AXI_BID     => slow_apb_axi_bid, 
    M_AXI_BRESP   => slow_apb_axi_bresp, 
    M_AXI_BVALID  => slow_apb_axi_bvalid, 
    M_AXI_BREADY  => slow_apb_axi_bready, 
    M_AXI_ARID    => slow_apb_axi_arid, 
    M_AXI_ARADDR  => slow_apb_axi_araddr, 
    M_AXI_ARLEN   => slow_apb_axi_arlen, 
    M_AXI_ARSIZE  => slow_apb_axi_arsize, 
    M_AXI_ARBURST => slow_apb_axi_arburst, 
    M_AXI_ARLOCK  => slow_apb_axi_arlock, 
    M_AXI_ARCACHE => slow_apb_axi_arcache, 
    M_AXI_ARPROT  => slow_apb_axi_arprot, 
    M_AXI_ARVALID => slow_apb_axi_arvalid, 
    M_AXI_ARREADY => slow_apb_axi_arready, 
    M_AXI_RREADY  => slow_apb_axi_rready, 
    M_AXI_RID     => slow_apb_axi_rid,
    M_AXI_RDATA   => slow_apb_axi_rdata,
    M_AXI_RRESP   => slow_apb_axi_rresp,
    M_AXI_RLAST   => slow_apb_axi_rlast, 
    M_AXI_RVALID  => slow_apb_axi_rvalid
  );
  -- AXI APB BRIDGE --
  axi_apb_ip_inst : entity work.axi_apb_ip
  generic map(
    ADDR_MAP    => APB_ADDR_MAP,
    MSB_DECODER => APB_MSB_DECODER
  )
  port map (
    S_AXI_ACLK     => APB_CLK,
    S_AXI_ARESETN  => APB_ARESETN,
    --                
    S_AXI_AWID     => slow_apb_axi_awid,
    S_AXI_AWADDR   => slow_apb_axi_awaddr,
    S_AXI_AWLEN    => slow_apb_axi_awlen,
    S_AXI_AWSIZE   => slow_apb_axi_awsize,
    S_AXI_AWBURST  => slow_apb_axi_awburst,
    S_AXI_AWLOCK   => slow_apb_axi_awlock,
    S_AXI_AWCACHE  => slow_apb_axi_awcache,
    S_AXI_AWPROT   => slow_apb_axi_awprot,
    S_AXI_AWVALID  => slow_apb_axi_awvalid,
    S_AXI_AWREADY  => slow_apb_axi_awready,
    S_AXI_WID      => slow_apb_axi_wid,
    S_AXI_WDATA    => slow_apb_axi_wdata,
    S_AXI_WSTRB    => slow_apb_axi_wstrb,
    S_AXI_WLAST    => slow_apb_axi_wlast,
    S_AXI_WVALID   => slow_apb_axi_wvalid,
    S_AXI_WREADY   => slow_apb_axi_wready,
    S_AXI_BID      => slow_apb_axi_bid,
    S_AXI_BRESP    => slow_apb_axi_bresp,
    S_AXI_BVALID   => slow_apb_axi_bvalid,
    S_AXI_BREADY   => slow_apb_axi_bready,
    S_AXI_ARID     => slow_apb_axi_arid,
    S_AXI_ARADDR   => slow_apb_axi_araddr,
    S_AXI_ARLEN    => slow_apb_axi_arlen,
    S_AXI_ARSIZE   => slow_apb_axi_arsize,
    S_AXI_ARBURST  => slow_apb_axi_arburst,
    S_AXI_ARLOCK   => slow_apb_axi_arlock,
    S_AXI_ARCACHE  => slow_apb_axi_arcache,
    S_AXI_ARPROT   => slow_apb_axi_arprot,
    S_AXI_ARVALID  => slow_apb_axi_arvalid,
    S_AXI_ARREADY  => slow_apb_axi_arready,
    S_AXI_RREADY   => slow_apb_axi_rready,
    S_AXI_RID      => slow_apb_axi_rid,
    S_AXI_RDATA    => slow_apb_axi_rdata,
    S_AXI_RRESP    => slow_apb_axi_rresp,
    S_AXI_RLAST    => slow_apb_axi_rlast,
    S_AXI_RVALID   => slow_apb_axi_rvalid,
    --
    M0_APB_PADDR   => uart_apb_paddr,
    M0_APB_PSEL    => uart_apb_psel,
    M0_APB_PENABLE => uart_apb_penable,
    M0_APB_PWRITE  => uart_apb_pwrite,
    M0_APB_PWDATA  => uart_apb_pwdata,
    M0_APB_PSTRB   => uart_apb_pstrb,
    M0_APB_PPROT   => uart_apb_pprot,
    M0_APB_PREADY  => uart_apb_pready,
    M0_APB_PRDATA  => uart_apb_prdata,
    M0_APB_PSLVERR => uart_apb_pslverr,
    --
    M1_APB_PADDR   => apb_slv_1_paddr,
    M1_APB_PSEL    => apb_slv_1_psel,
    M1_APB_PENABLE => apb_slv_1_penable,
    M1_APB_PWRITE  => apb_slv_1_pwrite,
    M1_APB_PWDATA  => apb_slv_1_pwdata,
    M1_APB_PSTRB   => apb_slv_1_pstrb,
    M1_APB_PPROT   => apb_slv_1_pprot,
    M1_APB_PREADY  => apb_slv_1_pready,
    M1_APB_PRDATA  => apb_slv_1_prdata,
    M1_APB_PSLVERR => apb_slv_1_pslverr,
    --
    M2_APB_PADDR   => apb_slv_2_paddr,
    M2_APB_PSEL    => apb_slv_2_psel,
    M2_APB_PENABLE => apb_slv_2_penable,
    M2_APB_PWRITE  => apb_slv_2_pwrite,
    M2_APB_PWDATA  => apb_slv_2_pwdata,
    M2_APB_PSTRB   => apb_slv_2_pstrb,
    M2_APB_PPROT   => apb_slv_2_pprot,
    M2_APB_PREADY  => apb_slv_2_pready,
    M2_APB_PRDATA  => apb_slv_2_prdata,
    M2_APB_PSLVERR => apb_slv_2_pslverr,
    --
    -- M2_APB_PADDR   => open,
    -- M2_APB_PSEL    => open,
    -- M2_APB_PENABLE => open,
    -- M2_APB_PWRITE  => open,
    -- M2_APB_PWDATA  => open,
    -- M2_APB_PSTRB   => open,
    -- M2_APB_PPROT   => open,
    -- M2_APB_PREADY  => '0',
    -- M2_APB_PRDATA  => (others => '0'),
    -- M2_APB_PSLVERR => '0',
    -- 
    M3_APB_PADDR   => open,
    M3_APB_PSEL    => open,
    M3_APB_PENABLE => open,
    M3_APB_PWRITE  => open,
    M3_APB_PWDATA  => open,
    M3_APB_PSTRB   => open,
    M3_APB_PPROT   => open,
    M3_APB_PREADY  => '0',
    M3_APB_PRDATA  => (others => '0'),
    M3_APB_PSLVERR => '0',
    --
    M4_APB_PADDR   => open,
    M4_APB_PSEL    => open,
    M4_APB_PENABLE => open,
    M4_APB_PWRITE  => open,
    M4_APB_PWDATA  => open,
    M4_APB_PSTRB   => open,
    M4_APB_PPROT   => open,
    M4_APB_PREADY  => '0',
    M4_APB_PRDATA  => (others => '0'),
    M4_APB_PSLVERR => '0',
    --
    M5_APB_PADDR   => open,
    M5_APB_PSEL    => open,
    M5_APB_PENABLE => open,
    M5_APB_PWRITE  => open,
    M5_APB_PWDATA  => open,
    M5_APB_PSTRB   => open,
    M5_APB_PPROT   => open,
    M5_APB_PREADY  => '0',
    M5_APB_PRDATA  => (others => '0'),
    M5_APB_PSLVERR => '0',
    --
    M6_APB_PADDR   => open,
    M6_APB_PSEL    => open,
    M6_APB_PENABLE => open,
    M6_APB_PWRITE  => open,
    M6_APB_PWDATA  => open,
    M6_APB_PSTRB   => open,
    M6_APB_PPROT   => open,
    M6_APB_PREADY  => '0',
    M6_APB_PRDATA  => (others => '0'),
    M6_APB_PSLVERR => '0',
    --
    M7_APB_PADDR   => open,
    M7_APB_PSEL    => open,
    M7_APB_PENABLE => open,
    M7_APB_PWRITE  => open,
    M7_APB_PWDATA  => open,
    M7_APB_PSTRB   => open,
    M7_APB_PPROT   => open,
    M7_APB_PREADY  => '0',
    M7_APB_PRDATA  => (others => '0'),
    M7_APB_PSLVERR => '0'
  );

  -- UART --
  uart_ip_inst : entity work.uart_ip
    port map (
      PCLK          => APB_CLK,
      PRESETN       => APB_ARESETN,
      --
      S_APB_PADDR   => uart_apb_paddr,
      S_APB_PSEL    => uart_apb_psel,
      S_APB_PENABLE => uart_apb_penable,
      S_APB_PWRITE  => uart_apb_pwrite,
      S_APB_PWDATA  => uart_apb_pwdata,
      S_APB_PSTRB   => uart_apb_pstrb,
      S_APB_PPROT   => uart_apb_pprot,
      S_APB_PREADY  => uart_apb_pready,
      S_APB_PRDATA  => uart_apb_prdata,
      S_APB_PSLVERR => uart_apb_pslverr,
      --
      IRQ           => OPEN,
      -- 
      RX            => UART_RXD_I,
      TX            => UART_TXD_O
    );

  -- APB REG SLAVE --
  apb_reg_ip_inst : entity work.apb_timer_ip
    port map (
      PCLK    => APB_CLK,
      PRESETN => APB_ARESETN,
      --
      S_APB_PADDR   => apb_slv_1_paddr,
      S_APB_PSEL    => apb_slv_1_psel,
      S_APB_PENABLE => apb_slv_1_penable,
      S_APB_PWRITE  => apb_slv_1_pwrite,
      S_APB_PWDATA  => apb_slv_1_pwdata,
      S_APB_PSTRB   => apb_slv_1_pstrb,
      S_APB_PPROT   => apb_slv_1_pprot,
      S_APB_PREADY  => apb_slv_1_pready,
      S_APB_PRDATA  => apb_slv_1_prdata,
      S_APB_PSLVERR => apb_slv_1_pslverr,
      TIMER_IRQ_O         => IRQ_O
    );

  -- TASTE APB REG SLAVE --
  apb_taste_reg_ip_inst : entity work.taste_ip
  port map (
    PCLK    => APB_CLK,
    PRESETN => APB_ARESETN,
    --
    S_APB_PADDR   => apb_slv_2_paddr,
    S_APB_PSEL    => apb_slv_2_psel,
    S_APB_PENABLE => apb_slv_2_penable,
    S_APB_PWRITE  => apb_slv_2_pwrite,
    S_APB_PWDATA  => apb_slv_2_pwdata,
    S_APB_PSTRB   => apb_slv_2_pstrb,
    S_APB_PPROT   => apb_slv_2_pprot,
    S_APB_PREADY  => apb_slv_2_pready,
    S_APB_PRDATA  => apb_slv_2_prdata,
    S_APB_PSLVERR => apb_slv_2_pslverr,
    LEDS_N_O      => status_taste,
    DBGDONE       => DBGDONE,
    DONEBLDBG     => DONEBLDBG,
    STARTDBG      => STARTDBG
  );

  -- LEDS assignment
  status_leds <= "1111111" & status_taste;
  LEDS_N_O <= status_leds;


  --------------------
  --   AHB DOMAIN   --
  --------------------

  ---
  -- FIXME: There is no AHB clock domain change 
  -- therefore AHB freq must work with AXI clock and reset
  axi_ahb_ip_inst : entity work.axi_ahb_ip
  generic map (
    AHB_ADDR_MAP    => AHB_ADDR_MAP, 
    MSB_DECODER     => AHB_MSB_DECODER
  )
  port map (
  -- AXI Global System Signals
    S_AXI_ACLK     => AHB_CLK, 
    S_AXI_ARESETN  => AHB_ARESETN, 
  -- AXI Write Address Channel Signals
    S_AXI_AWID     => ahb_axi_awid, 
    S_AXI_AWADDR   => ahb_axi_awaddr, 
    S_AXI_AWLEN    => ahb_axi_awlen, 
    S_AXI_AWSIZE   => ahb_axi_awsize, 
    S_AXI_AWBURST  => ahb_axi_awburst, 
    S_AXI_AWLOCK   => ahb_axi_awlock, 
    S_AXI_AWCACHE  => ahb_axi_awcache, 
    S_AXI_AWPROT   => ahb_axi_awprot, 
    S_AXI_AWVALID  => ahb_axi_awvalid, 
    S_AXI_AWREADY  => ahb_axi_awready, 
  -- AXI Write Channel Signals
    S_AXI_WID      => ahb_axi_wid, 
    S_AXI_WDATA    => ahb_axi_wdata, 
    S_AXI_WSTRB    => ahb_axi_wstrb, 
    S_AXI_WLAST    => ahb_axi_wlast,  
    S_AXI_WVALID   => ahb_axi_wvalid,  
    S_AXI_WREADY   => ahb_axi_wready,  
  -- AXI Write Response Channel Signals
    S_AXI_BID      => ahb_axi_bid, 
    S_AXI_BRESP    => ahb_axi_bresp, 
    S_AXI_BVALID   => ahb_axi_bvalid, 
    S_AXI_BREADY   => ahb_axi_bready, 
  -- AXI Read Address Channel Signals
    S_AXI_ARID     => ahb_axi_arid, 
    S_AXI_ARADDR   => ahb_axi_araddr, 
    S_AXI_ARLEN    => ahb_axi_arlen, 
    S_AXI_ARSIZE   => ahb_axi_arsize, 
    S_AXI_ARBURST  => ahb_axi_arburst, 
    S_AXI_ARLOCK   => ahb_axi_arlock, 
    S_AXI_ARCACHE  => ahb_axi_arcache, 
    S_AXI_ARPROT   => ahb_axi_arprot, 
    S_AXI_ARVALID  => ahb_axi_arvalid, 
    S_AXI_ARREADY  => ahb_axi_arready, 
  -- AXI Read Data Channel Signals
    S_AXI_RID      => ahb_axi_rid, 
    S_AXI_RDATA    => ahb_axi_rdata, 
    S_AXI_RRESP    => ahb_axi_rresp, 
    S_AXI_RLAST    => ahb_axi_rlast, 
    S_AXI_RVALID   => ahb_axi_rvalid, 
    S_AXI_RREADY   => ahb_axi_rready, 

  -- AHB signals
    M0_AHB_HRESETN   => ahb_slv_0_hresetn,     
    M0_AHB_HADDR     => ahb_slv_0_haddr,    
    M0_AHB_HWRITE    => ahb_slv_0_hwrite,     
    M0_AHB_HSIZE     => ahb_slv_0_hsize,    
    M0_AHB_HBURST    => ahb_slv_0_hburst,     
    M0_AHB_HPROT     => ahb_slv_0_hprot,    
    M0_AHB_HNONSEC   => ahb_slv_0_hnonsec,        
    M0_AHB_HTRANS    => ahb_slv_0_htrans,        
    M0_AHB_HMASTLOCK => ahb_slv_0_hmastlock,      
    M0_AHB_HWDATA    => ahb_slv_0_hwdata, 
    M0_AHB_HREADY    => ahb_slv_0_hready, 
    M0_AHB_HRDATA    => ahb_slv_0_hrdata, 
    M0_AHB_HRESP     => ahb_slv_0_hresp,
    M0_AHB_HSEL      => ahb_slv_0_hsel, 

    M1_AHB_HRESETN   => ahb_slv_1_hresetn,     
    M1_AHB_HADDR     => ahb_slv_1_haddr,    
    M1_AHB_HWRITE    => ahb_slv_1_hwrite,     
    M1_AHB_HSIZE     => ahb_slv_1_hsize,    
    M1_AHB_HBURST    => ahb_slv_1_hburst,     
    M1_AHB_HPROT     => ahb_slv_1_hprot,    
    M1_AHB_HNONSEC   => ahb_slv_1_hnonsec,        
    M1_AHB_HTRANS    => ahb_slv_1_htrans,        
    M1_AHB_HMASTLOCK => ahb_slv_1_hmastlock,      
    M1_AHB_HWDATA    => ahb_slv_1_hwdata, 
    M1_AHB_HREADY    => ahb_slv_1_hready, 
    M1_AHB_HRDATA    => ahb_slv_1_hrdata, 
    M1_AHB_HRESP     => ahb_slv_1_hresp,
    M1_AHB_HSEL      => ahb_slv_1_hsel, 

    M2_AHB_HRESETN   => open,
    M2_AHB_HADDR     => open,
    M2_AHB_HWRITE    => open,
    M2_AHB_HSIZE     => open,
    M2_AHB_HBURST    => open,
    M2_AHB_HPROT     => open,
    M2_AHB_HNONSEC   => open,
    M2_AHB_HTRANS    => open,
    M2_AHB_HMASTLOCK => open,
    M2_AHB_HWDATA    => open,
    M2_AHB_HREADY    => '0',
    M2_AHB_HRDATA    => (others => '0'),
    M2_AHB_HRESP     => '0',
    M2_AHB_HSEL      => open,

    M3_AHB_HRESETN   => open,
    M3_AHB_HADDR     => open,
    M3_AHB_HWRITE    => open,
    M3_AHB_HSIZE     => open,
    M3_AHB_HBURST    => open,
    M3_AHB_HPROT     => open,
    M3_AHB_HNONSEC   => open,
    M3_AHB_HTRANS    => open,
    M3_AHB_HMASTLOCK => open,
    M3_AHB_HWDATA    => open,
    M3_AHB_HREADY    => '0',
    M3_AHB_HRDATA    => (others => '0'),
    M3_AHB_HRESP     => '0',
    M3_AHB_HSEL      => open,

    M4_AHB_HRESETN   => open,
    M4_AHB_HADDR     => open,
    M4_AHB_HWRITE    => open,
    M4_AHB_HSIZE     => open,
    M4_AHB_HBURST    => open,
    M4_AHB_HPROT     => open,
    M4_AHB_HNONSEC   => open,
    M4_AHB_HTRANS    => open,
    M4_AHB_HMASTLOCK => open,
    M4_AHB_HWDATA    => open,
    M4_AHB_HREADY    => '0',
    M4_AHB_HRDATA    => (others => '0'),
    M4_AHB_HRESP     => '0',
    M4_AHB_HSEL      => open,

    M5_AHB_HRESETN   => open,
    M5_AHB_HADDR     => open,
    M5_AHB_HWRITE    => open,
    M5_AHB_HSIZE     => open,
    M5_AHB_HBURST    => open,
    M5_AHB_HPROT     => open,
    M5_AHB_HNONSEC   => open,
    M5_AHB_HTRANS    => open,
    M5_AHB_HMASTLOCK => open,
    M5_AHB_HWDATA    => open,
    M5_AHB_HREADY    => '0',
    M5_AHB_HRDATA    => (others => '0'),
    M5_AHB_HRESP     => '0',
    M5_AHB_HSEL      => open,

    M6_AHB_HRESETN   => open,
    M6_AHB_HADDR     => open,
    M6_AHB_HWRITE    => open,
    M6_AHB_HSIZE     => open,
    M6_AHB_HBURST    => open,
    M6_AHB_HPROT     => open,
    M6_AHB_HNONSEC   => open,
    M6_AHB_HTRANS    => open,
    M6_AHB_HMASTLOCK => open,
    M6_AHB_HWDATA    => open,
    M6_AHB_HREADY    => '0',
    M6_AHB_HRDATA    => (others => '0'),
    M6_AHB_HRESP     => '0',
    M6_AHB_HSEL      => open,

    M7_AHB_HRESETN   => open,
    M7_AHB_HADDR     => open,
    M7_AHB_HWRITE    => open,
    M7_AHB_HSIZE     => open,
    M7_AHB_HBURST    => open,
    M7_AHB_HPROT     => open,
    M7_AHB_HNONSEC   => open,
    M7_AHB_HTRANS    => open,
    M7_AHB_HMASTLOCK => open,
    M7_AHB_HWDATA    => open,
    M7_AHB_HREADY    => '0',
    M7_AHB_HRDATA    => (others => '0'),
    M7_AHB_HRESP     => '0',
    M7_AHB_HSEL      => open
  );
  -- AHB REG SLAVE  0 --
  ahb_slv_0_inst : entity work.ahb_reg_slave
  port map (
    S_AHB_HCLK      => AHB_CLK,
    S_AHB_HRESETN   => AHB_ARESETN,     
    S_AHB_HSEL      => ahb_slv_0_hsel,
    S_AHB_HADDR     => ahb_slv_0_haddr,    
    S_AHB_HWRITE    => ahb_slv_0_hwrite,     
    S_AHB_HSIZE     => ahb_slv_0_hsize,    
    S_AHB_HBURST    => ahb_slv_0_hburst,     
    S_AHB_HPROT     => ahb_slv_0_hprot,    
    S_AHB_HTRANS    => ahb_slv_0_htrans,        
    S_AHB_HMASTLOCK => ahb_slv_0_hmastlock, 
    S_AHB_HNONSEC   => ahb_slv_0_hnonsec,     
    S_AHB_HWDATA    => ahb_slv_0_hwdata, 
    S_AHB_HREADY    => ahb_slv_0_hready, 
    S_AHB_HRDATA    => ahb_slv_0_hrdata, 
    S_AHB_HRESP     => ahb_slv_0_hresp
  );
  -- AHB REG SLAVE  1 --
  ahb_slv_1_inst : entity work.ahb_reg_slave
  port map (
    S_AHB_HCLK      => AHB_CLK,
    S_AHB_HRESETN   => AHB_ARESETN,     
    S_AHB_HSEL      => ahb_slv_1_hsel,
    S_AHB_HADDR     => ahb_slv_1_haddr,    
    S_AHB_HWRITE    => ahb_slv_1_hwrite,     
    S_AHB_HSIZE     => ahb_slv_1_hsize,    
    S_AHB_HBURST    => ahb_slv_1_hburst,     
    S_AHB_HPROT     => ahb_slv_1_hprot,    
    S_AHB_HTRANS    => ahb_slv_1_htrans,        
    S_AHB_HMASTLOCK => ahb_slv_1_hmastlock,   
    S_AHB_HNONSEC   => ahb_slv_1_hnonsec,   
    S_AHB_HWDATA    => ahb_slv_1_hwdata, 
    S_AHB_HREADY    => ahb_slv_1_hready, 
    S_AHB_HRDATA    => ahb_slv_1_hrdata, 
    S_AHB_HRESP     => ahb_slv_1_hresp
  );
  --------------------
  --      BRAM      --
  --------------------
  bram_inst : entity work.axi_bram_ip
    generic map (
      ADDR_MAP => (0 => AXI_ADDR_MAP(BRAM_AXI_NR))
    )
    port map(
      S_AXI_ACLK    => AXI_ACLK,
      S_AXI_ARESETN => AXI_ARESETN,
      --             
      S_AXI_AWID    => bram_axi_awid, 
      S_AXI_AWADDR  => bram_axi_awaddr,
      S_AXI_AWLEN   => bram_axi_awlen, 
      S_AXI_AWSIZE  => bram_axi_awsize,
      S_AXI_AWBURST => bram_axi_awburst,
      S_AXI_AWLOCK  => bram_axi_awlock,
      S_AXI_AWCACHE => bram_axi_awcache,
      S_AXI_AWPROT  => bram_axi_awprot,
      S_AXI_AWVALID => bram_axi_awvalid,
      S_AXI_AWREADY => bram_axi_awready,
      S_AXI_WID     => bram_axi_wid, 
      S_AXI_WDATA   => bram_axi_wdata, 
      S_AXI_WSTRB   => bram_axi_wstrb, 
      S_AXI_WLAST   => bram_axi_wlast, 
      S_AXI_WVALID  => bram_axi_wvalid,
      S_AXI_WREADY  => bram_axi_wready,
      S_AXI_BID     => bram_axi_bid, 
      S_AXI_BRESP   => bram_axi_bresp, 
      S_AXI_BVALID  => bram_axi_bvalid,
      S_AXI_BREADY  => bram_axi_bready,
      S_AXI_ARID    => bram_axi_arid, 
      S_AXI_ARADDR  => bram_axi_araddr,
      S_AXI_ARLEN   => bram_axi_arlen, 
      S_AXI_ARSIZE  => bram_axi_arsize,
      S_AXI_ARBURST => bram_axi_arburst,
      S_AXI_ARLOCK  => bram_axi_arlock,
      S_AXI_ARCACHE => bram_axi_arcache,
      S_AXI_ARPROT  => bram_axi_arprot,
      S_AXI_ARVALID => bram_axi_arvalid,
      S_AXI_ARREADY => bram_axi_arready,
      S_AXI_RREADY  => bram_axi_rready,
      S_AXI_RID     => bram_axi_rid,
      S_AXI_RDATA   => bram_axi_rdata,
      S_AXI_RRESP   => bram_axi_rresp,
      S_AXI_RLAST   => bram_axi_rlast, 
      S_AXI_RVALID  => bram_axi_rvalid
    );
  --------------------
  --      SRAM      --
  --------------------
  sram_inst : entity work.axi_sram_ip
    generic map (
      ADDR_MAP => (0 => AXI_ADDR_MAP(SRAM_AXI_NR))
    )
    port map(
      S_AXI_ACLK    => AXI_ACLK,
      S_AXI_ARESETN => AXI_ARESETN,
      --             
      S_AXI_AWID    => sram_axi_awid, 
      S_AXI_AWADDR  => sram_axi_awaddr,
      S_AXI_AWLEN   => sram_axi_awlen, 
      S_AXI_AWSIZE  => sram_axi_awsize,
      S_AXI_AWBURST => sram_axi_awburst,
      S_AXI_AWLOCK  => sram_axi_awlock,
      S_AXI_AWCACHE => sram_axi_awcache,
      S_AXI_AWPROT  => sram_axi_awprot,
      S_AXI_AWVALID => sram_axi_awvalid,
      S_AXI_AWREADY => sram_axi_awready,
      S_AXI_WID     => sram_axi_wid, 
      S_AXI_WDATA   => sram_axi_wdata, 
      S_AXI_WSTRB   => sram_axi_wstrb, 
      S_AXI_WLAST   => sram_axi_wlast, 
      S_AXI_WVALID  => sram_axi_wvalid,
      S_AXI_WREADY  => sram_axi_wready,
      S_AXI_BID     => sram_axi_bid, 
      S_AXI_BRESP   => sram_axi_bresp, 
      S_AXI_BVALID  => sram_axi_bvalid,
      S_AXI_BREADY  => sram_axi_bready,
      S_AXI_ARID    => sram_axi_arid, 
      S_AXI_ARADDR  => sram_axi_araddr,
      S_AXI_ARLEN   => sram_axi_arlen, 
      S_AXI_ARSIZE  => sram_axi_arsize,
      S_AXI_ARBURST => sram_axi_arburst,
      S_AXI_ARLOCK  => sram_axi_arlock,
      S_AXI_ARCACHE => sram_axi_arcache,
      S_AXI_ARPROT  => sram_axi_arprot,
      S_AXI_ARVALID => sram_axi_arvalid,
      S_AXI_ARREADY => sram_axi_arready,
      S_AXI_RREADY  => sram_axi_rready,
      S_AXI_RID     => sram_axi_rid,
      S_AXI_RDATA   => sram_axi_rdata,
      S_AXI_RRESP   => sram_axi_rresp,
      S_AXI_RLAST   => sram_axi_rlast, 
      S_AXI_RVALID  => sram_axi_rvalid,

      SRAM_ADDR     => SRAM_ADDR,    
      SRAM_DATA     => SRAM_DATA,
      SRAM_CE_N     => SRAM_CE_N,
      SRAM_WE_N     => SRAM_WE_N,
      SRAM_OE_N     => SRAM_OE_N,
      SRAM_BE_N     => SRAM_BE_N
    );
end architecture rtl;
