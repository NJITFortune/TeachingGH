#' specplot
#'
#' This function will plot spectrograms. It works with either a wav file read by tuneR or frequency data.
#' When using frequency data alone, you need to specify a sample frequency. This function relies on the
#' imagep function from oce. specplot uses custom color palettes with 30 colors. Most parameters have defaults
#' and do not need to be specified by the user. Can pass graphical arguements onto imagep.
#'
#' @return A plot of a spectrgram using the default R graphics
#'
#' @usage specplot = function(freq_data, Fs, nfft, wl, ovlp, normal = TRUE, amp_range, color, amp_value = FALSE)
#'
#' @param freq_data Wav file or frequency data
#' @param Fs Sample rate, not necessary if provided by .wav file
#' @param nfft Defaults to 512
#' @param wl Defaults to 1/2 nfft
#' @param ovlp Overlap, give in percent. Defaults to 50 percent
#' @param normal Normalize. Defaults to TRUE
#' @param amp_range DB range
#' @param x_limit List of x-limits
#' @param y_limit List of y-limits
#' @param color Choose from 4 present color palettes; 1 = reverse heat, 2 = reverse greyscale, 3 = greyscale, 4 = heat
#' Defaults to reverse heat
#' @param amp_value Display min and max dB. Defaults to FALSE
#' @param no_label Removes plot axes labels. Defaults to FALSE
#' @param ... Pass on plot and graphical arguments. See function imagep in oce for availanble arguments
#'
#' @examples
#' specplot(zfinch_data, ovlp = 90, color = 2, amp_value = TRUE, amp_range = c(-45,-10))
#'
#' @export

specplot = function(freq_data, Fs, nfft, wl, ovlp, normal = TRUE, amp_range, x_limit, y_limit, color, amp_value = FALSE, no_label = FALSE, ...) {
  #requires tuneR (if using wave file for input), signal (to produce spectro data), and oce (for plotting)
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
    nfft = 512
  } else {
    nfft = nfft
  }

  #checks if wl is given, if not substitutes default value
  if(missing(wl)) {
    wl = nfft/2
  } else {
    wl = wl
  }

  #checks if ovlp is given, if not substitutes default value
  if(missing(ovlp)) {
    ovlp = wl/2
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

  #extract frequency for later
  f = spec$f

  #output amp values
  if(amp_value) {
    print(max(t(P)))
    print(min(t(P)))
  }


  #check if user entered zlim parameter or set default
  bottom_amp = 0.6
  top_amp = 1
  if(missing(amp_range)) {
    amp_range = c(min(t(P))*bottom_amp, max(t(P))*top_amp)
  } else {
    amp_range = amp_range
  }

  #set color pallete, default is heat, 1 = greyscale, 2 = heat, 3 = rev heat, 4 = rev greyscale
  if(missing(color)) {
    col_select = rev(heat_col_custom)
    box_col = "Black"
    par(bg = "white")
    par(col.lab="black")
    par(col.axis="black")
    par(col.main="black")
  } else {
    if(color == 3){
      col_select = greyscale_custom
      box_col = "Black"
      par(bg = "white")
      par(col.lab="black")
      par(col.axis="black")
      par(col.main="black")
    } else {
      if(color ==4){
        col_select = heat_col_custom
        box_col = "Black"
        par(bg = "white")
        par(col.lab="black")
        par(col.axis="black")
        par(col.main="black")
      } else {
        if(color == 1) {
          col_select = rev(heat_col_custom)
          par(bg = "black")
          par(col.lab="white")
          par(col.axis="white")
          par(col.main="white")
          box_col = "white"
        } else {
          if(color == 2) {
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

  #check to see if user input x limits
  if(missing(x_limit)) {
    x_limit = c(t[1], t[length(t)])
  } else {
    x_limit = x_limit
  }

  #check to see if user input y limits
  if(missing(y_limit)) {
    y_limit = c(f[1], f[length(f)])
  } else {
    y_limit = y_limit
  }
  
  if(no_label == FALSE)
  {
    #check to see frequency max
    if(max(f) > 100000) {
      #plot in kHz
      imagep(x = t, y = f, z = t(P),
             zlim = amp_range,
             col = col_select,
             ylab = "Frequency [kHz]",
             xlab = "Time [s]",
            drawPalette = FALSE,
            decimate = FALSE,
            xlim = x_limit,
            ylim = y_limit,
            axes = FALSE,
            ...)
      axis(2, at = seq(0, max(f), 20000), labels = seq(0, max(f)/1000, 20))
      axis(1)
      box(col = box_col)

    } else {
      #plot in [Hz]
      imagep(x = t, y = f, z = t(P),
            zlim = amp_range,
            col = col_select,
            ylab = "Frequency [Hz]",
            xlab = "Time [s]",
            drawPalette = FALSE,
            decimate = FALSE,
            xlim = x_limit,
            ylim = y_limit,
            ...)
      box(col = box_col)
    }
  } else {
    
    #plot without axis of frame
    imagep(x = t, y = f, z = t(P),
           zlim = amp_range,
           col = col_select,
           ylab = "",
           xlab = "",
           drawPalette = FALSE,
           decimate = FALSE,
           xlim = x_limit,
           ylim = y_limit,
           axes = FALSE,
           bty = 'n',
           mar = rep(0, 4),
           ...)
    box(col = box_col)
    
  }
  
}
