-------------------------------------------------------
--! @file       apb_master_if.vhd
--! @brief      APB wrapper for custom APB type
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

entity apb_master_if is
  port (
    M_APB_PADDR   : out std_logic_vector(31 downto 0);
    M_APB_PPROT   : out std_logic_vector(2 downto 0);
    M_APB_PSEL    : out std_logic;
    M_APB_PENABLE : out std_logic;
    M_APB_PWRITE  : out std_logic;
    M_APB_PWDATA  : out std_logic_vector(31 downto 0);
    M_APB_PSTRB   : out std_logic_vector(3 downto 0);
    M_APB_PREADY  : in  std_logic;
    M_APB_PRDATA  : in  std_logic_vector(31 downto 0);
    M_APB_PSLVERR : in  std_logic;

    m_apb_master  : in  ApbMasterType;
    m_apb_slave   : out ApbSlaveType
  );
end entity apb_master_if;

architecture wrapper of apb_master_if is
begin
  M_APB_PADDR   <= m_apb_master.paddr;
  M_APB_PPROT   <= m_apb_master.pprot;
  M_APB_PSEL    <= m_apb_master.psel;
  M_APB_PENABLE <= m_apb_master.penable;
  M_APB_PWRITE  <= m_apb_master.pwrite;
  M_APB_PWDATA  <= m_apb_master.pwdata;
  M_APB_PSTRB   <= m_apb_master.pstrb;

  m_apb_slave.pready  <= M_APB_PREADY;
  m_apb_slave.prdata  <= M_APB_PRDATA;
  m_apb_slave.pslverr <= M_APB_PSLVERR;
end architecture wrapper; 
