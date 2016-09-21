/* .............................................................................

Alterações:  03/11/2008 - Inclusao widget-pool (martin)

............................................................................. */

&ANALYZE-SUSPEND _VERSION-NUMBER WDT_v2r1 Web-Object
/* Maps: wpgd0011a.htm */
&ANALYZE-RESUME
&ANALYZE-SUSPEND _CODE-BLOCK _CUSTOM Definitions 
/*------------------------------------------------------------------------

  File: 

  Description: 

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author: 

  Created: 

------------------------------------------------------------------------*/
/*           This .W file was created with WebSpeed Workshop.           */
/*----------------------------------------------------------------------*/

create widget-pool.

/* ***************************  Definitions  ************************** */

/* Preprocessor Definitions ---                                         */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
def var v-ok as log no-undo.

DEFINE VARIABLE conteudo-aux AS CHARACTER.
DEFINE VARIABLE conta AS INTEGER.
&ANALYZE-RESUME
&ANALYZE-SUSPEND _PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object

&Scoped-define WEB-FILE wpgd0011a.htm

/* Default preprocessor names. */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS basebusca campo1 campo2 campo3 caux conteudo1 conteudo2 conteudo3 retorno1 retorno2 retorno3 solicitante 
&Scoped-Define DISPLAYED-OBJECTS basebusca campo1 campo2 campo3 caux conteudo1 conteudo2 conteudo3 retorno1 retorno2 retorno3 solicitante 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _FORM-BUFFER


/* Definitions of the field level widgets                               */
DEFINE VARIABLE basebusca AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE campo1 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE campo2 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE campo3 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE caux AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE conteudo1 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE conteudo2 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE conteudo3 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE retorno1 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE retorno2 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE retorno3 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE solicitante AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     basebusca SKIP
     campo1 SKIP
     campo2 SKIP
     campo3 SKIP
     caux SKIP
     conteudo1 SKIP
     conteudo2 SKIP
     conteudo3 SKIP
     retorno1 SKIP
     retorno2 SKIP
     retorno3 SKIP
     solicitante SKIP
    WITH NO-LABELS.

 

&ANALYZE-RESUME

/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

&ANALYZE-SUSPEND _INCLUDED-LIBRARIES
/* Included Libraries --- */

{src/web/method/html-map.i}
&ANALYZE-RESUME _END-INCLUDED-LIBRARIES

&ANALYZE-SUSPEND _CODE-BLOCK _CUSTOM "Main Code Block" 


/* ************************  Main Code Block  ************************* */

/* 
 * Standard Main Code Block. This dispatches two events:
 *   'initialize'
 *   'process-web-request'
 * The bulk of the web processing is in the procedure 'process-web-request'
 * elsewhere in this Web object.
 */
{src/web/template/hmapmain.i}
&ANALYZE-RESUME
/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _CODE-BLOCK _PROCEDURE htm-offsets _WEB-HTM-OFFSETS
PROCEDURE htm-offsets :
/*------------------------------------------------------------------------------
  Purpose:     Runs procedure to associate each HTML field with its
               corresponding widget name and handle.
  Parameters:  
  Notes:       
------------------------------------------------------------------------------*/
  RUN web/support/rdoffr.p ("{&WEB-FILE}":U).
  RUN htm-associate IN THIS-PROCEDURE
    ("basebusca":U,"basebusca":U,basebusca:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("campo1":U,"campo1":U,campo1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("campo2":U,"campo2":U,campo2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("campo3":U,"campo3":U,campo3:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("caux":U,"caux":U,caux:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("conteudo1":U,"conteudo1":U,conteudo1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("conteudo2":U,"conteudo2":U,conteudo2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("conteudo3":U,"conteudo3":U,conteudo3:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("retorno1":U,"retorno1":U,retorno1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("retorno2":U,"retorno2":U,retorno2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("retorno3":U,"retorno3":U,retorno3:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("solicitante":U,"solicitante":U,solicitante:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.

&ANALYZE-RESUME
&ANALYZE-SUSPEND _CODE-BLOCK _PROCEDURE output-header 
PROCEDURE output-header :
/*------------------------------------------------------------------------
  Purpose:     Output the MIME header, and any "cookie" information needed 
               by this procedure.  
  Parameters:  <none>
  Notes:       In the event that this Web object is State-Aware, this is also
               a good place to set the "Web-State" and "Web-Timeout" 
               attributes.              
------------------------------------------------------------------------*/
   
   output-content-type ("text/html":U).
  
END PROCEDURE.
&ANALYZE-RESUME
&ANALYZE-SUSPEND _CODE-BLOCK _PROCEDURE process-web-request 
PROCEDURE process-web-request :
/*------------------------------------------------------------------------
  Purpose:     Process the web request.
  Notes:       
------------------------------------------------------------------------*/
     
  RUN output-header.
  RUN dispatch IN THIS-PROCEDURE ('input-fields':U).
  RUN dispatch IN THIS-PROCEDURE ('assign-fields':U).

  CASE basebusca:
      WHEN "nrdconta" THEN
      DO:
          /*FIND FIRST crapass WHERE crapass.nrdconta = INT(conteudo1) NO-LOCK NO-ERROR.*/
          FIND FIRST crapttl WHERE
                     crapttl.cdcooper = INT(conteudo3) AND
                     crapttl.nrdconta = INT(conteudo1) AND
                     crapttl.idseqttl = INT(conteudo2) NO-LOCK NO-ERROR.

          IF AVAIL crapttl THEN
             DO:
                FIND FIRST crapass WHERE crapass.nrdconta = crapttl.nrdconta AND
                                         crapass.cdcooper = crapttl.cdcooper NO-LOCK NO-ERROR.
                ASSIGN retorno1 = crapttl.nmextttl
                       retorno2 = IF AVAIL crapass THEN STRING(crapass.cdagenci) ELSE ""
                       retorno3 = IF AVAIL crapass THEN STRING(crapass.cdcooper) ELSE "".
             END.
          ELSE
             DO:
                 ASSIGN retorno1 = "* * * ASSOCIADO NAO ENCONTRADO * * *"
                        retorno2 = ""
                        retorno3 = conteudo3.
             END.
      END.
  END CASE.             
  RUN dispatch IN THIS-PROCEDURE ('display-fields':U).    
  RUN dispatch IN THIS-PROCEDURE ('enable-fields':U).
  RUN dispatch IN THIS-PROCEDURE ('output-fields':U).
END PROCEDURE.
&ANALYZE-RESUME
