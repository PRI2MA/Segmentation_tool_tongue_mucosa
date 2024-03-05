function MESSEDWITH_Idose=DOSE2CT_intrein_DE(handles, DD)

%----determine resolution CT and DOSE
slice_space=(max(handles.CT.Z_pos)-min(handles.CT.Z_pos))/(length(handles.CT.Z_pos)-1);
% if slice_space==5; slice_space=3; end
CTspacing=[handles.CT.META{1}.PixelSpacing(1),handles.CT.META{1}.PixelSpacing(2),slice_space];
if isempty(handles.DOSE.META.SliceThickness); 
    display('zelf gemaakt')
    DDspacing=[handles.DOSE.META.PixelSpacing(1),handles.DOSE.META.PixelSpacing(2),handles.DOSE.META.PixelSpacing(2)]
else
    DDspacing=[handles.DOSE.META.PixelSpacing(1),handles.DOSE.META.PixelSpacing(2),handles.DOSE.META.SliceThickness];
    handles.DOSE.META.SliceThickness;
    
end


%---determine absolute dose resolution size in mm
lengthDD=size(DD).*DDspacing;

resample=(size(DD).*CTspacing-(1-CTspacing./DDspacing))./((lengthDD));

xnew{1}=1:resample(1):size(DD,1);
ynew{1}=1:resample(2):size(DD,2);
xnew{2}=1:resample(1):size(DD,1)+resample(1);
ynew{2}=1:resample(2):size(DD,2)+resample(2);
znew{1}=1:resample(3):size(DD,3);
znew{2}=1:resample(3):size(DD,3)+resample(3);

spir=[[length(xnew{1}),length(ynew{1}),length(znew{1})].*CTspacing;[length(xnew{2}),length(ynew{2}),length(znew{2})].*CTspacing]-[lengthDD;lengthDD];
[x n]=min(abs(spir));


    xnew=xnew{n(1)};
ynew=ynew{n(2)};
znew=znew{n(3)};
%-- check interpolation
if isfield(handles.DOSE, 'Idose')
     display('interpolation check has allready performed')
else
    lengthDDnew=[length(xnew),length(ynew),length(znew)].*CTspacing;
    if sum(lengthDD==floor(lengthDDnew))==3 || sum(lengthDD==floor(lengthDDnew-resample))==3 || (sum(lengthDD==floor(lengthDDnew))==2 && lengthDD(3)==floor(lengthDDnew(3)-2*resample(3)))
       display( ['Interpolation of ',handles.info.patientname, ' has been performed correctly'])
    else
        display([ 'Interpolation of ', handles.info.patientname, ' has NOT !!! been performed correctly'])
        display(['it should be:      ',num2str(lengthDD)])
        display(['...but it is: ' num2str(lengthDDnew)])
    end
end

%--- interpolating dose to resolution of CT
[xnew ynew znew]=meshgrid(ynew,xnew,znew);
DDntp=interp3(DD,xnew,ynew,znew);

       
%--- obtaining location of dose in CT
    posCT=handles.CT.META{1}.ImagePositionPatient;posCT(3)=min(handles.CT.Z_pos);
    posDD=handles.DOSE.META.ImagePositionPatient; 
    posDD=posDD'-((DDspacing./2)-(CTspacing./2));
    start=round((posDD-posCT')./CTspacing);%plus 1, otherwise this calculates to be 0 when equally positioned
  
        
%         if start>1 
%           
%         ystart=round((handles.DOSE.META.ImagePositionPatient(1))-handles.CT.META{1}.ImagePositionPatient(1)./(handles.CT.META{1}.PixelSpacing(1)));
%         xstart=round((handles.DOSE.META.ImagePositionPatient(2))-handles.CT.META{1}.ImagePositionPatient(2)./(handles.CT.META{1}.PixelSpacing(2)));
%         zstart=abs(round(min(handles.CT.Z_pos)-handles.DOSE.META.ImagePositionPatient(3))./(slice_space));
% round(meta.ImagePositionPatient(3)-info1{1}.ImagePositionPatient(3)./(slice_space))

%---fitting dose in same absolute grid of CT
        if start(2)<1;
           DDntp=DDntp(1+abs(start(2)):end,:,:);start(2)=1;
        end
        if start(1)<1;
            DDntp=DDntp(:,1+abs(start(1)):end,:);start(1)=1;
        end
        if start(3)<1;
           DDntp=DDntp(:,:,1+abs(start(3)):end);start(3)=1;
        end
        
Idose=double(handles.CT.DATA).*0;
        if (start(2)+size(DDntp,1)-1)>size(Idose,1);
           DDntp=DDntp(1:end-((start(2)+size(DDntp,1)-1)-size(Idose,1)),:,:);
        end
        if (start(1)+size(DDntp,2)-1)>size(Idose,2);
            DDntp=DDntp(:,1:end-((start(1)+size(DDntp,2)-1)-size(Idose,2)),:);
        end
        if (start(3)+size(DDntp,3)-1)>size(Idose,3);
           DDntp=DDntp(:,:,1:end-((start(3)+size(DDntp,3)-1)-size(Idose,3)));
        end
       
       
%---hanging interpolated dose in CT
        Idose(start(2):(start(2)+size(DDntp,1)-1),start(1):(start(1)+size(DDntp,2)-1),start(3):(start(3)+size(DDntp,3)-1))=DDntp;

   MESSEDWITH_Idose=Idose;

end