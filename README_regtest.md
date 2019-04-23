While some of the WRF containers were OK with a default size of 2 GB, the WRF Chem build exhibited problems (such as the registry program saying "killed"). Bumping up the container size to 8 GB works, though that could be larger than required for the small test cases in the regtest suite.

First build the WRF regression image.  This docker build step takes about 10-25 minutes, depending on network speeds. 
```
docker build -t wrf_regtest --build-arg argname=regtest .
```
You can verify that you have an image created:
```
docker images -a
```
Start up an instance of this image, and make the instance stay "up". This takes about 30 seconds.
```
docker run -d -t --name test_001 wrf_regtest
```
We can verify that we have this container running:
```
docker ps -a
```
For test 001, we are going to do an MPI build for em_real, single precision, with configure -d (currently, must be GNU). Depending on your processor, this takes about 5 minutes to build the WRF executable from source. For GNU versions 6 and 7, the "-d" option on configure causes troubles with various RRTMG codes (internal compiler error!). To speed up the build, assume that we have parallel make running with up to three processes.
```
docker exec test_001 ./script.csh BUILD CLEAN 34 1 em_real -d J=-j@3
```
Perhaps this is required to get the WRF RRTMG compiles working.
```
docker exec test_001 ./script.csh BUILD CLEAN 34 1 em_real J=-j@3
```
There are two ways to see if this was successful. We can either look at the return code:
```
set OK = $status
echo $OK
```
or we can look at the list of executables:
```
docker exec test_001 ls -ls WRF/main
```
After the executables are built, we can use this container to run a large number of tests. We test after each one to make sure things are OK:
```
foreach t ( 03 03DF 03FD 03VN 06 06VN 07 07NE 07VN 09 09QT 10 10VN 11 14 16 16DF 16VN 17 17AD 17VN 18 18VN 20 20NE 20VN 21 31 31AD 31VN 38 38VN 42 42VN 48 48VN 49 49VN 50 50VN 51 52 52DF 52FD 52VN 56 56NE 56VN 57 57NE 58 58NE 60 60NE 62 65DF 66FD 67 67NE 68 68NE 71 72 73 76 76NE 77 77NE 78 global )
	docker exec test_001 ./script.csh RUN em_real 34 em_real $t NP=3
	set OK = $status
	echo $OK for test $t
end
```
Tests that always work: toss out VN, BN, GR, things with RRTMG fast (not built usually), and use only Jan 2000 cases.
```
foreach t ( 01 01ST 02 02ST 03DF 03FD 04FD 07 07NE 08 10 11 13 14 15 15AD 16 16DF 17 17AD 18 19 20 20NE 25 26 29 29QT 30 31 31AD 32 35 38 38AD 39 39AD 43 52DF 52FD 55FD 60NE 61NE 64 64FD 65DF 66FD 69 70 71 74 75 78 )
	docker exec test_001 ./script.csh RUN em_real 34 em_real $t NP=3
	set OK = $status
	echo $OK for test $t
end

```
Because we set up the container to keep running, we need to explicitly stop it.
```
docker stop test_001
```
Without additional explanation, the following are built, run, and (importantly) stopped.

#### NMM ####
```
docker run -d -t --name test_002 wrf_regtest

docker exec test_002 ./script.csh BUILD CLEAN 34 1 nmm_real -d WRF_NMM_CORE=1 J=-j@3
set OK = $status
echo $OK

foreach t ( 01 01c 03 04a 06 07 15 )
	docker exec test_002 ./script.csh RUN nmm_real 34 nmm_nest $t NP=3
	set OK = $status
	echo $OK for test $t
end

docker stop test_002
```

#### Chem ####
```
docker run -d -t --name test_003 wrf_regtest

docker exec test_003 ./script.csh BUILD CLEAN 34 1 em_real -d WRF_CHEM=1 J=-j@3
set OK = $status
echo $OK

foreach t ( 1 2 5 )
	docker exec test_003 ./script.csh RUN em_real 34 em_chem $t NP=3
	set OK = $status
	echo $OK for test $t
end

docker stop test_003
```

#### Ideal: QSS ####
```
docker run -d -t --name test_004 wrf_regtest

docker exec test_004 ./script.csh BUILD CLEAN 34 1 em_quarter_ss -d J=-j@3
set OK = $status
echo $OK

foreach t ( 02 02NE 03 03NE 04 04NE 05 05NE 06 06NE 08 09 10 11NE 12NE 13NE 14NE )
	docker exec test_004 ./script.csh RUN em_quarter_ss 34 em_quarter_ss $t NP=3
	set OK = $status
	echo $OK for test $t
end

docker stop test_004
```

#### Ideal: B Wave ####
```
docker run -d -t --name test_005 wrf_regtest

docker exec test_005 ./script.csh BUILD CLEAN 34 1 em_b_wave -d J=-j@3
set OK = $status
echo $OK


foreach t ( 1 1NE 2 2NE 3 3NE 4 4NE 5 5NE )
	docker exec test_005 ./script.csh RUN em_b_wave 34 em_b_wave $t NP=3
	set OK = $status
	echo $OK for test $t
end

docker stop test_005
```

#### EM Real*8 ####
```
docker run -d -t --name test_006 wrf_regtest

docker exec test_006 ./script.csh BUILD CLEAN 34 1 em_real -d -r8 J=-j@3
set OK = $status
echo $OK


foreach t ( 14 16 17 17AD 18 31 31AD 38 74 75 76 77 78 )
	docker exec test_006 ./script.csh RUN em_real 34 em_real8 $t NP=3
	set OK = $status
	echo $OK for test $t
end

docker stop test_006
```

#### EM QSS*8 ####
```
docker run -d -t --name test_007 wrf_regtest

docker exec test_007 ./script.csh BUILD CLEAN 34 1 em_quarter_ss -d -r8 J=-j@3
set OK = $status
echo $OK


foreach t ( 02 03 04 05 06 08 09 10 )
	docker exec test_007 ./script.csh RUN em_quarter_ss 34 em_quarter_ss8 $t NP=3
	set OK = $status
	echo $OK for test $t
end

docker stop test_007
```

#### Moving Nest ####
```
docker run -d -t --name test_008 wrf_regtest

docker exec test_008 ./script.csh BUILD CLEAN 34 3 em_real -d J=-j@3
set OK = $status
echo $OK


foreach t ( 01 02 )
	docker exec test_008 ./script.csh RUN em_real 34 em_move $t NP=3
	set OK = $status
	echo $OK for test $t
end

docker stop test_008
```

#### WRF Fire ####
```
docker run -d -t --name test_009 wrf_regtest

docker exec test_009 ./script.csh BUILD CLEAN 34 1 em_fire -d J=-j@3
set OK = $status
echo $OK


foreach t ( 01 )
	docker exec test_009 ./script.csh RUN em_fire 34 em_fire $t NP=3
	set OK = $status
	echo $OK for test $t
end

docker stop test_009
```

#### Ideal: Hill 2d-x ####
```
docker run -d -t --name test_010 wrf_regtest

docker exec test_010 ./script.csh BUILD CLEAN 32 0 em_hill2d_x -d J=-j@3
set OK = $status
echo $OK


foreach t ( 01 )
	docker exec test_010 ./script.csh RUN em_hill2d_x 32 em_hill2d_x $t
	set OK = $status
	echo $OK for test $t
end

docker stop test_010
```
