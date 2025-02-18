% 1. ��ȡ����
% �����ļ�����ǰ׺�ͺ�׺
file_prefix = 's';  % �ļ���ǰ׺
file_extension = '.mat';  % �ļ���չ��
% ׼ȷ����֤��Ϣ
freq_list = zeros(1, 40);
fre_exam = load('Freq_Phase.mat');
% 2. ��������
sampling_rate = 250;  % ����Ƶ�� 250Hz
stim_freqs = [8, 9, 10, 11, 12, 13, 14, 15, ...
              8.2, 9.2, 10.2, 11.2, 12.2, 13.2, 14.2, 15.2, ...
              8.4, 9.4, 10.4, 11.4, 12.4, 13.4, 14.4, 15.4, ...
              8.6, 9.6, 10.6, 11.6, 12.6, 13.6, 14.6, 15.6, ...
              8.8, 9.8, 10.8, 11.8, 12.8, 13.8, 14.8, 15.8];  % 40��Ŀ��Ƶ��
t = 1:1000;  
        
% ����ͨ��Ƶ�� wp �����Ƶ�� ws
wp = {[5, 90], [14, 90], [22, 90], [30, 90], [38, 90]};  % ͨ��Ƶ��
ws = {[3, 92], [12, 92], [20, 92], [28, 92], [36, 92]};  % ���Ƶ��
        
% �����ʺ��˲�������
srate = 250;
order = 15;
rp=0.5;
% ����˲�����
filterbank = generate_filterbank(wp, ws, srate, order, rp);  % ��ʼ���˲�����
        
% �˲���Ȩ��ϵ��
filterweights = arrayfun(@(idx_filter) (idx_filter + 1) ^ (-1.25) + 0.25, 0:4);
        
% ʹ��forѭ����ȡÿ���ļ�
for h = 1:6
    % �����ļ���
    file_name = [file_prefix num2str(h) file_extension];
    
    % ����ļ��Ƿ����
    if exist(file_name, 'file')
        % �����ļ�
        data = load(file_name);
        eeg_data = data.data;  % ��ȡ���ݾ���
        
        % ��ȡ����һ�����������
        for block_index = 1:size(eeg_data, 4)
            data_first_block = eeg_data(:, :, :, block_index);
            % 3. ��������
            for stim_index = 1:size(stim_freqs,2)
                % ��ȡĿ��̼������ݣ�ά���� [64, 1500]��64 ���缫��1500 ��ʱ��㣩
                data_at_time_point = data_first_block(:, :, stim_index);  % ȥ��Ŀ��̼�ά�ȣ��õ� [64, 1500]
                %��ȡ��Ҷ����Ҷ����Pz��PO5��PO3��POz��PO4��PO6��O1��Oz��O2����ssvep�ź�
                data_at_time_point = data_at_time_point([48, 54, 55, 56, 57, 58, 61, 62, 63], :);
                % ��ȡ��ǰ�̼��ε�����
                stim_data = data_at_time_point(:, 251:1250);  % ��ǰ�̼���ȥ���̼�ǰ0.5s�ʹ̼���0.5s  9*1000
                
                % 4. ��ͨ�˲�
                n_channels = size(stim_data, 1);  % ͨ������Ӧ���� 9
                n_samples = size(stim_data, 2);   % ÿ��ͨ�������ݵ�����Ӧ���� 1000
            
                % ��ʼ���˲�����ź�
                Xs = zeros(length(filterbank), n_channels, n_samples);  % ÿ���˲��������
            
                % ��ÿ���˲��������˲�
                for i = 1:length(filterbank)  % ��ÿ���˲���
                    for c = 1:n_channels  % ��ÿ��ͨ��
                        % ʹ�� filtfilt ��������λ�˲�
                        Xs(i, c, :) = filtfilt(filterbank{i}, 1, stim_data(c, :));  % ÿ��ͨ�����ź��˲�
                    end
                    % 5. ʹ��FBCCA�㷨,���˲������ݷ���CCA
                    eeg_data_c =squeeze(Xs(i, :, :)); 
                    estimated_p = fbcca(eeg_data_c', sampling_rate, t,stim_freqs);
                    freq_list= freq_list+ filterweights(i) .* estimated_p;
                end
                [max_value, max_index] = max(freq_list);
                freq_list = zeros(1, 40);
                % 6. �����ǰ�̼��εĹ���Ƶ��
                %fprintf('�̼��� %d �Ĺ���Ƶ����: %.2f Hz\n', stim_index, stim_freqs(max_index));
                fre_res(stim_index) = stim_freqs(max_index);
            end
            accuracy(block_index) = cplist(fre_res,fre_exam.freqs);
        end
        % ����ÿ���ļ�6���Դε�ƽ��׼ȷ�� 
        acc_list(h)=mean(accuracy);
    else
        disp(['�ļ� ' file_name ' ������']);
    end
    fprintf('S%d�ļ���׼ȷ�ʣ�%.2f%%\n', h, acc_list(h));
end
fprintf('6���ļ���׼ȷ�ʣ�%.2f%%\n',mean(acc_list));