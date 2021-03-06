#function uses specplot function, requires 

sepsyll = function(wav_file, Fs, sms, thresh) {
  
  #make formal class for storage of individual syllable data including: number, sample rate, frequency data, 
  ##time of syllable starting from 0 AND time relative to entire recording, and dominate frequency
  #setClass("Syllable", slots = list(syllable.number = "integer", 
                                    #samp.rate = "integer", 
                                    #frequency.data = "integer", 
                                    #timmy = "numeric", 
                                    #timm = "numeric", 
                                    #dom.freq = "integer"))
  
  #creates a user input for sampling frequency. 
  #If no user input then the function will try to extract from .wav file
  if(missing(Fs)) {
    Fs = wav_file@samp.rate
  } else {
    Fs = Fs
  }

  #creates user input for filter duration in seconds. If there is no input, default is set to 0.020s
  if(missing(sms)) {
    sms = 0.0020
  } else {
    sms = sms
  }
  
  #check to see if input file is .wav.
  #if .wav, extract freq data, else directly use the data provided
  if(isS4(wav_file) == TRUE) {
    wav_file = wav_file@left
  } else {
    wav_file = wav_file
  }
  
  #centers signal at zero 
  data_center = wav_file - mean(wav_file) 
  
  #creates tim variable 
  tim = seq(1/Fs, length(wave_file)/Fs, 1/Fs)
  
  #take absolute value of the centered data
  rz = abs(data_center)
  
  #apply median filter 
  mrz = runmed(rz, Fs*sms) 
  mrz = mrz*1000
  
  #plot data and choose threshold for syllable selection. 
  #This will prompt user to input a click for the threshold if no threshold was specified. 
  #It will then apply that and visualize. 
  #Then the user will be prompted to accept or enter a new value.
  con_plot_thresh = 2
  
  #check to see if threshold is specified
  if (missing(thresh)) {
    con_plot_thresh = 2
  } else {
    #if threshold is specified plot and prompt for confirmation
    thresh = thresh
    plot(tim, mrz, 
         type = "l", 
         log = "y", 
         col = "Red", 
         ylab = "", 
         xlab = "Time")
    par(new = TRUE)
    abline(h = thresh, col = "Blue")
    
    con_plot_thresh = as.integer(readline(prompt = "Is this threshold okay? 1 = Yes ; 2 = No  "))
  }
  #if no threshold specified prompt user to click plot and select threshold.
  #Confirm threshold or restart 
  con_plot_thresh = con_plot_thresh
  
  while (con_plot_thresh == 2) {
    plot(tim, mrz, 
         type = "l", 
         log = "y", 
         col = "Red", 
         ylab = "", 
         xlab = "Time")
    print("Please click on plot to set threshold.")
    thresh = locator(1)
    thresh = thresh[2]
    plot(tim, mrz, 
        type = "l", 
        log = "y", 
        col = "Red", 
        ylab = "", 
        xlab = "Time")
    par(new = TRUE)
    abline(h = thresh, col = "Blue")
    print(thresh)
   
    con_plot_thresh = as.integer(readline(prompt = "Is this threshold okay? 1 = Yes ; 2 = No  "))
  
    }
  
  
  
  
  #here we are pulling out the start and end times of the syllables 
  syls = which(mrz > thresh)
  #create a list of zeros with length = to the length of the file
  zz = rep(0, length((wave_file@left)))
  #sets all points about threshold = 1
  zz[syls] = 1
  #take difference, this will give us a list of 1s and -1s marking start and end times
  yy = diff(zz)
  
  #identify our start and end points
  #correct for partial syllables by removing the first/last syllable if the recording does not begin 
  #with a start(1) or end with and end(-1)
  if(yy[1] == 1) {
    starts = which(yy == 1)
  } else {
    yy[1] = NULL
    starts = which(yy == 1)
  }
  if(yy[length(yy)] == -1) {
    ends = which(yy == -1)
  } else {
    yy[length(yy)] = NULL
    ends = which(yy == -1)
  }
  
  #create empty lists to store our syllable data in
  syllable = c()
  timmy = c()
  timm = c()
  
  
  #create our output data for syllable locations
  for (i in seq(1,length(starts))) {
    
    syllable[[i]] = wave_file@left[starts[i]:ends[i]]
    timmy[[i]] = tim[starts[i]:ends[i]]
    timm[[i]] = seq(1/Fs, (1 + ends[i] - starts[i])/Fs, 1/Fs)
    
  }
  
  all_syllables = c("Syllable" = syllable, "Timmy" = timmy, "Timm" = timm)
  return(all_syllables)
  
}


