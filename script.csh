#!/bin/csh

set WHICH_FUNCTION    = $1
shift

if      ( $WHICH_FUNCTION == BUILD ) then

	if ( ${#argv} < 4 ) then
		touch /wrf/wrfoutput/FAIL_BUILD_ARGS
		exit ( 1 )
	endif

	set CLEAN             = $1
	set CONF_BUILD_NUM    = $2
	set CONF_BUILD_NEST   = $3
	set COMP_BUILD_TARGET = $4
	shift
	shift
	shift
	shift

	set CONF_OPT = " "
	while ( ${#argv} )
		set HOLD = $1
		set str = "-"
		set loc = `awk -v a="$HOLD" -v b="$str" 'BEGIN{print index(a,b)}'`
		if ( $loc == 1 ) then
			set CONF_OPT = ( $CONF_OPT " " $HOLD )
			shift
		else
			break
		endif
	end

	set str = @
	while ( ${#argv} )
		set PACKAGE = $1
		set loc = `awk -v a="$PACKAGE" -v b="$str" 'BEGIN{print index(a,b)}'`
		if ( $loc != 0 ) then
			sed -e 's/@/ /g' .orig_with_at > .new_without_at
			set PACKAGE = `cat .new_without_at`
		endif
		set ARGUMENT =  `echo $PACKAGE | cut -d"=" -f1`
		set VALUE    = "`echo $PACKAGE | cut -d"=" -f2`"
		setenv $ARGUMENT "$VALUE"
		shift
	end

	cd WRF >& /dev/null
	
	rm /wrf/wrfoutput/SUCC* >& /dev/null
	rm /wrf/wrfoutput/FAIL* >& /dev/null

	if ( $CLEAN == CLEAN ) then
		./clean >& /dev/null
	endif
	
	./configure ${CONF_OPT} << EOF >& configure.output
$CONF_BUILD_NUM
$CONF_BUILD_NEST
EOF
	
	./compile $COMP_BUILD_TARGET >& compile.log.$COMP_BUILD_TARGET.$CONF_BUILD_NUM
	
	if      ( $COMP_BUILD_TARGET ==  em_real ) then
		if ( ( -e main/wrf.exe       ) && \
		     ( -e main/real.exe      ) && \
		     ( -e main/tc.exe        ) && \
		     ( -e main/ndown.exe     ) ) then
			touch /wrf/wrfoutput/SUCCESS_BUILD_WRF_${COMP_BUILD_TARGET}_${CONF_BUILD_NUM}
		else
			touch /wrf/wrfoutput/FAIL_BUILD_WRF_${COMP_BUILD_TARGET}_${CONF_BUILD_NUM}
			exit ( 2 )
		endif
	
	else if ( $COMP_BUILD_TARGET == nmm_real ) then
		if ( ( -e main/wrf.exe       ) && \
		     ( -e main/real_nmm.exe  ) ) then
			touch /wrf/wrfoutput/SUCCESS_BUILD_WRF_${COMP_BUILD_TARGET}_${CONF_BUILD_NUM}
		else
			touch /wrf/wrfoutput/FAIL_BUILD_WRF_${COMP_BUILD_TARGET}_${CONF_BUILD_NUM}
			exit ( 2 )
		endif
	endif

else if ( $WHICH_FUNCTION == RUN   ) then

	if ( ${#argv} < 4 ) then
		touch /wrf/wrfoutput/FAIL_RUN_ARGS
		exit ( 1 )
	endif

	set COMP_BUILD_TARGET = $1
	set CONF_BUILD_NUM    = $2
	set COMP_RUN_DIR      = $3
	set COMP_RUN_TEST     = $4

	cd WRF >& /dev/null
	
	rm /wrf/wrfoutput/SUCC* >& /dev/null
	rm /wrf/wrfoutput/FAIL* >& /dev/null

	cd test/$COMP_BUILD_TARGET

	foreach f ( wrfinput_d wrfbdy_d wrfout_d wrfchemi_d wrf_chem_input_d)
		set num = `ls -1 | grep $f | wc -l | awk '{print $1}'`
		if ( $num > 0 ) then
			rm -rf ${f}*
		endif
	end
	
	ln -sf /wrf/Data/$COMP_RUN_DIR/* .
	
	if      ( (   ${COMP_BUILD_TARGET} == nmm_real      )                                          || \
	          ( ( ${COMP_BUILD_TARGET} == em_b_wave     ) && ( $COMP_RUN_DIR == em_b_wave      ) ) || \
	          ( ( ${COMP_BUILD_TARGET} == em_real       ) && ( $COMP_RUN_DIR == em_chem        ) ) || \
	          ( ( ${COMP_BUILD_TARGET} == em_real       ) && ( $COMP_RUN_DIR == em_chem_kpp    ) ) || \
	          ( ( ${COMP_BUILD_TARGET} == em_fire       ) && ( $COMP_RUN_DIR == em_fire        ) ) || \
	          ( ( ${COMP_BUILD_TARGET} == em_hill2d_x   ) && ( $COMP_RUN_DIR == em_hill2d_x    ) ) || \
	          ( ( ${COMP_BUILD_TARGET} == em_quarter_ss ) && ( $COMP_RUN_DIR == em_quarter_ss  ) ) || \
	          ( ( ${COMP_BUILD_TARGET} == em_quarter_ss ) && ( $COMP_RUN_DIR == em_quarter_ss8 ) ) ) then
		cp /wrf/Namelists/weekly/$COMP_RUN_DIR/namelist.input.${COMP_RUN_TEST} namelist.input
	else if ( ( ( ${COMP_BUILD_TARGET} == em_real       ) && ( $COMP_RUN_DIR == em_real        ) ) || \
	          ( ( ${COMP_BUILD_TARGET} == em_real       ) && ( $COMP_RUN_DIR == em_real8       ) ) ) then
		if      ( $CONF_BUILD_NUM == 32 ) then
			cp /wrf/Namelists/weekly/$COMP_RUN_DIR/SERIAL/namelist.input.${COMP_RUN_TEST} namelist.input
		else if ( $CONF_BUILD_NUM == 33 ) then
			cp /wrf/Namelists/weekly/$COMP_RUN_DIR/OPENMP/namelist.input.${COMP_RUN_TEST} namelist.input
		else if ( $CONF_BUILD_NUM == 34 ) then
			cp /wrf/Namelists/weekly/$COMP_RUN_DIR/MPI/namelist.input.${COMP_RUN_TEST} namelist.input
		endif
	else if ( ( ${COMP_BUILD_TARGET} == em_real ) && ( $COMP_RUN_DIR == em_move ) ) then
		cp /wrf/Namelists/weekly/$COMP_RUN_DIR/MPI/namelist.input.${COMP_RUN_TEST} namelist.input
	endif
	
	if      ( ${COMP_BUILD_TARGET} ==  em_real ) then
		set exec = real.exe
		set NP   = 3
	else if ( ${COMP_BUILD_TARGET} == nmm_real ) then
		set exec = real_nmm.exe
		set NP   = 3
	else
		set str = em
		set loc = `awk -v a="$COMP_BUILD_TARGET" -v b="$str" 'BEGIN{print index(a,b)}'`
		if ( $loc == 1 ) then
			set exec = ideal.exe
			set NP   = 1
		endif
	endif

	if      ( $CONF_BUILD_NUM == 32 ) then
		${exec} >& real.print.out
	else if ( $CONF_BUILD_NUM == 33 ) then
		${exec} >& real.print.out
	else if ( $CONF_BUILD_NUM == 34 ) then
		mpirun -np $NP ${exec} >& real.print.out
	endif

	if      ( (   ${COMP_BUILD_TARGET} !=  em_real ) && ( ${COMP_BUILD_TARGET} != nmm_real ) ) then
		if   ( -e wrfinput_d01 ) then
			touch /wrf/wrfoutput/SUCCESS_RUN_REAL_${COMP_BUILD_TARGET}_${CONF_BUILD_NUM}
		else
			touch /wrf/wrfoutput/FAIL_RUN_REAL_${COMP_BUILD_TARGET}_${CONF_BUILD_NUM}
			exit ( 2 )
		endif
	else if ( (   ${COMP_BUILD_TARGET} == nmm_real ) || \
	          ( ( ${COMP_BUILD_TARGET} ==  em_real ) && ( ${COMP_RUN_TEST}     != global   ) ) ) then
		if ( ( -e wrfinput_d01 ) && ( -e wrfbdy_d01 ) ) then
			touch /wrf/wrfoutput/SUCCESS_RUN_REAL_${COMP_BUILD_TARGET}_${CONF_BUILD_NUM}
		else
			touch /wrf/wrfoutput/FAIL_RUN_REAL_${COMP_BUILD_TARGET}_${CONF_BUILD_NUM}
			exit ( 2 )
		endif
	else if ( (   ${COMP_BUILD_TARGET} ==  em_real ) && ( ${COMP_RUN_TEST}     == global   ) ) then
		if   ( -e wrfinput_d01 ) then
			touch /wrf/wrfoutput/SUCCESS_RUN_REAL_${COMP_BUILD_TARGET}_${CONF_BUILD_NUM}
		else
			touch /wrf/wrfoutput/FAIL_RUN_REAL_${COMP_BUILD_TARGET}_${CONF_BUILD_NUM}
			exit ( 2 )
		endif
	endif

	if      ( $CONF_BUILD_NUM == 32 ) then
		wrf.exe >& wrf.print.out
	else if ( $CONF_BUILD_NUM == 33 ) then
		wrf.exe >& wrf.print.out
	else if ( $CONF_BUILD_NUM == 34 ) then
		mpirun -np 3 wrf.exe >& wrf.print.out
	endif

	set MAX_DOM = `grep max_dom namelist.input | cut -d"=" -f2 | cut -d"," -f1 | awk '{print $1}'`
	set d = 0
      	while ( $d < $MAX_DOM )  
		@ d ++
		@ return_code = 10 + $d

		set num = `ls -1 | grep wrfout_d0 | wc -l | awk '{print $1}'`
		if ( $num > 0 ) then

			ncdump wrfout_d0${d}_* | grep -i nan | grep -vi dominant
			set OK_nan = $status
			set nt = `ncdump -h wrfout_d0${d}_* | grep "Time = UNLIMITED" | cut -d"(" -f2 | awk '{print $1}'`
			if ( $nt == 2 ) then
				set OK_time_levels = 0
			else
				set OK_time_levels = 1
			endif
			if ( ( $OK_nan == 1 ) && ( $OK_time_levels == 0 ) ) then
				touch /wrf/wrfoutput/SUCCESS_RUN_WRF_d0${d}_${COMP_BUILD_TARGET}_${CONF_BUILD_NUM}
			else 
				touch /wrf/wrfoutput/FAIL_RUN_WRF_d0${d}_${COMP_BUILD_TARGET}_${CONF_BUILD_NUM}
				exit ( $return_code )
			endif
		else
			touch /wrf/wrfoutput/FAIL_RUN_WRF_d0${d}_${COMP_BUILD_TARGET}_${CONF_BUILD_NUM}
			exit ( $return_code )
		endif
	end
endif
