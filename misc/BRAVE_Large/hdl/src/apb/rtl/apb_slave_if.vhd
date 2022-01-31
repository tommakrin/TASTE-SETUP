-------------------------------------------------------
--! @file       apb_slave_if.vhd
--! @brief      Wrapper for custom APB slave type
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

entity apb_slave_if is
  port (
    S_APB_PADDR   : in  std_logic_vector(31 downto 0);
    S_APB_PPROT   : in  std_logic_vector(2 downto 0);
    S_APB_PSEL    : in  std_logic;
    S_APB_PENABLE : in  std_logic;
    S_APB_PWRITE  : in  std_logic;
    S_APB_PWDATA  : in  std_logic_vector(31 downto 0);
    S_APB_PSTRB   : in  std_logic_vector(3 downto 0);
    S_APB_PREADY  : out std_logic;
    S_APB_PRDATA  : out std_logic_vector(31 downto 0);
    S_APB_PSLVERR : out std_logic;

    s_apb_master : out ApbMasterType;
    s_apb_slave  : in  ApbSlaveType
  );
end entity apb_slave_if;

architecture wrapper of apb_slave_if is
begin
    s_apb_master.paddr   <= S_APB_PADDR;
    s_apb_master.pprot   <= S_APB_PPROT;
    s_apb_master.psel    <= S_APB_PSEL;
    s_apb_master.penable <= S_APB_PENABLE;
    s_apb_master.pwrite  <= S_APB_PWRITE;
    s_apb_master.pwdata  <= S_APB_PWDATA;
    s_apb_master.pstrb   <= S_APB_PSTRB;

    S_APB_PREADY  <= s_apb_slave.pready;
    S_APB_PRDATA  <= s_apb_slave.prdata;
    S_APB_PSLVERR <= s_apb_slave.pslverr;
end architecture wrapper; 
