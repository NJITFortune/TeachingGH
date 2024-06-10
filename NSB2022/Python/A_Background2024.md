# Import libraries
```{python}
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import find_peaks, butter, filtfilt
```

# Parameters
```{python}
Fs = 20000  # Sample rate
EndTime = 2  # Length of signals in seconds
windowidth = 0.15  # Width of plot in seconds

S1f = 250  # Frequency in Hz of first fish
S2f = 260  # Frequency in Hz of second fish
```

# Make the sinewaves
```{python}
tim = np.arange(1/Fs, EndTime, 1/Fs)  # time stamps for EndTime seconds of sampling
S1 = np.sin(tim * S1f * 2 * np.pi)  # Fish #1 - 250 Hz
S2 = np.sin(tim * S2f * 2 * np.pi) * 0.8  # Fish #2 - 260 Hz and 80% of amplitude of fish #1
```

# Plot sinewaves
plt.figure()
plt.title('Two EOD signals')
plt.plot(tim, S1, 'b', label='S1')
plt.plot(tim, S2, 'm', label='S2')
plt.xlim([0, windowidth])
plt.legend()
plt.show()


#################################################

# Summing sinewaves
ss = S1 + S2
ass = np.abs(S1 + S2)
LOCS, _  = find_peaks(ass)

plt.figure()
plt.title("Summed signal and beat - AMs and PMs")
plt.plot(tim, ss, 'k-', label='Summed signal')
plt.plot(tim[LOCS], ass[LOCS], 'r.-', label='Envelope')
plt.xlim([0, windowidth])
plt.legend()
plt.show()

#####################################################

# SAM Sinewave
samFreq = abs(S1f - S2f)
sam = 0.5 + (np.cos(samFreq * 2 * np.pi * tim) * 0.4)
S1AM = sam * S1

fig, (ax1, ax2) = plt.subplots(2, 1)
ax1.set_title('Signal and AM')
ax1.plot(tim, S1, 'b', label='S1')
ax1.plot(tim, sam, 'm', label='SAM')
ax1.legend()

ax2.set_title('Modulated signal')
ax2.plot(tim, S1AM, 'k', label='S1AM')
ax2.plot(tim, sam, 'r', label='SAM')
ax2.legend()

fig.tight_layout()
plt.xlim([0, windowidth])
plt.show()

######################################################
# Sum of Sines signals
otherFreqs = np.array([255.55, 269.21, 292.03])
otherFreqs.sort()

SoSreal = np.sin(tim * S1f * 2 * np.pi)
for freq in otherFreqs:
    SoSreal += np.sin(2 * np.pi * tim * freq)

aSoSreal = np.abs(SoSreal)
LOCS, _ = find_peaks(aSoSreal)

fig, (ax1, ax2) = plt.subplots(2, 1)
ax1.set_title('Sum of Sines signal by adding EODs')
ax1.plot(tim, SoSreal, 'k', linewidth=1)
ax1.plot(tim[LOCS], aSoSreal[LOCS], 'r.-')
ax1.set_xlim([0, 0.2])

# Difference frequencies
SoSmult = np.zeros(len(tim))
dFFreqs = otherFreqs - S1f
dFFreqs = np.append(dFFreqs, np.diff(otherFreqs))

if len(otherFreqs) == 3:
    dFFreqs = np.append(dFFreqs, otherFreqs[0] - otherFreqs[2])
elif len(otherFreqs) == 4:
    dFFreqs = np.append(dFFreqs, [otherFreqs[0] - otherFreqs[2], otherFreqs[0] - otherFreqs[3], otherFreqs[1] - otherFreqs[3]])

for freq in dFFreqs:
    SoSmult += (1 + np.cos(2 * np.pi * tim * freq))

SoSmult -= min(SoSmult)
SoSmult /= max(abs(SoSmult))
SoS1 = SoSmult * np.sin(tim * S1f * 2 * np.pi)

ax2.set_title('SoS AM by multiplication')
ax2.plot(tim, SoS1 / max(SoS1), 'k', linewidth=1)
ax2.plot(tim, SoSmult, 'r', linewidth=2)
ax2.set_xlim([0, windowidth])

fig.tight_layout()
plt.show()

################################################
# Random Signal
RandomSignal = np.random.rand(len(S1))

RR = 100
b, a = butter(3, RR / (Fs / 2), 'low')
RandomSignal[:round(Fs * (1 / RR))] = 0.5
RandomSignal = filtfilt(b, a, RandomSignal)
RandomSignal -= min(RandomSignal)
RandomSignal /= max(RandomSignal)

RAM = RandomSignal * np.sin(tim * S1f * 2 * np.pi)

fig, (ax1, ax2) = plt.subplots(2, 1)
ax1.set_title('EOD waveform of single fish and random-multifish signal')
ax1.plot(tim, S1 / max(S1), 'b')
ax1.plot(tim, RandomSignal, 'm', linewidth=1)

ax2.set_title('Product of the two waveforms (black) and the RAM (red)')
ax2.plot(tim, RAM / max(RAM), 'k', linewidth=1)
ax2.plot(tim, RandomSignal, 'r', linewidth=2)
ax2.set_xlim([0, 0.2])

fig.tight_layout()
plt.show()

# Moving S2 fish
S2movementfreq = 0.6
S2distance = (np.sin(tim * 2 * np.pi * S2movementfreq) / 3) + 0.6
movingS2 = S2 * S2distance
comboEnv = movingS2 + np.sin(tim * S1f * 2 * np.pi)
acomboEnv = np.abs(comboEnv)

LOCS, _ = find_peaks(acomboEnv)
eLOCS, _ = find_peaks(np.abs(acomboEnv[LOCS]))

fig, (ax1, ax2, ax3) = plt.subplots(3, 1)
ax1.plot(tim, S1, 'b')
ax1.set_title('EOD of S1 fish - zoom in to see sinewave')
ax1.set_ylim([-1.2, 1.2])

ax2.plot(tim, movingS2, 'b')
ax2.set_title('EOD of S2 fish - changes amplitude in relation to distance')
ax2.set_ylim([-1.2, 1.2])

ax3.plot(tim, comboEnv, 'k')
ax3.plot(tim[LOCS], acomboEnv[LOCS], 'r.-')
ax3.plot(tim[LOCS[eLOCS]], acomboEnv[LOCS[eLOCS]], 'go-', linewidth=2, markersize=4)
ax3.set_title('Sum of S1 and S2 (black) with AM (red) and Envelope (green)')

fig.tight_layout()
plt.xlim([0, 0.5])
plt.show()

##########################################
# Contrast modulation
Env = sam * S2distance
Env /= max(Env)
simEnv = S1 * Env

fig, (ax1, ax2) = plt.subplots(2, 1)
ax1.set_title('EOD (blue) and contrast modulation (magenta). zoom in to see sinewave')
ax1.plot(tim, S1, 'b')
ax1.plot(tim, Env, 'm', linewidth=2)
ax1.set_ylim([-1.2, 1.2])

ax2.set_title('Product (black), contrast modulated SAM (red), and envelope (green)')
ax2.plot(tim, simEnv, 'k', linewidth=1)
ax2.plot(tim, Env, 'r', linewidth=2)
ax2.plot(tim, S2distance, 'g', linewidth=2)
ax2.set_xlim([0, 0.5])

fig.tight_layout()
plt.show()

