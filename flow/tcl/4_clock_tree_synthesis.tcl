# ==================== aes_secworks 时钟树综合脚本 ====================
#openroad -no_splash -exit tcl/4_clock_tree_synthesis.tcl
# 设计名称与工艺平台
set DESIGN_NAME "aes_secworks"
set ACTUAL_TOP_MODULE_NAME "aes"
set PLATFORM "nangate45"

# --- 路径配置 ---
set PLATFORM_DIR "./platforms/${PLATFORM}"
set RESULTS_DIR "./results/separated/cts" ;# 修改为CTS专用目录
set SDC_FILE "./results/separated/placement/3_5_place_dp.sdc"
set SCRIPTS_DIR "./scripts"
file mkdir $RESULTS_DIR

# === 技术文件配置 ===
set TECH_LEF    "${PLATFORM_DIR}/lef/NangateOpenCellLibrary.tech.lef"
set SC_LEF      "${PLATFORM_DIR}/lef/NangateOpenCellLibrary.macro.mod.lef"
set LIB_FILES   "${PLATFORM_DIR}/lib/NangateOpenCellLibrary_typical.lib"

# === 环境变量配置 ===
set ::env(DONT_USE_CELLS) "TAPCELL_* FILLER_*"
set ::env(CELL_PAD_IN_SITES_DETAIL_PLACEMENT) 2
set ::env(CTS_CLUSTER_DIAMETER) 100  ;# 时钟sink最大间距(µm)
set ::env(CTS_BUF_DISTANCE) 50       ;# 缓冲器间距
set ::env(SETUP_SLACK_MARGIN) 0.1    ;# 设置时序修复参数
set ::env(HOLD_SLACK_MARGIN) 0.05    ;# 设置时序修复参数
set ::env(SCRIPTS_DIR) "./scripts"
set ::env(REPORTS_DIR) "./reports"

# === 加载布局结果 ===
read_lef $TECH_LEF
read_lef $SC_LEF
read_liberty $LIB_FILES
read_db "./results/separated/placement/3_5_place_dp.odb"
read_sdc $SDC_FILE
# 加载平台RC配置文件（必须！）
source ${PLATFORM_DIR}/setRC.tcl

# === 关键步骤1: 修复时钟反相器 ===
puts "\n===== 修复时钟反相器 ====="
repair_clock_inverters

# === 关键步骤2: 时钟树综合 ===
puts "\n===== 执行时钟树综合 ====="
clock_tree_synthesis -sink_clustering_enable \
                     -distance_between_buffers $::env(CTS_BUF_DISTANCE) \
                     -balance_levels; # 平衡时钟树层级
# -sink_clustering_max_diameter $::env(CTS_CLUSTER_DIAMETER) 

# === 设置传播时钟 ===
set_propagated_clock [all_clocks]

# === 关键步骤3: 修复时钟网络 ===
puts "\n===== 修复时钟网络 ====="
repair_clock_nets

# === 布局合法性修复 ===
puts "\n===== 执行布局合法性修复 ====="
set_placement_padding -global \
                      -left $::env(CELL_PAD_IN_SITES_DETAIL_PLACEMENT) \
                      -right $::env(CELL_PAD_IN_SITES_DETAIL_PLACEMENT)
# 分阶段详细布局
detailed_placement 

# === 寄生参数估算 ===
estimate_parasitics -placement

# === 时序修复 ===
puts "\n===== 时序修复 ====="
source "$SCRIPTS_DIR/util.tcl"
# 替换直接调用repair_timing，使用repair_timing_helper函数
repair_timing_helper
# 注意：repair_timing_helper会根据环境变量自动设置参数

# === 执行时序修复后的详细布局 ===
puts "\n===== 时序修复后详细布局优化 ====="
detailed_placement

# === 保存结果 ===
write_db $RESULTS_DIR/4_1_cts.odb
write_sdc $RESULTS_DIR/4_cts.sdc

# === 生成报告 ===
puts "\n===== 时钟树质量报告 ====="
# 修正：使用官方支持的时钟报告命令
report_checks -path_delay min_max -fields {slew cap input_pins}  ;# 时序检查

puts "\n===== 布局合法性检查 ====="
check_placement -verbose

puts "Clock Tree Synthesis for ${DESIGN_NAME} completed!"