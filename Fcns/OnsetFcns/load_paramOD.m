function paramOD=load_paramOD(bird,cID)
try
    load(['Data\' bird '\MCMC\paramOD_standard.mat'],'paramOD');%load the standard one
catch
    disp('cant find standard params')
end
% [num,txt]=xlsread(['Data\' bird '\MCMC\paramOD.xlsx'],bird);%then see if we need to update any of them
% c=num(:,1);
ind=0;%c==cID;%find this cell-day
if sum(ind)==1
    fields=txt(1,3:end);%all the possible fields across all cells days that we might have editted 
    vals=num(:,3:end);
    fields=fields(1:size(vals,2));
    for f=1:length(fields)
        if ~isnan(vals(ind,f))
            disp(['paramOD.' fields{f} '=' num2str(vals(ind,f)) ';'])
            eval(['paramOD.' fields{f} '=' num2str(vals(ind,f)) ';'])
        end
    end
    fprint('loading new params')
elseif sum(ind)>1
    error('how did you put it down twice? fuck you')
end