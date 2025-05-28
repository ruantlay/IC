export PLATFORM               = nangate45

export DESIGN_NAME            = aes
export DESIGN_NICKNAME        = aes_secworks

export VERILOG_FILES    = $(sort $(wildcard ./designs/nangate45/src/$(DESIGN_NICKNAME)/*.v))
export SDC_FILE         = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

export CORE_UTILIZATION = 40
export PLACE_DENSITY    = 0.60

export TNS_END_PERCENT  = 100
