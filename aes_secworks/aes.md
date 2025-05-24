
# Entity: aes 
- **File**: aes.v

## Diagram
![Diagram](aes.svg "Diagram")
## Ports

| Port name  | Direction | Type           | Description |
| ---------- | --------- | -------------- | ----------- |
| clk        | input     | wire           |             |
| reset_n    | input     | wire           |             |
| cs         | input     | wire           |             |
| we         | input     | wire           |             |
| address    | input     | wire  [7 : 0]  |             |
| write_data | input     | wire  [31 : 0] |             |
| read_data  | output    | wire [31 : 0]  |             |

## Signals

| Name              | Type           | Description |
| ----------------- | -------------- | ----------- |
| init_reg          | reg            |             |
| init_new          | reg            |             |
| next_reg          | reg            |             |
| next_new          | reg            |             |
| encdec_reg        | reg            |             |
| keylen_reg        | reg            |             |
| config_we         | reg            |             |
| block_reg [0 : 3] | reg [31 : 0]   |             |
| block_we          | reg            |             |
| key_reg [0 : 7]   | reg [31 : 0]   |             |
| key_we            | reg            |             |
| result_reg        | reg [127 : 0]  |             |
| valid_reg         | reg            |             |
| ready_reg         | reg            |             |
| tmp_read_data     | reg [31 : 0]   |             |
| core_encdec       | wire           |             |
| core_init         | wire           |             |
| core_next         | wire           |             |
| core_ready        | wire           |             |
| core_key          | wire [255 : 0] |             |
| core_keylen       | wire           |             |
| core_block        | wire [127 : 0] |             |
| core_result       | wire [127 : 0] |             |
| core_valid        | wire           |             |

## Constants

| Name             | Type | Value        | Description |
| ---------------- | ---- | ------------ | ----------- |
| ADDR_NAME0       |      | 8'h00        |             |
| ADDR_NAME1       |      | 8'h01        |             |
| ADDR_VERSION     |      | 8'h02        |             |
| ADDR_CTRL        |      | 8'h08        |             |
| CTRL_INIT_BIT    |      | 0            |             |
| CTRL_NEXT_BIT    |      | 1            |             |
| ADDR_STATUS      |      | 8'h09        |             |
| STATUS_READY_BIT |      | 0            |             |
| STATUS_VALID_BIT |      | 1            |             |
| ADDR_CONFIG      |      | 8'h0a        |             |
| CTRL_ENCDEC_BIT  |      | 0            |             |
| CTRL_KEYLEN_BIT  |      | 1            |             |
| ADDR_KEY0        |      | 8'h10        |             |
| ADDR_KEY7        |      | 8'h17        |             |
| ADDR_BLOCK0      |      | 8'h20        |             |
| ADDR_BLOCK3      |      | 8'h23        |             |
| ADDR_RESULT0     |      | 8'h30        |             |
| ADDR_RESULT3     |      | 8'h33        |             |
| CORE_NAME0       |      | 32'h61657320 |             |
| CORE_NAME1       |      | 32'h20202020 |             |
| CORE_VERSION     |      | 32'h302e3630 |             |

## Processes
- reg_update: ( @ (posedge clk or negedge reset_n) )
  - **Type:** always
- api: ( @* )
  - **Type:** always

## Instantiations

- core: aes_core
