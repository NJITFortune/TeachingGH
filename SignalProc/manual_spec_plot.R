install.packages("signal")
library(signal)
library(ggplot2)
install.packages("oce")
library(oce)
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

c("#FFFFFF","#FFFBCC","#FFF8A0","#FFF572","#FFF24A","#FFF028","#FFEC00","#FFEC00","#FFE100","#FFD600","#FFBF00","#FFA900","#FF9D00","#FF8700","#FF7C00","#FF6500","#FF4F00","#FF4300","#FF3800","#FF0000","#E30000","#D00000","#BD0000","#9C0000","#850000","#520000","#3E0000","#270000","#130000","#000000")

drericfortunesperfectspectrogramplottingfunction = function(freq_data, Fs, nfft, wl, ovlp, normal = TRUE, scale_dB, color) {
  #requires tuneR (if using wave file for input), signal (to produce spectro data)
  #freq _data may be list of frequencies or wav file
  #if sample rate is provided in wav, it does not need to be specified, otherwise it MUST be given
  #all other parameters are optional and have defaults
  #nfft, wl are input in points
  #ovlp is input in percent 
  
  #create 2 custom palletes for graphing 
  heat_col_custom = c("#FFFFFF","#FFFBCC","#FFF8A0","#FFF572","#FFF24A","#FFF028","#FFEC00","#FFEC00","#FFE100","#FFD600","#FFBF00","#FFA900","#FF9D00","#FF8700","#FF7C00","#FF6500","#FF4F00","#FF4300","#FF3800","#FF0000","#E30000","#D00000","#BD0000","#9C0000","#850000","#520000","#3E0000","#270000","#130000","#000000")
  #heat color alternate pallete
  #c("#FFFFFF","#FFF254","#FFF700","#FFEC00","#FFE100","#FFD600","#FFBF00","#FFA900","#FF9D00","#FF8700","#FF7C00","#FF7000","#FF6500","#FF4F00","#FF4300","#FF3800","#FF2D00","#FF1600","#FF0B00","#FF0000","#E30000","#D00000", "#BD0000","#9C0000","#850000","#520000","#3E0000","#270000","#130000", "#000000")
  greyscale_custom = c("#FFFFFF","#F9F9F9","#F4F4F4","#F0F0F0","#EAEAEA","#E5E5E5","#E1E1E1","#DDDDDD","#D9D9D9","#D2D2D2","#CCCCCC","#C7C7C7","#C1C1C1","#BFBFBF","#BABABA","#B2B2B2","#A9A9A9","#9F9F9F","#949494","#8E8E8E","#818181","#747474","#696969","#636363","#585858","#4B4B4B","#3E3E3E","#333333","#202020","#000000")
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
  
  #set color pallete, default is heat, 1 = greyscale, 2 = heat, 3 = rev heat, 4 = rev greyscale
  if(missing(color)) {
    col_select = heat_col_custom
  } else { 
    if(color == 1){
      col_select = greyscale_custom
      box_col = "Black"
      par(bg = "white")
      par(col.lab="black")
      par(col.axis="black")
      par(col.main="black")
    } else {
      if(color ==2){
        col_select = heat_col_custom
        box_col = "Black"
        par(bg = "white")
        par(col.lab="black")
        par(col.axis="black")
        par(col.main="black")
      } else {
        if(color == 3) {
          col_select = rev(heat_col_custom)
          par(bg = "black")
          par(col.lab="white")
          par(col.axis="white")
          par(col.main="white")
          box_col = "white"
        } else {
          if(color == 4) {
            col_select = rev(greyscale_custom)
            par(bg = "black")
            par(col.lab="white")
            par(col.axis="white")
            par(col.main="white")
            box_col = "white"
          }
        }
      }
    }
  }
  #plot
  imagep(x = t, y = spec$f, z = t(P), 
        zlim = scale_dB,
        col = col_select, 
        ylab = "Frequency [Hz]", 
        xlab = "Time [s]",
        drawPalette = TRUE)
  box(col = box_col)
}

drericfortunesperfectspectrogramplottingfunction(zfinch_data, scale_dB = c(-30, 0), color = 2)


  