#include "fir.h"
#include <stdint.h>

void __attribute__ ( ( section ( ".mprjram" ) ) ) initfir() {

	// program data length
	reg_fir_len = data_length;

	// program coefficient
	for (uint32_t i = 0; i < 11; i++) {
		wb_write(reg_fir_coeff + 4*i , taps[i]);
		//reg_fir_coeff + 4*i = taps[i];
	}
}

int* __attribute__ ( ( section ( ".mprjram" ) ) ) fir_excute() {
	
	//write down your fir
	// StartMark
	reg_mprj_datal = 0x00A50000;
        //wb_write(checkbits, 0x00A50000);
        

        // ap_start
        //wb_write(reg_fir_ap_ctrl, 0x1);
        reg_fir_ap_ctrl = 1;
	
        uint8_t register t = 0;


        while (t < data_length) {
        	 reg_fir_x_in = t;
                //wb_write(reg_fir_x_in, t); // write X into fir
                //outputsignal[t] =  wb_read(reg_fir_y_out);  // read Y from fir
                outputsignal[t] =  reg_fir_y_out;
                t = t + 1;
        }

        // let TB check the final Y by using MPRJ[31:24]
        // and send the EndMark 5A signal at MPRJ[23:16]
        // check ap_done
        reg_fir_ap_ctrl;
        //wb_read(reg_fir_ap_ctrl);
        //wb_write(checkbits, outputsignal[N-1] << 24 | 0x005A0000);
        checkbits = outputsignal[N-1] << 24 | 0x005A0000;
        
	return outputsignal;
}
		
