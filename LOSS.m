
function [loss_sum] = LOSS(I, J, pkt_index)

global pkt;
global streams;
global master_length;

break_point_list = [];
affected_packet_list = [];

begin_time = J - pkt(pkt_index).length;
end_time = J;

break_point_list(1) = end_time;
affected_packet_list(1) = streams(1, master_length).selected_pkt(1);

%find the first packet to be affect for all streams
for i = 2 : I - 1
    packet_index = 1;
    while 1
      if streams(i, master_length).schedule(packet_index) > begin_time %END_PKT_NUMBER
        break_point_list(i) = streams(i, master_length).schedule(packet_index);
        affected_packet_list(i) = packet_index;
        break;
      end
      if streams(i, master_length).schedule(packet_index) + pkt(streams(i, master_length).selected_pkt(packet_index)).length > begin_time
        break_point_list(i) = streams(i, master_length).schedule(packet_index) + pkt(streams(i, master_length).selected_pkt(packet_index)).length;
        affected_packet_list(i) = packet_index - 0.5;
        break;
      end
      if packet_index < size(streams(i, master_length).schedule)
          packet_index = packet_index + 1;
      else
          break_point_list(i) = 65535;
          affected_packet_list(i) = -1;
          break;
      end
    end
end

loss_sum = 0;
current_timing = 0;

while 1
    i = find(break_point_list == min(break_point_list));
    i = i(1);
    if break_point_list(i) > end_time
        break_point = end_time;
    else
        break_point = break_point_list(i);
    end
    loss_list = streams(1, master_length).selected_pkt(1);
    for j = 2 : I - 1
      if mod((affected_packet_list(j)), 1) == 0 && affected_packet_list(j) ~= -1
        loss_list = [loss_list streams(j, master_length).selected_pkt(affected_packet_list(j))];
      end
    end
    loss_sum = loss_sum + Loss_SNR(loss_list, pkt_index) * (break_point - current_timing);
    loss_sum = loss_sum(1);
    current_timing = break_point;
    if current_timing == end_time
        break;
    end   
    current_packet = affected_packet_list(i);
    if mod(current_packet, 1) == 0
        s = size(streams(i, master_length).schedule);
        if current_packet == s(2)
            break_point_list(i) = 65535;
            affected_packet_list(i) = 0.5;
        else
            if streams(i, master_length).schedule(current_packet) + pkt(streams(i, master_length).selected_pkt(current_packet)).length == streams(i, master_length).schedule(current_packet + 1)
                affected_packet_list(i) = current_packet + 1;
                break_point_list(i) = streams(i, master_length).schedule(current_packet + 1) + pkt(streams(i, master_length).selected_pkt(current_packet + 1)).length;
            else
                affected_packet_list(i) = current_packet + 0.5;
                break_point_list(i) = streams(i, master_length).schedule(current_packet + 1);
            end 
        end
    else
        break_point_list(i) = streams(i, master_length).schedule(current_packet + 0.5);
        affected_packet_list(i) = current_packet + 0.5;
    end
end