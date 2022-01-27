-------------------------------------------------------
--! @file       top.vhd
--! @brief      R5 reference design top level for Nanoxplore NG-Large eval board
--! @author     Régis Spadotti (Scalian) 
--! @author     Michel Francis (Scalian)
--! @author     Florent Manni (CNES)
--!
--!-----------------------------------------------------------------------------------------------
--! @copyright   CNES.   
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
--!                         * Improve code readability
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
--!  This reference design is described in details in the [markdown readme file](../doc/Reference_design.md)
--!
--! Limitations : None
--!
-------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.AxiPkg.all;
use work.AddrDecoderPkg.all;

entity top is
  port (
    --------------------------
    --external clock and reset
    --------------------------
    
    --! @note for  Nx board NG-large, if jumper J20 ON and (J19 and J18) OFF => 25 MHz 
    EXT_CLK_I         : in std_logic; --!  External clock 

    EXT_POR_RST_NI    : in std_logic; --! Active low  Power on reset reset (full reset)
    EXT_SW_RST_NI        : in std_logic; --! Active low  software only reset (processor soft reset)

    --------------------------
    -- JTAG interface
    --------------------------

    --! @attention This is an active low signal on contrary to its name. There is a pull  up on evalboard.
    ARM_DEBUG_RST     : in  std_logic; --! This signal comes from jtag debug probe and might helps reset design to clean up the software boot from jtag.
    JTAG_TCK_I        : in  std_logic; --! ARM JTAG clock
    JTAG_TRST_NI      : in  std_logic; --! ARM JTAG Reset
    JTAG_TMS_I        : in  std_logic; --! ARM JTAG select
    JTAG_TDI_I        : in  std_logic; --! ARM JTAG input 
    JTAG_TDO_O        : out std_logic; --! ARM JTAG output
    --------------------------
    -- uart interface
    --------------------------

    UART_CP2105_TXD_O : out std_logic; --! UART TX (from board point of view)
    UART_CP2105_RXD_I : in  std_logic; --! UART RX (from board point of view)

    ---------------
    -- LED OUTPUTS
    ---------------
    LEDS_N_O : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

    ---------------
    -- Debug
    ---------------

    IRQ_DBG : OUT STD_LOGIC;
    DBGDONE : OUT STD_LOGIC;
    DONEBLDBG : OUT STD_LOGIC;
    STARTDBG : OUT STD_LOGIC;

    --------------------------
    -- SRAM interface 
    --------------------------
    SRAM_ADDR         : out   std_logic_vector(15 downto 0); --!  SRAM Address Bus
    SRAM_DATA         : inout std_logic_vector(15 downto 0); --!  SRAM Data Bus
    SRAM_CE_N         : out   std_logic;                     --!  SRAM Chip enable
    SRAM_WE_N         : out   std_logic;                     --!  SRAM Write enable
    SRAM_OE_N         : out   std_logic;                     --!  SRAM Output enable
    SRAM_BE_N         : out   std_logic_vector(1 downto 0)   --!  SRAM bank enable
  );
end entity top;

--! Architecture definition of Top entity
architecture struct of top is


----------------------------------------------------------------
--! @name               AXI 
----------------------------------------------------------------
--! @{
  signal r5_axi_aclk    : std_logic; 
  signal r5_axi_aresetn : std_logic;
  signal r5_axi_awid    : std_logic_vector(3 downto 0);
  signal r5_axi_awaddr  : std_logic_vector(31 downto 0);
  signal r5_axi_awlen   : std_logic_vector(3 downto 0);
  signal r5_axi_awsize  : std_logic_vector(2 downto 0);
  signal r5_axi_awburst : std_logic_vector(1 downto 0);
  signal r5_axi_awlock  : std_logic_vector(1 downto 0);
  signal r5_axi_awcache : std_logic_vector(3 downto 0);
  signal r5_axi_awprot  : std_logic_vector(2 downto 0);
  signal r5_axi_awvalid : std_logic;
  signal r5_axi_awready : std_logic;
  signal r5_axi_wid     : std_logic_vector(3 downto 0);
  signal r5_axi_wdata   : std_logic_vector(63 downto 0);
  signal r5_axi_wstrb   : std_logic_vector(7 downto 0);
  signal r5_axi_wlast   : std_logic;
  signal r5_axi_wvalid  : std_logic;
  signal r5_axi_wready  : std_logic;
  signal r5_axi_bid     : std_logic_vector(3 downto 0);
  signal r5_axi_bresp   : std_logic_vector(1 downto 0);
  signal r5_axi_bvalid  : std_logic;
  signal r5_axi_bready  : std_logic;
  signal r5_axi_arid    : std_logic_vector(3 downto 0);
  signal r5_axi_araddr  : std_logic_vector(31 downto 0);
  signal r5_axi_arlen   : std_logic_vector(3 downto 0);
  signal r5_axi_arsize  : std_logic_vector(2 downto 0);
  signal r5_axi_arburst : std_logic_vector(1 downto 0);
  signal r5_axi_arlock  : std_logic_vector(1 downto 0);
  signal r5_axi_arcache : std_logic_vector(3 downto 0);
  signal r5_axi_arprot  : std_logic_vector(2 downto 0);
  signal r5_axi_arvalid : std_logic;
  signal r5_axi_arready : std_logic;
  signal r5_axi_rready  : std_logic;
  signal r5_axi_rid     : std_logic_vector(3 downto 0);
  signal r5_axi_rdata   : std_logic_vector(63 downto 0);
  signal r5_axi_rresp   : std_logic_vector(1 downto 0);
  signal r5_axi_rlast   : std_logic;
  signal r5_axi_rvalid  : std_logic;
  --! @}

  ----------------------------------------------------------------
  --! @name                 UART 
  ----------------------------------------------------------------
  --! @{
  signal uart_txd : std_logic;
  signal uart_rxd : std_logic;
  --! @}

  ----------------------------------------------------------------
 --!  @name                     IRQ                             
  ----------------------------------------------------------------
    --! @{
  signal cpu_irq_ni : std_logic;
  signal irq        : std_logic;
  --! @}

  ----------------------------------------------------------------
   --!  @name                        RESET                      
  ----------------------------------------------------------------
  --! @{
  signal delay_rst_q  : std_logic_vector(15 downto 0);
  signal ext_rst      : std_logic; 
  signal cpu_soft_rst_n : std_logic;
  signal cpu_soft_rst_n_1  : std_logic; 
  signal cpu_soft_rst_n_2  : std_logic;
  signal cpu_rst_n    : std_logic;
  signal apb_rst_n    : std_logic; 
  signal ahb_rst_n    : std_logic; 
  --! @}

  ----------------------------------------------------------------
  --!  @name                 CLOCKS                             
  ----------------------------------------------------------------
  --! @{
  signal pll_locked   : std_logic;
  signal cpu_clk      : std_logic; 
  signal axi_clk      : std_logic; 
  signal axi_clk_en   : std_logic; 
  signal apb_clk      : std_logic;
  signal ahb_clk      : std_logic;
  --! @}

begin
  ---------------------------------------------------------------------------
  --! External power on reset
  ---------------------------------------------------------------------------
  ext_rst      <= not EXT_POR_RST_NI;

  ---------------------------------------------------------------------------
  --! CLOCK  GENERATION
  ---------------------------------------------------------------------------
  clkgen_inst : entity work.clkgen
    port map (
      CLK_IN     => EXT_CLK_I,
      RESET      => ext_rst,
      APB_CLK    => apb_clk,
      AHB_CLK    => ahb_clk,
      CPU_CLK    => cpu_clk,
      AXI_CLK    => axi_clk,
      AXI_CLK_EN => axi_clk_en,
      LOCKED     => pll_locked,
      o_CPU_RST_N=> cpu_rst_n,
      o_APB_RST_N=> apb_rst_n,
      o_AHB_RST_N=> ahb_rst_n);

 --! cpu software reset generation
 --! release software after the last peripheral bus
  process(apb_clk, apb_rst_n) is
  begin 
    if apb_rst_n = '0' then 
      cpu_soft_rst_n_1 <= '0'; 
      cpu_soft_rst_n_2 <= '0'; 
    elsif rising_edge(apb_clk) then 
      cpu_soft_rst_n_1 <= ARM_DEBUG_RST and EXT_SW_RST_NI; 
      cpu_soft_rst_n_2 <= cpu_soft_rst_n_1; 
    end if; 
  end process;
  cpu_soft_rst_n<=cpu_soft_rst_n_2;
  ----------------------------------------------------------------
  --!                       INTERRUPTIONS                       --
  ----------------------------------------------------------------
  cpu_irq_ni <= not irq;
  IRQ_DBG <= cpu_irq_ni;

  ----------------------------------------------------------------
  --!                         CORTEX R5                          --
  ----------------------------------------------------------------
  r5_ip_inst: entity work.r5_ip
    port map (
      --! 
      GLOBAL_RESETN => cpu_rst_n,         --! this if the power on reset
      CPU_ARESETN   => cpu_soft_rst_n,    --! this is the software reset
      --! 
      CPU_CLK       => cpu_clk,      
      AXI_CLK_EN    => axi_clk_en, 
      AXI_CLK       => axi_clk,
      --
      CPU_IRQ_NI    => cpu_irq_ni,
      --
      JTAG_TCK_I    => JTAG_TCK_I,
      JTAG_TRST_NI  => JTAG_TRST_NI,
      JTAG_TMS_I    => JTAG_TMS_I,
      JTAG_TDI_I    => JTAG_TDI_I,
      JTAG_TDO_O    => JTAG_TDO_O,
      --
      M_AXI_AWID    => r5_axi_awid,
      M_AXI_AWADDR  => r5_axi_awaddr,
      M_AXI_AWLEN   => r5_axi_awlen,
      M_AXI_AWSIZE  => r5_axi_awsize,
      M_AXI_AWBURST => r5_axi_awburst,
      M_AXI_AWLOCK  => r5_axi_awlock,
      M_AXI_AWCACHE => r5_axi_awcache,
      M_AXI_AWPROT  => r5_axi_awprot,
      M_AXI_AWVALID => r5_axi_awvalid,
      M_AXI_AWREADY => r5_axi_awready,
      M_AXI_WID     => r5_axi_wid,
      M_AXI_WDATA   => r5_axi_wdata,
      M_AXI_WSTRB   => r5_axi_wstrb,
      M_AXI_WLAST   => r5_axi_wlast,
      M_AXI_WVALID  => r5_axi_wvalid,
      M_AXI_WREADY  => r5_axi_wready,
      M_AXI_BID     => r5_axi_bid,
      M_AXI_BRESP   => r5_axi_bresp,
      M_AXI_BVALID  => r5_axi_bvalid,
      M_AXI_BREADY  => r5_axi_bready,
      M_AXI_ARID    => r5_axi_arid,
      M_AXI_ARADDR  => r5_axi_araddr,
      M_AXI_ARLEN   => r5_axi_arlen,
      M_AXI_ARSIZE  => r5_axi_arsize,
      M_AXI_ARBURST => r5_axi_arburst,
      M_AXI_ARLOCK  => r5_axi_arlock,
      M_AXI_ARCACHE => r5_axi_arcache,
      M_AXI_ARPROT  => r5_axi_arprot,
      M_AXI_ARVALID => r5_axi_arvalid,
      M_AXI_ARREADY => r5_axi_arready,
      M_AXI_RREADY  => r5_axi_rready,
      M_AXI_RID     => r5_axi_rid,
      M_AXI_RDATA   => r5_axi_rdata,
      M_AXI_RRESP   => r5_axi_rresp,
      M_AXI_RLAST   => r5_axi_rlast,
      M_AXI_RVALID  => r5_axi_rvalid
    );
    
  ----------------------------------------------------------------
  --! @brief                AXI_SYSTEM                          --
  ----------------------------------------------------------------
  axi_system_ip_inst : ENTITY work.axi_system_ip
    PORT MAP(
      AXI_ACLK => axi_clk,
      AXI_ARESETN => cpu_rst_n,
      --
      S_AXI_AWID => r5_axi_awid,
      S_AXI_AWADDR => r5_axi_awaddr,
      S_AXI_AWLEN => r5_axi_awlen,
      S_AXI_AWSIZE => r5_axi_awsize,
      S_AXI_AWBURST => r5_axi_awburst,
      S_AXI_AWLOCK => r5_axi_awlock,
      S_AXI_AWCACHE => r5_axi_awcache,
      S_AXI_AWPROT => r5_axi_awprot,
      S_AXI_AWVALID => r5_axi_awvalid,
      S_AXI_AWREADY => r5_axi_awready,
      S_AXI_WID => r5_axi_wid,
      S_AXI_WDATA => r5_axi_wdata,
      S_AXI_WSTRB => r5_axi_wstrb,
      S_AXI_WLAST => r5_axi_wlast,
      S_AXI_WVALID => r5_axi_wvalid,
      S_AXI_WREADY => r5_axi_wready,
      S_AXI_BID => r5_axi_bid,
      S_AXI_BRESP => r5_axi_bresp,
      S_AXI_BVALID => r5_axi_bvalid,
      S_AXI_BREADY => r5_axi_bready,
      S_AXI_ARID => r5_axi_arid,
      S_AXI_ARADDR => r5_axi_araddr,
      S_AXI_ARLEN => r5_axi_arlen,
      S_AXI_ARSIZE => r5_axi_arsize,
      S_AXI_ARBURST => r5_axi_arburst,
      S_AXI_ARLOCK => r5_axi_arlock,
      S_AXI_ARCACHE => r5_axi_arcache,
      S_AXI_ARPROT => r5_axi_arprot,
      S_AXI_ARVALID => r5_axi_arvalid,
      S_AXI_ARREADY => r5_axi_arready,
      S_AXI_RREADY => r5_axi_rready,
      S_AXI_RID => r5_axi_rid,
      S_AXI_RDATA => r5_axi_rdata,
      S_AXI_RRESP => r5_axi_rresp,
      S_AXI_RLAST => r5_axi_rlast,
      S_AXI_RVALID => r5_axi_rvalid,
      --
      APB_CLK => apb_clk,
      APB_ARESETN => apb_rst_n,
      --! 
      --be careful thee is no clock domain change omplemented for AHB from AXI
      --! we should be using ahb_rst_n and ahb_clk but instead it is cpu domain
      AHB_CLK => axi_clk,
      AHB_ARESETN => cpu_rst_n,
      --
      UART_TXD_O => UART_CP2105_TXD_O,
      UART_RXD_I => UART_CP2105_RXD_I,
      --!  
      LEDS_N_O => LEDS_N_O,
      DBGDONE => DBGDONE,
      DONEBLDBG => DONEBLDBG,
      STARTDBG => STARTDBG,
      --
      SRAM_ADDR => SRAM_ADDR,
      SRAM_DATA => SRAM_DATA,
      SRAM_CE_N => SRAM_CE_N,
      SRAM_WE_N => SRAM_WE_N,
      SRAM_OE_N => SRAM_OE_N,
      SRAM_BE_N => SRAM_BE_N,
      
      IRQ_O => irq
    );

end architecture;
