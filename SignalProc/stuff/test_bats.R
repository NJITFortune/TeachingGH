install.packages("seewave")
library(seewave)
library(tuneR)

bat_sounds = readWave("myotis_nattereri_1_o.wav")
wcswave = readWave("wcs.wav")

some_syllables = sepsyll(bat_sounds)

Fs = 250000
tim = seq(1/Fs, length(bat_sounds@left)/Fs, 1/Fs)
sms = 0.020

data_center = bat_sounds@left - mean(bat_sounds@left)
rz = abs(data_center)

mrz = runmed(rz, Fs*sms) 


plot(tim, mrz,
     type = "l", 
     col = "Red", 
     ylab = "",
     xlab = "Time")


plot(tim, mrz, 
     type = "l", 
     log = "y", 
     col = "Red", 
     ylab = "", 
     xlab = "Time")


spectro(bat_sounds)

plot(tim, bat_sounds@left,col = "Blue", type = "l", xlab = "Time")
     
plot(tim, bat_sounds@left, 
     main = "Zebra Finch Data", 
     col = "Blue", type = "l", 
     xlab = "Time" , 
     ylab = "", 
     yaxt = "none")
axis(2, seq(27, 227,100))    


plot(rz, col = "Blue", type = "l", xlab = "Time")
plot(mrz, col = "Blue", type = "l")

spectro(some_syllables$Syllable3,
        Fs,
        wl = 1024, 
        zp = 1, 
        fastdisp = TRUE, 
        norm = TRUE, 
        osc = TRUE, 
        palette = reverse.heat.colors, 
        collevels = seq(-100, 10,1))


dev.off()


install.packages("bioacoustics")
library(bioacoustics)

spectro

mrz_filt = which(mrz < 270)

mrz[mrz_filt] = 0

print(some_syllables$Timmy1[1390])
print(length(some_syllables$Syllable1))
plot(some_syllables$Timmy3, some_syllables$Syllable3, col = "Blue", type = "l")      
spectro(some_syllables$Syllable3, Fs, )
