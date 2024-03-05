clear all
close all
clc

%% set up
errorID = [];
errorreason = [];
erreason = 0;
output_dir = 'path';

%% get directories of CT folder, RTSTRUCT file and dose file

dirr = 'path';
dirr2 = 'path';
patient_list = dir(dirr);
patient_list = {patient_list.name};
patient_list = patient_list(3:end)';

[directoriesCTDose] = get_directories_CT_Dose(dirr, patient_list);
directoriesCTDose.patient_list = str2double(directoriesCTDose.patient_list);
[directoriesDLC] = get_directories_DLC(dirr2, patient_list);
directoriesDLC.patient_list = str2double(directoriesDLC.patient_list);
save('directoriesDLC','directoriesDLC');

%% Start loop over all patients
% - skips patients that are already in the output folder
% - saves error ID in case there is a problem and skips that patient

for num = 1:height(directoriesDLC)
    CT_folder = directoriesCTDose.CT{num};
    RTDOSE_file = directoriesCTDose.RTDOSE{num};
    DLC_file = directoriesDLC.DLC{num};
    ID = extractBetween(DLC_file,'complete\','\');
    
  if ~exist(char(strcat(output_dir,'\STRUC_CT_Dose\',ID,'.mat')), 'file')
    try
            
            %% STEP 1.1 - load CT
            [CT, metas, Z_ImagePositionPatient] = dicomreadCT_fixs_dubble_clean(CT_folder);
            resol = [metas{1}.PixelSpacing;metas{1}.SliceThickness]; %dimensions of CT voxel
            
            % "handles" contains variables needed for DOSE2CT script
            handles.CT.DATA = CT;
            handles.CT.Z_pos = Z_ImagePositionPatient;
            handles.CT.META = metas;
            handles.info.dzCT = size(handles.CT.DATA,3);
            handles.info.patientname = metas{1}.PatientID;
            
            %% STEP 1.2 - load and match Dose
            [DD, metaDose] = dicomread_DOSE_one_real_dose(RTDOSE_file);
            handles.DOSE.META = metaDose;
            
            % match (interpolate) dose onto CT - they will have the same dimensions now
            Idose = DOSE2CT_intrein_DE(handles, DD);
            
            %% STEP 1.3 - load DLC
            STRUC=[];
            info = dicominfo(DLC_file);
            NumberOfContours = length(fieldnames(info.ROIContourSequence));
            StructureOfInterest = [];
            
            % load strucs from header
            for j = 1:NumberOfContours
                name = [info.StructureSetROISequence.(['Item_',num2str(j)]).ROIName];
                strucnamen{j,1} = name;
            end
            
            strucnamen = regexprep(strucnamen, '[~!@#$%^&*()_+`=,./<>?;:{}[]|-]','_');
            strucnamen = regexprep(strucnamen, ' ','_');
            strucnamen = regexprep(strucnamen, '\','_');
            strucnamen = regexprep(strucnamen,'"','');
            
            %% STEP 2.1 - extract oral cavity structure
            % structures needed: oral cavity
            
            
            oralcavity = ~cellfun(@isempty,regexpi(strucnamen,'oral'));
            match = find(oralcavity,1,'first');
            strucnamen(find(oralcavity,1,'first')) = {'OralCavity_Ext'};
            if sum(double(oralcavity))==0
                erreason = 1;
            end

            for x = 1:length(match)
                    struclocation = match(x); %struclocation = find(ismember(strucnamen,{'OralCavity_Ext'}));
                    [I , CNTOUR] = STRUCtoCT_corrected(info, metas, Z_ImagePositionPatient, size(CT) , struclocation);
                    I(I>0) = 1;
                    STRUC.(strucnamen{struclocation}).I = I;
                    STRUC.(strucnamen{struclocation}).CNTOUR = CNTOUR;
            end
                
 
            %% STEP 3 - calculate structure volumes of parotid glands and submandibular glands
            for x = 1:length(match)
                    struclocation = match(x);
                    chosen_structure = strucnamen{struclocation};
                    STRUC.(strucnamen{struclocation}).vol = length(find(double(STRUC.(strucnamen{struclocation}).I)))*(handles.CT.META{1}.PixelSpacing(1)^2*handles.CT.META{1}.SliceThickness);
            end
                
          %PatientID = [PatientID; str2double(metas{1}.PatientID)];      
          save([output_dir,'/STRUC_CT_Dose/',metas{1}.PatientID],'CT','resol','STRUC','Idose')
          fprintf('saved')
                
catch 
      errorID = [errorID;ID];
      errorreason = [errorreason, erreason];
      erreason = 0;
      save('errorID','errorID')
    end
  else 
      fprintf('%s\n', char(ID), ' already exists');
  end
end

