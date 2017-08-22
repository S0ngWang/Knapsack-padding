function [] = random_padding(Ant_Number, Pkt_Number)
M = Ant_Number; %number of antenna
k = Pkt_Number; %number of packets

global pkt;
global master_length;
global streams;
used_pkt = [];
%-----all packests are stored in global array pkt[]
longest_pkt_index = 1;

%-----select the longest packet for master stream
for n = 2: numel(pkt)
  if pkt(n).length > pkt(longest_pkt_index).length
      longest_pkt_index = n;
  end  
end

master_length = pkt(longest_pkt_index).length;
master_length
used_pkt = [used_pkt longest_pkt_index];


%streams(M, master_length) = struct(field3,value3, field4,value4, field5,value5);   

streams(1, master_length).selected_pkt = longest_pkt_index;
streams(1, master_length).max_value = pkt(longest_pkt_index).value;
streams(1, master_length).schedule = 0;

pkt_index = 1;

for i = 2 : M
    in_str_index = 1;
    current_length = 0;
    while pkt_index < k
       if pkt_index == longest_pkt_index
           pkt_index = pkt_index + 1;
       end
       streams(i, master_length).selected_pkt(in_str_index) = pkt_index;
       streams(i, master_length).schedule(in_str_index) = current_length;
       current_length = current_length + pkt(pkt_index).length;
       pkt_index = pkt_index + 1;
       if current_length + pkt(pkt_index).length > master_length
           break;
       end
       in_str_index = in_str_index + 1;
    end
    if pkt_index == k
        break;
    end
end

end