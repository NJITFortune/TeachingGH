
% Initialize the "object" that will be the final movie
writerObj = VideoWriter('mymovie.avi');
writerObj.FrameRate = 20;
%writerObj.VideoFormat = 'RGB24';
writerObj.Quality = 90;


open(writerObj);

for i = 100:1000;
    figure(2); clf;
    imshow(im(i).gray); 
    hold on; 
    plot(data.x(i), data.y(i), 'm*', data.x(i-90:i), data.y(i-90:i), 'm-'); 
    hold off;
    frame = getframe(gcf);
    writeVideo(writerObj, frame);

end;


close(writerObj);


