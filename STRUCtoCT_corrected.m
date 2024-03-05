function [I  CNTOUR]= STRUCtoCT_DE(info, infoCT, Z_ImagePositionPatient, sizeCT , StructureOfInterest)
    tot=1;
    Nofpixels=sizeCT(1);
    cutindex=3;

% for tot=1:length(StructureOfInterest)
    I=int16(zeros(sizeCT)); 
 for com=1:sizeCT(3)
     CNTOUR{com}{1}=[];
 end
    data=[];
    NumberOfContourPoints=0;
    name=info.StructureSetROISequence.(['Item_',num2str(StructureOfInterest(tot))]).ROIName;
    str=['Loading contour called: ',name];
    disp(str)
    
%-- reading structure and information
if isfield(info.ROIContourSequence.(['Item_',num2str(StructureOfInterest(tot))]),'ContourSequence')
    NumberOfContourSlices=length(fieldnames(info.ROIContourSequence.(['Item_',num2str(StructureOfInterest(tot))]).ContourSequence));
    for k=1:NumberOfContourSlices
        NumberOfContourPoints=[NumberOfContourPoints;info.ROIContourSequence.(['Item_',num2str(StructureOfInterest(tot))]).ContourSequence.(['Item_',num2str(k)]).NumberOfContourPoints];
        data=[data;info.ROIContourSequence.(['Item_',num2str(StructureOfInterest(tot))]).ContourSequence.(['Item_',num2str(k)]).ContourData];
    end
    
% Picking out xyz coordinates from each individual contourpoint from
% variable 'structure data' and save them in variables v1, v2, and v3 for x, y,
% and z coordinates respectively. V1, v2, and v3 have to be altered for
% matching the coordinate systems of the CT images and the RT STRUCT.
% ImagePositionPatient, which describes the minimum value of the CT
% images in one direction, is subtracted from v1. This answer is
% divided by the distance of 2 different voxels among the corresponding
% axis. Eventually Matlabs function 'poly2mask', which computes a
% binary mask from the contour, is used to sum each contour.
    for l=1:NumberOfContourSlices
        v1=[];
        v2=[];
        v3=[];
        
        for m=sum(NumberOfContourPoints(1:l)*3)+1:cutindex:sum(NumberOfContourPoints(1:(l+1))*3)-2
            v1=[v1 data(m)];
            v2=[v2 data(m+1)];
            v3=[v3 data(m+2)];
        end
        
         slice_space=(max(Z_ImagePositionPatient)-min(Z_ImagePositionPatient))/(length(Z_ImagePositionPatient)-1);

        v11=(v1-infoCT{1}.ImagePositionPatient(1))./(infoCT{1}.PixelSpacing(1))+1;
        v22=(v2-infoCT{1}.ImagePositionPatient(2))./(infoCT{1}.PixelSpacing(2))+1;
        v33=(v3-min(Z_ImagePositionPatient))./(slice_space)+1;
       
% ---creating mask --> these are used for analysis
        if round(v33(1))>0 ; 
            I(:,:,round(v33(1)))=  I(:,:,round(v33(1)))+int16(poly2mask(v11,v22,Nofpixels,Nofpixels));
            I(I == 2) = 0; % ADDED THIS LINE
        end

% ---getting line contour/coordinates --> these are used for visualisation only   
     if round(v33(1))>0 
        if isempty(CNTOUR{round(v33(1))}{1}) 
             contourtje=[v11;v22];%contourtje=[contourtje,contourtje(:,1)];
            CNTOUR{round(v33(1))}{1}=contourtje;
        elseif exist('CNTOUR{round(v33(1)+1)}{2}')==0 
          
           CNTOUR{round(v33(1))}{2}=[v11;v22];
        else
            'doebel'
            'doebel'  
        end
     end
   end
else
    I=[];
    CONTOUR=[];
end
 end



