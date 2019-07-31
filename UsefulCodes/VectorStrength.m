function vs = VectorStrength(spikearray)
% spits out the vector strength for a spike array encoded in radians

totspikes = 0; sinsum = 0; cossum = 0;

for i = 1:length(spikearray);
    
    totspikes = totspikes + length(spikearray{i});
    sinsum = sinsum + sum(sin(spikearray{i}));
    cossum = cossum + sum(cos(spikearray{i}));    
    
end;

% Compute Vector Strength
vs = sqrt(sinsum^2 + cossum^2) / totspikes;

