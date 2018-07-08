function [fish, imdata] = shakenbake(vdata, dil, rango)
% Usage: [fish imdata] = traxer(vid, fishNum, dilation-num, rango);
% This is a simple electric fish tracker based on the Matlab object-tracking script example. 
% Nothing fancy here.
% vdata is the output from VideoReader.
% dilation-num is the number of frames for computing the background - 50 is a good number
% rango (optional) is the frame range and can be used with the threshold 
%   level e.g. [startframe endframe level] 
%
% fish is a structure of output data, imdata is the images structure(grayscale and thresholded)
%

fishNum = 1;

figure(1); clf; figure(3); clf;

%% Preparations

finalframe = vdata.NumberOfFrames;
dst = [];  
jumpthresh = 15; % Number of pixels a fish may move between frames before we think something went wrong

boxy = [10 10];

% A list of colors for plotting. This is embarrasing.
colr(1,:)='r*'; colr(2,:)='b*'; colr(3,:)='m*'; colr(4,:)='g*'; colr(5,:)='c*'; colr(6,:)='k*';
colrl(1,:)='r-'; colrl(2,:)='b-'; colrl(3,:)='m-'; colrl(4,:)='g-'; colrl(5,:)='c-'; colrl(6,:)='k-';
colo(1,:)='ro'; colo(2,:)='bo'; colo(3,:)='mo'; colo(4,:)='go'; colo(5,:)='co'; colo(6,:)='ko';

fprintf('Number of frames in video: %i \n', finalframe);

% If the user gave a frame range, then we use that
if nargin > 2;
        startframe = rango(1);
        endframe = rango(2);
        if length(rango) == 3;
            userpick = rango(3); % This is the threshold level
        end;
else
    % Otherwise we as or do the whole video.
        startframe = 1;
        endframe = vdata.NumberOfFrames;
        rango = []; % input('Enter range (e.g. [1000 1500]) or hit return to do entire video: ');
end

% Convert to grayscale and reduce to 1/2 size
% grae is the processed grayscale video - this takes time
    fprintf('Importing video and reducing size.\n');
    for i = endframe:-1:startframe;
        tmp = rgb2gray(read(vdata, i));
        grae(:,:,1+(i-startframe)) = tmp(1:2:end,1:2:end);
    end;
    
    clear tmp;

% Initialize variables for first fish
fprintf('Allocating memory.\n');

    fish(fishNum).x = zeros(endframe-startframe,1); % centroid X
    fish(fishNum).y = zeros(endframe-startframe,1); % centroid Y
    fish(fishNum).Rx = zeros(endframe-startframe,1); % centroid X
    fish(fishNum).Ry = zeros(endframe-startframe,1); % centroid Y
    fish(fishNum).orient = zeros(endframe-startframe,1); % Orientation of major axis
    fish(fishNum).majorLength = zeros(endframe-startframe,1); % Length of major axis
    fish(fishNum).minorLength = zeros(endframe-startframe,1); % Length of minor axis
    fish(fishNum).majorXs = zeros(endframe-startframe,2); % X pairs for major axis line
    fish(fishNum).majorYs = zeros(endframe-startframe,2); % Y pairs for major axis line
    fish(fishNum).minorXs = zeros(endframe-startframe,2); % X pairs for minor axis line
    fish(fishNum).minorYs = zeros(endframe-startframe,2); % Y pairs for minor axis line
    fish(fishNum).frameno = zeros(endframe-startframe,1);
    
%% Prepare the data for analysis

% Compute the background
fprintf('Computing background. \n');
    bg = imdilate(grae, ones(1, 1, dil));

% Get the differences between each frame and the background
fprintf('Taking image differences. \n');
    df = imabsdiff(grae, bg);

    threshval = [-0.9 -0.5 -0.3 0.3 0.5 0.9];

    userpick = 99;

while userpick == 99;
    
% Take different thresholds of the background level
    fprintf('Applying thresholds. \n');
    
    % Thresholds for closed door only IR
    thresh(1) = graythresh(df) + graythresh(df)* threshval(1);
    thresh(2) = graythresh(df) + graythresh(df)* threshval(2);
    thresh(3) = graythresh(df) + graythresh(df)* threshval(3);
    thresh(4) = graythresh(df) + graythresh(df)* threshval(4);
    thresh(5) = graythresh(df) + graythresh(df)* threshval(5);
    thresh(6) = graythresh(df) + graythresh(df)* threshval(6);

    lt = length(thresh); % There are presently 6 thresholds defined above
    N = sort(fix((endframe-startframe)*rand(1,lt))); % We'll display 'lt' random frames from our movie

    if length(rango) < 3 % User did not provide which gray level they want
    % Show the User what we've got
    for pp = 1:lt; % 1 2 3 4 5 6 
        figure(1);
        nrw = lt * (pp - 1);
        % Let's do 1 row
        for rw = 1+nrw:(lt + nrw);
            wb = (df >= thresh(pp) * 255);
            subplot(lt,lt,rw); imshow(wb(:,:,N(rw-nrw))); 
        end

    end
    
    userpick = input('Which threshold? If all are poopy, use 99: ');
    close(1);
    
    end

    if userpick == 99;
        fprintf('The old numbers were: ');
        threshval
        threshval = input('Gimme the new numbers! e.g. [1 2 3 4 5 6]: ');
    end

end


% Make the image binary - white for above thresh and 0 black below
    bw = (df >= thresh(userpick) * 255);
    
%% Get user picks for first fish position

fprintf('Click initial fish position in Figure 1. \n');
    
    % Show the "end" image
       figure(1); imshow(grae(:,:,end)); 
    % Now click the fish
        fishi = round(ginput(fishNum));

        hormax = length(bw(:,1,1));
        vermax = length(bw(1,:,1));

        %plot([200 210], [50 120], 'b');
        %figure(1); hold on; plot([200, 210, 210, 200, 200], [50, 50, 120, 120, 50], 'r');
        %pause(3);
                

%% Track the fish        
for jj = endframe-startframe-1:-1:1       % Cycle through every frame of our sample
    
    for kk = 1:fishNum; % Cycle tracking for each fish
        
        L = logical(bw(max([1 fishi(kk,2)-boxy(1)]):min([fishi(kk,2)+boxy(1) hormax]), max([1 fishi(kk,1)-boxy(2)]):min([fishi(kk,1)+boxy(2) vermax]), jj));
        
        %figure(2); clf; imshow(L); pause(5);
        s = regionprops(L, 'Area', 'Centroid', 'Orientation', 'MajorAxisLength', 'MinorAxisLength');
        area_vector = [s.Area];
        % Take the largest blob
        [~, blobidx] = max(area_vector); 

        % BLOB CHECK (EMPTY)
        
        if isempty(blobidx) == 1 % We have no blob so we need to get a click
                
                % Show the fish
                figure(1); clf; imshow(grae(:,:,jj)); hold on;
                if kk == 1; % THIS IS ME BEING STOOPID.  Didn't bother to figure out how to handle the two fishies
                    plot(fish(kk).x, fish(kk).y, 'g-');
                    plot(fish(kk).x(jj+1), fish(kk).y(jj+1), 'go', 'MarkerSize', 2); % Last known location of lost fish
                    if (fishNum > 1);
                        plot(fish(2).x(jj+1), fish(2).y(jj+1), 'b*'); % Last known location of good fish
                    end
                end
                
                [xTMP, yTMP] = ginput(1); % Get our click
                fish(kk).x(jj) = round(xTMP); fish(kk).y(jj) = round(yTMP); % We need integers for indices

                    % We don't have these data because no blob was found.  
                    fish(kk).majorLength(jj) = [];
                    fish(kk).minorLength(jj) = [];
                    fish(kk).majorXs(jj,:) = [];
                    fish(kk).majorYs(jj,:) = [];
                    fish(kk).minorXs(jj,:) = [];
                    fish(kk).minorYs(jj,:) = [];                    

        end
            
        % BLOB CHECK (FULL!)
        
        if isempty(blobidx) == 0 % Yay!  We have a blob.
        % Save the x (centroid) position for the largest blob
            fish(kk).x(jj) = round(s(blobidx).Centroid(1)) + fishi(kk,1)-boxy(1);
            fish(kk).y(jj) = round(s(blobidx).Centroid(2)) + fishi(kk,2)-boxy(2);
            
            % Save the rest of the data
                fish(kk).orient(jj) = s(blobidx).Orientation;
                fish(kk).majorLength(jj) = s(blobidx).MajorAxisLength;
                fish(kk).minorLength(jj) = s(blobidx).MinorAxisLength;
                    XX = (s(blobidx).MajorAxisLength * cosd(s(blobidx).Orientation))/2;
                    YY = (s(blobidx).MajorAxisLength * sind(s(blobidx).Orientation))/2;
                fish(kk).majorXs(jj,:) = [(s(blobidx).Centroid(1)-XX) (s(blobidx).Centroid(1)+XX)];
                fish(kk).majorYs(jj,:) = [(s(blobidx).Centroid(2)+YY) (s(blobidx).Centroid(2)-YY)];
                    XX = (s(blobidx).MinorAxisLength * cosd(s(blobidx).Orientation-90))/2;
                    YY = (s(blobidx).MinorAxisLength * sind(s(blobidx).Orientation-90))/2;
                fish(kk).minorXs(jj,:) = [(s(blobidx).Centroid(1)-XX) (s(blobidx).Centroid(1)+XX)];
                fish(kk).minorYs(jj,:) = [(s(blobidx).Centroid(2)+YY) (s(blobidx).Centroid(2)-YY)];
                fish(kk).frameno(jj) = jj+startframe-1;
            
        end
        
        fishi(kk,:) = [fish(kk).x(jj) fish(kk).y(jj)]; % fishi is the current location - set it for the next iteration
        
    end
    
    % Update the plot every 10 frames
    
             if rem(jj,10) == 0
                figure(3); clf; imshow(grae(:,:,jj)); hold on; 
                plot(fish(1).x, fish(1).y, 'r*');
                if (fishNum > 1)
                    plot(fish(2).x, fish(2).y, 'b*');
                end
                pause(0.1); 
             end    
end        

%% Fish is tracked, now track the rod movement
        % figure(1); hold on; plot([200, 210, 210, 200, 200], [50, 50, 120, 120, 50], 'r');

fprintf('Click initial stimulus position in Figure 1. \n');

    % Show the "end" image
        figure(1); clf; imshow(grae(:,:,end)); 
        figure(1); hold on; plot([200, 210, 210, 200, 200], [50, 50, 120, 120, 50], 'r');
    % Now click the rod
        fishR = round(ginput(1));

        hormax = length(bw(:,1,1));
        vermax = length(bw(1,:,1));


newbw = grae;
newbw(grae > 150) = 0;
newbw(grae < 90) = 255;


        
        
%% Track the rod        
for jj = endframe-startframe-1:-1:1       % Cycle through every frame of our sample
            % 65:110,197:205
L = logical(newbw(65:110, 195:210, jj));

        
        %figure(2); clf; imshow(L); pause(5);
        s = regionprops(L, 'Area', 'Centroid');
        area_vector = [s.Area];
        % Take the largest blob
        [~, blobidx] = max(area_vector); 

        % BLOB CHECK (EMPTY)
        
        if isempty(blobidx) == 1 % We have no blob so we need to get a click
                
                % Show the fish
                figure(1); clf; imshow(grae(:,:,jj)); hold on;
                if kk == 1; % THIS IS ME BEING STOOPID.  Didn't bother to figure out how to handle the two fishies
                    plot(fish(kk).Rx, fish(kk).Ry, 'g-');
                    plot(fish(kk).Rx(jj+1), fish(kk).Ry(jj+1), 'go', 'MarkerSize', 2); % Last known location of lost fish
                end
                
                [xTMP, yTMP] = ginput(1); % Get our click
                fish(kk).Rx(jj) = round(xTMP); fish(kk).Ry(jj) = round(yTMP); % We need integers for indices

        end
            
        % BLOB CHECK (FULL!)
        
        if isempty(blobidx) == 0 % Yay!  We have a blob.
        % Save the x (centroid) position for the largest blob
            fish(kk).Rx(jj) = round(s(blobidx).Centroid(1)) + 195;
            fish(kk).Ry(jj) = round(s(blobidx).Centroid(2)) + 65;
            
                fish(kk).Rframeno(jj) = jj+startframe-1;
            
        end
        
        fishR(kk,:) = [fish(kk).Rx(jj) fish(kk).Ry(jj)]; % fishi is the current location - set it for the next iteration
            
    % Update the plot every 10 frames
    
             if rem(jj,10) == 0
                figure(3); clf; imshow(grae(:,:,jj)); hold on; 
                plot(fish(1).x, fish(1).y, 'r*');
    figure(27); subplot(121); imshow(L); subplot(122); imshow(grae(65:110, 195:210, jj));
                pause(0.1); 
             end    
end        

        
        

        
        
        
        
        
        
        
%% When all is said and done, transfer the images to our output variable    
fprintf('Taking final images. \n');
for i = (endframe-startframe):-1:1; 
    imdata(i).bw = bw(:,:,i); 
    imdata(i).gray = grae(:,:,i);
end;
% 
% %% Plot final tracks
% figure(99); hold off; imshow(grae(:,:,end)); hold on; 
% for ii = 1:fishNum;
%     plot(fish(ii).x, fish(ii).y, colr(ii,:));
% end;
% 
%     
% end

%% Award Winning Code
%for j=16:2:length(asdf(1).x); plot(asdf(1).x(j-15:j), asdf(1).y(j-15:j), 'g*'); axis([0,350,0,350]); hold on; plot(asdf(2).x(j-15:j), asdf(2).y(j-15:j), 'm*'); pause(0.01); hold off; end;
%
% colr(1,:)='r*'; colr(2,:)='b*'; colr(3,:)='m*'; colr(4,:)='g*'; colr(5,:)='c*'; colr(6,:)='k*'; figure; set(gcf, 'Position', [838 639 759 541]);
% for i=1:length(fish(1).x); clf; imshow(im(i).gray); hold on; for j=1:length(fish); plot(fish(j).x(i),fish(j).y(i),colr(j,:)); end; pause(0.01); end;
%
% colrl(1,:)='r-'; colrl(2,:)='b-'; colrl(3,:)='m-'; colrl(4,:)='g-'; colrl(5,:)='c-'; colrl(6,:)='k-';
% colr(1,:)='r*'; colr(2,:)='b*'; colr(3,:)='m*'; colr(4,:)='g*'; colr(5,:)='c*'; colr(6,:)='k*'; figure;
% for i=21:length(fish(1).x); clf; imshow(im(i).gray); hold on; for j=1:length(fish); plot(fish(j).x(i-20:i),fish(j).y(i-20:i),colrl(j,:)); plot(fish(j).x(i),fish(j).y(i),colr(j,:)); end; pause(0.01); end;
