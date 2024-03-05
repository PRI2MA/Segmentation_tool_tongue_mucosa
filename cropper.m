function [I, M1,CTcrop,MzonderRand]=cropper(ctSTRUC,CT)

%ctSTRUCT is CT * STRUCT

I=ctSTRUC;
% I(all(all(isnan(I),3),2),:,:) = [];
% I(:,all(all(isnan(I),3),1),:) = [];
% I(:,:,all(all(isnan(I),1),2)) = [];

% M=I;
% M(isnan(I))=0;M((I>1))=1;
% Is=I;
% Is(isnan(I))=0;

fl=find(~all(all(isnan(I),3),2));
CT=CT(min(fl)-1:max(fl)+1,:,:);
fl=find(~all(all(isnan(I),3),1));
% CT(:,all(all(isnan(I),3),1),:) = [];
CT=CT(:,min(fl)-1:max(fl)+1,:);
fl=find(~all(all(isnan(I),1),2));
% CT(:,:,all(all(isnan(I),1),2)) = [];
if min(fl)==1 &&  max(fl)==size(CT,3)
    CT=CT(:,:,min(fl):max(fl));
elseif min(fl)==1
    CT=CT(:,:,min(fl):max(fl)+1);
elseif max(fl)==size(CT,3)  
    CT=CT(:,:,min(fl)-1:max(fl));
else    
CT=CT(:,:,min(fl)-1:max(fl)+1);
end
CTcrop=CT; 


I(all(all(isnan(I),3),2),:,:) = [];
I(:,all(all(isnan(I),3),1),:) = [];
I(:,:,all(all(isnan(I),1),2)) = [];M0=I;
I0=nan(size(I)+2);
I0(2:end-1,2:end-1,2:end-1)=I;
 

M=I;MzonderRand=M;MzonderRand(M>0)=1;MzonderRand(isnan(M))=0;
M(isnan(M0))=0;M((M0>1))=1;
M1=zeros(size(I)+2);
M1(2:end-1,2:end-1,2:end-1)=M;

I=I0;
end