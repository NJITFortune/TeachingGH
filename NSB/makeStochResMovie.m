a = imread('~/Downloads/Wrens2011-CarlosPhoto.jpeg');
a = a(:,:,2);

[im1, sr1] = StochRes2021(a, 50);

vidfile = VideoWriter('StochRes2021.mp4','MPEG-4');

open(vidfile);

for j=1:256
    
    [~, sr] = StochRes2021(a, 50);    
    writeVideo(vidfile, sr);

end

close(vidfile)




function [im, sr] = StochRes2021(in, thresh)

im = in;

x = length(im(:,1));
y = length(im(1,:));

im(in > thresh) = 255;
im(in < thresh) = 0;

sr = zeros(x, y, 'uint8');
%threshbox = thresh * ones(x, y);
rnd = randi([0 80], x, y, 'uint8');

for j = 1:length(rnd(:,1))
    for k = 1:length(rnd(1,:))
        if in(j,k) > rnd(j,k)+thresh  
            sr(j,k) = 255;
        end
    end
end

end