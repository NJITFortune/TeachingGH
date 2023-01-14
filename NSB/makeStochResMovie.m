function makeStochResMovie(thre, rang)

[ff, pp] = uigetfile;
a = imread(fullfile(pp,ff));

% a = a(:,:,2);
a = rgb2gray(a);

[im1, sr1] = StochRes2021(a, thre, rang);
    imwrite(im1,'SimpleThreshold2023.jpg','JPEG')
    imwrite(sr1,'SingleStochRes2023.jpg','JPEG')

vidfile = VideoWriter('StochRes2023.mp4','MPEG-4');

open(vidfile);

for j=1:256
    
    [~, sr] = StochRes2021(a, thre, rang);    
    writeVideo(vidfile, sr);

end

close(vidfile)



function [im, sr] = StochRes2021(in, thresh, rango)

im = in;

x = length(im(:,1));
y = length(im(1,:));

im(in > thresh) = 255;
im(in < thresh) = 0;

sr = zeros(x, y, 'uint8');
%threshbox = thresh * ones(x, y);
rnd = randi([-rango rango], x, y, 'uint8');

for jj = 1:length(rnd(:,1))
    for k = 1:length(rnd(1,:))
        if in(jj,k) > rnd(jj,k)+thresh  
            sr(jj,k) = 255;
        end
    end
end

end

end