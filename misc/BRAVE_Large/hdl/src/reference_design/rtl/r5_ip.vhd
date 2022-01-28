-------------------------------------------------------
--! @file       r5_ip.vhd
--! @brief      R5 processor with AXI master (bootrom)
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

use work.AxiPkg.all;

entity r5_ip is
  port (
    -- Reset
    GLOBAL_RESETN : in std_logic; 
    CPU_ARESETN   : in std_logic;
    -- clocks
    CPU_CLK       : in std_logic;
    AXI_CLK_EN    : in std_logic;
    AXI_CLK       : in std_logic;

    -- IRQ
    CPU_IRQ_NI    : in std_logic;

    -- JTAG interface
    JTAG_TCK_I    : in  std_logic;
    JTAG_TRST_NI  : in  std_logic;
    JTAG_TMS_I    : in  std_logic;
    JTAG_TDI_I    : in  std_logic;
    JTAG_TDO_O    : out std_logic;

    -- AXI interface
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
    M_AXI_RVALID  : in  std_logic
  );
end entity r5_ip;

architecture wrapper of r5_ip is
  signal m_r5_axi_master : AxiMasterType;
  signal m_r5_axi_slave  : AxiSlaveType;
begin

  r5_inst : entity work.r5_wrapper
    port map (
      GLOBAL_RESETN      => GLOBAL_RESETN,
      CPU_ARESETN        => CPU_ARESETN, 

      CPU_CLK            => CPU_CLK, 
      AXI_CLK_EN         => AXI_CLK_EN, 
      AXI_CLK            => AXI_CLK, 

      CPU_IRQ_NI         => CPU_IRQ_NI, 

      JTAG_TCK_I         => JTAG_TCK_I, 
      JTAG_TRST_NI       => JTAG_TRST_NI, 
      JTAG_TMS_I         => JTAG_TMS_I, 
      JTAG_TDI_I         => JTAG_TDI_I, 
      JTAG_TDO_O         => JTAG_TDO_O, 

      m_r5_axi_master_o  => m_r5_axi_master,
      m_r5_axi_slave_i   => m_r5_axi_slave
    );


 axi_master_if_inst : entity work.axi_master_if
   port map (
     M_AXI_AWID    => M_AXI_AWID,
     M_AXI_AWADDR  => M_AXI_AWADDR,
     M_AXI_AWLEN   => M_AXI_AWLEN,
     M_AXI_AWSIZE  => M_AXI_AWSIZE,
     M_AXI_AWBURST => M_AXI_AWBURST,
     M_AXI_AWLOCK  => M_AXI_AWLOCK,
     M_AXI_AWCACHE => M_AXI_AWCACHE,
     M_AXI_AWPROT  => M_AXI_AWPROT,
     M_AXI_AWVALID => M_AXI_AWVALID,
     M_AXI_AWREADY => M_AXI_AWREADY,
     M_AXI_WID     => M_AXI_WID,
     M_AXI_WDATA   => M_AXI_WDATA,
     M_AXI_WSTRB   => M_AXI_WSTRB,
     M_AXI_WLAST   => M_AXI_WLAST,
     M_AXI_WVALID  => M_AXI_WVALID,
     M_AXI_WREADY  => M_AXI_WREADY,
     M_AXI_BID     => M_AXI_BID,
     M_AXI_BRESP   => M_AXI_BRESP,
     M_AXI_BVALID  => M_AXI_BVALID,
     M_AXI_BREADY  => M_AXI_BREADY,
     M_AXI_ARID    => M_AXI_ARID,
     M_AXI_ARADDR  => M_AXI_ARADDR,
     M_AXI_ARLEN   => M_AXI_ARLEN,
     M_AXI_ARSIZE  => M_AXI_ARSIZE,
     M_AXI_ARBURST => M_AXI_ARBURST,
     M_AXI_ARLOCK  => M_AXI_ARLOCK,
     M_AXI_ARCACHE => M_AXI_ARCACHE,
     M_AXI_ARPROT  => M_AXI_ARPROT,
     M_AXI_ARVALID => M_AXI_ARVALID,
     M_AXI_ARREADY => M_AXI_ARREADY,
     M_AXI_RREADY  => M_AXI_RREADY,
     M_AXI_RID     => M_AXI_RID,
     M_AXI_RDATA   => M_AXI_RDATA,
     M_AXI_RRESP   => M_AXI_RRESP,
     M_AXI_RLAST   => M_AXI_RLAST,
     M_AXI_RVALID  => M_AXI_RVALID,
     m_axi_master  => m_r5_axi_master,
     m_axi_slave   => m_r5_axi_slave
   );

 

end wrapper;