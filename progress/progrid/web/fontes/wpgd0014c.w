/*...............................................................................

Alterações: 05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                         busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
             
            10/08/2015 - Ajustes para projeto 229 - Melhorias OQS (Jean Michel).            
            
            08/03/2016 - Alterado para que os eventos do tipo EAD 
                         e EAD Assemblear não sejam apresentados.
                         Projeto 229 - Melhorias OQS (Lombardi)         

...............................................................................*/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_cdagenci AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdcooper AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lsevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD glb_cdcooper AS CHARACTER FORMAT "X(256)":U 
       FIELD nmresage AS CHARACTER FORMAT "X(256)":U .

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

/* Preprocessor Definitions ---                                         */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEFINE VARIABLE ProgramaEmUso         AS CHARACTER INITIAL ["wpgd0014c"].
DEFINE VARIABLE NmeDoPrograma         AS CHARACTER INITIAL ["wpgd0014c.w"].

DEFINE VARIABLE opcao                 AS CHARACTER.
DEFINE VARIABLE msg-erro              AS CHARACTER.
DEFINE VARIABLE msg-erro-aux          AS INTEGER.
DEFINE VARIABLE aux_nrdrowid-auxiliar AS CHARACTER.
DEFINE VARIABLE pesquisa              AS CHARACTER.     
DEFINE VARIABLE FlagPermissoes        AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER FORMAT "x(47)".
DEFINE VARIABLE vauxsenha             AS CHARACTER FORMAT "X(16)".

DEFINE VARIABLE i                     AS INTEGER                        NO-UNDO.
DEFINE VARIABLE m-erros               AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE v-qtdeerro            AS INTEGER                        NO-UNDO.
DEFINE VARIABLE v-descricaoerro       AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE v-identificacao       AS CHARACTER                      NO-UNDO.

DEFINE VARIABLE vetoreventos          AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE aux_ttcabeca          AS INTEGER                        NO-UNDO.
DEFINE VARIABLE aux_dsorigem          AS CHARACTER     EXTENT 99        NO-UNDO.
DEFINE VARIABLE aux_qtorigem          AS INTEGER       EXTENT 99        NO-UNDO.
DEFINE VARIABLE aux_qttoteve          AS INTEGER                        NO-UNDO.
DEFINE VARIABLE aux_qttotdes          AS INTEGER                        NO-UNDO.
DEFINE VARIABLE aux_flgexist          AS LOGICAL                        NO-UNDO.
DEFINE VARIABLE aux_savedado          AS LOGICAL                        NO-UNDO INIT FALSE.

/*** Declaração de BOs ***/
DEFINE VARIABLE h-b1wpgd0014b         AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE crateap NO-UNDO     LIKE crapeap
  INDEX crateap1 AS PRIMARY idevento cdcooper dtanoage cdevento cdagenci.

DEFINE TEMP-TABLE cratagp NO-UNDO
       FIELD cdagenci LIKE crapage.cdagenci
       FIELD nmresage LIKE crapage.nmresage
       INDEX cratagp1 AS PRIMARY UNIQUE cdagenci.

/*** BUFFER'S ***/
DEFINE BUFFER crabsdp FOR crapsdp.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0014c.htm

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.nmresage ab_unmap.aux_cdagenci ~
ab_unmap.aux_lsevento ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ~
ab_unmap.aux_dsendurl ab_unmap.aux_idevento ab_unmap.aux_lspermis ~
ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ab_unmap.glb_cdcooper ~
ab_unmap.aux_dtanoage 
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.nmresage ab_unmap.aux_cdagenci ~
ab_unmap.aux_lsevento ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ~
ab_unmap.aux_dsendurl ab_unmap.aux_idevento ab_unmap.aux_lspermis ~
ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ab_unmap.glb_cdcooper ~
ab_unmap.aux_dtanoage 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */
/* Definitions of the field level widgets                               */
/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.nmresage AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdagenci AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lsevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdcooper AT ROW 1 COL 1 HELP
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
     ab_unmap.aux_idevento AT ROW 1 COL 1 HELP
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
     ab_unmap.glb_cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_dtanoage AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 44 BY 19.95.

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
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lsevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD glb_cdcooper AS CHARACTER FORMAT "X(256)":U 
          FIELD nmresage AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 19.95
         WIDTH              = 44.
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
   FRAME-NAME UNDERLINE                                                 */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdagenci IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdcooper IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cddopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dtanoage IN FRAME Web-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lsevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.glb_cdcooper IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.nmresage IN FRAME Web-Frame
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaEventos w-html 
PROCEDURE CriaListaEventos :
/*------------------------------------------------------------------------------
  Purpose:     
  Parameters:  <none>
  Notes:       
------------------------------------------------------------------------------*/
  DEF VAR aux_nmagenci AS CHAR NO-UNDO.
  
    ASSIGN vetoreventos = "".

    /* Limpa a tabela temporária */
    EMPTY TEMP-TABLE cratagp.
    
    /* Faz o agrupamento dos PAC'S */
    /* PAC's agrupadores */
    FOR EACH crapagp WHERE crapagp.idevento = INTEGER(ab_unmap.aux_idevento)  AND
                           crapagp.cdcooper = INTEGER(ab_unmap.aux_cdcooper)  AND
                           crapagp.dtanoage = INTEGER(ab_unmap.aux_dtanoage)  AND 
                           crapagp.cdageagr = crapagp.cdagenci                NO-LOCK:
    
        FIND crapage WHERE crapage.cdcooper = crapagp.cdcooper   AND
                           crapage.cdagenci = crapagp.cdagenci   NO-LOCK NO-ERROR.
        
        FIND cratagp WHERE cratagp.cdagenci = crapagp.cdagenci NO-LOCK NO-ERROR.
    
        IF   NOT AVAILABLE cratagp   THEN
             DO:
                 CREATE cratagp.
                 ASSIGN cratagp.cdagenci = crapagp.cdagenci
                        cratagp.nmresage = crapage.nmresage.
             END.
    END.
    
    /* PAC's agrupados */
    FOR EACH crapagp WHERE crapagp.idevento = INTEGER(ab_unmap.aux_idevento)  AND
                           crapagp.cdcooper = INTEGER(ab_unmap.aux_cdcooper)  AND
                           crapagp.dtanoage = INTEGER(ab_unmap.aux_dtanoage)  AND 
                           crapagp.cdageagr <> crapagp.cdagenci               NO-LOCK:
    
        FIND crapage WHERE crapage.cdcooper = crapagp.cdcooper   AND
                           crapage.cdagenci = crapagp.cdagenci   NO-LOCK NO-ERROR.
    
        FIND cratagp WHERE cratagp.cdagenci = crapagp.cdageagr EXCLUSIVE-LOCK NO-ERROR.

        ASSIGN cratagp.nmresage = cratagp.nmresage + " / " +
                                  (IF AVAIL crapage THEN crapage.nmresage ELSE "").
    END.
      
    /* Nome do PAC */
    FIND cratagp WHERE cratagp.cdagenci = INTEGER(ab_unmap.aux_cdagenci)   NO-LOCK NO-ERROR.
             
    /* cabeçalho */
    vetoreventos = "~{nmresage:'" + cratagp.nmresage + "',nmevento:'Evento',cdevento:'0'~}".
    
    /* Monta a tabela dos EVENTOS */
    FOR EACH crapedp WHERE crapedp.idevento = INTEGER(ab_unmap.aux_idevento)   AND
                           crapedp.cdcooper = INTEGER(ab_unmap.aux_cdcooper)   AND
                           crapedp.dtanoage = INTEGER(ab_unmap.aux_dtanoage)   AND
                           crapedp.tpevento <> 10                              AND
                           crapedp.tpevento <> 11                              NO-LOCK
                           BY crapedp.nmevento:
                           
        aux_flgexist = FALSE.
        
        /* Carrega o array com as sugestões do evento */
        FOR EACH crapsdp WHERE crapsdp.idevento = crapedp.idevento                AND
                               crapsdp.cdevento = crapedp.cdevento                AND
                               crapsdp.dtanoage = ?                               AND
                               crapsdp.cdcooper = crapedp.cdcooper                AND
                              (crapsdp.cdagenci = INTEGER(ab_unmap.aux_cdagenci)  OR
                               /* sugestoes comuns a todos os PAC'S */
                               crapsdp.cdagenci = 0)                              NO-LOCK
                               BREAK BY crapsdp.cdevento
                                        BY crapsdp.cdorisug:                       
            
            aux_flgexist = TRUE.
            
            IF   LAST-OF(crapsdp.cdevento)   THEN
                 DO:
                    /* Carrega, também, as sugenstões dos PAC'S que foram agrupados a este */
                    IF   crapsdp.cdagenci <> 0   THEN
                         FOR EACH crapagp WHERE crapagp.idevento  = crapsdp.idevento   AND
                                                crapagp.cdcooper  = crapsdp.cdcooper   AND
                                                crapagp.dtanoage  = crapsdp.dtanoage   AND
                                                crapagp.cdageagr  = crapsdp.cdagenci   AND
                                                crapagp.cdagenci <> crapsdp.cdagenci   NO-LOCK:
                             
                             FOR EACH crabsdp WHERE crabsdp.idevento = crapedp.idevento   AND
                                                    crabsdp.cdevento = crapedp.cdevento   AND
                                                    crabsdp.dtanoage = ?                  AND
                                                    crabsdp.cdcooper = crapedp.cdcooper   AND
                                                    crabsdp.cdagenci = crapagp.cdagenci   NO-LOCK:
                  
                                 aux_flgexist = TRUE.   
    
                             END.
                  
                         END.
                 
                    /* atribui os valores somados no vetor */
                    vetoreventos = vetoreventos + ",~{nmevento:'" + crapedp.nmevento + "',cdevento:'" + STRING(crapedp.cdevento) + "'".                 
                   
                 END.                
        END.
    
        /* Cria o EVENTO mesmo sem ter sugestões */
        IF   aux_flgexist = FALSE   THEN
             DO:
                 vetoreventos = vetoreventos + ",~{nmevento:'" + crapedp.nmevento + "',cdevento:'" + STRING(crapedp.cdevento) + "'".    
             END.
    
        /* Verifica se o EVENTO já está escolhido */
        FIND crapeap WHERE crapeap.cdcooper = crapedp.cdcooper                 AND
                           crapeap.idevento = crapedp.idevento                 AND
                           crapeap.cdagenci = INTEGER(ab_unmap.aux_cdagenci)   AND
                           crapeap.cdevento = crapedp.cdevento                 AND
                           crapeap.dtanoage = INTEGER(ab_unmap.aux_dtanoage)   NO-LOCK NO-ERROR.
    
        IF   AVAILABLE crapeap   THEN
             vetoreventos = vetoreventos + ",flgativo:'yes',flgevobr:'" + STRING(crapeap.flgevobr,"yes/no") + "'~}".
        ELSE
             vetoreventos = vetoreventos + ",flgativo:'no',flgevobr:'" + STRING(crapedp.flgtdpac,"yes/no") + "'~}".
                           
    END.

    RUN RodaJavaScript("var meventos=new Array();meventos=["  + vetoreventos + "]"). 

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
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtanoage":U,"ab_unmap.aux_dtanoage":U,ab_unmap.aux_dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lsevento":U,"ab_unmap.aux_lsevento":U,ab_unmap.aux_lsevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("glb_cdcooper":U,"ab_unmap.glb_cdcooper":U,ab_unmap.glb_cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nmresage":U,"ab_unmap.nmresage":U,ab_unmap.nmresage:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
DEFINE INPUT PARAMETER opcao AS CHARACTER.
    
  /* Instancia a BO para executar as procedures */
  RUN dbo/b1wpgd0014b.p PERSISTENT SET h-b1wpgd0014b.
  
  /* Se BO foi instanciada */
  IF VALID-HANDLE(h-b1wpgd0014b) THEN
    DO:
      DO WITH FRAME {&FRAME-NAME}:
        IF opcao = "inclusao" THEN
          DO: 
            
              ASSIGN aux_savedado = TRUE.  
              /* Limpa a tabela */
              FOR EACH crapeap WHERE crapeap.cdagenci = INTEGER(ab_unmap.aux_cdagenci)
                                 AND crapeap.cdcooper = INTEGER(ab_unmap.aux_cdcooper)
                                 AND crapeap.dtanoage = INTEGER(ab_unmap.aux_dtanoage)
                                 AND crapeap.idevento = INTEGER(ab_unmap.aux_idevento) EXCLUSIVE-LOCK:
                DELETE crapeap.
              END.
                 
              DO i = 1 TO NUM-ENTRIES(ab_unmap.aux_lsevento,";"):
                
                 FIND crapeap WHERE crapeap.cdagenci = INTEGER(ab_unmap.aux_cdagenci)
                                AND crapeap.cdcooper = INTEGER(ab_unmap.aux_cdcooper)
                                AND crapeap.cdevento = INTEGER(ENTRY(1,ENTRY(i,ab_unmap.aux_lsevento,";"),","))
                                AND crapeap.dtanoage = INTEGER(ab_unmap.aux_dtanoage)
                                AND crapeap.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-ERROR NO-WAIT.
                                 
                 IF NOT AVAILABLE crapeap THEN                         
                   DO:
                     /* Busca o evento para ver se é integração */
                     FIND crapedp WHERE 
                          crapedp.cdcooper = INT(ab_unmap.aux_cdcooper)                            AND
                          crapedp.cdevento = INT(ENTRY(1,ENTRY(i,ab_unmap.aux_lsevento,";"),","))  AND
                          crapedp.idevento = INT(ab_unmap.aux_idevento)                            AND
                          crapedp.dtanoage = INT(ab_unmap.aux_dtanoage)                            AND
                          crapedp.tpevento = 2 /*integração*/ NO-LOCK NO-ERROR. 
                      
                     CREATE crapeap.
                     ASSIGN crapeap.cdagenci = INTEGER(ab_unmap.aux_cdagenci)
                            crapeap.cdcooper = INTEGER(ab_unmap.aux_cdcooper)
                            crapeap.cdevento = INTEGER(ENTRY(1,ENTRY(i,ab_unmap.aux_lsevento,";"),","))
                            crapeap.dtanoage = INTEGER(ab_unmap.aux_dtanoage)
                            crapeap.flgevobr = LOGICAL(ENTRY(2,ENTRY(i,ab_unmap.aux_lsevento,";"),","))
                            crapeap.flgevsel = IF AVAIL crapedp THEN TRUE
                                                                ELSE FALSE /* PAC ainda não escolheu */
                            crapeap.idevento = INTEGER(ab_unmap.aux_idevento).
                     VALIDATE crapeap.     
                   END.      
              END. /* Fim DO*/    
            
          END. /* IF inlcusao*/
      END. /* DO WITH FRAME {&FRAME-NAME} */
     
      /* Deleta a instância da BO */
      DELETE PROCEDURE h-b1wpgd0014b NO-ERROR.
     
    END. /* IF VALID-HANDLE(h-b1wpgd0014b) */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
/* Se BO foi instanciada (no local-assign-record) */
    
  IF VALID-HANDLE(h-b1wpgd0014b)   THEN
    DO:
      /* Apaga todos os registros do evento para os PAC'S */
      FOR EACH crapeap WHERE crapeap.cdcooper = INTEGER(ab_unmap.aux_cdcooper)   AND
                             crapeap.idevento = INTEGER(ab_unmap.aux_idevento)   AND
                             crapeap.dtanoage = INTEGER(ab_unmap.aux_dtanoage)   AND
                             crapeap.cdagenci = INTEGER(ab_unmap.aux_cdagenci)   NO-LOCK:

        /* Limpa a tabela temporária */
        EMPTY TEMP-TABLE crateap.

        CREATE crateap.
        BUFFER-COPY crapeap TO crateap.
        
        RUN exclui-registro IN h-b1wpgd0014b(INPUT TABLE crateap, OUTPUT msg-erro).

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

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES*/
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + v-identificacao + "*" NO-LOCK:
    LEAVE.
END.
  
ASSIGN opcao                 = GET-FIELD("aux_cddopcao")
       FlagPermissoes        = GET-VALUE("aux_lspermis")
       msg-erro-aux          = 0
       ab_unmap.aux_idevento = GET-VALUE("aux_idevento")
       ab_unmap.aux_dsendurl = AppURL                        
       ab_unmap.aux_lspermis = FlagPermissoes                
       ab_unmap.aux_nrdrowid = GET-VALUE("aux_nrdrowid")         
       ab_unmap.aux_stdopcao = GET-VALUE("aux_stdopcao")
       ab_unmap.aux_cdagenci = GET-VALUE("aux_cdagenci")
       ab_unmap.aux_lsevento = GET-VALUE("aux_lsevento")
       /* COOPERATIVA do Usuário */
       ab_unmap.glb_cdcooper = GET-VALUE("glb_cdcooper")
       /* COOPERATIVA que está sendo trabalhada */
       ab_unmap.aux_cdcooper = GET-VALUE("aux_cdcooper")
       ab_unmap.aux_dtanoage = GET-VALUE("aux_dtanoage").

RUN outputHeader.

/* Busca o ano da Agenda */
FIND LAST gnpapgd WHERE gnpapgd.idevento = INTEGER(ab_unmap.aux_idevento)  AND 
                        gnpapgd.cdcooper = INTEGER(ab_unmap.aux_cdcooper)  AND 
                        gnpapgd.dtanonov = INTEGER(ab_unmap.aux_dtanoage)  NO-LOCK NO-ERROR.

IF NOT AVAILABLE gnpapgd THEN
   FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                           gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR.

IF AVAILABLE gnpapgd   THEN
  ab_unmap.aux_dtanoage = STRING(gnpapgd.dtanonov).

/* método POST */
IF REQUEST_METHOD = "POST":U   THEN 
  DO:
    CASE opcao:
      WHEN "sa" THEN /* salvar */
        IF ab_unmap.aux_stdopcao = "i" THEN /* inclusao */
          DO:
            RUN local-assign-record("inclusao").                                        
              
              IF msg-erro <> "" THEN
                ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
              ELSE 
                ASSIGN msg-erro-aux          = 10
                       ab_unmap.aux_stdopcao = "al"
                       opcao                 = "al".
          END. /* fim inclusao */
    END CASE.
     
    CASE msg-erro-aux:
      WHEN 10 THEN
        DO:
          RUN RodaJavaScript('window.opener.Recarrega();').
          RUN RodaJavaScript('self.close();').
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
          RUN CriaListaEventos.
          RUN displayFields.
          RUN enableFields.
          RUN outputFields.
        END. /* fim otherwise */                  
    END CASE. 
      
END. /* fim do método GET */

/* Show error messages. */
IF AnyMessage() THEN 
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