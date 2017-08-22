clear;clc;

sim_runs = 200;
INI_PKT_NUMBER = 20; %Assume every user request for transmissoin
END_PKT_NUMBER = 30;
ANT_NUMBER = 4;
NOISE_STRENGTH = 10;
result_random = [];
result_padding = [];
result_no = [];
sim = INI_PKT_NUMBER:2:END_PKT_NUMBER;
padding_matrix = zeros(sim_runs, length(sim));
random_matrix = zeros(sim_runs, length(sim));
no_matrix = zeros(sim_runs, length(sim));
global CSI;
CSI = [];
global jind;
global Noise;
dirpath = '/Users/jingqi/Documents/MATLAB/Code_signpost/newTrace';
global selected_index_list;
%Noise  =[-2.40560836056256,-4.85420061068653,-3.36616367133211;5.22396083186100,5.54298110515826,-6.02533369857555;-2.74982086276051,4.05736304595268,0.526727072833778;-1.04493234814343,0.296123330804093,0.625282968981890;0.253290238396859,4.99671122524120,0.698029474554989;-5.31959986718526,0.774073950173357,5.60622459896059;-3.19099651829745,-3.22632755675756,3.89871670753351;-4.09091799237673,3.56654539237373,5.89383083735814;-8.42524676527110,7.05968590181993,0.696809897821595;6.74513827766874,-2.44838428703699,2.87335760013486;-2.30958033748860,-3.16688600459192,-1.86944438307573;2.65650131956022,3.59970398263075,-0.730422433528583;0.0543724599095093,-0.0757415739107779,-5.52693241918193;-3.14374143422192,-4.31281640044459,0.220828833057216;-0.127723767202991,3.90957504769011,2.93137098320746;1.27991471432684,-0.487229017862358,-3.34624646238678;-3.61389379863546,-2.51466402368327,-0.703557935007382;3.78873892863274,-1.83909398911020,-2.28974653078626;3.78473636182684,-1.57375173796106,-2.55641148273406;-0.307931460922992,2.96440764091774,2.85361874594142;1.94273707547875,-3.65473094164351,0.212717176393721;-3.85355490146316,1.48381613173599,2.33879918881915;1.80842371561215,3.17622761889690,1.25471369812283;-0.405751912853145,-2.71906111911034,2.95923262915824;5.08658039040198,1.05742303281435,-7.13790568044084;-3.02653099502167,-5.22872875151062,-3.23223633599470;6.36095065583579,2.20372370235159,-0.543547481260867;0.0635139469957058,-3.54873780104404,1.10019476521076;1.40881927441515,2.54994463861606,3.63166251160987;4.58381413205985,1.37105312063082,-2.02266780465309;3.48783523015953,-1.30096093847941,-1.91301172865445;-2.76972379321051,-4.67975407858749,-0.901739334820310;-2.89424119585368,4.21084727328603,2.19848020279531;-2.89292122526824,0.482888802780073,0.336576313995751;3.39865885231298,5.30408584893238,3.55978119202574;-0.429115031192586,0.0270852019695077,-2.44106301060191;-1.40629926265506,-5.62374785736158,1.30011873394938;0.260941737817937,5.34445979960161,1.22439735240238;3.27538645400019,-0.921452086335730,-5.19880903555325;-0.502453271648449,2.92321012470713,0.937263723555253;0.978036135687057,-2.28392431639858,5.50139439920132;-7.32195332447304,1.93479082107255,-3.78772941628441;-2.11108554401127,2.64046536306715,-2.01462784238229;-3.37283854827833,3.20365955642871,-3.21527081273016;-2.02118883135903,1.57813125310459,3.57042637865386;-2.40955329665873,-0.129055487728423,-1.75985202786683;-1.33481567574669,0.456878742750519,2.37600258377141;-1.55371590798259,0.956098818592601,-5.20118723930340;2.07997331297951,-2.33522104833812,-5.76341626147571;4.54129327454274,1.74059108805018,3.15391592636614];
for d = 1:sim_runs
    CSI = [];
    for PKT_NUMBER = sim
        %------------generate CSI and noise using data from signpost    
%        for ii = 1:PKT_NUMBER
%             filename = sprintf('/location%d/pkt1.mat', ii);
%             Tr = load(strcat(dirpath, filename));
%        
%             for kk = 1:ANT_NUMBER
%                 
%                 eval( sprintf('CSI(ii,kk) = Tr.Ant%d.decoder.CSI.CE(20);', kk));
%                 eval(sprintf('Noise(ii, kk) = Tr.Ant%d.decoder.CSI.Noise;', kk));
%             end
%         end
        CSI = sqrt(1/2)* unifrnd (-2, 2, PKT_NUMBER, ANT_NUMBER) + 1i * unifrnd (-2, 2, PKT_NUMBER, ANT_NUMBER);
        Noise  = wgn(PKT_NUMBER,ANT_NUMBER,NOISE_STRENGTH);
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
        %global CSI;
        %CSI = sqrt(1/2)* unifrnd (-2, 2, N, M) + 1i * unifrnd (-2, 2, N, M);
        

        %% -----generate noise here  WHITTE GAISSIAN NOISE
    %     global Noise;
    %     Noise  = wgn(N,M,p);
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

        global pkt;

        pkt = struct(field1,value1, field2,value2);%define structure of packet, pkt is global variable
        for i = 1: N
           pkt(i).length = time_len(i);
           pkt(i).value = time_len(i)*SNR_alone_list(i);
        end

        %% ------calculate packets value and fullfill packes here

        knapsack_padding(M, N);


        knapsack_through_put = eval_throughput(M);

        streams = struct(field3,value3, field4,value4, field5,value5);
        master_length = 0;

        random_padding(M, N);


        random_through_put = eval_throughput(M);
        
        streams = struct(field3,value3, field4,value4, field5,value5);
        master_length = 0;
%         
        no_padding(M, N);
% 
        no_through_put = eval_throughput(M);
        
        

        result_padding = [result_padding knapsack_through_put];
        result_random = [result_random random_through_put];
        result_no = [result_no no_through_put];
    end
    padding_matrix(d,:)= result_padding;
    result_padding = [];
    random_matrix(d,:)= result_random;
    result_random = [];
    no_matrix(d,:)= result_no;
    result_no = [];
end

random_padding = sum(random_matrix,1) / d;
our_padding = sum(padding_matrix,1) / d;
no_padding = sum(no_matrix,1) / d;
figure(1)
x = sim;
% plot(x, result_ran,'r'); hold on;    plot(x, our_padding,'b');hold on;    plot(x, no_padding,'g');
plot(x, our_padding,'b',x, random_padding,'r',x, no_padding,'g');
legend('our\_padding','random\_padding','no\_padding');
