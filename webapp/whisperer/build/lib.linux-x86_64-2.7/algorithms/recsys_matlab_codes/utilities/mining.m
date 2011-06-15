fid = fopen('urmMLmining.txt','w');
for i=1:size(urmML,1) 
    nonzerosindex=find(urmML(i,:)~=0);
    for j=1:length(nonzerosindex)
        fprintf(fid,'%d ',nonzerosindex(j));
    end
    fprintf(fid,'\n');
end