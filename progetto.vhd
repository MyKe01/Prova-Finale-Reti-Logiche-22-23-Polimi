LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
    port (
    i_clk : in std_logic;
    i_rst : in std_logic;
    i_start : in std_logic;
    i_w : in std_logic;
    o_z0 : out std_logic_vector(7 downto 0);
    o_z1 : out std_logic_vector(7 downto 0);
    o_z2 : out std_logic_vector(7 downto 0);
    o_z3 : out std_logic_vector(7 downto 0);
    o_done : out std_logic;
    o_mem_addr : out std_logic_vector(15 downto 0);
    i_mem_data : in std_logic_vector(7 downto 0);
    o_mem_we : out std_logic;
    o_mem_en : out std_logic
    );
end project_reti_logiche;


architecture behavioral of project_reti_logiche is
    TYPE state_type is (START , READ_CHANNEL , READ_ADDRESS , READ_MEM ,WAIT_MEM, WRITE_MEM , DONE , LAST);
    SIGNAL curr_state , next_state : state_type;
    SIGNAL enable1, enable1_next : std_logic := '1';
    SIGNAL curr_channel, next_channel : std_logic_vector(1 downto 0) := "00";
    SIGNAL curr_addr , next_addr : unsigned(15 downto 0) := "0000000000000000";
    SIGNAL curr_pos, next_pos : unsigned(15 downto 0) := "0000000000000001";
    SIGNAL i_w_curr : std_logic;
    SIGNAL i_mem_data_curr : std_logic_vector(7 downto 0);
    SIGNAL done_next : std_logic := '0';
    SIGNAL out1 , out2 , out3 , out0 : std_logic_vector(7 downto 0) :="00000000";
    begin
        process(i_clk , i_rst)
        begin
            if(i_rst = '1') then
                  out0 <= "00000000";
                  out1 <= "00000000";
                  out2 <= "00000000";
                  out3 <= "00000000";
                  o_z0 <= "00000000";
                  o_z1 <= "00000000";
                  o_z2 <= "00000000";
                  o_z3 <= "00000000";
                  o_done <= '0';
                  
                  enable1 <= '1';
                  curr_pos <= "0000000000000001";
                  
                  
                  curr_addr <= "0000000000000000";
                 
                  curr_channel <= "00";
                
                  curr_state <= START;
            elsif(rising_edge(i_clk)) then 
                curr_pos <= next_pos;
                i_w_curr <= i_w ;
                curr_channel <= next_channel;
                curr_addr <= next_addr;
                i_mem_data_curr <= i_mem_data;
                enable1 <= enable1_next;
                o_done <= done_next; 
                if(curr_state = WRITE_MEM)THEN 
                    if(curr_channel = "00")then
                             out0 <= i_mem_data_curr;
                    elsif(curr_channel = "01")then
                              out1 <= i_mem_data_curr;
                    elsif(curr_channel = "10")then
                              out2 <= i_mem_data_curr;
                    elsif(curr_channel = "11")then                           
                              out3 <= i_mem_data_curr;    
                    end if;    
                end if;
                if(curr_state = DONE)THEN
                    o_z0 <= out0;
                    o_z1 <= out1;
                    o_z2 <= out2;
                    o_z3 <= out3;
                else
                    o_z0 <= "00000000";
                    o_z1 <= "00000000";
                    o_z2 <= "00000000";
                    o_z3 <= "00000000";
                end if;
                
               
                     
                curr_state <= next_state;    
            end if;    
        end process;

        process( i_w_curr, i_start, curr_state , enable1, i_mem_data , done_next, curr_channel, curr_pos)
               
                
                variable adder_exit : unsigned(15 downto 0);
        begin
        
            next_pos <= curr_pos;
            enable1_next <= enable1;
            done_next <= '0';
            next_state <= curr_state;
            o_mem_en <= '0';
            o_mem_we <= '1';
            o_mem_addr <= "0000000000000000";
            next_channel <= curr_channel; 
            
        
            case curr_state is
            
                when START =>
                                   
                        if(i_start = '1' and i_rst ='0') then
                            next_pos <= "0000000000000001";
                            next_addr <= "0000000000000000";
                            
                            adder_exit := "0000000000000000";
                            enable1_next <= '1';
                          
                            next_state <= READ_CHANNEL;
                            
                        END IF;   


                when READ_CHANNEL =>
                        if(enable1 = '1') then 
                            next_channel(1) <= i_w_curr;
                            enable1_next <= '0';
                        else 
                            next_channel(0) <= i_w_curr;
                            next_state <= READ_ADDRESS;
                        END IF;

                when READ_ADDRESS =>
                        if(i_start = '0') then
                               next_state <= READ_MEM; 
                        else
                               

                               if(i_w_curr = '1') then
                                       
                                       adder_exit := curr_addr + curr_addr + 1;
                                else
                                       
                                       adder_exit := curr_addr + curr_addr;
                                end if;
                                next_addr <= adder_exit;
                                next_pos <= curr_pos + curr_pos;
                                
                        end if;
                when READ_MEM =>
                            o_mem_addr <= std_logic_vector(curr_addr);
                            o_mem_we <= '0';
                            o_mem_en <= '1';
                            next_state <= WAIT_MEM;
                            next_addr <= "0000000000000000";                            
                when WAIT_MEM =>
                            next_state <= WRITE_MEM;
                            o_mem_en <= '0';
                            o_mem_we <= '0';
                when WRITE_MEM =>
                            next_state <= DONE;    
                when DONE =>
                            done_next <= '1';
                            next_state <= LAST; 
                when LAST =>
                            done_next <= '0';
                            next_state <= START;
            end case; 
        end process;                       
end behavioral;