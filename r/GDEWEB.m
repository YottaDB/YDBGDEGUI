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
;
; Starts the HTTP(S) server to serve the GUI files and web services
;
; @param {Integer} portnum - The TCP Port number to start the web server on
; @param {Integer} ssl - Enable/disable SSL
;
; @example
; d WEB^GDEWEB(9080)
;
WEB(portnum,ssl,gzipdisable,userpass)
	; Sanity check env vars to make sure GDE works as intended
	i (+$ztrnlnm("ydb_local_collate")'=0) w "Local collation environment variable (ydb_local_collate) must be 0" quit
	i (+$ztrnlnm("ydb_lct_stdnull")'=1) w "Standard null collation environment variable (ydb_lct_stdnull) must be 1" quit
	; parse arguments
	n done,args,i
	s done=0
	f i=1:1:$l($zcmdline," ") d
	. s args(i)=$p($zcmdline," ",i)
	; port number
	i $l($g(args(1)))&($g(args(1))=+$g(args(1))) s portnum=args(1)
	; ssl/tls config
	i $l($g(args(2))) s ssl=args(2)
	; gzip disable
	i $l($g(args(3))) s gzipdisable=args(3)
	; admin username/password
	i $l($g(args(4))) s userpass=args(4)
	;
	; Get the port number to run on
	i '$l($g(portnum))  w "No port number specified, or invalid - using default of 8080",!
	;
	; If we have no ssl flag quit (explicit configuration of SSl/TLS vs plain text)
	i $g(ssl)="" w "SSL/TLS is not explicitly disabled or enabled. You must explicitly configure this!",!,"Quitting...",! quit
	;
	; Determine if we need to run in SSL/TLS mode
	i ((ssl="ssl")!(ssl="SSL")!(ssl=1)) s ssl=1
	i ((ssl)&('$l($ztrnlnm("ydb_tls_passwd_ydbgui")))) w "SSL/TLS configuration not found!",! quit
	;
	; See if we are asked to be in non-SSL/TLS mode
	i ((ssl="nossl")!(ssl="NOSSL")!(ssl=0)) s ssl=0 w "SSL configuration NOT found!",!
	i 'ssl w "WARNING: Web server started without SSL/TLS",!
	;
	; set the GZIP flag
	i ((gzipdisable="nogzip")!(gzipdisable="NOGZIP")!(gzipdisable=1)) s gzipdisable=1 w "GZIP compression disabled",!
	e  s gzipdisable=0
	;
	; Make sure userpass argument is valid
	i $l($g(userpass))&($g(userpass)'[":") w "userpass argument must be in username:password format!",!,$g(userpass),!,"Quitting...",! quit
	;
	; Start the web server
	i $l($t(^%webreq)) d
	. w "Starting Web Server...",!
	. d job^%webreq($g(portnum,8080),$s(ssl:"ydbgui",1:""),1,$g(userpass),gzipdisable)
	e  d
	. w "Web server code not found in $zroutines, please make sure $zroutines is set correctly!",!
	quit
;
; Stops the HTTP(S) server that serves the GUI files and web services
;
; Note: This only works in the same session that started the web server as it uses local variables to find processes to kill
;
; @example
; d STOP^GDEWEB
STOP
	n pid
	s pid=""
	f  s pid=$o(KBBO("JOBS",pid)) q:pid=""  d
	. zsy "kill "_pid
	. k KBBO("JOBS",pid)
	quit
;
; Get the global directory as a JSON object
;
; @param {Array} RESULT - Passed by reference. The JSON representation of the global directory
; @param {Array} ARGS - Passed by reference. Unused variable, used only to conform to interface specification for web server
;
; @example
; d get^GDEWEB(.RESULT,.ARGS)
;
get(RESULT,ARGS)
	n JSON,ERR,gdequiet,gdeweberror,gdewebquit
	n useio,io
	;
	; GDE variables in the stack
	n BOL,FALSE,HEX,MAXGVSUBS,MAXGVSUBS,MAXNAMLN,MAXREGLN,MAXSEGLN,MAXSTRLEN
	n ONE,PARNAMLN,PARREGLN,PARSEGLN,SIZEOF,TAB,TRUE,TWO,ZERO,accmeth,am,bs
	n chset,combase,comlevel,comline,create,dbfilpar,defdb,defgld,defgldext
	n defglo,defreg,defseg,dflreg,encsupportedplat,endian,f,file,filesize
	n filexfm,gdeerr,glo,gnams,gtm64,hdrlab,helpfile,i,inst,killed,ks,l,label
	n len,log,logfile,lower,mach,matchLen,maxgnam,maxinst,maxreg,maxseg,mingnam
	n minreg,minseg,nams,nommbi,olabel,quitLoop,rec,reghasv550fields
	n reghasv600fields,regs,renpref,resume,s,seghasencrflag,segs,sep,syntab
	n tfile,tmpacc,tmpreg,tmpseg,tokens,typevalue,update,upper,v30,v44,v532
	n v533,v534,v542,v550,v5ft1,v600,v621,v631,v63a,ver,x,y,map,map2,mapdisp,s1,s2,l1,j
	;
	; setup required variables
	s gdequiet=1
	s io=$io
	s useio="io"
	d setup
	;
	n result
	;
	; Names
	;
	d NAM2MAP^GDEMAP ; get human readable mapping names
	n mapreg,mapdispmaxlen,index s mapreg="",mapdispmaxlen=0 D mapdispcalc
	s s1=$o(map("$"))
	i s1'="%" s map("%")=map("$"),s1="%"
	f index=1:1  s s2=s1,s1=$o(map(s2)) q:'$zl(s1)  d onemap(s1,s2)
	d onemap("...",s2)
	s index=index+1
	i $d(nams("#")) s s2="LOCAL LOCKS",map(s2)=nams("#") d onemap("",s2) k map(s2)
	m result("names")=nams
	zk result("names")
	m result("map")=map2
	m result("globalNames")=gnams
	zk result("globalNames")
	;
	; Regions
	;
	m result("regions")=regs
	zk result("regions")
	; minreg/maxreg are limits from INITGDE
	; probably not needed
	;merge result("minreg")=minreg
	;merge result("maxreg")=maxreg
	;
	; Segments
	;
	m result("segments")=segs
	zk result("segments")
	; minseg/maxseg are limits from INITGDE
	; probably not needed
	;merge result("minseg")=minseg
	;merge result("maxseg")=maxseg
	;
	; Templates
	;
	m result("template","accessMethod")=tmpacc
	m result("template","segment")=tmpseg
	zk result("template","segment","BG")
	zk result("template","segment","MM")
	m result("template","region")=tmpreg
	;
	; Access Methods
	n i
	f i=2:1:$l(accmeth,"\") s result("accessMethods",i-1)=$zpi(accmeth,"\",i)
	;
	; convert to booleans
	d inttobool(.result)
	; encode the result
	d ENCODE^%webjson("result","RESULT","ERR")
	i $d(ERR) D SETERROR^%webutils(201) quit
	quit
;
; Delete given global directory element(s)
;
; @param {Array} ARGS - Passed by reference. Unused variable, used only to conform to interface specification for web server
; @param {Array/Object} BODY - Passed by reference. JSON array or object that describes the global directory element to delete
; @param {Array} RESULT - Passed by reference. JSON object that contains errors, verification state, and the resulting global
;                         directory after the deletion
; @returns {String} - Empty string unless an error occurs. Errors are found in ^TMP($J)
;
; @example
; s BODY="{""name"":{""NAME"":""ZZYOTTADB1""},""region"":{""REGION"":""ZZYOTTADB""},""segment"":{""SEGMENT"":""ZZYOTTADB""}}"
; s STATUS=$$delete^GDEWEB(.ARGS,.BODY,.RESULT)
;
delete(ARGS,BODY,RESULT)
	n JSON,ERR,gdequiet,gdeweberror,gdewebquit
	n useio,io
	;
	; GDE variables in the stack
	n BOL,FALSE,HEX,MAXGVSUBS,MAXGVSUBS,MAXNAMLN,MAXREGLN,MAXSEGLN,MAXSTRLEN
	n ONE,PARNAMLN,PARREGLN,PARSEGLN,SIZEOF,TAB,TRUE,TWO,ZERO,accmeth,am,bs
	n chset,combase,comlevel,comline,create,dbfilpar,defdb,defgld,defgldext
	n defglo,defreg,defseg,dflreg,encsupportedplat,endian,f,file,filesize
	n filexfm,gdeerr,glo,gnams,gtm64,hdrlab,helpfile,i,inst,killed,ks,l,label
	n len,log,logfile,lower,mach,matchLen,maxgnam,maxinst,maxreg,maxseg,mingnam
	n minreg,minseg,nams,nommbi,olabel,quitLoop,rec,reghasv550fields
	n reghasv600fields,regs,renpref,resume,s,seghasencrflag,segs,sep,syntab
	n tfile,tmpacc,tmpreg,tmpseg,tokens,typevalue,update,upper,v30,v44,v532
	n v533,v534,v542,v550,v5ft1,v600,v621,v631,v63a,ver,x,y,map,map2,mapdisp,s1,s2,l1,j
	n attr,filetype,gdeputzs,gdexcept,maxs,record,ref,sreg,tempfile
	;
	i (($d(BODY)=0)!($d(BODY)=1))&($g(BODY)="") D SETERROR^%webutils(301,"BODY") quit ""
	d DECODE^%webjson("BODY","JSON","ERR")
	i $d(ERR) D SETERROR^%webutils(202) quit ""
	;
	; setup required variables
	s gdequiet=1
	s io=$io
	s useio="io"
	d setup
	;
	n NAME,REGION,SEGMENT,RSLT,getMapData,verifyStatus,next,x,debug
	s debug=""
	;
	; delete the object we've been given from the global directory
	i $d(JSON(1)) d
	. n i,item
	. s i=0
	. f  s i=$o(JSON(i)) q:i=""  d
	. . k item
	. . m item=JSON(i)
	. . d deleteone(.item)
	e  d deleteone(.JSON)
	; Perform verification
	i '$d(gdeweberror),$$ALL^GDEVERIF,$$GDEPUT^GDEPUT d
	. s verifyStatus="true"
	; We didn't pass validation OR couldn't save the global directory
	e  s verifyStatus="false",getMapData="" ; null value instead of empty string for getMapData?
	;
	; Prepare result
	s RSLT("verifyStatus")=verifyStatus
	m RSLT("getMapData")=getMapData
	m RSLT("errors")=gdeweberror
	d ENCODE^%webjson("RSLT","RESULT","ERR")
	i $d(ERR) D SETERROR^%webutils(201) quit ""
	quit ""
;
; Internal line tag for delete line tag that deletes a single item from the global directory.
; This requires a verification and put to save the changes to the global directory.
;
; @param {Array} JSON - Passed by reference. Contains an array structure for a single entry to be deleted from the global directory
;
; @example
; d deleteone^GDEWEB("{""name"":{""NAME"":""XTMP""}")
;
deleteone(JSON)
	i $d(JSON("name")) d
	. i $g(JSON("name","NAME"))="#" s gdeweberror($i(gdeweberror("count")))="Can't delete 'Local Locks' name" q
	. s NAME=$g(JSON("name","NAME"))
	. d NAME^GDEDELET
	i $d(JSON("region")) d
	. s REGION=$tr($g(JSON("region","REGION")),lower,upper)
	. d REGION^GDEDELET
	i $d(JSON("segment")) d
	. s SEGMENT=$tr($g(JSON("segment","SEGMENT")),lower,upper)
	. d SEGMENT^GDEDELET
	quit
;
; Save a given global directory
;
; @param {Array} ARGS - Passed by reference. Unused variable, used only to conform to interface specification for web server
; @param {Array/Object} BODY - Passed by reference. JSON object that describes the global directory entries to save
; @param {Array} RESULT - Passed by reference. JSON object that contains errors, verification state, and the resulting global
;                         directory after the operation
; @returns {String} - Empty string unless an error occurs. Errors are found in ^TMP($J)
;
; @example
; s BODY="{""names"":{""ZZYOTTADB2(1:3)"":""TEMP""}}"
; s STATUS=$$save^GDEWEB(.ARGS,.BODY,.RESULT)
;
save(ARGS,BODY,RESULT)
	n JSON,ERR,gdequiet,gdeweberror,gdewebquit
	n useio,io
	;
	; GDE variables in the stack
	n BOL,FALSE,HEX,MAXGVSUBS,MAXGVSUBS,MAXNAMLN,MAXREGLN,MAXSEGLN,MAXSTRLEN
	n ONE,PARNAMLN,PARREGLN,PARSEGLN,SIZEOF,TAB,TRUE,TWO,ZERO,accmeth,am,bs
	n chset,combase,comlevel,comline,create,dbfilpar,defdb,defgld,defgldext
	n defglo,defreg,defseg,dflreg,encsupportedplat,endian,f,file,filesize
	n filexfm,gdeerr,glo,gnams,gtm64,hdrlab,helpfile,i,inst,killed,ks,l,label
	n len,log,logfile,lower,mach,matchLen,maxgnam,maxinst,maxreg,maxseg,mingnam
	n minreg,minseg,nams,nommbi,olabel,quitLoop,rec,reghasv550fields
	n reghasv600fields,regs,renpref,resume,s,seghasencrflag,segs,sep,syntab
	n tfile,tmpacc,tmpreg,tmpseg,tokens,typevalue,update,upper,v30,v44,v532
	n v533,v534,v542,v550,v5ft1,v600,v621,v631,v63a,ver,x,y,map,map2,mapdisp,s1,s2,l1,j
	n attr,filetype,gdeputzs,gdexcept,maxs,record,ref,sreg,tempfile
	;
	i (($d(BODY)=0)!($d(BODY)=1))&($g(BODY)="") D SETERROR^%webutils(301,"BODY") quit ""
	d DECODE^%webjson("BODY","JSON","ERR")
	i $d(ERR) D SETERROR^%webutils(202) quit ""
	;
	; setup required variables
	s gdequiet=1
	s io=$io
	s useio="io"
	d setup
	;
	n verifyStatus,x,region,segment,namPlusCaret,reg,next,debug,NAME,result,getMapData
	n uname
	s debug=""
	;
	; Convert boolean to integer
	d booltoint(.JSON)
	;
	; Delete items from the global directory
	n i,item
	s i=0
	f  s i=$o(JSON("deletedItems",i)) q:i=""  d
	. k item
	. m item=JSON("deletedItems",i)
	. d deleteone(.item)
	;
	; Names:
	m nams=JSON("names")
	s x="" f  s x=$o(nams(x)) q:x=""  d
	. k region,NAME
	. s region=nams(x)
	. d:(x'="#")&(x'="*") createnamearray(x)
	. m nams(x)=NAME
	. s nams(x)=region
	;
	; Global Names:
	m gnams=JSON("globalNames")
	;
	; Regions:
	s x="" f  s x=$o(JSON("regions",x)) q:x=""  d
	. m regs(x)=tmpreg
	. ; remove items that are invalid
	. k JSON("regions",x,"NAME")
	. s attr="" f  s attr=$o(JSON("regions",x,attr)) q:attr=""  d
	. . i '$l($g(JSON("regions",x,attr))) k JSON("regions",x,attr)
	. ; Now merge the the incoming region
	. m regs($tr(x,lower,upper))=JSON("regions",x)
	. ; uppercase the dynamic segment
	. s regs($tr(x,lower,upper),"DYNAMIC_SEGMENT")=$tr(regs($tr(x,lower,upper),"DYNAMIC_SEGMENT"),lower,upper)
	;
	; Segments:
	s x="" f  s x=$o(JSON("segments",x)) q:x=""  d
	. i ($l($g(JSON("segments",x,"ACCESS_METHOD")))),($d(tmpseg(JSON("segments",x,"ACCESS_METHOD")))) m segs(x)=tmpseg(JSON("segments",x,"ACCESS_METHOD"))
	. e  d message^GDE(gdeerr("QUALREQD"),"""Access method""")
	. ; remove items that are invalid
	. k JSON("segments",x,"NAME")
	. s attr="" f  s attr=$o(JSON("segments",x,attr)) q:attr=""  d
	. . i '$l($g(JSON("segments",x,attr))) k JSON("segments",x,attr)
	. ; Now merge the incoming segment
	. m segs($tr(x,lower,upper))=JSON("segments",x)
	;
	; Template Access Methods:
	m tmpacc=JSON("template","accessMethod")
	;
	; Template Region:
	m tmpreg=JSON("template","region")
	;
	; Template Segment:
	m tmpseg=JSON("template","segment")
	;
	; Perform verification
	i ('$d(gdeweberror)),$$ALL^GDEVERIF,$$GDEPUT^GDEPUT d
	. s verifyStatus="true"
	; We didn't pass validation OR couldn't save the global directory
	e  s verifyStatus="false" ; null value instead of empty string for getMapData?
	;
	; Prepare result
	s result("verifyStatus")=verifyStatus
	m result("errors")=gdeweberror
	d ENCODE^%webjson("result","RESULT","ERR")
	i $d(ERR) D SETERROR^%webutils(201) quit ""
	quit ""
;
; Verify a given global directory
;
; @param {Array} ARGS - Passed by reference. Unused variable, used only to conform to interface specification for web server
; @param {Array/Object} BODY - Passed by reference. JSON object that describes the global directory to verify
; @param {Array} RESULT - Passed by reference. JSON object that contains errors, verification state, and the resulting global
;                         directory
; @returns {String} - Empty string unless an error occurs. Errors are found in ^TMP($J)
;
; @example
; s BODY="{""names"":{""ZZTEST"":""TEMP""}}"
; s STATUS=$$verify^GDEWEB(.ARGS,.BODY,.RESULT)
;
verify(ARGS,BODY,RESULT)
	n JSON,ERR,gdequiet,gdeweberror,gdewebquit
	n useio,io
	;
	; GDE variables in the stack
	n BOL,FALSE,HEX,MAXGVSUBS,MAXGVSUBS,MAXNAMLN,MAXREGLN,MAXSEGLN,MAXSTRLEN
	n ONE,PARNAMLN,PARREGLN,PARSEGLN,SIZEOF,TAB,TRUE,TWO,ZERO,accmeth,am,bs
	n chset,combase,comlevel,comline,create,dbfilpar,defdb,defgld,defgldext
	n defglo,defreg,defseg,dflreg,encsupportedplat,endian,f,file,filesize
	n filexfm,gdeerr,glo,gnams,gtm64,hdrlab,helpfile,i,inst,killed,ks,l,label
	n len,log,logfile,lower,mach,matchLen,maxgnam,maxinst,maxreg,maxseg,mingnam
	n minreg,minseg,nams,nommbi,olabel,quitLoop,rec,reghasv550fields
	n reghasv600fields,regs,renpref,resume,s,seghasencrflag,segs,sep,syntab
	n tfile,tmpacc,tmpreg,tmpseg,tokens,typevalue,update,upper,v30,v44,v532
	n v533,v534,v542,v550,v5ft1,v600,v621,v631,v63a,ver,x,y,map,map2,mapdisp,s1,s2,l1,j
	;
	i (($d(BODY)=0)!($d(BODY)=1))&($g(BODY)="") D SETERROR^%webutils(301,"BODY") quit ""
	d DECODE^%webjson("BODY","JSON","ERR")
	i $d(ERR) D SETERROR^%webutils(202) quit ""
	;
	; setup required variables
	s gdequiet=1
	s io=$io
	s useio="io"
	d setup
	n NAME,RSLT,region,attr,temp,SEGMENT,REGION
	;
	; Convert boolean to integer
	d booltoint(.JSON)
	;
	; Names:
	s x="" f  s x=$o(JSON("names",x)) q:x=""  d
	. ; Skip any nodes from JSON decoding
	. i x="\s" q
	. ; From GDEPARSE
	. ; relevant code from GDEPARSE is in createnamearray.
	. ; End from GDEPARSE
	. ; From GDEADD
	. i '$l($g(JSON("names",x)))  d message^GDE(gdeerr("QUALREQD"),"""Region""") q
	. ; End from GDEADD
	. k region,NAME
	. ; save off region as it gets re-written by createname array
	. s region=JSON("names",x)
	. d:(x'="#")&(x'="*") createnamearray(x)
	. m JSON("names",x)=NAME
	. s JSON("names",x)=region
	. ; Now merge the the incoming name
	. m nams(x)=JSON("names",x)
	. ; Now kill it so we don't loop over it
	. k JSON("names",x)
	;
	; Global Names:
	m gnams=JSON("globalNames")
	;
	; Regions:
	s REGION="" f  s REGION=$o(JSON("regions",REGION)) q:REGION=""  d
	. ; From GDEPARSE
	. ; make uppercase
	. k temp
	. m temp($tr(REGION,lower,upper))=JSON("regions",REGION)
	. k JSON("regions",REGION)
	. m JSON("regions",$tr(REGION,lower,upper))=temp($tr(REGION,lower,upper))
	. s REGION=$tr(REGION,lower,upper)
	. i '$zl(REGION) d message^GDE(gdeerr("VALUEBAD"),$zwrite(REGION)_":"""_renpref_"region""") q
	. i $l(REGION)'=$zl(REGION) d message^GDE(gdeerr("NONASCII"),$zwrite(REGION)_":""region""")	q ; error if the name of the region is non-ascii
	. i REGION=defreg q
	. s x=$ze(REGION) i x'?1A d message^GDE(gdeerr("PREFIXBAD"),$zwrite(REGION)_":"""_renpref_"region"_""":""name""") q
	. i $ze(REGION,2,999)'?.(1AN,1"_",1"$") d message^GDE(gdeerr("VALUEBAD"),$zwrite(REGION)_":""region""") q
	. i $zl(REGION)>PARREGLN d message^GDE(gdeerr("VALTOOLONG"),$zwrite(REGION)_":"""_PARREGLN_""":"""_renpref_"region""") q
	. ; End from GDEPARSE
	. ; From GDEADD
	. i '$d(JSON("regions",REGION,"DYNAMIC_SEGMENT")) d message^GDE(gdeerr("QUALREQD"),"""Dynamic_segment""") q
	. ; End from GDEADD
	. m regs(REGION)=tmpreg
	. ; remove items that are invalid
	. k JSON("regions",REGION,"NAME")
	. s attr="" f  s attr=$o(JSON("regions",REGION,attr)) q:attr=""  d
	. . i '$l($g(JSON("regions",REGION,attr))) k JSON("regions",REGION,attr)
	. ; Now merge the the incoming region
	. m regs($tr(REGION,lower,upper))=JSON("regions",REGION)
	. ; uppercase the dynamic segment
	. s regs($tr(REGION,lower,upper),"DYNAMIC_SEGMENT")=$tr(regs($tr(REGION,lower,upper),"DYNAMIC_SEGMENT"),lower,upper)
	;
	; Segments:
	s SEGMENT="" f  s SEGMENT=$o(JSON("segments",SEGMENT)) q:SEGMENT=""  d
	. ; From GDEPARSE
	. ; make uppercase
	. k temp
	. m temp($tr(SEGMENT,lower,upper))=JSON("segments",SEGMENT)
	. k JSON("segments",SEGMENT)
	. m JSON("segments",$tr(SEGMENT,lower,upper))=temp($tr(SEGMENT,lower,upper))
	. s SEGMENT=$tr(SEGMENT,lower,upper)
	. ;
	. i '$zl(SEGMENT) d message^GDE(gdeerr("VALUEBAD"),$zwrite(SEGMENT)_":"""_renpref_"segment""") q
	. i $l(SEGMENT)'=$zl(SEGMENT) d message^GDE(gdeerr("NONASCII"),$zwrite(SEGMENT)_":""segment""")	q ; error if the name of the segment is non-ascii
	. i SEGMENT=defseg q
	. s x=$ze(SEGMENT) i x'?1A d message^GDE(gdeerr("PREFIXBAD"),$zwrite(SEGMENT)_":"""_renpref_"segment"_""":""name""") q
	. i $ze(SEGMENT,2,999)'?.(1AN,1"_",1"$") d message^GDE(gdeerr("VALUEBAD"),$zwrite(SEGMENT)_":""segment""") q
	. i $zl(SEGMENT)>PARSEGLN d message^GDE(gdeerr("VALTOOLONG"),$zwrite(SEGMENT)_":"""_PARSEGLN_""":"""_renpref_"segment""") q
	. ; End from GDEPARSE
	. ; From GDEADD
	. i '$d(JSON("segments",SEGMENT,"FILE_NAME")) d message^GDE(gdeerr("QUALREQD"),"""File""") q
	. i $g(JSON("segments",SEGMENT,"FILE_NAME"))="" d message^GDE(gdeerr("QUALREQD"),"""File""") q
	. ; End from GDEADD
	. i ($l($g(JSON("segments",SEGMENT,"ACCESS_METHOD")))),($d(tmpseg(JSON("segments",SEGMENT,"ACCESS_METHOD")))) m segs(SEGMENT)=tmpseg(JSON("segments",SEGMENT,"ACCESS_METHOD"))
	. e  d message^GDE(gdeerr("QUALREQD"),"""Access method""")
	. ; remove items that are invalid
	. k JSON("segments",SEGMENT,"NAME")
	. s attr="" f  s attr=$o(JSON("segments",SEGMENT,attr)) q:attr=""  d
	. . i '$l($g(JSON("segments",SEGMENT,attr))) k JSON("segments",SEGMENT,attr)
	. ; Now merge the incoming segment
	. m segs($tr(SEGMENT,lower,upper))=JSON("segments",SEGMENT)
	;
	; Template Access Methods:
	m tmpacc=JSON("template","accessMethod")
	;
	; Template Region:
	m tmpreg=JSON("template","region")
	;
	; Template Segment:
	m tmpseg=JSON("template","segment")
	;
	; Now verify it!
	i ('$g(gdewebquit))&($$ALL^GDEVERIF) s RSLT("verifyStatus")="true"
	e  s RSLT("verifyStatus")="false"
	m RSLT("errors")=gdeweberror
	d ENCODE^%webjson("RSLT","RESULT","ERR")
	i $d(ERR) D SETERROR^%webutils(201) quit ""
	quit ""
;
; =========================================================================
; Common functions
; =========================================================================
;
;
; Performs all of the required setup to execute global directory editor internal commands.
; Also sets up various error traps, etc.
;
;
setup
	n debug
	s debug=""
	; Based off of DBG^GDE
	; Save parent process context before GDE tampers with it for its own necessities.
	; Most of it is stored in the "gdeEntryState" local variable in subscripted nodes.
	; Exceptions are local collation related act,ncol,nct values which have to be stored in in unsubscripted
	; variables to prevent COLLDATAEXISTS error as part of the $$set^%LCLCOL below.
	n gdeEntryState,gdeEntryStateAct,gdeEntryStateNcol,gdeEntryStateNct
	s gdeEntryStateAct=$$get^%LCLCOL
	s gdeEntryStateNcol=$$getncol^%LCLCOL
	s gdeEntryStateNct=$$getnct^%LCLCOL
	; Set local collation to what GDE wants to operate. Errors while doing so will have to exit GDE right away.
	; Prepare special $etrap to issue error in case VIEW "YLCT" call to set local collation fails below
	; Need to use this instead of the gde $etrap (set a few lines later below) as that expects some initialization
	; to have happened whereas we are not yet there since setting local collation is a prerequisite for that init.
	s $et="w !,$p($zs,"","",3,999) s $ecode="""" d message^GDE(150503603,""""_$zparse(""$ydb_gbldir"","""",""*.gld"")_"""") s ^KBBOET=1 quit"
	; since GDE creates null subscripts, we don't want user level setting of gtm_lvnullsubs to affect us in any way
	s gdeEntryState("nullsubs")=$v("LVNULLSUBS")
	v "LVNULLSUBS"
	s gdeEntryState("zlevel")=$zlevel-1
	s gdeEntryState("io")=$io
	s $et=$s(debug:"b:$zs'[""%GDE""!allerrs  ",1:"")_"g:(""%GDE%NONAME""[$p($p($zs,"","",3),""-"")) SHOERR^GDE d ABORT^GDE"
	s io=$io,useio="io",comlevel=0,combase=$zl,resume(comlevel)=$zl_":INTERACT"
	i $$set^%PATCODE("M")
	s gdequiet=1
	; GDEINIT sets up required variables
	; GDEMSGIN sets up gdeerror map between text and zmessage number
	; GDFIND finds the global directory
	; CREATE/LOAD creates or reads the global directory
	d GDEINIT^GDEINIT,GDEMSGIN^GDEMSGIN,GDFIND^GDESETGD,CREATE^GDEGET:create,LOAD^GDEGET:'create
	s useio="io"
	s io=$io
	; Using the GDE Defaults isn't an error. Kill it so the webservices can move on
	i ($g(gdeweberror("count"))=1),gdeweberror(1)["%GDE-I-GDUSEDEFS" k gdeweberror
	quit
;
; This converts object properties from boolean true/false to integer 1/0
;
; @input object - gde object structure
booltoint(object)
	n REGION,SEGMENT,ITEM
	; There is nothing in names that would need to be converted
	s REGION="" f  s REGION=$o(object("regions",REGION)) q:REGION=""  d
	. s ITEM="" f ITEM="NULL_SUBSCRIPTS","STDNULLCOLL","JOURNAL","INST_FREEZE_ON_ERROR","QDBRUNDOWN","EPOCHTAPER","AUTODB","STATS","LOCK_CRIT_SEPARATE","BEFORE_IMAGE" d
	. . i $g(object("regions",REGION,ITEM))="true" s object("regions",REGION,ITEM)=1
	. . e  i $g(object("regions",REGION,ITEM))="false" s object("regions",REGION,ITEM)=0
	s SEGMENT="" f  s SEGMENT=$o(object("segments",SEGMENT)) q:SEGMENT=""  d
	. s ITEM="" f ITEM="ENCRYPTION_FLAG","DEFER_ALLOCATE","ASYNCIO" d
	. . i $g(object("segments",SEGMENT,ITEM))="true" s object("segments",SEGMENT,ITEM)=1
	. . e  i $g(object("segments",SEGMENT,ITEM))="false" s object("segments",SEGMENT,ITEM)=0
	quit
;
; This converts object properties from integer 1/0 to boolean true/false
;
; @input object - gde object structure
inttobool(object)
	n REGION,SEGMENT,ITEM
	; There is nothing in names that would need to be converted
	s REGION="" f  s REGION=$o(object("regions",REGION)) q:REGION=""  d
	. s ITEM="" f ITEM="NULL_SUBSCRIPTS","STDNULLCOLL","JOURNAL","INST_FREEZE_ON_ERROR","QDBRUNDOWN","EPOCHTAPER","AUTODB","STATS","LOCK_CRIT_SEPARATE","BEFORE_IMAGE" d
	. . i $g(object("regions",REGION,ITEM))=1 s object("regions",REGION,ITEM)="true"
	. . e  i $g(object("regions",REGION,ITEM))=0 s object("regions",REGION,ITEM)="false"
	s SEGMENT="" f  s SEGMENT=$o(object("segments",SEGMENT)) q:SEGMENT=""  d
	. s ITEM="" f ITEM="ENCRYPTION_FLAG","DEFER_ALLOCATE","ASYNCIO" d
	. . i $g(object("segments",SEGMENT,ITEM))=1 s object("segments",SEGMENT,ITEM)="true"
	. . e  i $g(object("segments",SEGMENT,ITEM))=0 s object("segments",SEGMENT,ITEM)="false"
	quit
;
; =========================================================================
; Internal line tags below...
; =========================================================================
;
; This calculates the display names. It is copied from GDESHOW and modified to move results to map2
;
; @input map - Global Directory map information
;
mapdispcalc:
	n coll,gblname,isplusplus,m,mapdisplen,mlen,mprev,mtmp,name,namedisp,namelen,offset
	s m=""
	f  s mprev=m,m=$o(map(m)) q:'$zl(m)  d
	. i $l(mapreg),(mapreg'=map(m)),('$zl(mprev)!(mapreg'=map(mprev))) q
	. s offset=$zfind(m,ZERO,0)
	. i offset=0  s mapdisp(m)=$tr(m,")","0") q  ; no subscripts case. finish it off first
	. s gblname=$ze(m,1,offset-2),coll=+$g(gnams(gblname,"COLLATION")),mlen=$zl(m)
	. s isplusplus=$$isplusplus^GDEMAP(m,mlen)
	. s mtmp=$s(isplusplus:$ze(m,1,mlen-1),1:m)  ; if ++ type map entry, remove last 01 byte before converting it into gvn
	. s name=$zcollate(mtmp_ZERO_ZERO,coll,1)
	. i isplusplus s name=name_"++"
	. s namelen=$zl(name),name=$ze(name,2,namelen) ; remove '^' at start of name
	. s namedisp=$$namedisp(name,0)
	. s mapdisp(m)=namedisp,mapdisplen=$zwidth(namedisp)
	. i mapdispmaxlen<mapdisplen s mapdispmaxlen=mapdisplen
	quit
;
; Convert passed name to a name that is displayable (i.e. if it contains control characters, they are replaced by $c() etc.)
; (called from mapdispcalc and onemap)
;
; @param {Array} name - Name from map data to convert to display name
; @param {Integer} addquote - 0 = no surrounding double-quotes are added. 1 = when control characters are seen (e.g. $c(...)) return
;                                 the name with double-quotes
; @returns {String} - Display name of passed name
;
namedisp:(name,addquote)
	; returns a
	n namezwrlen,namezwr,namedisplen,namedisp,ch,quotestate,starti,i,seenquotestate3,doublequote
	s namezwr=$zwrite(name) ; this will convert all control characters to $c()/$zc() notation
	; But $zwrite will introduce more double-quotes than we want to display; so remove them
	; e.g. namezwr = "MODELNUM("""_$C(0)_""":"""")"
	s namezwrlen=$zl(namezwr),namedisp="",doublequote=""""
	s namedisp="",namedisplen=0,quotestate=0
	f i=1:1:namezwrlen  s ch=$ze(namezwr,i) d
	. i (quotestate=0) d  q
	. . i (ch=doublequote) s quotestate=1,starti=i+1  q
	. . ; We expect ch to be "$" here
	. . s quotestate=3
	. i (quotestate=1) d  q
	. . i ch'=doublequote q
	. . s quotestate=2  s namedisp=namedisp_$ze(namezwr,starti,i-1),namedisplen=namedisplen+(i-starti),starti=i+1 q
	. i (quotestate=2) d  q
	. . ; At this point ch can be either doublequote or "_"
	. . s quotestate=$s(ch=doublequote:1,1:0)
	. . i ch="_" d  q
	. . . i (($ze(namedisp,namedisplen)'=doublequote)!($ze(namedisp,namedisplen-1)=doublequote)) d  q
	. . . . s starti=(i-1) ; include previous double-quote
	. . . ; remove extraneous ""_ before $c()
	. . . s namedisp=$ze(namedisp,1,namedisplen-1),namedisplen=namedisplen-1,starti=i+1
	. i (quotestate=3) d  q
	. . s seenquotestate3=1
	. . i (ch=doublequote) s quotestate=1 q
	. . i ((ch="_")&($ze(namezwr,i+1,i+3)=(doublequote_doublequote_doublequote))&($ze(namezwr,i+4)'=doublequote))  d  q
	. . . ; remove extraneous _"" after $c()
	. . . s namedisp=namedisp_$ze(namezwr,starti,i-1),namedisplen=namedisplen+(i-starti),starti=i+4,quotestate=1,i=i+3 q
	i addquote&$d(seenquotestate3) s namedisp=doublequote_namedisp_doublequote
	; 2 and 3 are the only terminating states; check that. that too 3 only if addquote is 1.
	; ASSERT : i '((quotestate=2)!(addquote&(quotestate=3))) s $etrap="zg 0" zsh "*"  zhalt 1
	q namedisp
;
; Convert the map data into displayable format in map2
;
; @input {Array} map - Global Directory map data
; @param {Array} s1 - Start of range
; @param {Array/Object} s2 - End of range
; @output {Array} map2 - Global Directory map data in displyable format
;
onemap:(s1,s2)
	i $l(mapreg),mapreg'=map(s2) quit
	s l1=$zl(s1)
	i $zl(s2)=l1,$ze(s1,l1)=0,$ze(s2,l1)=")",$ze(s1,1,l1-1)=$ze(s2,1,l1-1) quit
	i '$d(mapdisp(s1)) s mapdisp(s1)=s1 ; e.g. "..." or "LOCAL LOCKS"
	i '$d(mapdisp(s2)) s mapdisp(s2)=s2 ; e.g. "..." or "LOCAL LOCKS"
	s map2(index,"from")=mapdisp(s2)
	s map2(index,"to")=mapdisp(s1)
	s map2(index,"region")=map(s2)
	i '$d(regs(map(s2),"DYNAMIC_SEGMENT")) d  quit
	. s map2(index,"segment")="NONE"
	. s map2(index,"file")="NONE"
	s j=regs(map(s2),"DYNAMIC_SEGMENT") s map2(index,"segment")=j
	i '$d(segs(j,"ACCESS_METHOD")) s map2(index,"file")="NONE"
	e  s s=segs(j,"FILE_NAME") s map2(index,"file")=$$namedisp(s,1)
	quit
;
; Convert a given name string into a parsed array that contains all of the data needed to work with other GDE APIs
; This is copied from tokscan^GDESCAN and modified to be silent and work with passed data
;
; @param {Array} name - name to convert
; @output {Array} NAME - Parsed name in format understandable by other GDE APIs
;
createnamearray(name)
	n i,c,NAMEsubs,NAMEtype,cp,ntoken
	s cp=1
	; About to parse the token following a -name. Take double-quotes into account.
	; Any delimiter that comes inside a double-quote does NOT terminate the scan/parse.
	; Implement the following DFA (Deterministic Finite Automaton)
	;	  State 0 --> next char is     a double-quote --> State 1
	;	  State 0 --> next char is NOT a double-quote --> State 0
	;	  State 1 --> next char is     a double-quote --> State 2
	;	  State 1 --> next char is NOT a double-quote --> State 1
	;	  State 2 --> next char is     a double-quote --> State 1
	;	  State 2 --> next char is NOT a double-quote --> State 0
	; Also note down (in NAMEsubs) the columns where LPAREN, COMMA and COLON appear. Later used in NAME^GDEPARSE
	n quotestate,parenstate,errstate,quitloop
	s quotestate=0,parenstate=0,errstate=""
	k NAMEsubs ; this records the column where subscript delimiters COMMA or COLON appear in the name specification
	k NAMEtype
	s NAMEtype="POINT",NAMEsubs=0,quitloop=0
	f i=0:1 s c=$ze(name,cp+i) q:(c="")  d  q:quitloop
	. i c="""" s quotestate=$s(quotestate=1:2,1:1)
	. e        s quotestate=$s(quotestate=2:0,1:quotestate) i 'quotestate d
	. . i $data(delim(c)) s quitloop=1 q
	. . i (parenstate=2) i '$zl(errstate) s errstate="NAMRPARENNOTEND"
	. . i (c="(") d
	. . . i parenstate s parenstate=parenstate+2  q   ; nested parens
	. . . s parenstate=1
	. . . s NAMEsubs($incr(NAMEsubs))=(i+2)
	. . i (c=",") d
	. . . i 'parenstate i '$zl(errstate) s errstate="NAMLPARENNOTBEG"
	. . . i (1'=parenstate) q   ; nested parens
	. . . i NAMEtype="RANGE" i '$zl(errstate) s errstate="NAMRANGELASTSUB"
	. . . s NAMEsubs($incr(NAMEsubs))=(i+2)
	. . i c=":" d
	. . . i 'parenstate i '$zl(errstate) s errstate="NAMLPARENNOTBEG"
	. . . i NAMEtype="RANGE" i '$zl(errstate) s errstate="NAMONECOLON"
	. . . s NAMEsubs($incr(NAMEsubs))=(i+2),NAMEtype="RANGE"
	. . i c=")" d
	. . . i 'parenstate i '$zl(errstate) s errstate="NAMLPARENNOTBEG"
	. . . i (1'=parenstate) s parenstate=parenstate-2 q   ; nested parens
	. . . s parenstate=2
	. . . s NAMEsubs($incr(NAMEsubs))=(i+2)
	i quotestate i '$zl(errstate) s errstate="STRMISSQUOTE"
	i (1=parenstate)!(2<parenstate) i '$zl(errstate) s errstate="NAMRPARENMISSING"
	i $zl(errstate) d message^GDE(gdeerr(errstate),""""_$ze(name,cp,cp+i-1)_"""")
	i 'NAMEsubs s NAMEsubs($incr(NAMEsubs))=i+2
	i c="" d
	. ; check if tail of last token in line contains $c(13,10) and if so remove it
	. ; this keeps V61 GDE backward compatible with V60 GDE
	. n j
	. f j=1:1 s c=$ze(name,cp+i-j) q:($c(10)'=c)&($c(13)'=c)
	. s i=i-j+1
	s ntoken=$ze(name,cp,cp+i-1),cp=cp+i
	; NAME from GDEPARSE
	n c,len,j,k,starti,endi,subcnt,gblname,rangeprefix,nullsub,lsub,sub
	i "%Y"=$ze(name,1,2) d message^GDE(gdeerr("NOPERCENTY"))
	i (MAXGVSUBS<(NAMEsubs-1-$select(NAMEtype="RANGE":1,1:0))) d message^GDE(gdeerr("NAMGVSUBSMAX"),"""name"":"""_MAXGVSUBS_"")
	; parse subscripted name (potentially with ranges) to ensure individual pieces are well-formatted
	; One would be tempted to use $NAME to do automatic parsing of subscripts for well-formedness, but there are issues
	; with it. $NAME does not issue error in various cases (unsubscripted global name longer than 31 characters,
	; numeric subscript mantissa more than 18 digits etc.). And since we want these cases to error out as well, we parse
	; the subscript explicitly below.
	s len=$zl(name)
	s j=$g(NAMEsubs(1))
	s gblname=$ze(name,1,j-2)
	s NAME=gblname
	i $l(NAME)'=$zl(NAME) d message^GDE(gdeerr("NONASCII"),"""NAME"":"""_name_"")	; error if the name is non-ascii
	s NAME("SUBS",0)=gblname
	i $ze(gblname,j-2)="*" s NAMEtype="STAR"
	s NAME("TYPE")=NAMEtype
	i ("*"'=gblname)&(gblname'?1(1"%",1A).AN.1"*") d message^GDE(gdeerr("VALUEBAD"),""""_gblname_""":""name""")
	i (j-2)>PARNAMLN d message^GDE(gdeerr("VALTOOLONG"),""""_gblname_""":"""_PARNAMLN_""":""name""")
	i j=(len+2) s NAME("NSUBS")=0 q  ; no subscripts to process. done.
	; have subscripts to process
	i NAMEtype="STAR" d message^GDE(gdeerr("NAMSTARSUBSMIX"),""""_name_"""")
	i $ze(name,len)'=")" d message^GDE(gdeerr("NAMENDBAD"),""""_name_"""")
	s NAME=NAME_"("
	s nullsub=""""""
	f subcnt=1:1:NAMEsubs-1 d
	. s k=NAMEsubs(subcnt+1)
	. s sub=$ze(name,j,k-2)
	. i (sub="") d
	. . ; allow empty subscripts only on left or right side of range
	. . i (NAMEtype="RANGE") d
	. . . i (subcnt=(NAMEsubs-2)) s sub=nullsub q  ; if left  side of range is empty, replace with null subscript
	. . . i (subcnt=(NAMEsubs-1)) s sub=nullsub q  ; if right side of range is empty, replace with null subscript
	. i (sub="") d message^GDE(gdeerr("NAMSUBSEMPTY"),""""_subcnt_"""") ; null subscript
	. s c=$ze(sub,1)
	. i (c="""")!(c="$") set sub=$$STRSUB^GDEPARSE(sub,subcnt)	; string subscript
	. e  set sub=$$numsub^GDEPARSE(sub,subcnt)			; numeric subscript
	. i (NAMEtype="RANGE")&(subcnt=(NAMEsubs-2)) s rangeprefix=NAME,lsub=sub
	. s NAME("SUBS",subcnt)=sub,NAME=NAME_sub,j=k
	. s NAME=NAME_$s(subcnt=(NAMEsubs-1):")",(NAMEtype="RANGE")&(subcnt=(NAMEsubs-2)):":",1:",")
	s NAME("NSUBS")=NAMEsubs-1,NAME("NAME")=NAME
	i NAMEtype="RANGE" d
	. ; check if both subscripts are identical; if so morph the RANGE subscript into a POINT type.
	. ; the only exception is if the range is of the form <nullsub>:<nullsub>. In this case, it is actually a range
	. ; meaning every possible value in that subscript.
	. i ((NAME("SUBS",NAMEsubs-1)=lsub)&(lsub'=nullsub)) d  q
	. . s NAME("NAME")=rangeprefix_lsub_")",NAME("NSUBS")=NAMEsubs-2,NAME("TYPE")="POINT",NAME=NAME("NAME")
	. . k NAME("SUBS",NAMEsubs-1)
	. s NAME("GVNPREFIX")=rangeprefix	; subscripted gvn minus the last subscript
	. ; note the below (which does out-of-order check) also does the max-key-size checks for both sides of the range
	. d namerangeoutofordercheck^GDEPARSE(.NAME,+$g(gnams(gblname,"COLLATION")))
	e  d
	. ; ensure input NAME is within maximum key-size given current gblname value of collation
	. n coll,key
	. s coll=+$g(gblname,"COLLATION")
	. s key=$$gvn2gds^GDEMAP("^"_NAME,coll)
	. d keylencheck^GDEPARSE(NAME,key,coll)
	quit
