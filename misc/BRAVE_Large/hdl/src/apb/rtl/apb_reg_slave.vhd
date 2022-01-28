-------------------------------------------------------
--! @file       apb_reg_slave.vhd
--! @brief      Simple APB register bank
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

use work.ApbPkg.all;

entity apb_reg_slave is
  port (
    clk_i  : in std_logic;
    rst_ni : in std_logic;

    s_apb_master : in ApbMasterType;
    s_apb_slave  : out ApbSlaveType
  );
end apb_reg_slave;

architecture rtl of apb_reg_slave is
  subtype Reg32 is std_logic_vector(31 downto 0);
  type Reg32Array is array (natural range <>) of Reg32;

  type RegType is record
    regs      : Reg32Array(0 to 3);
    apb_slave : ApbSlaveType;
    idx       : natural range 0 to 3;
  end record;

  constant C_REG_INIT : RegType := (
    regs      => (others => (others => '0')),
    apb_slave => C_APB_SLAVE_INIT,
    idx       => 0
  );

  signal r   : RegType := C_REG_INIT;
  signal rin : RegType;
begin
  process (r, s_apb_master)
    variable v : RegType;
  begin
    v := r;

    if (s_apb_master.psel) = '1' then
      v.idx := to_integer(unsigned(s_apb_master.paddr(3 downto 2)));
    end if;

    -- write transaction
    if (s_apb_master.psel and (s_apb_master.pwrite and s_apb_master.penable)) = '1' then
      v.apb_slave.pready := '1';
      v.regs(r.idx) := s_apb_master.pwdata;
    end if;

    -- read transaction
    if (s_apb_master.psel and not s_apb_master.pwrite) = '1' then
      v.apb_slave.pready := '1';
      v.apb_slave.prdata := r.regs(r.idx);
    end if;

    -- handshake
    if (s_apb_master.penable and r.apb_slave.pready) = '1' then
      v.apb_slave.pready := '0';
    end if;

    rin <= v;
  end process;

  process (rst_ni, clk_i)
  begin
    if rst_ni = '0' then
      r <= C_REG_INIT;
    elsif rising_edge(clk_i) then
      r <= rin;
    end if;
  end process;

  s_apb_slave <= r.apb_slave;
end rtl;
