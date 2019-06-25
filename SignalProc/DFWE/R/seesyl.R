#' seesyl
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
#' @param bat Defaults to TRUE, a series of default values tuned to produce nice plots from bat data
#' @param ... Pass parameters on to specplot function !!EXCEPT amp_range!!
#'
#' @examples slop(wav_file = bat_sounds, syllable_data = bat_syl)
#'
#' @export

seesyl = function(wav_file, syllable_data, Fs, nfft, bat = TRUE, ...) {

  #check for and set nfft
  if(missing(nfft) & bat == FALSE ) {
    nfft = 512
  }
  if(missing(nfft) & bat == TRUE) {
    nfft = 128
  } else {
    nfft = nfft
  }

  #set defaults for amp_range when bat = TRUE
  if(bat) {
    ar = c(-10,0)
  } else {
    ar = c(-25,0)
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


  #create list of start and end data for syllables
  starts = syllable_data$syllable_start/Fs
  ends = syllable_data$syllable_ends/Fs
  #plot using ablines and list of times
  specplot(wav_file, Fs, nfft = nfft, amp_range = ar, ...)
  abline(v = starts, col = "Green", lwd = .5)
  abline(v = ends, col = "Red", lwd = .5)
}
