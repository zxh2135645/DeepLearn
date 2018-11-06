function RuleOutLabel = NameRuleOutVolumeFunc(Names)
RuleOutLabel = zeros(length(Names), 1);

for i = 1:length(Names)
    switch Names{i}
        case {'CHOO_KYUNG_MIN', 'KO_KIL_OONG'}
            RuleOutLabel(i) = 1;
        otherwise
            RuleOutLabel(i) = 0;
    end
end
end