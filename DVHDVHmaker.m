function [DVH ,x]=DVHDVHmaker(I, Idose) 

if isempty(I)==0
    
    struc=double(I); %mask data of structure
    struc(struc==0)=nan; struc(struc>1)=nan;    
    kl=numel(struc(struc==1));
  

        IdoseSTRUC=double(Idose).*struc; %excluding dose distribution outside of structure 
      clear struc 
    x=0:8.0e3;% def: dose range of interests
    HistDATA=reshape(IdoseSTRUC,1,size(IdoseSTRUC,1)*size(IdoseSTRUC,2)*size(IdoseSTRUC,3));
    HistDATA=HistDATA(~isnan(HistDATA));
    kmo=hist(HistDATA,x);% creating absolute histogram
    DVH=cumsum(kmo(end:-1:1)); % creating cumulative histogram
    DVH=DVH(end:-1:1)./kl.*100;% normalizing and inverting DVH
%   end  
  

else 
    display('Structure is empty')
    DVH=[];x=[];
end
  end

% cc=cc+1;