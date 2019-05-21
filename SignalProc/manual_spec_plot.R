install.packages("signal")
library(signal)

nfft = 1024
wl = 256
ovlp = 128
snd = zfinch_data@left
Fs = zfinch_data@samp.rate
spec = specgram(snd, nfft, Fs, 256, 128)

P = abs(spec$S)

P = P/max(P)

P = 10*log10(P)

t = spec$t


image(x = t, y = spec$f, z = t(P), 
      zlim = c(-35, -5),
      col = (100), 
      ylab = "Frequency [Hz]", 
      xlab = "Time [s]")

spectro(zf_data, zf_data@samp.rate, 256, ovlp = 50, 
        scale = FALSE, 
        collevels = c(-80, 0, 1))

z = t(P)
max(z)
min(z)

-35/-58.6



drericfortunesperfectspectrogramplottingfunction = function(freq_data, Fs, nfft, wl, ovlp, normal = TRUE, scale_dB, color) {
  #requires tuneR (if using wave file for input), signal (to produce spectro data)
  #freq _data may be list of frequencies or wav file
  #if sample rate is provided in wav, it does not need to be specified, otherwise it MUST be given
  #all other parameters are optional and have defaults
  #nfft, wl are input in points
  #ovlp is input in percent 
  
  #create 2 custom palletes for graphing 
  heat_col_custom = c("#FFFFFF","#FDFF97","#EBF900","#FBE900","#FFD600","#FFBF00","#FF7C00","#FF4300","#FF0000","#000000")
  greyscale_custom = c("#FFFFFF","#EEEEEE","#DBDBDB","#C1C1C1","#ACACAC","#8E8E8E","#7A7A7A","#5C5C5C","3E3E3E","000000")
  #check if sample rate is given, if not extract from .wav file
  if(missing(Fs)) {
    Fs = freq_data@samp.rate
  } else {
    Fs = Fs
  }
  
  #checks if nfft is given, if not substitutes default value
  if(missing(nfft)) {
    nfft = 1024
  } else {
    nfft = nfft
  }
  
  #checks if wl is given, if not substitutes default value
  if(missing(wl)) {
    wl = 256
  } else {
    wl = wl
  }
  
  #checks if ovlp is given, if not substitutes default value
  if(missing(ovlp)) {
    ovlp = 128
  } else {
    ovlp = (ovlp/100) * wl
  }
  #check to see if input file is .wav.
  #if .wav, extract freq data, else directly use the data provided
  if(isS4(freq_data) == TRUE) {
    snd = freq_data@left
  } else {
    snd = freq_data
  }

  #remove offset
  snd = snd - mean(snd)
  
  #produce spectrogram of data using signal function  
  ##MUST HAVE SIGNAL INSTALLED 
  spec = specgram(snd, nfft, Fs, wl, ovlp)
  
  #remove phase info
  P = abs(spec$S)
  
  #normalize
  if(normal) {
    P = P/max(P)
  }
  
  #convert to dB
  P = 10*log10(P)
  
  #extract time
  t = spec$t
  
  #check if user entered zlim parameter or set default 
  if(missing(scale_dB)) {
    scale_dB = c(min(t(P))*.6, max(t(P)))
  } else {
    scale_dB = scale_dB
  }
  
  #set color pallete, default is heat, 1 = heat, 2 = greyscale
  if(missing(color)) {
    col_select = heat_col_custom
  } else { 
    if(color == 1){
      col_select = greyscale_custom 
    } else {
      if(color ==2){
        col_select = heat_col_custom 
      } else {
        if(color == 3) {
          col_select = rev(heat_col_custom)
        } else {
          if(color == 4) {
            col_select = rev(greyscale_custom)
          }
        }
      }
    }
  }
  #plot
  image(x = t, y = spec$f, z = t(P), 
        zlim = scale_dB,
        col = col_select, 
        ylab = "Frequency [Hz]", 
        xlab = "Time [s]")
}

drericfortunesperfectspectrogramplottingfunction(zfinch_data)
