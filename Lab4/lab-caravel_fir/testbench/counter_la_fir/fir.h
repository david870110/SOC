#ifndef __FIR_H__
#define __FIR_H__

#define reg_fir_ap_ctrl  (*(volatile uint32_t*)0x30000000) // ap_control
#define reg_fir_ss_ready (*(volatile uint32_t*)0x30000004)
#define reg_fir_sm_valid (*(volatile uint32_t*)0x30000008)

#define reg_fir_len      (*(volatile uint32_t*)0x30000010) // data length
#define reg_fir_coeff    0x30000040                        // Load   into TapRAM
#define reg_fir_x_in     (*(volatile uint32_t*)0x30000080) // Load X into DataRAM
#define reg_fir_y_out    (*(volatile uint32_t*)0x30000084) // Take the output Y

#define checkbits        (*(volatile uint32_t*)0x2600000C) // MPRJ I/O
#define reg_mprj_xfer    (*(volatile uint32_t*)0x26000000)
#define reg_mprj_datal   (*(volatile uint32_t*)0x2600000c)

#define N 64
#define data_length N

int taps[11] = {0,-10,-9,23,56,63,56,23,-9,-10,0};
//int inputbuffer[N];
//int inputsignal[N] = {1,2,3,4,5,6,7,8,9,10,11};
int outputsignal[N];

#define adr_ofst(target, offset) (target + offset)
#define wb_write(target, data)   (*(volatile uint32_t*)(target)) = data // wishbone write
#define wb_read(target)   	  (*(volatile uint32_t*)(target))        // wishbone read 


#endif
