### The Proper Care and Feeding of the Regtest script.csh File ###

The entire suite of regression tests for the WRF modeling system may be run within this Docker container system. The regression tests are conducted with a single type of WRF model build (for example, em_real, single precision, MPI, debugging level) that is matched to an associated list of available namelist files. A script inside of the WRF regtest container is able to handle one of two possible requests: build the executables, or run a test. External to the container, some (not included here) script loops over all of the possible build types, and for each of those build types then loops over the possible namelist-selected tests.

The script is case sensitive and order sensitive.  The script understands the keywords `BUILD` and `RUN`, and one of those words must be the first argument in the command line. After the first keyword must come the expected mandatory pieces of information (depending on whether this is a `BUILD` or a `RUN` type job). Following the mandatory entries come the optional settings.


#### BUILD ####

```
./script.csh BUILD clean_opt conf_num nest_opt build_opt <conf_opt1 <conf_opt2>> <env_var1=val1 <env_var2=val2>>
```

##### MANDATORY ##### 

When the initial keyword is `BUILD`, the script expects four mandatory entries: `clean_opt`, `conf_num`, `nest_opt`, and `build_opt`.

`clean_opt`: If this valis is `CLEAN`, then the clean script is run. Any other string is interpreted as "do not run the clean script".

`conf_num` : When issuing the `./configure` commmand inside the WRF system, this is the numerical entry that is selected by the user, for example `32` means serial build for GNU. For this container, only 32, 33, or 34 are permissible.

`nest_opt` : When issuing the `./configure` commmand inside the WRF system, this is the type of nest that is selected. Most of the time, the value `1` is sufficient. A moving nest case requires `3`, while an idealized 2d case requires a no-nest build `0`.

`build_opt`: When issuing the `./compile` command, the `build_opt` is the target, such as `em_real`, or `em_b_wave`, or `nmm_real`.

##### OPTIONAL ##### 

The `conf_opt` values are the options that are fed to the `./configure` script. Examples include `-d`, `-D`, `-r8`. All of these options MUST begin with a dash character `-`.

The `env_var=val` options are environment variables that are required to be set prior to the build of the WRF system. These are typically used in concert with the `build_opt` setting. For example `em_real` would build a traditional WRF model, but `em_real` and the environment variable `WRF_CHEM=1` would build a WRF Chem model. Another example: `nmm_real` requires `WRF_NMM_CORE=1`. No spaces or quotes are permitted in the environment settings. Use the at, @, symbol to denote a space. For example, to tell the Makefile to build with up to three parallel build processes, `J=-j@1`. All of these environment settings must include an equal sign `=`.


#### RUN ####
```
./script.csh RUN build_opt conf_num data_dir test_num <env_var1=val1 <env_var2=val2>>
```

##### MANDATORY ##### 

When the initial keyword is `RUN`, the script expects four mandatory entries: `build_opt`, `conf_num`, `data_dir`, and `test_num`.

Two of these options are required to be sync'ed with the `BUILD` call: `build_opt` and `conf_num`. If we build with `em_real`, then we need to run with `em_real`. Similarly, if we build with for MPI, we need to run with MPI.

The other two mandatory command line arguments deal with the specifics of the regression testing system: what is the subdirectory where the data is located for this specific model set up, and what specific test number is to be conducted.

`data_dir`: This information is used when assigning both the namelist and the gridded first-guess data. The available values for `data_dir` can be selected from among the subdirectories of [Namelists/weekly](Namelists/weekly).

`test_num` : Associated with the `data_dir` is which of the available test are to be conducted. For `em_real8`, the available options would be found in [Namelists/weekly/em_real8/MPI](Namelists/weekly/em_real8/MPI). For example, the file namelist.input.07 would be identified in the script call as `07`. This is a character string, so if the leading "0" is present in the filename, it must be part of the `test_num` string.

##### OPTIONAL ##### 

The `env_var=val` options are environment variables that are required to be set prior to the run of the WRF system. The only example of this is setting the number of threads before an OpenMP run: `OMP_NUM_THREADS=3`.


#### What Settings are We Allowed to Set ####

| `data_dir`      | `build_opt`     | `conf_num` |  `test_num` |
| --------------  | --------------- |:----------:|:------- |
| em_b_wave       | em_b_wave       | 32, 33, 34 | 1 1NE 2 2NE 3 3NE 4 4NE 5 5NE |
| em_chem         | em_real         | 32, 34     | 1 2 5 |
| em_fire         | em_fire         | 32, 33, 34 | 01        |
| em_hill2d_x     | em_hill2d_x     | 32         | 01        |
| em_move         | em_real         |         34 | 01 02                  |
| em_quarter_ss   | em_quarter_ss   | 32, 33, 34 | 02 02NE 03 03NE 04 04NE 05 05NE 06 06NE 08 09 10 11NE 12NE 13NE 14NE |
| em_quarter_ss8  | em_quarter_ss   | 32, 33, 34 | 02 03 04 05 06 08 09 10 |
| em_real         | em_real         | 32, 33, 34 | 01 01ST 02 02GR 02ST 03 03DF 03FD 03ST 03VN 04FD 05 05AD 05ST 06 06BN 06VN 07 07NE 07VN 08 09 09QT 10 10VN 11 12 12GR 13 14 14VN 15 15AD 16 16BN 16DF 16VN 17 17AD 17VN 18 18BN 18VN 19 20 20NE 20VN 21 25 26 29 29QT 30 31 31AD 31VN 32 33 34 35 37 38 38AD 38VN 39 39AD 40 41 42 42VN 43 48 48VN 49 49VN 50 50VN 51 52 52DF 52FD 52VN 54 55FD 56 56NE 56VN 57 57NE 58 58NE 60 60NE 61 61NE 62 63 64 64FD 64VN 65DF 66FD 67 67NE 68 68NE 69 70 71 72 73 74 75 76 76NE 77 77NE 78 global |
| em_real8        | em_real         | 32, 33, 34 | 07 14 16 17 17AD 18 31 31AD 38 74 75 76 77 78 |
| nmm_nest        | nmm_real        | 32,     34 | 02 08 09 12 13 14 |

