%% ---------------Evaluating throughput -------------------%%
% --------please put the resulting throughput in
% UserSelectionMethods(round,m).resulting_throughput, for each round, and
% each method m%
 
 sumUser= zeros(1,NUMBER_COMPARRE_METHODS);
 Num_Round_NO_COLLISION = zeros(1,NUMBER_COMPARRE_METHODS);
 
 for i = 1:ROUND_NUMBER
     for m = 1: NUMBER_COMPARRE_METHODS
         if UserSelectionMethods(i,m).collision_flag == 1
             continue;
         end
        Num_Round_NO_COLLISION(m) = Num_Round_NO_COLLISION(m) + 1;
        sumUser(m) = sumUser(m) +  numel(UserSelectionMethods(i,m).selected_users);
     end
 end
 AverageUsersNumber = sumUser./Num_Round_NO_COLLISION
 %?? AverageUsersNumber
 
 throughput = zeros(NUMBER_COMPARRE_METHODS,ROUND_NUMBER,N);
 for i = 1:ROUND_NUMBER %?????
     [CSI,Noise] = getCSI(N,mod(i,3)+1,M); 
      S = size(CSI,3);%?????
     for m = 1:NUMBER_COMPARRE_METHODS
         
        if UserSelectionMethods(i,m).collision_flag == 1    %???????
             continue;
        end
        
        using_selected_users = UserSelectionMethods(i,m).selected_users;%?n????i??????
        if numel(using_selected_users) == 0 %?????????0?????
             continue;
         end
         
         
         SNR_persubcarrier = zeros(numel(using_selected_users),S);
         for s =1:S           
             normalized_power = sqrt( 1./Noise(using_selected_users,:)); %???????
             H = normalized_power.*CSI(using_selected_users,:,s);
             H = H.';%????
             SNR_persubcarrier(:,s) = diag ( 1./inv(H'*H + eye(size(H,2)) ) - 1 );%??????SNR
         end
         
         for n = 1: numel(using_selected_users)   
             bers = qam64_ber(SNR_persubcarrier(n,:));
             mean_ber = mean(bers);
             throughput(m,i,using_selected_users(n))  = log2( 1+ qam64_berinv(mean_ber) ); %?m????i??n????throughput
             UserSelectionMethods(i,m).resulting_throughput = [UserSelectionMethods(i,m).resulting_throughput log2( 1+ qam64_berinv(mean_ber) )];
         end            
     end
 end
 
 
% %--------------throughput = zeros(NUMBER_COMPARRE_METHODS,ROUND_NUMBER,N);
 figure(1)
 average_throughput_perTransmission = sum(throughput,3);
 plot(average_throughput_perTransmission','--s');
 legend('SAM','MIMOMate','OPUS','Signpost');
 mean(average_throughput_perTransmission,2)
 
 figure(2)
 average_throughput_perNode = squeeze (mean(throughput,2));
 plot(average_throughput_perNode','--*');
 legend('SAM','MIMOMate','OPUS','Signpost');

save exp_result.dat UserSelectionMethods;