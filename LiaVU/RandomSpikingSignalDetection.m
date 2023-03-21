clear all

%% Random spikes 

numits = 1024; % How many neurons 

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