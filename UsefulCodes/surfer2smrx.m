function out = surfer2smrx
% Usage out = surfer2smrx
% Converts a h5 file from wavesurfer to smrx for use with Spike2.
% Creates an smrx file with the same name as the h5 file, but with the smrx extension.
% Does not protect from overwriting
% out is optional and is a structure with the data organized by sweep.
%
% This only works on MS-WINDOWS using the mat-smrx package from CED.
% spike2matson - it can be found on the CED.co.uk website as of fall 2016.
%
% WARNING: only works for sweeps up to 1999.
% WARNING: Does not handle digital channels
% WARNING: Seems like there must be other problems...
% Version 8-Feb-2019 
% ** WORKS WITH wavesurfer v0.965 ***


%% Get the file information % h5disp('DualTest_2016-10-19_0002-0003.h5', '/header', 'simple')

% Do a UIOPEN to find h5 data file
    [fn, pn] = uigetfile('.h5', 'Open WaveSurfer File');
    inh5file = fullfile(pn,fn);

% We will generate a smrx file with the same name in the same directory
    [~, basenm, ~] = fileparts(fn); % gets the basename without the extension
    outsmrxfile = fullfile(pn,[basenm '.smrx']); % Construct the output filename with path

% CED setup
    cedpath = getenv('CEDS64ML');
    addpath(cedpath);

% load ceds64int.dll
    CEDS64LoadLib( cedpath );
    fhand = CEDS64Create(outsmrxfile);
        if (fhand <= 0); CEDS64ErrorMessage(fhand); unloadlibrary ceds64int; return; end
    CEDS64FileComment( fhand, 1, 'Made with surfer2wave' );

% Get and set the sample rate
    Fs = h5read(inh5file, '/header/AcquisitionSampleRate');
    CEDS64TimeBase( fhand, 1/Fs );

%% Setup the read of the h5 file

    AnalogueNames = h5read(inh5file, '/header/AIChannelNames');
    NumAnalogueChans = h5read(inh5file, '/header/NAIChannels');

    %   /header/NSweepsCompletedInThisRun
    %   /header/NSweepsPerRun
    %   /header/SweepDuration
    %   /header/SweepDurationIfFinite 
    %   StartingSweep = h5read(inh5file, '/header/Logging/NextSweepIndex'); % Which was the first sweep number

%% Read the data

% Because I don't know how to easily figure out how many or which sweeps
% are recorded, I do this. It constructs the '/sweep_####/analogScans'
% headers to probe the h5 file. Deeply embarrassing to be sure...

for ttt = 1:-1:0 
    thousands = ttt*1000;
    for h=9:-1:0 
        hundreds = h*100;
        for j=9:-1:0 
            decades = j*10;
            
            for k=9:-1:0
                cursum = thousands+hundreds+decades+k;
                
                if cursum > 0
      datums(cursum,:) = ['/sweep_' num2str(ttt) num2str(h) num2str(j) num2str(k) '/analogScans'];
                end

            end
        end
    end
end

ActualSweeps = 1:1:1999; % We can have up to 1999 sweeps.
FailedSweepsTMP = []; 

for lp = 1999:-1:1 % We have a possible 1999 sweeps - try each one. Sweep counting does not necessarily start at 1.
    try
        a(lp).s = h5read(inh5file, datums(lp,:)); % Attempt to get data from that sweep
    catch
        FailedSweepsTMP(end+1) = lp; % If we fail, catalogue the number so that we can figure out which entries worked.
    end
end

ActualSweeps = setdiff(ActualSweeps, FailedSweepsTMP); % ActualSweeps is now an accurate name for this variable 
NumSweeps = length(ActualSweeps); % How many sweeps do we have
fillret(1:NumAnalogueChans) =  1; % I don't recall what this does...

%% Write the data

% Create the analogue channels 
for kk = 1:NumAnalogueChans % For each channel in our data...
    wavechan = CEDS64GetFreeChan( fhand ); % Read the next free channel number
    createret = CEDS64SetWaveChan( fhand, wavechan, 1, 1); % Create that channel
        if createret ~= 0, warning('waveform channel not created correctly'); end
end

% Use the marker channel ONLY if we are doing sweep data

IsItContinous = h5read(inh5file, '/header/AreSweepsContinuous'); % 1 if continuous, 0 if sweeps

if IsItContinous == 0
% create textmarker channel
    tmarkerbuffer = CEDTextMark();    
    tmarkchan = CEDS64GetFreeChan( fhand );
    createret = CEDS64SetExtMarkChan(fhand, tmarkchan, 1000, 8, 1);
        if createret ~= 0, warning('textmarker channel not created correctly'); end
    CEDS64ChanTitle( fhand, tmarkchan, 'Keyboard');
    %CEDS64ChanUnits( fhand, tmarkchan, 'mA' );

    for j = 1:NumSweeps
        tmarkerbuffer.SetTime( fillret(end) );
        tmarkerbuffer.SetCode( 1, 00);
        tmarkerbuffer.SetData('t');
        footurn = CEDS64WriteExtMarks(fhand, tmarkchan, tmarkerbuffer);
            if footurn < 0, warning('text-marker channel not filled correctly'); end
    end
end % End of the textmarker channel
   
% Now fill each of the analogue channels

for j = NumSweeps:-1:1
    
        out(j).Fs = Fs;
    
    for i=1:NumAnalogueChans % Cycle for each analogue channel
    % Label DATA channel
        CEDS64ChanTitle( fhand, i, AnalogueNames{i});
    %CEDS64ChanComment( fhand, wavechan, 'ADC comment');
        CEDS64ChanUnits( fhand, i, 'Volts' );

        %sTime = CEDS64SecsToTicks( fhand, 0 ); % offset start by 0 seconds
        fillret(i) = CEDS64WriteWave( fhand, i, a(ActualSweeps(j)).s(:,i), fillret(i)); 
        
        out(j).data(:,i) = a(ActualSweeps(j)).s(:,i);
    end

end

 
%% Close the smrx file
CEDS64CloseAll();

