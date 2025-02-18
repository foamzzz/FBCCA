function accuracy = cplist(A, B)
    % compare_lists �������Ƚ������б�A��B��Ԫ���Ƿ���ͬ��������׼ȷ��
    % ���룺
    %   A - ��һ���б�
    %   B - �ڶ����б�
    % �����
    %   accuracy - �����б�Ԫ����ͬ��׼ȷ�ʣ��ٷֱȣ�

    % ��������б�ĳ����Ƿ���ͬ
    if length(A) ~= length(B)
        error('�б�A��B�ĳ��Ȳ���ͬ��');
    end

    % �Ƚ�A��B��Ӧλ���ϵ�Ԫ��
    correct_count = sum(A == B);

    % ����׼ȷ��
    accuracy = correct_count / length(A) * 100;

end
