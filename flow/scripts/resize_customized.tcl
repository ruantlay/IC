puts "=== 开始执行 resize_customized.tcl 进行时序优化 ==="

# 禁止 ODB 重载，避免流程出错
# read_db $result_file ; # 注释掉这一行！ODB 已在前面加载

# 设置默认库中的 buffer 和驱动单元
rsz::set_buffer_cells { BUFX2 BUFX4 }
set_driver_cells [get_lib_cells *DFF*]

# 设置目标延迟范围（你可以根据实际设计调整）
set max_delay 1.0

# resize 修复 setup violation
repair_design -setup -max_delay $max_delay

# resize 修复 hold violation（如果有）
repair_design -hold -max_delay $max_delay

# 报告当前时序
report_checks -path_delay min_max -slack_less_than 0 -digits 4

puts "=== resize_customized.tcl 时序优化完成 ==="
