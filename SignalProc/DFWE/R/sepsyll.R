#' sepsyll
#'
#' This function seperates syllables from a recording. This recording can be a .wav file read by tuneR or
#' frequency data. It will return a list of lists and can be searched by index. All syllables and times will be numbered.
#' Syllable frequency data, syllable time, and syllable time relative to recording are all included.
#'
#' @return A list of syllables and times
#'
#' @usage sepsyll = function(wav_file, Fs, sms, thresh, syllable_filter = FALSE, syl_filt)
#'
#' @param wav_file Can be either a .wav file or a list of frequencies
#' @param Fs Sampling rate, can be supplied by .wav or specified
#' @param sms Sets the filter threshold. Defaults to 20ms (0.0020 seconds)
#' @param thresh Sets the threshold for identifying syllables. If there is not a user specified threshold, the data will
#' plot and you will be prompted to select a level.
#' @param syllable_filter Defaults to false. Turns off/on the syllable filter set with syl_filt.
#' @param syl_filt Sets a minimum sample length for syllables in order to filter out non-syllables
#' i.e. syllables that are detected as a result of noise and are not of interest. Defaults to 50.
#'
#' @examples
#' sepsyll(zfinch_data, thresh = 1000, syllable_filter = TRUE, syl_filt = 15)
#'
#' @export

sepsyll = function(wav_file, Fs, sms, thresh, syllable_filter = FALSE, syl_filt) {

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

  #creates user input for filter duration in seconds. If there is no input, default is set to 0.0020s
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

  #checks to see if there is a syl_filt specified, if not uses default of 50 samples
  if(missing(syl_filt)) {
    syl_filt = 50
  } else {
    syl_filt = syl_filt
  }

  #centers signal at zero
  data_center = wav_file - mean(wav_file)

  #creates tim variable
  tim = seq(1/Fs, length(wav_file)/Fs, 1/Fs)

  #take absolute value of the centered data
  rz = abs(data_center)

  #integer width of median window value for median filter. must be odd
  #will change to odd if even
  k = Fs*sms
  if((k %% 2) == 0) {
    k = k + 1
  } else {
    k = k
  }

  #apply median filter
  mrz = runmed(rz, Fs*sms)

  #mrz = mrz*1000

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
  zz = rep(0, length((wav_file)))
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

  #create empty lists to store syllable data in
  syllable = c()
  timmy = c()
  timm = c()


  #create our output data for syllable locations
  for (i in seq(1,length(starts))) {
    syllable[[i]] = wav_file[starts[i]:ends[i]]
    timmy[[i]] = tim[starts[i]:ends[i]]
    timm[[i]] = seq(1/Fs, (1 + ends[i] - starts[i])/Fs, 1/Fs)

  }

  #checks to see if syllables (and timm, timmy) meet the minimum sample length requirement. if not, delete
  if(syllable_filter){
    for (s in seq(1, length(syllable))) {
      if(length(syllable[[s]]) <= syl_filt) {
        syllable[s] = NULL
      }
      if(length(timmy[[s]]) <= syl_filt) {
        timmy[s] = NULL
      }
      if(length(timm[[s]]) <= syl_filt) {
        timm[s] = NULL
      }
    }
  }


  all_syllables = c("syllable" = syllable, "timmy" = timmy, "timm" = timm)
  return(all_syllables)

}


