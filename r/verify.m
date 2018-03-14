;								
; Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	
; All rights reserved.						
;								
;	This source code contains the intellectual property	
;	of its copyright holder(s), and is made available	
;	under a license.  If you do not know the terms of	
;	the license, please stop and do not read further.	
;	

verify ;;verify the GDE locals sent from the client as valid/invalid
handle(ARGS,BODY,RESULT)
 ;
 NEW JSON,RSLT,ERR,nams,regs,segs,tmpacc,tmpreg,tmpseg,minreg,maxreg,minseg,maxseg
 D DECODE^VPRJSON("BODY","JSON","ERR")
 ; NOTE: the object sent from the client doesn't contain the nams/regs/segs count component stored in the unsubscripted spot
 ; i.e. while GDE has locals like nams=2, regs=2, segs=1 storing the num of names/regions/segments, the client doesn't send that data back
 ; after changes on the client side which may change those numbers
 M nams=JSON("nams")
 M regs=JSON("regs")
 M segs=JSON("segs")
 M tmpacc=JSON("tmpacc")
 M tmpreg=JSON("tmpreg")
 M tmpseg=JSON("tmpseg")
 M gnams=JSON("gnams") ;AKB 2018-03 not 100% sure if this data is necessary
 D GDEINIT^GDEINIT
 D GDEMSGIN^GDEMSGIN
 I $$ALL^GDEVERIF S RSLT("verifyStatus")="success"
 E  S RSLT("verifyStatus")="failure"
 D ENCODE^VPRJSON("RSLT","RESULT","ERR")
 QUIT RESULT(1) 
