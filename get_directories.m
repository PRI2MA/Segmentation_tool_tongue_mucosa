function [directories] = get_directories(dirr, patient_list)
% get_directories returns the path for CT_folder, Dose_file and the largest
% RTSTRUCT_file. The largest RTSTRUCT file is mostly the one needed and
% circling through all files in the main script takes too much time. The
% Trouble_Shooting scripts deal with the few patients where a different
% RTSTRUCT file is needed.

for i = 1:length(patient_list)
    PatientID = patient_list{i};
    dirk = [dirr,'\', PatientID];
    p = genpath(dirk);
    p1 = strrep(p, '-','_');
    p1 = strrep(p1, ';',' ');
    p2 = strsplit(p1);

    CT_folder = p2{(contains(p2,'\CT'))};
    
    Dose_folder = p2{(contains(p2,'\RTDOSE'))};
    Dose_file = dir(Dose_folder);
    Dose_file = {Dose_file.name};
    appen = contains(Dose_file,'.dcm');
    if sum(appen) == 0
       
        Dose_file = [Dose_folder,'\', Dose_file{(contains(Dose_file,'.DCM'))}];
    else
        Dose_file = [Dose_folder,'\', Dose_file{(contains(Dose_file,'.dcm'))}];
    end
    
    CT{i} = CT_folder;
    RTSTRUCT{i} = RTSTRUCT_file;
    RTDOSE{i} = Dose_file;
end

CT = CT';
RTSTRUCT = RTSTRUCT';
RTDOSE = RTDOSE';

directories = table(patient_list,CT,RTSTRUCT,RTDOSE);
end

