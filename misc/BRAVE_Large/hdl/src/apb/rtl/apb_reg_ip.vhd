-------------------------------------------------------
--! @file       apb_reg_ip.vhd
--! @brief      APB bus and register bank
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

use work.ApbPkg.all;

entity apb_reg_ip is
  port (
    S_APB_ACLK    : in  std_logic; 
    S_APB_ARESETN : in  std_logic; 

    S_APB_PADDR   : in  std_logic_vector(31 downto 0);
    S_APB_PPROT   : in  std_logic_vector(2 downto 0);
    S_APB_PSEL    : in  std_logic;
    S_APB_PENABLE : in  std_logic;
    S_APB_PWRITE  : in  std_logic;
    S_APB_PWDATA  : in  std_logic_vector(31 downto 0);
    S_APB_PSTRB   : in  std_logic_vector(3 downto 0);
    S_APB_PREADY  : out std_logic;
    S_APB_PRDATA  : out std_logic_vector(31 downto 0);
    S_APB_PSLVERR : out std_logic 
  );
end entity apb_reg_ip;

architecture rtl of apb_reg_ip is
  signal s_apb_master : ApbMasterType;
  signal s_apb_slave  : ApbSlaveType;
begin
  apb_slave_if_inst : entity work.apb_slave_if
  port map (
    S_APB_PADDR   => S_APB_PADDR, 
    S_APB_PPROT   => S_APB_PPROT,
    S_APB_PSEL    => S_APB_PSEL,
    S_APB_PENABLE => S_APB_PENABLE,
    S_APB_PWRITE  => S_APB_PWRITE,
    S_APB_PWDATA  => S_APB_PWDATA,
    S_APB_PSTRB   => S_APB_PSTRB,  
    S_APB_PREADY  => S_APB_PREADY, 
    S_APB_PRDATA  => S_APB_PRDATA,
    S_APB_PSLVERR => S_APB_PSLVERR,

    s_apb_master  => s_apb_master,
    s_apb_slave   => s_apb_slave  
  );

  apb_reg_slave_inst : entity work.apb_reg_slave
  port map (
    clk_i        => S_APB_ACLK,   
    rst_ni       => S_APB_ARESETN, 

    s_apb_master => s_apb_master,
    s_apb_slave  => s_apb_slave 
  );
  
end architecture rtl; 
