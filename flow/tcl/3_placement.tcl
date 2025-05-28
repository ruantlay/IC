# ==================== aes_secworks Placement 脚本 ====================
#openroad -no_splash -exit tcl/3_placement.tcl
# 设计名称与工艺平台
set DESIGN_NAME "aes_secworks"    ;# 设计名称
set ACTUAL_TOP_MODULE_NAME "aes"
set PLATFORM   "nangate45" ;# 工艺平台名称

# --- 路径配置 ---
set PLATFORM_DIR "./platforms/${PLATFORM}"
set RESULTS_DIR "./results/separated/placement" ;# 修改为placement目录
set SDC_FILE "./results/separated/floorplan/2_4_floorplan_pdn.sdc"

file mkdir $RESULTS_DIR

# === 技术文件配置 ===
set TECH_LEF    "${PLATFORM_DIR}/lef/NangateOpenCellLibrary.tech.lef"
set SC_LEF      "${PLATFORM_DIR}/lef/NangateOpenCellLibrary.macro.mod.lef"
set LIB_FILES   "${PLATFORM_DIR}/lib/NangateOpenCellLibrary_typical.lib"

# === 环境变量配置 ===
set ::env(CELL_PAD_IN_SITES_GLOBAL_PLACEMENT) 1 ;# 增大全局布局单元间距
set ::env(CELL_PAD_IN_SITES_DETAIL_PLACEMENT) 1 ;# 增大全局布局单元间距
set ::env(DONT_USE_CELLS) "TAPCELL_*"  ;# 禁止使用的单元类型
set ::env(SCRIPTS_DIR) "./scripts"
set ::env(REPORTS_DIR) "./reports"
set ::env(LIB_FILES) $LIB_FILES
set ::env(RESULTS_DIR) $RESULTS_DIR             ;# 结果目录
# === resize.tcl所需的环境变量 ===
set ::env(TIELO_CELL_AND_PORT) "LOGIC0_X1 Z"    ;# Tie低单元和端口（适用于Nangate45）
set ::env(TIEHI_CELL_AND_PORT) "LOGIC1_X1 Z"    ;# Tie高单元和端口（适用于Nangate45）
# 可选环境变量
set ::env(DONT_BUFFER_PORTS) 0                  ;# 0=缓冲IO端口, 1=不缓冲
set ::env(TIE_SEPARATION) 5                     ;# Tie单元间隔（以网格为单位）

# === 加载Floorplan结果 ===
read_lef $TECH_LEF
read_lef $SC_LEF
read_liberty $LIB_FILES
read_db "./results/separated/floorplan/2_4_floorplan_pdn.odb" ;# 输入Floorplan最终结果
read_sdc $SDC_FILE

# === 跳过IO的全局布局 ===
puts "\n===== 执行全局布局 ====="
global_placement -skip_io -density 0.6 \
                 -pad_left $::env(CELL_PAD_IN_SITES_GLOBAL_PLACEMENT) \
                 -pad_right $::env(CELL_PAD_IN_SITES_GLOBAL_PLACEMENT)

write_db $RESULTS_DIR/3_1_place_gp_skip_io.odb
write_def $RESULTS_DIR/3_1_place_gp_skip_io.def

# === IO单元布局 ===
puts "\n===== 放置IO单元 ====="
place_pins -hor_layers "metal5" -ver_layers "metal6"  -random -corner_avoidance 2 -min_distance 1
write_db $RESULTS_DIR/3_2_place_iop.odb
write_def $RESULTS_DIR/3_2_place_iop.def

# 加载平台RC配置文件（必须！）
source ${PLATFORM_DIR}/setRC.tcl

# === 带有IO的全局布局 ===
puts "\n===== 继续执行带有IO的全局布局 ====="
global_placement -density 0.7 -timing_driven \
                 -pad_left $::env(CELL_PAD_IN_SITES_GLOBAL_PLACEMENT) \
                 -pad_right $::env(CELL_PAD_IN_SITES_GLOBAL_PLACEMENT) 
                
write_db $RESULTS_DIR/3_3_place_gp.odb
write_def $RESULTS_DIR/3_3_place_gp.def
# 修复 buffer驱动能力
# repair_design -verbose

# === 时序优化（使用resize.tcl）===
puts "\n===== 使用resize.tcl执行时序优化 ====="
# 需要创建2_floorplan.sdc文件供resize.tcl使用
write_sdc $RESULTS_DIR/2_floorplan.sdc
# 调用resize.tcl脚本, 修复std单元驱动能力
# 注意：注释掉官方脚本 resize.tcl 中第4行避免odb重载错误！！
source $::env(SCRIPTS_DIR)/resize_customized.tcl

# === 额外的时序修复 ===
puts "\n===== 执行额外的时序修复 ====="
# 额外的时序修复步骤
estimate_parasitics -placement
repair_timing -setup_margin 0.3 

# === 详细布局优化 ===
puts "\n===== 执行详细布局 ====="
set_placement_padding -global \
                      -left $::env(CELL_PAD_IN_SITES_DETAIL_PLACEMENT) \
                      -right $::env(CELL_PAD_IN_SITES_DETAIL_PLACEMENT)
detailed_placement
optimize_mirroring

# === 保存结果 ===
write_db $RESULTS_DIR/3_5_place_dp.odb  ;# 详细布局结果
write_sdc $RESULTS_DIR/3_5_place_dp.sdc
write_def $RESULTS_DIR/3_5_place_dp.def

# === 生成报告 ===
report_units        ;# 报告单位设置
report_design_area  ;# 报告设计面积

# === 检查布局合法性 ===
puts "\n===== 布局合法性检查 ====="
check_placement -verbose

# === 报告时序指标 ===
puts "\n===== 关键路径时序报告 ====="
report_checks -path_delay min_max -fields {slew cap input_pins} -format full_clock_expanded

puts "Placement for ${DESIGN_NAME} completed!"\
