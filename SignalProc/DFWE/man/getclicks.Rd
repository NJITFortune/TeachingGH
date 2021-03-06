% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getclicks.R
\name{getclicks}
\alias{getclicks}
\title{getclicks}
\usage{
getclicks(zfinch_data)
}
\arguments{
\item{wav_file}{A .wav file of vector/list of frequency data}

\item{Fs}{The sampling rate. Does not need to be provided if it is included in the .wav}

\item{frame_shift}{User defined display window size for collecting clicks. Will default to
2 seconds. Input in seconds.}

\item{data_frame}{Choose to whether or not to export data as a dataframe. Dataframe will include NA's}
}
\value{
A nested list of x-positions(time in seconds)
}
\description{
This function gets the location of user-input clicks on the plotting window in order to extract
extract data from song spectrograms. You can input one or more series of clicks.
The program is interactive and requires user input. Will cyle through spectrogram in user defined
increments.
}
\examples{
getclicks(zfinch_data, frame_shift = 1)

}
