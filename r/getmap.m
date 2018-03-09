;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017,2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

getmap ;;2017-12-21
handle(RESULT,ARGS)
 N DATA,JSON,ERR
 D DUMP^GDE(.DATA)
 ; remove top level counts from names, regs, and segs
 ; the JSON encoder won't encode the data in the subscripts below if
 ; there is a vaule set at a parent subscript
 ZK DATA("nams"),DATA("regs"),DATA("segs")
 ZK DATA("tmpseg","BG"),DATA("tmpseg","MM")
 m ^KBBO("getmap")=DATA
 D ENCODE^VPRJSON("DATA","JSON","ERR")
 I $D(ERR) D SETERROR^VPRJRUT("500","Error in JSON conversion") QUIT
 M RESULT=JSON
 QUIT

