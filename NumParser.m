function NumParser(Names, SliceNum)
prompt = 'Please type a number within the range of training data: ';
x = input(prompt);
N = length(Names);
count = 1;
flag = 0;
for i = 1:N
    M = length(SliceNum{i});
    for j = 1:M
        if count == x
            flag = 1;
            break;
        else
            count = count + 1;
        end
    end
    if flag == 1
        break;
    end
end

fprintf("The Name of the Subject is: %s.\n And the Slice Number is: %d. \n", Names{i}, SliceNum{i}(j));

end