#' slop
#'
#' Graphs spectrogram of bat or bird sounds and marks beginning and end of syllables. slop can also plot dominate frequency on
#' top of the spectrogram.
#'
#' @return A plot containing marked syllables and dominate frequencies
#'
#' @usage slop(zfinch_data, zf_syllables)
#'
#' @param wav_file A .wav file or list of frequency data
#' @param syllable_data A data frame produced by the sepsyll function
#' @param Fs Sample rate, optional if included in .wav file
#' @param nfft Default value 128 when bat = TRUE, when bat = FALSE the default is 512
#' @param dom_freq defaults to TRUE, includes dominate frequency plot
#' @param bat Defaults to TRUE, a series of default values tuned to produce nice plots from bat data
#'
#' @examples
#'
#' @export

slop = function(wav_file, syllable_data, Fs, nfft, dom_freq = TRUE, bat = TRUE, amp_range) {

  #check for and set nfft
  if(missing(nfft) & bat == FALSE ) {
    nfft = 512
  }
  if(missing(nfft) & bat == TRUE) {
    nfft = 128
  } else {
    nfft = nfft
  }

  #set defaults for amp_range
  if(missing(amp_range) & bat == TRUE) {
    ar = c(-10,0)
  }
  if(missing(amp_range) & bat == FALSE) {
    ar = c(-25,0)
  } else {
    ar = amp_range
  }


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
    wav_file = wav_file
  }

  #generate dominant frequency, check to see if dom_freq is set to TRUE
  if(dom_freq){

    #check to see if syllable start and end data is provided
    if(missing(syllable_data)) {
      #plot just spectro and dominant frequency if no syllable start or end data
      specplot(wav_file, Fs, nfft = nfft, amp_range = ar)
      par(new = TRUE)
      #dfreq function from seewave
      dfreq(wav_file, f = Fs,
            type = "l",
            wl = nfft,
            ovlp = 95,
            xaxt = "none",
            yaxt = "none",
            xlab = "",
            ylab = "",
            col = "Blue",
            lwd = 2)

    } else {
      #create list of start and end data for syllables
      starts = syllable_data$syllable_start/Fs
      ends = syllable_data$syllable_ends/Fs
      #plot
      specplot(wav_file, Fs, nfft = nfft, amp_range = ar)
      abline(v = starts, col = "Green", lwd = .5)
      abline(v = ends, col = "Red", lwd = .5)
      par(new = TRUE)
      dfreq(wav_file, f = Fs,
            type = "l",
            wl = nfft,
            ovlp = 95,
            xaxt = "none",
            yaxt = "none",
            xlab = "",
            ylab = "",
            col = "Blue",
            lwd = 2)
    }
  } else {
    #if dominant frequency is not choosen, plot without
    #create list of start and end data for syllables
    starts = syllable_data$syllable_start/Fs
    ends = syllable_data$syllable_ends/Fs
    #plot using ablines and list of times
    specplot(wav_file, Fs, nfft = nfft, amp_range = ar)
    abline(v = starts, col = "Green", lwd = .5)
    abline(v = ends, col = "Red", lwd = .5)
  }
}
