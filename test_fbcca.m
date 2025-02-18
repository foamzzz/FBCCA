% 1. 提取数据
% 定义文件名的前缀和后缀
file_prefix = 's';  % 文件名前缀
file_extension = '.mat';  % 文件扩展名
% 准确率验证信息
freq_list = zeros(1, 40);
fre_exam = load('Freq_Phase.mat');
% 2. 参数设置
sampling_rate = 250;  % 采样频率 250Hz
stim_freqs = [8, 9, 10, 11, 12, 13, 14, 15, ...
              8.2, 9.2, 10.2, 11.2, 12.2, 13.2, 14.2, 15.2, ...
              8.4, 9.4, 10.4, 11.4, 12.4, 13.4, 14.4, 15.4, ...
              8.6, 9.6, 10.6, 11.6, 12.6, 13.6, 14.6, 15.6, ...
              8.8, 9.8, 10.8, 11.8, 12.8, 13.8, 14.8, 15.8];  % 40个目标频率
t = 1:1000;  
        
% 定义通带频率 wp 和阻带频率 ws
wp = {[5, 90], [14, 90], [22, 90], [30, 90], [38, 90]};  % 通带频率
ws = {[3, 92], [12, 92], [20, 92], [28, 92], [36, 92]};  % 阻带频率
        
% 采样率和滤波器阶数
srate = 250;
order = 15;
rp=0.5;
% 设计滤波器组
filterbank = generate_filterbank(wp, ws, srate, order, rp);  % 初始化滤波器组
        
% 滤波器权重系数
filterweights = arrayfun(@(idx_filter) (idx_filter + 1) ^ (-1.25) + 0.25, 0:4);
        
% 使用for循环读取每个文件
for h = 1:6
    % 构建文件名
    file_name = [file_prefix num2str(h) file_extension];
    
    % 检查文件是否存在
    if exist(file_name, 'file')
        % 加载文件
        data = load(file_name);
        eeg_data = data.data;  % 获取数据矩阵
        
        % 提取其中一个区块的数据
        for block_index = 1:size(eeg_data, 4)
            data_first_block = eeg_data(:, :, :, block_index);
            % 3. 处理数据
            for stim_index = 1:size(stim_freqs,2)
                % 提取目标刺激的数据，维度是 [64, 1500]（64 个电极，1500 个时间点）
                data_at_time_point = data_first_block(:, :, stim_index);  % 去掉目标刺激维度，得到 [64, 1500]
                %提取顶叶和枕叶区域（Pz、PO5、PO3、POz、PO4、PO6、O1、Oz和O2）的ssvep信号
                data_at_time_point = data_at_time_point([48, 54, 55, 56, 57, 58, 61, 62, 63], :);
                % 提取当前刺激段的数据
                stim_data = data_at_time_point(:, 251:1250);  % 当前刺激段去除刺激前0.5s和刺激后0.5s  9*1000
                
                % 4. 带通滤波
                n_channels = size(stim_data, 1);  % 通道数，应该是 9
                n_samples = size(stim_data, 2);   % 每个通道的数据点数，应该是 1000
            
                % 初始化滤波后的信号
                Xs = zeros(length(filterbank), n_channels, n_samples);  % 每个滤波器的输出
            
                % 对每个滤波器进行滤波
                for i = 1:length(filterbank)  % 对每个滤波器
                    for c = 1:n_channels  % 对每个通道
                        % 使用 filtfilt 进行零相位滤波
                        Xs(i, c, :) = filtfilt(filterbank{i}, 1, stim_data(c, :));  % 每个通道的信号滤波
                    end
                    % 5. 使用FBCCA算法,将滤波后数据放入CCA
                    eeg_data_c =squeeze(Xs(i, :, :)); 
                    estimated_p = fbcca(eeg_data_c', sampling_rate, t,stim_freqs);
                    freq_list= freq_list+ filterweights(i) .* estimated_p;
                end
                [max_value, max_index] = max(freq_list);
                freq_list = zeros(1, 40);
                % 6. 输出当前刺激段的估计频率
                %fprintf('刺激段 %d 的估计频率是: %.2f Hz\n', stim_index, stim_freqs(max_index));
                fre_res(stim_index) = stim_freqs(max_index);
            end
            accuracy(block_index) = cplist(fre_res,fre_exam.freqs);
        end
        % 计算每个文件6个试次的平均准确率 
        acc_list(h)=mean(accuracy);
    else
        disp(['文件 ' file_name ' 不存在']);
    end
    fprintf('S%d文件的准确率：%.2f%%\n', h, acc_list(h));
end
fprintf('6个文件总准确率：%.2f%%\n',mean(acc_list));