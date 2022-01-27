-------------------------------------------------------
--! @file       apb_uart_ip.vhd
--! @brief      instanciate uart apb module (with custom type)
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

use work.ApbPkg.all;

entity uart_ip is
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
    --! IRQ
    IRQ            : out std_logic;
    --! UART 
    RX             : in  std_logic; 
    TX             : out std_logic 
  );
end uart_ip;

architecture wrapper of uart_ip is
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

    s_apb_master  => s_apb_master,
    s_apb_slave   => s_apb_slave
  );

  ----------------------------------------------------------------------------
  --                             IP LOGIC                                   --
  ----------------------------------------------------------------------------
  apb_uart_inst : entity work.apb_uart
  port map(
    pclk         => PCLK, 
    presetn      => PRESETN,

    s_apb_master => s_apb_master,
    s_apb_slave  => s_apb_slave,

    rxd          => RX, 
    txd          => TX, 

    irq_out      => IRQ
  );
end wrapper;
