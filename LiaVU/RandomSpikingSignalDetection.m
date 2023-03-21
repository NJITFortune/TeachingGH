clear all

%% Random spikes 

% How many neurons 
    numits = 20; 

% Duration of the epoch
    len = 200; 
% Number of spikes per epoch
    numspikes = 30; 

% Time steps
    t = 1:len; 

% Initialize neurons, no spikes
    neuron = zeros(len,numits);

% Generate spikes
    spikeIDXs = randi(len,[numits,numspikes]);
    neuron(spikeIDXs) = 1; 

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

%% Signal detection with random spikes

% Chance that a neuron will detect the event (range 0-1)
    detectionChance = 0.80; 


neuronDetector = neuron;

detections = find(rand(1,numits) <= detectionChance);
neuronDetector(round(len/2),detections) = 1;

% Calculate the downstream response to all neural inputs
    avgDownStreamDetector = sum(neuronDetector');
    avgDownStreamDetector = avgDownStreamDetector / numits;


figure(29); clf; hold on;
    for j=1:min([maxnumtrainstoshow, numits])
        plot(t, neuronDetector(:,j)+j);
    end
    ylim([0.9, min([maxnumtrainstoshow+1, numits+1])])
    plot(round(len/2), 1, 'r*'); plot(round(len/2), min([maxnumtrainstoshow+1, numits+1]), 'r*')

% Plot the downstream neural response
    figure(30); clf; 
        plot(t, avgDownStreamDetector); 
        hold on;
        plot(round(len/2), 1, 'r*'); plot(round(len/2), 0, 'r*')
        ylim([0 1]);



