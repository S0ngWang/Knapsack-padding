%----------------- INPUT:  loss_list and index of appended packet
%----------------- OUTPUT: loss of SNR(larger than 0)
function [loss_sum] = Loss_SNR(loss_list, pkt_index)

%........global variable
global CSI;
global Noise;

%................concurrent SNR of pkts in loss_list
%SNR_con_list = zeros(numel(loss_list));

normalized_power = sqrt( 1./Noise(loss_list,:));
H = normalized_power.*CSI(loss_list,:);
H = H.';%inverse of matrix
SNR_con_list = diag ( 1./inv(H'*H + eye(size(H,2)) ) - 1 );

SNR_con_sum = sum(SNR_con_list);

%................SNR of pkt_index alone
noise_alone = norm(Noise(pkt_index,:));
CSI_alone = CSI(pkt_index,:);
signal_alone = norm(CSI_alone);
SNR_alone = signal_alone / noise_alone;

%................concurrent SNR of pkt_index and loss_list
total_list = [loss_list pkt_index];
%SNR_total_list = zeros(numel(total_list));

normalized_power = sqrt( 1./Noise(total_list,:));
H = normalized_power.*CSI(total_list,:);
H = H.';%inverse of matrix
SNR_total_list = diag ( 1./inv(H'*H + eye(size(H,2)) ) - 1 );

%SNR_total_sum = sum(log2(1 + SNR_total_list));
SNR_total_sum = sum(SNR_total_list);

loss_sum = SNR_con_sum + SNR_alone - SNR_total_sum;
