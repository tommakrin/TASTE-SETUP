-------------------------------------------------------
--! @file       addr_decoder_pkg.vhd
--! @brief      Address package definition for AXI
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

package AddrDecoderPkg is
  --! Address range type definition (ranges are inclusive)
  type AddrRangeType is record
    --! start of address range
    start_addr : std_logic_vector(31 downto 0);
    --! end of address range (inclusive)
    end_addr   : std_logic_vector(31 downto 0);
  end record;

  --! Address mapping table type definition
  type AddrMappingTable is array (natural range <>) of AddrRangeType;

  --! Default Address mapping table
  constant C_ADDR_MAPPING_TABLE_DEFAULT : AddrMappingTable(0 to 7) := (
    0 => (start_addr => X"1000_0000", end_addr => X"1FFF_FFFF"),
    1 => (start_addr => X"2000_0000", end_addr => X"2FFF_FFFF"),
    2 => (start_addr => X"3000_0000", end_addr => X"3FFF_FFFF"),
    3 => (start_addr => X"4000_0000", end_addr => X"4FFF_FFFF"),
    4 => (start_addr => X"5000_0000", end_addr => X"5FFF_FFFF"),
    5 => (start_addr => X"6000_0000", end_addr => X"6FFF_FFFF"),
    6 => (start_addr => X"7000_0000", end_addr => X"7FFF_FFFF"),
    7 => (start_addr => X"8000_0000", end_addr => X"8FFF_FFFF")
  );

  procedure addr_map_decode(
    --! Address range mapping table
    constant addr_map : AddrMappingTable;
    --! MSB offset
    constant addr_msb : natural;
    --! LSB offset
    constant addr_lsb : natural;
    --! Address to decode
    addr : in std_logic_vector(31 downto 0);
    --! Index value result, when the address is not mapped, `addr_map'length` is returned
    variable index : out natural
  );
end package AddrDecoderPkg;

package body AddrDecoderPkg is
  procedure addr_map_decode(
    --! Address range mapping table
    constant addr_map : AddrMappingTable;
    --! MSB offset
    constant addr_msb : natural;
    --! LSB offset
    constant addr_lsb : natural;
    --! Address to decode
    addr : in std_logic_vector(31 downto 0);
    --! Index value result, when the address is not mapped, `addr_map'length` is returned
    variable index : out natural)
  is
    variable laddr, saddr, haddr : std_logic_vector(addr_msb-addr_lsb downto 0);
  begin
    index := addr_map'length;
    for i in addr_map'range loop
      laddr := addr_map(i).start_addr(addr_msb downto addr_lsb);
      saddr := addr(addr_msb downto addr_lsb);
      haddr := addr_map(i).end_addr(addr_msb downto addr_lsb);
      if unsigned(laddr) <= unsigned(saddr) and unsigned(saddr) <= unsigned(haddr) then
        index := i;
      end if;
    end loop;
  end procedure addr_map_decode;
end package body AddrDecoderPkg;
