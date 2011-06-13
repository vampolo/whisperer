function [outTxt] = showTitles (titles, indexes, languageColumns, stems,icm)
    outTxt='';
    if isempty(indexes)
        return;
    end
    if nargin>4
        for i=1:length(indexes)
           if iscell(stems)
                outTxt=strvcat(outTxt,([strcat(titles(indexes(i),:)),'  (',cell2mat(stems(intersect(find(icm(:,indexes(i))),languageColumns))'),')']));
           else
               outTxt=strvcat(outTxt,([strcat(titles(indexes(i),:)),'  (',(stems(intersect(find(icm(:,indexes(i))),languageColumns))'),')']));
           end
        end
    else
        outTxt=titles(indexes,:);
    end
end