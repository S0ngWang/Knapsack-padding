
function [] = knapsack_padding(Ant_Number, Pkt_Number)
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
used_pkt = [used_pkt longest_pkt_index];


%streams(M, master_length) = struct(field3,value3, field4,value4, field5,value5);   

streams(1, master_length).selected_pkt = longest_pkt_index;
streams(1, master_length).max_value = pkt(longest_pkt_index).value;
streams(1, master_length).schedule = 0;

for i = 2: M
  for j = 2: master_length
      streams(i,j).max_value = 0;
      streams(i,j).selected_pkt = [];

      for l = 1:k
          if pkt(l).length < j
              if isempty(find(l==used_pkt, 1)) == 1 && isempty(find(l==streams(i, j - pkt(l).length).selected_pkt, 1)) == 1
                  value = pkt(l).value + streams(i, j - pkt(l).length).max_value - LOSS(i, j, l);%calculate LOSS
                    if value > streams(i,j).max_value
                        max_sum = 0;
                        if size(streams(i, j - pkt(l).length).selected_pkt) ~= 0
                            for m = 1 : size(streams(i, j).selected_pkt)
                                max_sum = max_sum + pkt(streams(i, j - pkt(l).length).selected_pkt(m)).value;
                            end
                        end
                        max_sum = max_sum + pkt(l).value;
                        streams(i,j).max_value = max_sum;
                        streams(i,j).selected_pkt = [streams(i,j - pkt(l).length).selected_pkt l];
                        streams(i,j).schedule = [streams(i,j - pkt(l).length).schedule j - pkt(l).length];
                    end   
              end  
          end
      end     
  end
  used_pkt = [used_pkt streams(i,master_length).selected_pkt];
  %output streams are stored in 'streams(M, master_length).selected_pkt'
end
