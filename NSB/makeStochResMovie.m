a = imread('~/Downloads/Wrens2011-CarlosPhoto.jpeg');
a = a(:,:,2);

vidfile = VideoWriter('StochRes2021.mp4','MPEG-4');

open(vidfile);

