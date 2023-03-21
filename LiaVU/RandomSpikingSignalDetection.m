clear all

%% Random spikes 

numits = 512; % How many neurons 

len = 200; % Duration of the epoch
numspikes = 30; % Number of spikes per epoch

z = zeros(1,len); % Empty time window, no spikes
t = 1:len; % Time steps

% Make each neuron
for j=numits:-1:1
    neuron(:,j) = z; 
    tt = randi(len,[1,numspikes]); % Random time indexes...
    neuron(tt,j) = 1; % Are set to one, which is the spike
end

% Calculate the downstream response to all neural inputs
    avgDownStream = sum(neuron');
    avgDownStream = avgDownStream / numits;

% Plot all or some of the raw spike trains
maxnumtrainstoshow = 50;
figure(27); clf; hold on;
    for j=1:min([maxnumtrainstoshow, numits])
        plot(t, neuron(:,j)+j);
    end
    ylim([0.9, min([maxnumtrainstoshow+1, numits+1])])

% Plot the downstream neural response
    figure(28); clf; 
        plot(t, avgDownStream); ylim([0 1]);

%% Signal

detectionChance = 0.50; % Chance that a neuron will detect the event (range 0-1)


neuronDetector = neuron;

detections = find(rand(1,numits) >= detectionChance);
neuronDetector(round(len/2),detections) = 1;

% Calculate the downstream response to all neural inputs
    avgDownStreamDetector = sum(neuronDetector');
    avgDownStreamDetector = avgDownStreamDetector / numits;


figure(29); clf; hold on;
    for j=1:min([maxnumtrainstoshow, numits])
        plot(t, neuronDetector(:,j)+j);
    end
    ylim([0.9, min([maxnumtrainstoshow+1, numits+1])])

% Plot the downstream neural response
    figure(30); clf; 
        plot(t, avgDownStreamDetector); ylim([0 1]);