/*.................................................................................
Alterações: 19/10/2015 - Fonte criado para alteração de fornecedores/facilitadores
                         (Jean Michel).
...................................................................................*/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions */
DEFINE TEMP-TABLE ab_unmap
  FIELD aux_cdagenci AS CHARACTER FORMAT "X(256)":U
  FIELD aux_cdcooper AS CHARACTER FORMAT "X(256)":U
  FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U
  FIELD aux_cdevento AS CHARACTER FORMAT "X(256)":U
  FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U
  FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U
  FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U
  FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U
  FIELD aux_lsfornec AS CHARACTER FORMAT "X(256)":U
  FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U
  FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U
  FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U
  FIELD aux_idfacili AS CHARACTER FORMAT "X(256)":U
  FIELD aux_nrseqdig AS CHARACTER FORMAT "X(256)":U
  FIELD aux_idvapost AS CHARACTER FORMAT "X(256)":U.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-html 
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
/*           This .W file was created with AppBuilder.                  */
/*----------------------------------------------------------------------*/

/* Create an unnamed pool to store all the widgets created 
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures 
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */
/* Preprocessor Definitions                                             */
/* Parameters Definitions                                               */
/* Local Variable Definitions                                           */
/* ******************************************************************** */

DEFINE VARIABLE ProgramaEmUso AS CHARACTER INITIAL ["wpgd0019b"].
DEFINE VARIABLE NmeDoPrograma AS CHARACTER INITIAL ["wpgd0019b.w"].

DEFINE VARIABLE opcao                 AS CHARACTER.
DEFINE VARIABLE msg-erro              AS CHARACTER.
DEFINE VARIABLE msg-erro-aux          AS INTEGER.
DEFINE VARIABLE aux_nrdrowid-auxiliar AS CHARACTER.
DEFINE VARIABLE pesquisa              AS CHARACTER.     
DEFINE VARIABLE FlagPermissoes        AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER FORMAT "x(47)".
DEFINE VARIABLE vauxsenha             AS CHARACTER FORMAT "X(16)".

DEFINE VARIABLE i                     AS INTEGER   NO-UNDO.
DEFINE VARIABLE m-erros               AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-qtdeerro            AS INTEGER   NO-UNDO.
DEFINE VARIABLE v-descricaoerro       AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-identificacao       AS CHARACTER NO-UNDO.
DEFINE VARIABLE vr_errfacil           AS CHARACTER NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratcdp NO-UNDO     LIKE crapcdp.
DEFINE TEMP-TABLE crabadp NO-UNDO     LIKE crapadp.
DEFINE VARIABLE vetorfornec          AS CHARACTER FORMAT "X(2000)" NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0019b.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_cdagenci ab_unmap.aux_cdcooper ~
ab_unmap.aux_lsfornec ab_unmap.aux_idevento ab_unmap.aux_cdevento ab_unmap.aux_dtanoage ~
ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ab_unmap.aux_dsretorn ~
ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ~
ab_unmap.aux_idfacili ab_unmap.aux_nrseqdig ab_unmap.aux_idvapost
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_cdagenci ab_unmap.aux_dtanoage ~
ab_unmap.aux_cdcooper ab_unmap.aux_lsfornec ab_unmap.aux_idevento ~
ab_unmap.aux_cdevento ab_unmap.aux_cddopcao ab_unmap.aux_dsendurl ~
ab_unmap.aux_dsretorn ab_unmap.aux_lspermis ab_unmap.aux_nrdrowid ~
ab_unmap.aux_stdopcao ab_unmap.aux_idfacili ab_unmap.aux_idvapost ~
ab_unmap.aux_nrseqdig

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME
/* ***********************  Control Definitions  ********************** */
/* Definitions of the field level widgets                               */
/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
  ab_unmap.aux_cdagenci AT ROW 1 COL 1 HELP
      "" NO-LABEL FORMAT "X(256)":U
      VIEW-AS FILL-IN 
      SIZE 20 BY 1
  ab_unmap.aux_cdcooper AT ROW 1 COL 1 HELP
      "" NO-LABEL FORMAT "X(256)":U
      VIEW-AS FILL-IN 
      SIZE 20 BY 1
  ab_unmap.aux_lsfornec AT ROW 1 COL 1 HELP
      "" NO-LABEL FORMAT "X(256)":U
      VIEW-AS FILL-IN 
      SIZE 20 BY 1
  ab_unmap.aux_idevento AT ROW 1 COL 1 HELP
      "" NO-LABEL FORMAT "X(256)":U
      VIEW-AS FILL-IN 
      SIZE 20 BY 1
  ab_unmap.aux_dtanoage AT ROW 1 COL 1 HELP
      "" NO-LABEL FORMAT "X(256)":U
      VIEW-AS FILL-IN 
      SIZE 20 BY 1
  ab_unmap.aux_cdevento AT ROW 1 COL 1 HELP
      "" NO-LABEL FORMAT "X(256)":U
      VIEW-AS FILL-IN 
      SIZE 20 BY 1
  ab_unmap.aux_cddopcao AT ROW 1 COL 1 HELP
      "" NO-LABEL FORMAT "X(256)":U
      VIEW-AS FILL-IN 
      SIZE 20 BY 1
  ab_unmap.aux_dsendurl AT ROW 1 COL 1 HELP
      "" NO-LABEL FORMAT "X(256)":U
      VIEW-AS FILL-IN 
      SIZE 20 BY 1
  ab_unmap.aux_dsretorn AT ROW 1 COL 1 HELP
      "" NO-LABEL FORMAT "X(256)":U
      VIEW-AS FILL-IN 
      SIZE 20 BY 1
  ab_unmap.aux_lspermis AT ROW 1 COL 1 HELP
      "" NO-LABEL FORMAT "X(256)":U
      VIEW-AS FILL-IN 
      SIZE 20 BY 1
  ab_unmap.aux_nrdrowid AT ROW 1 COL 1 HELP
      "" NO-LABEL FORMAT "X(256)":U
      VIEW-AS FILL-IN 
      SIZE 20 BY 1
  ab_unmap.aux_stdopcao AT ROW 1 COL 1 HELP
      "" NO-LABEL FORMAT "X(256)":U
      VIEW-AS FILL-IN 
      SIZE 20 BY 1
  ab_unmap.aux_idfacili AT ROW 1 COL 1 HELP
      "" NO-LABEL FORMAT "X(256)":U
      VIEW-AS FILL-IN 
      SIZE 20 BY 1
  ab_unmap.aux_nrseqdig AT ROW 1 COL 1 HELP
      "" NO-LABEL FORMAT "X(256)":U
      VIEW-AS FILL-IN 
      SIZE 20 BY 1
  ab_unmap.aux_idvapost AT ROW 1 COL 1 HELP
      "" NO-LABEL FORMAT "X(256)":U
      VIEW-AS FILL-IN 
      SIZE 20 BY 1
  WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
     SIDE-LABELS 
     AT COL 1 ROW 1
     SIZE 53.8 BY 25.57.

/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Web-Object
   Allow: Query
   Frames: 1
   Add Fields to: Neither
   Editing: Special-Events-Only
   Events: web.output,web.input
   Other Settings: COMPILE
   Temp-Tables and Buffers:
      TABLE: ab_unmap W "?" ?  
      ADDITIONAL-FIELDS:
          FIELD aux_cdagenci AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cdcooper AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cdevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsretorn AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dtanoge  AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lsfornec AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idfacili AS CHARACTER FORMAT "X(256)":U
          FIELD aux_nrseqdig AS CHARACTER FORMAT "X(256)":U
          FIELD aux_idvapost AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 25.57
         WIDTH              = 53.8.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB w-html 
/* *********************** Included-Libraries ************************* */

{src/web2/html-map.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW w-html
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME Web-Frame
   UNDERLINE                                                            */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdagenci IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdcooper IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cddopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsretorn IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dtanoage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */                
/* SETTINGS FOR FILL-IN ab_unmap.aux_lsfornec IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idfacili IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idvapost IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrseqdig IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK w-html 

/* ************************  Main Code Block  ************************* */

/* Standard Main Block that runs adm-create-objects, initializeObject 
 * and process-web-request.
 * The bulk of the web processing is in the Procedure process-web-request
 * elsewhere in this Web object.
 */
{src/web2/template/hmapmain.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaFornecedor w-html 
PROCEDURE CriaListaFornecedor:
  /*------------------------------------------------------------------------------
    Purpose:     
    Parameters:  <none>
    Notes:       
  ------------------------------------------------------------------------------*/

  DEF VAR aux_dtvalpro AS CHAR NO-UNDO.
  DEF VAR aux_nrpropos AS CHAR NO-UNDO.
  DEF VAR aux_vlinvest AS CHAR NO-UNDO.
  DEF VAR aux_regselec AS CHAR NO-UNDO.
  
  FIND FIRST crapedp WHERE crapedp.cdevento = INT(ab_unmap.aux_cdevento)
                       AND crapedp.dtanoage = 0 NO-LOCK NO-ERROR.
  
  /* Carrega o array com todos os Fornecedores */
  FOR EACH gnapfdp WHERE gnapfdp.cdcooper = 0        
                     AND gnapfdp.idevento = INTEGER(ab_unmap.aux_idevento) 
                     AND gnapfdp.dtforina = ? /* Somente fornecedores ativos */
                     NO-LOCK BY gnapfdp.nmfornec:
  
    ASSIGN aux_dtvalpro = ""
           aux_nrpropos = ""
           aux_vlinvest = "".
  
    FIND FIRST gnapefp WHERE gnapefp.cdcooper = gnapfdp.cdcooper
                         AND gnapefp.nrcpfcgc = gnapfdp.nrcpfcgc
                         AND gnapefp.cdeixtem = crapedp.cdeixtem NO-LOCK NO-ERROR.

    IF NOT AVAILABLE gnapefp THEN
      DO:
        NEXT.
      END.
  
    /* Se tiver proposta, mostra todas */
    FOR EACH gnappdp WHERE gnappdp.idevento = gnapfdp.idevento
                       AND gnappdp.cdcooper = gnapfdp.cdcooper
                       AND gnappdp.nrcpfcgc = gnapfdp.nrcpfcgc
                       AND gnappdp.cdevento = crapedp.cdevento 
                       AND gnappdp.dtvalpro >= TODAY NO-LOCK:
  
      ASSIGN aux_dtvalpro = STRING(gnappdp.dtvalpro, "99/99/9999")
             aux_nrpropos = STRING(gnappdp.nrpropos)
             aux_vlinvest = STRING(gnappdp.vlinvest, "->>>,>>9.99").
  
      /* verifica se algo já foi selecionado */
      FIND FIRST crapcdp WHERE crapcdp.idevento = INT(ab_unmap.aux_idevento)
                           AND crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper)
                           AND crapcdp.cdagenci = INT(ab_unmap.aux_cdagenci)
                           AND crapcdp.cdevento = INT(ab_unmap.aux_cdevento)
                           AND crapcdp.dtanoage = INT(ab_unmap.aux_dtanoage)
                           AND crapcdp.cdcuseve = 1 /* Honorários */
                           AND crapcdp.nrcpfcgc = gnapfdp.nrcpfcgc
                           AND crapcdp.nrpropos = gnappdp.nrpropos NO-LOCK NO-ERROR.

      IF AVAILABLE crapcdp THEN
        ASSIGN aux_regselec = "#CCCCCC".
      ELSE
        ASSIGN aux_regselec = "#FFFFFF".

      /* Busca o facilitador associado a proposta */
      FIND gnfacep where gnfacep.idevento = INT(ab_unmap.aux_idevento)
                     AND gnfacep.cdcooper = 0
                     AND gnfacep.nrcpfcgc = gnapfdp.nrcpfcgc
                     AND gnfacep.nrpropos = gnappdp.nrpropos NO-LOCK NO-ERROR NO-WAIT.

      IF AVAILABLE gnfacep THEN
        DO:
          /* Busca o Facilitador */
          FIND gnapfep WHERE gnapfep.nrcpfcgc = gnfacep.nrcpfcgc
                         AND gnapfep.cdfacili = gnfacep.cdfacili NO-LOCK NO-ERROR NO-WAIT.
        END.
      
      IF vetorfornec = "" THEN
        vetorfornec = "~{" + "nrcpfcgc:" + "'" + STRING(gnapfdp.nrcpfcgc) + "'" + 
                             ",nmfornec:" + "'" + gnapfdp.nmfornec + "'" +
                             ",nmfacili:" + "'" + gnapfep.nmfacili + "'" +
                             ",nrpropos:" + "'" + aux_nrpropos     + "'" +
                             ",dtvalpro:" + "'" + aux_dtvalpro     + "'" +
                             ",vlinvest:" + "'" + aux_vlinvest     + "'" + 
                             ",regselec:" + "'" + aux_regselec     + "'" + "~}".
      ELSE
        vetorfornec = vetorfornec + "," + 
                            "~{" + "nrcpfcgc:" + "'" + STRING(gnapfdp.nrcpfcgc) + "'" +
                                  ",nmfornec:" + "'" + gnapfdp.nmfornec + "'" +
                                  ",nmfacili:" + "'" + gnapfep.nmfacili + "'" +
                                  ",nrpropos:" + "'" + aux_nrpropos + "'" +
                                  ",dtvalpro:" + "'" + aux_dtvalpro + "'" +
                                  ",vlinvest:" + "'" + aux_vlinvest + "'" + 
                                  ",regselec:" + "'" + aux_regselec     + "'" + "~}".                
    END. /* For Each */

END. /* CriaListaFornecedor */

RUN RodaJavaScript("var mfornece=new Array();mfornece=["  + vetorfornec + "]"). 

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE htmOffsets w-html  _WEB-HTM-OFFSETS
PROCEDURE htmOffsets :
  /*------------------------------------------------------------------------------
    Purpose:     Runs procedure to associate each HTML field with its
                 corresponding widget name and handle.
    Parameters:  
    Notes:       
  ------------------------------------------------------------------------------*/
  RUN readOffsets ("{&WEB-FILE}":U).
  RUN htmAssociate
    ("aux_cdagenci":U,"ab_unmap.aux_cdagenci":U,ab_unmap.aux_cdagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdcooper":U,"ab_unmap.aux_cdcooper":U,ab_unmap.aux_cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cddopcao":U,"ab_unmap.aux_cddopcao":U,ab_unmap.aux_cddopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdevento":U,"ab_unmap.aux_cdevento":U,ab_unmap.aux_cdevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsretorn":U,"ab_unmap.aux_dsretorn":U,ab_unmap.aux_dsretorn:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtanoage":U,"ab_unmap.aux_dtanoage":U,ab_unmap.aux_dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lsfornec":U,"ab_unmap.aux_lsfornec":U,ab_unmap.aux_lsfornec:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idfacili":U,"ab_unmap.aux_idfacili":U,ab_unmap.aux_idfacili:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrseqdig":U,"ab_unmap.aux_nrseqdig":U,ab_unmap.aux_nrseqdig:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idvapost":U,"ab_unmap.aux_idvapost":U,ab_unmap.aux_idvapost:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record:
  DEFINE INPUT PARAMETER opcao AS CHARACTER.

  FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento)
                      AND gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper)
                      AND gnpapgd.dtanonov = INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR.
  
  IF NOT AVAILABLE gnpapgd THEN
    DO:
      LEAVE.
    END.
  
  DO WITH FRAME {&FRAME-NAME}:
    IF opcao = "inclusao" THEN
      DO:
        FIND FIRST crapcdp WHERE crapcdp.idevento = INT(ab_unmap.aux_idevento)
                             AND crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper)
                             AND crapcdp.cdagenci = INT(ab_unmap.aux_cdagenci)
                             AND crapcdp.cdevento = INT(ab_unmap.aux_cdevento)
                             AND crapcdp.dtanoage = gnpapgd.dtanonov           
                             AND crapcdp.tpcuseve = 1 /* custos diretos */     
                             AND crapcdp.cdcuseve = 1 /* Honorários */ NO-LOCK NO-ERROR.

        IF NOT AVAILABLE crapcdp THEN
          DO:
            ASSIGN msg-erro = msg-erro + "Custo não encontrado.".
          END.
        ELSE
          DO:
            FIND crapcdp WHERE crapcdp.idevento = INT(ab_unmap.aux_idevento)
                           AND crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper)
                           AND crapcdp.cdagenci = INT(ab_unmap.aux_cdagenci)
                           AND crapcdp.dtanoage = gnpapgd.dtanonov
                           AND crapcdp.cdevento = INT(ab_unmap.aux_cdevento) 
                           AND crapcdp.tpcuseve = 1 /* Custos Diretos */
                           AND crapcdp.cdcuseve = 1 NO-LOCK NO-ERROR NO-WAIT. /* Honorários */
                
            IF AVAILABLE crapcdp THEN
              DO:
                FIND CURRENT crapcdp EXCLUSIVE-LOCK.
                
                ASSIGN crapcdp.idevento = INT(ab_unmap.aux_idevento) 
                       crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper) 
                       crapcdp.cdagenci = INT(ab_unmap.aux_cdagenci) 
                       crapcdp.cdevento = INT(ab_unmap.aux_cdevento)  
                       crapcdp.dtanoage = gnpapgd.dtanonov           
                       crapcdp.cdcuseve = 1 /* Honorários */ 
                       crapcdp.tpcuseve = 1 /* Custos Diretos */
                       crapcdp.nrcpfcgc = DEC(ENTRY(1,ab_unmap.aux_lsfornec))
                       crapcdp.nrpropos = IF ENTRY(2,ab_unmap.aux_lsfornec) <> "" THEN ENTRY(2,ab_unmap.aux_lsfornec) ELSE ?.
              END.
            ELSE
              DO:
                CREATE crapcdp.
                ASSIGN crapcdp.idevento = INT(ab_unmap.aux_idevento) 
                       crapcdp.cdcooper = INT(ab_unmap.aux_cdcooper) 
                       crapcdp.cdagenci = INT(ab_unmap.aux_cdagenci) 
                       crapcdp.cdevento = INT(ab_unmap.aux_cdevento)  
                       crapcdp.dtanoage = gnpapgd.dtanonov           
                       crapcdp.cdcuseve = 1 /* Honorários */ 
                       crapcdp.tpcuseve = 1 /* Custos Diretos */
                       crapcdp.nrcpfcgc = DEC(ENTRY(1,ab_unmap.aux_lsfornec))
                       crapcdp.nrpropos = IF ENTRY(2,ab_unmap.aux_lsfornec) <> "" THEN ENTRY(2,ab_unmap.aux_lsfornec) ELSE ?.
              END.
            
            FIND FIRST gnappdp WHERE gnappdp.cdcooper = 0
                                 AND gnappdp.nrcpfcgc = crapcdp.nrcpfcgc
                                 AND gnappdp.nrpropos = crapcdp.nrpropos NO-LOCK NO-ERROR.
                                 
            IF AVAILABLE gnappdp THEN
              DO:
                crapcdp.vlcuseve = gnappdp.vlinvest.
              END.

          END. /*ELSE*/
      END. /* Inclusao */   
  END. /* DO WITH FRAME {&FRAME-NAME} */
       
    RUN RodaJavaScript('window.opener.Recarrega();').  
    RUN RodaJavaScript('self.close();').
    
END PROCEDURE.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE valida-facilitador w-html 
PROCEDURE valida-facilitador:
  
  DEF VAR aux_dsdiaeve AS CHAR NO-UNDO.
  DEF VAR aux_dsdiapro AS CHAR NO-UNDO.
  DEF VAR aux_contador AS INT  NO-UNDO.
  DEF VAR aux_nrcpfcgc AS DEC  NO-UNDO.
  DEF VAR aux_nrpropos AS CHAR NO-UNDO.
  DEF VAR aux_cdfacili AS INT  NO-UNDO.
    
  FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento)
                      AND gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper)
                      AND gnpapgd.dtanonov = INT(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR.
  
  IF NOT AVAILABLE gnpapgd THEN
    DO:
      LEAVE.
    END.
    
  FIND crapadp WHERE crapadp.idevento = INT(ab_unmap.aux_idevento)
                 AND crapadp.cdcooper = INT(ab_unmap.aux_cdcooper)
                 AND crapadp.dtanoage = gnpapgd.dtanonov  
                 AND crapadp.cdagenci = INT(ab_unmap.aux_cdagenci)
                 AND crapadp.cdevento = INT(ab_unmap.aux_cdevento)
                 AND crapadp.nrseqdig = INT(GET-VALUE("aux_nrseqdig")) NO-LOCK NO-ERROR NO-WAIT.
                 
  IF NOT AVAILABLE crapadp THEN
    DO:
      ASSIGN msg-erro = "Evento não encontrado.".
      LEAVE.
    END.
  ELSE
    DO:
      ASSIGN aux_dsdiaeve = crapadp.dsdiaeve.
      
      IF crapadp.dtinieve = ? OR
         crapadp.dtfineve = ? THEN
        DO:
          LEAVE.
        END.
    END.  
        
  ASSIGN aux_nrcpfcgc = DEC(ENTRY(1,ab_unmap.aux_lsfornec))
         aux_nrpropos = IF ENTRY(2,ab_unmap.aux_lsfornec) <> "" THEN ENTRY(2,ab_unmap.aux_lsfornec) ELSE ?.
   
  /* Consulta codigo do facilitador selecionado*/
  FIND gnfacep where gnfacep.idevento = INT(ab_unmap.aux_idevento)
                 AND gnfacep.cdcooper = 0
                 AND gnfacep.nrcpfcgc = aux_nrcpfcgc
                 AND gnfacep.nrpropos = aux_nrpropos NO-LOCK NO-ERROR NO-WAIT.

  IF AVAILABLE gnfacep THEN
    DO:
      /* Busca o Facilitador */
      ASSIGN aux_cdfacili = gnfacep.cdfacili.
    END.
  /* Fim Consulta codigo do facilitador selecionado */
      
  FOR EACH crabadp WHERE crabadp.idevento  = crapadp.idevento
                     AND crabadp.dtanoage >= crapadp.dtanoage
                     AND crabadp.dtinieve >= crapadp.dtinieve
                     AND crabadp.dtfineve <= crapadp.dtfineve
                     AND crabadp.nrseqdig <> crapadp.nrseqdig
                     AND (crabadp.idstaeve = 0
                      OR  crabadp.idstaeve = 1
                      OR  crabadp.idstaeve = 3
                      OR  crabadp.idstaeve = 6) NO-LOCK:
        
    ASSIGN aux_dsdiapro = crabadp.dsdiaeve.
        
    /* verifica se algo já foi selecionado */
    FIND FIRST crapcdp WHERE crapcdp.idevento = crabadp.idevento
                         AND crapcdp.cdcooper = crabadp.cdcooper
                         AND crapcdp.cdevento = crabadp.cdevento
                         AND crapcdp.dtanoage = crabadp.dtanoage
                         AND crapcdp.cdcuseve = 1 /* Honorários */
                         AND crapcdp.nrcpfcgc = aux_nrcpfcgc
                         AND crapcdp.nrpropos = aux_nrpropos NO-LOCK NO-ERROR.
                     
    /* Busca o facilitador associado a proposta */
    FIND gnfacep where gnfacep.idevento = INT(ab_unmap.aux_idevento)
                   AND gnfacep.cdcooper = 0
                   AND gnfacep.nrcpfcgc = gnapfdp.nrcpfcgc
                   AND gnfacep.nrpropos = gnappdp.nrpropos NO-LOCK NO-ERROR NO-WAIT.

    IF AVAILABLE gnfacep THEN
      DO:
        IF aux_cdfacili = gnfacep.cdfacili THEN
          DO:
            DO aux_contador = 1 TO NUM-ENTRIES(aux_dsdiaeve,","):
              IF CAN-DO(aux_dsdiapro,ENTRY(aux_contador,aux_dsdiaeve,",")) THEN
                DO:
                  FOR FIRST crapcop FIELDS(nmrescop) WHERE crapcop.cdcooper = crabadp.cdcooper NO-LOCK. END.
                  FOR FIRST crapedp FIELDS(nmevento) WHERE crapedp.idevento = crabadp.idevento AND crapedp.cdcooper = crabadp.cdcooper AND crapedp.dtanoage = 0 AND crapedp.cdevento = crabadp.cdevento NO-LOCK. END.
                  FOR FIRST crapage FIELDS(nmresage) WHERE crapage.cdcooper = crabadp.cdcooper AND crapage.cdagenci = crabadp.cdagenci NO-LOCK. END.
                  ASSIGN vr_errfacil = "Facilitador com evento já cadastrado para esta data, confirma inclusão? Coopaerativa: " + STRING(crapcop.nmrescop) + ", Evento: " + STRING(crapedp.nmevento) + ", PA: " + STRING(crapage.nmresage) + ", Data: " + STRING(crapadp.dtinieve) + ".".
                  ASSIGN msg-erro = "Evento não encontrado.".
                  LEAVE.
                END.
            END.
          END.          
      END.
  END.
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-display-fields w-html 
PROCEDURE local-display-fields :
  RUN displayFields.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE outputHeader w-html 
PROCEDURE outputHeader :
/*------------------------------------------------------------------------
  Purpose:     Output the MIME header, and any "cookie" information needed 
               by this procedure.  
  Parameters:  <none>
  Notes:       In the event that this Web object is state-aware, this is 
               a good place to set the WebState and WebTimeout attributes.
------------------------------------------------------------------------*/

  output-content-type ("text/html":U).
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PermissaoDeAcesso w-html 
PROCEDURE PermissaoDeAcesso :
{includes/wpgd0009.i}

/* Permissão fixa, uma vez que ele já tem permissão para a tela que 'chamou' */ 
ASSIGN v-identificacao = get-cookie("cookie-usuario-em-uso")
       v-permissoes    = "IAEPLU".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-web-request w-html 
PROCEDURE process-web-request :
/*------------------------------------------------------------------------------
   Tipo: Procedure interna
   Nome: includes/webreq.i - Versão WebSpeed 2.1
  Autor: B&T/Solusoft
 Função: Processo de requisição web p/ cadastros simples na web - Versão WebSpeed 3.0
  Notas: Este é o procedimento principal onde terá as requisições GET e POST.
         GET - É ativa quando o formulário é chamado pela 1a vez
         POST - Após o get somente ocorrerá POST no formulário      
         Caso seja necessário custimizá-lo para algum programa específico 
         Favor cópiar este procedimento para dentro do procedure process-web-requeste 
         faça lá alterações necessárias.

Alterações: 10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).

-------------------------------------------------------------------------------*/

v-identificacao = get-cookie("cookie-usuario-em-uso").

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + v-identificacao + "*" NO-LOCK:
  LEAVE.
END.

ASSIGN opcao                 = GET-FIELD("aux_cddopcao")
       FlagPermissoes        = GET-VALUE("aux_lspermis")
       msg-erro-aux          = 0
       ab_unmap.aux_dsendurl = AppURL                        
       ab_unmap.aux_lspermis = FlagPermissoes                
       ab_unmap.aux_nrdrowid = GET-VALUE("aux_nrdrowid")         
       ab_unmap.aux_stdopcao = GET-VALUE("aux_stdopcao")
       ab_unmap.aux_lsfornec = GET-VALUE("aux_lsfornec")
       ab_unmap.aux_idevento = GET-VALUE("aux_idevento")
       ab_unmap.aux_dtanoage = GET-VALUE("aux_dtanoage")
       ab_unmap.aux_cdcooper = GET-VALUE("aux_cdcooper")
       ab_unmap.aux_cdagenci = GET-VALUE("aux_cdagenci")
       ab_unmap.aux_cdevento = GET-VALUE("aux_cdevento")
       ab_unmap.aux_nrseqdig = GET-VALUE("aux_nrseqdig").

RUN outputHeader.

/* método POST */
IF REQUEST_METHOD = "POST":U THEN 
  DO:
    RUN inputFields.
    
    CASE opcao:
    WHEN "sa" THEN /* salvar */
      
      IF ab_unmap.aux_stdopcao = "i"   THEN /* inclusao */
        DO:
        
          /* Verificacao de validacao de facilitador */
          IF GET-VALUE("aux_idfacili") = "N" THEN
            DO:
            
              ASSIGN msg-erro = ?.
              
              RUN valida-facilitador.
              
              IF msg-erro <> ? THEN
                DO:
                  ASSIGN msg-erro-aux = 11. /* erros da validação de dados */
                END.
              ELSE
                DO:
                  RUN local-assign-record ("inclusao").                                        
           
                  IF msg-erro <> "" THEN
                    DO:
                      ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                    END.
                  ELSE
                    DO:
                      ASSIGN msg-erro-aux          = 10
                             ab_unmap.aux_stdopcao = "al".
                    END.
                END.
            END.
          ELSE
            DO:
              RUN local-assign-record ("inclusao").                                        
            
              IF msg-erro <> "" THEN
                DO:
                  ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                END.
              ELSE
                DO:
                  ASSIGN msg-erro-aux          = 10
                         ab_unmap.aux_stdopcao = "al".
                END.         
            END.
      END. /* fim inclusao */
    END CASE.

		RUN CriaListaFornecedor.
    RUN displayFields.
    RUN enableFields.
    RUN outputFields.  
		        
    CASE msg-erro-aux:
      WHEN 10 THEN
        DO:
          RUN RodaJavaScript('window.opener.Recarrega();').  
          RUN RodaJavaScript('self.close();').
        END.   
      WHEN 11 THEN
        DO:
          RUN RodaJavaScript('var conf = confirm("' + STRING(vr_errfacil) + '");'). 
          RUN RodaJavaScript('((!conf) ? document.form.aux_idfacili.value = "N" : document.form.aux_idfacili.value = "S")').
          RUN RodaJavaScript('((!conf) ? document.form.aux_cddopcao.value = "" : document.form.aux_cddopcao.value = "sa")').
          RUN RodaJavaScript('((!conf) ? document.form.aux_idvapost.value = "S" : document.getElementById("form").submit())').
        END.
    END CASE.     
  END. /* Fim do método POST */
ELSE /* Método GET */ 
  DO:
    RUN PermissaoDeAcesso(INPUT ProgramaEmUso, OUTPUT IdentificacaoDaSessao, OUTPUT ab_unmap.aux_lspermis).

    CASE ab_unmap.aux_lspermis:
      WHEN "1" THEN /* get-cookie em usuario-em-uso voltou valor nulo */
        RUN RodaJavaScript('top.close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').

      WHEN "2" THEN /* identificacao vinda do cookie bao existe na tabela de log de sessao */ 
        DO: 
          DELETE-COOKIE("cookie-usuario-em-uso",?,?).
           
          RUN RodaJavaScript('top.close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').
        END.
      WHEN "3" THEN /* usuario nao tem permissao para acessa o programa */
        RUN RodaJavaScript('window.location.href = "' + ab_unmap.aux_dsendurl + '/gerenciador/negado"').
      OTHERWISE
        DO: 
          RUN CriaListaFornecedor.
          RUN displayFields.
          RUN enableFields.
          RUN outputFields.
        END. /* fim otherwise */                  
    END CASE. 
  END. /* fim do método GET */

/* Show error messages. */
IF AnyMessage()   THEN 
  DO:
    /* ShowDataMessage may return a Progress column name. This means you
    * can use the function as a parameter to HTMLSetFocus instead of 
    * calling it directly.  The first parameter is the form name.   
    *
    * HTMLSetFocus("document.DetailForm",ShowDataMessages()). */

    ShowDataMessages().
  END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RodaJavaScript w-html 
PROCEDURE RodaJavaScript :
  {includes/rodajava.i}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME