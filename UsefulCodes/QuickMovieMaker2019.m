    writerObj = VideoWriter('mothymoth.avi');
    writerObj.FrameRate = 30;
    open(writerObj);

    for j=1:length(im)
        
    figure(1); 
    
    imshow(im(j).orig, 'InitialMagnification', 200);
%    truesize([640 480]);

    pause(0.1);
    if rem(j,20) == 0
        j
    end
        
    out= getframe(gcf);
    writeVideo(writerObj,out);    

        
    end
    
    close(writerObj);
