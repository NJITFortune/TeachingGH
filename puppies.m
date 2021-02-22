function puppies(num, simulationlength, jigglestrength, biastrength, maxdist, maxturnangle)
% Usage puppies(num, simulationlength, jigglestrength, centerbiastrength)
% Good values might be:
% num = 5
% simulationlength = 100;
% biastrength = 1;
% jigglestrength = 0.2;
% maxdist = 30; 
% maxturnangle = pi/32;

%% Physical features

    % Arena
        arenawidth = 500; % Half of actual because we go from -arenawidth to +arenawidth
        arenaheight = 500; % Half of actual because we go from -arenaheight to +arenaheight

    % puppy properties
        puppywid = 40; % Puppy width in pixels
        puppylen = 100;  % Puppy length in pixels
        
        %maxdist = 30; % Farthest forward the puppy can move in pixels
        % maxturnangle = pi/32; % maximum turning in a step
        
    % Bowl properties
        bowlradius = 80; % Radius of bowl in pixels
        % Render the bowl
        sm = 0.1:0.1:2*pi; bowl = polyshape(cos(sm)*bowlradius, sin(sm)*bowlradius);
        
  
%% Initialize puppies  (Can start anywhere within the bounds of the field, including on top of bowl or other puppy  
    for z = num:-1:1 % For each puppy
        scottie(z).ctr = [round(rand*1000)-arenawidth, round(rand*1000)-arenaheight]; % Put the puppy at a random spot
        scottie(z).puppyang = rand*2*pi; % Randomly set the angle of the puppy
        scottie(z).coord = drawpuppy(scottie(z).ctr, scottie(z).puppyang-pi/2, puppywid, puppylen); % Render the body of the puppy
    end
    
    clrs = lines(num); % Give each puppy a color
    
%% Run Simulation    
    for k = 2:simulationlength % For each iteration of simulation

        % Clear the figure and prepare for PUPPIES!!!
        figure(1); clf; hold on; 
        plot(bowl); axis([-arenawidth, arenawidth, -arenaheight, arenaheight]);
        a = gcf;
        set(gcf, 'Position', [a.Position(1), a.Position(2), 560, 510]);
        
        for z = 1:num  % For each puppy (required)
            
        % RANDOM PUPPY ANGLE for each step in the simulation        
        scottie(z).puppyang(k) = puppyturn(scottie(z).puppyang(k-1), maxturnangle, jigglestrength);

        % RANDOM PUPPY MOVEMENT for each step in the simulation
        scottie(z).ctr(k,:) = puppymove(scottie(z).ctr(k-1,:), scottie(z).puppyang(k-1), maxdist);
 
        % GET PUPPY BODY
        scottie(z).coord = drawpuppy(scottie(z).ctr(k,:), scottie(z).puppyang(k)-pi/2, puppywid, puppylen); 

% Add functions here to make the simulation 'interesting'
        
        % Puppy attractor - biases each puppy to turn towards the center of the arena (0,0)
        scottie(z).puppyang(k) = puppyattactor(scottie(z).ctr(k,:), scottie(z).puppyang(k), biastrength, maxturnangle);
        
        % DID IT RUN INTO A WALL? Puppy, don't run away!
        %[scottie(z).ctr(k,:), scottie(z).puppyang(k)] = wallcheck(scottie(z).ctr(k,:), scottie(z).puppyang(k));   
        
        % DID PUPPY RUN INTO THE BOWL? Generally messy, so we should avoid that.
        [scottie(z).ctr(k,:), scottie(z).puppyang(k)] = bowlcheck(scottie(z), 8*maxturnangle, bowlradius);           
                
        % Did the puppy run into another puppy? This seems important.
        [scottie(z).ctr(k,:), scottie(z).puppyang(k)]  = puppycheck(scottie, z);
        
% PLOT the puppies!!!!
        % Get puppy body location
            scottie(z).coord = drawpuppy(scottie(z).ctr(k,:), scottie(z).puppyang(k)-pi/2, puppywid, puppylen); 
            fill(scottie(z).coord(:,1), scottie(z).coord(:,2), clrs(z,:));
        % Plot the puppy in our figure
            plot(scottie(z).ctr(k,1), scottie(z).ctr(k,2), '.', 'MarkerSize', puppywid, 'Color', [0,0,0]); 
            plot(scottie(z).ctr(:,1), scottie(z).ctr(:,2), '-', 'LineWidth', 0.5, 'Color', clrs(z,:));
            % text(scottie(z).ctr(k,1), scottie(z).ctr(k,2), num2str(scottie(z).puppyang));
            
        end   
        
            plot(0,0,'k.', 'MarkerSize', 40); % Origin
            text(-arenawidth+50,-arenaheight+50, num2str(simulationlength-k)); % Countdown timer
            drawnow; % Force Matlab to render the puppies for each cycle
    
    end

    
%% EMBEDDED FUNCTIONS

% RANDOM PUPPY TURN
    function newang = puppyturn(oldang, maxang, getjiggy)
    % Random angle change within our user-specified 'jigglestrength'
        newang = oldang + (getjiggy * (0.5 - rand(1)) * maxang); % add random angle change
            if newang > 2*pi; newang = newang - 2*pi; end
            if newang < 0; newang = 2*pi + newang; end        
    end
    
% RANDOM PUPPY MOVEMENT
    function newctr = puppymove(oldctr, ang, maxmove)
    % Random forward movement in the direction of the puppy. Distance is <=
    % 'maxdist' which was specified by the user
            dist =  rand(1) * maxmove;
            newctr = [oldctr(1) - dist * sin(ang), oldctr(2) - dist * cos(ang)];            
    end
    
% PUPPY ATTRACTOR

    function biasedangle = puppyattactor(currctr, currang, biastrength, mxang)
    % Bias the angle of the puppy towards the origin (center of arena)
         biasedangle = currang;
         
        % CRAPPY METHOD - by quadrants
        if currctr(1) >= 0 && currctr(2) >= 0 %         upper right quadrant
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
        
        if currctr(1) < 0 && currctr(2) >= 0 %          upper left quadrant
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
        
        if currctr(1) >= 0 && currctr(2) < 0 %          lower right quadrant
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
        
        if currctr(1) < 0 && currctr(2) < 0 %           lower left quadrant
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
    
        % Unwind angle
        if biasedangle > 2*pi; biasedangle = biasedangle - (2*pi); end
        if biasedangle < 0; biasedangle = 2*pi + biasedangle; end
        
    end

% WALLCHECK - Bounce off the walls my puppies!
    function [wallctr, wallang] = wallcheck(wctr, wang)
    % Ensure that the puppies don't run away        
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
            
            % Unwind angle
            if wallang > 2*pi; wallang = wallang - (2*pi); end
            if wallang < 0; wallang = 2*pi + wallang; end            
    end

% PUPPY OVERLAP - Pauli exclusion principle: no two puppies may occupy the same space
    function [newloc, newang] = puppycheck(struct, idx)
    % The most important function - how the puppies interact when they run into each other    

    % Make no changes if the puppies did not overlap
        newloc = struct(idx).ctr(end,:); 
        newang = struct(idx).puppyang(end);
    
    % Render the current positions of every puppy
        for pp = length(struct):-1:1
            shp(pp) = polyshape(struct(pp).coord(:,1), struct(pp).coord(:,2));
        end
        
    % Use 'overlaps' to find out if any of our puppies are overlapping    
        TF = overlaps(shp); TF = TF(:,idx);

        if sum(TF) ~= 1  % There was an overlap! We have to do something!!
         
             % Pick the first puppy with overlap 
             whichidx = find(TF); whichidx = whichidx(whichidx~=idx);

        % ALTER POSITION
        
        % 1) NUDGE OUT METHOD. Furthest puppy is bumped further away
                nudgedist = 10;
             
        % If our puppy is further away from center, nudge it out further yet     
            vec = [0,0; struct(idx).ctr(end,1),struct(idx).ctr(end,2)];
                focalpupdist = pdist(vec,'euclidean');
            vec = [0,0; struct(whichidx(1)).ctr(end,1),struct(whichidx(1)).ctr(end,2)];
                otherpupdist = pdist(vec,'euclidean');
            if focalpupdist > otherpupdist
                % Do this by quadrant
                if struct(idx).ctr(1) >= 0 
                    if struct(idx).ctr(2) >= 0 % Upper right
                        newloc = [struct(idx).ctr(end,1)+nudgedist, struct(idx).ctr(end,2)+nudgedist];
                    else % Lower right
                        newloc = [struct(idx).ctr(end,1)+nudgedist, struct(idx).ctr(end,2)-nudgedist];
                    end
                else
                    if struct(idx).ctr(2) >= 0 % Upper left
                        newloc = [struct(idx).ctr(end,1)-nudgedist, struct(idx).ctr(end,2)+nudgedist];
                    else % Lower left
                        newloc = [struct(idx).ctr(end,1)-nudgedist, struct(idx).ctr(end,2)-nudgedist];
                    end
                end

            end
                
         % ALTER ANGLE 
         
         % 1) Match angle method (alter focal puppy angle to more closely match the other puppy) 
             angledifference = struct(idx).puppyang(end) - struct(whichidx(1)).puppyang(end);
             
             if abs(angledifference) < pi
                 newang = newang - (angledifference/4);
             elseif abs(angledifference) > pi
                 newang = newang - (angledifference/abs(angledifference)*(2*pi - abs(angledifference)))/4; 
             end
            
            % Unwind angle
            if newang > 2*pi; newang = newang - 2*pi; end
            if newang < 0; newang = 2*pi + newang; end
            
        end % If there is an overlap between our puppy and another
        
    end

% PUPPY BOWL - Keep puppies out of the bowl!
    function [cirloc, cirang] = bowlcheck(in, maxT, thebowl)   
    % This is brain dead and doesn't work.  Wish I had spend a few moments
    % of thinking before I wrote this incredibly stoopid method for
    % avoiding the bowl. This function is also critically important for our
    % emergent behavior and should be tuned so that the simulation can
    % work.
    
    % If the puppy is not in the bowl, do nothing
        cirang = in.puppyang(end); % Set new angle as previous
        cirloc = in.ctr(end,:); % Set new position as previous
        
        bounceback = 25; % How many pixels we 'bounce' puppy back when it dips into the bowl

        % Get the Euclian distance of the puppy from center
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