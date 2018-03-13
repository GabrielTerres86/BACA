/* .............................................................................

Alterações:  03/11/2008 - Inclusao widget-pool (martin)

............................................................................. */

&ANALYZE-SUSPEND _VERSION-NUMBER WDT_v2r1 Web-Object
/* Maps: wpgd0017a.htm */
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

&Scoped-define WEB-FILE wpgd0017a.htm

/* Default preprocessor names. */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS basebusca campo1 campo2 campo3 campo4 campo5 caux conteudo1 conteudo2 conteudo3 conteudo4 conteudo5 retorno1 retorno2 retorno3 retorno4 retorno5 retorno6 retorno7 retorno8 retorno9 retorno10 retorno11 retorno12 solicitante campo6 campo7 campo8 campo9 campo10 conteudo6 conteudo7 conteudo8 conteudo9 conteudo10
&Scoped-Define DISPLAYED-OBJECTS basebusca campo1 campo2 campo3 campo4 campo5 caux conteudo1 conteudo2 conteudo3 conteudo4 conteudo5 retorno1 retorno2 retorno3 retorno4 retorno5 retorno6 retorno7 retorno8 retorno9 retorno10 retorno11 retorno12 solicitante campo6 campo7 campo8 campo9 campo10 conteudo6 conteudo7 conteudo8 conteudo9 conteudo10

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _FORM-BUFFER

DEFINE TEMP-TABLE tt-valores
      FIELD cdagenci AS CHAR
      FIELD valor    AS CHAR
      FIELD percent  AS CHAR. 


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

DEFINE VARIABLE campo4 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE campo5 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE campo6 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE campo7 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE campo8 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE campo9 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE campo10 AS CHARACTER FORMAT "x(256)":U 
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

DEFINE VARIABLE conteudo4 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE conteudo5 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE conteudo6 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE conteudo7 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE conteudo8 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE conteudo9 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE conteudo10 AS CHARACTER FORMAT "x(256)":U 
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

DEFINE VARIABLE retorno4 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE retorno5 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE retorno6 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE retorno7 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE retorno8 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE retorno9 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE retorno10 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE retorno11 AS CHARACTER FORMAT "x(256)":U 
     VIEW-AS FILL-IN
     SIZE 20 BY 1 NO-UNDO.

DEFINE VARIABLE retorno12 AS CHARACTER FORMAT "x(256)":U 
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
     campo4 SKIP
     campo5 SKIP
     campo6 SKIP
     campo7 SKIP
     campo8 SKIP
     campo9 SKIP
     campo10 SKIP
     caux SKIP
     conteudo1 SKIP
     conteudo2 SKIP
     conteudo3 SKIP
     conteudo4 SKIP
     conteudo5 SKIP
     conteudo6 SKIP
     conteudo7 SKIP
     conteudo8 SKIP
     conteudo9 SKIP
     conteudo10 SKIP
     retorno1 SKIP
     retorno2 SKIP
     retorno3 SKIP
     retorno4 SKIP
     retorno5 SKIP
     retorno6 SKIP
     retorno7 SKIP
     retorno8 SKIP
     retorno9 SKIP
     retorno10 SKIP
     retorno11 SKIP
     retorno12 SKIP
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
    ("campo4":U,"campo4":U,campo4:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("campo5":U,"campo5":U,campo5:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("campo6":U,"campo6":U,campo6:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("campo7":U,"campo7":U,campo7:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("campo8":U,"campo8":U,campo8:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("campo9":U,"campo9":U,campo9:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("campo10":U,"campo10":U,campo10:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("caux":U,"caux":U,caux:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("conteudo1":U,"conteudo1":U,conteudo1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("conteudo2":U,"conteudo2":U,conteudo2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("conteudo3":U,"conteudo3":U,conteudo3:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("conteudo4":U,"conteudo4":U,conteudo4:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("conteudo5":U,"conteudo5":U,conteudo5:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("conteudo6":U,"conteudo6":U,conteudo6:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("conteudo7":U,"conteudo7":U,conteudo7:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("conteudo8":U,"conteudo8":U,conteudo8:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("conteudo9":U,"conteudo9":U,conteudo9:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("conteudo10":U,"conteudo10":U,conteudo10:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("retorno1":U,"retorno1":U,retorno1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("retorno2":U,"retorno2":U,retorno2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("retorno3":U,"retorno3":U,retorno3:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("retorno4":U,"retorno4":U,retorno4:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("retorno5":U,"retorno5":U,retorno5:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("retorno6":U,"retorno6":U,retorno6:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("retorno7":U,"retorno7":U,retorno7:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("retorno8":U,"retorno8":U,retorno8:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("retorno9":U,"retorno9":U,retorno9:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("retorno10":U,"retorno10":U,retorno10:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("retorno11":U,"retorno11":U,retorno11:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htm-associate IN THIS-PROCEDURE
    ("retorno12":U,"retorno12":U,retorno12:HANDLE IN FRAME {&FRAME-NAME}).
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
  DEF VAR i AS INT NO-UNDO.

  DEF VAR vlr_total AS DEC NO-UNDO.
     
  RUN output-header.
  RUN dispatch IN THIS-PROCEDURE ('input-fields':U).
  RUN dispatch IN THIS-PROCEDURE ('assign-fields':U).

  CASE basebusca:
      WHEN "media" THEN
      DO:
          /*
          conteudo1: valor da verba da Cooperativa
          conteudo2: quantidade total de PACs da Cooperativa
          conteudo3: valor da verba já distribuída
          conteudo4: número da linha que deve ser colocada em formato decimal
          conteudo5: valor da verba da linha
          conteudo6: valor de despesas (que não pode ser distribuido aos PACs)
          ---------------------------------------------------
          retorno1:  valor da verba da Cooperativa
          retorno2:  média de verba por PAC
          retorno3:  % da média de verba por PAC
          retorno4:  valor da verba já distribuída
          retorno5:  % de verba distribuída
          retorno6:  saldo da verba (valores não distribuídos ainda)
          retorno7:  % saldo
          retorno8:  linha que será atualizada
          retorno9:  valor da linha
          retorno10: percentual da linha
          retorno11: valor das despesas (com formatação)
          retorno12: valor para distribuir para os PACs (com formatação)
          */

          ASSIGN
              retorno1 = TRIM(STRING(ROUND((DEC(conteudo1)), 2), "->>>,>>>,>>9.99"))
              retorno2 = "0,00"
              retorno3 = "0,00" 
              retorno4 = TRIM(STRING(DEC(conteudo3), "->>>,>>>,>>9.99"))
              retorno5 = "0,00"
              retorno6 = "0,00"
              retorno7 = "0,00".

          IF DEC(conteudo2) <> 0 THEN
              /* Valor Total da Verba dividido pela Quantidade de PACs */
              retorno2 = TRIM(STRING(ROUND(((DEC(conteudo1) - DEC(conteudo6)) / DEC(conteudo2)), 2), "->>>,>>>,>>9.99")).
          
          IF DEC(conteudo1) <> 0 THEN
              /* Verba por PAC dividido pelo total da Verba vezes 100 */
              retorno3 = TRIM(STRING(ROUND((DEC(retorno2) / (DEC(conteudo1) - DEC(conteudo6)) * 100), 2), "->>>,>>>,>>9.99")).
          
          IF DEC(conteudo2) <> 0 THEN
              /* Verba distribuída dividida pela Verba total vezes 100 */
              retorno5 = TRIM(STRING(ROUND((DEC(retorno4) / (DEC(conteudo1) - DEC(conteudo6)) * 100), 2), "->>>,>>>,>>9.99")).
          
          /* Verba total menos verba distribuída */
          IF (DEC(conteudo1) - DEC(conteudo6)) > DEC(conteudo3) THEN
              retorno6 = TRIM(STRING(ROUND(((DEC(conteudo1) - DEC(conteudo6)) - DEC(retorno4)), 2), "->>>,>>>,>>9.99")).
          ELSE
              retorno6 = TRIM(STRING(ROUND(((DEC(retorno4) - (DEC(conteudo1) - DEC(conteudo6))) * -1), 2), "->>>,>>>,>>9.99")).

        
          IF DEC(conteudo1) <> 0 THEN
              /* Saldo dividido pela verba total vezes 100 */
              retorno7 = TRIM(STRING(ROUND((DEC(retorno6) / (DEC(conteudo1) - DEC(conteudo6)) * 100), 2), "->>>,>>>,>>9.99")).

          retorno8 = conteudo4.

          retorno9 = TRIM(STRING(ROUND((DEC(conteudo5)), 2), "->>>,>>>,>>9.99")). 

          retorno10 = TRIM(STRING(ROUND((DEC(retorno9) / (DEC(conteudo1) - DEC(conteudo6)) * 100), 2), "->>>,>>>,>>9.99")).

          retorno11 = TRIM(STRING(ROUND((DEC(conteudo6)), 2), "->>>,>>>,>>9.99")).

          retorno12 = TRIM(STRING(ROUND(DEC(retorno1) - DEC(retorno11), 2), "->>>,>>>,>>9.99")).

          IF retorno1  = ? THEN retorno1  = "0,00".
          IF retorno2  = ? THEN retorno2  = "0,00".
          IF retorno3  = ? THEN retorno3  = "0,00".
          IF retorno4  = ? THEN retorno4  = "0,00".
          IF retorno5  = ? THEN retorno5  = "0,00".
          IF retorno6  = ? THEN retorno6  = "0,00".
          IF retorno7  = ? THEN retorno7  = "0,00".
          IF retorno8  = ? THEN retorno8  = "0,00".
          IF retorno9  = ? THEN retorno9  = "0,00".
          IF retorno10 = ? THEN retorno10 = "0,00".
          IF retorno11 = ? THEN retorno11 = "0,00". 
          IF retorno12 = ? THEN retorno12 = "0,00".

          
      END.
  
  END CASE.             
  RUN dispatch IN THIS-PROCEDURE ('display-fields':U).    
  RUN dispatch IN THIS-PROCEDURE ('enable-fields':U).
  RUN dispatch IN THIS-PROCEDURE ('output-fields':U).
END PROCEDURE.
&ANALYZE-RESUME
