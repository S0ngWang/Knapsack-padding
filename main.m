clear;clc;

PKT_NUMBER = 20; %Assume every user request for transmissoin
ANT_NUMBER = 3;
NOISE_STRENGTH = 10;

N = PKT_NUMBER;
M = ANT_NUMBER;
p = NOISE_STRENGTH;

global master_length;
master_length = 0;

%% -----define structure of every unit of stream
global streams;

field3 = 'max_value'; value3 = 0;
field4 = 'selected_pkt'; value4 = [];
field5 = 'schedule'; value5 = [];
streams = struct(field3,value3, field4,value4, field5,value5);
%% -----generate CSI here
global CSI;
CSI = sqrt(1/2)* unifrnd (-2, 2, N, M) + 1i * unifrnd (-2, 2, N, M);

%% -----generate noise here  WHITTE GAISSIAN NOISE
global Noise;
Noise  = wgn(N,M,p);
% calculate SNR alone of every packets(not sure how to calculate SNR alone)
global SNR_alone_list
SNR_alone_list = zeros(1, N);
for i = 1 : N
    noise_alone = norm(Noise(i,:));
    CSI_alone = CSI(i,:);
    signal_alone = norm(CSI_alone);
    SNR_alone = signal_alone / noise_alone;
    SNR_alone_list(i) = SNR_alone;
end

%% -----define and initiated all the field of pkt 
field1 = 'length'; value1 = 0;
field2 = 'value'; value2 = 0;
time_len = round(unifrnd (1, 200, 1, N)); %uniform distribution from 1~3
%time_len(1) = 500;

global pkt;

pkt = struct(field1,value1, field2,value2);%define structure of packet, pkt is global variable
for i = 1: N
   pkt(i).length = time_len(i);
   pkt(i).value = time_len(i)*SNR_alone_list(i);
end

%% ------calculate packets value and fullfill packes here
    
knapsack_padding(M, N);

for i = 1 : M
    streams(i, master_length).selected_pkt
end

knapsack_through_put = eval_throughput(M);

streams = struct(field3,value3, field4,value4, field5,value5);

random_padding(M, N);

for i = 1 : M
    streams(i, master_length).selected_pkt
end

random_through_put = eval_throughput(M);

knapsack_through_put
random_through_put