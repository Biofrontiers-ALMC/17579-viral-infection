clearvars
clc

folders = dir('D:\Projects\ALMC Tickets\EmmaWS\data\20240912');
folders(1:2) = [];

dataDir = fullfile(folders(1).folder, folders(1).name);
files = dir(fullfile(dataDir, 'H3N2\*.nd2'));

for iF = 1:numel(files)

    fn = files(iF).name;

    imageStack = zeros(512, 512, 16, 'uint16');

    for ii = 1:numel(folders)

        filepath = fullfile(folders(ii).folder, folders(ii).name, 'H3N2');

        reader = BioformatsImage(fullfile(filepath, fn));

        for iC = 1:4
            imageStack(:, :, ((ii - 1) * 4) + iC) = getPlane(reader, 1, iC, 1);
        end
    end

    %%

    %Register the image stack using only translation and rotation
    refImage = 1;

    [optimizer,metric] = imregconfig("monomodal");

    fixed = imageStack(:, :, refImage);

    registeredImageStack = zeros(512, 512, 16, 'uint16');

    for ii = 1:size(imageStack, 3)

        moving = imageStack(:, :, ii);

        registeredImageStack(:, :, ii) = imregister(moving,fixed,"rigid",optimizer,metric);
    end

    %% Crop the registered images



    %% Export the registered image stack
    [~, outputFN] = fileparts(fn);

    for ii = 1:size(registeredImageStack, 3)
        if ii == 1
            imwrite(registeredImageStack(:, :, ii), [outputFN, '.tif'], 'Compression', 'none');
        else
            imwrite(registeredImageStack(:, :, ii), [outputFN, '.tif'], 'Compression', 'none', ...
                'WriteMode', 'append');
        end
    end

end






