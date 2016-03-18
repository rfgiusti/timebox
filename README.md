# timebox - Time Series toolbox for Matlab

TimeBox is a procedural library that implements data structures and functions for the evaluation
of time series classification methods.

Except for third-party material included in this software, TimeBox is licensed under the Apache License,
Version 2.0 (the "License"); you may not use TimeBox except in compliance with the License. You may
obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

This software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
either express or implied.

Third-party material is included in this software in respect to their license terms, which are
transcribed in THIRD-PARTY.txt. Please see those license terms before using this software.

**Table of Contents**:

1. [Installing TimeBox](#installing-timebox)
1. [A word about data sets](#a-word-about-data-sets)
1. [A simple example](#a-simple-example)



## Installing TimeBox

TimeBox has been tested on Matlab 2010b for GNU/Linux. If you are running a different version of Matlab
or a different operating system, TimeBox may not work properly without tweaks. Particularly, TimeBox
has not been tested on any version of Microsoft Windows.

To get TimeBox:

1. Get the latest stable release <a href="https://github.com/rfgiusti/timebox/releases/latest">here</a>; or
1. Get the latest code as soon as it's developed <a href="https://github.com/rfgiusti/timebox/archive/master.zip">here</a>; or
1. Download an old version of TimeBox from the <a href="https://github.com/rfgiusti/timebox/releases">releases section</a>.
   If you got here while trying to reproduce some paper results, this is probably what you want.

To run TimeBox on GNU/Linux:

1. Simply unzip the downloaded file into the desired location (*e.g.*, `~/timebox`);
1. Run Matlab;
1. Either `chdir` to the TimeBox root directory or add TimeBox to your Matlab search path. For instance: 

```Matlab
addpath ~/timebox
```

You can check the TimeBox version you are currently running by typing

```Matlab
tb.version
```

A few features require that some MEX files be compiled. This include the UCR Suite-based implementation of
the Dynamic Time Warping in `timebox/+dists/DTW_mex.cpp`, the fast 1-NN classification model in 
`timebox/+models/nn1_mex.c`, and the Atiya-based ensemble stragegy in `timebox/+runs/+dme/+aux/atiya_Mex.c`.
Currently, those must be manually compiled, but this should change in the future. To compile a MEX file,
a C and/or C++ compiler is required, and the procedure goes somewhat like this;

```Matlab
cd ~/timebox/+dists    % assuming TimeBox was installed into HOME 
mex DTW_mex.cpp
```

On Linux, warnings about GCC version are probably harmless. If the compilation is successful, a file
containing `.mex` as part of its extension will be generated. This file is system-dependent and should not
be included in the repository.



## A word about data sets

TimeBox currently works only with data sets of equal-length time series. A data set is simply
a matrix of M-by-(N+1) doubles where each row is one time series. The first column of the matrix
contains the class labels of the eries. This is the same format adopted in the
[UCR Time Series Repository](http://www.cs.ucr.edu/~eamonn/time_series_data/), so importing that
kind of data to TimeBox is quite easy.

Class labels must be numeric. If the original data set uses symbolic classes, then they must be
mapped before the data set can be used with TimeBox. TimeBox *might* be used for
semisupervised/unsupervised learning, but most of its sweet is intended for supervised
classification.
 
TimeBox works by default with a local repository of data sets. Some features require data sets to
be imported into the local repository. Any function that takes a data set name instead of the data
itself requires the data set to have been previously cached into the local repository.

The location of this repository is, by default, `~/timeseries`, but a different path may be
specified as a single-line text file in `~/.timebox.dspath`. For instance:

    /home/myusername/resarch/timeseries/datasets/timebox

Currently, this path must be specified in absoute form (no `~` expansion). This may change in the
future.

In the local repository, each data set shold be in a Matlab data file (`.mat`) with the same name as
its directory. Each data set file should contain two variables: `train` and `test`, for the
training and test samples, respectivelly. If your data set does not have labeled data for testing,
the `test` variable should contain an empty array `[]`. Some features of TimeBox require labeled
data.

The `TS` package contains functions for handling data sets. In particular `TS.LOAD` loads a data set
from the TimeBox repository (and *only* from the TimeBox repository). Conversely, `TS.SAVE` saves a
data set into the TimeBox repository.

As an example, a test data set may be found in `assets/dataset_example`. It contains two files,
`dataset_example.train` and `dataset_example.test`. To load this small data set and save it in the
TimeBox repository with the name `example`, you may proceed as follows:

```Matlab
chdir('~/timebox');                % assuming TimeBox has been installed here
train = load('assets/dataset_example.train');
test = load('assets/dataset_example.test');
ts.save(train, test, 'example');   % register into the repository
```

Once the data set has been saved into the TimeBox repository, it should be referred to by its given
name (in this case, `example`) every time a function needs to access the repository. For instance,
the `TS.LOAD` function may be from now on used to load the previously data set `example` as follows:

```Matlab
chdir('~/timebox');                % assuming TimeBox has been installed here
[train, test] = ts.load('example');
```

Because the local repository is kept as binary Matlab files, loading the data sets this way is faster
than parsing CSV files. Moreover, TimeBox is able to keep cache of transformed data sets, distance
matrices, and, as it is being developed, other kind of data. It also keeps track of meta-data that
may be useful in experiments.

If you do not wish to use the local repository, TimeBox still has lots of functionalities that work
without cached data.



## A simple example

The RUNS package contains functions to classify data sets. The function `RUNS.PARTITIONED` performs
a classification round on a partitioned data set (split into train/test data) and returns the
observed accuracy. The default classification model is the 1-NN classifier.

Here's how to make a single run on the previously cached data set `example`:

```Matlab
chdir('~/timebox');                % assuming TimeBox has been installed here
[train, test] = ts.load('example');
runs.partitioned(train, test)
```

The return value will be the observed accuracy for the 1-NN on the `example` data set.

There are several ways to change the classification model:

- Using a different classification model (since TimeBox v0.11, the default is `MODELS.NN1EUCLIDEAN`);
- Using a different distance function (default is Euclidean distance);
- Using a different time series representation (data sets can be converted from the time domain
  to other representations with `TRANSFORM.*` functions -- *e.g.*, `TRANSFORM.PS`);

TimeBox is under effort to be kept internally documented. Please check the internal documentation
by typing `help FUNCTION-NAME` in the Matlab shell (*e.g.*, `help runs.leaveoneout`).
