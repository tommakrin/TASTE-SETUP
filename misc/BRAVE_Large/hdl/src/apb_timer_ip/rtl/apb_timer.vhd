-------------------------------------------------------
--! @file       apb_taste.vhd
--! @brief      APB Timer IP 
--! @author     Thomas Makryniotis (ESA) 
--!
--!-----------------------------------------------------------------------------------------------
--! @details  
--! 
-------------------------------------------------------------------------------------------------
--
-- Control Register
-- +---+---+-----+-----+-----+-----+-----+----+
-- | 7 | 6 |  5  |  4  |  3  |  2  |  1  |  0 |
-- +---+---+-----+-----+-----+-----+-----+----+
-- | - | - |  -  |     |     |  -  | RST | En |
-- +---+---+-----+-----+-----+-----+-----+----+
--
-- 0: Enable timer
-- 1: Reset
-- 2,3,4,5,6,7: Not used
-------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ApbPkg.all;

entity apb_timer is
  port (
    pclk : in std_logic;
    presetn : in std_logic;

    s_apb_master : in ApbMasterType;
    s_apb_slave : out ApbSlaveType;

    IRQ_O : out std_logic
  );
end apb_timer;

architecture arch of apb_timer is

  -- Register Index
  constant CTRL : integer := 1; -- Control register - Read/Write
  constant CVALUE : integer := 2; -- Current Counter value - Read only

  -- Counter
  signal control_register_d, control_register_q : std_logic_vector(7 downto 0);

  --! Constants to create the 100 Hz frequency needed:
  --! Formula is: (10 MHz / 100 Hz * 50% duty cycle)
  --! So for 100 Hz: 10,000,000 / 100 * 0.5 = 50,000
  constant c_CNT_100HZ : natural := 50_000;
  constant CLK_DEC_FACTOR : natural := 2 * c_CNT_100HZ + 1;

  signal EN, IRQ : std_logic;

  signal counter : unsigned(31 downto 0);
  signal clk_100Hz : std_logic;
  signal reset : std_logic;

begin
  reset <= (not presetn) or control_register_q(1);
  EN <= control_register_q(0);

  -- Split the following process into two processes, one solely for the registers
  -- and one for the combinational logic
  proc_apb_access : process (all)
  begin

    if presetn = '0' then
      s_apb_slave <= C_APB_SLAVE_INIT;
      control_register_d <= (others => '0');

    elsif rising_edge(pclk) then

      -- Begin default assignments
      control_register_d <= control_register_q;

      s_apb_slave.pready <= '0';
      s_apb_slave.pslverr <= '0';
      s_apb_slave.prdata <= (others => '0');

      if (s_apb_master.psel and s_apb_master.penable) then
        s_apb_slave.pready <= '1';
        -- Write
        if (s_apb_master.pwrite) = '1' then
          case to_integer(unsigned(s_apb_master.paddr(5 downto 2))) is
            when CTRL =>
              control_register_d <= s_apb_master.pwdata(7 downto 0);
            when others =>
              s_apb_slave.pslverr <= '1';
          end case;
        else
          --Read
          case to_integer(unsigned(s_apb_master.paddr(5 downto 2))) is
            when CTRL =>
              s_apb_slave.prdata <= X"000000" & control_register_q;
            when CVALUE =>
              s_apb_slave.prdata <= std_logic_vector(counter);
            when others =>
              s_apb_slave.pslverr <= '1';
          end case;
        end if;
      end if;
    end if;
  end process;

  --! 100Hz clock

  cd_proc : process (reset, pclk)
  begin
    if (reset = '1') then
      counter <= (others => '0');
      clk_100Hz <= '1';
    elsif rising_edge(pclk) then
      counter <= counter + 1;
      if (counter = c_CNT_100HZ) then
        counter <= (others => '0');
        clk_100Hz <= clk_100Hz xor '1';
      end if;
    end if;
  end process;

  --! Simple interrupt logic

  process (reset, pclk)
  begin
    if (reset = '1') then
      IRQ <= '0';
    elsif (rising_edge(pclk)) then
      IRQ <= '0';
      if (EN = '1' and counter = 0) then
        IRQ <= '1';
      end if;
    end if;
  end process;

  --! Control register process

  ctrl_reg_proc : process (presetn, pclk)
  begin
    if presetn = '0' then
      control_register_q <= (others => '0');
    elsif rising_edge(pclk) then
      control_register_q <= control_register_d;
      -- if (control_register_q(2) = '1') then
      --   control_register_q(2) <= '0'; --After we clear the interrupt, reset the bit back to 0
      -- end if;
    end if;
  end process;

  IRQ_O <= IRQ;

end arch;