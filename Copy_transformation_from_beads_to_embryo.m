function Copy_transformation_from_beads_to_embryo()

% This function copies registration information from the beads to the embryo

Folder_path = cd; % Note the current folder
NumViews = 6; % Input the number of views
Numtps = 84; % Input the number of time points

% Read the beads.xml file
fileID = fopen(strcat(Folder_path,'/beads/beads.xml'));
beads = textscan(fileID,'%s','Delimiter','\n');
fclose(fileID);

% Make note of the lines that need to be copied for each view
To_be_copied = cell(NumViews,1);
for i = 1:NumViews
    idx = ~cellfun('isempty',strfind(beads{1},strcat('<ViewRegistration timepoint="0" setup="',num2str(i-1),'">')));
    To_be_copied{i} = beads{1}(find(idx)+1:find(idx)+4);
end

% Read the embryo.xml file
fileID = fopen(strcat(Folder_path,'/embryo/embryo.xml'));
embryo = textscan(fileID,'%s','Delimiter','\n');
fclose(fileID);

% Duplicate the embryo.xml file to a new file named embryo_update.xml file. Do this directly in the folder before running the code.
% Open the embryo_update.xml file
fileID = fopen(strcat(Folder_path,'/embryo/embryo_update.xml'),'w');

idx_old = 0;

% Loop through every time point
for tp = 1:Numtps
    % Loop through every view
    for i = 1:NumViews
        % Find the starting line into which the registration information needs to be copied
        idx_new = find(~cellfun('isempty',strfind(embryo{1},strcat('<ViewRegistration timepoint="',num2str(tp-1),'" setup="',num2str(i-1),'">'))));
        
        % Paste the registration from the beads.xml file to the embryo_update.xml file
        fprintf(fileID,'%s\r\n',embryo{1}{idx_old+1:idx_new});
        fprintf(fileID,'%s\r\n',To_be_copied{i}{1:4});
        
        idx_old = idx_new;
        
    end
    inc = 1;
    % Do the same as above for the second channel. Comment out lines 45 to 54 if only one channel is available.
    for i = NumViews+1:NumViews*2
        
        idx_new = find(~cellfun('isempty',strfind(embryo{1},strcat('<ViewRegistration timepoint="',num2str(tp-1),'" setup="',num2str(i-1),'">'))));
        
        fprintf(fileID,'%s\r\n',embryo{1}{idx_old+1:idx_new});
        fprintf(fileID,'%s\r\n',To_be_copied{inc}{1:4});
        
        idx_old = idx_new;
        inc = inc+1;
    end
end
fprintf(fileID,'%s\r\n',embryo{1}{idx_old+1:end});
fclose(fileID); % close the file