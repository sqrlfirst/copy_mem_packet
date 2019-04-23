module MAC_memory
    #(
        parameter               pADRESS = 2,      //Capacity for port №   
                                pSLOTS = 16384,   //№ of adresses   
                                pDATA_WIDTH=8,
                                pTIME = 9,         //Capacity for save time = 300 seconds 
                                pMAX_PACKET_LENGHT = 1536,
                                pONE_SECOND = 125000000
    )
    (
        input wire                          iclk,
        input wire [pADRESS-1:0]            i_port_num,
        input wire [pDATA_WIDTH-1:0]        irx_d,
        input wire [2:0]                    iFSM_state,
        output reg [pADRESS-1:0]            o_port_num
    );

    reg [pADRESS-1:0]                       r_port_num [$clog2(pSLOTS)-1:0] ='{default: 'b0};
    reg [pTIME-1:0]                         r_time [$clog2(pSLOTS)-1:0] ='{default: 'd300};
    reg [$clog2(pSLOTS)-1:0]                r_adress ='0; 

    reg [$clog2(pMAX_PACKET_LENGHT)-1:0]    r_counter_len ='0;
    reg [5:0]                               r_MAC_higher ='0; 
    reg [pDATA_WIDTH-1:0]                   r_MAC_lower ='0;
    reg                                     r_write_en='0;

    reg [$clog2(pSLOTS)-1:0]                r_d_counter='0; 
    reg [$clog2(pONE_SECOND)-1:0]           r_FBC='0;



    always @(posedge iclk) begin
    r_FBC<=r_FBC+1;
    if (r_FBC==27'd125000000)
       r_FBC<=0;
       r_d_counter<='0; 
    end 


    always @(posedge iclk) begin                        //Getting MAC adress
        if ((iFSM_state!==3'b000)|(iFSM_state!==3'b001)|(iFSM_state!==3'b111)) 
            r_counter_len<=r_counter_len+1;       
        if ((iFSM_state==3'b100)|(iFSM_state==3'b101)|(iFSM_state==3'b110)) begin 
        case (r_counter_len)
        'd10: r_MAC_higher<=irx_d [5:0];    //write Adress
        'd11: r_MAC_lower<=irx_d;
        'd12: r_adress<={r_MAC_higher,r_MAC_lower};
        'd13: r_write_en<=1'b1;
        'd14: r_write_en<=1'b0;
        endcase
        end
        if (iFSM_state==3'b111) 
            r_counter_len<='0;
        end

    always @(posedge iclk) begin 
        if (r_write_en) begin
            r_port_num[r_adress] <= i_port_num;
            r_time[r_adress] <= 9'd300;
        end
        if  (r_FBC > 27'd124983615) begin
            r_d_counter<=r_d_counter+1;
            r_time[r_d_counter]<=r_time[r_d_counter]-1;
        end
        end

    endmodule


    