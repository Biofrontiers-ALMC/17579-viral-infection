clearvars
clc

channelToRegister = 2;

folders = dir('D:\Projects\ALMC Tickets\EmmaWS\data\20240912');
folders(1:2) = [];

dataDir = fullfile(folders(1).folder, folders(1).name);
files = dir(fullfile(dataDir, 'H3N2\*.nd2'));

[optimizer,metric] = imregconfig("multimodal");

for iF = 1:numel(files)

    fn = files(iF).name;

    registeredImageStack = zeros(512, 512, 16, 'uint16');

    for ii = 1:numel(folders)

        filepath = fullfile(folders(ii).folder, folders(ii).name, 'H3N2');
        reader = BioformatsImage(fullfile(filepath, fn));

        if ii == 1
            refImage = getPlane(reader, 1, channelToRegister, 1);
            tform = [];
            figure;
            title(fn)
        else

            if ii ~= 4
                movedImage = getPlane(reader, 1, channelToRegister, 1);
            else
                movedImage = getPlane(reader, 1, 1, 1);
            end

            % Default spatial referencing objects
            fixedRefObj = imref2d(size(refImage));
            movingRefObj = imref2d(size(movedImage));

            tform = imregcorr(movedImage,movingRefObj,refImage,fixedRefObj,'transformtype','similarity','Window',true);
            % tform = imregtform(movedImage, refImage, "rigid", optimizer, metric);

            %% Display the results
            subplot(2, 2, ii)
            Ireg = imwarp(movedImage, tform, "OutputView", imref2d(size(refImage)));
            imshowpair(refImage, Ireg, "Scaling", "joint")
        end

        for iC = 1:reader.sizeC

            I = getPlane(reader, 1, iC, 1);

            if ~isempty(tform)
                Ireg = imwarp(I, tform, "OutputView",imref2d(size(refImage)));
            else
                Ireg = I;
            end

            registeredImageStack(:, :, (ii - 1) * 4 + iC) = Ireg;

        end
    end

    %% Crop the images to exclude the rotated region

    minIP = min(registeredImageStack, [], 3);
    minIP_hasdata = minIP > 0;

    leftEdge = find( any(minIP_hasdata, 1), 1, 'first');
    rightEdge = find( any(minIP_hasdata, 1), 1, 'last');

    topEdge = find( any(minIP_hasdata, 2), 1, 'first');
    bottomEdge = find( any(minIP_hasdata, 2), 1, 'last');

    registeredImageStack = registeredImageStack(topEdge:bottomEdge, leftEdge:rightEdge, :);
    
    %% Export the registered image stack
    [~, outputFN] = fileparts(fn);

    for iImg = 1:size(registeredImageStack, 3)
        if iImg == 1
            imwrite(registeredImageStack(:, :, iImg), [outputFN, '.tif'], 'Compression', 'none');
        else
            imwrite(registeredImageStack(:, :, iImg), [outputFN, '.tif'], 'Compression', 'none', ...
                'WriteMode', 'append');
        end
    end

    


end






