	;								
	; Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	
	; All rights reserved.						
	;								
	;	This source code contains the intellectual property	
	;	of its copyright holder(s), and is made available	
	;	under a license.  If you do not know the terms of	
	;	the license, please stop and do not read further.	
	;	

save ;;save the new GDE local state obtained from the client
handle(ARGS,BODY,RESULT)
  ;
  new JSON,RSLT,ERR
  do DECODE^VPRJSON("BODY","JSON","ERR")
  new verifySaveStatus
  new nams,regs,segs,tmpacc,tmpreg,tmpseg,gnams,create,file,useio,debug,io
  merge nams=JSON("nams") ;NOTE: the object sent from the client doesn't contain the nams/regs/segs count component stored in the unsubscripted spot
                          ;i.e. while GDE has locals like nams=2, regs=2, segs=1 storing the num of names/regions/segments, the client doesn't send that data back
                          ;after changes on the client side which may change those numbers
  ;convert all region data in nams to uppercase - should be enforced client-side, but this is for safety
  set x="" for  set x=$order(nams(x)) quit:x=""  set nams(x)=$$FUNC^%UCASE(nams(x))
  merge regs=JSON("regs")
  ;convert all first-level subscripts of regs to uppercase - they should already all be uppercase (enforced on client side), but this is for safety
  set next=$order(regs("")) for  set x=next quit:x=""  do
  . set next=$order(regs(x))
  . kill temp
  . merge temp=regs(x)
  . set temp("DYNAMIC_SEGMENT")=$$FUNC^%UCASE(temp("DYNAMIC_SEGMENT")) ;part of converting all segments to uppercase
  . kill regs(x)
  . merge regs($$FUNC^%UCASE(x))=temp
  ;if $ZJOBEXAM() ;DEBUG - TODO remove; this line not getting hit when re-saving unmodified default directory - why?
  merge segs=JSON("segs")
  ;convert all first-level subscripts of segs to uppercase - they should already all be uppercase (enforced on client side), but this is for safety
  set next=$order(segs("")) for  set x=next quit:x=""  do
  . set next=$order(segs(x))
  . kill temp
  . merge temp=segs(x)
  . kill segs(x)
  . merge segs($$FUNC^%UCASE(x))=temp
  merge tmpacc=JSON("tmpacc")
  merge tmpreg=JSON("tmpreg")
  merge tmpseg=JSON("tmpseg")
  merge gnams=JSON("gnams")
  merge create=JSON("create")
  merge file=JSON("file")
  merge useio=JSON("useio") ;2018-03 AKB - do I need to pass this between the client and server? looks like it's just "io"
  merge debug=JSON("debug")
  merge io=JSON("io")
  do GDEINIT^GDEINIT
  do GDEMSGIN^GDEMSGIN
  i $$ALL^GDEVERIF,$$GDEPUT^GDEPUT do  
  . s verifySaveStatus="success"
  . ;
  . ; new $etrap
  . ; set $etrap="zshow ""*"":mysavetrap"
  . ; do DUMP^GDE(.getMapData)
  . ;
  . ;
  . ;Similar to what happens in the getmap route - should they be refactored?
  . ;
  . kill getMapData
  . merge getMapData("nams")=nams
  . merge getMapData("regs")=regs
  . merge getMapData("segs")=segs
  . ;TODO test that name/region transformations on the server are properly captured by these merges
  . ;TODO handling lowercase regs and segs, nams that map to lowercase regs
  . ;set getMapData=""
  e  s verifySaveStatus="failure",getMapData="" ;null value instead of empty string for getMapData?
  ;do GETOUT^GDEEXIT ;this ends with a zgoto 0? - how to properly get out of gde? gdeentrystate being saved properly?
  set RSLT("verifySaveStatus")=verifySaveStatus
  merge RSLT("getMapData")=getMapData
  kill ^ashokvar merge ^ashokvar=RSLT("getMapData") ;DEBUG remove
  do ENCODE^VPRJSON("RSLT","RESULT","ERR")
  kill ^ashokvar merge ^ashokvar=RESULT ;DEBUG remove
  quit ""
