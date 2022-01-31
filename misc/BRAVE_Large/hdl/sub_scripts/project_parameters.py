def commun_parameters(p,option):
    print("No commun parameters")
    #p.addParameters({'',''})

def NG_MEDIUM_parameters(p,option):
    print("No NG-MEDIUM parameters")
    #p.addParameters({'',''})

def NG_LARGE_parameters(p,option):
    print("No NG-LARGE parameters")
    #p.addParameters({'',''})

def NG_ULTRA_parameters(p,option):
    print("No NG-ULTRA parameters")
    #p.addParameters({'',''})

def commun_options(p,option):
    p.setOptions({'DefaultFSMEncoding': 'OneHot',
        'DefaultRAMMapping': 'AUTO',
        'DefaultROMMapping': 'AUTO',
        'DisableAssertionChecking': 'No',
        'DisableKeepPortOrdering': 'No',
        'DisableRAMAlternateForm': 'No',
        'DisableROMFullLutRecognition': 'No',
        'IgnoreRAMFlashClear': 'No',
        'ManageUnconnectedOutputs': 'Ground',
        'ManageUnconnectedSignals': 'Ground',
        'MaxRegisterCount': '3700',
        'DisableAdderBasicMerge': 'No',
        'DisableAdderTreeOptimization': 'No',
        'DisableAdderTrivialRemoval': 'No',
        'DisableDSPAluOperator': 'No',
        'DisableDSPFullRecognition': 'No',
        'DisableDSPPreOperator': 'No',
        'DisableDSPRegisters': 'No',
        'DisableLoadAndResetBypass': 'No',
        'DisableRAMRegisters': 'No',
        'ManageAsynchronousReadPort': 'No',
        'ManageUninitializedLoops': 'No',
        'MappingEffort': 'High',
        'OptimizedMux': 'Yes',
#       'TimingDriven': 'No',   # Not available in NXMAP v3.0.9
#       'UseSynthesisRetiming': 'No',       # Not available in NXMAP v3.0.9
        'VariantAwareSynthesis': 'Yes',
        'RoutingEffort': 'High'})

#these lines are supposed to initialize AXI master ram but it doesn't seem to work??
# it is replaced by in vhdl intialization : see axi/rtl/axi_master.vhd       
    p.addMappingDirective('getModels(.*mem_axi_master)', 'ROM', 'RAM') 
    p.addMemoryInitialization('getModels(.*mem_axi_master)', 'NX', '../src/axi/rtl/Loop-zero.mem')  
    
            
    p.createClock('getPort(EXT_CLK_I)','clk',40000)
    #p.addFalsePath('getPort(EXT_RST_NI)', 'getRegisters(r5_wrapper_inst|delay_rst_q_reg)')
   # p.createClock('getClockNet(axi_clk)','axi_clk', 33333)
    p.setInputDelay('getClock(clk)','rise', 3000, 10000, 'getPorts(SRAM_DATA\[[0-15]\])')
    p.setOutputDelay('getClock(clk)','rise', 3000, 10000, 'getPorts(SRAM_ADDR\[[0-15]\])')
    p.setOutputDelay('getClock(clk)','rise', 3000, 10000, 'getPorts(SRAM_BE_N\[[0-1]\])')
    p.setOutputDelay('getClock(clk)','rise', 3000, 10000, 'getPort(SRAM_OE_N)')
    p.setOutputDelay('getClock(clk)','rise', 3000, 10000, 'getPort(SRAM_WE_N)')
    p.setOutputDelay('getClock(clk)','rise', 3000, 10000, 'getPort(SRAM_CE_N)')

def NG_MEDIUM_options(p,option):
    print('No specific variant options')

def NG_LARGE_options(p,option):
    print('No specific variant options')

def NG_ULTRA_options(p,option):
    print('No specific variant options')
