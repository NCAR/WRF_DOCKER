### WRF Docker Container Tutorial Information ###

Here are some simple instructions to try running the WRF system in a docker container.

The absolute first thing to do, you need docker installed on your laptop.

On a Mac:
```
https://docs.docker.com/docker-for-mac/install/
```

On a Windows machine (there are issues with Windows 7, basically do not even try docker with Windows 7):
```
https://docs.docker.com/docker-for-windows/install/
```

The NCAR WRF Tutorial staff cannot assist you with this installation. We are not permitted to work on any laptop from a tutorial attendee.

Once you have docker installed, make sure it is working by trying the "hello world" program.
```
docker    run    hello-world
```

If this works, you get a short "Hello from Docker!" message, something like below:
```
   Hello from Docker!
   This message shows that your installation appears to be working correctly.
```

#### Building a WRF Docker Container ####

Now that we have docker working on your machine, we use the two WRF-supplied files: Dockerfile and default-mca-params.conf. They are both text files, so feel free to peek inside to see what they are doing. The Dockerfile, the bigger file, sets up the whole environment within the container: directories, compiler versions, environment variables, lots of libraries, netcdf, MPI, WRF and WPS source code, WPS_GEOG data, grib2 data - _EVERYTHING_. The smaller file contains some information to allow openmpi to run on multiple cores.

To generate our WRF container, we use the `docker build` command, and that command automatically uses the two supplied files. Therefore, both the Dockerfile and the configuration file need to be in the current directory when you issue this `docker build` command.  And _YES_, there really is a period at the end of the following command, and it is really important! 

```
docker   build   -t   wrf_tutorial   .
```

This command takes a few minutes (on my 4 year old Mac at home it takes 4.5 minutes, at work with faster internet it takes 3 minutes). Quite a few files are downloaded, so you might want to issue this container `docker build` command when using a reasonable network. For example, NOT with lots of your best friends at the same time at a WRF Tutorial on a guest network. This command would be much better processed at your home institution where you have a fast internet connection. After that, maybe at your hotel would work, but only maybe.

#### Running a Docker Instance of the Built Image ####

Now we want to get INTO that container that we have just built. When we issue the following `docker run` command (takes a few seconds to do), note that your command line prompt changes after you issue this command:
```
docker   run   -it   --name   teachme   wrf_tutorial   /bin/tcsh
```

You are now in _CONTAINER LAND_. You are running an instance of the "wrf_tutorial" container (we just built it above). We could "run" the container externally, but we prefer that introductory students interact with the source code interactively from within the container. You have named your container instance "teachme". Your default shell is /bin/tcsh, which you could easily switch to /bin/bash from the docker command.

When you do an `ls -ls` from within the container, you see something like:
```
[wrfuser@efee06a6d22f ~]$ ls -ls
total 24
4 drwxr-sr-x  2 wrfuser wrf 4096 Nov 30 20:52 netcdf_links
4 drwxr-sr-x  7 wrfuser wrf 4096 Nov 10 00:13 WPS
4 drwsr-sr-x 31 wrfuser wrf 4096 Nov 30 20:51 WPS_GEOG
4 drwxr-sr-x 22 wrfuser wrf 4096 Nov  9 23:55 WRF
4 drwsr-sr-x  2 wrfuser wrf 4096 Nov 30 20:52 wrfinput
4 drwxr-sr-x  3 wrfuser wrf 4096 Jan 22  2014 WRF_NCL_scripts
0 drwxr-xr-x  2 wrfuser wrf   68 Nov 30 20:57 wrfoutput
```

The WPS source code (WPS directory), the WRF source code (WRF directory), the WPS geographic/static data (WPS_GEOG), and the GRIB2 data (wrfinput directory) are all here. Also, the namelists for the tutorial case that are consistent with the grib data are included in the wrfinput directory. There is quite a bit of data in this container which is why we recommend that you issue the `docker build` command in a location with a fast internet.

#### Example 1 ####

For this first example, do not be afraid. You cannot break anything, even if you really try. From within the container (in this first example), you cannot modify anything on your laptop. Even within the container things are very safe. If you remove all of the files within the container instance, you can simply exit out of the container, remove that docker container instance, re-issue that `docker run` command, and then you are back to the original pristine version of the WRF container.

For example, from within the container, we type `exit`. That pops us back out to the host OS. From there, we remove the existing (currently stopped) instance with the `docker rm` command, and then just type the `docker run` command.
```
docker    rm     teachme
docker   run  -it  --name   teachme  wrf_tutorial   /bin/tcsh
```

#### START TO BUILD AND RUN THE WRF SYSTEM ####

So far we have built our image (the `docker build` step), we have gone in and out of the container a couple of times, and even did an `ls`. Let's do some real work: we are going to build the WRF and WPS executables from source, and then we are going to use those executables to run the tutorial test case. This appears to be many steps, but we are just being very explicit. In this first example, we are considering this a test case, so even though we will build and run WRF, we won't be able to do anything with the data. That will be a second test case.


1. Make sure that you are "in" your container instance. You will know this because you have issued the `docker run` command, you are in CONTAINER LAND, and the prompt you see is now your container prompt (something like [wrfuser@efee06a6d22f ~]$  ).

2. Build the WRF code
   * cd to the WRF directory, build WRF  
     NOTE: Just to be safe, usually a good idea when starting a new build  
     NOTE: select build option "34" (GNU with DM parallelism), and choose nesting option "1" (which is just regular, non-moving nests)  
     NOTE: takes about 9 minutes on my laptop
```
    ./clean -a
    ./configure
    ./compile em_real >&! foo
```

```
    ls -ls main/*.exe
     41580 -rwxr-xr-x 1 wrfuser wrf 42574576 Nov 30 21:09 main/ndown.exe
     41436 -rwxr-xr-x 1 wrfuser wrf 42427024 Nov 30 21:09 main/real.exe
     40952 -rwxr-xr-x 1 wrfuser wrf 41931864 Nov 30 21:09 main/tc.exe
     45888 -rwxr-xr-x 1 wrfuser wrf 46988104 Nov 30 21:08 main/wrf.exe
```

2. Build the WPS, configure
   * NOTE: select build option "1" (gfortran serial)  
```
    cd ../WPS
    ./configure
```
3. Build the WPS, tweaks for the configure script
   * NOTE: edit the configure.wps, add "-lnetcdff" to the line that has "-lnetcdf", and the libraries have to be in the correct order  
   * Original line vs new line
```
                        -L$(NETCDF)/lib  -lnetcdf
```
```
                        -L$(NETCDF)/lib  -lnetcdff -lnetcdf
```
4. Build the WPS, compile step
   * NOTE: takes 15 s on my laptop  
```
    ./compile >&! foo
```
5. Build the WPS, Hey! we have executables!
```
    ls -ls *.exe
    0 lrwxrwxrwx 1 wrfuser wrf 23 Nov 30 21:12 geogrid.exe -> geogrid/src/geogrid.exe
    0 lrwxrwxrwx 1 wrfuser wrf 23 Nov 30 21:12 metgrid.exe -> metgrid/src/metgrid.exe
    0 lrwxrwxrwx 1 wrfuser wrf 21 Nov 30 21:12 ungrib.exe -> ungrib/src/ungrib.exe
```
6. Run WPS, small namelist changes
   * cd to the WPS directory (if you just built the code, you are THERE)
   * geogrid requires the namelist.wps to be modified for various size, geophysical siting, and the location of the GEOG data  
     --> hold on the the original namelist for WPS
   * `cp namelist.wps namelist.wps.original`  
      --> use the sample namelist provided inside the container  
   * `cp /wrf/wrfinput/namelist.wps.docker namelist.wps`  
7. Run WPS, GEOGRID
   * `./geogrid.exe`  
     NOTE: takes about 3 seconds
```
      ls -ls geo_em.d01.nc 
      2672 -rw-r--r-- 1 wrfuser wrf 2736012 Dec  3 19:35 geo_em.d01.nc
```
8. Run WPS, UNGRIB
   * ungrib requires the grib2 data and the correct Vtable
   * edit the `namelist.wps` file, pay attention to the `&share` and `&ungrib` namelist records - the DATES are important (for this test, that work is already handled)
   * `./link_grib.csh /wrf/wrfinput/fnl`
   * `cp ungrib/Variable_Tables/Vtable.GFS Vtable`
   * `./ungrib.exe`  
     NOTE: takes about 2 seconds
```
      ls -ls FILE*
      41272 -rw-r--r-- 1 wrfuser wrf 42261264 Nov 30 21:52 FILE:2016-03-23_00
      41272 -rw-r--r-- 1 wrfuser wrf 42261264 Nov 30 21:52 FILE:2016-03-23_06
      41272 -rw-r--r-- 1 wrfuser wrf 42261264 Nov 30 21:52 FILE:2016-03-23_12
      41272 -rw-r--r-- 1 wrfuser wrf 42261264 Nov 30 21:52 FILE:2016-03-23_18
      41272 -rw-r--r-- 1 wrfuser wrf 42261264 Nov 30 21:52 FILE:2016-03-24_00
```
9. Run WPS, METGRID
   * metgrid is usually able to run if both geogrid and ungrib mods to the namelist have been completed
   * `./metgrid.exe`  
     NOTE: takes about 2 seconds
```
      ls -ls met_em.*
      6728 -rw-r--r-- 1 wrfuser wrf 6888308 Dec  3 16:33 met_em.d01.2016-03-23_00:00:00.nc
      6728 -rw-r--r-- 1 wrfuser wrf 6888308 Dec  3 16:33 met_em.d01.2016-03-23_06:00:00.nc
      6728 -rw-r--r-- 1 wrfuser wrf 6888308 Dec  3 16:33 met_em.d01.2016-03-23_12:00:00.nc
      6728 -rw-r--r-- 1 wrfuser wrf 6888308 Dec  3 16:33 met_em.d01.2016-03-23_18:00:00.nc
      6728 -rw-r--r-- 1 wrfuser wrf 6888308 Dec  3 16:33 met_em.d01.2016-03-24_00:00:00.nc
```

10. Run Real, initial set up of files and namelist
    * cd WRF directory/test/em_real
    * link the WPS metgrid files locally
    * edit the namelist for the tutorial case
    * NOTE: you can "cheat" with `/wrf/wrfinput/namelist.input.docker` file
```
    ln -sf ../../../WPS/met_em* .
    cp namelist.input namelist.input.original  
    cp /wrf/wrfinput/namelist.input.docker namelist.input
```

11. run real, we are selecting 2 cores just to show how
    * NOTE: takes about 1 second on my laptop

```
    mpirun -np 2 ./real.exe  
```
12. run real, inspecting output
    * NOTE: look at the last line of the `rsl.out.0000` file:
```
    d01 2016-03-24_00:00:00 real_em: SUCCESS COMPLETE REAL_EM INIT
```
13. Run real, there are some expected files 
```
    ls -ls wrfinput_d01 wrfbdy_d01 
    20028 -rw-r--r-- 1 wrfuser wrf 20508248 Dec  3 16:39 wrfbdy_d01
    15868 -rw-r--r-- 1 wrfuser wrf 16247624 Dec  3 16:39 wrfinput_d01
```

14. Run WRF
    * run wrf, we are selecting 3 cores to show this can be different than what was chosen for real
    * NOTE: the ending "&" lets the job work in the background and returns control to you
    * NOTE: takes about 7 minutes on my laptop (the first time computes look up tables), approximately 4 minutes on subsequent runs from within the same instance
    * NOTE: look at the end of the `rsl.out.0000` file
```
    mpirun -np 3 ./wrf.exe &
```
```
    tail rsl.out.0000
    Timing for main: time 2016-03-23_23:39:00 on domain   1:    0.30511 elapsed seconds
    Timing for main: time 2016-03-23_23:42:00 on domain   1:    0.31809 elapsed seconds
    Timing for main: time 2016-03-23_23:45:00 on domain   1:    0.30482 elapsed seconds
    Timing for main: time 2016-03-23_23:48:00 on domain   1:    0.31682 elapsed seconds
    Timing for main: time 2016-03-23_23:51:00 on domain   1:    0.30941 elapsed seconds
    Timing for main: time 2016-03-23_23:54:00 on domain   1:    0.32885 elapsed seconds
    Timing for main: time 2016-03-23_23:57:00 on domain   1:    0.31250 elapsed seconds
    Timing for main: time 2016-03-24_00:00:00 on domain   1:    0.32680 elapsed seconds
    Timing for Writing wrfout_d01_2016-03-24_00:00:00 for domain        1:    0.68972 elapsed seconds
    d01 2016-03-24_00:00:00 wrf: SUCCESS COMPLETE WRF
```
15. Run WRF, expected files
```
    ls -ls wrfo*
    18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 19:49 wrfout_d01_2016-03-23_00:00:00
    18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 19:49 wrfout_d01_2016-03-23_03:00:00
    18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 19:50 wrfout_d01_2016-03-23_06:00:00
    18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 19:50 wrfout_d01_2016-03-23_09:00:00
    18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 19:50 wrfout_d01_2016-03-23_12:00:00
    18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 19:51 wrfout_d01_2016-03-23_15:00:00
    18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 19:52 wrfout_d01_2016-03-23_18:00:00
    18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 19:52 wrfout_d01_2016-03-23_21:00:00
    18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 19:53 wrfout_d01_2016-03-24_00:00:00
```

#### Example 2 ####

If you have been able to get the model to run and produce the model output files, then you are ready for the second part of the test case. In the first part, we knew that we would have absolutely no impact outside of the container. For the second test, we are going to re-do all of the above work (by exiting out of the container, removing it, and running the test again). However, we are going to add an option to the docker run command so that we have a shared directory between the host operating system and CONTAINER LAND.

To leave the container, simply type `exit`.  Now you are back in your hosting operating system - NOT in the container.  When you exit the first practice container (the container instance that had no external volume that was visible), make sure that you remove that instance first:

```
docker   rm    teachme
```
For our second test, this new instance will be set up to allow us to move data between the host OS and CONTAINER LAND.

We built and ran the code, but we can't look at the data from within the container (using X tools). We need to be able to "see" the container data from the outside world.  

We can "see" the container data from the outside (and also the outside from within the container) by setting up the "run" command on our instance a little differently. We have to add the `-v` option (i.e. volume, visible, etc). 

```
docker run -it --name teachme -v _some_directory_absolute_path_on_my_laptop_:/wrf/wrfoutput wrf_tutorial /bin/tcsh
```

If you want a concrete example, put in a subdirectory called `OUTPUT` on your host OS platform, then use that directory as the shared volume:
```
mkdir OUTPUT
docker run -it --name teachme -v `pwd`/OUTPUT:/wrf/wrfoutput wrf_tutorial /bin/tcsh
```

With the above `docker run` command, from within the container, anything that we place in the /wrf/wrfoutput directory is visible to the outside world (located in the explicitly defined directory on the left hand side of the ":"). Similarly, any files placed in the explicitly named local directory (the left hand side of the ":"), those files are visible within the container in the /wrf/wrfoutput directory (the directory listed on the right hand side of the ":"). Note that you can add more  "-v localpath:containerpath" entries to this `docker run` command to have even more shared volumes as visible.

If you are now starting test case 2, go to the top of these instructions and look for "START TO BUILD AND RUN THE WRF SYSTEM". If you have completed the WRF model run for test case 2, and you would like to manufacture imagery, continue on to the next step.

#### How to Manufacture Imagery ####

1. There are two methods of constructing imagery with data that is inside a container. The first method is to simply get the data that is inside the container to be visible outide the container. Once that happens, the usual post-processing methods you prefer are available.

   a. Push the WRF output files to the visible volume for easy visualization
```
    cp wrfo* /wrf/wrfoutput/
    ls -ls /wrf/wrfoutput
    total 145148
    18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 20:04 wrfout_d01_2016-03-23_00:00:00
    18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 20:04 wrfout_d01_2016-03-23_03:00:00
    18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 20:04 wrfout_d01_2016-03-23_06:00:00
    18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 20:04 wrfout_d01_2016-03-23_09:00:00
    18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 20:04 wrfout_d01_2016-03-23_12:00:00
    18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 20:04 wrfout_d01_2016-03-23_15:00:00
    18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 20:04 wrfout_d01_2016-03-23_18:00:00
    18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 20:04 wrfout_d01_2016-03-23_21:00:00
    18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 20:04 wrfout_d01_2016-03-24_00:00:00
```
   b. From outside of the container from from the native host OS (notice the different time zones and different block sizes)
```
    ls -ls OUTPUT
    total 335664
    37296 -rw-r--r--  1 gill  1500  19095444 Dec  3 13:04 wrfout_d01_2016-03-23_00:00:00
    37296 -rw-r--r--  1 gill  1500  19095444 Dec  3 13:04 wrfout_d01_2016-03-23_03:00:00
    37296 -rw-r--r--  1 gill  1500  19095444 Dec  3 13:04 wrfout_d01_2016-03-23_06:00:00
    37296 -rw-r--r--  1 gill  1500  19095444 Dec  3 13:04 wrfout_d01_2016-03-23_09:00:00
    37296 -rw-r--r--  1 gill  1500  19095444 Dec  3 13:04 wrfout_d01_2016-03-23_12:00:00
    37296 -rw-r--r--  1 gill  1500  19095444 Dec  3 13:04 wrfout_d01_2016-03-23_15:00:00
    37296 -rw-r--r--  1 gill  1500  19095444 Dec  3 13:04 wrfout_d01_2016-03-23_18:00:00
    37296 -rw-r--r--  1 gill  1500  19095444 Dec  3 13:04 wrfout_d01_2016-03-23_21:00:00
    37296 -rw-r--r--  1 gill  1500  19095444 Dec  3 13:04 wrfout_d01_2016-03-24_00:00:00
```
NOTE: These files are now eligible for any post-processing / visualization that is typically done with your WRF model output.


2. The built container includes the NCAR COmmand Language. You can run NCL scripts from within container.
  a. Get to the WRF_NCL_scripts directory (on the same level as WRF and WPS).
  b. Edit the wrf_Precip_multi_files.ncl file
    NOTE: Change the location of the WRF output files
      Original line:
```
        DATADir = "/kiaat2/bruyerec/WRF/WRFV3_4861/test/em_real/split_files/"
```
New Line:
```
        DATADir = "/wrf/WRF/test/em_real/"
```
    NOTE: Change the type of plot from x11 (screen image) to pdf (file format)
      Original Line:
```
          type = "x11"
        ; type = "pdf"
```
      New Line:
```
        ; type = "x11"
          type = "pdf"
```
    NOTE: Change the TITLE to reflect the docker test
      Original Line:
```
          res@MainTitle = "REAL-TIME WRF"
```
      New Line:
```
          res@MainTitle = "Docker Test WRF"
```
  c. Run the NCL script
```
    ncl wrf_Precip_multi_files.ncl
```
    NOTE: expected files
```
    ls -ls plt_Precip_multi_files.pdf 
    1944 -rw-r--r-- 1 wrfuser wrf 1986904 Dec  3 20:19 plt_Precip_multi_files.pdf
```
  d. To view this file, put this file in the visible volume directory shared between the original OS and container land.
```
    cp *.pdf /wrf/wrfoutput/
```

#### SOME IMPORTANT CONSIDERATIONS ####

1. Gee, I made some changes in the container (I ran a simulation or changed a file). I exited, but now I want to get back in.
```
docker    start   -ai   teachme
```


2. I'm on a windows machine, colons are a problem on the external volume (i.e., my local windows file system).

The WPS and WRF systems use the ":" character as part of the default names. If you want to make those model generated files visible to the outside file system, the colons need to be removed. There are several ways to do this. The easiest is to simply change the filenames in the container's visible directory. The WRF model has an option to remove colons from the file names, but this only works for model output.

```
&time_control
 nocolons = .true.
/
```



3. What docker container instances are available? How would I delete one?
```
docker    ps    –a
docker    rm    teachme
```



4. What docker images are available? How would I delete one?
```
docker    images    –a
docker    rmi    wrf_tutorial
```


5. What is the difference between a docker container and a docker image?

A docker image is immutable. You can almost think of it as a Linux command, such as "vi" or "ls". It is created by the `docker build` command.

A docker container is an instance of an image, it is manufactured with the `docker run` command. You can have multiple containers of the same image: one container built with optimization, one for debugging, one with lots of testing print statements, etc.



6. Weird "no space left on device" during some of the curl untar commands

The Mac disk image grows every time a new docker image is started. Could also be Docker.raw, depending on Mac formats.
```
rm ~/Library/Containers/com.docker.docker/Data/com.docker.driver.amd64-linux/Docker.qcow2
```



7. Execute commands while outside of a container

From outside of the container, start the container back up:
```
docker start teachme
```

Issue a simple command from within the container:
```
docker exec teachme ls /wrf/WRF/test/em_real | grep wrfo
wrfout_d01_2016-03-23_00:00:00
wrfout_d01_2016-03-23_03:00:00
wrfout_d01_2016-03-23_06:00:00
wrfout_d01_2016-03-23_09:00:00
wrfout_d01_2016-03-23_12:00:00
wrfout_d01_2016-03-23_15:00:00
wrfout_d01_2016-03-23_18:00:00
wrfout_d01_2016-03-23_21:00:00
wrfout_d01_2016-03-24_00:00:00
```

But let's say you want to do something more involved and complicated. Here is a short script that gets copied into the shared visible volume:
```
cat OUTPUT/test_things.csh 
```
```
#!/bin/csh

echo Files
ls -ls /wrf/WRF/test/em_real/wrfout_d01*
ls -1 /wrf/WRF/test/em_real/wrfout_d01* > /wrf/wrfoutput/list
echo
set file = `cat /wrf/wrfoutput/list | tail -1`
ncdump $file | grep -i nan | grep -v DOMINANT >& /dev/null
set OOPS = $status
if ( $OOPS == 0 ) then
	echo NaNs: found nans in $file
else
	echo NaNs: None found in $file
endif
```

Run the script from within the container
```
docker exec teachme /wrf/wrfoutput/test_things.csh
Files
18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 19:49 /wrf/WRF/test/em_real/wrfout_d01_2016-03-23_00:00:00
18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 19:49 /wrf/WRF/test/em_real/wrfout_d01_2016-03-23_03:00:00
18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 19:50 /wrf/WRF/test/em_real/wrfout_d01_2016-03-23_06:00:00
18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 19:50 /wrf/WRF/test/em_real/wrfout_d01_2016-03-23_09:00:00
18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 19:50 /wrf/WRF/test/em_real/wrfout_d01_2016-03-23_12:00:00
18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 19:51 /wrf/WRF/test/em_real/wrfout_d01_2016-03-23_15:00:00
18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 19:52 /wrf/WRF/test/em_real/wrfout_d01_2016-03-23_18:00:00
18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 19:52 /wrf/WRF/test/em_real/wrfout_d01_2016-03-23_21:00:00
18648 -rw-r--r-- 1 wrfuser wrf 19095444 Dec  3 19:53 /wrf/WRF/test/em_real/wrfout_d01_2016-03-24_00:00:00

NaNs: None found in /wrf/WRF/test/em_real/wrfout_d01_2016-03-24_00:00:00
```
