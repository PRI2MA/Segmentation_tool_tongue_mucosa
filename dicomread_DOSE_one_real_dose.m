function [DD, meta]=dicomread_DOSE_one_real_dose(dirlocfile1)

% dirloc='H:\Data\DATA_SHAP';
% [dirfile dirloc]=uigetfile({'*.dcm'},'pick a DD',dirloc);dirfile=dirfile(1:end-4);

%     meta=dicominfo([dirloc,dirfile,'.dcm']);
%     DD=double(squeeze(dicomread([dirloc,dirfile,'.dcm'])));

% dirlocfile1=DIRs.(patjes{patnum1}).DOSE.dir;
% meta=DIRs.(patjes{patnum1}).DOSE.meta;
% splitDIRLOC=regexp(dirlocfile1,'\','split')';dirloc=dirlocfile1(1:end-length(splitDIRLOC{end}));
% direct=dir(dirloc);
sz=1;%size(direct,1)-2;

if sz>1
for i=1:sz
    
%     DATA(:,:,i)=dicomread([dirloc,direct(i+2).name]);
    
    metainf=dicominfo([dirloc,direct(i+2).name]);
    scaly{i}=metainf.DoseGridScaling;
    metas{i}=metainf;
    Z_ImagePositionPatient(i)=metainf.ImagePositionPatient(3);
end

[m k]=sort(Z_ImagePositionPatient,'ascend');
Z_ImagePositionPatient=m;
[l b]=min(k);
meta=metas{b};
if isempty(meta.SliceThickness)
meta.SliceThickness=(Z_ImagePositionPatient(end)-Z_ImagePositionPatient(1))./(sz-1);
% m=m(end:-1:1);k=k(end:-1:1);
display( 'Helax')
else
   

end
h=1;
for kok=k
   ok= metas{kok};
     DATA(:,:,h)=double(squeeze(dicomread([dirloc,direct(kok+2).name]))).* ok.DoseGridScaling;
    
     h=h+1;
end

% DATA=DATA(:,:,end:-1:1);
DD=DATA.*3900;


else
 meta=dicominfo(dirlocfile1);
    DD=double(squeeze(dicomread(dirlocfile1)));
    DD=DD.*meta.DoseGridScaling.*100;
    
end

end