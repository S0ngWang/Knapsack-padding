function [] = no_padding(Ant_Number, Pkt_Number)

global streams;
global master_length;

selected_index_list = [];
[selected_index_list] = find_orth_vector(Pkt_Number, Ant_Number);

for i = 1:Ant_Number
   streams(i, master_length).selected_pkt = selected_index_list(i);
   streams(i, master_length).schedule = 0;
end
