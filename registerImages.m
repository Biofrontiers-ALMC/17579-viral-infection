function registerImages(dataDir, outputDir, varargin)
%REGISTERIMAGES  Register images and save as a new stack
%
%  REGISTERIMAGES(DATADIR, OUTPUTDIR) will process the ND2-files specified
%  in the main directory DATADIR. Each ND2 file should contain at least
%  one image which is used to register all images in the rest of the file.
%  This function will output a single TIFF-stack of the registered images.
%  Note that the registered images will be cropped to the smallest region
%  that contains data.
%
%  The files are assumed to be stored in the following directory structure
%  and have the following naming convention:
%      <dataDir>/Round <x>/<virus>/<filename>.nd2
%  where <x> is a number, e.g. from 1 to 2 that specifies the imaging
%  round, and <virus> is the type of virus that was used (e.g., H1N1). Note
%  that there should not be additional sub-directories (e.g., 'mock',
%  'washed') and these will be ignored during processing. Please move the
%  files out of these directories and change their filename as needed.

%Parse the inputs
ip = inputParser;
addParameter(ip, 'ChannelToRegister', 2);
parse(ip, varargin{:});

%Pase the input directories

%Get the "rounds" directory
dataRoundsDir = dir(dataDir);

%Remove the '.' and '..' directories
dataRoundsDir = dataRoundsDir(~ismember({dataRoundsDir.name}, {'.', '..'}));

%Get the "virus" directories (only need to check the first round)
dataVirusDir = dir(fullfile(dataDir, dataRoundsDir(1).name));

%Remove the '.' and '..' directories
dataVirusDir = dataVirusDir(~ismember({dataVirusDir.name}, {'.', '..'}));

for iVDir = 1:numel(dataVirusDir)

    %Get the files
    files = dir(fullfile(dataDir, dataRoundsDir(1).name, dataVirusDir(iVDir).name, '*.nd2'));

    if isempty(files)
        error('registerImages:NoFilesFound', ...
            'No ND2 files were found at the path specified. Please check that the directory structure is as expected.')
    end

    %Register each image file
    for iF = 1:numel(files)

        %Grab the filename
        fn = files(iF).name;

        %Initialize an empty matrix for the image stack
        registeredImageStack = zeros(512, 512, 16, 'uint16');

        for iRDir = 1:numel(dataRoundsDir)

            currfilepath = fullfile(dataRoundsDir(iRDir).folder, dataRoundsDir(iRDir).name, dataVirusDir(iVDir).name);

            %Read the images
            reader = BioformatsImage(fullfile(currfilepath, fn));

            %Calculate the transform matrix for this set of images
            if iRDir == 1
                %Set the main reference image (defined as image from Round
                %1)
                refImage = getPlane(reader, 1, ip.Results.ChannelToRegister, 1);
                tform = [];
                
                %Generate the spatial referencing object
                refObj = imref2d(size(refImage));

                % figure;
                % title(fn)
            else

                %Hack to handle image from round 4 being different
                if iRDir ~= 4
                    movedImage = getPlane(reader, 1, ip.Results.ChannelToRegister, 1);
                else
                    movedImage = getPlane(reader, 1, 1, 1);
                end

                %Use the phase correlation registration algorithm
                tform = imregcorr(movedImage, refObj, ...
                    refImage, refObj, ...
                    'transformtype', 'similarity', 'Window', true);

                % %% Display the results
                % subplot(2, 2, iRDir)
                % Ireg = imwarp(movedImage, tform, "OutputView", imref2d(size(refImage)));
                % imshowpair(refImage, Ireg, "Scaling", "joint")
            end

            %Register the iamges
            for iC = 1:reader.sizeC

                I = getPlane(reader, 1, iC, 1);

                if ~isempty(tform)
                    Ireg = imwarp(I, tform, "OutputView",imref2d(size(refImage)));
                else
                    Ireg = I;
                end

                %Store in image stack
                registeredImageStack(:, :, (iRDir - 1) * 4 + iC) = Ireg;

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

        outputPath = fullfile(outputDir, dataVirusDir(iVDir).name);

        if ~exist(outputPath, 'dir')
            mkdir(outputPath)
        end

        for iImg = 1:size(registeredImageStack, 3)
            if iImg == 1
                imwrite(registeredImageStack(:, :, iImg), fullfile(outputPath, [outputFN, '.tif']), 'Compression', 'none');
            else
                imwrite(registeredImageStack(:, :, iImg), fullfile(outputPath, [outputFN, '.tif']), 'Compression', 'none', ...
                    'WriteMode', 'append');
            end
        end

    end








end






