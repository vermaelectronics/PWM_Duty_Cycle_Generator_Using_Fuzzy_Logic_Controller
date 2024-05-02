// Code your design here
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: National Institute of Technology, Warangal
// Engineer: Sandeep Kumar Verma
// 
// Create Date: 04/22/2024 06:30:56 PM
// Design Name: PWM Duty Cycle Gnerator for the Variation of Intensity of Light through LED using Fuzzy Logic Controller
// Module Name: TOP
// Project Name: PWM Duty Cycle Generator Using Fuzzy Logic Controller
// Target Devices: CORA Z7 SoC Developement Board (XC7Z010-1CLG400C)
// Tool Versions: 
// Description: 
// 
// Dependencies: @vermaelectronics
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Please Ask Before Use
// 
//////////////////////////////////////////////////////////////////////////////////

// Code your design here

module TOP_LED(
  input CLK_TOP,
  input RESET_TOP,
  input [7:0] BCD_TOP,
  //output [7:0] digital_freq,
  output [7:0] DUTY_TOP,
  //output [7:0] fuzzy_set_id
  output LED_TOP
);

  // PWM Output Pin of LED of FPGA/SoC Developement Board
  wire PWM_OUT_TOP;
  
  wire [7:0] DIGITAL_FREQ_TOP;
  
  // Digital Output Frequency 
  wire [7:0] OUT_DIG_FREQ_TOP;

  //wire [7:0] output_fuzzy_set_id;

  // Input FUZZY FREQUENCY

  wire [7:0] PTR_FREQ_FUZZY_TOP;
  wire [7:0] PTR_INPUT_FUZZY_SET_ID_TOP;

  //Input FUZZY SETS

  wire [7:0] PTR_negGIGANTIC_TOP;
  wire [7:0] PTR_negHUGE_TOP;
  wire [7:0] PTR_negBIG_TOP;
  wire [7:0] PTR_negMEDIUM_TOP;
  wire [7:0] PTR_negSMALL_TOP;
  wire [7:0] PTR_ZERO_TOP;
  wire [7:0] PTR_posSMALL_TOP;
  wire [7:0] PTR_posMEDIUM_TOP;
  wire [7:0] PTR_posBIG_TOP;
  wire [7:0] PTR_posHUGE_TOP;
  wire [7:0] PTR_posGIGANTIC_TOP;
  wire [7:0] OUTPUT_FUZZY_SET_ID_TOP;
  wire [7:0] PWM_DUTY_CYCLE_TOP;

  //reg PROCESS_Control = 2'b00;

  // 1. MODULE to Digitize the BCD Value That is Received From The ADC

  DIGITIZATION DIGITIZATION(
    .CLK(CLK_TOP),
    .INPUT_BIT(BCD_TOP),
    .FREQ(DIGITAL_FREQ_TOP),
    .OUT_DIG_FREQ(OUT_DIG_FREQ_TOP)
  );

  // 2. MODULE to Fuzzify The Input Frequency

  FUZZIFICATION FUZZIFICATION(
    .CLK(CLK_TOP),
    .FREQ_CRISP(OUT_DIG_FREQ_TOP),
    .PTR_FREQ_FUZZY(PTR_FREQ_FUZZY_TOP),
    .PTR_INPUT_FUZZY_SET_ID(PTR_INPUT_FUZZY_SET_ID_TOP),
    .PTR_negGIGANTIC(PTR_negGIGANTIC_TOP),
    .PTR_negHUGE(PTR_negHUGE_TOP),
    .PTR_negBIG(PTR_negBIG_TOP),
    .PTR_negMEDIUM(PTR_negMEDIUM_TOP),
    .PTR_negSMALL(PTR_negSMALL_TOP),
    .PTR_ZERO(PTR_ZERO_TOP),
    .PTR_posSMALL(PTR_posSMALL_TOP),
    .PTR_posMEDIUM(PTR_posMEDIUM_TOP),
    .PTR_posBIG(PTR_posBIG_TOP),
    .PTR_posHUGE(PTR_posHUGE_TOP),
    .PTR_posGIGANTIC(PTR_posGIGANTIC_TOP)
  );

  // 3. RULEBASE MODULE to Infer The Output Membership Function Based On The Input Membership Function

  RULEBASE RULEBASE(
    .CLK(CLK_TOP),
    .INPUT_FUZZY_SET_ID(PTR_INPUT_FUZZY_SET_ID_TOP),
    .OUTPUT_FUZZY_SET_ID(OUTPUT_FUZZY_SET_ID_TOP)
  );

  // 4. DEFUZZIFICATION MODULE to Defuzzify The Fuzzy Values Into a Crisp Output

  DEFUZZIFICATION DEFUZZIFICATION(
    .CLK(CLK_TOP),
    .OUTPUT_FUZZY_SET_ID(OUTPUT_FUZZY_SET_ID_TOP),
    .PWM_DUTY(PWM_DUTY_CYCLE_TOP)
  );

  PWM_DUTY_MOD PWM_DUTY_MOD(.CLK(CLK_TOP),
                    .RESET(RESET_TOP),
                    .PWM_DUTY_ONE(PWM_DUTY_CYCLE_TOP),
                    .PWM_OUT(PWM_OUT_TOP)
                   );
  
  assign DUTY_TOP = PWM_DUTY_CYCLE_TOP;
  //assign fuzzy_set_id = output_fuzzy_set_id;
  assign LED_TOP = PWM_OUT_TOP;

endmodule

// Digitization Module

module DIGITIZATION(
  input CLK,
  input  [7:0] INPUT_BIT,
  output [7:0] OUT_DIG_FREQ,
  output [7:0] FREQ
); 
  reg BIT_ONE = 1'b1;
  reg BIT_ZER = 1'b0;
  reg [3:0] LSB_DIG;
  reg [3:0] MSB_DIG;   
  reg [7:0] INTERNAL_FREQ;
   
  // This 'always' Block Only Converts The Data Bits Received In The PMOD Ports of The FPGA BOARD to Binary Digit Values.

  always @(posedge CLK) 
    begin
      //  Aassigning Appropriate Values to The BCD LSB
      if ((INPUT_BIT[3] == BIT_ZER) && (INPUT_BIT[2] == BIT_ZER) && (INPUT_BIT[1] == BIT_ZER) && (INPUT_BIT[0] == BIT_ZER))
        begin
          LSB_DIG <= 4'b0000;
        end 
      else if ((INPUT_BIT[3] == BIT_ZER) && (INPUT_BIT[2] == BIT_ZER) && (INPUT_BIT[1] == BIT_ZER) && (INPUT_BIT[0] == BIT_ONE)) 
        begin
          LSB_DIG <= 4'b0001;
        end 
      else if ((INPUT_BIT[3] == BIT_ZER) && (INPUT_BIT[2] == BIT_ZER) && (INPUT_BIT[1] == BIT_ONE) && (INPUT_BIT[0] == BIT_ZER)) 
        begin
            LSB_DIG <= 4'b0010;
        end 
      else if ((INPUT_BIT[3] == BIT_ZER) && (INPUT_BIT[2] == BIT_ZER) && (INPUT_BIT[1] == BIT_ONE) && (INPUT_BIT[0] == BIT_ONE)) 
          begin
            LSB_DIG <= 4'b0011;
        end 
      else if ((INPUT_BIT[3] == BIT_ZER) && (INPUT_BIT[2] == BIT_ONE) && (INPUT_BIT[1] == BIT_ZER) && (INPUT_BIT[0] == BIT_ZER)) 
        begin
            LSB_DIG <= 4'b0100;
        end 
      else if ((INPUT_BIT[3] == BIT_ZER) && (INPUT_BIT[2] == BIT_ONE) && (INPUT_BIT[1] == BIT_ZER) && (INPUT_BIT[0] == BIT_ONE)) 
        begin
            LSB_DIG <= 4'b0101;
        end 
      else if ((INPUT_BIT[3] == BIT_ZER) && (INPUT_BIT[2] == BIT_ONE) && (INPUT_BIT[1] == BIT_ONE) && (INPUT_BIT[0] == BIT_ZER)) 
        begin
            LSB_DIG <= 4'b0110;
        end 
      else if ((INPUT_BIT[3] == BIT_ZER) && (INPUT_BIT[2] == BIT_ONE) && (INPUT_BIT[1] == BIT_ONE) && (INPUT_BIT[0] == BIT_ONE)) 
        begin
            LSB_DIG <= 4'b0111;    
        end 
      else if ((INPUT_BIT[3] == BIT_ONE) && (INPUT_BIT[2] == BIT_ZER) && (INPUT_BIT[1] == BIT_ZER) && (INPUT_BIT[0] == BIT_ZER)) 
        begin
            LSB_DIG <= 4'b1000;
        end 
      else if ((INPUT_BIT[3] == BIT_ONE) && (INPUT_BIT[2] == BIT_ZER) && (INPUT_BIT[1] == BIT_ZER) && (INPUT_BIT[0] == BIT_ONE)) 
        begin
            LSB_DIG <= 4'b1001;
        end
      
      //  Aassigning Appropriate Values to The BCD MSB      
      if ((INPUT_BIT[7] == BIT_ZER) && (INPUT_BIT[6] == BIT_ZER) && (INPUT_BIT[5] == BIT_ZER) && (INPUT_BIT[4] == BIT_ZER)) 
        begin
            MSB_DIG <= 4'b0000;
        end 
      else if ((INPUT_BIT[7] == BIT_ZER) && (INPUT_BIT[6] == BIT_ZER) && (INPUT_BIT[5] == BIT_ZER) && (INPUT_BIT[4] == BIT_ONE)) 
          begin
            MSB_DIG <= 4'b0001;
        end 
      else if ((INPUT_BIT[7] == BIT_ZER) && (INPUT_BIT[6] == BIT_ZER) && (INPUT_BIT[5] == BIT_ONE) && (INPUT_BIT[4] == BIT_ZER)) 
        begin
            MSB_DIG <= 4'b0010;
        end 
      else if ((INPUT_BIT[7] == BIT_ZER) && (INPUT_BIT[6] == BIT_ZER) && (INPUT_BIT[5] == BIT_ONE) && (INPUT_BIT[4] == BIT_ONE)) 
        begin
            MSB_DIG <= 4'b0011;
        end 
      else if ((INPUT_BIT[7] == BIT_ZER) && (INPUT_BIT[6] == BIT_ONE) && (INPUT_BIT[5] == BIT_ZER) && (INPUT_BIT[4] == BIT_ZER)) 
        begin
            MSB_DIG <= 4'b0100;
        end 
      else if ((INPUT_BIT[7] == BIT_ZER) && (INPUT_BIT[6] == BIT_ONE) && (INPUT_BIT[5] == BIT_ZER) && (INPUT_BIT[4] == BIT_ONE)) 
        begin
            MSB_DIG <= 4'b0101;
        end 
      else if ((INPUT_BIT[7] == BIT_ZER) && (INPUT_BIT[6] == BIT_ONE) && (INPUT_BIT[5] == BIT_ONE) && (INPUT_BIT[4] == BIT_ZER)) 
        begin
            MSB_DIG <= 4'b0110;
        end 
      else if ((INPUT_BIT[7] == BIT_ZER) && (INPUT_BIT[6] == BIT_ONE) && (INPUT_BIT[5] == BIT_ONE) && (INPUT_BIT[4] == BIT_ONE)) 
        begin
            MSB_DIG <= 4'b0111;
        end 
      else if ((INPUT_BIT[7] == BIT_ONE) && (INPUT_BIT[6] == BIT_ZER) && (INPUT_BIT[5] == BIT_ZER) && (INPUT_BIT[4] == BIT_ZER)) 
        begin
            MSB_DIG <= 4'b1000;
        end 
      else if ((INPUT_BIT[7] == BIT_ONE) && (INPUT_BIT[6] == BIT_ZER) && (INPUT_BIT[5] == BIT_ZER) && (INPUT_BIT[4] == BIT_ONE)) 
        begin
            MSB_DIG <= 4'b1001;
        end
    end

  always @*
    begin
       INTERNAL_FREQ <= (MSB_DIG * 4'b1010) + {3'b0, LSB_DIG};
    end
  
  assign FREQ = INTERNAL_FREQ;
  
  reg [7:0] DIG_FREQ;
  
  parameter ZER = 5'b00000;
  parameter ONE = 5'b00001;
  parameter TWO = 5'b00010;
  parameter THR = 5'b00011;
  parameter FOR = 5'b00100;
  parameter FIV = 5'b00101; 
  parameter SIX = 5'b00110; 
  parameter SEV = 5'b00111; 
  parameter EIG = 5'b01000;
  parameter NIN = 5'b01001;
  parameter TEN = 5'b01010;
  parameter ELE = 5'b01011;
  parameter TWE = 5'b01100;
  parameter THI = 5'b01101;
  parameter FRT = 5'b01110;
  parameter FIF = 5'b01111;
  parameter SXT = 5'b10000;
  parameter SVT = 5'b10001;
  parameter EIT = 5'b10010;
  parameter NIT = 5'b10011;
  parameter TWT = 5'b10100;
  parameter TON = 5'b10101;
    
  
  parameter  FORTY_eBIT        = 8'b00101000;
  parameter  FORTY_ONE_eBIT    = 8'b00101001; 
  parameter  FORTY_TWO_eBIT    = 8'b00101010;
  parameter  FORTY_THREE_eBIT  = 8'b00101011;
  parameter  FORTY_FOUR_eBIT   = 8'b00101100;
  parameter  FORTY_FIVE_eBIT   = 8'b00101101;
  parameter  FORTY_SIX_eBIT    = 8'b00101110;
  parameter  FORTY_SEVEN_eBIT  = 8'b00101111;
  parameter  FORTY_EIGHT_eBIT  = 8'b00110000;
  parameter  FORTY_NINE_eBIT   = 8'b00110001;
  parameter  FIFTY_eBIT        = 8'b00110010;
  parameter  FIFTY_ONE_eBIT    = 8'b00110011;
  parameter  FIFTY_TWO_eBIT    = 8'b00110100;
  parameter  FIFTY_THREE_eBIT  = 8'b00110101;
  parameter  FIFTY_FOUR_eBIT   = 8'b00110110;
  parameter  FIFTY_FIVE_eBIT   = 8'b00110111;
  parameter  FIFTY_SIX_eBIT    = 8'b00111000;
  parameter  FIFTY_SEVEN_eBIT  = 8'b00111001;
  parameter  FIFTY_EIGHT_eBIT  = 8'b00111010;
  parameter  FIFTY_NINE_eBIT   = 8'b00111011;
  parameter  SIXTY_eBIT        = 8'b00111100;
 
  always @(posedge CLK)
    begin
      if(INTERNAL_FREQ <= FORTY_eBIT)
        begin
          DIG_FREQ = ZER;
        end
      else if((INTERNAL_FREQ > FORTY_eBIT) && (INTERNAL_FREQ <= FORTY_ONE_eBIT))
        begin
          DIG_FREQ = ONE;
        end
      else if((INTERNAL_FREQ > FORTY_ONE_eBIT ) && (INTERNAL_FREQ <= FORTY_TWO_eBIT))
        begin
          DIG_FREQ = TWO;
        end
      else if((INTERNAL_FREQ > FORTY_TWO_eBIT) && (INTERNAL_FREQ <= FORTY_THREE_eBIT))
        begin
          DIG_FREQ = THR;
        end
      else if((INTERNAL_FREQ > FORTY_THREE_eBIT) && (INTERNAL_FREQ <= FORTY_FOUR_eBIT))
        begin
          DIG_FREQ = FOR;
        end
      else if((INTERNAL_FREQ > FORTY_FOUR_eBIT) && (INTERNAL_FREQ <= FORTY_FIVE_eBIT))
        begin
          DIG_FREQ = FIV;
        end
      else if((INTERNAL_FREQ > FORTY_FIVE_eBIT) && (INTERNAL_FREQ<= FORTY_SIX_eBIT))
        begin
          DIG_FREQ = SIX;
        end
      else if((INTERNAL_FREQ > FORTY_SIX_eBIT) && (INTERNAL_FREQ <= FORTY_SEVEN_eBIT))
        begin
          DIG_FREQ = SEV;
        end
      else if((INTERNAL_FREQ > FORTY_SEVEN_eBIT) && (INTERNAL_FREQ <= FORTY_EIGHT_eBIT))
        begin
          DIG_FREQ = EIG;
        end
      else if((INTERNAL_FREQ > FORTY_EIGHT_eBIT) && (INTERNAL_FREQ <= FORTY_NINE_eBIT))
        begin
          DIG_FREQ = NIN;
        end
      else if((INTERNAL_FREQ > FORTY_NINE_eBIT) && (INTERNAL_FREQ <= FIFTY_eBIT))
        begin
          DIG_FREQ = TEN;
        end
      else if((INTERNAL_FREQ > FIFTY_eBIT) && (INTERNAL_FREQ <= FIFTY_ONE_eBIT))
        begin
          DIG_FREQ = ELE;
        end
      else if((INTERNAL_FREQ > FIFTY_ONE_eBIT) && (INTERNAL_FREQ <= FIFTY_TWO_eBIT))
        begin
          DIG_FREQ = TWE;
        end
      else if((INTERNAL_FREQ > FIFTY_TWO_eBIT) && (INTERNAL_FREQ <= FIFTY_THREE_eBIT))
        begin
          DIG_FREQ = THI;
        end
      else if((INTERNAL_FREQ > FIFTY_THREE_eBIT) && (INTERNAL_FREQ <= FIFTY_FOUR_eBIT))
        begin
          DIG_FREQ = FRT;
        end
      else if((INTERNAL_FREQ > FIFTY_FOUR_eBIT) && (INTERNAL_FREQ <= FIFTY_FIVE_eBIT))
        begin
          DIG_FREQ = FIF;
        end
      else if((INTERNAL_FREQ > FIFTY_FIVE_eBIT) && (INTERNAL_FREQ <= FIFTY_SIX_eBIT))
        begin
          DIG_FREQ = SXT;
        end
      else if((INTERNAL_FREQ > FIFTY_SIX_eBIT) && (INTERNAL_FREQ <= FIFTY_SEVEN_eBIT))
        begin
          DIG_FREQ = SVT;
        end
      else if((INTERNAL_FREQ > FIFTY_SEVEN_eBIT) && (INTERNAL_FREQ <= FIFTY_EIGHT_eBIT))
        begin
          DIG_FREQ = EIT;
        end
      else if((INTERNAL_FREQ > FIFTY_EIGHT_eBIT) && (INTERNAL_FREQ <= FIFTY_NINE_eBIT))
        begin
          DIG_FREQ = NIT;
        end
      else if((INTERNAL_FREQ > FIFTY_NINE_eBIT) && (INTERNAL_FREQ <= SIXTY_eBIT))
        begin
          DIG_FREQ = TWT;
        end
      else if(INTERNAL_FREQ > SIXTY_eBIT)
        begin
          DIG_FREQ = TON;
        end
    end     
  
  assign OUT_DIG_FREQ = DIG_FREQ;
              
endmodule

// Fuzzification

module FUZZIFICATION (
  input  CLK,
  input  [7:0] FREQ_CRISP, 
  output [7:0] PTR_FREQ_FUZZY, 
  output [7:0] PTR_INPUT_FUZZY_SET_ID, 
  output [7:0] PTR_negGIGANTIC, 
  output [7:0] PTR_negHUGE, 
  output [7:0] PTR_negBIG, 
  output [7:0] PTR_negMEDIUM, 
  output [7:0] PTR_negSMALL, 
  output [7:0] PTR_ZERO, 
  output [7:0] PTR_posSMALL, 
  output [7:0] PTR_posMEDIUM, 
  output [7:0] PTR_posBIG, 
  output [7:0] PTR_posHUGE, 
  output [7:0] PTR_posGIGANTIC 
);
    
  reg [7:0] INT_FREQ_FUZZY;
  reg [7:0] INT_INPUT_FUZZY_SET_ID; 
  reg [7:0] INT_negGIGANTIC;
  reg [7:0] INT_negHUGE; 
  reg [7:0] INT_negBIG;
  reg [7:0] INT_negMEDIUM; 
  reg [7:0] INT_negSMALL; 
  reg [7:0] INT_ZERO; 
  reg [7:0] INT_posSMALL; 
  reg [7:0] INT_posMEDIUM; 
  reg [7:0] INT_posBIG; 
  reg [7:0] INT_posHUGE; 
  reg [7:0] INT_posGIGANTIC; 
    
  parameter ZERO_eBIT      =  8'b00000000;
  parameter ONE_eBIT       =  8'b00000001;
  parameter TWO_eBIT       =  8'b00000010;
  parameter THREE_eBIT     =  8'b00000011;
  parameter FOUR_eBIT      =  8'b00000100;
  parameter FIVE_eBIT      =  8'b00000101;
  parameter SIX_eBIT       =  8'b00000110;
  parameter SEVEN_eBIT     =  8'b00000111;
  parameter EIGHT_eBIT     =  8'b00001000;
  parameter NINE_eBIT      =  8'b00001001;
  parameter TEN_eBIT       =  8'b00001010;
  parameter ELEVEN_eBIT    =  8'b00001011;
  parameter TWELVE_eBIT    =  8'b00001100;
  parameter THIRTEEN_eBIT  =  8'b00001101;
  parameter FOURTEEN_eBIT  =  8'b00001110;
  parameter FIFTEEN_eBIT   =  8'b00001111;
  parameter SIXTEEN_eBIT   =  8'b00010000;
  parameter SEVENTEEN_eBIT =  8'b00010001;
  parameter EIGHTEEN_eBIT  =  8'b00010010;
  parameter NINETEEN_eBIT  =  8'b00010011;
  parameter TWENTY_eBIT    =  8'b00010100;
  
  // Internal Register to Hold The Crisp Value of Frequency
  reg [7:0] INT_FREQ_CRISP;
  
  always@ (posedge CLK) 
    begin
      INT_FREQ_CRISP <= FREQ_CRISP;
    
      if (INT_FREQ_CRISP < ZERO_eBIT) 
        begin
          INT_negGIGANTIC <= ONE_eBIT; // Neg Gignatic
            
          // Identifying The Selected Fuzzy Set
          
          INT_INPUT_FUZZY_SET_ID <= ONE_eBIT; 
          // The Input to Rule Base is Calculated With MAX Rule, Direct Assignment Works As Only One Value Exists 
          INT_FREQ_FUZZY <= INT_negGIGANTIC;

          /* Set everything else to zero */
          INT_negHUGE     <= 8'b00000000;
          INT_negBIG      <= 8'b00000000;
          INT_negMEDIUM   <= 8'b00000000;
          INT_negSMALL    <= 8'b00000000;
          INT_ZERO        <= 8'b00000000;
          INT_posSMALL    <= 8'b00000000;
          INT_posMEDIUM   <= 8'b00000000;
          INT_posBIG      <= 8'b00000000;
          INT_posHUGE     <= 8'b00000000;
          INT_posGIGANTIC <= 8'b00000000;
        end 
      
      else if ((INT_FREQ_CRISP >= ZERO_eBIT) && (INT_FREQ_CRISP < TWO_eBIT)) 
        begin
          // Int_negHuge <= FREQ_CRISP
          // int_negGigantic <= (TWO_eBIT - int_freq_crisp)
          // Instead of a Division Algo, a Division by 2 LUT is created below.
          case (FREQ_CRISP)
            ZERO_eBIT: 
              begin
                INT_negHUGE <= ZERO_eBIT;       //   0   / 2 = 0
                INT_negGIGANTIC <= ONE_eBIT;    // (2-0) / 2 = 1 
              end
            ONE_eBIT:  
              begin
                INT_negHUGE <= ONE_eBIT;     // 1 / 2 = 1
                INT_negGIGANTIC <= ZERO_eBIT; // (2-1) / 2 = 1
              end
          endcase
        
          if (INT_negHUGE >= INT_negGIGANTIC) 
            begin
              INT_FREQ_FUZZY <= INT_negHUGE;
              INT_INPUT_FUZZY_SET_ID <= TWO_eBIT;
            end 
          else 
            begin
              INT_FREQ_FUZZY <= INT_negGIGANTIC;
              INT_INPUT_FUZZY_SET_ID <= ONE_eBIT;
            end
            
          // Set Everything Else to Zero
          INT_negBIG      <= 8'b00000000;
          INT_negMEDIUM   <= 8'b00000000;
          INT_negSMALL    <= 8'b00000000;
          INT_ZERO        <= 8'b00000000;
          INT_posSMALL    <= 8'b00000000;
          INT_posMEDIUM   <= 8'b00000000;
          INT_posBIG      <= 8'b00000000;
          INT_posHUGE     <= 8'b00000000;
          INT_posGIGANTIC <= 8'b00000000;
        end 
    
      else if ((INT_FREQ_CRISP >= TWO_eBIT) && (INT_FREQ_CRISP < FOUR_eBIT)) 
        begin
          case (FREQ_CRISP)
            TWO_eBIT: 
              begin
                // int_negHuge <= (four_ebit - int_freq_crisp) / two_ebit;
                INT_negHUGE <= ONE_eBIT;       /* (4 - 2) / 2 = 1 */
                                    
                // int_negBig <=  (int_freq_crisp - two_ebit) / two_ebit;
                INT_negBIG <= ZERO_eBIT;       /* (2 - 2) / 2 = 0 */
              end
            THREE_eBIT:  
              begin
                // int_negHuge <= (four_ebit - int_freq_crisp) / two_ebit ;
                INT_negHUGE <= ZERO_eBIT;      /* (4 - 3) / 2 = 1 */
                                    
                // int_negBig <=  (int_freq_crisp - two_ebit) / two_ebit ;
                INT_negBIG <= ONE_eBIT;        /* (3 - 2) / 2 = 0 */
              end
          endcase
        
          if (INT_negHUGE >= INT_negBIG) 
            begin
              INT_FREQ_FUZZY <= INT_negHUGE;
              INT_INPUT_FUZZY_SET_ID <= TWO_eBIT;
            end 
          else 
            begin
              INT_FREQ_FUZZY <= INT_negBIG;
              INT_INPUT_FUZZY_SET_ID <= THREE_eBIT;
            end
            
          // Set Everything Else to Zero 
          INT_negGIGANTIC <= 8'b00000000;
          INT_negMEDIUM   <= 8'b00000000;
          INT_negSMALL    <= 8'b00000000;
          INT_ZERO        <= 8'b00000000;
          INT_posSMALL    <= 8'b00000000;
          INT_posMEDIUM   <= 8'b00000000;
          INT_posBIG      <= 8'b00000000;
          INT_posHUGE     <= 8'b00000000;
          INT_posGIGANTIC <= 8'b00000000;
            
        end
      
      else if ((INT_FREQ_CRISP >= FOUR_eBIT) && (INT_FREQ_CRISP < SIX_eBIT)) 
        begin
          case (FREQ_CRISP)
            FOUR_eBIT: 
              begin
                // int_negBig <= (six_ebit - int_freq_crisp) / two_ebit;
                INT_negBIG      <= ONE_eBIT;       // (6 - 4) / 2 = 1 (44 Hz Should be Negative Big With 1 Membership Value)
                // int_negMedium <= (int_freq_crisp - 4) / two_ebit; */
                INT_negMEDIUM   <= ZERO_eBIT;   // (4 - 2) / 2 = 1 (44 Hz Should be Negative Medium with 0 Membership Value)
              end
            
            FIVE_eBIT:  
              begin
                // int_negBig <= (six_ebit - int_freq_crisp) / two_ebit;
                INT_negBIG      <= ZERO_eBIT;    // (6 - 5) / 2 = 0.5 (45 Hz should be negative Big with 0 membership value) 
                // int_negMedium <= (int_freq_crisp - 4) / two_ebit;
                INT_negMEDIUM <= ONE_eBIT;  // (5 - 4) / 2 = 0.5 (44 Hz should be negative medium with 1 membership value)
              end
          endcase
        
          // Selecting the Maximum Value
          if (INT_negBIG >= INT_negMEDIUM) 
            begin
              INT_FREQ_FUZZY         <= INT_negBIG;
              INT_INPUT_FUZZY_SET_ID <= THREE_eBIT;
            end 
          else 
            begin
              INT_FREQ_FUZZY         <= INT_negMEDIUM;
              INT_INPUT_FUZZY_SET_ID <= FOUR_eBIT;
            end
          // Set Everything Else to Zero 
          INT_negGIGANTIC <= 8'b00000000;
          INT_negHUGE     <= 8'b00000000;
          INT_negSMALL    <= 8'b00000000;
          INT_ZERO        <= 8'b00000000;
          INT_posSMALL    <= 8'b00000000;
          INT_posMEDIUM   <= 8'b00000000;
          INT_posBIG      <= 8'b00000000;
          INT_posHUGE     <= 8'b00000000;
          INT_posGIGANTIC <= 8'b00000000;
            
        end 
    
      else if ((INT_FREQ_CRISP >= SIX_eBIT) && (INT_FREQ_CRISP < EIGHT_eBIT)) 
        begin
          case (FREQ_CRISP)
            SIX_eBIT: 
              begin       
                INT_negMEDIUM <= ONE_eBIT;    
                INT_negSMALL  <= ZERO_eBIT;
              end
            SEVEN_eBIT:  
              begin
                INT_negMEDIUM <= ZERO_eBIT;                                            
                INT_negSMALL <= ONE_eBIT;
              end
          endcase

          // Selecting the maximum value 
          if (INT_negMEDIUM >= INT_negSMALL) 
            begin
              INT_FREQ_FUZZY <= INT_negMEDIUM;
              INT_INPUT_FUZZY_SET_ID <= FOUR_eBIT;
            end 
          else 
            begin
              INT_FREQ_FUZZY <= INT_negSMALL;
              INT_INPUT_FUZZY_SET_ID <= FIVE_eBIT;
            end
        
          // Set Everything Else to Zero 
          INT_negGIGANTIC <= 8'b00000000;
          INT_negHUGE     <= 8'b00000000;
          INT_negBIG      <= 8'b00000000;
          INT_ZERO        <= 8'b00000000;
          INT_posSMALL    <= 8'b00000000;
          INT_posMEDIUM   <= 8'b00000000;
          INT_posBIG      <= 8'b00000000;
          INT_posHUGE     <= 8'b00000000;
          INT_posGIGANTIC <= 8'b00000000;
        end
    
      else if ((INT_FREQ_CRISP >= EIGHT_eBIT) && (INT_FREQ_CRISP < TWELVE_eBIT)) 
        begin
          case (FREQ_CRISP)
            EIGHT_eBIT: 
              begin     
                INT_negSMALL <= ONE_eBIT;                                                    
                INT_ZERO     <= ZERO_eBIT;   
              end
            NINE_eBIT:  
              begin  
                INT_negSMALL <= ZERO_eBIT;
                INT_ZERO     <= ONE_eBIT;  
              end
            TEN_eBIT:
              begin
                INT_negSMALL <= ZERO_eBIT;    
                INT_ZERO     <= ONE_eBIT;
              end
            ELEVEN_eBIT:
              begin
                INT_negSMALL <= ZERO_eBIT;  
                INT_ZERO     <= ONE_eBIT;  
              end            
          endcase
            
          // Selecting The Maximum Value
          if (INT_negSMALL >= INT_ZERO) 
            begin
              INT_FREQ_FUZZY <= INT_negSMALL;
              INT_INPUT_FUZZY_SET_ID <= FIVE_eBIT;
            end 
          else 
            begin
              INT_FREQ_FUZZY         <= INT_ZERO;
              INT_INPUT_FUZZY_SET_ID <= SIX_eBIT;
            end
          // Set Everything Else to Zero 
          INT_negGIGANTIC <= 8'b00000000;
          INT_negHUGE     <= 8'b00000000;
          INT_negBIG      <= 8'b00000000;
          INT_negMEDIUM   <= 8'b00000000;
          INT_posSMALL    <= 8'b00000000;
          INT_posMEDIUM   <= 8'b00000000;
          INT_posBIG      <= 8'b00000000;
          INT_posHUGE     <= 8'b00000000;
          INT_posGIGANTIC <= 8'b00000000;
        
        end 
    
      else if ((INT_FREQ_CRISP >= TWELVE_eBIT) && (INT_FREQ_CRISP < FOURTEEN_eBIT)) 
        begin
          case (FREQ_CRISP)
            TWELVE_eBIT: 
              begin  
                INT_ZERO <= ONE_eBIT;
                INT_posSMALL <= ZERO_eBIT; 
              end
            THIRTEEN_eBIT:  
              begin
                INT_ZERO <= ZERO_eBIT;   
                INT_posSMALL <= ONE_eBIT;
              end
          endcase
        
          // Selecting The Maximum Value
          if (INT_ZERO >= INT_posSMALL) 
            begin
              INT_FREQ_CRISP <= INT_ZERO;
              INT_INPUT_FUZZY_SET_ID <= SIX_eBIT;
            end 
          else 
            begin
              INT_FREQ_FUZZY <= INT_posSMALL;
              INT_INPUT_FUZZY_SET_ID <= SEVEN_eBIT;
            end
        
          // Set Everything Else to Zero 
          INT_negGIGANTIC <= 8'b00000000;
          INT_negHUGE     <= 8'b00000000;
          INT_negBIG      <= 8'b00000000;
          INT_negMEDIUM   <= 8'b00000000;
          INT_negSMALL    <= 8'b00000000;
          INT_posMEDIUM   <= 8'b00000000;
          INT_posBIG      <= 8'b00000000;
          INT_posHUGE     <= 8'b00000000;
          INT_posGIGANTIC <= 8'b00000000;
		    
        end 
      
      else if ((INT_FREQ_CRISP >= FOURTEEN_eBIT) && (INT_FREQ_CRISP < SIXTEEN_eBIT)) 
        begin
          case(FREQ_CRISP)
            FOURTEEN_eBIT: 
              begin 
                INT_posSMALL <= ONE_eBIT; 
                INT_posMEDIUM <= ZERO_eBIT; 
              end
            FIFTEEN_eBIT:  
              begin 
                INT_posSMALL <= ZERO_eBIT;  
                INT_posMEDIUM <= ONE_eBIT;   
              end
          endcase
          if(INT_posMEDIUM >= INT_posSMALL) 
            begin
              INT_FREQ_FUZZY <= INT_posMEDIUM;
              INT_INPUT_FUZZY_SET_ID <= EIGHT_eBIT;
            end 
          else 
            begin
              INT_FREQ_FUZZY <= INT_posSMALL;
              INT_INPUT_FUZZY_SET_ID <= SEVEN_eBIT;
            end
        
          // Set Everything Else to Zero 
          INT_negGIGANTIC <= 8'b00000000;
          INT_negHUGE     <= 8'b00000000;
          INT_negBIG      <= 8'b00000000;
          INT_negMEDIUM   <= 8'b00000000;
          INT_negSMALL    <= 8'b00000000;
          INT_ZERO        <= 8'b00000000;
          INT_posBIG      <= 8'b00000000;
          INT_posHUGE     <= 8'b00000000;
          INT_posGIGANTIC <= 8'b00000000;
        end 
    
      else if ((INT_FREQ_CRISP >= SIXTEEN_eBIT) && (INT_FREQ_CRISP < EIGHTEEN_eBIT)) 
        begin
          case (FREQ_CRISP)
            SIXTEEN_eBIT: 
              begin 
                INT_posMEDIUM <= ONE_eBIT;  
                INT_posBIG <= ZERO_eBIT;  
              end
            SEVENTEEN_eBIT:  
              begin
                INT_posMEDIUM <= ZERO_eBIT; 
                INT_posBIG <= ONE_eBIT;  
              end
          endcase     
          // Selecting The Maximum Value 
          if (INT_posBIG >= INT_posMEDIUM) 
            begin
              INT_FREQ_FUZZY <= INT_posBIG;
              INT_INPUT_FUZZY_SET_ID <= NINE_eBIT;
            end 
          else 
            begin
              INT_FREQ_FUZZY <= INT_posMEDIUM;
              INT_INPUT_FUZZY_SET_ID <= EIGHT_eBIT;
            end
          // Set Everything Else to Zero
          INT_negGIGANTIC <= 8'b00000000;
          INT_negHUGE     <= 8'b00000000;
          INT_negBIG      <= 8'b00000000;
          INT_negMEDIUM   <= 8'b00000000;
          INT_negSMALL    <= 8'b00000000;
          INT_ZERO        <= 8'b00000000;
          INT_posSMALL    <= 8'b00000000;
          INT_posHUGE     <= 8'b00000000;
          INT_posGIGANTIC <= 8'b00000000;
      
        end 
            
      else if ((INT_FREQ_CRISP >= EIGHTEEN_eBIT) && (INT_FREQ_CRISP <= TWENTY_eBIT)) 
        begin
          case (FREQ_CRISP)
            EIGHTEEN_eBIT: 
              begin
                INT_posBIG <= ONE_eBIT; 
                INT_posHUGE <= ZERO_eBIT; 
              end
            NINETEEN_eBIT:  
              begin             
                INT_posBIG <= ZERO_eBIT;  
                INT_posHUGE <= ONE_eBIT;
              end      
          endcase
        
          // Selecting The Maximum Value 
          if (INT_posBIG >= INT_posHUGE) 
            begin
              INT_FREQ_FUZZY <= INT_posBIG;
              INT_INPUT_FUZZY_SET_ID <= NINE_eBIT;
            end 
          else 
            begin
              INT_FREQ_FUZZY <= INT_posHUGE;
              INT_INPUT_FUZZY_SET_ID <= TEN_eBIT;
            end
        
          // Set Everything Else to Zero
          INT_negGIGANTIC <= 8'b00000000;
          INT_negHUGE     <= 8'b00000000;
          INT_negBIG      <= 8'b00000000;
          INT_negMEDIUM   <= 8'b00000000;
          INT_negSMALL    <= 8'b00000000;
          INT_ZERO        <= 8'b00000000;
          INT_posSMALL    <= 8'b00000000;
          INT_posMEDIUM   <= 8'b00000000;
          INT_posGIGANTIC <= 8'b00000000;
        end 
    
      else if (INT_FREQ_CRISP >= TWENTY_eBIT) 
        begin
          case (FREQ_CRISP)
            TWENTY_eBIT: 
              begin
                INT_posGIGANTIC <= ONE_eBIT;    
              end
          endcase
          
          // Selecting The Maximum Value
          INT_FREQ_FUZZY <= INT_posGIGANTIC;
          INT_INPUT_FUZZY_SET_ID <= ELEVEN_eBIT;
          
         // Set Everything Else to Zero
          INT_negGIGANTIC <= 8'b00000000;
          INT_negHUGE     <= 8'b00000000;
          INT_negBIG      <= 8'b00000000;
          INT_negMEDIUM   <= 8'b00000000;
          INT_negSMALL    <= 8'b00000000;
          INT_ZERO        <= 8'b00000000;
          INT_posSMALL    <= 8'b00000000;
          INT_posMEDIUM   <= 8'b00000000;
          INT_posBIG      <= 8'b00000000;
          INT_posHUGE     <= 8'b00000000;
        end        
    end 
  
  assign PTR_FREQ_FUZZY         = INT_FREQ_FUZZY; 
  assign PTR_INPUT_FUZZY_SET_ID = INT_INPUT_FUZZY_SET_ID; 
  assign PTR_negGIGANTIC        = INT_negGIGANTIC; 
  assign PTR_negHUGE            = INT_negHUGE; 
  assign PTR_negBIG             = INT_negBIG; 
  assign PTR_negMEDIUM          = INT_negMEDIUM; 
  assign PTR_negSMALL           = INT_negSMALL;
  assign PTR_ZERO               = INT_ZERO; 
  assign PTR_posSMALL           = INT_posSMALL; 
  assign PTR_posMEDIUM          = INT_posMEDIUM;
  assign PTR_posBIG             = INT_posBIG; 
  assign PTR_posHUGE            = INT_posHUGE; 
  assign PTR_posGIGANTIC        = INT_posGIGANTIC;

endmodule

//RuleBase Mdoule

module RULEBASE(
  input        CLK,
  input  [7:0] INPUT_FUZZY_SET_ID, 
  output [7:0] OUTPUT_FUZZY_SET_ID
);
  
  // Local Parameters to Represent The Numbers For Readability
  localparam ONE_eBIT       =  8'b00000001;
  localparam TWO_eBIT       =  8'b00000010;
  localparam THREE_eBIT     =  8'b00000011;
  localparam FOUR_eBIT      =  8'b00000100;
  localparam FIVE_eBIT      =  8'b00000101;
  localparam SIX_eBIT       =  8'b00000110;
  localparam SEVEN_eBIT     =  8'b00000111;
  localparam EIGHT_eBIT     =  8'b00001000;
  localparam NINE_eBIT      =  8'b00001001;
  localparam TEN_eBIT       =  8'b00001010;
  localparam ELEVEN_eBIT    =  8'b00001011;
     
  
  // Internal Registers to Handle the Input and Ouput Fuzzy Sets IDs 
  reg [7:0] INT_INPUT_ID;
  reg [7:0] INT_OUTPUT_ID;
  
  always@ (posedge CLK) 
    begin
      INT_INPUT_ID = INPUT_FUZZY_SET_ID;
      if (INT_INPUT_ID == ONE_eBIT) 
        begin 
          INT_OUTPUT_ID = ELEVEN_eBIT;
        end 
      else if (INT_INPUT_ID == TWO_eBIT) 
        begin
          INT_OUTPUT_ID = TEN_eBIT;
        end 
      else if (INT_INPUT_ID == THREE_eBIT) 
        begin
          INT_OUTPUT_ID = NINE_eBIT;
        end 
      else if (INT_INPUT_ID == FOUR_eBIT) 
        begin
          INT_OUTPUT_ID = EIGHT_eBIT;
        end 
      else if (INT_INPUT_ID == FIVE_eBIT) 
        begin
          INT_OUTPUT_ID = SEVEN_eBIT;
        end 
      else if (INT_INPUT_ID == SIX_eBIT) 
        begin
          INT_OUTPUT_ID = SIX_eBIT;
        end 
      else if (INT_INPUT_ID == SEVEN_eBIT) 
        begin
          INT_OUTPUT_ID = FIVE_eBIT;
        end 
      else if (INT_INPUT_ID == EIGHT_eBIT) 
        begin
          INT_OUTPUT_ID = FOUR_eBIT;
        end 
      else if (INT_INPUT_ID == NINE_eBIT) 
        begin
          INT_OUTPUT_ID = THREE_eBIT;
        end 
      else if (INT_INPUT_ID == TEN_eBIT) 
        begin
          INT_OUTPUT_ID = TWO_eBIT;
        end 
      else if (INT_INPUT_ID == ELEVEN_eBIT) 
        begin
          INT_OUTPUT_ID = ONE_eBIT;
        end 
    end 
  
  // Assigning The Value of The Internal Register to The Output 
  assign OUTPUT_FUZZY_SET_ID = INT_OUTPUT_ID;
    
endmodule

// Defuzzification

module DEFUZZIFICATION(
  input CLK,
  input [7:0] OUTPUT_FUZZY_SET_ID,
  output [7:0] PWM_DUTY
);
    
  // Local Parameters to Represent The Numbers for Readability 
  parameter LEN_FOUR = 3;
  parameter LEN_EIGHT = 7;
    
  parameter ZERO_eBIT      =  8'b00000000;
  parameter ONE_eBIT       =  8'b00000001;
  parameter TWO_eBIT       =  8'b00000010;
  parameter THREE_eBIT     =  8'b00000011;
  parameter FOUR_eBIT      =  8'b00000100;
  parameter FIVE_eBIT      =  8'b00000101;
  parameter SIX_eBIT       =  8'b00000110;
  parameter SEVEN_eBIT     =  8'b00000111;
  parameter EIGHT_eBIT     =  8'b00001000;
  parameter NINE_eBIT      =  8'b00001001;
  parameter TEN_eBIT       =  8'b00001010;
  parameter ELEVEN_eBIT    =  8'b00001011;
  
  parameter TWENTY_eBIT =   8'b00010100;
  parameter THIRTY_eBIT =   8'b00011110;
  parameter FOURTY_eBIT =   8'b00101000;
  parameter FIFTY_eBIT =    8'b00110010;
  parameter SIXTY_eBIT =    8'b00111100;
  parameter SEVENTY_eBIT =  8'b01000110;
  parameter EIGHTY_eBIT =   8'b01010000;
  parameter NINETY_eBIT =   8'b01011010;
  parameter HUNDRED_eBIT =  8'b01100100;
   
  reg [LEN_EIGHT:0] MEMO_negGIGANTIC;
  reg [LEN_EIGHT:0] MEMO_negHUGE;
  reg [LEN_EIGHT:0] MEMO_negBIG;
  reg [LEN_EIGHT:0] MEMO_negMEDIUM;
  reg [LEN_EIGHT:0] MEMO_negSMALL;
  reg [LEN_EIGHT:0] MEMO_ZERO;
  reg [LEN_EIGHT:0] MEMO_posSMALL;
  reg [LEN_EIGHT:0] MEMO_posMEDIUM;
  reg [LEN_EIGHT:0] MEMO_posBIG;
  reg [LEN_EIGHT:0] MEMO_posHUGE;
  reg [LEN_EIGHT:0] MEMO_posGIGANTIC;
    
  reg [7:0] DEGREE_MEM;
  reg [7:0] DUTY_CYCLE;
       
  always@ (posedge CLK) 
    begin
      DEGREE_MEM = OUTPUT_FUZZY_SET_ID;
      
      case (OUTPUT_FUZZY_SET_ID) 
        ONE_eBIT:   
          begin
            // Division by 10 Causes a Floating Point Value, However, The Result Would Still be The Same Without it.
            // Division by 10 is Removed;
            MEMO_negGIGANTIC = -(DEGREE_MEM) + TEN_eBIT;         // -(1/10) + 10 = 9.9 : -(1) + 10 = 9   => NOT SELECTED 
            MEMO_negHUGE = DEGREE_MEM + 3'b100;                  // (1 / 10) = 0.1     : 1+4 = 5  => SELECTED 
            // Selecting The Lower Value of The Two
            if (MEMO_negGIGANTIC >= MEMO_negHUGE)
              DUTY_CYCLE = MEMO_negHUGE;
            else 
              DUTY_CYCLE = MEMO_negGIGANTIC;
          end
        
        TWO_eBIT:   
          begin
            MEMO_negHUGE = -(DEGREE_MEM) + TWENTY_eBIT;         // (-2 / 10) + 20 = 19.8    :  -2 + 20 = 18
            MEMO_negBIG = (DEGREE_MEM) + TEN_eBIT - 2'b10;   // (2 / 10) + 10  = 10.2    :   2 + 10 - 2 = 12 => SELECTED*
            
            // Selecting The Lower of The Two Values
            if (MEMO_negHUGE >= MEMO_negBIG)
              DUTY_CYCLE = MEMO_negBIG;
            else 
              DUTY_CYCLE = MEMO_negHUGE;
          end
        
        THREE_eBIT: 
          begin
            MEMO_negBIG = -(DEGREE_MEM) + THIRTY_eBIT;
            MEMO_negMEDIUM = (DEGREE_MEM) + TWENTY_eBIT - 3'b100;
            // Selecting The Lower of The Two Values
            if (MEMO_negBIG >= MEMO_negMEDIUM)
              DUTY_CYCLE = MEMO_negMEDIUM;
            else 
              DUTY_CYCLE = MEMO_negBIG; 
          end
        FOUR_eBIT: 
          begin
            MEMO_negMEDIUM = -(DEGREE_MEM) + FOURTY_eBIT;
            MEMO_negSMALL = (DEGREE_MEM) + THIRTY_eBIT - 2'b10;
          
            // Selecting The Lower of The Two Values
            if (MEMO_negMEDIUM >= MEMO_negSMALL)
              DUTY_CYCLE = MEMO_negSMALL;
            else 
              DUTY_CYCLE = MEMO_negMEDIUM;
          end
        FIVE_eBIT: 
          begin
            MEMO_negSMALL = -(DEGREE_MEM) + FIFTY_eBIT;
            MEMO_ZERO = (DEGREE_MEM) + FOURTY_eBIT; //
                            
            // Selecting the lower of the two values 
            if (MEMO_ZERO >= MEMO_negSMALL)
              DUTY_CYCLE = MEMO_negSMALL;
            else 
              DUTY_CYCLE = MEMO_ZERO;    
          end
        SIX_eBIT: 
          begin
            // For The Singleton Function at The Middle, Only One Value Exists
            MEMO_ZERO = FIFTY_eBIT; 
            DUTY_CYCLE = MEMO_ZERO;
          end
        SEVEN_eBIT: 
          begin
            MEMO_ZERO = -(DEGREE_MEM) + SIXTY_eBIT;     
            MEMO_posSMALL = (DEGREE_MEM) + FIFTY_eBIT;   
            // Selecting The Lower of The Two Values 
            if (MEMO_ZERO >= MEMO_posSMALL)
              DUTY_CYCLE = MEMO_ZERO;
            else 
              DUTY_CYCLE = MEMO_posSMALL;
          end
        EIGHT_eBIT: 
          begin
            MEMO_posSMALL = -(DEGREE_MEM) + SEVENTY_eBIT;
            MEMO_posMEDIUM = (DEGREE_MEM) + SIXTY_eBIT; 
                            
            // Selecting The Lower of The Two Values
            if (MEMO_posMEDIUM >= MEMO_posSMALL)
              DUTY_CYCLE = MEMO_posMEDIUM;
            else 
              DUTY_CYCLE = MEMO_posSMALL;
          end
        NINE_eBIT: 
          begin
            MEMO_posMEDIUM = -(DEGREE_MEM) + EIGHTY_eBIT;
            MEMO_posBIG = (DEGREE_MEM) + SEVENTY_eBIT;
            
            // Selecting The Lower of The Two Values
            if (MEMO_posMEDIUM >= MEMO_posBIG)
              DUTY_CYCLE = MEMO_posMEDIUM;
            else 
              DUTY_CYCLE = MEMO_posBIG;
          end
        TEN_eBIT: 
          begin
            MEMO_posBIG = -(DEGREE_MEM) + NINETY_eBIT;
            MEMO_posHUGE = (DEGREE_MEM) + EIGHTY_eBIT; 
                            
            // Selecting The Lower of The Two Values
            if (MEMO_posHUGE >=  MEMO_posBIG)
              DUTY_CYCLE = MEMO_posHUGE;
            else 
              DUTY_CYCLE = MEMO_posBIG;   
          end
        ELEVEN_eBIT: 
          begin
            MEMO_posHUGE = -(DEGREE_MEM) + HUNDRED_eBIT;
            MEMO_posGIGANTIC = (DEGREE_MEM) + NINETY_eBIT;
                            
            // Selecting The Lower of The Two Values 
            if (MEMO_posHUGE >= MEMO_posGIGANTIC)
              DUTY_CYCLE = MEMO_posHUGE;
            else 
              DUTY_CYCLE = MEMO_posGIGANTIC - 3'b101;
          end
      endcase
    
    end 
  
  // Assigning The Value of Internal Register to Output Port
  assign PWM_DUTY = DUTY_CYCLE;
    
endmodule

// For LED Intensity Variation

module PWM_DUTY_MOD(
  input CLK,
  input RESET,
  input [7:0] PWM_DUTY_ONE,
  output PWM_OUT
    );
  
  //Up counter
  reg[7:0] Q_REG, Q_NEXT;
  //reg [8:0] duty = 0;
  reg [7:0] MEM_PWM_DUTY;
  
  always @(posedge CLK)
    begin
      MEM_PWM_DUTY = PWM_DUTY_ONE;
      if(~RESET == 1)
        begin
          Q_REG <= 1'b0;
        end
      else 
        begin 
          Q_REG <= Q_NEXT;
        end
    end
    
  //Next State Logic
  always @(*)
    begin
      Q_NEXT = Q_REG + 1;
    end
    
  //Output Logic
  assign PWM_OUT = (Q_REG < MEM_PWM_DUTY);

endmodule   
