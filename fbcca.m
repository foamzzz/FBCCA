% FBCCA算法示例实现
function [freq] = fbcca(eeg_data, fs, t,freq_list)
    % eeg_data: 输入的EEG数据，每个通道的信号 64*1000
    % fs: 采样频率
    % freq_list: 所有可能的刺激频率
    
    num_freqs = length(freq_list);
    num_channels = size(eeg_data, 1);
    C1_list = zeros(1, num_freqs); % 初始化存储 C1 的单元数组
   % n = 2:2:num_channels;
    for j = 1:num_freqs
        fre = freq_list(j);
        target_signal =[sin(2*pi*fre*t/fs);
                        cos(2*pi*fre*t/fs);
                        sin(4*pi*fre*t/fs);
                        cos(4*pi*fre*t/fs);
                        sin(6*pi*fre*t/fs);
                        cos(6*pi*fre*t/fs)]; % 6*1000
        target_signal = target_signal';  %1000*6
        [Wx, Wy, r] = canoncorr(eeg_data, target_signal);
        %r是典型相关系数
        [maxVals1, ~] = max(r);
        % 找到最大相关性的频率
        freq(j) = maxVals1^2;
    end
    %[maxval, index] = max(C1_list);
    %P = sqrt(max_value);  % 相关系数p等于λ，这里特征值是λ的平方，后面开根号
    %freq = maxval;

end
