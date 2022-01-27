-------------------------------------------------------
--! @file       r5_wrapper.vhd
--! @brief      R5 processor wrapper
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

library NX;
use NX.nxPackage.all;

use work.AxiPkg.all;

entity r5_wrapper is
  port (
    -- Reset
    GLOBAL_RESETN      : in std_logic; 
    CPU_ARESETN        : in std_logic;
    -- clocks
    CPU_CLK            : in std_logic;
    AXI_CLK_EN         : in std_logic;
    AXI_CLK            : in std_logic;

    -- IRQ
    CPU_IRQ_NI         : in std_logic;

    -- R5 AXI Master interface
    M_R5_AXI_MASTER_O  : out AxiMasterType;
    M_R5_AXI_SLAVE_I   : in  AxiSlaveType;

    -- JTAG interface
    JTAG_TCK_I         : in  std_logic;
    JTAG_TRST_NI       : in  std_logic;
    JTAG_TMS_I         : in  std_logic;
    JTAG_TDI_I         : in  std_logic;
    JTAG_TDO_O         : out std_logic
  );
end entity r5_wrapper;

architecture rtl of r5_wrapper is
   -- DAP related PWRUP signals. simple loop. Should be connected to
   -- power controller(s)
   signal dbgpwrupreq : std_logic;
   signal dbgpwrupack : std_logic;
   signal syspwrupreq : std_logic;
   signal syspwrupack : std_logic;
   signal cdbgrstack  : std_logic;
   signal cdbgrstreq  : std_logic;

   signal s_jtag_tck_i : std_logic;

-----------------
-- TCM Initializer as a AXI master to R5 AXI slave port 
-----------------
signal nCPUHALT_ld : std_logic := '0';    
-- AXI slave port (write tcm from PL)
   -- Write Address Channel
   signal AWADDRS0  : std_logic_vector(31 downto 0) := (others => '0');
   signal AWBURSTS0 : std_logic_vector(1 downto 0)  := (others => '0');
   signal AWCACHES0 : std_logic_vector(3 downto 0)  := (others => '0');

   signal AWIDS0    : std_logic_vector(7 downto 0)  := (others => '0');
   signal AWLENS0   : std_logic_vector(3 downto 0)  := (others => '0');
   signal AWLOCKS0  : std_logic_vector(1 downto 0)  := (others => '0');
   signal AWPROTS0  : std_logic_vector(2 downto 0)  := (others => '0');
   signal AWREADYS0 : std_logic                     := '0';
   signal AWSIZES0  : std_logic_vector(2 downto 0)  := (others => '0');
   signal AWVALIDS0 : std_logic                     := '0';
   -- Write Data Channel
   signal WDATAS0   : std_logic_vector(63 downto 0) := (others => '0');
   signal WIDS0     : std_logic_vector(7 downto 0)  := (others => '0');
   signal WLASTS0   : std_logic                     := '0';
   signal WREADYS0  : std_logic                     := '0';
   signal WSTRBS0   : std_logic_vector(7 downto 0)  := (others => '0');
   signal WVALIDS0  : std_logic                     := '0';
   -- Write response channel
   signal BIDS0     : std_logic_vector(7 downto 0)  := (others => '0');
   signal BREADYS0  : std_logic                     := '0';
   signal BRESPS0   : std_logic_vector(1 downto 0)  := (others => '0');
   signal BVALIDS0  : std_logic                     := '0';
   -- Read Address Channel
   signal ARADDRS0  : std_logic_vector(31 downto 0) := (others => '0');
   signal ARBURSTS0 : std_logic_vector(1 downto 0)  := (others => '0');
   signal ARCACHES0 : std_logic_vector(3 downto 0)  := (others => '0');
   signal ARIDS0    : std_logic_vector(7 downto 0)  := (others => '0');
   signal ARLENS0   : std_logic_vector(3 downto 0)  := (others => '0');
   signal ARLOCKS0  : std_logic_vector(1 downto 0)  := (others => '0');
   signal ARPROTS0  : std_logic_vector(2 downto 0)  := (others => '0');
   signal ARREADYS0 : std_logic                     := '0';
   signal ARSIZES0  : std_logic_vector(2 downto 0)  := (others => '0');

   signal ARVALIDS0  : std_logic                     := '0';
   -- Read Data Channel
   signal RDATAS0    : std_logic_vector(63 downto 0) := (others => '0');
   signal RIDS0      : std_logic_vector(7 downto 0)  := (others => '0');
   signal RLASTS0    : std_logic                     := '0';
   signal RREADYS0   : std_logic                     := '0';
   signal RRESPS0    : std_logic_vector(1 downto 0)  := (others => '0');
   signal RVALIDS0   : std_logic                     := '0';

begin

WFG_MASTER_L_0 : NX_WFG_L
  generic map(
    wfg_edge => '0',
    mode => '0',
    pattern_end => 0,
    pattern => (others => '0'),
    delay_on => '0',
    delay => 0
  )
  port map (
    R=> '0',
    SI => '0',
    ZI => JTAG_TCK_I,
    RDY => '1',
    SO => open,
    ZO => s_jtag_tck_i
  );

  ---------------------------------------------------------------------------
  -- CORTEX R5 HARD IP
  ---------------------------------------------------------------------------
  cpu_core_inst: NX_R5_L_WRAP
    port map (
      ------------------------------------------------------------------------
      -- (Cortex R5 A.1)
      -- Global
      ------------------------------------------------------------------------
      CLKIN            => CPU_CLK,
      nRESET0          => CPU_ARESETN,
      nSYSPORESET      => GLOBAL_RESETN,
      nCPUHALT0        => nCPUHALT_ld,
      DBGNOCLKSTOP     => '0',
      nCLKSTOPPED0     => open,
      nWFEPIPESTOPPED0 => open,
      nWFIPIPESTOPPED0 => open,
      EVENTI0          => '0',
      EVENTO0          => open,
      ------------------------------------------------------------------------
      -- Configuration signals
      ------------------------------------------------------------------------
      VINITHI0         => '0',             --
      CFGEE            => '0',             --
      CFGIE            => '0',             --
      INITRAMA0        => '1',             --
      LOCZRAMA0        => '1',             --
      TEINIT           => '0',             -- '1' : for thumb | '0' : for ARM
      CFGNMFI0         => '0',             --
      PARECCENRAM0     => '0',             -- ECC check for ATCM
      PARITYLEVEL      => '0',             -- '0' : for even parity | '1' : for odd parity
      ERRENRAM0        => '0',             -- '1' : ATCM external error enable.
      GROUPID          => (others => '0'), --
      INITPPX0         => '0',             --  AXI disabled after reset
      PPXBASE0         => X"10000",        -- 20'hAE000    0x10000000
      PPXSIZE0         => "00111",         --  5'h07 (64kB)
      PPVBASE0         => X"10000",        -- 20'hAE000    0x10000000
      PPVSIZE0         => "00011",         --  5'h03 (4kB)
      ------------------------------------------------------------------------
      -- (Cortex R5 A.4)
      -- Interrupt signals
      ------------------------------------------------------------------------
      nFIQ0            => '1',
      nIRQ0            => CPU_IRQ_NI,
      nPMUIRQ0         => open,
      ------------------------------------------------------------------------
      -- (Cortex R5 A.5.1)
      -- L2 interface signals - AXI Master Port
      ------------------------------------------------------------------------
      ACLKENM0         => AXI_CLK_EN,
      -- WRITE ADDRESS CHANNEL
      AWADDRM0         => M_R5_AXI_MASTER_O.aw.addr,
      AWBURSTM0        => M_R5_AXI_MASTER_O.aw.burst,
      AWCACHEM0        => M_R5_AXI_MASTER_O.aw.cache,
      AWIDM0           => M_R5_AXI_MASTER_O.aw.id,
      AWLENM0          => M_R5_AXI_MASTER_O.aw.len,
      AWLOCKM0         => M_R5_AXI_MASTER_O.aw.lock,
      AWPROTM0         => M_R5_AXI_MASTER_O.aw.prot,
      AWREADYM0        => M_R5_AXI_SLAVE_I.awready,
      AWSIZEM0         => M_R5_AXI_MASTER_O.aw.size,
      AWINNERM0        => open,
      AWSHAREM0        => open,
      AWVALIDM0        => M_R5_AXI_MASTER_O.awvalid,
      -- WRITE DATA CHANNEL
      WDATAM0          => M_R5_AXI_MASTER_O.w.data,
      WIDM0            => M_R5_AXI_MASTER_O.w.id,
      WLASTM0          => M_R5_AXI_MASTER_O.w.last,
      WREADYM0         => M_R5_AXI_SLAVE_I.wready,
      WSTRBM0          => M_R5_AXI_MASTER_O.w.strb,
      WVALIDM0         => M_R5_AXI_MASTER_O.wvalid,
      -- WRITE RESPONSE CHANNEL
      BIDM0            => M_R5_AXI_SLAVE_I.b.id,
      BREADYM0         => M_R5_AXI_MASTER_O.bready,
      BRESPM0          => M_R5_AXI_SLAVE_I.b.resp,
      BVALIDM0         => M_R5_AXI_SLAVE_I.bvalid,
      -- READ ADDRESS CHANNEL
      ARADDRM0         => M_R5_AXI_MASTER_O.ar.addr,
      ARBURSTM0        => M_R5_AXI_MASTER_O.ar.burst,
      ARCACHEM0        => M_R5_AXI_MASTER_O.ar.cache,
      ARIDM0           => M_R5_AXI_MASTER_O.ar.id,
      ARLENM0          => M_R5_AXI_MASTER_O.ar.len,
      ARLOCKM0         => M_R5_AXI_MASTER_O.ar.lock,
      ARPROTM0         => M_R5_AXI_MASTER_O.ar.prot,
      ARREADYM0        => M_R5_AXI_SLAVE_I.arready,
      ARSIZEM0         => M_R5_AXI_MASTER_O.ar.size,
      ARINNERM0        => open,
      ARSHAREM0        => open,
      ARVALIDM0        => M_R5_AXI_MASTER_O.arvalid,
      -- READ DATA CHANNEL
      RDATAM0          => M_R5_AXI_SLAVE_I.r.data,
      RIDM0            => M_R5_AXI_SLAVE_I.r.id,
      RLASTM0          => M_R5_AXI_SLAVE_I.r.last,
      RREADYM0         => M_R5_AXI_MASTER_O.rready,
      RRESPM0          => M_R5_AXI_SLAVE_I.r.resp,
      RVALIDM0         => M_R5_AXI_SLAVE_I.rvalid,
      ------------------------------------------------------------------------
      -- (Cortex R5 A.5.3)
      -- L2 interface signals - AXI Slave Port
      ------------------------------------------------------------------------
      ACLKENS0         =>AXI_CLK_EN, 
      -- WRITE ADDRESS CHANNEL
      AWADDRS0         => AWADDRS0, --
      AWBURSTS0        => AWBURSTS0,
      AWCACHES0        => AWCACHES0,
      AWIDS0           => AWIDS0,
      AWLENS0          => AWLENS0,
      AWLOCKS0         => AWLOCKS0,
      AWPROTS0         => AWPROTS0,
      AWREADYS0        => AWREADYS0,
      AWSIZES0         => AWSIZES0,
      AWVALIDS0        => AWVALIDS0,
      -- WRITE DATA CHANNEL
      WDATAS0          =>WDATAS0,
      WIDS0            => WIDS0,
      WLASTS0          => WLASTS0,
      WREADYS0         => WREADYS0,
      WSTRBS0          => WSTRBS0,
      WVALIDS0         => WVALIDS0,
      -- WRITE RESPONSE CHANNEL
      BIDS0            => BIDS0,
      BREADYS0         => BREADYS0,
      BRESPS0          => BRESPS0,
      BVALIDS0         => BVALIDS0,
      -- READ ADDRESS CHANNEL
      ARADDRS0         => ARADDRS0,
      ARBURSTS0        => ARBURSTS0,
      ARCACHES0        => ARCACHES0,
      ARIDS0           => ARIDS0,
      ARLENS0          => ARLENS0,
      ARLOCKS0         => ARLOCKS0,
      ARPROTS0         => ARPROTS0,
      ARREADYS0        => ARREADYS0,
      ARSIZES0         => ARSIZES0,
      ARVALIDS0        => ARVALIDS0,
      -- READ DATA CHANNEL
      RDATAS0          => RDATAS0,
      RIDS0            => RIDS0,
      RLASTS0          => RLASTS0,
      RREADYS0         => RREADYS0,
      RRESPS0          => RRESPS0,
      RVALIDS0         => RVALIDS0,
      ------------------------------------------------------------------------
      -- (Cortex R5 A.5.9)
      -- L2 interface signals - AXI Peripheral Port
      ------------------------------------------------------------------------
      ACLKENP0         => '0',
      -- WRITE ADDRESS CHANNEL
      AWIDP0           => open,
      AWADDRP0         => open,
      AWLENP0          => open,
      AWSIZEP0         => open,
      AWBURSTP0        => open,
      AWLOCKP0         => open,
      AWCACHEP0        => open,
      AWPROTP0         => open,
      AWVALIDP0        => open,
      AWREADYP0        => '0',
      -- WRITE DATA CHANNEL
      WIDP0            => open,
      WDATAP0          => open,
      WSTRBP0          => open,
      WLASTP0          => open,
      WVALIDP0         => open,
      WREADYP0         => '0',
      -- WRITE RESPONSE CHANNEL
      BIDP0            => (others => '0'),
      BRESPP0          => (others => '0'),
      BVALIDP0         => '0',
      BREADYP0         => open,
      -- READ ADDRESS CHANNEL
      ARIDP0           => open,
      ARADDRP0         => open,
      ARLENP0          => open,
      ARSIZEP0         => open,
      ARBURSTP0        => open,
      ARLOCKP0         => open,
      ARCACHEP0        => open,
      ARPROTP0         => open,
      ARVALIDP0        => open,
      ARREADYP0        => '0',
      -- READ DATA CHANNEL
      RIDP0            => (others => '0'),
      RDATAP0          => (others => '0'),
      RRESPP0          => (others => '0'),
      RLASTP0          => '0',
      RVALIDP0         => '0',
      RREADYP0         => open,
      ------------------------------------------------------------------------
      -- Debug Miscellaneous
      ------------------------------------------------------------------------
      DBGEN0           => '1',
      NIDEN0           => '1',
      EDBGRQ0          => '0',
      DBGACK0          => open,
      DBGRSTREQ0       => open,
      COMMRX0          => open,
      COMMTX0          => open,
      DBGNOPWRDWN      => open,
      DBGROMADDR       => (others => '0'),
      DBGROMADDRV      => '0',
      DBGSELFADDR0     => (others => '0'),
      DBGSELFADDRV0    => '0',
      ------------------------------------------------------------------------
      -- (Cortex R5 A.9)
      -- ETM Interface
      ------------------------------------------------------------------------
      nETMPORESET      => GLOBAL_RESETN,
      ETMASICCTL0      => open,
      ETMEN0           => open,
      ETMEXTOUT0       => open,
      ------------------------------------------------------------------------
      -- (Cortex R5 A.12)
      -- Validation
      ------------------------------------------------------------------------
      nVALIRQ0         => open,
      nVALFIQ0         => open,
      nVALRESET0       => open,
      ------------------------------------------------------------------------
      -- (Cortex R5 A.13)
      -- FPU
      ------------------------------------------------------------------------
      FPIXC0           => open,
      FPOFC0           => open,
      FPUFC0           => open,
      FPIOC0           => open,
      FPDZC0           => open,
      FPIDC0           => open,
      ------------------------------------------------------------------------
      -- Coresight TPIU-Lite
      ------------------------------------------------------------------------
      ------------------------------------------------------------------------
      -- (TPIU-Lite A.1)
      -- ATB Port
      ------------------------------------------------------------------------
      ATRESETn         => GLOBAL_RESETN,
      ------------------------------------------------------------------------
      -- (TPIU-Lite A.3)
      -- Trace Out Port
      ------------------------------------------------------------------------
      TRACECLK         => open,
      TRACEDATA        => open,
      TRACECTL         => open,
      ------------------------------------------------------------------------
      -- Coresight DAP-Lite
      ------------------------------------------------------------------------
      ------------------------------------------------------------------------
      -- (DAP-Lite A.1)
      -- CoreSight DAP Ports
      ------------------------------------------------------------------------
      PCLKSYS          => AXI_CLK,         -- System APB clock (typically HCLK)
      PCLKENSYS        => '1',             -- Enable term for PCLKSYS domain
      PRESETSYSn       => GLOBAL_RESETN,   -- Resets the APB interface connected to the system bus
      PADDRSYS         => (others => '0'), -- System APB address bus
      PENABLESYS       => '0',             -- System APB enable signal - indicates second and
                                           -- subsequent cycles of an APB transfer
      PRDATASYS        => open,            -- System APB write data bus
      PREADYSYS        => open,            -- System APB Ready signal
      PSELSYS          => '0',             -- System APB select
      PSLVERRSYS       => open,            -- System APB transfer error signal
      PWDATASYS        => (others => '0'), -- System APB Write data bus
      PWRITESYS        => '0',             -- System APB write access

      CDBGPWRUPACK     => dbgpwrupack,     --*nc Debug Power Domain power-up acknowledge
                                           -- (u_cs connect with CDBGPWRUPREQ)
      CDBGPWRUPREQ     => dbgpwrupreq,     --*nc Debug Power Domain power-up request
                                           -- (u_cs connect with CDBGPWRUPACK)
      CDBGRSTACK       => cdbgrstack,      -- Debug reset acknowledge from reset controller (??? top is low)
      CDBGRSTREQ       => cdbgrstreq,      --*nc Debug reset request to reset controller (u_cs nc)
      CSYSPWRUPACK     => syspwrupack,     --*nc System Power Domain power-up acknowledge(u_cs connect
                                           -- with CSYSPWRUPREQ)
      CSYSPWRUPREQ     => syspwrupreq,     --*nc System Power Domain power-up request    (u_cs connect
                                           -- with CSYSPWRUPACK)
      DEVICEEN         => '1',             -- Device enable
      JTAGNSW          => open,            -- Current TAP Mode of operation
      nPOTRST          => GLOBAL_RESETN,   -- JTAG SRSTn
      nTDOEN           => open,            -- Asynchronous JTAG TAP Data Out Enable
      nTRST            => JTAG_TRST_NI,    -- JTAG TRSTn
      SWCLKTCK         => s_jtag_tck_i,    -- JTAG TCK
      SWDITMS          => JTAG_TMS_I,      -- JTAG TMS
      SWDO             => open,            -- SW Data Out
      SWDOEN           => open,            -- SW Data Out Enable
      TDI              => JTAG_TDI_I,      -- JTAG TDI
      TDO              => JTAG_TDO_O       -- JTAG TDO
    );

   -- rebouclage des req/ack de pwr-up depuis le dap
   dbgpwrupack <= dbgpwrupreq;
   syspwrupack <= syspwrupreq;
   cdbgrstack  <= cdbgrstreq;


-- Initialize TCM with infinite loop trought R5 slave AXI port
AXI_M : entity work.AXI_MASTER
generic map (
  ADDR_LENGTH => 32,
  DATA_LENGTH => 64,
  NBR_INSTR => 77*2     -- THE NBR of INSTRUCTIONS in the file boot.txt (MUST be EVEN)
  )
port map(
  CLK         => AXI_CLK,
  RST_N       => GLOBAL_RESETN,
  CPUHALT     => nCPUHALT_ld,
  -- Write Adress channel
  M_AWADDRS0  => AWADDRS0,
  M_AWBURSTS0 => AWBURSTS0,
  M_AWCACHES0 => AWCACHES0,
  M_AWIDS0    => AWIDS0,
  M_AWLENS0   => AWLENS0,
  M_AWLOCKS0  => AWLOCKS0,
  M_AWPROTS0  => AWPROTS0,
  M_AWREADYS0 => AWREADYS0,
  M_AWSIZES0  => AWSIZES0,
  M_AWVALIDS0 => AWVALIDS0,
  -- Write Data Channel
  M_WDATAS0   => WDATAS0,
  M_WIDS0     => WIDS0,
  M_WLASTS0   => WLASTS0,
  M_WREADYS0  => WREADYS0,
  M_WSTRBS0   => WSTRBS0,
  M_WVALIDS0  => WVALIDS0,
  -- Write response channel
  M_BIDS0     => BIDS0,
  M_BREADYS0  => BREADYS0,
  M_BRESPS0   => BRESPS0,
  M_BVALIDS0  => BVALIDS0,
  -- Read Address Channel
  M_ARADDRS0  => ARADDRS0,
  M_ARBURSTS0 => ARBURSTS0,
  M_ARCACHES0 => ARCACHES0,
  M_ARIDS0    => ARIDS0,
  M_ARLENS0   => ARLENS0,
  M_ARLOCKS0  => ARLOCKS0,
  M_ARPROTS0  => ARPROTS0,
  M_ARREADYS0 => ARREADYS0,
  M_ARSIZES0  => ARSIZES0,
  M_ARVALIDS0 => ARVALIDS0,
  -- Read Data Channel
  M_RDATAS0   => RDATAS0,
  M_RIDS0     => RIDS0,
  M_RLASTS0   => RLASTS0,
  M_RREADYS0  => RREADYS0,
  M_RRESPS0   => RRESPS0,
  M_RVALIDS0  => RVALIDS0
);


end architecture rtl;
