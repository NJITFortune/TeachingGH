function puppies(num, simulationlength, jigglestrength, biastrength)
% Usage puppies(num, simlength, jigglestr, biastr)
% simulationlength = 100;
% biastrength = 2;
% jigglestrength = 1;
      
    % puppy properties
        puppywid = 40;
        puppylen = 100;
        
        maxdist = 30;
        maxturnangle = pi/16;
  
%% Initialize puppies    
    for z = num:-1:1 % For each puppy
        scottie(z).ctr = [round(rand*1000)-500, round(rand*1000)-500]; % Put the puppy at a random spot
        scottie(z).puppyang = rand*2*pi; % Randomly set the angle of the puppy
        
        scottie(z).coord = drawpuppy(scottie(z).ctr, scottie(z).puppyang-pi/2, puppywid, puppylen); % Render the body of the puppy
    end
    
    clrs = lines(num); % Give each puppy a color
    
%% Run Simulation    
    for k = 2:simulationlength % Length of simulation
        
        figure(1); clf; hold on; 

        for z = 1:num  % For each puppy
            
        % RANDOM PUPPY ANGLE for each step in the simulation
        scottie(z).puppyang = puppyturn(scottie(z).puppyang, maxturnangle, jigglestrength);

        % RANDOM PUPPY MOVEMENT for each step in the simulation
        scottie(z).ctr(k,:) = puppymove(scottie(z).ctr(k-1,:), scottie(z).puppyang, maxdist);
 
        % GET PUPPY BODY
        scottie(z).coord = drawpuppy(scottie(z).ctr(k,:), scottie(z).puppyang-pi/2, puppywid, puppylen); 

% Add stuff here to make the simulation work
        
        % Puppy attractor
        scottie(z).puppyang = puppyattactor(scottie(z).ctr(k,:), scottie(z).puppyang, biastrength, maxturnangle);

        % DID IT RUN INTO A WALL?
        [scottie(z).ctr(k,:), scottie(z).puppyang] = wallcheck(scottie(z).ctr(k,:), scottie(z).puppyang);   
        
        % Did the puppy run into another puppy?
        scottie(z).ctr(k,:) = puppycheck(scottie, z);

        
% PLOT the puppies!!!!
            fill(scottie(z).coord(:,1), scottie(z).coord(:,2), clrs(z,:));
            % plot(scottie(z).ctr(k,1), scottie(z).ctr(k,2), '.', 'MarkerSize', puppywid, 'Color',[0,0,0]); 
            plot(scottie(z).ctr(:,1), scottie(z).ctr(:,2), '-', 'LineWidth', 0.5, 'Color', clrs(z,:));
            text(scottie(z).ctr(k,1), scottie(z).ctr(k,2), num2str(scottie(z).puppyang));
            
        end   
            plot(0,0,'k.', 'MarkerSize', 40);
            axis([-500, 500, -500, 500]);
            text(-450,-450, num2str(simulationlength-k));
            drawnow;
    
    end

    
%% EMBEDDED FUNCTIONS

% RANDOM PUPPY TURN
    function newang = puppyturn(oldang, maxang, getjiggy)
       
        newang = oldang + (getjiggy * (0.5 - rand(1)) * maxang); % add random angle change
        if newang > 2*pi; newang = newang - 2*pi; end
        if newang < 0; newang = 2*pi + newang; end
        
    end
    
% RANDOM PUPPY MOVEMENT
    function newctr = puppymove(oldctr, ang, maxmove)
        
            dist =  rand(1) * maxmove;
            newctr = [oldctr(1) - dist * sin(ang), oldctr(2) - dist * cos(ang)];
            
    end
    
% PUPPY ATTRACTOR

    function biasedangle = puppyattactor(currctr, currang, biastrength, mxang)
   
         biasedangle = currang;
        % Do this by quadrants
        
        if currctr(1) >= 0 && currctr(2) >= 0 % upper right quadrant
            if currang > pi/4 && currang < (5*pi)/4
                biasedangle = currang - (mxang * biastrength);
            end
            if currang > (5*pi)/4
                biasedangle = currang + (mxang * biastrength);
            end
            if currang < pi/4
                biasedangle = currang + (mxang * biastrength);
            end
        end            
        if currctr(1) < 0 && currctr(2) >= 0 % upper left quadrant
            if currang < (3*pi)/4 
                biasedangle = currang - (mxang * biastrength);
            end
            if currang > (7*pi)/4 
                biasedangle = currang - (mxang * biastrength);
            end
            if currang > (3*pi)/4 && currang < (7*pi)/4
                biasedangle = currang + (mxang * biastrength);
            end
        end            
        if currctr(1) >= 0 && currctr(2) < 0 % lower right quadrant
            if currang > (3*pi)/4 && currang < (7*pi)/4
                biasedangle = currang - (mxang * biastrength);
            end
            if currang > (7*pi)/4
                biasedangle = currang + (mxang * biastrength);
            end
            if currang < (3*pi)/4
                biasedangle = currang + (mxang * biastrength);
            end
        end            
        if currctr(1) < 0 && currctr(2) < 0 % lower left quadrant
            if currang > pi/4 && currang < (5*pi)/4 
                biasedangle = currang + (mxang * biastrength);
            end
            if currang < pi/4 
                biasedangle = currang - (mxang * biastrength);
            end
            if currang > (5*pi)/4 
                biasedangle = currang - (mxang * biastrength);
            end
        end            
   
        if biasedangle > 2*pi; biasedangle = biasedangle - (2*pi); end
        if biasedangle < 0; biasedangle = 2*pi + biasedangle; end
        
    end

% WALLCHECK
    function [wallctr, wallang] = wallcheck(wctr, wang)
        
        wallctr = wctr; wallang = wang;
        
        rescueturnangle = pi/4;
        
            if wctr(1) < -500 
                  wallctr(1) = -500;
                  if wang > 1.5*pi
                      wallang = wang + rescueturnangle;
                  end
                  if wang < 1.5*pi
                      wallang = wang - rescueturnangle;
                  end
            end
            if wctr(1) > 500 
                  wallctr(1) = 500;
                  if wang < 0.5*pi
                      wallang = wang - rescueturnangle;
                  end
                  if wang > 0.5*pi
                      wallang = wang + rescueturnangle;
                  end
            end
            
            if wctr(2) < -500 
                  wallctr(2) = -500;
                  if wang > pi
                      wallang = wang - rescueturnangle;
                  end
                  if wang < pi
                      wallang = wang + rescueturnangle;
                  end
            end
            if wctr(2) > 500 
                  wallctr(2) = 500;
                  if wang > pi && wang < 2*pi
                      wallang = wang + rescueturnangle;
                  end
                  if wang > 0 && wang < pi
                      wallang = wang - rescueturnangle;
                  end
            end
    end

    function newloc = puppycheck(struct, idx)

        jumpfactor = 10;
        
        for pp = length(struct):-1:1
            shp(pp) = polyshape(struct(pp).coord(:,1), struct(pp).coord(:,2));
        end
        
        TF = overlaps(shp); TF = TF(:,idx);
        
        newloc = struct(idx).ctr(end,:); 

        if sum(TF) ~= 1  % There was an overlap! Do something!!
        
            whichidx = find(TF); whichidx = whichidx(whichidx~=idx);
            
            for qq = 1:length(whichidx)
                
                currang = atan2((newloc(2) - struct(whichidx(qq)).ctr(end,2)), (newloc(1) - struct(whichidx(qq)).ctr(end,1)));
                if currang > 0
                    if cos(currang) > 0; newloc = [newloc(1)+jumpfactor, newloc(2)+(jumpfactor*sin(currang))]; end
                    if cos(currang) < 0; newloc = [newloc(1)-jumpfactor, newloc(2)+(jumpfactor*sin(currang))]; end
                end
                if currang < 0
                    if cos(-currang) > 0; newloc = [newloc(1)+jumpfactor, newloc(2)-(jumpfactor*sin(currang))]; end
                    if cos(-currang) < 0; newloc = [newloc(1)-jumpfactor, newloc(2)-(jumpfactor*sin(currang))]; end
                end
                
            end
            
        end
        
        
    end

% RENDER THE BODY OF THE PUPPY
    function pp = drawpuppy(hd, ang, wid, len)
        
        pp(1,:) = [hd(1) - (wid/2) * sin(ang), hd(2) - (wid/2) * cos(ang)];
        pp(2,:) = [hd(1) - (wid/2) * sin(ang-pi), hd(2) - (wid/2) * cos(ang-pi)];
        pp(3,:) = [pp(2,1) - len * sin(ang-(pi/2)), pp(2,2) - len * cos(ang-(pi/2))];
        pp(4,:) = [pp(3,1) - wid * sin(ang), pp(3,2) - wid * cos(ang)];
        pp(5,:) = pp(1,:);

    end

end