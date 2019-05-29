#' slop
#'
#' Graphs spectrogram of bat or bird sounds and marks beginning and end of syllables. slop can also plot dominate frequency on
#' top of the spectrogram.
#'
#' @return A plot containing marked syllables and dominate frequencies
#'
#' @param wav_file
#' @param Fs
#' @param syllable_data
#' @param dom_freq
#' @param ...

slop = function(wav_file, Fs, syllable_data, dom_freq = FALSE, ...) {

  #check if sample rate is given, if not extract from .wav file
  if(missing(Fs)) {
    Fs = wav_file@samp.rate
  } else {
    Fs = Fs
  }

  #check to see if input file is .wav.
  #if .wav, extract freq data, else directly use the data provided
  if(isS4(wav_file) == TRUE) {
    wav_file = wav_file@left
  } else {
    wav_file = wave_file
  }

  #generate dominant frequency, check to see if dom_freq is set to TRUE
  if(dom_freq){

    #check to see if syllable start and end data is provided
    if(missing(syllable_data)) {
      #plot just spectro and dominant frequency if no syllable start or end data
      specplot(wav_file, Fs)
      par(new = TRUE)
      plot()
      dfreq(wav_file, Fs, ovlp = 90, type = "l")

    } else {
      #create list of start and end data for syllables
      starts = syllable_data@syllable_start/Fs
      ends = syllable_data@syllable_end/Fs
      #plot
      specplot(wav_file, Fs)
      abline(v = starts, col = "Green", lwd = 2)
      abline(v = ends, col = "Red", lwd = 2)
    }
  } else {
    #if dominant frequency is not choosen, plot without
    #create list of start and end data for syllables
    starts = syllable_data@syllable_start/Fs
    ends = syllable_data@syllable_end/Fs
    #plot using ablines and list of times
    specplot(wav_file, Fs)
    abline(v = starts, col = "Green", lwd = 2)
    abline(v = ends, col = "Red", lwd = 2)
  }
}
