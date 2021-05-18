function sr = stochasticresonanceNOISE(im, thresh, rango)

im = rgb2gray(im);

x = length(im(:,1));
y = length(im(1,:));

sr = zeros(x, y, 'uint8');

% im(im > thresh) = 255;
% im(im < thresh) = 0;

figure(2); clf; imshow(im);

    lvl = randi([-rango, rango], x, y) + thresh;

    length(sr)
    length(im)
    length(lvl)
sr(im > lvl) =  255;
    
%     
% %threshbox = thresh * ones(x, y);
% rnd = randi([0 80], x, y, 'uint8');
% 
% for j = 1:length(rnd(:,1))
%     for k = 1:length(rnd(1,:))
%         if in(j,k) > rnd(j,k)+thresh  
%             sr(j,k) = 255;
%         end
%     end
% end

figure(3); clf; imshow(sr);
