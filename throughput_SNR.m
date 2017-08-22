%----------------- INPUT:  loss_list and index of appended packet
%----------------- OUTPUT: loss of SNR(larger than 0)
function [SNR_con_sum] = throughput_SNR(throughput_list)

%........global variable
global CSI;
global Noise;

%................concurrent SNR of pkts in loss_list
%SNR_con_list = 0;

normalized_power = sqrt( 1./Noise(throughput_list,:));
H = normalized_power.*CSI(throughput_list,:);
H = H.';%inverse of matrix
SNR_con_list = diag ( 1./inv(H'*H + eye(size(H,2)) ) - 1 );

SNR_con_sum = sum(SNR_con_list);