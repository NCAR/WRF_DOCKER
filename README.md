### Docker Container for WRF ###

John Exby and Kate Fossell provided a method to encapsulate the WRF modeling system with a container. 

From there work, we have modified the Dockerfiles to work with new code, and a couple of separate use cases. The Dockerfiles include
   * Source code for WRF and WPS, from github
   * External libraries required to build WRF and WPS
   * Construct enough of an OS to have traditional user-level Linux capabilities
   * Ability to use the GNU compiler for compilation
   * OpenMPI is used for distributed memory processing
   * Post-processing is available, via PDF fields, from NCL
   * The static data for geogrid is available (low resolution only)
   * Two Dockerfiles to allow a tutorial walk-through, or regression testing
   * The tutorial case has namelists and Grib data to run end-to-end
   * The regression case has metgrid output and all of the NML files from the regression suite

There is a README for each of the two Dockerfiles: tutorial and regtest. Make sure that you copy the correct Dockerfile. Either:
```
ln -sf Dockerfile_tutorial Dockerfile
```
or 
```
ln -sf Dockerfile_regtest Dockerfile
```

#### Tutorial ####

The tutorial README has step-by-step instructions to run the entire WRF system, from geogrid through generating PDF files with model output. We go "into" the container for the tutorial case.

```
docker   build   -t   wrf_tutorial  .
mkdir OUTPUT
docker   run   -it   --name   teachme   -v   `pwd`/OUTPUT:/wrf/wrfoutput   wrf_tutorial   /bin/tcsh
```

#### Regtest ####

The purpose of the regression test is to allow a specifically built container to conduct a number of tests. We stay outside of the container for the regression test case.

```
docker   build   -t   wrf_regtest  .
docker   run   -d -t   --name   test_001   wrf_regtest   /bin/tcsh
docker   exec  test_001   chmod +x script.csh
docker   exec  test_001   ./script.csh   BUILD   CLEAN   34   1   em_real -d
docker   exec  test_001   ./script.csh   RUN   em_real   34   em_real 03
```

