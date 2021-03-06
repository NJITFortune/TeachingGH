#' sepsyll
#'
#' This function seperates syllables from a recording. This recording can be a .wav file read by tuneR or
#' frequency data. This function has two options for output: It can return a list of lists that includes syllable frequency data,
#' syllable time, and syllable time relative to recordin. Alternatively it can output a datafram of syllable start and end indices and times.
#'
#' @return A list of syllables and times. Timmy is the time in relation to the entire song. Timm is the time of the individual syllable.
#' -OR-
#' A dataframe containing the start and end indices and times of each syllable.
#'
#' @usage sepsyll = function(wav_file, Fs, sms, thresh, syllable_filter = FALSE, syl_filt)
#'
#' @param wav_file Can be either a .wav file or a list of frequencies.
#' @param Fs Sampling rate, can be supplied by .wav or specified.
#' @param sms Sets the filter threshold. Defaults to 20ms (0.020 seconds).
#' @param thresh Sets the threshold for identifying syllables. If there is not a user specified threshold, the data will
#' plot and you will be prompted to select a threshold level.
#' @param syllable_filter Defaults to TRUE. Turns off/on the syllable filter (filter defined with syl_filt).
#' @param syl_filt Sets a minimum time for syllables in order to filter out non-syllables
#' i.e. syllables that are detected as a result of noise and are not of interest. Defaults to 0.02s.
#' @param plot_thresh If a user specified threshold is used, setting to TRUE will plot threshold and prompt for confirmation. Defaults to true.
#' Turn of if you know your threshold and don't want to waste time plotting and confirming.
#' @param plot_syl Plot a spectrogram with the start and ends of each syllable marked in green/red respectively.
#' @param index_simp Changes output from default data to indices and times of syllables as a dataframe. Default FALSE.
#' @param syl_buff Adds a buffer to each the start and end of each extracted syllable to avoid losing the beginning or end. Input in seconds, defaults to 0.
#'
#' @examples
#' sepsyll(zfinch_data, thresh = 1000, syllable_filter = TRUE, syl_filt = 15)
#'
#' @export

sepsyll = function(wav_file, Fs, sms, thresh, syllable_filter = TRUE, syl_filt, plot_thresh = TRUE, plot_syl = FALSE, index_simp = FALSE, syl_buff) {

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
    sms = 0.020
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

  #checks to see if there is a syl_filt specified, if not uses default of 0.02 seconds
  if(missing(syl_filt)) {
    syl_filt = .02
  } else {
    syl_filt = syl_filt
  }

  #check to see if syl_buff is specified, if not default to 0s
  #convert seconds to samples
  if(missing(syl_buff)) {
    syl_buff = 0
  } else {
    syl_buff = syl_buff*Fs
  }

  #centers signal at zero
  data_center = wav_file - mean(wav_file)

  #creates tim variable
  tim = seq(1/Fs, length(wav_file)/Fs, 1/Fs)

  #take absolute value of the centered data
  rz = abs(data_center)

  #integer width of median window value for median filter. must be odd
  #will change to odd if even
  k = as.integer(Fs*sms)
  if((k %% 2) == 0) {
    k = k + 1
  } else {
    k = k
  }

  #apply median filter
  mrz = runmed(rz, k)
  mrz = mrz*100

  #plot data and choose threshold for syllable selection.
  #This will prompt user to input a click for the threshold if no threshold was specified.
  #It will then apply that and visualize.
  #Then the user will be prompted to accept or enter a new value.
  con_plot_thresh = 2

  #check to see if threshold is specified
  if (missing(thresh)) {
    con_plot_thresh = 2
  } else {
    #if threshold is specified plot
    thresh = thresh
    plot(tim, mrz,
         type = "l",
         log = "y",
         col = "Red",
         ylab = "",
         xlab = "Time")
    par(new = TRUE)
    abline(h = thresh, col = "Blue")

    #if plot_thresh is TRUE plot user entered threshold and prompt for confirmation
    if(plot_thresh){
      con_plot_thresh = as.integer(readline(prompt = "Is this threshold okay? 1 = Yes ; 2 = No  "))
    } else {
      con_plot_thresh = 1
    }
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
  zz = rep(0, length((wav_file)))
  #sets all points above threshold = 1
  zz[syls] = 1
  #take difference, this will give us a list of 1s and -1s marking start and end times
  yy = diff(zz)

  #extract start and end indices
  starts = which(yy == 1)
  ends = which(yy == -1)
  #create temp variables for index output
  filt_starts = c()
  filt_ends = c()


  #correct for partial syllables by removing the first/last syllable if the recording does not begin
  #with a start(1) or end with and end(-1)
  if(starts[1] < ends[1]) {
    starts = starts
  } else {
    ends = ends[2:length(ends)]
  }
  if(ends[length(ends)] > starts[length(starts)]) {
    ends = ends
  } else {
    starts = starts[1:length(start)-1]
  }

  #apply sylable buffer, first to starts, then to ends
  #check to make sure syllables don't run out of bounds
  for(i in seq(1, length(starts))) {
    #make sure ends[[i-1]] exists
    if(i-1 > 0) {
      #should modify any syllable that does not go into negative time or overlap with another syllable
      #modify any syllable that overlaps
      #should modify any syllable that goes into negative time
      if(starts[[i]]-syl_buff >= 0 && starts[[i]]-syl_buff > ends[[i-1]]) {
        starts[[i]] = starts[[i]]-syl_buff
      } else if(starts[[i]]-syl_buff <= ends[[i-1]])  {
        starts[[i]] = starts[[i]]-abs((ends[[i-1]]-starts[[i]])-1)
      } else if(starts[[i]]-syl_buff <= 0) {
        starts[[i]] = starts[[i]]-abs((ends[[i]]-starts[[i+1]])-1)
      }
    } else if(starts[[i]]-syl_buff <= 0) {
      starts[[i]] = 0
    }
  }

  for(i in seq(1, length(ends))) {
    #make sure starts[[i+1]] exists
    if(i+1 <= length(starts)) {
      #should modify any syllable that does not go overtime or overlap with another syllable
      #modify any syllable that overlaps
      #should modify any syllable that goes overtime
      if(ends[[i]]+syl_buff <= length(wav_file) && ends[[i]]+syl_buff < starts[[i+1]]) {
        ends[[i]] = ends[[i]]+syl_buff
      } else if(ends[[i]]+syl_buff >= starts[[i+1]]) {
        ends[[i]] = ends[[i]]+abs((starts[[i+1]]-ends[[i]])-1)
      } else if(ends[[i]]+syl_buff >= length(wav_file)) {
        ends[[i]] = ends[[i]]+abs((ends[[i]]-starts[[i+1]])-1)
      }
    } else if(ends[[i]]+syl_buff >= length(wav_file)) {
      ends[[i]] = length(wav_file)
    }
  }

  #determine if the user wants index data or full syllable data and output as dataframe
  if(index_simp) {
    #filter out small non-syllables if syllable filter is true
    if(syllable_filter) {
      syl_index = ends - starts
      syl_filt_b = syl_filt*Fs
      for (s in seq(1, length(starts))) {
        if(syl_index[[s]] >= syl_filt_b) {
          filt_starts[[s]] = starts[[s]]
          filt_ends[[s]] = ends[[s]]
        }
      }
      #generate final lists by replacing storage lists with temporary lists - null values
      starts = filt_starts[!sapply(filt_starts, is.na)]
      ends = filt_ends[!sapply(filt_ends, is.na)]
    }
    #output
    #index_out = c("syl_start" = starts, "syl_end" = ends)
    index_out = data.frame(syllable_number = c(1:length(starts)),
                           syllable_start = starts,
                           syllable_ends = ends,
                           syllable_start_time = starts/Fs,
                           syllable_end_time = ends/Fs)
    return(index_out)
  } else {
    #create empty lists to store syllable data in
    syllable = c()
    timmy = c()
    timm = c()
    filt_syl = c()
    filt_timm = c()
    filt_timmy = c()

    if(syllable_filter) {
      syl_index = ends - starts
      syl_filt_b = syl_filt*Fs
      for (s in seq(1, length(starts))) {
        if(syl_index[[s]] >= syl_filt_b) {
          filt_starts[[s]] = starts[[s]]
          filt_ends[[s]] = ends[[s]]
        }
      }
      #generate final lists by replacing storage lists with temporary lists - null values
      starts = filt_starts[!sapply(filt_starts, is.na)]
      ends = filt_ends[!sapply(filt_ends, is.na)]
    }


    #create our output data for syllable locations
    for (i in seq(1,length(starts))) {
      syllable[[i]] = wav_file[starts[i]:ends[i]]
      timmy[[i]] = tim[starts[i]:ends[i]]
      timm[[i]] = seq(1/Fs, (1 + ends[i] - starts[i])/Fs, 1/Fs)

    }

    #create final output as nested list
    all_syllables = c("syl" = syllable, "syl_time" = timm, "time" = timmy)
    return(all_syllables)
  }

  if(plot_syl) {
    specplot(wav_file, Fs)
    par(new = TRUE)
    abline(v = starts, col = "Green")
    abline(v = ends, col = "Red")
  }

}


