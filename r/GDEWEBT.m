;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GDEWEBT	; Run unit tests for GDEWEB/GDE Web services
	i $t(^%ut)="" w "Unable to find unit test framework!",! QUIT
	d EN^%ut($t(+0),3)
	QUIT
get	;; @TEST get web service
	n ARGS,RESULT,HTTPERR,JSON,ERR
	;
	; Valid data is returned
	k ARGS,RESULT,HTTPERR,JSON,^TMP("HTTPERR",$J)
	d get^GDEWEB(.RESULT,.ARGS)
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(10,$d(RESULT),"Unexpected result")
	d ASSERT("",$g(HTTPERR),"Error returned when there shouldn't be one")
	d ASSERT(0,$d(^TMP("HTTPERR",$J,1,"error","code")),"Error code not set")
	d ASSERT("%",$g(JSON("map",1,"from")),"Missing % map")
	d ASSERT("...",$g(JSON("map",13,"to")),"Missing ... map")
	QUIT
	;
verify	;; @TEST Verify web service
	n ARGS,BODY,ERR,RESULT,HTTPERR,JSON
	;
	; null BODY
	k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J)
	s BODY=""
	s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT("",$g(RESULT),"Incorrect Response from Null Body")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(400,$g(HTTPERR),"Incorrect Response from Null Body")
	d ASSERT(400,$g(^TMP("HTTPERR",$J,1,"error","code")),"Error code not set from Null Body")
	d ASSERT(301,$g(^TMP("HTTPERR",$J,1,"error","errors",1,"reason")),"Reason code not set from Null Body")
	d ASSERT(0,$d(^TMP("HTTPERR",$J,1,"error","errors",2,"reason")),"Too many errors set from Null Body")
	;
	; Invalid JSON
	; k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J)
	; s BODY="{TEST: HI""}"
	; s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	; d ASSERT("",$g(RESULT),"Incorrect Response from Null Body")
	; d ASSERT(400,$g(HTTPERR),"Incorrect Response from Invalid JSON")
	; d ASSERT(400,$g(^TMP("HTTPERR",$J,1,"error","code")),"Error code not set from Invalid JSON")
	; d ASSERT(202,$g(^TMP("HTTPERR",$J,1,"error","errors",1,"reason")),"Reason code not set from Invalid JSON")
	; d ASSERT(0,$d(^TMP("HTTPERR",$J,1,"error","errors",2,"reason")),"Too many errors set from Invalid JSON")
	;
	; Name with empty string for a region
	k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY(1)="{""names"":{""ZZTEST"":""""}}"
	s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Name with an empty string for a region")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Name with an empty string for a region response")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from Name with an empty string for a region")
	d ASSERT("%GDE-E-QUALREQD, Region required",$g(JSON("errors",1)),"Expected error doesn't exist from Name with an empty string for a region")
	d ASSERT("false",$g(JSON("verifyStatus")),"Invalid verifyStatus from Name with an empty string for a region")
	;
	; Name with region (Valid)
	k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""names"":{""ZZTEST"":""TEMP""}}"
	s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Valid Name")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Valid Name response")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from Valid Name")
	d ASSERT(0,$d(JSON("errors")),"Receved an unexpected error from Valid Name")
	d ASSERT("true",$g(JSON("verifyStatus")),"Invalid verifyStatus from Valid Name")
	;
	; Region with missing required attribute
	k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""regions"":{""YOTTADB"":{""test"":""""}}}"
	s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from region missing required attribute")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from region missing required attribute")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from region missing required attribute")
	d ASSERT("%GDE-E-QUALREQD, Dynamic_segment required",$g(JSON("errors",1)),"Receved an unexpected error from region missing required attribute")
	d ASSERT(0,$d(JSON("errors",2)),"Receved too many errors from region missing required attribute")
	d ASSERT("false",$g(JSON("verifyStatus")),"Invalid verifyStatus from region missing required attribute")
	;
	; Region with required attribute, no segment
	k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""regions"":{""YOTTADB"":{""DYNAMIC_SEGMENT"":""YOTTADB""}}}"
	s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from region with required attribute - no segment")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from region with required attribute - no segment")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from region with required attribute - no segment")
	d ASSERT("%GDE-I-MAPBAD, Dynamic segment YOTTADB for Region YOTTADB does not exist",$g(JSON("errors",1)),"Receved an unexpected error from region with required attribute - no segment")
	d ASSERT("%GDE-I-MAPBAD, A NAME for REGION YOTTADB does not exist",$g(JSON("errors",2)),"Receved an unexpected error from region with required attribute - no segment")
	d ASSERT(0,$d(JSON("errors",3)),"Receved too many errors from region with required attribute - no segment")
	d ASSERT("false",$g(JSON("verifyStatus")),"Invalid verifyStatus from region with required attribute - no segment")
	;
	; Segment with missing required attribute
	k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""segments"":{""YOTTADB"":{""test"":""""}}}"
	s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from segment missing required attribute")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from segment missing required attribute")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from segment missing required attribute")
	d ASSERT("%GDE-E-QUALREQD, File required",$g(JSON("errors",1)),"Receved an unexpected error from segment missing required attribute")
	d ASSERT(0,$d(JSON("errors",2)),"Receved too many errors from segment missing required attribute")
	d ASSERT("false",$g(JSON("verifyStatus")),"Invalid verifyStatus from segment missing required attribute")
	;
	; Segment with 1 required attribute, no region, no access method
	k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""segments"":{""YOTTADB"":{""FILE_NAME"":""/tmp/yottadb.dat""}}}"
	s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from segment with required attribute - no region, no access method")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from segment with required attribute - no region, no access method")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from segment with required attribute - no region, no access method")
	d ASSERT("%GDE-E-QUALREQD, Access method required",$g(JSON("errors",1)),"Receved an unexpected error from segment with required attribute - no region, no access method")
	d ASSERT(0,$d(JSON("errors",2)),"Receved too many errors from segment with required attribute - no region, no access method")
	d ASSERT("false",$g(JSON("verifyStatus")),"Invalid verifyStatus from segment with required attribute - no region, no access method")
	;
	; Segment with 2 required attribute, no region
	k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""segments"":{""YOTTADB"":{""FILE_NAME"":""/tmp/yottadb.dat"",""ACCESS_METHOD"":""BG""}}}"
	s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from segment with required attribute - no region")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from segment with required attribute - no region")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from segment with required attribute - no region")
	d ASSERT("%GDE-I-MAPBAD, A REGION for SEGMENT YOTTADB does not exist",$g(JSON("errors",1)),"Receved an unexpected error from segment with required attribute - no region")
	d ASSERT(0,$d(JSON("errors",2)),"Receved too many errors from segment with required attribute - no region")
	d ASSERT("false",$g(JSON("verifyStatus")),"Invalid verifyStatus from segment with required attribute - no region")
	;
	; Valid Name, Invalid Segment
	k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""names"":{""ZZTEST"":""TEMP""},""segments"":{""-YOTTADB"":{""FILE_NAME"":""/tmp/yottadb.dat"",""ACCESS_METHOD"":""BG""}}}"
	s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Valid Name, Invalid Segment")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Valid Name, Invalid Segment")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from Valid Name, Invalid Segment")
	d ASSERT("%GDE-E-PREFIXBAD, -YOTTADB - segment name must start with an alphabetic character",$g(JSON("errors",1)),"Receved an unexpected error from Valid Name, Invalid Segment")
	d ASSERT(0,$d(JSON("errors",2)),"Receved too many errors from Valid Name, Invalid Segment")
	d ASSERT("false",$g(JSON("verifyStatus")),"Invalid verifyStatus from Valid Name, Invalid Segment")
	;
	; Invalid Name, Valid Segment
	k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""names"":{""-ZZTEST"":""TEMP""},""segments"":{""YOTTADB"":{""FILE_NAME"":""/tmp/yottadb.dat"",""ACCESS_METHOD"":""BG""}}}"
	s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Invalid Name, Valid Segment")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Invalid Name, Valid Segment")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from Invalid Name, Valid Segment")
	d ASSERT("%GDE-E-VALUEBAD, -ZZTEST is not a valid name",$g(JSON("errors",1)),"Receved an unexpected error from Invalid Name, Valid Segment")
	d ASSERT(0,$d(JSON("errors",2)),"Receved too many errors from Valid Name, Invalid Segment")
	d ASSERT("false",$g(JSON("verifyStatus")),"Invalid verifyStatus from Invalid Name, Valid Segment")
	;
	; Invalid Name, Invalid Segment
	k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""names"":{""-ZZTEST"":""TEMP""},""segments"":{""-YOTTADB"":{""FILE_NAME"":""/tmp/yottadb.dat"",""ACCESS_METHOD"":""BG""}}}"
	s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Invalid Name, Invalid Segment")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Invalid Name, Invalid Segment")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from Invalid Name, Invalid Segment")
	d ASSERT("%GDE-E-VALUEBAD, -ZZTEST is not a valid name",$g(JSON("errors",1)),"Receved an unexpected error from Invalid Name, Invalid Segment")
	d ASSERT("%GDE-E-PREFIXBAD, -YOTTADB - segment name must start with an alphabetic character",$g(JSON("errors",2)),"Receved an unexpected error from Invalid Name, Invalid Segment")
	d ASSERT(0,$d(JSON("errors",3)),"Receved too many errors from Invalid Name, Invalid Segment")
	d ASSERT("false",$g(JSON("verifyStatus")),"Invalid verifyStatus from Invalid Name, Invalid Segment")
	;
	; Valid Name, Valid Segment
	k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""names"":{""ZZTEST"":""YOTTADB""},""segments"":{""YOTTADB"":{""FILE_NAME"":""/tmp/yottadb.dat"",""ACCESS_METHOD"":""BG""}}}"
	s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Valid Name, Valid Segment")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Valid Name, Valid Segment")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from Valid Name, Valid Segment")
	d ASSERT("%GDE-I-MAPBAD, Region YOTTADB for Name ZZTEST does not exist",$g(JSON("errors",1)),"Receved an unexpected error from Valid Name, Valid Segment")
	d ASSERT("%GDE-I-MAPBAD, A REGION for SEGMENT YOTTADB does not exist",$g(JSON("errors",2)),"Receved an unexpected error from Valid Name, Valid Segment")
	d ASSERT(0,$d(JSON("errors",3)),"Receved too many errors from Valid Name, Valid Segment")
	d ASSERT("false",$g(JSON("verifyStatus")),"Invalid verifyStatus from Valid Name, Valid Segment")
	;
	; Invalid Name, Valid Segment, Valid Region
	k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""names"":{""-ZZTEST"":""YOTTADB""},""regions"":{""YOTTADB"":{""DYNAMIC_SEGMENT"":""YOTTADB""}},""segments"":{""YOTTADB"":{""FILE_NAME"":""/tmp/yottadb.dat"",""ACCESS_METHOD"":""BG""}}}"
	s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Invalid Name, Valid Segment, Valid Region")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Invalid Name, Valid Segment, Valid Region")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from Invalid Name, Valid Segment, Valid Region")
	d ASSERT("%GDE-E-VALUEBAD, -ZZTEST is not a valid name",$g(JSON("errors",1)),"Receved an unexpected error from Invalid Name, Valid Segment, Valid Region")
	d ASSERT(0,$d(JSON("errors",2)),"Receved too many errors from Invalid Name, Valid Segment, Valid Region")
	d ASSERT("false",$g(JSON("verifyStatus")),"Invalid verifyStatus from Invalid Name, Valid Segment, Valid Region")
	;
	; Valid Name, Invalid Segment, Valid Region
	k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""names"":{""ZZTEST"":""YOTTADB""},""regions"":{""YOTTADB"":{""DYNAMIC_SEGMENT"":""YOTTADB""}},""segments"":{""-YOTTADB"":{""FILE_NAME"":""/tmp/yottadb.dat"",""ACCESS_METHOD"":""BG""}}}"
	s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Valid Name, Invalid Segment, Valid Region")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Valid Name, Invalid Segment, Valid Region")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from Valid Name, Invalid Segment, Valid Region")
	d ASSERT("%GDE-E-PREFIXBAD, -YOTTADB - segment name must start with an alphabetic character",$g(JSON("errors",1)),"Receved an unexpected error from Valid Name, Invalid Segment, Valid Region")
	d ASSERT(0,$d(JSON("errors",2)),"Receved too many errors from Valid Name, Invalid Segment, Valid Region")
	d ASSERT("false",$g(JSON("verifyStatus")),"Invalid verifyStatus from Valid Name, Invalid Segment, Valid Region")
	;
	; Valid Name, Invalid Segment, Invalid Region
	k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""names"":{""ZZTEST"":""YOTTADB""},""regions"":{""-YOTTADB"":{""DYNAMIC_SEGMENT"":""YOTTADB""}},""segments"":{""-YOTTADB"":{""FILE_NAME"":""/tmp/yottadb.dat"",""ACCESS_METHOD"":""BG""}}}"
	s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Valid Name, Invalid Segment, Invalid Region")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Valid Name, Invalid Segment, Invalid Region")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from Valid Name, Invalid Segment, Invalid Region")
	d ASSERT("%GDE-E-PREFIXBAD, -YOTTADB - region name must start with an alphabetic character",$g(JSON("errors",1)),"Receved an unexpected error from Valid Name, Invalid Segment, Invalid Region")
	d ASSERT("%GDE-E-PREFIXBAD, -YOTTADB - segment name must start with an alphabetic character",$g(JSON("errors",2)),"Receved an unexpected error from Valid Name, Invalid Segment, Invalid Region")
	d ASSERT(0,$d(JSON("errors",3)),"Receved too many errors from Valid Name, Invalid Segment, Invalid Region")
	d ASSERT("false",$g(JSON("verifyStatus")),"Invalid verifyStatus from Valid Name, Invalid Segment, Invalid Region")
	;
	; Valid Name, Valid Segment, Invalid Region
	k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""names"":{""ZZTEST"":""YOTTADB""},""regions"":{""-YOTTADB"":{""DYNAMIC_SEGMENT"":""YOTTADB""}},""segments"":{""YOTTADB"":{""FILE_NAME"":""/tmp/yottadb.dat"",""ACCESS_METHOD"":""BG""}}}"
	s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Valid Name, Valid Segment, Invalid Region")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Valid Name, Valid Segment, Invalid Region")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from Valid Name, Valid Segment, Invalid Region")
	d ASSERT("%GDE-E-PREFIXBAD, -YOTTADB - region name must start with an alphabetic character",$g(JSON("errors",1)),"Receved an unexpected error from Valid Name, Valid Segment, Invalid Region")
	d ASSERT(0,$d(JSON("errors",2)),"Receved too many errors from Valid Name, Valid Segment, Invalid Region")
	d ASSERT("false",$g(JSON("verifyStatus")),"Invalid verifyStatus from Valid Name, Valid Segment, Invalid Region")
	;
	; Valid Name, Valid Segment, Valid Region
	k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""names"":{""ZZTEST"":""YOTTADB""},""regions"":{""YOTTADB"":{""DYNAMIC_SEGMENT"":""YOTTADB""}},""segments"":{""YOTTADB"":{""FILE_NAME"":""/tmp/yottadb.dat"",""ACCESS_METHOD"":""BG""}}}"
	s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Valid Name, Valid Segment, Valid Region")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Valid Name, Valid Segment, Valid Region")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from Valid Name, Valid Segment, Valid Region")
	d ASSERT(0,$d(JSON("errors",1)),"Receved too many errors from Valid Name, Valid Segment, Valid Region")
	d ASSERT("true",$g(JSON("verifyStatus")),"Invalid verifyStatus from Valid Name, Valid Segment, Valid Region")
	;
	; Invalid Name, Invalid Segment, Invalid Region
	k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""names"":{""-ZZTEST"":""YOTTADB""},""regions"":{""-YOTTADB"":{""DYNAMIC_SEGMENT"":""YOTTADB""}},""segments"":{""-YOTTADB"":{""FILE_NAME"":""/tmp/yottadb.dat"",""ACCESS_METHOD"":""BG""}}}"
	s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Invalid Name, Invalid Segment, Invalid Region")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Invalid Name, Invalid Segment, Invalid Region")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from Invalid Name, Invalid Segment, Invalid Region")
	d ASSERT("%GDE-E-VALUEBAD, -ZZTEST is not a valid name",$g(JSON("errors",1)),"Receved an unexpected error from Invalid Name, Invalid Segment, Invalid Region")
	d ASSERT("%GDE-E-PREFIXBAD, -YOTTADB - region name must start with an alphabetic character",$g(JSON("errors",2)),"Receved an unexpected error from Invalid Name, Invalid Segment, Invalid Region")
	d ASSERT("%GDE-E-PREFIXBAD, -YOTTADB - segment name must start with an alphabetic character",$g(JSON("errors",3)),"Receved an unexpected error from Invalid Name, Invalid Segment, Invalid Region")
	d ASSERT(0,$d(JSON("errors",4)),"Receved too many errors from Invalid Name, Invalid Segment, Invalid Region")
	d ASSERT("false",$g(JSON("verifyStatus")),"Invalid verifyStatus from Invalid Name, Invalid Segment, Invalid Region")
	;
	; lowercase Segment, lowercase Region
	k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""regions"":{""yottadb"":{""DYNAMIC_SEGMENT"":""yottadb""}},""segments"":{""yottadb"":{""FILE_NAME"":""/tmp/yottadb.dat"",""ACCESS_METHOD"":""BG""}}}"
	s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from lowercase Segment, lowercase Region")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from lowercase Segment, lowercase Region")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from lowercase Segment, lowercase Region")
	d ASSERT("%GDE-I-MAPBAD, A NAME for REGION YOTTADB does not exist",$g(JSON("errors",1)),"Receved an unexpected error from lowercase Segment, lowercase Region")
	d ASSERT(0,$d(JSON("errors",2)),"Receved too many errors from Invalid Name, Invalid Segment, Invalid Region")
	d ASSERT("false",$g(JSON("verifyStatus")),"Invalid verifyStatus from lowercase Segment, lowercase Region")
	;
	; no file name for segment
	k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J),JSON
	; yes, this is a really long line
	s BODY="{""names"":{""#"":""DEFAULT"",""*"":""DEFAULT"",""XTMP"":""TEMP""},""regions"":{""DEFAULT"":{""ALIGNSIZE"":4096,""ALLOCATION"":2048,""AUTODB"":0,""AUTOSWITCHLIMIT"":8386560,""BEFORE_IMAGE"":1,""BUFFER_SIZE"":2312,""COLLATION_DEFAULT"":0,""DYNAMIC_SEGMENT"":""DEFAULT"",""EPOCHTAPER"":1,""EPOCH_INTERVAL"":300,""EXTENSION"":2048,""FILE_NAME"":""/opt/yottadb/gui/j/vehu.mjl"",""INST_FREEZE_ON_ERROR"":0,""JOURNAL"":1,""KEY_SIZE"":1019,""LOCK_CRIT_SEPARATE"":1,""NULL_SUBSCRIPTS"":0,""QDBRUNDOWN"":0,""RECORD_SIZE"":16368,""STATS"":1,""STDNULLCOLL"":1,""SYNC_IO"":0,""YIELD_LIMIT"":8},""TEMP"":{""ALIGNSIZE"":4096,""ALLOCATION"":2048,""AUTODB"":0,""AUTOSWITCHLIMIT"":8386560,""BEFORE_IMAGE"":0,""BUFFER_SIZE"":2312,""COLLATION_DEFAULT"":0,""DYNAMIC_SEGMENT"":""TEMP"",""EPOCHTAPER"":1,""EPOCH_INTERVAL"":300,""EXTENSION"":2048,""FILE_NAME"":"""",""INST_FREEZE_ON_ERROR"":0,""JOURNAL"":0,""KEY_SIZE"":1019,""LOCK_CRIT_SEPARATE"":1,""NULL_SUBSCRIPTS"":0,""QDBRUNDOWN"":0,""RECORD_SIZE"":16368,""STATS"":1,""STDNULLCOLL"":1,""SYNC_IO"":0,""YIELD_LIMIT"":8}},""segments"":{""DEFAULT"":{""ACCESS_METHOD"":""BG"",""ALLOCATION"":200000,""ASYNCIO"":0,""BLOCK_SIZE"":4096,""BUCKET_SIZE"":"""",""DEFER"":"""",""DEFER_ALLOCATE"":1,""ENCRYPTION_FLAG"":0,""EXTENSION_COUNT"":1024,""FILE_NAME"":""/opt/yottadb/gui/g/vehu.dat"",""FILE_TYPE"":""DYNAMIC"",""GLOBAL_BUFFER_COUNT"":4096,""LOCK_SPACE"":400,""MUTEX_SLOTS"":1024,""RESERVED_BYTES"":0,""WINDOW_SIZE"":""""},""TEMP"":{""ACCESS_METHOD"":""MM"",""ALLOCATION"":10000,""ASYNCIO"":0,""BLOCK_SIZE"":4096,""BUCKET_SIZE"":"""",""DEFER"":1,""DEFER_ALLOCATE"":1,""ENCRYPTION_FLAG"":0,""EXTENSION_COUNT"":1024,""FILE_NAME"":""/opt/yottadb/gui/g/temp.dat"",""FILE_TYPE"":""DYNAMIC"",""GLOBAL_BUFFER_COUNT"":4096,""LOCK_SPACE"":400,""MUTEX_SLOTS"":1024,""RESERVED_BYTES"":0,""WINDOW_SIZE"":""""},""ASDF"":{""NAME"":""ASDF"",""FILE_NAME"":"""",""ACCESS_METHOD"":""BG"",""ALLOCATION"":100,""ASYNCIO"":false,""BLOCK_SIZE"":1024,""DEFER_ALLOCATE"":true,""ENCRYPTION_FLAG"":false,""EXTENSION_COUNT"":100,""GLOBAL_BUFFER_COUNT"":1024,""LOCK_SPACE"":40,""MUTEX_SLOTS"":1024,""RESERVED_BYTES"":0}}}"
	s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from no file name for segment")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from no file name for segment")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from no file name for segment")
	d ASSERT("%GDE-E-QUALREQD, File required",$g(JSON("errors",1)),"Receved an unexpected error from no file name for segment")
	d ASSERT(0,$d(JSON("errors",2)),"Receved too many errors from no file name for segment")
	d ASSERT("false",$g(JSON("verifyStatus")),"Invalid verifyStatus from no file name for segment")
	;
	; invalid access method
	k BODY,RESULT,ERR,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""names"":{""ZZYOTTADB1"":""ZZYOTTADB""},""regions"":{""ZZYOTTADB"":{""DYNAMIC_SEGMENT"":""ZZYOTTADB""}},""segments"":{""ZZYOTTADB"":{""FILE_NAME"":""/tmp/zzyottadb.dat"",""ACCESS_METHOD"":""ZZ""}}}"
	s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from invalid access method")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from invalid access method")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from invalid access method")
	d ASSERT("%GDE-E-QUALREQD, Access method required",$g(JSON("errors",1)),"Receved incorrect error from invalid access method")
	d ASSERT(0,$d(JSON("errors",2)),"Receved too many errors from invalid access method")
	d ASSERT("false",$g(JSON("verifyStatus")),"Invalid verifyStatus from invalid access method")
	;
	; string subscript mapping
	k BODY,RESULT,ERR,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""names"":{""ZZYOTTADB1(\""OFF\"")"":""ZZYOTTADB""},""regions"":{""ZZYOTTADB"":{""DYNAMIC_SEGMENT"":""ZZYOTTADB""}},""segments"":{""ZZYOTTADB"":{""FILE_NAME"":""/tmp/zzyottadb.dat"",""ACCESS_METHOD"":""BG""}}}"
	s RESULT=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from string subscript mapping")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from string subscript mapping")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from string subscript mapping")
	d ASSERT("true",$g(JSON("verifyStatus")),"Invalid verifyStatus from string subscript mapping")
	QUIT
	;
save	;; @TEST save web service
	n ARGS,BODY,ERR,RESULT,HTTPERR,JSON
	; Invalid cases are dealt with in Verify step
	; TODO: Global Names, Template Access Methods, Template Region, Template Segment
	;
	; null BODY
	k BODY,RESULT,ERR,HTTPERR,^TMP("HTTPERR",$J)
	s BODY=""
	s RESULT=$$save^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT("",$g(RESULT),"Incorrect Response from Null Body")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(400,$g(HTTPERR),"Incorrect Response from Null Body")
	d ASSERT(400,$g(^TMP("HTTPERR",$J,1,"error","code")),"Error code not set from Null Body")
	d ASSERT(301,$g(^TMP("HTTPERR",$J,1,"error","errors",1,"reason")),"Reason code not set from Null Body")
	d ASSERT(0,$d(^TMP("HTTPERR",$J,1,"error","errors",2,"reason")),"Too many errors set from Null Body")
	;
	; Invalid JSON
	; k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J)
	; s BODY="{TEST: HI""}"
	; s RESULT=$$save^GDEWEB(.ARGS,.BODY,.RESULT)
	; d ASSERT("",$g(RESULT),"Incorrect Response from Null Body")
	; d ASSERT(400,$g(HTTPERR),"Incorrect Response from Invalid JSON")
	; d ASSERT(400,$g(^TMP("HTTPERR",$J,1,"error","code")),"Error code not set from Invalid JSON")
	; d ASSERT(202,$g(^TMP("HTTPERR",$J,1,"error","errors",1,"reason")),"Reason code not set from Invalid JSON")
	; d ASSERT(0,$d(^TMP("HTTPERR",$J,1,"error","errors",2,"reason")),"Too many errors set from Invalid JSON")
	;
	; Name with region (Valid)
	k BODY,RESULT,ERR,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY(1)="{""names"":{""ZZYOTTADB"":""TEMP""}}"
	s RESULT=$$save^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Valid Name")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Valid Name response")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from Valid Name")
	d ASSERT(0,$d(JSON("errors")),"Receved an unexpected error from Valid Name")
	d ASSERT("true",$g(JSON("verifyStatus")),"Invalid verifyStatus from Valid Name")
	;
	; verify with get to make sure added name is there
	k ARGS,RESULT,ERR,HTTPERR,JSON,^TMP("HTTPERR",$J)
	d get^GDEWEB(.RESULT,.ARGS)
	d ASSERT(10,$d(RESULT),"Incorrect Response from Valid Name verification")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Valid Name verification response")
	d ASSERT("ZZYOTTADB",$g(JSON("map",14,"from")),"Unable to find added name from Valid Name verification")
	d ASSERT("TEMP",$g(JSON("map",14,"region")),"Unable to find added name from Valid Name verification")
	d ASSERT("TEMP",$g(JSON("names","ZZYOTTADB")),"Unable to find added name from Valid Name verification")
	;
	; Name with range
	k BODY,RESULT,ERR,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""names"":{""ZZYOTTADB2(1:3)"":""TEMP""}}"
	s RESULT=$$save^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Valid Name Range")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Valid Name Range response")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from Valid Name Range")
	d ASSERT(0,$d(JSON("errors")),"Receved an unexpected error from Valid Name Range")
	d ASSERT("true",$g(JSON("verifyStatus")),"Invalid verifyStatus from Valid Name Range")
	;
	; verify with get to make sure added name is there
	k ARGS,RESULT,ERR,HTTPERR,JSON,^TMP("HTTPERR",$J)
	d get^GDEWEB(.RESULT,.ARGS)
	d ASSERT(10,$d(RESULT),"Incorrect Response from Valid Name Range verification")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Valid Name Range verification response")
	d ASSERT("ZZYOTTADB2(1)",$g(JSON("map",16,"from")),"Unable to find added name from Valid Name Range verification")
	d ASSERT("ZZYOTTADB2(3)",$g(JSON("map",16,"to")),"Unable to find added name from Valid Name Range verification")
	d ASSERT("TEMP",$g(JSON("map",16,"region")),"Unable to find added name from Valid Name Range verification")
	d ASSERT("TEMP",$g(JSON("names","ZZYOTTADB2(1:3)")),"Unable to find added name from Valid Name Range verification")
	;
	; Valid Name, Valid Segment, Valid Region
	k BODY,RESULT,ERR,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""names"":{""ZZYOTTADB1"":""ZZYOTTADB""},""regions"":{""ZZYOTTADB"":{""DYNAMIC_SEGMENT"":""ZZYOTTADB""}},""segments"":{""ZZYOTTADB"":{""FILE_NAME"":""/tmp/zzyottadb.dat"",""ACCESS_METHOD"":""BG""}}}"
	s RESULT=$$save^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Valid Name, Valid Segment, Valid Region")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Valid Name, Valid Segment, Valid Region")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from Valid Name, Valid Segment, Valid Region")
	d ASSERT(0,$d(JSON("errors",1)),"Receved too many errors from Valid Name, Valid Segment, Valid Region")
	d ASSERT("true",$g(JSON("verifyStatus")),"Invalid verifyStatus from Valid Name, Valid Segment, Valid Region")
	;
	; verify with get to make sure added name is there
	k ARGS,RESULT,ERR,HTTPERR,JSON,^TMP("HTTPERR",$J)
	d get^GDEWEB(.RESULT,.ARGS)
	d ASSERT(10,$d(RESULT),"Incorrect Response from Valid Name verification")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Valid Name verification response")
	d ASSERT("ZZYOTTADB1",$g(JSON("map",16,"from")),"Unable to find added name from Valid Name, Valid Segment, Valid Region verification")
	d ASSERT("ZZYOTTADB",$g(JSON("map",16,"region")),"Unable to find added name from Valid Name, Valid Segment, Valid Region verification")
	d ASSERT("ZZYOTTADB",$g(JSON("names","ZZYOTTADB1")),"Unable to find added name from Valid Name, Valid Segment, Valid Region verification")
	d ASSERT(10,$d(JSON("regions","ZZYOTTADB")),"Unable to find added region from Valid Name, Valid Segment, Valid Region verification")
	d ASSERT(10,$d(JSON("segments","ZZYOTTADB")),"Unable to find added region from Valid Name, Valid Segment, Valid Region verification")
	;
	; invalid access method
	k BODY,RESULT,ERR,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""names"":{""ZZYOTTADB1"":""ZZYOTTADB""},""regions"":{""ZZYOTTADB"":{""DYNAMIC_SEGMENT"":""ZZYOTTADB""}},""segments"":{""ZZYOTTADB"":{""FILE_NAME"":""/tmp/zzyottadb.dat"",""ACCESS_METHOD"":""ZZ""}}}"
	s RESULT=$$save^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from invalid access method")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from invalid access method")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from invalid access method")
	d ASSERT("%GDE-E-QUALREQD, Access method required",$g(JSON("errors",1)),"Receved incorrect error from invalid access method")
	d ASSERT(0,$d(JSON("errors",2)),"Receved too many errors from invalid access method")
	d ASSERT("false",$g(JSON("verifyStatus")),"Invalid verifyStatus from invalid access method")
	;
	; delete and add a name in the same transaction
	k BODY,RESULT,ERR,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""deletedItems"":[{""name"":{""NAME"":""ZZYOTTADB""}}],""names"":{""ZZYOTTADB2"":""ZZYOTTADB""}}"
	s RESULT=$$save^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Delete name and add name single transaction")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Delete name and add name single transaction")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from Delete name and add name single transaction")
	d ASSERT(0,$d(JSON("errors",1)),"Receved too many errors from Delete name and add name single transaction")
	d ASSERT("true",$g(JSON("verifyStatus")),"Invalid verifyStatus from Delete name and add name single transaction")
	;
	; verify with get to make sure added name is there
	k ARGS,RESULT,ERR,HTTPERR,JSON,^TMP("HTTPERR",$J)
	d get^GDEWEB(.RESULT,.ARGS)
	d ASSERT(10,$d(RESULT),"Incorrect Response from Delete name and add name single transaction verification")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Delete name and add name single transaction response")
	d ASSERT("ZZYOTTADB2",$g(JSON("map",16,"from")),"Unable to find added name from Delete name and add name single transaction verification")
	d ASSERT("ZZYOTTADB",$g(JSON("map",16,"region")),"Unable to find added name from Delete name and add name single transaction verification")
	d ASSERT("ZZYOTTADB",$g(JSON("names","ZZYOTTADB1")),"Unable to find added name from Delete name and add name single transaction verification")
	d ASSERT(10,$d(JSON("regions","ZZYOTTADB")),"Unable to find added region from Delete name and add name single transaction verification")
	d ASSERT(10,$d(JSON("segments","ZZYOTTADB")),"Unable to find added region from Delete name and add name single transaction verification")
	;
	; Reset for delete test
	k BODY,RESULT,ERR,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""deletedItems"":[{""name"":{""NAME"":""ZZYOTTADB2""}}],""names"":{""ZZYOTTADB"":""ZZYOTTADB""}}"
	s RESULT=$$save^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Reset Delete name and add name single transaction")
	QUIT
	;
delete	;; @TEST delete web service
	n ARGS,BODY,ERR,RESULT,HTTPERR,JSON
	; Invalid cases are dealt with in Verify step
	; TODO: Global Names, Template Access Methods, Template Region, Template Segment
	;
	; null BODY
	k BODY,RESULT,ERR,HTTPERR,^TMP("HTTPERR",$J)
	s BODY=""
	s RESULT=$$delete^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT("",$g(RESULT),"Incorrect Response from Null Body")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(400,$g(HTTPERR),"Incorrect Response from Null Body")
	d ASSERT(400,$g(^TMP("HTTPERR",$J,1,"error","code")),"Error code not set from Null Body")
	d ASSERT(301,$g(^TMP("HTTPERR",$J,1,"error","errors",1,"reason")),"Reason code not set from Null Body")
	d ASSERT(0,$d(^TMP("HTTPERR",$J,1,"error","errors",2,"reason")),"Too many errors set from Null Body")
	;
	; Invalid JSON
	; k BODY,RESULT,HTTPERR,^TMP("HTTPERR",$J)
	; s BODY="{TEST: HI""}"
	; s RESULT=$$save^GDEWEB(.ARGS,.BODY,.RESULT)
	; d ASSERT("",$g(RESULT),"Incorrect Response from Null Body")
	; d ASSERT(400,$g(HTTPERR),"Incorrect Response from Invalid JSON")
	; d ASSERT(400,$g(^TMP("HTTPERR",$J,1,"error","code")),"Error code not set from Invalid JSON")
	; d ASSERT(202,$g(^TMP("HTTPERR",$J,1,"error","errors",1,"reason")),"Reason code not set from Invalid JSON")
	; d ASSERT(0,$d(^TMP("HTTPERR",$J,1,"error","errors",2,"reason")),"Too many errors set from Invalid JSON")
	;
	; Name with region (Valid)
	k BODY,RESULT,ERR,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY(1)="{""name"":{""NAME"":""ZZYOTTADB""}}"
	s RESULT=$$delete^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Valid Name")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Valid Name response")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from Valid Name")
	d ASSERT(0,$d(JSON("errors")),"Receved an unexpected error from Valid Name")
	d ASSERT("true",$g(JSON("verifyStatus")),"Invalid verifyStatus from Valid Name")
	;
	; verify with get to make sure added name is there
	k ARGS,RESULT,ERR,HTTPERR,JSON,^TMP("HTTPERR",$J)
	d get^GDEWEB(.RESULT,.ARGS)
	d ASSERT(10,$d(RESULT),"Incorrect Response from Valid Name verification")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Valid Name verification response")
	d ASSERT("",$g(JSON("names","ZZYOTTADB")),"Unable to find added name from Valid Name verification")
	;
	; Name with range
	k BODY,RESULT,ERR,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""name"":{""NAME"":""ZZYOTTADB2(1:3)""}}"
	s RESULT=$$delete^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Valid Name Range")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Valid Name Range response")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from Valid Name Range")
	d ASSERT(0,$d(JSON("errors")),"Receved an unexpected error from Valid Name Range")
	d ASSERT("true",$g(JSON("verifyStatus")),"Invalid verifyStatus from Valid Name Range")
	;
	; verify with get to make sure added name is there
	k ARGS,RESULT,ERR,HTTPERR,JSON,^TMP("HTTPERR",$J)
	d get^GDEWEB(.RESULT,.ARGS)
	d ASSERT(10,$d(RESULT),"Incorrect Response from Valid Name Range verification")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Valid Name Range verification response")
	d ASSERT("",$g(JSON("names","ZZYOTTADB2(1:3)")),"Unable to find added name from Valid Name Range verification")
	;
	; Valid Name, Valid Segment, Valid Region
	k BODY,RESULT,ERR,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""name"":{""NAME"":""ZZYOTTADB1""},""region"":{""REGION"":""ZZYOTTADB""},""segment"":{""SEGMENT"":""ZZYOTTADB""}}"
	s RESULT=$$delete^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Valid Name, Valid Segment, Valid Region")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Valid Name, Valid Segment, Valid Region")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from Valid Name, Valid Segment, Valid Region")
	d ASSERT(0,$d(JSON("errors",1)),"Receved too many errors from Valid Name, Valid Segment, Valid Region")
	d ASSERT("true",$g(JSON("verifyStatus")),"Invalid verifyStatus from Valid Name, Valid Segment, Valid Region")
	;
	; verify with get to make sure added name is there
	k ARGS,RESULT,ERR,HTTPERR,JSON,^TMP("HTTPERR",$J)
	d get^GDEWEB(.RESULT,.ARGS)
	d ASSERT(10,$d(RESULT),"Incorrect Response from Valid Name verification")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Valid Name verification response")
	d ASSERT("",$g(JSON("names","ZZYOTTADB1")),"Unable to find added name from Valid Name, Valid Segment, Valid Region verification")
	d ASSERT(0,$d(JSON("regions","ZZYOTTADB")),"Unable to find added region from Valid Name, Valid Segment, Valid Region verification")
	d ASSERT(0,$d(JSON("segments","ZZYOTTADB")),"Unable to find added region from Valid Name, Valid Segment, Valid Region verification")
	;
	; delete invalid name
	k BODY,RESULT,ERR,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY(1)="{""name"":{""NAME"":""ASDF""}}"
	s RESULT=$$delete^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Invalid Name")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Invalid Name response")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from Invalid Name")
	d ASSERT(10,$d(JSON("errors")),"Receved an unexpected error from Invalid Name")
	d ASSERT("false",$g(JSON("verifyStatus")),"Invalid verifyStatus from Invalid Name")
	;
	; delete Local Locks
	k BODY,RESULT,ERR,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY(1)="{""name"":{""NAME"":""#""}}"
	s RESULT=$$delete^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Delete Local Locks Name")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Delete Local Locks Name response")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from Delete Local Locks Name")
	d ASSERT(10,$d(JSON("errors")),"Receved an unexpected error from Delete Local Locks Name")
	d ASSERT("false",$g(JSON("verifyStatus")),"Invalid verifyStatus from Delete Local Locks Name")
	;
	; delete with an array
	; first add stuff to delete:
	k BODY,RESULT,ERR,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY="{""names"":{""YDB"":""YOTTADB""},""regions"":{""YOTTADB"":{""DYNAMIC_SEGMENT"":""YDB""}},""segments"":{""YDB"":{""FILE_NAME"":""/tmp/ydb.dat"",""ACCESS_METHOD"":""BG""}}}"
	s RESULT=$$save^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Create Deletion Data")
	;
	; now delete it
	k BODY,RESULT,ERR,HTTPERR,^TMP("HTTPERR",$J),JSON
	s BODY(1)="[{""region"":{""REGION"":""YOTTADB""}},{""segment"":{""SEGMENT"":""YDB""}},{""name"":{""NAME"":""YDB""}}]"
	s RESULT=$$delete^GDEWEB(.ARGS,.BODY,.RESULT)
	d ASSERT(11,$d(RESULT),"Incorrect Response from Delete Array")
	d:$d(RESULT) DECODE^%webjson("RESULT","JSON","ERR")
	d ASSERT(0,$d(ERR),"Unable to decode JSON from Delete Array response")
	d ASSERT("",$g(HTTPERR),"Incorrect Response from Delete Array")
	d ASSERT(0,$d(JSON("errors")),"Receved an unexpected error from Delete Array")
	d ASSERT("true",$g(JSON("verifyStatus")),"Invalid verifyStatus from Delete Array")
	;
	QUIT
	;
message ;; @TEST Verify ZMessage replacement
	n gdequiet,gdeweberror,gdewebquit,gdeerr
	s gdequiet=1
	d ^GDEMSGIN
	k gdeweberror,gdewebquit
	d message^GDE(150503435,$zwrite(1233.5)_":"_$zwrite(1234)) ; "BLKSIZ512"
	d ASSERT("%GDE-I-BLKSIZ512, Block size 1233.5 rounds to 1234",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for BLKSIZ512")
	k gdeweberror,gdewebquit
	d message^GDE(150503443,$zwrite("test")) ; "EXECOM"
	d ASSERT("%GDE-I-EXECOM, Executing command file test",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for EXECOM")
	k gdeweberror,gdewebquit
	d message^GDE(150503451,$zwrite("/asdf.txt")) ; "FILENOTFND"
	d ASSERT("%GDE-I-FILENOTFND, File /asdf.txt not found",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for FILENOTFND")
	k gdeweberror,gdewebquit
	d message^GDE(150503459,$zwrite("test")) ; "GDCREATE"
	d ASSERT("%GDE-I-GDCREATE, Creating Global Directory file \n"_$C(9)_"test",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for GDCREATE")
	k gdeweberror,gdewebquit
	d message^GDE(150503467) ; "GDECHECK"
	d ASSERT("%GDE-I-GDECHECK, Internal GDE consistency check",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for GDECHECK")
	k gdeweberror,gdewebquit
	d message^GDE(150503475,$zwrite("test")) ; "GDUNKNFMT"
	d ASSERT("%GDE-I-GDUNKNFMT, test \n"_$C(9)_"is not formatted as a Global Directory",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for GDUNKNFMT")
	k gdeweberror,gdewebquit
	; Note this on is different!
	; We don't report GDUPDATE messages as an error 
	d message^GDE(150503483,$zwrite("test")) ; "GDUPDATE"
	d ASSERT(0,$d(gdeweberror),"Invalid message returned")
	d ASSERT("",$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for LOADGD")
	k gdeweberror,gdewebquit
	d message^GDE(150503491,$zwrite("test")) ; "GDUSEDEFS"
	d ASSERT("%GDE-I-GDUSEDEFS, Using defaults for Global Directory \n"_$C(9)_"test",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for GDUSEDEFS")
	k gdeweberror,gdewebquit
	d message^GDE(150503498,$zwrite("a")) ; "ILLCHAR"
	d ASSERT("%GDE-E-ILLCHAR, a is not a legal character in this context",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for ILLCHAR")
	k gdeweberror,gdewebquit
	d message^GDE(150503506) ; "INPINTEG"
	d ASSERT("%GDE-E-INPINTEG, Input integrity error -- aborting load",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for INPINTEG")
	k gdeweberror,gdewebquit
	d message^GDE(150503515,$zwrite("test1")_":"_$zwrite("test2")) ; "KEYTOOBIG"
	d ASSERT("%GDE-I-KEYTOOBIG, But record size test1 can only support key size test2",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for KEYTOOBIG")
	k gdeweberror,gdewebquit
	d message^GDE(150503523,$zwrite(1234)) ; "KEYSIZIS"
	d ASSERT("%GDE-I-KEYSIZIS, Key size is 1234",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for KEYSIZIS")
	k gdeweberror,gdewebquit
	d message^GDE(150503530,$zwrite("testa")_":"_$zwrite("test")) ; "KEYWRDAMB"
	d ASSERT("%GDE-E-KEYWRDAMB, testa is ambiguous for test",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for KEYWRDAMB")
	k gdeweberror,gdewebquit
	d message^GDE(150503538,$zwrite("bob")_":"_$zwrite("alice")) ; "KEYWRDBAD"
	d ASSERT("%GDE-E-KEYWRDBAD, bob is not a valid alice in this context",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for KEYWRDBAD")
	k gdeweberror,gdewebquit
	; Note this on is different!
	; We don't report LOADGD messages as an error 
	d message^GDE(150503547,$zwrite("/tmp/test")) ; "LOADGD"
	d ASSERT(0,$d(gdeweberror),"Invalid message returned")
	d ASSERT("",$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for LOADGD")
	k gdeweberror,gdewebquit
	d message^GDE(150503555,$zwrite("/tmp/log.log")) ; "LOGOFF"
	d ASSERT("%GDE-I-LOGOFF, No longer logging to file /tmp/log.log",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for LOGOFF")
	k gdeweberror,gdewebquit
	d message^GDE(150503563,$zwrite("/tmp/log.log")) ; "LOGON"
	d ASSERT("%GDE-I-LOGON, Logging to file /tmp/log.log",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for LOGON")
	k gdeweberror,gdewebquit
	d message^GDE(150503570) ; "LVSTARALON"
	d ASSERT("%GDE-E-LVSTARALON, The * name cannot be deleted or renamed",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for LVSTARALON")
	k gdeweberror,gdewebquit
	d message^GDE(150503579,$zwrite("test1")_":"_$zwrite("test2")_":"_$zwrite("test3")_":"_$zwrite("test4")) ; "MAPBAD"
	d ASSERT("%GDE-I-MAPBAD, test1 test2 for test3 test4 does not exist",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for MAPBAD")
	k gdeweberror,gdewebquit
	d message^GDE(150503587,$zwrite("test1")_":"_$zwrite("test2")_":"_$zwrite("test3")_":"_$zwrite("test4")_":"_$zwrite("test5")) ; "MAPDUP"
	d ASSERT("%GDE-I-MAPDUP, test1 test2 and test3 both map to test4 test5",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for MAPDUP")
	k gdeweberror,gdewebquit
	d message^GDE(150503594,$zwrite("test")) ; "NAMENDBAD"
	d ASSERT("%GDE-E-NAMENDBAD, Subscripted name test must end with right parenthesis",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NAMENDBAD")
	k gdeweberror,gdewebquit
	d message^GDE(150503603,$zwrite("test")) ; "NOACTION"
	d ASSERT("%GDE-I-NOACTION, Not updating Global Directory test",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for NOACTION")
	k gdeweberror,gdewebquit
	d message^GDE(150503610) ; "RPAREN"
	d ASSERT("%GDE-E-RPAREN, List must end with right parenthesis or continue with comma",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for RPAREN")
	k gdeweberror,gdewebquit
	d message^GDE(150503619) ; "NOEXIT"
	d ASSERT("%GDE-I-NOEXIT, Cannot exit because of verification failure",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for NOEXIT")
	k gdeweberror,gdewebquit
	d message^GDE(150503627,$zwrite("test")) ; "NOLOG"
	d ASSERT("%GDE-I-NOLOG, Logging is currently disabled\n Log file is test.",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for NOLOG")
	k gdeweberror,gdewebquit
	d message^GDE(150503634,$zwrite("test")) ; "NOVALUE"
	d ASSERT("%GDE-E-NOVALUE, Qualifier test does not take a value",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NOVALUE")
	k gdeweberror,gdewebquit
	d message^GDE(150503642,$zwrite("test")) ; "NONEGATE"
	d ASSERT("%GDE-E-NONEGATE, Qualifier test cannot be negated",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NONEGATE")
	k gdeweberror,gdewebquit
	d message^GDE(150503650,$zwrite("test")_":"_$zwrite("test1")) ; "OBJDUP"
	d ASSERT("%GDE-E-OBJDUP, test test1 already exists",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for OBJDUP")
	k gdeweberror,gdewebquit
	d message^GDE(150503658,$zwrite("test")_":"_$zwrite("test1")) ; "OBJNOTADD"
	d ASSERT("%GDE-E-OBJNOTADD, Not adding test test1",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for OBJNOTADD")
	k gdeweberror,gdewebquit
	d message^GDE(150503666,$zwrite("test")_":"_$zwrite("test1")) ; "OBJNOTCHG"
	d ASSERT("%GDE-E-OBJNOTCHG, Not changing test test1",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for OBJNOTCHG")
	k gdeweberror,gdewebquit
	d message^GDE(150503674,$zwrite("test")_":"_$zwrite("test1")) ; "OBJNOTFND"
	d ASSERT("%GDE-E-OBJNOTFND, test test1 does not exist",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for OBJNOTFND")
	k gdeweberror,gdewebquit
	d message^GDE(150503682,$zwrite("test")) ; "OBJREQD"
	d ASSERT("%GDE-E-OBJREQD, test required",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for OBJREQD")
	k gdeweberror,gdewebquit
	d message^GDE(150503690,$zwrite("test")_":"_$zwrite("test1")_":"_$zwrite("test2")) ; "PREFIXBAD"
	d ASSERT("%GDE-E-PREFIXBAD, test - test1 test2 must start with an alphabetic character",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for PREFIXBAD")
	k gdeweberror,gdewebquit
	d message^GDE(150503698,$zwrite("test")) ; "QUALBAD"
	d ASSERT("%GDE-E-QUALBAD, test is not a valid qualifier",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for QUALBAD")
	k gdeweberror,gdewebquit
	d message^GDE(150503706,$zwrite("test")) ; "QUALDUP"
	d ASSERT("%GDE-E-QUALDUP, test qualifier appears more than once in the list",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for QUALDUP")
	k gdeweberror,gdewebquit
	d message^GDE(150503714,$zwrite("test")) ; "QUALREQD"
	d ASSERT("%GDE-E-QUALREQD, test required",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for QUALREQD")
	k gdeweberror,gdewebquit
	d message^GDE(150503723,$zwrite("test")_":"_$zwrite("asdf")_":"_$zwrite(3)) ; "RECTOOBIG"
	d ASSERT("%GDE-I-RECTOOBIG, Block size test and asdf reserved bytes limit record size to 3",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for RECTOOBIG")
	k gdeweberror,gdewebquit
	d message^GDE(150503731,$zwrite(1)) ; "RECSIZIS"
	d ASSERT("%GDE-I-RECSIZIS, Record size is 1",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for RECSIZIS")
	k gdeweberror,gdewebquit
	d message^GDE(150503739,$zwrite("bob")) ; "REGIS"
	d ASSERT("%GDE-I-REGIS, in region bob",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for REGIS")
	k gdeweberror,gdewebquit
	d message^GDE(150503747,$zwrite("octo")_":"_$zwrite("rocks")) ; "SEGIS"
	d ASSERT("%GDE-I-SEGIS, in octo segment rocks",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for SEGIS")
	k gdeweberror,gdewebquit
	d message^GDE(150503755,$zwrite(100)_":"_$zwrite(1)_":"_$zwrite("bob")) ; "VALTOOBIG"
	d ASSERT("%GDE-I-VALTOOBIG, 100 is larger than the maximum of 1 for a bob",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for VALTOOBIG")
	k gdeweberror,gdewebquit
	d message^GDE(150503762,$zwrite(100)_":"_$zwrite(.9999)_":"_$zwrite("alice")) ; "VALTOOLONG"
	d ASSERT("%GDE-E-VALTOOLONG, 100 exceeds the maximum length of .9999 for a alice",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for VALTOOLONG")
	k gdeweberror,gdewebquit
	d message^GDE(150503771,$zwrite(1)_":"_$zwrite(100)_":"_$zwrite("segment")) ; "VALTOOSMALL"
	d ASSERT("%GDE-I-VALTOOSMALL, 1 is less than the minimum of 100 for a segment",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for VALTOOSMALL")
	k gdeweberror,gdewebquit
	d message^GDE(150503778,$zwrite(1)_":"_$zwrite("message")) ; "VALUEBAD"
	d ASSERT("%GDE-E-VALUEBAD, 1 is not a valid message",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for VALUEBAD")
	k gdeweberror,gdewebquit
	d message^GDE(150503786,$zwrite("test")) ; "VALUEREQD"
	d ASSERT("%GDE-E-VALUEREQD, Qualifier test requires a value",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for VALUEREQD")
	k gdeweberror,gdewebquit
	; Note this on is different!
	; We don't report VERIFY messages as an error
	d message^GDE(150503795) ; "VERIFY"
	d ASSERT(0,$d(gdeweberror),"Invalid message returned")
	d ASSERT("",$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for VERIFY")
	k gdeweberror,gdewebquit
	d message^GDE(150503803,$zwrite("test")) ; "BUFSIZIS"
	d ASSERT("%GDE-I-BUFSIZIS, Journal Buffer size is test",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for BUFSIZIS")
	k gdeweberror,gdewebquit
	d message^GDE(150503811,$zwrite("test")_":"_$zwrite(100)) ; "BUFTOOSMALL"
	d ASSERT("%GDE-I-BUFTOOSMALL, But block size test requires buffer size 100",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for BUFTOOSMALL")
	k gdeweberror,gdewebquit
	d message^GDE(150503819) ; "MMNOBEFORIMG"
	d ASSERT("%GDE-I-MMNOBEFORIMG, MM segments do not support before image jounaling",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for MMNOBEFORIMG")
	k gdeweberror,gdewebquit
	d message^GDE(150503827,$zwrite("test")) ; "NOJNL"
	d ASSERT("%GDE-I-NOJNL, test segments do not support journaling",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for NOJNL")
	k gdeweberror,gdewebquit
	d message^GDE(150503835,$zwrite("/tmp/test")) ; "GDREADERR"
	d ASSERT("%GDE-I-GDREADERR, Error reading Global Directory: /tmp/test",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for GDREADERR")
	k gdeweberror,gdewebquit
	d message^GDE(150503843) ; "GDNOTSET"
	d ASSERT("%GDE-I-GDNOTSET, Global Directory not changed because the current GD cannot be written",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for GDNOTSET")
	k gdeweberror,gdewebquit
	d message^GDE(150503851,$zwrite("tmp/tst")_":"_$zwrite("/opt/tmp/test")) ; "INVGBLDIR"
	d ASSERT("%GDE-I-INVGBLDIR, Invalid Global Directory spec: tmp/tst.\nContinuing with /opt/tmp/test",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for INVGBLDIR")
	k gdeweberror,gdewebquit
	d message^GDE(150503859,$zwrite("fail")) ; "WRITEERROR"
	d ASSERT("%GDE-I-WRITEERROR, Cannot exit because of write failure.  Reason for failure: fail",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for WRITEERROR")
	k gdeweberror,gdewebquit
	d message^GDE(150503866,$zwrite("test")_":"_$zwrite("region")) ; "NONASCII"
	d ASSERT("%GDE-E-NONASCII, test is illegal for a region as it contains non-ASCII characters",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NONASCII")
	k gdeweberror,gdewebquit
	d message^GDE(150503874,$zwrite("test")) ; "GDECRYPTNOMM"
	d ASSERT("%GDE-E-GDECRYPTNOMM, test segment has encryption turned on. Cannot support MM access method.",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for GDECRYPTNOMM")
	k gdeweberror,gdewebquit
	d message^GDE(150504106,$zwrite("test")) ; "GDEASYNCIONOMM"
	d ASSERT("%GDE-E-GDEASYNCIONOMM, test segment has ASYNCIO turned on. Cannot support MM access method.",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for GDEASYNCIONOMM")
	k gdeweberror,gdewebquit
	d message^GDE(150503883,$zwrite(1)_":"_$zwrite(100)_":"_$zwrite("test")_":"_$zwrite("segment")) ; "JNLALLOCGROW"
	d ASSERT("%GDE-I-JNLALLOCGROW, Increased Journal ALLOCATION from [1 blocks] to [100 blocks] to match AUTOSWITCHLIMIT for test segment",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for JNLALLOCGROW")
	k gdeweberror,gdewebquit
	d message^GDE(150503891,$zwrite(512)_":"_$zwrite(2)_":"_$zwrite(510)) ; "KEYFORBLK"
	d ASSERT("%GDE-I-KEYFORBLK, But block size 512 and reserved bytes 2 limit key size to 510",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for KEYFORBLK")
	k gdeweberror,gdewebquit
	d message^GDE(150503898,$zwrite("TEST")) ; "STRMISSQUOTE"
	d ASSERT("%GDE-E-STRMISSQUOTE, Missing double-quote at end of string specification TEST",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for STRMISSQUOTE")
	k gdeweberror,gdewebquit
	d message^GDE(150503907,$zwrite("test")) ; "GBLNAMEIS"
	d ASSERT("%GDE-I-GBLNAMEIS, in gblname test",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for GBLNAMEIS")
	k gdeweberror,gdewebquit
	d message^GDE(150503914,$zwrite(1)) ; "NAMSUBSEMPTY"
	d ASSERT("%GDE-E-NAMSUBSEMPTY, Subscript #1 is empty in name specification",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NAMSUBSEMPTY")
	k gdeweberror,gdewebquit
	d message^GDE(150503922,$zwrite(20)_":"_$zwrite("a")) ; "NAMSUBSBAD"
	d ASSERT("%GDE-E-NAMSUBSBAD, Subscript #20 with value a in name specification is an invalid number or string",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NAMSUBSBAD")
	k gdeweberror,gdewebquit
	d message^GDE(150503930,$zwrite(2)_":"_$zwrite("test")) ; "NAMNUMSUBSOFLOW"
	d ASSERT("%GDE-E-NAMNUMSUBSOFLOW, Subscript #2 with value test in name specification has a numeric overflow",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NAMNUMSUBSOFLOW")
	k gdeweberror,gdewebquit
	d message^GDE(150503938,$zwrite(5)_":"_$zwrite("BEEF")) ; "NAMNUMSUBNOTEXACT"
	d ASSERT("%GDE-E-NAMNUMSUBNOTEXACT, Subscript #5 with value BEEF in name specification is not an exact GT.M number",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NAMNUMSUBNOTEXACT")
	k gdeweberror,gdewebquit
	d message^GDE(150503946,$zwrite("^")_":"_$zwrite("test")_":"_$zwrite("bob")) ; "MISSINGDELIM"
	d ASSERT("%GDE-E-MISSINGDELIM, Delimiter ^ expected before test bob",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for MISSINGDELIM")
	k gdeweberror,gdewebquit
	d message^GDE(150503954,$zwrite("test")) ; "NAMRANGELASTSUB"
	d ASSERT("%GDE-E-NAMRANGELASTSUB, Ranges in name specification test are allowed only in the last subscript",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NAMRANGELASTSUB")
	k gdeweberror,gdewebquit
	d message^GDE(150503962,$zwrite("test")) ; "NAMSTARSUBSMIX"
	d ASSERT("%GDE-E-NAMSTARSUBSMIX, Name specification test cannot contain * and subscripts at the same time",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NAMSTARSUBSMIX")
	k gdeweberror,gdewebquit
	d message^GDE(150503970,$zwrite("test")) ; "NAMLPARENNOTBEG"
	d ASSERT("%GDE-E-NAMLPARENNOTBEG, Subscripted Name specification test needs to have a left parenthesis at the beginning of subscripts",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NAMLPARENNOTBEG")
	k gdeweberror,gdewebquit
	d message^GDE(150503978,$zwrite("TEST")) ; "NAMRPARENNOTEND"
	d ASSERT("%GDE-E-NAMRPARENNOTEND, Subscripted Name specification TEST cannot have anything following the right parenthesis at the end of subscripts",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NAMRPARENNOTEND")
	k gdeweberror,gdewebquit
	d message^GDE(150503986,$zwrite("test")) ; "NAMONECOLON"
	d ASSERT("%GDE-E-NAMONECOLON, Subscripted Name specification test must have at most one colon (range) specification",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NAMONECOLON")
	k gdeweberror,gdewebquit
	d message^GDE(150503994,$zwrite("test")) ; "NAMRPARENMISSING"
	d ASSERT("%GDE-E-NAMRPARENMISSING, Subscripted Name specification test is missing one or more right parentheses at the end of subscripts",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NAMRPARENMISSING")
	k gdeweberror,gdewebquit
	d message^GDE(150504002,$zwrite("test")_":"_$zwrite(1)) ; "NAMGVSUBSMAX"
	d ASSERT("%GDE-E-NAMGVSUBSMAX, Subscripted Name specification test has more than the maximum # of subscripts (1)",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NAMGVSUBSMAX")
	k gdeweberror,gdewebquit
	d message^GDE(150504010,$zwrite(10)_":"_$zwrite("test")) ; "NAMNOTSTRSUBS"
	d ASSERT("%GDE-E-NAMNOTSTRSUBS, Subscript #10 with value test in name specification is not a properly formatted string subscript",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NAMNOTSTRSUBS")
	k gdeweberror,gdewebquit
	d message^GDE(150504018,$zwrite(3)_":"_$zwrite("test")) ; "NAMSTRSUBSFUN"
	d ASSERT("%GDE-E-NAMSTRSUBSFUN, Subscript #3 with value test in name specification uses function other than $C/$CHAR/$ZCH/$ZCHAR",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NAMSTRSUBSFUN")
	k gdeweberror,gdewebquit
	d message^GDE(150504026,$zwrite(5)_":"_$zwrite("test1")) ; "NAMSTRSUBSLPAREN"
	d ASSERT("%GDE-E-NAMSTRSUBSLPAREN, Subscript #5 with value test1 in name specification does not have left parenthesis following $ specification",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NAMSTRSUBSLPAREN")
	k gdeweberror,gdewebquit
	d message^GDE(150504034,$zwrite(8)_":"_$zwrite("test4")) ; "NAMSTRSUBSCHINT"
	d ASSERT("%GDE-E-NAMSTRSUBSCHINT, Subscript #8 with value test4 in name specification does not have a positive integer inside $C/$CHAR/$ZCH/$ZCHAR",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NAMSTRSUBSCHINT")
	k gdeweberror,gdewebquit
	d message^GDE(150504042,$zwrite(11)_":"_$zwrite("a")_":"_$zwrite(5)) ; "NAMSTRSUBSCHARG"
	d ASSERT("%GDE-E-NAMSTRSUBSCHARG, Subscript #11 with value a in name specification specifies a $C/$ZCH with number 5 that is invalid in the current $zchset",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NAMSTRSUBSCHARG")
	k gdeweberror,gdewebquit
	d message^GDE(150504050,$zwrite(5)_":"_$zwrite("November")) ; "GBLNAMCOLLUNDEF"
	d ASSERT("%GDE-E-GBLNAMCOLLUNDEF, Error opening shared library of collation sequence #5 for GBLNAME November",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for GBLNAMCOLLUNDEF")
	k gdeweberror,gdewebquit
	d message^GDE(150504058,$zwrite("November")_":"_$zwrite(5)) ; "NAMRANGEORDER"
	d ASSERT("%GDE-E-NAMRANGEORDER, Range in name specification November specifies out-of-order subscripts using collation sequence #5",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NAMRANGEORDER")
	k gdeweberror,gdewebquit
	d message^GDE(150504066,$zwrite("test")_":"_$zwrite("test3")_":"_$zwrite(5)) ; "NAMRANGEOVERLAP"
	d ASSERT("%GDE-E-NAMRANGEOVERLAP, Range in name specifications test and test3 overlap using collation sequence #5",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NAMRANGEOVERLAP")
	k gdeweberror,gdewebquit
	d message^GDE(150504074,$zwrite(3)_":"_$zwrite(14)_":"_$zwrite(159)) ; "NAMGVSUBOFLOW"
	d ASSERT("%GDE-E-NAMGVSUBOFLOW, Subscripted name 3...14 is too long to represent in the database using collation value #159",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NAMGVSUBOFLOW")
	k gdeweberror,gdewebquit
	d message^GDE(150504082,$zwrite(3.14159)) ; "GBLNAMCOLLRANGE"
	d ASSERT("%GDE-E-GBLNAMCOLLRANGE, Collation sequence #3.14159 is out of range (0 thru 255)",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for GBLNAMCOLLRANGE")
	k gdeweberror,gdewebquit
	d message^GDE(150504091,$zwrite("test")_":"_$zwrite("test6")) ; "STDNULLCOLLREQ"
	d ASSERT("%GDE-I-STDNULLCOLLREQ, Region test needs Standard Null Collation enabled because global test6 spans through it",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT("",$g(gdewebquit),"gdewebquit is invalid for STDNULLCOLLREQ")
	k gdeweberror,gdewebquit
	d message^GDE(150504098,$zwrite("test")_":"_$zwrite(1337)_":"_$zwrite(3)_":"_$zwrite(5)) ; "GBLNAMCOLLVER"
	d ASSERT("%GDE-E-GBLNAMCOLLVER, Global directory indicates GBLNAME test has collation sequence #1337 with a version #3 but shared library reports different version #5",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for GBLNAMCOLLVER")
	k gdeweberror,gdewebquit
	d message^GDE(150504114) ; "NOPERCENTY"
	d ASSERT("%GDE-E-NOPERCENTY, ^%Y* is a reserved global name in YottaDB",$g(gdeweberror(1)),"Invalid message returned")
	d ASSERT(1,$g(gdeweberror("count")),"Too many errors returned")
	d ASSERT(1,$g(gdewebquit),"gdewebquit is invalid for NOPERCENTY")
	QUIT
isFAO	;; @TEST Is FAO string Valid
	d ASSERT(1,$$isFAO^GDE("!/"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!_"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!^"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!!"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2AC"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!AC"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2AD"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!AD"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2AF"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!AF"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2AS"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!AS"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2AZ"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!AZ"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2SB"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!SB"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2SW"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!SW"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2SL"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!SL"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2UB"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!UB"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2UW"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!UW"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2UL"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!UL"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2@UJ"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!@UJ"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2@UQ"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!@UQ"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2XB"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!XB"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2XW"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!XW"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2XL"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!XL"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2XJ"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!XJ"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2@XJ"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!@XJ"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2@XQ"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!@XQ"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2ZB"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!ZB"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2ZW"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!ZW"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2ZL"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!ZL"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!2*A"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!*A"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!@ZJ"),"FAO code isn't recognized")
	d ASSERT(1,$$isFAO^GDE("!@ZQ"),"FAO code isn't recognized")
	;
	; Invalid tests
	d ASSERT(0,$$isFAO^GDE("ASDF"),"FAO code recognized")
	d ASSERT(0,$$isFAO^GDE("#$@%"),"FAO code recognized")
	d ASSERT(0,$$isFAO^GDE("!2UUL"),"FAO code recognized")
	d ASSERT(0,$$isFAO^GDE("!UUL"),"FAO code recognized")
	d ASSERT(0,$$isFAO^GDE("!@2UUL"),"FAO code recognized")
	d ASSERT(0,$$isFAO^GDE("!2@UUL"),"FAO code recognized")
	d ASSERT(0,$$isFAO^GDE("!"),"FAO code recognized")
	d ASSERT(0,$$isFAO^GDE("_"),"FAO code recognized")
	QUIT
createnamearray(name)
	n BOL,FALSE,HEX,MAXGVSUBS,MAXNAMLN,MAXREGLN,MAXSEGLN,MAXSTRLEN,ONE,PARNAMLN,PARREGLN,PARSEGLN
	n SIZEOF,TAB,TRUE,TWO,ZWRO,accmeth,comline,dbfilpar,defdb,defgld,defgldext,defglo,defreg,defseg
	n dflreg,encsupportedplat,endian,filexfm,gdeerr,glo,gtm64,hdrlab,helpfile,log,logfile,lower,maxgnam
	n maxinst,maxreg,maxseg,mingnam,minreg,minseg,nommbi,renpref,sep,spacedelim,syntab,tfile,tokendelim,tokens
	n typevalue,upper,ver,x,gdequiet
	;
	n useio,NAME
	s gdequiet=1
	s useio="io"
	d GDEINIT^GDEINIT,GDEMSGIN^GDEMSGIN
	;
	; Unsubscripted
	k NAME
	d createnamearray^GDEWEB("YOTTADB")
	d ASSERT("YOTTADB",$g(NAME),"Unexpected result from top level of NAME variable")
	d ASSERT("0",$g(NAME("NSUBS")),"Unexpected result from Number of Subscripts of NAME variable")
	d ASSERT("YOTTADB",$g(NAME("SUBS",0)),"Unexpected result Subscripts of NAME variable")
	d ASSERT("POINT",$g(NAME("TYPE")),"Unexpected result from TYPE of NAME variable")
	;
	; 1 alpha subscript
	k NAME
	d createnamearray^GDEWEB("YOTTADB(""TEST"")")
	d ASSERT("YOTTADB(""TEST"")",$g(NAME),"Unexpected result from top level of NAME variable")
	d ASSERT("YOTTADB(""TEST"")",$g(NAME("NAME")),"Unexpected result from NAME subscript of NAME variable")
	d ASSERT("1",$g(NAME("NSUBS")),"Unexpected result from Number of Subscripts of NAME variable")
	d ASSERT("YOTTADB",$g(NAME("SUBS",0)),"Unexpected result Subscripts of NAME variable")
	d ASSERT("""TEST""",$g(NAME("SUBS",1)),"Unexpected result Subscripts of NAME variable")
	d ASSERT("POINT",$g(NAME("TYPE")),"Unexpected result from TYPE of NAME variable")
	;
	; 1 alpha 1 numeric subscript
	k NAME
	d createnamearray^GDEWEB("YOTTADB(""TEST"",1)")
	d ASSERT("YOTTADB(""TEST"",1)",$g(NAME),"Unexpected result from top level of NAME variable")
	d ASSERT("YOTTADB(""TEST"",1)",$g(NAME("NAME")),"Unexpected result from NAME subscript of NAME variable")
	d ASSERT("2",$g(NAME("NSUBS")),"Unexpected result from Number of Subscripts of NAME variable")
	d ASSERT("YOTTADB",$g(NAME("SUBS",0)),"Unexpected result Subscripts of NAME variable")
	d ASSERT("""TEST""",$g(NAME("SUBS",1)),"Unexpected result Subscripts of NAME variable")
	d ASSERT(1,$g(NAME("SUBS",2)),"Unexpected result Subscripts of NAME variable")
	d ASSERT("POINT",$g(NAME("TYPE")),"Unexpected result from TYPE of NAME variable")
	;
	; numeric range 1 subscript
	k NAME
	d createnamearray^GDEWEB("YOTTADB(1:3)")
	d ASSERT("YOTTADB(1:3)",$g(NAME),"Unexpected result from top level of NAME variable")
	d ASSERT("YOTTADB(1:3)",$g(NAME("NAME")),"Unexpected result from NAME subscript of NAME variable")
	d ASSERT("YOTTADB(",$g(NAME("GVNPREFIX")),"Unexpected result from GVNPREFIX subscript of NAME variable")
	d ASSERT("2",$g(NAME("NSUBS")),"Unexpected result from Number of Subscripts of NAME variable")
	d ASSERT("YOTTADB",$g(NAME("SUBS",0)),"Unexpected result Subscripts of NAME variable")
	d ASSERT(1,$g(NAME("SUBS",1)),"Unexpected result Subscripts of NAME variable")
	d ASSERT(3,$g(NAME("SUBS",2)),"Unexpected result Subscripts of NAME variable")
	d ASSERT("RANGE",$g(NAME("TYPE")),"Unexpected result from TYPE of NAME variable")
	;
	; numeric range 2 subscripts
	k NAME
	d createnamearray^GDEWEB("YOTTADB(5,1:3)")
	d ASSERT("YOTTADB(5,1:3)",$g(NAME),"Unexpected result from top level of NAME variable")
	d ASSERT("YOTTADB(5,1:3)",$g(NAME("NAME")),"Unexpected result from NAME subscript of NAME variable")
	d ASSERT("YOTTADB(5,",$g(NAME("GVNPREFIX")),"Unexpected result from GVNPREFIX subscript of NAME variable")
	d ASSERT("3",$g(NAME("NSUBS")),"Unexpected result from Number of Subscripts of NAME variable")
	d ASSERT("YOTTADB",$g(NAME("SUBS",0)),"Unexpected result Subscripts of NAME variable")
	d ASSERT(5,$g(NAME("SUBS",1)),"Unexpected result Subscripts of NAME variable")
	d ASSERT(1,$g(NAME("SUBS",2)),"Unexpected result Subscripts of NAME variable")
	d ASSERT(3,$g(NAME("SUBS",3)),"Unexpected result Subscripts of NAME variable")
	d ASSERT("RANGE",$g(NAME("TYPE")),"Unexpected result from TYPE of NAME variable")
	;
	; alpha range 1 subscript
	k NAME
	d createnamearray^GDEWEB("YOTTADB(""A"":""F"")")
	d ASSERT("YOTTADB(""A"":""F"")",$g(NAME),"Unexpected result from top level of NAME variable")
	d ASSERT("YOTTADB(""A"":""F"")",$g(NAME("NAME")),"Unexpected result from NAME subscript of NAME variable")
	d ASSERT("YOTTADB(",$g(NAME("GVNPREFIX")),"Unexpected result from GVNPREFIX subscript of NAME variable")
	d ASSERT("2",$g(NAME("NSUBS")),"Unexpected result from Number of Subscripts of NAME variable")
	d ASSERT("YOTTADB",$g(NAME("SUBS",0)),"Unexpected result Subscripts of NAME variable")
	d ASSERT("A",$g(NAME("SUBS",1)),"Unexpected result Subscripts of NAME variable")
	d ASSERT("F",$g(NAME("SUBS",2)),"Unexpected result Subscripts of NAME variable")
	d ASSERT("RANGE",$g(NAME("TYPE")),"Unexpected result from TYPE of NAME variable")
	;
	; alpha range 2 subscripts
	k NAME
	d createnamearray^GDEWEB("YOTTADB(""TEST"",""G"":""Z"")")
	d ASSERT("YOTTADB(""TEST"",""G"":""Z"")",$g(NAME),"Unexpected result from top level of NAME variable")
	d ASSERT("YOTTADB(""TEST"",""G"":""Z"")",$g(NAME("NAME")),"Unexpected result from NAME subscript of NAME variable")
	d ASSERT("YOTTADB(""TEST"",",$g(NAME("GVNPREFIX")),"Unexpected result from GVNPREFIX subscript of NAME variable")
	d ASSERT("3",$g(NAME("NSUBS")),"Unexpected result from Number of Subscripts of NAME variable")
	d ASSERT("YOTTADB",$g(NAME("SUBS",0)),"Unexpected result Subscripts of NAME variable")
	d ASSERT("""TEST""",$g(NAME("SUBS",1)),"Unexpected result Subscripts of NAME variable")
	d ASSERT("""G""",$g(NAME("SUBS",2)),"Unexpected result Subscripts of NAME variable")
	d ASSERT("""Z""",$g(NAME("SUBS",3)),"Unexpected result Subscripts of NAME variable")
	d ASSERT("RANGE",$g(NAME("TYPE")),"Unexpected result from TYPE of NAME variable")
	QUIT
; Convenience method
ASSERT(expected,actual,message)
	d CHKEQ^%ut($g(expected),$g(actual),$g(message))
	QUIT
