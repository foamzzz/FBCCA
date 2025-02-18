function accuracy = cplist(A, B)
    % compare_lists 函数：比较两个列表A和B的元素是否相同，并计算准确率
    % 输入：
    %   A - 第一个列表
    %   B - 第二个列表
    % 输出：
    %   accuracy - 两个列表元素相同的准确率（百分比）

    % 检查两个列表的长度是否相同
    if length(A) ~= length(B)
        error('列表A和B的长度不相同！');
    end

    % 比较A和B对应位置上的元素
    correct_count = sum(A == B);

    % 计算准确率
    accuracy = correct_count / length(A) * 100;

end
