#' getclicks
#'
#' This function gets the location of user-input clicks on the plotting window in order to extract
#' extract data from song spectrograms. You can input one or more series of clicks.
#' The program is interactive and requires user input. Will cyle through spectrogram in user defined
#' increments.
#'
#' @return A nested list of x-positions(time in seconds)
#'
#' @usage getclicks(zfinch_data)
#'
#' @param wav_file A .wav file of vector/list of frequency data
#' @param Fs The sampling rate. Does not need to be provided if it is included in the .wav
#' @param frame_shift User defined display window size for collecting clicks. Will default to
#' 2 seconds. Input in seconds.
#'
#' @examples
#' getclicks(zfinch_data, frame_shift = 1)


getclicks = function(wav_file, Fs, frame_shift){

  #variable to continue/end click collection
  continue = 1

  #function to merge click positions nicely, internal, called later on
  #adds each element in collected lists to larger list.
  internallistcombine = function(list1, list2){
    #create empty list
    n = c()

    for(x in list1){
      n = c(n, x)
    }
    for(y in list2){
      n = c(n, y)
    }
    return(n)
  }

  #check to see if user specified Fs, if not then use embedded wav sample rate
  if(missing(Fs)){
    Fs = wav_file@samp.rate
  } else {
    Fs = Fs
  }

  #check to see if wav_file is actually a wav and extract frequency data. If not wav, then just use the data
  if(isS4(wav_file)) {
    wav_file = wav_file@left
  } else {
    wav_file = wav_file
  }

  #add variable frame shift with a default value of 2
  if(missing(frame_shift)) {
    frame_shift = 2
  } else {
    frame_shift = frame_shift
  }

  #get the length of clip in seconds
  tmax = length(wav_file)/Fs
  #series from 0 to the max number of frameshifts to be ploted, prevents plotting out of bounds
  nframe = c(-1:trunc(tmax/2)+1)
  #set up collection points for click data
  internal_data_collect = c()

  #plot entire spectro to get overview
  specplot(wav_file, Fs)


  #main function. while loop that will ask to continue when finished. allows multiple click series to be captured
  while(continue == 1) {
    #prompts user to name click series
    name_set = readline(prompt = "Enter series name: ")
    #changing variable for shifting frame
    new_plot = 1
    #multiplier for frame shift, resets each loop
    nshift = 0
    #creates new storage list. also clears list at the start of loop
    internal_list = c()

    #actual click capture part.
    while(new_plot == 1) {
     #start frame
      sframe = c(0, frame_shift)
      #amount of frame shift
      ##modify this to add overlap
      shift = c(frame_shift, frame_shift)

      #set the frame to graph
      #test if the upper limit "b" of tlim c(a,b) is greater than the tmax of the clip.
      #if b is greater than tmax, tmax is used as upper tlim, prevents plotting out of bounds
      pframe = if((nshift+1)*shift[2] <= tmax) {
        sframe + shift*nshift
      } else {
        c(sframe[1] + nshift*shift[1], tmax)
      }

      #plot portion of spectrogram. 2 second intervals
      specplot(wav_file, Fs, x_limit = pframe)

      print("Select points on graph. Hit 'ESC' when complete")

      #collect set of clicks
      #plots points
      ##locator is slow for some reason. it doesn't like to plot these points
      clicks = locator(type = "p", col = "Red")
      #take only x values
      clicks_x = clicks[1]
      #create internal function list of click x values
      internal_list = list("a" = internallistcombine(internal_list, clicks[1]))


      #check to see if plotting complete
      continue_plot = ifelse(pframe[2] == tmax, 0, 1)
      new_plot = continue_plot
      #add 1 to nshift, advancing plot window
      nshift = nshift + 1
    }

  #rename set of clicks to user generated name
  names(internal_list) = name_set
  #add newly generated and named list to function variable for storage
  internal_data_collect = append(internal_data_collect, internal_list)

  continue = as.integer(readline(prompt = "Would you like to select another series of points? 1 = Yes ; 2 = No  "))
  }
  return(internal_data_collect)
}

document()






