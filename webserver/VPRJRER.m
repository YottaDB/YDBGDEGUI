
VPRJRER ;SLC/KCM -- Error Recording
 ;;1.0;JSON DATA STORE;;Sep 01, 2012
 ;
SETERROR(ERRCODE,MESSAGE) ; set error info into ^TMP("HTTPERR",$J)
 ; causes HTTPERR system variable to be set
 ; ERRCODE:  M errors are 500
 ; MESSAGE:  additional explanatory material
 N NEXTERR,ERRNAME,TOPMSG
 S HTTPERR=400,TOPMSG="Bad Request"
 ; JSON errors (200-299)
 I ERRCODE=200 S ERRNAME="Unable to decode JSON"
 E  I ERRCODE=201 S ERRNAME="Unable to encode JSON"
 ; Generic Errors
 E  I ERRCODE=301 S ERRNAME="Required variable undefined"
 ; HTTP errors
 E  I ERRCODE=400 S ERRNAME="Bad Request"
 E  I ERRCODE=404 S ERRNAME="Not Found"
 E  I ERRCODE=405 S ERRNAME="Method Not Allowed"
 ; system errors (500-599)
 E  I ERRCODE=501 S ERRNAME="M execution error"
 E  I ERRCODE=502 S ERRNAME="Unable to lock record"
 E  I '$L($G(ERRNAME)) S ERRNAME="Unknown error"
 ;
 I ERRCODE>500 S HTTPERR=500,TOPMSG="Internal Server Error"  ; M Server Error
 I ERRCODE<500,ERRCODE>400 S HTTPERR=ERRCODE,TOPMSG=ERRNAME  ; Other HTTP Errors
 S NEXTERR=$G(^TMP("HTTPERR",$J,0),0)+1,^TMP("HTTPERR",$J,0)=NEXTERR
 S ^TMP("HTTPERR",$J,1,"apiVersion")="1.0"
 S ^TMP("HTTPERR",$J,1,"error","code")=HTTPERR
 S ^TMP("HTTPERR",$J,1,"error","message")=TOPMSG
 S ^TMP("HTTPERR",$J,1,"error","request")=$G(HTTPREQ("method"))_" "_$G(HTTPREQ("path"))_" "_$G(HTTPREQ("query"))
 S ^TMP("HTTPERR",$J,1,"error","errors",NEXTERR,"reason")=ERRCODE
 S ^TMP("HTTPERR",$J,1,"error","errors",NEXTERR,"message")=ERRNAME
 I $L($G(MESSAGE)) S ^TMP("HTTPERR",$J,1,"error","errors",NEXTERR,"domain")=MESSAGE
 Q
