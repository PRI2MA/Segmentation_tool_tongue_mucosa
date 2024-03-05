function [directories] = get_directories_DLC(dirr, patient_list)
% get_directories returns the path for CT_folder, Dose_file and the largest
% RTSTRUCT_file. The largest RTSTRUCT file is mostly the one needed and
% circling through all files in the main script takes too much time. The
% Trouble_Shooting scripts deal with the few patients where a different
% RTSTRUCT file is needed.

for i = 1:length(patient_list)
    PatientID = patient_list{i};
    dirk = [dirr, PatientID];
    p = genpath(dirk);
    p2 = strsplit(p, ';');
    DLC_folder = p2{1};

    DLC_file = dir(DLC_folder);
    DLC_file = {DLC_file.name};
    appen = contains(DLC_file,'.dcm');
    if sum(appen) == 0
       
        DLC_file = [DLC_folder,'\', DLC_file{(contains(DLC_file,'.DCM'))}];
    else
        DLC_file = [DLC_folder,'\', DLC_file{(contains(DLC_file,'.dcm'))}];
    end
    
    DLC{i} = DLC_file;
    
end

DLC = DLC';

directories = table(patient_list,DLC);
end

