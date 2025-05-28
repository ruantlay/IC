# aes_secwooks Floorplan Script
# 设计和工艺平台名称
set DESIGN_NAME "aes_secworks"    ;# 设计名称
set ACTUAL_TOP_MODULE_NAME "aes"
set PLATFORM    "nangate45" ;# 工艺平台名称

# --- 路径配置 ---
set PLATFORM_DIR "./platforms/${PLATFORM}"
set SYNTH_VERILOG_FILE "./results/separated/synth/aes_synth.v"
set SDC_FILE "./designs/nangate45/aes_secworks/constraint.sdc"
set RESULTS_DIR "./results/separated/floorplan"
file mkdir $RESULTS_DIR

# === 技术文件配置 ===
set TECH_LEF    "${PLATFORM_DIR}/lef/NangateOpenCellLibrary.tech.lef"
set SC_LEF      "${PLATFORM_DIR}/lef/NangateOpenCellLibrary.macro.mod.lef"
set LIB_FILES   "${PLATFORM_DIR}/lib/NangateOpenCellLibrary_typical.lib"
set SITE_NAME   "FreePDK45_38x28_10R_NP_162NW_34O"
set ::env(SCRIPTS_DIR) "./scripts"
set ::env(REPORTS_DIR) "./reports"
set ::env(LIB_FILES) $LIB_FILES
set ::env(RESULTS_DIR) $RESULTS_DIR             ;# 结果目录
# 设置Tapcell的单元名称（根据工艺库实际名称调整）
set ::env(TAP_CELL_NAME) "TAPCELL_X1"

# === 初始化设计 ===
read_lef $TECH_LEF
read_lef $SC_LEF
read_liberty $LIB_FILES

# 加载网表和约束
read_verilog $SYNTH_VERILOG_FILE
link_design $ACTUAL_TOP_MODULE_NAME
read_sdc $SDC_FILE


# ======================== 2_1_floorplan.tcl =========================
# 初始化Floorplan阶段
# 依赖：1_synth.v, 1_synth.sdc, LEF文件等
# 生成：2_1_floorplan.odb, 2_1_floorplan.sdc

# === Floorplan初始化 ===
puts "=== Floorplan初始化 ==="
initialize_floorplan \
  -utilization 30 \
  -aspect_ratio 1.0 \
  -core_space 2.0 \
  -site $SITE_NAME

# 初步修复修复时序
repair_timing -verbose -setup_margin 0

# 生成电源轨道
source $PLATFORM_DIR/make_tracks.tcl
# 保存阶段结果
write_db $RESULTS_DIR/2_1_floorplan.odb
write_sdc $RESULTS_DIR/2_1_floorplan.sdc
write_def $RESULTS_DIR/2_1_floorplan.def

# ======================== 2_2_floorplan_macro.tcl ====================
# 宏单元放置阶段
# 依赖：2_1_floorplan.odb
# 生成：2_2_floorplan_macro.odb
# 执行宏布局（示例：手动指定宏坐标）
# place_macro -name "AES_CORE" -llx 100 -lly 100 -urx 200 -ury 200
# 保存结果
# write_db $::env(RESULTS_DIR)/2_2_floorplan_macro.odb

# ======================== 2_3_floorplan_tapcell.tcl =================
# Tapcell插入阶段
# 插入Tapcell（从环境变量获取单元名）
# insert_tapcell \
#   -tapcell_master $::env(TAP_CELL_NAME) \
#   -distance 20
puts "=== Tapcell插入阶段 ==="
source ${PLATFORM_DIR}/tapcell.tcl
# 保存结果
write_db $RESULTS_DIR/2_3_floorplan_tapcell.odb
write_def $RESULTS_DIR/2_3_floorplan_tapcell.def

# ======================== 2_4_floorplan_pdn.tcl =====================
# PDN生成阶段
# 依赖：2_3_floorplan_tapcell.odb
# 生成：2_4_floorplan_pdn.odb
puts "=== PDN生成阶段 ==="
# === 电源网络配置 ===
source ${PLATFORM_DIR}/grid_strategy-M1-M4-M7.tcl
pdngen

# Check all supply nets
set block [ord::get_db_block]
foreach net [$block getNets] {
    set type [$net getSigType]
}

# === 保存结果 ===
write_db $RESULTS_DIR/2_4_floorplan_pdn.odb
write_sdc $RESULTS_DIR/2_4_floorplan_pdn.sdc
write_def $RESULTS_DIR/2_4_floorplan_pdn.def

# === 生成报告 ===
report_design_area
report_design_area_metrics
puts "Floorplan completed for ${DESIGN_NAME}"
#openroad  -exit ./tcl/2_floorplan_to_pdn.tcl