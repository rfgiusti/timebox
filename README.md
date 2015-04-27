# timebox
Time Series toolbox for MATLAB

Purpose
---

TimeBox is a procedural library that implements data structures and functions for the evaluation
of time series classification methods.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in
compliance with the License. You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

This software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
either express or implied.


Installing TimeBox
---

TimeBox has been tested on Matlab 2013 for GNU/Linux. If you are running a different version of Matlab
or a different operating system, TimeBox may not work properly without tweaks.

For installation on GNU/Linux:

1. Get the stable or the desired version of TimeBox as a .zip file;
1. Unpack in any location (i.e., ~/timebox).

This should be enough. If you are not running Matlab from TimeBox root directory, then you should
add TimeBox's root directory to your Matlab path. For example:

```Matlab
addpath ~/timebox
```

An explanation about data sets
---

TimeBox currently works only with data sets of equal-length time series. A data set is simply
a matrix of M-by-(N+1) doubles where the each row is a time series. The first column of the matrix
contains the class labels of the associated series.

TimeBox works by default with a local repository of data sets. The location of this repository is,
by default, "~/timeseries", but a different path may be specified as a single-line text file in
"~/.timebox.dspath". Each data set shold be in a Matlab data file (`.mat`) with the same name as
its directory. Each data set file should contain two variables: `train` and `test`, for the training
and test samples, respectivelly. If your data set does not have labeled data for testing, the `test`
variable should contain an empty array `[]`.

The TS package contains functions for handling data sets. In particular TS.LOAD loads a data set
from the TimeBox repository. Conversely, TS.SAVE saves a data set into the TimeBox repository.

As an example, a test data set may be found in `assets/dataset_example`. It contains two files,
`dataset_example.train` and `dataset_example.test`. To load this small data set and save it in the
TimeBox repository with the name `example`, you may proceed as follows:

```Matlab
chdir('~/timebox');                % assuming TimeBox has been installed here
train = load('assets/dataset_example.train');
test = load('assets/dataset_example.test');
ts.save(train, test, 'example');   % register into the repository
```

Once the data set has been saved into TimeBox repository, it should be referred to by its given name
(in this case, `example`) every time a function needs to access the repository.
