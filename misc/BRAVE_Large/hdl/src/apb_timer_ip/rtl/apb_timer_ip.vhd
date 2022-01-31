-------------------------------------------------------
--! @file       apb_timer.vhd
--! @brief      Instantiate APB-wrapped timer IP
--! @author     T. Makryniotis (ESA)
--!
-------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ApbPkg.all;

entity apb_timer_ip is
  port (
    PCLK           : in std_logic;  --! APB clock
    PRESETN        : in std_logic;  --! Asynchronous reset, active low
    --! APB Interface 
    S_APB_PADDR    : in  std_logic_vector(31 downto 0);
    S_APB_PSEL     : in  std_logic;
    S_APB_PENABLE  : in  std_logic;
    S_APB_PWRITE   : in  std_logic;
    S_APB_PWDATA   : in  std_logic_vector(31 downto 0);
    S_APB_PSTRB    : in  std_logic_vector(3 downto 0);
    S_APB_PPROT    : in  std_logic_vector(2 downto 0);
    S_APB_PREADY   : out std_logic;
    S_APB_PRDATA   : out std_logic_vector(31 downto 0);
    S_APB_PSLVERR  : out std_logic;

    TIMER_IRQ_O    : out std_logic
  );
end apb_timer_ip;

architecture wrapper of apb_timer_ip is
  signal s_apb_master : ApbMasterType;
  signal s_apb_slave  : ApbSlaveType;
begin
  ----------------------------------------------------------------------------
  --                           SIGNAL MAPPING                               --
  ----------------------------------------------------------------------------
  --! APB interfaces
  apb_wrap: entity work.apb_slave_if
  port map(
    S_APB_PADDR   => S_APB_PADDR,
    S_APB_PSEL    => S_APB_PSEL,
    S_APB_PENABLE => S_APB_PENABLE,
    S_APB_PWRITE  => S_APB_PWRITE,
    S_APB_PWDATA  => S_APB_PWDATA,
    S_APB_PSTRB   => S_APB_PSTRB,
    S_APB_PPROT   => S_APB_PPROT,
    S_APB_PREADY  => S_APB_PREADY,
    S_APB_PRDATA  => S_APB_PRDATA,
    S_APB_PSLVERR => S_APB_PSLVERR,
    -- Internal signals
    s_apb_master  => s_apb_master,
    s_apb_slave   => s_apb_slave
  );

  ----------------------------------------------------------------------------
  --                             IP LOGIC                                   --
  ----------------------------------------------------------------------------
  apb_timer_inst : entity work.apb_timer
  port map(
    -- Pass to external signals
    pclk         => PCLK, 
    presetn      => PRESETN,
    -- Internal signals
    s_apb_master => s_apb_master,
    s_apb_slave  => s_apb_slave,

    IRQ_O  => TIMER_IRQ_O
  );
end wrapper;
