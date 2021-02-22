function puppies(num, simulationlength, jigglestrength, biastrength)
% Usage puppies(num, simlength, jigglestr, biastr)
% simulationlength = 100;
% biastrength = 2;
% jigglestrength = 1;
      
    % puppy properties
        puppywid = 40;
        puppylen = 100;
        
        maxdist = 30;
        maxturnangle = pi/32;
        
    % Bowl properties
        bowlradius = 60; 
        sm = 0.1:0.1:2*pi;
        bowl = polyshape(cos(sm)*bowlradius, sin(sm)*bowlradius);
        
  
%% Initialize puppies    
    for z = num:-1:1 % For each puppy
        scottie(z).ctr = [round(rand*1000)-500, round(rand*1000)-500]; % Put the puppy at a random spot
        scottie(z).puppyang = rand*2*pi; % Randomly set the angle of the puppy
        
        scottie(z).coord = drawpuppy(scottie(z).ctr, scottie(z).puppyang-pi/2, puppywid, puppylen); % Render the body of the puppy
    end
    
    clrs = lines(num); % Give each puppy a color
    
%% Run Simulation    
    for k = 2:simulationlength % Length of simulation
        
        figure(1); clf; hold on; plot(bowl); axis([-500, 500, -500, 500]);

        for z = 1:num  % For each puppy
            
        % RANDOM PUPPY ANGLE for each step in the simulation
        
        scottie(z).puppyang(k) = puppyturn(scottie(z).puppyang(k-1), maxturnangle, jigglestrength);

        % RANDOM PUPPY MOVEMENT for each step in the simulation
        scottie(z).ctr(k,:) = puppymove(scottie(z).ctr(k-1,:), scottie(z).puppyang(k-1), maxdist);
 
        % GET PUPPY BODY
        scottie(z).coord = drawpuppy(scottie(z).ctr(k,:), scottie(z).puppyang(k)-pi/2, puppywid, puppylen); 

% Add stuff here to make the simulation work
        
        % Puppy attractor
        scottie(z).puppyang(k) = puppyattactor(scottie(z).ctr(k,:), scottie(z).puppyang(k), biastrength, maxturnangle);
        
        % DID IT RUN INTO A WALL?
        [scottie(z).ctr(k,:), scottie(z).puppyang(k)] = wallcheck(scottie(z).ctr(k,:), scottie(z).puppyang(k));   
        
        % DID PUPPY RUN INTO THE BOWL
        %[scottie(z).ctr(k,:), scottie(z).puppyang(k)] = bowlcheck(scottie(z), 8*maxturnangle, bowlradius);           
                
        % Did the puppy run into another puppy?
        %[scottie(z).ctr(k,:), scottie(z).puppyang(k)]  = puppycheck(scottie, z);
        

% PLOT the puppies!!!!
        % GET PUPPY BODY AGAIN
            scottie(z).coord = drawpuppy(scottie(z).ctr(k,:), scottie(z).puppyang(k)-pi/2, puppywid, puppylen); 
            fill(scottie(z).coord(:,1), scottie(z).coord(:,2), clrs(z,:));
            
            plot(scottie(z).ctr(k,1), scottie(z).ctr(k,2), '.', 'MarkerSize', puppywid, 'Color',[0,0,0]); 
            plot(scottie(z).ctr(:,1), scottie(z).ctr(:,2), '-', 'LineWidth', 0.5, 'Color', clrs(z,:));
            % text(scottie(z).ctr(k,1), scottie(z).ctr(k,2), num2str(scottie(z).puppyang));
            
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
         
%          realref = [0, -100]; testref = [1, -100];
%          
%          realang = (currctr(1)*realref(1) + currctr(2)*realref(2)) / (sqrt(currctr(1)^2 + currctr(2)^2) * sqrt(realref(1)^2 + realref(2)^2));
%          testang = (currctr(1)*testref(1) + currctr(2)*testref(2)) / (sqrt(currctr(1)^2 + currctr(2)^2) * sqrt(testref(1)^2 + testref(2)^2));
%          
%          if testang <= realang; realang = 2*pi - realang; end
%          
%          goang = realang + pi; if goang > 2*pi; goang = goang - 2*pi; end
         
        % Do this by quadrants
        if currctr(1) >= 0 && currctr(2) >= 0 % upper right quadrant
            if currang >= pi/4 && currang < (5*pi)/4
                biasedangle = currang - (mxang * biastrength);
            end
            if currang >= (5*pi)/4
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
        
            if wctr(1) < -500 % Left wall
                  wallctr(1) = -500;
                  if wang < 3*pi/2 && wang > pi/2; wallang = wang + rescueturnangle; end
                  if wang < 3*pi/2; wallang = wang - rescueturnangle; end
                  if wang >= 3*pi/2; wallang = wang - rescueturnangle; end
            end
            if wctr(1) > 500 % Right wall
                  wallctr(1) = 500;
                  if wang >= pi/2 && wang < 3*pi/2; wallang = wang - rescueturnangle; end
                  if wang < pi/2; wallang = wang + rescueturnangle; end
                  if wang >= 3*pi/2; wallang = wang + rescueturnangle; end
            end
            
            if wctr(2) < -500 % Bottom wall
                  wallctr(2) = -500;
                  if wang >= pi; wallang = wang - rescueturnangle; end
                  if wang < pi; wallang = wang + rescueturnangle; end
            end
            if wctr(2) > 500 
                  wallctr(2) = 500; % Top wall
                  if wang >= pi; wallang = wang + rescueturnangle; end
                  if wang < pi; wallang = wang - rescueturnangle; end
            end
            
            if wallang > 2*pi; wallang = wallang - (2*pi); end
            if wallang < 0; wallang = 2*pi + wallang; end
            
    end

% PUPPY OVERLAP

    function [newloc, newang] = puppycheck(struct, idx)
        
        for pp = length(struct):-1:1
            shp(pp) = polyshape(struct(pp).coord(:,1), struct(pp).coord(:,2));
        end
        
        TF = overlaps(shp); TF = TF(:,idx);
        
        newloc = struct(idx).ctr(end,:); 
        newang = struct(idx).puppyang(end);
        
        if sum(TF) ~= 1  % There was an overlap! Do something!!
        
%             % Position goes back in time one step
%             % newloc = struct(idx).ctr(end-1,:);
 
             % Pick the first puppy with overlap 
             whichidx = find(TF); whichidx = whichidx(whichidx~=idx);
             
             % What is the angle difference with the other puppy?
             angledifference = struct(idx).puppyang(end) - struct(whichidx(1)).puppyang(end);
             
             if abs(angledifference) < pi
                 newang = newang - (angledifference/4);
             elseif abs(angledifference) > pi
                 newang = newang - (angledifference/abs(angledifference)*(2*pi - abs(angledifference)))/4; 
             end
            
            if newang > 2*pi; newang = newang - 2*pi; end
            if newang < 0; newang = 2*pi + newang; end
            
        newloc = struct(idx).ctr(end-1,:);
%         newang = struct(idx).puppyang(end-1);
        puppywidagain = 40;
        puppylenagain = 100;

            struct(idx).coord = drawpuppy(struct(idx).ctr(end,:), struct(idx).puppyang(end)-pi/2, puppywidagain, puppylenagain); 



%             
%             for qq = 1:length(whichidx)
%                 
%                 currang = atan2((newloc(2) - struct(whichidx(qq)).ctr(end,2)), (newloc(1) - struct(whichidx(qq)).ctr(end,1)));
%                 if currang > 0
%                     if cos(currang) > 0; newloc = [newloc(1)+jumpfactor, newloc(2)+(jumpfactor*sin(currang))]; end
%                     if cos(currang) < 0; newloc = [newloc(1)-jumpfactor, newloc(2)+(jumpfactor*sin(currang))]; end
%                 end
%                 if currang < 0
%                     if cos(-currang) > 0; newloc = [newloc(1)+jumpfactor, newloc(2)-(jumpfactor*sin(currang))]; end
%                     if cos(-currang) < 0; newloc = [newloc(1)-jumpfactor, newloc(2)-(jumpfactor*sin(currang))]; end
%                 end
%                 
%             end
            
        end
        
    end

% PUPPY BOWL

    function [cirloc, cirang] = bowlcheck(in, maxT, thebowl)   

        cirang = in.puppyang(end);
        cirloc = in.ctr(end,:);
        bounceback = 20;

        % Euclian distance from center
        vec = [0,0; cirloc(1),cirloc(2)];
        pupdist = pdist(vec,'euclidean');

        if pupdist <= thebowl % We are in the bowl
            % By Quadrant - This is quick and dirty and deeply embarrasing coding
            
            % upper right
            if in.ctr(1) >= 0 && in.ctr(2) >= 0
                if in.ctr(1) - in.ctr(2) >=0 % bottom of upper right
                    if in.puppyang(end) <= 3*pi/8; cirang = in.puppyang(end) - maxT; end
                    if in.puppyang(end) > 3*pi/2; cirang = in.puppyang(end) - maxT; end
                    if in.puppyang(end) > 3*pi/8 && in.puppyang(end) < 5*pi/4; cirang = in.puppyang(end) + maxT; end
                else % upper of upper right
                    if in.puppyang(end) <= pi/8; cirang = in.puppyang(end) - maxT; end
                    if in.puppyang(end) > 5*pi/4; cirang = in.puppyang(end) - maxT; end
                    if in.puppyang(end) > pi/8 && in.puppyang(end) < pi; cirang = in.puppyang(end) + maxT; end                    
                end
                cirloc(1) = in.ctr(end-1,1)+(bounceback*rand); cirloc(2) = in.ctr(end-1,2)+(bounceback*rand);
            end    
            % upper left
            if in.ctr(1) < 0 && in.ctr(2) >= 0
                if abs(in.ctr(1)) - in.ctr(2) >=0 % bottom of upper left
                    if in.puppyang(end) >= 13*pi/8; cirang = in.puppyang(end) + maxT; end
                    if in.puppyang(end) < pi/2; cirang = in.puppyang(end) + maxT; end
                    if in.puppyang(end) < 13*pi/8 && in.puppyang < 7*pi/8; cirang = in.puppyang(end) - maxT; end
                else % top of upper left
                    if in.puppyang(end) >= 15*pi/8; cirang = in.puppyang(end) + maxT; end
                    if in.puppyang(end) < 5*pi/8; cirang = in.puppyang(end) + maxT; end
                    if in.puppyang(end) < 15*pi/8 && in.puppyang < 7*pi/8; cirang = in.puppyang(end) - maxT; end                    
                end
                cirloc(1) = in.ctr(end-1,1)-(bounceback*rand); cirloc(2) = in.ctr(end-1,2)+(bounceback*rand);
            end
            % lower right
            if in.ctr(1) >= 0 && in.ctr(2) < 0
                if in.ctr(1) - abs(in.ctr(2)) >=0 % top of lower right
                    if in.puppyang(end) <= 5*pi/8 && in.puppyang(end) > 7*pi/4; cirang = in.puppyang(end) - maxT; end
                    if in.puppyang(end) > 5*pi/8 && in.puppyang(end) < 7*pi/4; cirang = in.puppyang(end) + maxT; end
                else % bottom of lower right
                    if in.puppyang(end) <= 7*pi/8 && in.puppyang(end) > 7*pi/4; cirang = in.puppyang(end) - maxT; end
                    if in.puppyang(end) > 7*pi/8 && in.puppyang(end) < 7*pi/4; cirang = in.puppyang(end) + maxT; end                    
                end
                cirloc(1) = in.ctr(end-1,1)+(bounceback*rand); cirloc(2) = in.ctr(end-1,2)-(bounceback*rand);
            end    
            % lower left
            if in.ctr(1) < 0 && in.ctr(2) < 0
                if abs(in.ctr(1)) - abs(in.ctr(2)) >=0 % top of lower left
                    if in.puppyang(end) <= 11*pi/8; cirang = in.puppyang(end) - maxT; end
                    if in.puppyang(end) > 11*pi/8; cirang = in.puppyang(end) + maxT; end
                else % bottom of lower left
                    if in.puppyang(end) >= 9*pi/8; cirang = in.puppyang(end) + maxT; end
                    if in.puppyang(end) < 9*pi/8; cirang = in.puppyang(end) - maxT; end
                end
                cirloc(1) = in.ctr(end-1,1)-(bounceback*rand); cirloc(2) = in.ctr(end-1,2)-(bounceback*rand);
            end    
            
            if cirang > 2*pi; cirang = cirang - 2*pi; end
            if cirang < 0; cirang = 2*pi + cirang; end
            
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