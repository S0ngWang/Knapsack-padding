%--------Input: stream schedules - streams
%               antenna number - M
%               packet number - k

%--------Output: throughput_sum

%--------break_point_list[M - 1] - points where stream change packets
%--------affected_packet_list[M - 1] - current packets in every stream
function [throughput_sum] = eval_throughput(M)
global streams;
global master_length;
global pkt;

%break_point_list = ones(1, M - 1);
break_point_list = [];
affected_packet_list = [];

break_point_list(1) = master_length;
affected_packet_list(1) = streams(1, master_length).selected_pkt(1);

for i = 2 : M
  if isempty(streams(i, master_length).selected_pkt)
      break;
  else
      if streams(i, master_length).schedule(1) == 0
        break_point_list(i) = pkt(streams(i, master_length).selected_pkt(1)).length;
        affected_packet_list(i) = 1;
      else
        break_point_list(i) = streams(i, master_length).schedule(1);
        affected_packet_list(i) = 0.5;
      end
  end
end

throughput_sum = 0;
current_timing = 0;
max_count = 0;

while 1
  i = find(min(break_point_list) == break_point_list);
  i = i(1);
  break_point = break_point_list(i);
  throughput_list = streams(1, master_length).selected_pkt(1);
  for j = 2 : M
      if mod(affected_packet_list(j),1) == 0
          throughput_list = [throughput_list streams(j, master_length).selected_pkt(affected_packet_list(j))];
      end
  end
  throughput_sum = throughput_sum + throughput_SNR(throughput_list) * (break_point - current_timing);
  current_timing = break_point;
  current_packet = affected_packet_list(i);

  if mod(current_packet, 1) == 0
      s = size(streams(i, master_length).schedule, 2);
      if current_packet >= s
            break_point_list(i) = 65535;
            affected_packet_list(i) = 0.5;
            max_count = max_count + 1;
      else
          %if the next packet starts immediately after current_packet ends
          if streams(i, master_length).schedule(current_packet) + pkt(streams(i, master_length).selected_pkt(current_packet)).length == streams(i, master_length).schedule(current_packet + 1)
              %break_point_list(i) = the end of the next packet;
              break_point_list(i) = streams(i, master_length).schedule(current_packet + 1) + pkt(streams(i, master_length).selected_pkt(current_packet + 1)).length;
              affected_packet_list(i) = current_packet + 1;
          else
              %break_point_list(i) = the begin of the next packet;
              break_point_list(i) = streams(i, master_length).schedule(current_packet + 1);
              affected_packet_list(i) = current_packet + 0.5;
          end
      end
  else
      break_point_list(i) = streams(i, master_length).schedule(current_packet + 0.5);
      affected_packet_list(i) = current_packet + 0.5;
  end
      
      if max_count == M
          break;
      end
end
end
