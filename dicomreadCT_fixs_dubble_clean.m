function [DATA, metas, Z_ImagePositionPatient]=dicomreadCT_fixs_dubble_clean(CT_folder)

d=dir(CT_folder);n={d.name}';slices = n(~ismember(n,{'.','..'}));
meta=dicominfo(fullfile(CT_folder,slices{1}));

    sz=size(slices,1);


DATA=zeros([meta.Rows,meta.Columns,sz],'int16');
% test=[]
for i=1:sz
    waar=fullfile(CT_folder,slices{i});
    metainf=dicominfo(waar);
    metas{i}=metainf;
    Z_ImagePositionPatient(i)=metainf.ImagePositionPatient(3);
    CT0(:,:,i)=dicomread(waar).*metainf.RescaleSlope + (metainf.RescaleIntercept+1000);

end

[~,  k]=sort(Z_ImagePositionPatient,'ascend');
Z_ImagePositionPatient=Z_ImagePositionPatient(k);

     DATA=CT0(:,:,k);
     metas=metas(k);


[uniqueA, i, j] = unique(Z_ImagePositionPatient,'first');
% indexToDupes = find(not(ismember(1:numel(Z_ImagePositionPatient),i)));
DATA=DATA(:,:,ismember(1:numel(Z_ImagePositionPatient),i));
% Lct3(DATA(:,:,ismember(1:numel(Z_ImagePositionPatient),i)),[800 1200])
Z_ImagePositionPatient=Z_ImagePositionPatient(ismember(1:numel(Z_ImagePositionPatient),i));

DATA(end:-1:1,:,:);
display('CT is loaded')







