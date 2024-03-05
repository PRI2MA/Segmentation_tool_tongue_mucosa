clear all
close all
clc

%% Setup

dirr = 'path';
output_dir = 'path';

load('directoriesDLC');
patient_list = directoriesDLC.patient_list;

errorID = [];

%% Tongue Erosion

for num = 1:length(patient_list)
    ID = num2str(patient_list(num));
    
    if ~exist(char(strcat(output_dir,'\STRUC_Tongue\',ID,'.mat')), 'file')
 try  
    load([dirr,num2str(patient_list(num))])
     
    
    STRUC.TongueTop.I = double(STRUC.OralCavity_Ext.I);
     
    STRUC.TongueTop.ctSTRUC = double(CT).*double(STRUC.OralCavity_Ext.I);
    ctSTRUCHU = STRUC.TongueTop.ctSTRUC -1000; % convert CT back to Hounsfield Units (undo +1000 from Sannes script)
    %-200HU might also be appropriate but I decided on the more cautious -500HU
    STRUC.TongueTop.I(ctSTRUCHU < -500) = 0;
    STRUC.TongueTop.I(ctSTRUCHU > 500) = 0;
     
     
    Struc_resize = imresize3(STRUC.TongueTop.I,[size(STRUC.TongueTop.I,1),size(STRUC.TongueTop.I,2),size(STRUC.TongueTop.I,3)*resol(3)],'nearest');
    v = []; vr1 = []; vc1 = []; vr2 = []; vc2 = [];
    for i = 1:size(Struc_resize,2)
        [r1,c1] = find(Struc_resize(:,i,:),1,'first');
        [r2,c2] = find(Struc_resize(:,i,:),1,'last');
        if r1 >0
            v = [v;i];
        end
    end

    centerOCplane = v(round(length(v)/2));
    j = centerOCplane;
     
     
     
    se = strel('sphere',7);
    se2 = strel('sphere',3);
    se3 = strel('sphere',5);
    erodedOral = imerode(Struc_resize,se);
    erodedOral2 = imerode(erodedOral,se2);
    dilatedOral = imdilate(erodedOral2,se2);
    dilatedOral2 = imdilate(dilatedOral,se);
    erodedOral3 = imerode(dilatedOral2, se3);
    HollowTongue = dilatedOral2-erodedOral3;
     
    toplayer = HollowTongue; 
    
    middleplane = HollowTongue(:,j,:);
    rotplane = permute(middleplane,[3,2,1]);
    [r,c] = find(HollowTongue(:,j,:),1,'first');
    [r1,c1] = find(HollowTongue(:,j,:),1,'last');
    [r2,c2] = find(rotplane,1,'first');
    [r3,c3] = find(rotplane,1,'last');
    cd = c1 - c;
    
    x = [0 512 512  c3 c2 0];
    y = [0 0 round(c+cd/2) round(c+cd/2)  r2 r2 ];
    bw = poly2mask(x,y,size(Struc_resize,3),512);

    mask = repmat(bw,1,1,512);
    mask = permute(mask,[2,3,1]);
    mask = abs(mask-1);
    newtop = mask.*toplayer;
    
    
    toplayer = imresize3(newtop,[size(STRUC.TongueTop.I,1),size(STRUC.TongueTop.I,2),size(STRUC.TongueTop.I,3)],'nearest');
    
    STRUC.TongueTop.I = int16(toplayer);
    display_overlay_Tongue_Top_new(STRUC,ID,round(r2/resol(3)),CT,'path',j); % make
    %sure to use this if you want to save images of how the structure looks
    
    toplayer(toplayer==0) = nan;         %exchanges all 0 for empty elements      
    STRUC.TongueTop.doseSTRUC = double(Idose).*toplayer; %multiplies the 1s in the struct matrix with the CT values from the same positions
    STRUC.TongueTop.ctSTRUC = double(CT).*toplayer;
    
    [DVH ,x] = DVHDVHmaker(STRUC.TongueTop.I, Idose);
    STRUC.TongueTop.DVH = [DVH;x];
    
    TongueDVH = STRUC.TongueTop.DVH;
    
    save([output_dir,'Tongue_DVH\',ID],'TongueDVH');
    
    difDVH = STRUC.TongueTop.DVH(1,:)-[STRUC.TongueTop.DVH(1,2:end),0];
    STRUC.TongueTop.meandose = sum(difDVH.*STRUC.TongueTop.DVH(2,:))./(100*100);
    
    STRUC.TongueTop.vol = length(find(double(STRUC.TongueTop.I)))*(resol(1)^2*resol(3));
    
    STRUC_Tongue = STRUC.TongueTop;
    save([output_dir, 'STRUC_Tongue\',ID],'STRUC_Tongue');
    fprintf('%s\n', char(ID), ' success');
 catch
     errorID = [errorID;ID];
     save('errorID','errorID')
     fprintf('%s\n', char(ID), ' error');
 end
    end
end