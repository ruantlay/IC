
# Entity: aes_inv_sbox 
- **File**: aes_inv_sbox.v

## Diagram
![Diagram](aes_inv_sbox.svg "Diagram")
## Ports

| Port name | Direction | Type           | Description |
| --------- | --------- | -------------- | ----------- |
| sword     | input     | wire  [31 : 0] |             |
| new_sword | output    | wire [31 : 0]  |             |

## Signals

| Name               | Type         | Description |
| ------------------ | ------------ | ----------- |
| inv_sbox [0 : 255] | wire [7 : 0] |             |
