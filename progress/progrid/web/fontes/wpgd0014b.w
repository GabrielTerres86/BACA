/*...............................................................................

Alterações: 05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
						 busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).

            10/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
            10/08/2015 - Ajustes para projeto 229 - Melhorias OQS (Jean Michel).                      

            08/03/2016 - Alterado para que os eventos do tipo EAD 
                         e EAD Assemblear não sejam apresentados.
                         Projeto 229 - Melhorias OQS (Lombardi)
                         
           03/06/2016 - Criação da variável aux_flgevsel (Vanessa)
           
           31/01/2017 - Alterar o label “Max. Participante” por “Meta do PA”,
                        Prj. 229 (Jean Michel).
                        
...............................................................................*/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_cdcooper AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lsagenci AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
       FIELD glb_cdcooper AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_qtmaxtur AS CHARACTER FORMAT "X(256)":U 
       FIELD nmevento AS CHARACTER FORMAT "X(256)":U
       FIELD aux_cdcopope AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_cdoperad AS CHARACTER FORMAT "X(256)":U.

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

DEFINE VARIABLE ProgramaEmUso         AS CHARACTER INITIAL ["wpgd0014b"].
DEFINE VARIABLE NmeDoPrograma         AS CHARACTER INITIAL ["wpgd0014b.w"].

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

DEFINE VARIABLE vetorpacs             AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE aux_ttcabeca          AS INTEGER                        NO-UNDO.
DEFINE VARIABLE aux_dsorigem          AS CHARACTER     EXTENT 99        NO-UNDO.
DEFINE VARIABLE aux_qtorigem          AS INTEGER       EXTENT 99        NO-UNDO.
DEFINE VARIABLE aux_qttotpac          AS INTEGER                        NO-UNDO.
DEFINE VARIABLE aux_qttotdes          AS INTEGER                        NO-UNDO.
DEFINE VARIABLE aux_flgexist          AS LOGICAL                        NO-UNDO.
DEFINE VARIABLE aux_flgtdpac          AS LOGICAL                        NO-UNDO.
DEFINE VARIABLE aux_qtmaxtur          AS INTEGER   INIT 0               NO-UNDO.
DEFINE VARIABLE aux_flgevsel          AS LOGICAL   INIT FALSE           NO-UNDO.
DEFINE VARIABLE aux_nrocoeve          AS INTEGER   INIT 0               NO-UNDO.

DEFINE TEMP-TABLE cratagp NO-UNDO
       FIELD cdagenci LIKE crapage.cdagenci
       FIELD nmresage LIKE crapage.nmresage
       INDEX cratagp1 AS PRIMARY UNIQUE cdagenci.

/*** Declaração de BOs ***/
DEFINE VARIABLE h-b1wpgd0014b         AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE crateap NO-UNDO     LIKE crapeap.

/*** BUFFER'S ***/
DEFINE BUFFER crabsdp FOR crapsdp.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0014b.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.nmevento ab_unmap.aux_lsagenci ~
ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ab_unmap.aux_cdevento ~
ab_unmap.aux_dsendurl ab_unmap.aux_idevento ab_unmap.aux_lspermis ~
ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ab_unmap.glb_cdcooper ~
ab_unmap.aux_dtanoage ab_unmap.aux_qtmaxtur ab_unmap.aux_cdcopope ~
ab_unmap.aux_cdoperad 
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.nmevento ab_unmap.aux_lsagenci ~
ab_unmap.aux_cdcooper ab_unmap.aux_cddopcao ab_unmap.aux_cdevento ~
ab_unmap.aux_dsendurl ab_unmap.aux_idevento ab_unmap.aux_lspermis ~
ab_unmap.aux_nrdrowid ab_unmap.aux_stdopcao ab_unmap.glb_cdcooper ~
ab_unmap.aux_dtanoage ab_unmap.aux_qtmaxtur ab_unmap.aux_cdcopope ~
ab_unmap.aux_cdoperad 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */
/* Definitions of the field level widgets                               */
/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.nmevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_lsagenci AT ROW 1 COL 1 HELP
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
     ab_unmap.aux_cdevento AT ROW 1 COL 1 HELP
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
     ab_unmap.aux_qtmaxtur AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdcopope AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.aux_cdoperad AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
         
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 46.4 BY 12.43.

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
          FIELD aux_cdcooper AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cddopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_cdevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lsagenci AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_nrdrowid AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_stdopcao AS CHARACTER FORMAT "X(256)":U 
          FIELD glb_cdcooper AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_qtmaxtur AS CHARACTER FORMAT "X(256)":U  
          FIELD nmevento AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 12.43
         WIDTH              = 46.4.
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
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdcooper IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cddopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_cdevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dtanoage IN FRAME Web-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lsagenci IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_nrdrowid IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_stdopcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.glb_cdcooper IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.nmevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.qtmaxtur IN FRAME Web-Frame
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE CriaListaPacs w-html 
PROCEDURE CriaListaPacs :
    
    ASSIGN vetorpacs    = ""
           aux_ttcabeca = 0
           aux_qttotpac = 0
           aux_qttotdes = 0.
    
    RUN RodaJavaScript("var mpacs = new Array();").
    
    /* Limpa a tabela temporária */
    EMPTY TEMP-TABLE cratagp.
        
    /* Faz o agrupamento dos PA'S */
    /* PA's agrupadores */
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
                        cratagp.nmresage = crapage.nmresage WHEN AVAILABLE crapage.
             END.            
        
    END.
    
    /* PA's agrupados */
    FOR EACH crapagp WHERE crapagp.idevento = INTEGER(ab_unmap.aux_idevento)  
                       AND crapagp.cdcooper = INTEGER(ab_unmap.aux_cdcooper)  
                       AND crapagp.dtanoage = INTEGER(ab_unmap.aux_dtanoage)   
                       AND crapagp.cdageagr <> crapagp.cdagenci               NO-LOCK:
    
        FIND crapage WHERE crapage.cdcooper = crapagp.cdcooper   AND
                           crapage.cdagenci = crapagp.cdagenci   NO-LOCK NO-ERROR NO-WAIT.
    
        FIND cratagp WHERE cratagp.cdagenci = crapagp.cdageagr EXCLUSIVE-LOCK NO-ERROR.
    
        ASSIGN cratagp.nmresage = cratagp.nmresage + " / " + 
                                  (IF AVAIL crapage THEN crapage.nmresage ELSE "").
                                  
                                              
    END.    
    
    /* Nome do EVENTO */
    FIND crapedp WHERE crapedp.cdcooper = INTEGER(ab_unmap.aux_cdcooper)   
                   AND crapedp.idevento = INTEGER(ab_unmap.aux_idevento)   
                   AND crapedp.dtanoage = INTEGER(ab_unmap.aux_dtanoage)   
                   AND crapedp.cdevento = INTEGER(ab_unmap.aux_cdevento)   
                   AND crapedp.tpevento <> 10                              
                   AND crapedp.tpevento <> 11 NO-LOCK NO-ERROR NO-WAIT.

    /* cabeçalho */
    If available crapedp Then
      vetorpacs = "~{nmevento:'" + crapedp.nmevento + "',nmresage:'PA',cdagenci:'0'" + ",qtmaxtur:'Meta do PA'~}".    
    Else
      vetorpacs = "~{nmevento:' ',nmresage:'PA',cdagenci:'0'" + ",qtmaxtur:'Meta do PA'~}".    
      
      
    /* Monta a tabela dos PA'S */
    FOR EACH cratagp NO-LOCK BY cratagp.nmresage:
    
        aux_flgexist = FALSE.
    
        /* Carrega o array com as sugestões do evento */
        FOR EACH crapsdp WHERE crapsdp.idevento = INTEGER(ab_unmap.aux_idevento)  AND
                               crapsdp.cdevento = INTEGER(ab_unmap.aux_cdevento)  AND
                               crapsdp.dtanoage = ?                               AND
                               crapsdp.cdcooper = INTEGER(ab_unmap.aux_cdcooper)  AND
                              (crapsdp.cdagenci = cratagp.cdagenci                OR
                               /* sugestoes comuns a todos os PA'S */
                               crapsdp.cdagenci = 0)                              NO-LOCK
                               BREAK BY crapsdp.cdevento
                                     BY crapsdp.cdorisug:                       
               
           aux_flgexist = TRUE.
                
           IF LAST-OF(crapsdp.cdevento) THEN
               DO:
                  /* Carrega, também, as sugenstões dos PA'S que foram agrupados a este */
                  IF   crapsdp.cdagenci <> 0   THEN
                       FOR EACH crapagp WHERE crapagp.idevento  = crapsdp.idevento   AND
                                              crapagp.cdcooper  = crapsdp.cdcooper   AND
                                              crapagp.dtanoage  = crapsdp.dtanoage   AND
                                              crapagp.cdageagr  = crapsdp.cdagenci   AND
                                              crapagp.cdagenci <> crapsdp.cdagenci   NO-LOCK:
                           
                           FOR EACH crabsdp WHERE crabsdp.idevento = INTEGER(ab_unmap.aux_idevento)  AND
                                                  crabsdp.cdevento = INTEGER(ab_unmap.aux_cdevento)  AND
                                                  crabsdp.dtanoage = ?                               AND
                                                  crabsdp.cdcooper = INTEGER(ab_unmap.aux_cdcooper)  AND
                                                  crabsdp.cdagenci = crapagp.cdagenci                NO-LOCK:
                    
                                aux_flgexist = TRUE.                               
                           END.
                
                       END.
                  /* atribui os valores somados no vetor */
                  vetorpacs = vetorpacs + ",~{nmresage:'" + cratagp.nmresage + "',cdagenci:'" + STRING(cratagp.cdagenci) + "'".
        
               END.                
    
        END.
    
        /* Cria o PA mesmo sem ter sugestões */
        IF aux_flgexist = FALSE THEN
          DO:
            ASSIGN vetorpacs = vetorpacs + ",~{nmresage:'" + cratagp.nmresage + "',cdagenci:'" + STRING(cratagp.cdagenci) + "'".
          END.
    
        /* Verifica se o PA já está escolhido */
        FIND crapeap WHERE crapeap.cdcooper = INTEGER(ab_unmap.aux_cdcooper)
                       AND crapeap.idevento = INTEGER(ab_unmap.aux_idevento)
                       AND crapeap.cdagenci = cratagp.cdagenci                 
                       AND crapeap.cdevento = INTEGER(ab_unmap.aux_cdevento)
                       AND crapeap.dtanoage = INTEGER(ab_unmap.aux_dtanoage) NO-LOCK NO-ERROR NO-WAIT.
    
        /* Obrigatoriedade escolhida para o PA */
        IF AVAILABLE crapeap THEN 
          DO:
            IF crapeap.qtmaxtur > 0 THEN  
              ASSIGN aux_qtmaxtur = crapeap.qtmaxtur.
            ELSE  
              ASSIGN aux_qtmaxtur = crapedp.qtmaxtur.
              
            ASSIGN vetorpacs = vetorpacs + ",qtmaxtur:'" + STRING(aux_qtmaxtur) + "',flgativo:'yes',flgevobr:'" + STRING(crapeap.flgevobr,"yes/no") + "'~}".
          END.
        /* Obrigatoriedade escolhida para a COOP */
        ELSE 
          DO:
            ASSIGN aux_qtmaxtur = crapedp.qtmaxtur
                   vetorpacs = vetorpacs + ",qtmaxtur:'" + STRING(aux_qtmaxtur) + "',flgativo:'no',flgevobr:'" + STRING(crapedp.flgtdpac,"yes/no") + "'~}".
          END.  

    END.

    RUN RodaJavaScript("mpacs.push(" + vetorpacs + ");"). 

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
    ("aux_cdcooper":U,"ab_unmap.aux_cdcooper":U,ab_unmap.aux_cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cddopcao":U,"ab_unmap.aux_cddopcao":U,ab_unmap.aux_cddopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdevento":U,"ab_unmap.aux_cdevento":U,ab_unmap.aux_cdevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtanoage":U,"ab_unmap.aux_dtanoage":U,ab_unmap.aux_dtanoage:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lsagenci":U,"ab_unmap.aux_lsagenci":U,ab_unmap.aux_lsagenci:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_nrdrowid":U,"ab_unmap.aux_nrdrowid":U,ab_unmap.aux_nrdrowid:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_stdopcao":U,"ab_unmap.aux_stdopcao":U,ab_unmap.aux_stdopcao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("glb_cdcooper":U,"ab_unmap.glb_cdcooper":U,ab_unmap.glb_cdcooper:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("glb_cdcooper":U,"ab_unmap.aux_qtmaxtur":U,ab_unmap.aux_qtmaxtur:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("nmevento":U,"ab_unmap.nmevento":U,ab_unmap.nmevento:HANDLE IN FRAME {&FRAME-NAME}).
    
   RUN htmAssociate
    ("aux_cdcopope":U,"ab_unmap.aux_cdcopope":U,ab_unmap.aux_cdcopope:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_cdoperad":U,"ab_unmap.aux_cdoperad":U,ab_unmap.aux_cdoperad:HANDLE IN FRAME {&FRAME-NAME}).   
    
     
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
                    /* Apaga todos os registros e recria somente os escolhidos */
                    RUN local-delete-record.
                                          
                    /* Pega os PA'S que foram escolhidos */
                    DO i = 1 TO NUM-ENTRIES(ab_unmap.aux_lsagenci,";"):
          
                       /* Limpa a tabela temporária */
                       /*EMPTY TEMP-TABLE crateap.*/
    
                       /* Busca o evento "genérico" */
                       /*FIND crapedp WHERE crapedp.cdcooper = 0                               AND
                                          crapedp.cdevento = INTEGER(ab_unmap.aux_cdevento)  AND
                                          crapedp.idevento = INTEGER(ab_unmap.aux_idevento)  AND
                                          crapedp.dtanoage = 0
                                          NO-LOCK NO-ERROR.
                                              
                       CREATE crateap.
                       ASSIGN crateap.cdagenci = INTEGER(ENTRY(1,ENTRY(i,ab_unmap.aux_lsagenci,";"),","))
                              crateap.cdcooper = INTEGER(ab_unmap.aux_cdcooper)
                              crateap.cdevento = INTEGER(ab_unmap.aux_cdevento)
                              crateap.dtanoage = INTEGER(ab_unmap.aux_dtanoage)
                              crateap.flgevobr = LOGICAL(ENTRY(2,ENTRY(i,ab_unmap.aux_lsagenci,";"),","))
                              crateap.flgevsel = IF crapedp.tpevento = 2 THEN TRUE  /* Integração já é escolhida */
                                                                         ELSE FALSE /* PA ainda não escolheu */
                              crateap.idevento = INTEGER(ab_unmap.aux_idevento)
                              crateap.qtmaxtur = INTEGER(ENTRY(3,ENTRY(i,ab_unmap.aux_lsagenci,";"),",")).
    
                       RUN inclui-registro IN h-b1wpgd0014b (INPUT TABLE crateap, OUTPUT msg-erro).*/
                       ASSIGN aux_flgevsel = FALSE.                      
                       
                       FIND crapeap WHERE crapeap.cdagenci = INTEGER(ENTRY(1,ENTRY(i,ab_unmap.aux_lsagenci,";"),","))
                                      AND crapeap.cdcooper = INTEGER(ab_unmap.aux_cdcooper)
                                      AND crapeap.cdevento = INTEGER(ab_unmap.aux_cdevento)
                                      AND crapeap.dtanoage = INTEGER(ab_unmap.aux_dtanoage)
                                      AND crapeap.idevento = INTEGER(ab_unmap.aux_idevento) NO-LOCK NO-ERROR NO-WAIT.
                                       
                       IF NOT AVAILABLE crapeap THEN                         
                         DO:
                           /* Busca o evento para ver se é integração */
                           FIND crapedp WHERE crapedp.cdcooper = 0                             
                                          AND crapedp.cdevento = INTEGER(ab_unmap.aux_cdevento)
                                          AND crapedp.idevento = INTEGER(ab_unmap.aux_idevento)
                                          AND crapedp.dtanoage = 0
                                          AND crapedp.tpevento <> 10
                                          AND crapedp.tpevento <> 11 NO-LOCK NO-ERROR. 
                           
                           FIND FIRST crapadp WHERE crapadp.cdagenci = INTEGER(ENTRY(1,ENTRY(i,ab_unmap.aux_lsagenci,";"),","))
                                                AND crapadp.cdcooper = INTEGER(ab_unmap.aux_cdcooper)
                                                AND crapadp.cdevento = INTEGER(ab_unmap.aux_cdevento)
                                                AND crapadp.dtanoage = INTEGER(ab_unmap.aux_dtanoage)
                                                AND crapadp.idevento = 1 NO-LOCK NO-ERROR NO-WAIT.
                           
                           IF AVAILABLE crapadp THEN
                              ASSIGN aux_flgevsel = TRUE.  
                          
                          ASSIGN aux_nrocoeve = 0.
                          
                          FOR EACH crapsde WHERE crapsde.cdagenci = INTEGER(ENTRY(1,ENTRY(i,ab_unmap.aux_lsagenci,";"),","))
                                                AND crapsde.cdcooper = INTEGER(ab_unmap.aux_cdcooper)
                                                AND crapsde.cdevento = INTEGER(ab_unmap.aux_cdevento)
                                                AND crapsde.dtanoage = INTEGER(ab_unmap.aux_dtanoage)
                                                AND crapsde.idevento = 1 NO-LOCK :
                                   ASSIGN aux_nrocoeve  =  aux_nrocoeve + 1.
                          END.
                            
                           IF aux_nrocoeve > 0 THEN
                              ASSIGN aux_flgevsel = TRUE.  
                           
                           CREATE crapeap.
                           ASSIGN crapeap.cdagenci = INTEGER(ENTRY(1,ENTRY(i,ab_unmap.aux_lsagenci,";"),","))
                                  crapeap.cdcooper = INTEGER(ab_unmap.aux_cdcooper)
                                  crapeap.cdevento = INTEGER(ab_unmap.aux_cdevento)
                                  crapeap.dtanoage = INTEGER(ab_unmap.aux_dtanoage)
                                  crapeap.flgevobr = LOGICAL(ENTRY(2,ENTRY(i,ab_unmap.aux_lsagenci,";"),","))
                                  crapeap.flgevsel = IF crapedp.tpevento = 2 THEN TRUE  /* Integração já é escolhida */
                                                                         ELSE aux_flgevsel /* PA ainda não escolheu */
                                  crapeap.idevento = INTEGER(ab_unmap.aux_idevento)
                                  crapeap.qtmaxtur = INTEGER(ENTRY(3,ENTRY(i,ab_unmap.aux_lsagenci,";"),","))
                                  crapeap.qtocoeve = aux_nrocoeve
                                  crapeap.cdcopope = INTEGER(ab_unmap.aux_cdcopope)
                                  crapeap.cdoperad =  STRING(ab_unmap.aux_cdoperad).
                           VALIDATE crapeap.     
                         END.
      
                    END.
    
                    /* Integrações - Cria um registro pra cada PA Agrupador */
                    FIND FIRST crapedp WHERE crapedp.tpevento  = 2 and
                                             crapedp.cdcooper <> 0 NO-LOCK NO-ERROR.
    
                    IF NOT AVAIL crapedp THEN LEAVE.
                    
                    FOR EACH crapagp WHERE crapagp.cdagenci = crapagp.cdageagr NO-LOCK:
    
    
                        /* Limpa a tabela temporária */
                        EMPTY TEMP-TABLE crateap.
                       
                        CREATE crateap.
                        ASSIGN crateap.cdagenci = crapagp.cdageagr
                               crateap.cdcooper = crapedp.cdcooper
                               crateap.cdevento = crapedp.cdevento
                               crateap.dtanoage = crapedp.dtanoage
                               crateap.flgevobr = YES
                               crateap.flgevsel = YES
                               crateap.idevento = crapedp.idevento.
    
                        FIND FIRST crapeap WHERE crapeap.cdagenci = crateap.cdagenci    AND
                                                 crapeap.cdcooper = crateap.cdcooper    AND
                                                 crapeap.cdevento = crateap.cdevento    AND
                                                 crapeap.dtanoage = crateap.dtanoage    AND
                                                 crapeap.idevento = crateap.idevento    NO-LOCK NO-ERROR.
    
                        IF AVAILABLE crapeap THEN NEXT.
    
                        RUN inclui-registro IN h-b1wpgd0014b (INPUT TABLE crateap, OUTPUT msg-erro).
    
                    END.
    
                    /* Fim - Integrações */
    
                END.
          END. /* DO WITH FRAME {&FRAME-NAME} */
       
          /* "mata" a instância da BO */
          DELETE PROCEDURE h-b1wpgd0014b NO-ERROR.
       
       END. /* IF VALID-HANDLE(h-b1wpgd0014b) */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :
/* Se BO foi instanciada (no local-assign-record) */
    IF VALID-HANDLE(h-b1wpgd0014b) THEN
       DO:
          /* Apaga todos os registros do evento para os PA'S */
          FOR EACH crapeap WHERE crapeap.cdcooper = INTEGER(ab_unmap.aux_cdcooper) AND
                                 crapeap.idevento = INTEGER(ab_unmap.aux_idevento) AND
                                 crapeap.dtanoage = INTEGER(ab_unmap.aux_dtanoage) AND
                                 crapeap.cdevento = INTEGER(ab_unmap.aux_cdevento) NO-LOCK:
    
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

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
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
       ab_unmap.aux_cdevento = GET-VALUE("aux_cdevento")
       ab_unmap.aux_lsagenci = GET-VALUE("aux_lsagenci")
       /* COOPERATIVA do Usuário */
       ab_unmap.glb_cdcooper = GET-VALUE("glb_cdcooper")
       /* COOPERATIVA que está sendo trabalhada */
       ab_unmap.aux_cdcooper = GET-VALUE("aux_cdcooper")
       ab_unmap.aux_dtanoage = GET-VALUE("aux_dtanoage")
       ab_unmap.aux_cdcopope = GET-VALUE("aux_cdcopope")
       ab_unmap.aux_cdoperad = GET-VALUE("aux_cdoperad").

RUN outputHeader.

/* Busca o ano da Agenda */
FIND LAST gnpapgd WHERE gnpapgd.idevento = INTEGER(ab_unmap.aux_idevento)  AND 
                        gnpapgd.cdcooper = INTEGER(ab_unmap.aux_cdcooper)  AND 
                        gnpapgd.dtanonov = INTEGER(ab_unmap.aux_dtanoage)  NO-LOCK NO-ERROR.

IF NOT AVAILABLE gnpapgd THEN
   FIND LAST gnpapgd WHERE gnpapgd.idevento = INT(ab_unmap.aux_idevento) AND 
                           gnpapgd.cdcooper = INT(ab_unmap.aux_cdcooper) NO-LOCK NO-ERROR.

IF   AVAILABLE gnpapgd   THEN
     ab_unmap.aux_dtanoage = STRING(gnpapgd.dtanonov).

/* método POST */
IF   REQUEST_METHOD = "POST":U   THEN 
     DO:
        RUN inputFields.

        CASE opcao:
             WHEN "sa" THEN /* salvar */
                  IF   ab_unmap.aux_stdopcao = "i"   THEN /* inclusao */
                       DO:
                          RUN local-assign-record ("inclusao").                                        
                      
                          IF   msg-erro <> ""   THEN
                               ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                          ELSE 
                               ASSIGN msg-erro-aux          = 10
                                      ab_unmap.aux_stdopcao = "al".
                       END. /* fim inclusao */
             OTHERWISE
                  DO:
                      RUN CriaListaPacs.
                      RUN displayFields.
                      RUN enableFields.
                      RUN outputFields.
                  END.
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
                    RUN CriaListaPacs.
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