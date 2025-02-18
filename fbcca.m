% FBCCA�㷨ʾ��ʵ��
function [freq] = fbcca(eeg_data, fs, t,freq_list)
    % eeg_data: �����EEG���ݣ�ÿ��ͨ�����ź� 64*1000
    % fs: ����Ƶ��
    % freq_list: ���п��ܵĴ̼�Ƶ��
    
    num_freqs = length(freq_list);
    num_channels = size(eeg_data, 1);
    C1_list = zeros(1, num_freqs); % ��ʼ���洢 C1 �ĵ�Ԫ����
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
        %r�ǵ������ϵ��
        [maxVals1, ~] = max(r);
        % �ҵ��������Ե�Ƶ��
        freq(j) = maxVals1^2;
    end
    %[maxval, index] = max(C1_list);
    %P = sqrt(max_value);  % ���ϵ��p���ڦˣ���������ֵ�Ǧ˵�ƽ�������濪����
    %freq = maxval;

end
