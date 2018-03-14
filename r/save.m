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
handle()
	;
	new payload,push,status,postid,i

	; Support POST method only
	quit:'$$methodis^request("PUT",1)
	
	set status=$$decode^json(request("content"),"push")
  
  ; This is actually where you do processing, like creating a GDE file

  new responseObj,responseStr,verifySaveStatus
  new nams,regs,segs,tmpacc,tmpreg,tmpseg,minreg,maxreg,minseg,maxseg
  merge nams=push("nams") ;NOTE: the object sent from the client doesn't contain the nams/regs/segs count component stored in the unsubscripted spot
                          ;i.e. while GDE has locals like nams=2, regs=2, segs=1 storing the num of names/regions/segments, the client doesn't send that data back
                          ;after changes on the client side which may change those numbers
  merge regs=push("regs")
  merge segs=push("segs")
  merge tmpacc=push("tmpacc")
  merge tmpreg=push("tmpreg")
  merge tmpseg=push("tmpseg")
  merge gnams=push("gnams")
  merge create=push("create")
  merge file=push("file")
  merge useio=push("useio") ;2018-03 AKB - do I need to pass this between the client and server? looks like it's just "io"
  merge debug=push("debug")
  do GDEINIT^GDEINIT
  do GDEMSGIN^GDEMSGIN
  i $$ALL^GDEVERIF do  
  . do ^sstep
  . i $$GDEPUT^GDEPUT do  
  . . s verifySaveStatus="success"
  . . ;
  . . ; new $etrap
  . . ; set $etrap="zshow ""*"":mysavetrap"
  . . ; do DUMP^GDE(.getMapData)
  . . ;
  . . ;
  . . ;Similar to what happens in the getmap route - should they be refactored?
  . . ;
  . . ;kill getMapData
  . . ;merge getMapData("nams")=nams
  . . ;merge getMapData("regs")=regs
  . . ;merge getMapData("segs")=segs
  e  s verifySaveStatus="failure",getMapData="" ;null value instead of empty string for getMapData?
  ;do GETOUT^GDEEXIT ;this ends with a zgoto 0? - how to properly get out of gde? gdeentrystate being saved properly?
  set responseObj("verifySaveStatus")=verifySaveStatus
  merge responseObj("getMapData")=getMapData
  set responseStr=$$encode^json("responseObj")
  if $ZJOBEXAM() ;DEBUG -remove

  ; This is a reply. You can just say 201 created in the status and be done.
	if status=0 do
	.	do addcontent^response(responseStr)
	else  do addcontent^response("Sorry... :(")

	; Set content-type here as nobody really care for the response anyway, I think...
	set response("headers","Content-Type")="application/json"

	; No cache for this.
	set response("headers","Cache-Control")="no-cache"

	; Get md5sum of the generated content.
	do md5sum^response()

	; Validate the cache
	do validatecache^request()

	quit
