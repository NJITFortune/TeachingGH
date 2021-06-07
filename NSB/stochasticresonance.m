function [im, sr] = stochasticresonance(in, thresh)

im = in;

x = length(im(:,1));
y = length(im(1,:));

im(in > thresh) = 255;
im(in < thresh) = 0;

%figure(2); clf; imshow(im);

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

%figure(3); clf; imshow(sr);
