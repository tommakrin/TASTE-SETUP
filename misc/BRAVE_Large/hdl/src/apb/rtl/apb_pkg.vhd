-------------------------------------------------------
--! @file       apb_pkg.vhd
--! @brief      APB type definitions
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


package ApbPkg is
  -------------------------------------------------------------------------------------------------
  --    APB MASTER CHANNEL
  -------------------------------------------------------------------------------------------------

  --! @brief APB master type definition
  type ApbMasterType is record
    paddr   : std_logic_vector(31 downto 0);  --! Address
    pprot   : std_logic_vector(2 downto 0);   --! Protection type
    psel    : std_logic;                      --! Slave select
    penable : std_logic;                      --! Enable control signal
    pwrite  : std_logic;                      --! Direction
    pwdata  : std_logic_vector(31 downto 0);  --! Write data bus
    pstrb   : std_logic_vector(3 downto 0);   --! Write strobes
  end record;

  --! @brief Default value of an `ApbMasterType` signal
  constant C_APB_MASTER_INIT : ApbMasterType := (
    paddr   => (others => '0'),
    pprot   => (others => '0'),
    psel    => '0',
    penable => '0',
    pwrite  => '0',
    pwdata  => (others => '0'),
    pstrb   => (others => '0')
  );

  --! @brief Array of `ApbMasterType` type definition
  type ApbMasterArray is array (natural range<>) of ApbMasterType;

  -------------------------------------------------------------------------------------------------
  --    APB SLAVE CHANNEL
  -------------------------------------------------------------------------------------------------

  --! @brief APB slave type definition
  type ApbSlaveType is record
    pready  : std_logic;                      --! Ready control signal
    prdata  : std_logic_vector(31 downto 0);  --! Read data bus
    pslverr : std_logic;                      --! Failure notification
  end record;

  --! @brief Default value of an `ApbSlaveType` signal
  constant C_APB_SLAVE_INIT : ApbSlaveType := (
    pready  => '0',
    prdata  => (others => '0'),
    pslverr => '0'
  );

  --! @brief Array of `ApbSlaveType` type definition
  type ApbSlaveArray is array (natural range<>) of ApbSlaveType;

  -------------------------------------------------------------------------------------------------
  --    APB CONSTANTS
  -------------------------------------------------------------------------------------------------

  --! @brief ABP `OKAY` response
  constant C_APB_OKAY   : std_logic := '0';
  --! @brief ABD `SLVERR` response
  constant C_APB_SLVERR : std_logic := '1';
end ApbPkg;
