function [selected_index_list, sorted_signal_strength_list] = find_orth_vector_for_acpad(pkt_num, ant_num)

N = pkt_num ;
M = ant_num ;
global CSI;
global master_length;
global pkt;
% global selected_index_list;

spare_signal_strength_list = zeros(M,M);  %record SNR-based spared packets of each stream

orthogonal_set = zeros(N, M);
quantize_set = ones(1, N );
    for i = 1 : N
        orthogonal_set(i,M) = i;
        CSI_per_user = CSI(i,:);
        CSI_per_user_direction = CSI_per_user/norm(CSI_per_user);
        orthogonal__directions = null(CSI_per_user_direction);
        CSI_vectors = [orthogonal__directions,CSI_per_user_direction']; % orthogonol vectors for ith user

        inner_products = (abs (CSI*CSI_vectors) ).^2;
        norms_CSI = (diag (CSI*CSI') );
        norms_vectors = (diag (CSI_vectors'*CSI_vectors) );
        norms = norms_CSI* norms_vectors';
        metric_proximty_per_user(i,:,:) = inner_products./norms;
        %-------------find M-1 most orthogonal users with ith user
        for j = 1 : M-1
            orthogonal_set(i, j) = find(metric_proximty_per_user(i,:,j) == max(metric_proximty_per_user(i,:,j)), 1 );
            quantize_set(i) = quantize_set(i) + max(metric_proximty_per_user(i,:,j));
        end
    end
    
    max_index  = find( quantize_set == max(quantize_set), 1 );
    
    selected_index_list = orthogonal_set(max_index,:);
    %  calculate SNR-based spared packets of each stream
    i = selected_index_list(M);
    for j = 1:M    
        sorted_strength = sorted(metric_proximty_per_user(i,:,selected_index_list(j)));
        if j == M
            sorted_strength = sorted_strength(N-M-1:N-1);
        else
            sorted_strength = sorted_strength(N-M:N);
        end
        for ii = 1:M
            sorted_signal_strength_list(j,ii) = find(metric_proximty_per_user(i,:,selected_index_list(j)) == sorted_strength(ii) , 1);
            metric_proximty_per_user(find(metric_proximty_per_user(i,:,selected_index_list(j)) == sorted_strength(ii) , 1)) = -1;
        end
    end
    
    
    
%---------set master length  
max_length = 0;
for p = 1: M
    if max_length < pkt(selected_index_list(p)).length
        max_length = pkt(selected_index_list(p)).length;
    end
end  
master_length = max_length;   




