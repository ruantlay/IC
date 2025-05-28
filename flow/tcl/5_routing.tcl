# ==================== aes_secworks Routing 脚本 ====================
#openroad -no_splash -exit tcl/5_routing.tcl
# 设计名称与工艺平台
set DESIGN_NAME "aes_secworks"
set ACTUAL_TOP_MODULE_NAME "aes"
set PLATFORM "nangate45"

# --- 路径配置 ---
set PLATFORM_DIR "./platforms/${PLATFORM}"
set RESULTS_DIR "./results/separated/routing" ;# 修改为placement目录
set SDC_FILE "./results/separated/cts/4_cts.sdc"
file mkdir $RESULTS_DIR

# === 技术文件配置 ===
set TECH_LEF    "${PLATFORM_DIR}/lef/NangateOpenCellLibrary.tech.lef"
set SC_LEF      "${PLATFORM_DIR}/lef/NangateOpenCellLibrary.macro.mod.lef"
set LIB_FILES   "${PLATFORM_DIR}/lib/NangateOpenCellLibrary_typical.lib"
# === 环境变量配置 ===
set ::env(CELL_PAD_IN_SITES_DETAIL_PLACEMENT) 2 ;# 增大全局布局单元间距
set ::env(DONT_USE_CELLS) "TAPCELL_* FILLER_*"  ;# 禁止使用的单元类型
set ::env(SCRIPTS_DIR) "./scripts"
set ::env(REPORTS_DIR) "./reports"
set ::env(LIB_FILES) $LIB_FILES
set ::env(RESULTS_DIR) $RESULTS_DIR             ;# 结果目录
# === 核心环境变量 ===
set ::env(MIN_ROUTING_LAYER) metal2             ;# 最小布线层（Metal2）
set ::env(MAX_ROUTING_LAYER) metal10            ;# 最大布线层（Metal10）
set ::env(FILL_CELLS) "FILLCELL_X1 FILLCELL_X2 FILLCELL_X4 FILLCELL_X8 FILLCELL_X16 FILLCELL_X32"
set ::global_route_congestion_report "$::env(REPORTS_DIR)/congestion.rpt"
set ::env(ROUTING_LAYER_ADJUSTMENT) 0.4         ;# 添加这个参数供fast_route函数使用

# ==== 读取设计 ====
read_lef $TECH_LEF
read_lef $SC_LEF
read_liberty $LIB_FILES
read_db "./results/separated/cts/4_1_cts.odb"
read_sdc $SDC_FILE

# 加载平台RC配置文件（必须！）
source ${PLATFORM_DIR}/setRC.tcl
# 导入util.tcl
source $::env(SCRIPTS_DIR)/util.tcl

# ==== 全局布线 ====
puts "=== 开始全局布线 ==="

fast_route

# 执行引脚布线访问
pin_access -bottom_routing_layer $::env(MIN_ROUTING_LAYER) \
           -top_routing_layer $::env(MAX_ROUTING_LAYER)

# 执行全局布线
puts "执行全局布线..."
global_route -congestion_report_file $::global_route_congestion_report

set_placement_padding -global \
                      -left $::env(CELL_PAD_IN_SITES_DETAIL_PLACEMENT) \
                      -right $::env(CELL_PAD_IN_SITES_DETAIL_PLACEMENT)

# 设置传播时钟
set_propagated_clock [all_clocks]
estimate_parasitics -global_routing

set_dont_use $::env(DONT_USE_CELLS)

# Repair design using global route parasitics
repair_design_helper ;# 直接调用util.tcl中repair_design_helper函数

# Running DPL to fix overlapped instances
# Run to get modified net by DPL
global_route -start_incremental
detailed_placement
# Route only the modified net by DPL
global_route -end_incremental \
             -congestion_report_file $::env(REPORTS_DIR)/congestion_post_repair_design.rpt

# Repair timing using global route parasitics
puts "Repair setup and hold violations..."
estimate_parasitics -global_routing
repair_timing_helper ;# 直接调用util.tcl中repair_timing_helper函数

# Running DPL to fix overlapped instances
# Run to get modified net by DPL
global_route -start_incremental
detailed_placement
# Route only the modified net by DPL
global_route -end_incremental \
             -congestion_report_file $::env(REPORTS_DIR)/congestion_post_repair_timing.rpt

# 保存全局布线结果
# write_guides $RESULTS_DIR/route.guide
write_def $RESULTS_DIR/5_1_grt.def
write_db $RESULTS_DIR/5_1_grt.odb

# ==== 详细布线 ====
puts "=== 开始详细布线 === "
set detailed_route_args "-output_drc $::env(REPORTS_DIR)/route_drc.rpt"
detailed_route {*}$detailed_route_args

# # 简单检查天线效应并修复（仅一次迭代）
# repair_antennas
# detailed_route {*}$detailed_route_args

# 保存详细布线结果
write_def $RESULTS_DIR/5_2_route.def
write_db $RESULTS_DIR/5_2_route.odb

# # ==== 填充单元插入 ====
puts "=== 开始填充单元插入 === "
filler_placement $::env(FILL_CELLS)
write_def $RESULTS_DIR/5_3_fillcell.def
write_db $RESULTS_DIR/5_3_fillcell.odb

puts "Routing阶段完成！"