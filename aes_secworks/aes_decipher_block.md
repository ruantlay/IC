
# Entity: aes_decipher_block 
- **File**: aes_decipher_block.v

## Diagram
![Diagram](aes_decipher_block.svg "Diagram")
## Ports

| Port name | Direction | Type           | Description |
| --------- | --------- | -------------- | ----------- |
| clk       | input     | wire           |             |
| reset_n   | input     | wire           |             |
| next      | input     | wire           |             |
| keylen    | input     | wire           |             |
| round     | output    | wire [3 : 0]   |             |
| round_key | input     | wire [127 : 0] |             |
| block     | input     | wire [127 : 0] |             |
| new_block | output    | wire [127 : 0] |             |
| ready     | output    | wire           |             |

## Signals

| Name          | Type          | Description |
| ------------- | ------------- | ----------- |
| sword_ctr_reg | reg [1 : 0]   |             |
| sword_ctr_new | reg [1 : 0]   |             |
| sword_ctr_we  | reg           |             |
| sword_ctr_inc | reg           |             |
| sword_ctr_rst | reg           |             |
| round_ctr_reg | reg [3 : 0]   |             |
| round_ctr_new | reg [3 : 0]   |             |
| round_ctr_we  | reg           |             |
| round_ctr_set | reg           |             |
| round_ctr_dec | reg           |             |
| block_new     | reg [127 : 0] |             |
| block_w0_reg  | reg [31 : 0]  |             |
| block_w1_reg  | reg [31 : 0]  |             |
| block_w2_reg  | reg [31 : 0]  |             |
| block_w3_reg  | reg [31 : 0]  |             |
| block_w0_we   | reg           |             |
| block_w1_we   | reg           |             |
| block_w2_we   | reg           |             |
| block_w3_we   | reg           |             |
| ready_reg     | reg           |             |
| ready_new     | reg           |             |
| ready_we      | reg           |             |
| dec_ctrl_reg  | reg [2 : 0]   |             |
| dec_ctrl_new  | reg [2 : 0]   |             |
| dec_ctrl_we   | reg           |             |
| tmp_sboxw     | reg [31 : 0]  |             |
| new_sboxw     | wire [31 : 0] |             |
| update_type   | reg [2 : 0]   |             |

## Constants

| Name            | Type | Value | Description |
| --------------- | ---- | ----- | ----------- |
| AES_128_BIT_KEY |      | 1'h0  |             |
| AES_256_BIT_KEY |      | 1'h1  |             |
| AES128_ROUNDS   |      | 4'ha  |             |
| AES256_ROUNDS   |      | 4'he  |             |
| NO_UPDATE       |      | 3'h0  |             |
| INIT_UPDATE     |      | 3'h1  |             |
| SBOX_UPDATE     |      | 3'h2  |             |
| MAIN_UPDATE     |      | 3'h3  |             |
| FINAL_UPDATE    |      | 3'h4  |             |
| CTRL_IDLE       |      | 3'h0  |             |
| CTRL_INIT       |      | 3'h1  |             |
| CTRL_SBOX       |      | 3'h2  |             |
| CTRL_MAIN       |      | 3'h3  |             |
| CTRL_FINAL      |      | 3'h4  |             |

## Functions
- gm2 <font id="function_arguments">(input [7 : 0] op)</font> <font id="function_return">return ([7 : 0])</font>
- gm3 <font id="function_arguments">(input [7 : 0] op)</font> <font id="function_return">return ([7 : 0])</font>
- gm4 <font id="function_arguments">(input [7 : 0] op)</font> <font id="function_return">return ([7 : 0])</font>
- gm8 <font id="function_arguments">(input [7 : 0] op)</font> <font id="function_return">return ([7 : 0])</font>
- gm09 <font id="function_arguments">(input [7 : 0] op)</font> <font id="function_return">return ([7 : 0])</font>
- gm11 <font id="function_arguments">(input [7 : 0] op)</font> <font id="function_return">return ([7 : 0])</font>
- gm13 <font id="function_arguments">(input [7 : 0] op)</font> <font id="function_return">return ([7 : 0])</font>
- gm14 <font id="function_arguments">(input [7 : 0] op)</font> <font id="function_return">return ([7 : 0])</font>
- inv_mixw <font id="function_arguments">(input [31 : 0] w)</font> <font id="function_return">return ([31 : 0])</font>
- inv_mixcolumns <font id="function_arguments">(input [127 : 0] data)</font> <font id="function_return">return ([127 : 0])</font>
- inv_shiftrows <font id="function_arguments">(input [127 : 0] data)</font> <font id="function_return">return ([127 : 0])</font>
- addroundkey <font id="function_arguments">(input [127 : 0] data,<br><span style="padding-left:20px"> input [127 : 0] rkey)</font> <font id="function_return">return ([127 : 0])</font>

## Processes
- reg_update: ( @ (posedge clk or negedge reset_n) )
  - **Type:** always
- round_logic: ( @* )
  - **Type:** always
- sword_ctr: ( @* )
  - **Type:** always
- round_ctr: ( @* )
  - **Type:** always
- decipher_ctrl: ( @* )
  - **Type:** always

## Instantiations

- inv_sbox_inst: aes_inv_sbox

## State machines

![Diagram_state_machine_0]( fsm_aes_decipher_block_00.svg "Diagram")