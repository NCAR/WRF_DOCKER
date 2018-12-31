### The Proper Care and Feeding of the Regtest script.csh File ###

The entire suite of regression tests for the WRF modeling system may be run within this Docker container system. The regression tests are conducted with a single type of WRF model build (for example, em_real, single precision, MPI, debugging level) that is matched to an associated list of available namelist files. A script inside of the WRF regtest container is able to handle one of two possible requests: build the executables, or run a test. External to the container, some (not included here) script loops over all of the possible build types, and for each of those build types then loops over the possible namelist-selected tests.

The script is case sensitive and order sensitive.  The script understands the keywords `BUILD` and `RUN`, and one of those words must be the first argument in the command line. After the first keyword must come the expected mandatory pieces of information (depending on whether this is a `BUILD` or a `RUN` type job). Following the mandatory entries come the optional settings.


#### BUILD ####

```
./script.csh BUILD clean_opt conf_num nest_opt build_opt <conf_opt1 <conf_opt2>> <env_var1=val1 <env_var2=val2>>
```

##### MANDATORY ##### 

When the initial keyword is `BUILD`, the script expects three mandatory entries: `clean_opt`, `conf_num`, `nest_opt`, and `build_opt`.

`clean_opt`: If this valis is `CLEAN`, then the clean script is run. Any other string is interpreted as "do not run the clean script".

`conf_num` : When issuing the `./configure` commmand inside the WRF system, this is the numerical entry that is selected by the user, for example `32` means serial build for GNU. For this container, only 32, 33, or 34 are permissible.

`nest_opt` : When issuing the `./configure` commmand inside the WRF system, this is the type of nest that is selected. Most of the time, the value `1` is sufficient. A moving nest case requires `3`, while an idealized 2d case requires a no-nest build `0`.

`build_opt`: When issuing the `./compile` command, the `build_opt` is the target, such as `em_real`, or `em_b_wave`, or `nmm_real`.

##### OPTIONAL ##### 

The `conf_opt` values are the options that are fed to the `./configure` script. Examples include `-d`, `-D`, `-r8`. All of these options MUST begin with a dash character `-`.

The `env_var=val` options are environment variables that are required to be set prior to the build of the WRF system. These are typically used in concert with the `build_opt` setting. For example `em_real` would build a traditional WRF model, but `em_real` and the environment variable `WRF_CHEM=1` would build a WRF Chem model. Another example: `nmm_real` requires `WRF_NMM_CORE=1`. No spaces or quotes are permitted in the environment settings. Use the at, @, symbol to denote a space. For example, to tell the Makefile to build with up to three parallel build processes, `J=-j@1`. All of these environment settings must include an equal sign `=`.


#### RUN ####

