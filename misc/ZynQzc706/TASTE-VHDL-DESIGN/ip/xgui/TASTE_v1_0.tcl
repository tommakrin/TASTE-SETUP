# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ADD_ALIGNEMENT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ADD_BUS_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ADD_R_START" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ADD_W_START" -parent ${Page_0}


}

proc update_PARAM_VALUE.ADD_ALIGNEMENT { PARAM_VALUE.ADD_ALIGNEMENT } {
	# Procedure called to update ADD_ALIGNEMENT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADD_ALIGNEMENT { PARAM_VALUE.ADD_ALIGNEMENT } {
	# Procedure called to validate ADD_ALIGNEMENT
	return true
}

proc update_PARAM_VALUE.ADD_BUS_SIZE { PARAM_VALUE.ADD_BUS_SIZE } {
	# Procedure called to update ADD_BUS_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADD_BUS_SIZE { PARAM_VALUE.ADD_BUS_SIZE } {
	# Procedure called to validate ADD_BUS_SIZE
	return true
}

proc update_PARAM_VALUE.ADD_R_START { PARAM_VALUE.ADD_R_START } {
	# Procedure called to update ADD_R_START when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADD_R_START { PARAM_VALUE.ADD_R_START } {
	# Procedure called to validate ADD_R_START
	return true
}

proc update_PARAM_VALUE.ADD_W_START { PARAM_VALUE.ADD_W_START } {
	# Procedure called to update ADD_W_START when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADD_W_START { PARAM_VALUE.ADD_W_START } {
	# Procedure called to validate ADD_W_START
	return true
}


proc update_MODELPARAM_VALUE.ADD_BUS_SIZE { MODELPARAM_VALUE.ADD_BUS_SIZE PARAM_VALUE.ADD_BUS_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADD_BUS_SIZE}] ${MODELPARAM_VALUE.ADD_BUS_SIZE}
}

proc update_MODELPARAM_VALUE.ADD_ALIGNEMENT { MODELPARAM_VALUE.ADD_ALIGNEMENT PARAM_VALUE.ADD_ALIGNEMENT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADD_ALIGNEMENT}] ${MODELPARAM_VALUE.ADD_ALIGNEMENT}
}

proc update_MODELPARAM_VALUE.ADD_W_START { MODELPARAM_VALUE.ADD_W_START PARAM_VALUE.ADD_W_START } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADD_W_START}] ${MODELPARAM_VALUE.ADD_W_START}
}

proc update_MODELPARAM_VALUE.ADD_R_START { MODELPARAM_VALUE.ADD_R_START PARAM_VALUE.ADD_R_START } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADD_R_START}] ${MODELPARAM_VALUE.ADD_R_START}
}

