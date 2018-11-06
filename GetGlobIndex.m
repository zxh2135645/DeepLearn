function idx_array = GetGlobIndex(img_glob)
idx_array = zeros(length(img_glob), 1);
   for j = 1:length(img_glob)
       B = regexp(img_glob(j),'\d*','Match');
       
       for ii= 1:length(B)
           if ~isempty(B{ii})
               Num(ii,1)=str2double(B{ii}(end));
           else
               Num(ii,1)=NaN;
           end
       end
       % fprintf('%d\n', Num)
       idx_array(j) = Num;
   end
end