First build the WRF regression image.  This docker build step takes about 10-25 minutes, depending on network speeds. To get started, copy the regtest docker file to the correct name.
```
cp Dockerfile_regtest Dockerfile
docker build -t wrf_regtest .
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
Make the script we are going to run an executable:
```
docker exec test_001 chmod 744 script.csh
```
For test 001, we are going to do an MPI build for em_real, single precision, with configure -d (currently, must be GNU). Depending on your processor, this takes about 5 minutes to build the WRF executable from source.
```
docker exec test_001 ./script.csh BUILD CLEAN 34 1 em_real -d
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
	docker exec test_001 ./script.csh RUN em_real 34 em_real $t
	set OK = $status
	echo $OK for test $t
end
```
Because we set up the container to keep running, we need to explicitly stop it.
```
docker stop test_001
```
