/*.............................................................................

   Programa: siscaixa/web/crap022c.w
   Sistema : Caixa On-Line
   Autor   : Andre Santos - Supero
   Data    : Junho/2014                      Ultima atualizacao: 27/06/2017

   Dados referentes ao programa:

   Frequencia:  Diario (on-line)
   Objetivo  :  Transferencia e deposito entre cooperativas.

   Alteracoes: 17/11/2015 #345791 Melhoria no recebimento das variaveis do form
                          (Carlos)
               
               27/06/2017 - Retiradas conticoes que tratam a praça do cheque e os números DE 
                           documento 3,4 e 5. PRJ367 - Compe Sessao Unica (Lombardi)
                           
-----------------------------------------------------------------------------*/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD TpDocto AS CHARACTER FORMAT "X(256)":U
       FIELD vh_doc AS CHARACTER FORMAT "X(256)":U 
       FIELD vh_foco AS CHARACTER FORMAT "X(256)":U
       FIELD vh_TpDoctoAnt AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_codcoop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cpfcgc1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cpfcgc2 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cooppara AS CHARACTER FORMAT "X(256)":U
       FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nome1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nome2 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nroconta AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
       FIELD v_vlrdocumento AS CHARACTER FORMAT "X(256)":U
       FIELD v_btn_ok AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msgsaldo AS CHARACTER FORMAT "X(256)":U
       FIELD v_identificador AS CHARACTER FORMAT "X(256)":U
       FIELD v_chequescoop AS CHARACTER FORMAT "X(256)":U
       FIELD v_totdepos AS CHARACTER FORMAT "X(256)":U
       FIELD v_qtdchqs AS CHARACTER FORMAT "X(256)":U.
       
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS w-html 


CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Preprocessor Definitions ---                                         */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
                                
{dbo/bo-erro1.i} 

DEF VAR i-tipo-doc      AS INTE                        NO-UNDO.
DEF VAR p-nro-docto     AS INTE                        NO-UNDO.
DEF VAR p-histor        AS INTE                        NO-UNDO.
DEF VAR aux_vllanmto    AS DECI                        NO-UNDO.
DEF VAR aux_nrdconta    AS INTE                        NO-UNDO.
DEF VAR aux_mensagem    AS CHAR                        NO-UNDO.
DEF VAR p-programa      AS CHAR INITIAL "CRAP022c"     NO-UNDO.
DEF VAR p-flgdebcc      AS CHAR INITIAL FALSE          NO-UNDO.

DEF VAR aux_vlsddisp    AS DECI                        NO-UNDO.

DEF VAR p-literal       AS CHAR                        NO-UNDO.
DEF VAR p-ult-sequencia AS INTE                        NO-UNDO.
DEF VAR p-nrdocmto      AS DECI                        NO-UNDO.
DEF VAR p-nrdoccre      AS DECI                        NO-UNDO.
DEF VAR p-cdlantar      LIKE craplat.cdlantar          NO-UNDO.
DEF VAR aux_tpdmovto    AS INTE                        NO-UNDO.

DEF VAR p-nro-lote      AS INTE                        NO-UNDO.
DEF VAR p-nrultaut      AS INTE                        NO-UNDO.
DEF VAR i-cpfcgc-de     AS DEC FORMAT "zzzzzzzzzzzzz9" NO-UNDO.
DEF VAR i-cpfcgc-para   AS dec FORMAT "zzzzzzzzzzzzz9" NO-UNDO.
DEF VAR l-recibo        AS LOG NO-UNDO.

DEF VAR h-b1crap00      AS HANDLE                      NO-UNDO.
DEF VAR h-b1crap51      AS HANDLE                      NO-UNDO.
DEF VAR h-b1crap22      AS HANDLE                      NO-UNDO.

DEF VAR l-houve-erro    AS LOG                         NO-UNDO.
DEF VAR p-aviso-cx      AS LOG                         NO-UNDO.

DEF VAR v_nmtitular1    AS CHAR                        NO-UNDO.  
DEF VAR v_nrcpfcgc1     AS CHAR                        NO-UNDO.
DEF VAR v_nmtitular2    AS CHAR                        NO-UNDO.  
DEF VAR v_nrcpfcgc2     AS CHAR                        NO-UNDO.

DEF VAR aux_nmcoppara   AS CHAR                        NO-UNDO. 
DEF VAR aux_cdcoppara   AS INTE                        NO-UNDO.

DEF VAR aux_reciddeb    AS RECID                       NO-UNDO.
DEF VAR aux_recidcre    AS RECID                       NO-UNDO.

DEF VAR v_nrodocmto             AS INTE                NO-UNDO.
DEF VAR v_literal_autentica     AS CHAR                NO-UNDO.
DEF VAR v_ult_seq_autentica     AS INTE                NO-UNDO.
DEF VAR v_flg-cta-migrada       AS LOGICAL             NO-UNDO.
DEF VAR v_flg-coop-host         AS LOGICAL             NO-UNDO.
DEF VAR v_coop-migrada          AS CHAR                NO-UNDO.
DEF VAR v_nrsequni              AS CHAR                NO-UNDO.
DEF VAR v_dtenvelo              AS CHAR                NO-UNDO.
DEF VAR aux_achou               AS LOGI                NO-UNDO. 
DEF VAR vetorcheque             AS CHAR                NO-UNDO.

DEF TEMP-TABLE tt-erro NO-UNDO LIKE craperr.

DEF BUFFER crabcop FOR crapcop.


DEF TEMP-TABLE w-craperr                               NO-UNDO
     FIELD cdcooper   LIKE craperr.cdcooper
     FIELD cdagenci   LIKE craperr.cdagenc
     FIELD nrdcaixa   LIKE craperr.nrdcaixa
     FIELD nrsequen   LIKE craperr.nrsequen
     FIELD cdcritic   LIKE craperr.cdcritic
     FIELD dscritic   LIKE craperr.dscritic
     FIELD erro       LIKE craperr.erro.

DEFINE TEMP-TABLE tt-cheques NO-UNDO
       FIELD dtlibera AS DATE
       FIELD nrdocmto AS INTE
       FIELD vlcompel AS DECI
       INDEX tt-cheques1 nrdocmto dtlibera.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE crap022c.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.v_codcoop ab_unmap.v_nroconta ab_unmap.v_cooppara ab_unmap.v_nome1 ab_unmap.v_nome2 ab_unmap.v_cpfcgc1 ab_unmap.v_cpfcgc2 ab_unmap.TpDocto ab_unmap.vh_doc ab_unmap.vh_foco ab_unmap.vh_TpDoctoAnt ab_unmap.v_caixa ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_vlrdocumento ab_unmap.v_btn_ok ab_unmap.v_msgsaldo ab_unmap.v_identificador ab_unmap.v_chequescoop ab_unmap.v_totdepos ab_unmap.v_qtdchqs
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.v_codcoop ab_unmap.v_nroconta ab_unmap.v_cooppara ab_unmap.v_nome1 ab_unmap.v_nome2 ab_unmap.v_cpfcgc1 ab_unmap.v_cpfcgc2 ab_unmap.TpDocto ab_unmap.vh_doc ab_unmap.vh_foco ab_unmap.vh_TpDoctoAnt ab_unmap.v_caixa ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_vlrdocumento ab_unmap.v_btn_ok ab_unmap.v_msgsaldo ab_unmap.v_identificador ab_unmap.v_chequescoop ab_unmap.v_totdepos ab_unmap.v_qtdchqs

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.v_codcoop AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nroconta AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cooppara AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.v_nome1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nome2 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cpfcgc1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cpfcgc2 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.TpDocto AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
           "TpDocto 1", "Deposito":U,
           "TpDocto 3", "Cheque":U,
           "TpDocto 2", "Transferencia":U
          SIZE 20 BY 4
     ab_unmap.vh_doc AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 60.6 BY 14.19.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Web-Frame
     ab_unmap.vh_foco AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.vh_TpDoctoAnt AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_caixa AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_coop AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_data AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_msg AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_operador AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_pac AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_vlrdocumento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_btn_ok AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_msgsaldo AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_identificador AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_chequescoop  AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_totdepos  AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_qtdchqs  AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 60.6 BY 14.19.


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
          FIELD TpDocto AS CHARACTER 
          FIELD vh_doc AS CHARACTER FORMAT "X(256)":U 
          FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
          FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
          FIELD v_codcoop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cpfcgcde AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cpfcgc1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cpfcgc2 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cooppara AS CHARACTER 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nomede AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nome1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nome2 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nrocontade AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nroconta AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valordocumento AS CHARACTER FORMAT "X(256)":U    
          FIELD v_identificador AS CHARACTER FORMAT "X(256)":U    
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 14.19
         WIDTH              = 60.6.
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
/* SETTINGS FOR RADIO-SET ab_unmap.TpDocto IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.vh_doc IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.vh_foco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_caixa IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_codcoop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cpfcgcde IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cpfcgc1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cpfcgc2 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR SELECTION-LIST ab_unmap.v_cooppara IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nomede IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nome1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nome2 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nrocontade IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nroconta IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_valordocumento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_identificador IN FRAME Web-Frame
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects w-html  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE carregaCooperativa w-html 
PROCEDURE carregaCooperativa :
    
    DEFINE INPUT PARAMETER pTpDocto AS CHAR NO-UNDO.

    DEFINE VARIABLE cListAux  AS CHARACTER  NO-UNDO INITIAL ''.
    
    IF  pTpDocto = 'Cheque' THEN DO: 
        FOR EACH crabcop WHERE crabcop.cdcooper <> 3
                           AND crabcop.cdcooper <> crapcop.cdcooper
                           NO-LOCK:
            
             ASSIGN cListAux = cListAux +
                               (IF cListAux = '' THEN '' ELSE ',') +
                               STRING(crabcop.nmrescop) + ',' +
                               STRING(crabcop.nmrescop).
        END.
    END.
    
    ASSIGN v_cooppara:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = cListAux.

    RETURN 'OK'.

END PROCEDURE.

PROCEDURE reinicia-crapmdw:
    
    DEF INPUT PARAM p-cod-agencia AS INT NO-UNDO.
    DEF INPUT PARAM p-nr-caixa    AS INT NO-UNDO.
    
    FOR EACH crapmdw WHERE crapmdw.cdcooper   = crapcop.cdcooper AND
                           crapmdw.cdagenci   = p-cod-agencia    AND 
                           crapmdw.nrdcaixa   = p-nr-caixa       EXCLUSIVE-LOCK:
        ASSIGN crapmdw.inautent = NO.
    END.

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
    ("TpDocto":U,"ab_unmap.TpDocto":U,ab_unmap.TpDocto:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("vh_doc":U,"ab_unmap.vh_doc":U,ab_unmap.vh_doc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("vh_foco":U,"ab_unmap.vh_foco":U,ab_unmap.vh_foco:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("vh_TpDoctoAnt":U,"ab_unmap.vh_TpDoctoAnt":U,ab_unmap.vh_TpDoctoAnt:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_caixa":U,"ab_unmap.v_caixa":U,ab_unmap.v_caixa:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_codcoop":U,"ab_unmap.v_codcoop":U,ab_unmap.v_codcoop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cpfcgc1":U,"ab_unmap.v_cpfcgc1":U,ab_unmap.v_cpfcgc1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cpfcgc2":U,"ab_unmap.v_cpfcgc2":U,ab_unmap.v_cpfcgc2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cooppara":U,"ab_unmap.v_cooppara":U,ab_unmap.v_cooppara:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nome1":U,"ab_unmap.v_nome1":U,ab_unmap.v_nome1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nome2":U,"ab_unmap.v_nome2":U,ab_unmap.v_nome2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nroconta":U,"ab_unmap.v_nroconta":U,ab_unmap.v_nroconta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_vlrdocumento":U,"ab_unmap.v_vlrdocumento":U,ab_unmap.v_vlrdocumento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_btn_ok":U,"ab_unmap.v_btn_ok":U,ab_unmap.v_btn_ok:HANDLE IN FRAME {&FRAME-NAME}).   
  RUN htmAssociate
    ("v_msgsaldo":U,"ab_unmap.v_msgsaldo":U,ab_unmap.v_msgsaldo:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_identificador":U,"ab_unmap.v_identificador":U,ab_unmap.v_identificador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_chequescoop":U,"ab_unmap.v_chequescoop":U,ab_unmap.v_chequescoop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_totdepos":U,"ab_unmap.v_totdepos":U,ab_unmap.v_totdepos:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_qtdchqs":U,"ab_unmap.v_qtdchqs":U,ab_unmap.v_qtdchqs:HANDLE IN FRAME {&FRAME-NAME}).

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

  /* To make this a state-aware Web object, pass in the timeout period
   * (in minutes) before running outputContentType.  If you supply a 
   * timeout period greater than 0, the Web object becomes state-aware 
   * and the following happens:
   *
   *   - 4GL variables webState and webTimeout are set
   *   - a cookie is created for the broker to id the client on the return trip
   *   - a cookie is created to id the correct procedure on the return trip
   *
   * If you supply a timeout period less than 1, the following happens:
   *
   *   - 4GL variables webState and webTimeout are set to an empty string
   *   - a cookie is killed for the broker to id the client on the return trip
   *   - a cookie is killed to id the correct procedure on the return trip
   *
   * For example, set the timeout period to 5 minutes.
   *
   *   setWebState (5.0).
   */
    
  /* Output additional cookie information here before running outputContentType.
   *   For more information about the Netscape Cookie Specification, see
   *   http://home.netscape.com/newsref/std/cookie_spec.html  
   *   
   *   Name         - name of the cookie
   *   Value        - value of the cookie
   *   Expires date - Date to expire (optional). See TODAY function.
   *   Expires time - Time to expire (optional). See TIME function.
   *   Path         - Override default URL path (optional)
   *   Domain       - Override default domain (optional)
   *   Secure       - "secure" or unknown (optional)
   * 
   *   The following example sets custNum=23 and expires tomorrow at (about)
   *   the same time but only for secure (https) connections.
   *      
   *   RUN SetCookie IN web-utilities-hdl 
   *     ("custNum":U, "23":U, TODAY + 1, TIME, ?, ?, "secure":U).
   */ 
  output-content-type ("text/html":U).
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-web-request w-html 
PROCEDURE process-web-request :
/*------------------------------------------------------------------------
  Purpose:     Process the web request.
  Notes:       
------------------------------------------------------------------------*/

    DEFINE VARIABLE lOpenAutentica  AS LOGICAL      NO-UNDO INITIAL NO.

    RUN outputHeader.
    {include/i-global.i}

    IF  REQUEST_METHOD = 'POST':U THEN DO:

        RUN inputFields.

        {include/assignfields.i}

        RUN enableFields.

        /* Limpa os Campos */
        ASSIGN vh_foco           = '13' 
               v_btn_ok          = ''
               v_coop-migrada    = GET-VALUE("v_coop-migrada").

        IF UPPER(GET-VALUE("v_cta-migrada")) = 'YES' THEN
        v_flg-cta-migrada = YES.
        ELSE
        v_flg-cta-migrada = NO.
         
        IF UPPER(GET-VALUE("v_flg-coop-host")) = 'YES' THEN
        v_flg-coop-host = YES.
        ELSE
        v_flg-coop-host = NO.

        IF  get-value('cancela') <> '' THEN DO: /* Botao Cancela */

            /* Limpa os Campos */
            ASSIGN vh_foco           = '13' 
                   TpDocto           = 'Cheque'  
                   v_codcoop         = ''
                   v_cooppara        = ''
                   v_btn_ok          = ''
                   v_msgsaldo        = '' .
        
            RUN carregaCooperativa IN THIS-PROCEDURE ('Cheque').

        END.
        ELSE DO:

            RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.

            RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                               INPUT v_pac,
                                               INPUT v_caixa).

            DELETE PROCEDURE h-b1crap00.
          
            IF  RETURN-VALUE = "OK"  THEN DO:

                RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
                RUN  verifica-abertura-boletim IN h-b1crap00 (INPUT v_coop,
                                                              INPUT v_pac,
                                                              INPUT v_caixa,
                                                              INPUT v_operador).
                DELETE PROCEDURE h-b1crap00.
            END.
          
            IF   RETURN-VALUE = "NOK" THEN DO:
                 ASSIGN v_btn_ok = ''.
                 {include/i-erro.i}
            END.
            ELSE DO:
                       
                /* os valores dos selection-lists sao armazenados em variaveis
                hidden para depois serem resgatados para as variaves originais
                pois as lista de valores sao dinamicas e seus valores acabam se
                perdendo */
                ASSIGN v_cooppara     = v_codcoop
                       vh_TpDoctoAnt  = 'Cheque'.

                IF  tpDocto = 'Cheque'  THEN DO:

                    RUN carregaCooperativa IN THIS-PROCEDURE ('Cheque').

                    /*** Montar o Resumo ***/

                    FIND FIRST crapcop WHERE crapcop.nmrescop = v_coop
                                       NO-LOCK NO-ERROR.
            
                    RUN dbo/b1crap51.p PERSISTENT SET h-b1crap51.
            
                    RUN gera-tabela-resumo-cheques IN h-b1crap51(INPUT v_coop,
                                                                 INPUT INT(v_pac),
                                                                 INPUT INT(v_caixa),
                                                                 INPUT v_operador,
                                                                 INPUT INT(v_nroconta)).
            
                    DELETE PROCEDURE h-b1crap51.
            
                    /* Buscar os totais de Cheque Cooperativa */
                    FIND FIRST crapmrw WHERE crapmrw.cdcooper  = crapcop.cdcooper
                                         AND crapmrw.cdagenci  = INT(v_pac)
                                         AND crapmrw.nrdcaixa  = INT(v_caixa)
                                         NO-LOCK NO-ERROR.

                    IF  AVAIL crapmrw  THEN 
                        ASSIGN v_chequescoop = STRING(crapmrw.vlchqcop,"zzz,zzz,zzz,zz9.99")
                               v_totdepos    = STRING(DEC(v_totdepos) + crapmrw.vlchqcop,"zzz,zzz,zzz,zz9.99").
            
                    /* Buscar os totais de cheque maior e menor da Praca ou fora Praca */
                    FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper
                                       AND crapmdw.cdagenci = INT(v_pac)
                                       AND crapmdw.nrdcaixa = INT(v_caixa)
                                       NO-LOCK:
                            
                        ASSIGN v_qtdchqs = STRING(INT(v_qtdchqs) + 1).
                    
                        FIND tt-cheques WHERE tt-cheques.dtlibera = crapmdw.dtlibcom
                                          AND tt-cheques.nrdocmto = crapmdw.nrdocmto
                                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                    
                        IF  NOT AVAIL tt-cheques  THEN
                            CREATE tt-cheques.
                        
                        IF  crapmdw.cdhistor = 2433  THEN
                            ASSIGN tt-cheques.nrdocmto = 6
                                   tt-cheques.dtlibera = crapmdw.dtlibcom
                                   tt-cheques.vlcompel = tt-cheques.vlcompel + crapmdw.vlcompel
                                   v_totdepos = STRING(DEC(v_totdepos) + crapmdw.vlcompel,"zzz,zzz,zzz,zz9.99").
                        
                        FIND CURRENT tt-cheques NO-LOCK.
                        
                    END.

                    ASSIGN vetorcheque = "".
                    
                    FOR EACH tt-cheques WHERE tt-cheques.nrdocmto = 6  NO-LOCK:
                        
                          IF TRIM(vetorcheque) <> "" AND TRIM(vetorcheque) <> ? THEN
                              ASSIGN vetorcheque = vetorcheque + ",".
                                
                          ASSIGN vetorcheque = vetorcheque + "~{vlcheque:'" + TRIM(STRING(tt-cheques.vlcompel,"zzz,zzz,zzz,zz9.99"))
                                                           + "',dtcheque:'" + TRIM(STRING(tt-cheques.dtlibera,"99/99/99"))+ "'~}".
                    END.
                    
                    {&OUT} '<script language="JavaScript">var cheques = new Array(); cheques.push(' + STRING(vetorcheque) + ');</script>'.
        
                    IF  get-value('v_btn_ok') <> '' THEN DO:
                       ASSIGN l-houve-erro = NO.
                    END. /* Final do GET VALUE OK <> "" */
                    ELSE DO:
                        IF  get-value('retorna') <> '' THEN DO: /* Botao Deposito */

                            RUN carregaCooperativa IN THIS-PROCEDURE ('Cheque').

                            {&OUT} "<script language='JavaScript'>window.location='crap022b.p"
                                   "?v_cooppara="      + v_cooppara                   +
                                   "&v_nroconta="      + GET-VALUE("v_nroconta")      +
                                   "&v_vlrdocumento="  + GET-VALUE("v_vlrdocumento")  +
                                   "&v_identificador=" + GET-VALUE("v_identificador") +
                                   "&v_nome1="         + GET-VALUE("v_nome1")         +
                                   "&v_cpfcgc1="       + GET-VALUE("v_cpfcgc1")       +
                                   "&v_nome2="         + GET-VALUE("v_nome2")         +
                                   "&v_cpfcgc2="       + GET-VALUE("v_cpfcgc2")       +
                                   "&v_cta-migrada="   + STRING(v_flg-cta-migrada)    +
                                   "&v_coop-migrada="  + STRING(v_coop-migrada)       +
                                   "&v_flg-coop-host=" + STRING(v_flg-coop-host)      +
                                   "'</script>".
                        END.
                    END.
                END.
                ELSE
                IF  tpDocto = 'Deposito'  THEN DO:
                    IF  vh_TpDoctoAnt <> tpDocto  THEN DO:

                        FOR EACH crapmdw EXCLUSIVE-LOCK
                           WHERE crapmdw.cdcooper  = crapcop.cdcooper
                             AND crapmdw.cdagenci  = INT(v_pac)
                             AND crapmdw.nrdcaixa  = INT(v_caixa):
                            DELETE crapmdw.
                        END.
                        FOR EACH crapmrw EXCLUSIVE-LOCK
                            WHERE crapmrw.cdcooper = crapcop.cdcooper
                               AND crapmrw.cdagenci = INT(v_pac)
                               AND crapmrw.nrdcaixa = INT(v_caixa):
                              DELETE crapmrw.
                        END.

                        ASSIGN vh_TpDoctoAnt = 'Deposito'.

                        /* Volta a tela Principal Iniciando a Opercao */
                        {&OUT} "<script language='JavaScript'>window.location='crap022.w"      + 
                               "?tpDoctoSel=" + tpDocto                  +
                               "'</script>".
                    END.
                END.
                ELSE DO:  /** Transferencia **/
                    IF  vh_TpDoctoAnt <> tpDocto  THEN DO:

                        FOR EACH crapmdw EXCLUSIVE-LOCK
                           WHERE crapmdw.cdcooper  = crapcop.cdcooper
                             AND crapmdw.cdagenci  = INT(v_pac)
                             AND crapmdw.nrdcaixa  = INT(v_caixa):
                            DELETE crapmdw.
                        END.
                        FOR EACH crapmrw EXCLUSIVE-LOCK
                            WHERE crapmrw.cdcooper = crapcop.cdcooper
                               AND crapmrw.cdagenci = INT(v_pac)
                               AND crapmrw.nrdcaixa = INT(v_caixa):
                              DELETE crapmrw.
                        END.

                        ASSIGN vh_TpDoctoAnt = 'Transferencia'.

                        /* Volta a tela Principal Iniciando a Opercao */
                        {&OUT} "<script language='JavaScript'>window.location='crap022.w"      + 
                               "?tpDoctoSel=" + tpDocto                  +
                               "'</script>".
                    END.
                END. /** Fim transferencia **/
                     
                IF  get-value('v_btn_ok') <> '' AND NOT l-houve-erro THEN DO:
                    
                    ASSIGN l-houve-erro = NO.

MESSAGE "chw ENTROU " VIEW-AS ALERT-BOX INFO BUTTONS OK.

                    DO  WHILE TRUE:
                         
                         FIND FIRST crapass NO-LOCK WHERE
                                    crapass.cdcooper = crapcop.cdcooper  AND
                                    crapass.nrdconta = INT(v_nroconta) NO-ERROR.
                         
                         IF  NOT AVAIL crapass THEN
                             LEAVE.
                         
                         IF  AVAIL crapass THEN 
                             DO:
                                 IF  CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl))   THEN  
                                     DO:
                                         FIND FIRST craptrf WHERE craptrf.cdcooper = crapcop.cdcooper AND
                                                                  craptrf.nrdconta = crapass.nrdconta AND
                                                                  craptrf.tptransa = 1 AND
                                                                  craptrf.insittrs = 2 
                                                                  NO-LOCK USE-INDEX craptrf1 NO-ERROR.
                               
                                         IF AVAIL craptrf THEN
                                            ASSIGN v_nroconta = string(craptrf.nrsconta).
                                         ELSE
                                            LEAVE.
                                     END.
                                 ELSE
                                     LEAVE.       
                             END.
                    END.
                    DO:  
                        DO  TRANSACTION ON ERROR UNDO:
                   
                            RUN dbo/b1crap22.p PERSISTENT SET h-b1crap22.

                            IF  NOT v_flg-cta-migrada  THEN DO:

MESSAGE "chw ENTROU - CONTA NAO MIGRADA" VIEW-AS ALERT-BOX INFO BUTTONS OK.

                                RUN realiza-deposito-cheque IN h-b1crap22 (INPUT v_coop,                
                                                                           INPUT INT(v_pac),
                                                                           INPUT INT(v_caixa),
                                                                           INPUT v_operador,
                                                                           INPUT v_cooppara,
                                                                           INPUT v_nroconta, /* Cta Para*/
                                                                           INPUT 0,
                                                                           INPUT v_vlrdocumento,
                                                                           INPUT v_identificador,
                                                                           INPUT FALSE,
                                                                           OUTPUT v_nrodocmto,
                                                                           OUTPUT v_literal_autentica,
                                                                           OUTPUT v_ult_seq_autentica).
                            END.
                            ELSE DO:
                                IF  NOT v_flg-coop-host  THEN
                                DO: 
                                    MESSAGE "chw ENTROU - CONTA NAO coop host" VIEW-AS ALERT-BOX INFO BUTTONS OK.
                                    RUN realiza-deposito-cheque-migrado IN h-b1crap22 (INPUT v_coop,                
                                                                                       INPUT v_coop-migrada,
                                                                                       INPUT INT(v_pac),
                                                                                       INPUT INT(v_caixa),
                                                                                       INPUT v_operador,
                                                                                       INPUT v_cooppara,
                                                                                       INPUT v_nroconta, /* Cta Para*/
                                                                                       INPUT 0,
                                                                                       INPUT v_vlrdocumento,
                                                                                       INPUT v_identificador,
                                                                                       INPUT FALSE,
                                                                                       OUTPUT v_nrodocmto,
                                                                                       OUTPUT v_literal_autentica,
                                                                                       OUTPUT v_ult_seq_autentica).
                                END.
                                ELSE
                                DO:
                                    RUN realiza-deposito-cheque-migrado-host IN h-b1crap22 (INPUT v_coop,                
                                                                                            INPUT v_coop-migrada,
                                                                                            INPUT INT(v_pac),
                                                                                            INPUT INT(v_caixa),
                                                                                            INPUT v_operador,
                                                                                            INPUT v_cooppara,
                                                                                            INPUT v_nroconta, /* Cta Para*/
                                                                                            INPUT 0,
                                                                                            INPUT v_vlrdocumento,
                                                                                            INPUT v_identificador,
                                                                                            INPUT FALSE,
                                                                                            OUTPUT v_nrodocmto,
                                                                                            OUTPUT v_literal_autentica,
                                                                                            OUTPUT v_ult_seq_autentica).
                                END.
                            END.
                            
                            DELETE PROCEDURE h-b1crap22.
                            
                        END. /* Final da Transacao*/

                        IF  l-houve-erro = YES  THEN DO:
                            IF  CAN-FIND(FIRST crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper AND
                                                             crapmdw.cdagenci = INT(v_pac)        AND
                                                             crapmdw.nrdcaixa = INT(v_caixa)      AND
                                                             crapmdw.cdhistor = 386)  THEN DO:
                                    
                                    RUN reinicia-crapmdw IN THIS-PROCEDURE(INPUT INT(v_pac),
                                                                           INPUT INT(v_caixa)).
                        
                                    /*RUN JavaScript("window.open('crap051d.p?v_pconta="
                                    + STRING(v_nroconta) + "&v_pnome=" + STRING(v_nome1)
                                    + "&v_ppoup=" + "&v_pidentifica=" + STRING(v_identificador)
                                    + "&v_pvalor=" + STRING(v_vlrdocumento) + "&v_pvalor1="
                                    + STRING(v_vlrdocumento) + "&v_pestorno=YES','wautcoop','width=500,height=290,scrollbars=auto,alwaysRaised=true')").*/
                                               
                        
                            END. 
                          
                            FOR EACH craperr WHERE 
                                     craperr.cdcooper = crapcop.cdcooper  AND
                                     craperr.cdagenci = INTE(v_pac)       AND
                                     craperr.nrdcaixa = INTE(v_caixa)
                                     EXCLUSIVE-LOCK:
                                     DELETE craperr.
                            END.
                          
                            FOR EACH w-craperr NO-LOCK:
                                CREATE craperr.
                                ASSIGN craperr.cdcooper   = crapcop.cdcooper
                                       craperr.cdagenci   = w-craperr.cdagenc
                                       craperr.nrdcaixa   = w-craperr.nrdcaixa
                                       craperr.nrsequen   = w-craperr.nrsequen
                                       craperr.cdcritic   = w-craperr.cdcritic
                                       craperr.dscritic   = w-craperr.dscritic
                                       craperr.erro       = w-craperr.erro.
                                VALIDATE craperr.
                            END.
                            
                            FIND FIRST craperr NO-LOCK  where
                                       craperr.cdcooper = crapcop.cdcooper AND
                                       craperr.cdagenci = INT(v_pac)   and
                                       craperr.nrdcaixa = INT(v_caixa) no-error.
                        
                            IF  AVAIL craperr  THEN
                                {&OUT} "<script language='JavaScript'>window.open='mensagem.p','werro','height=220,width=400,scrollbars=yes,alwaysRaised=true'</script>".
                                   
                        END. /* Final do IF erro YES */
                        ELSE DO: 
                            ASSIGN   aux_achou = FALSE.
                            FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper     AND
                                                   crapmdw.cdagenci = int(v_pac)           AND
                                                   crapmdw.nrdcaixa = int(v_caixa) NO-LOCK:
                                
                                FIND FIRST crapfdc WHERE crapfdc.cdcooper = crapmdw.cdcooper AND
                                                         crapfdc.cdbanchq = crapmdw.cdbanchq AND
                                                         crapfdc.cdagechq = crapmdw.cdagechq AND
                                                         crapfdc.nrctachq = crapmdw.nrctabdb AND
                                                         crapfdc.nrcheque = crapmdw.nrcheque 
                                                         NO-LOCK NO-ERROR.
                            
                            
                                
                                IF  AVAIL crapfdc THEN
                                    ASSIGN aux_achou = true.
                            END.

                            IF   NOT aux_achou THEN DO:
                                 RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
                                 RUN atualiza-previa-caixa  IN h-b1crap00  (INPUT v_coop,
                                                                            INPUT int(v_pac),
                                                                            INPUT int(v_caixa),
                                                                            INPUT v_operador,
                                                                            INPUT v_data,
                                                                            INPUT 3). /*Consulta*/ 
                                 IF   RETURN-VALUE = "NOK" THEN DO:
                                    {include/i-erro.i}
                                 END.
                                 DELETE PROCEDURE h-b1crap00. 
                            END.

                            {&OUT}
                             '<script language="JavaScript">window.open("autentica.html?v_plit=" + "' STRING(v_literal_autentica) '" + 
                              "&v_pseq=" + "' STRING(v_ult_seq_autentica) '" + "&v_prec=" + "YES"  + "&v_psetcook=" + "YES","waut","width=250,height=145,scrollbars=auto,alwaysRaised=true")
                             </script>'.
                            
                        END.  
                        
                        FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper AND
                                               crapmdw.cdagenci = INT(v_pac)       AND
                                               crapmdw.nrdcaixa = INT(v_caixa)     EXCLUSIVE-LOCK:
                            DELETE crapmdw.
                        END.
                        
                        FOR EACH crapmrw WHERE crapmrw.cdcooper = crapcop.cdcooper AND
                                               crapmrw.cdagenci = INT(v_pac) AND
                                               crapmrw.nrdcaixa = INT(v_caixa) EXCLUSIVE-LOCK:
                            DELETE crapmrw.
                        END.
                        
                        /* Volta a tela Principal Iniciando a Opercao */
                        {&OUT} "<script language='JavaScript'>window.location='crap022.w"      + 
                               "?tpDoctoSel=Deposito"                    +
                               "'</script>".
                        
                    END. /* Final do IF erro NO */

                END.

            END. 
        END.
         
        RUN displayFields.
        
        RUN outputFields.
        
    END. /* Form has been submitted. */
    ELSE DO: /* REQUEST-METHOD = GET */ 

        IF  GET-VALUE("v_sangria") <> "" THEN DO:
            
            RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.

            RUN verifica-sangria-caixa IN h-b1crap00 (INPUT v_coop,
                                                      INPUT INT(v_pac),
                                                      INPUT INT(v_caixa),
                                                      INPUT v_operador).

            DELETE PROCEDURE h-b1crap00.

            IF  RETURN-VALUE = "MAX" THEN DO:
                {include/i-erro.i}

                {&OUT}
                     '<script language="JavaScript"> window.location = "crap002.html" </script>'.
        
            END.

            IF RETURN-VALUE = "MIN" THEN
                {include/i-erro.i}

            IF  RETURN-VALUE = "NOK" THEN DO:
                {include/i-erro.i}

                {&OUT}
                     '<script language="JavaScript"> window.location = "crap002.html" </script>'.
            END.
        END.

        /* Carrega Dados */
        ASSIGN vh_foco           = '13'
               tpDocto           = 'Cheque'
               v_cooppara        = GET-VALUE("v_pcoop")
               v_nroconta        = GET-VALUE("v_nroconta")
               v_vlrdocumento    = GET-VALUE("v_vlrdocumento")
               v_identificador   = GET-VALUE("v_identificador")
               v_nome1           = GET-VALUE("v_nome1")
               v_cpfcgc1         = GET-VALUE("v_cpfcgc1")
               v_nome2           = GET-VALUE("v_nome2")
               v_cpfcgc2         = GET-VALUE("v_cpfcgc2")
               v_coop-migrada    = GET-VALUE("v_coop-migrada").

        IF UPPER(GET-VALUE("v_cta-migrada")) = 'YES' THEN
        v_flg-cta-migrada = YES.
        ELSE
        v_flg-cta-migrada = NO.
         
        IF UPPER(GET-VALUE("v_flg-coop-host")) = 'YES' THEN
        v_flg-coop-host = YES.
        ELSE
        v_flg-coop-host = NO.


        RUN carregaCooperativa  IN THIS-PROCEDURE (tpDocto).

        /*** Montar o Resumo ***/

        FIND FIRST crapcop WHERE crapcop.nmrescop = v_coop
                           NO-LOCK NO-ERROR.

        RUN dbo/b1crap51.p PERSISTENT SET h-b1crap51.

        RUN gera-tabela-resumo-cheques IN h-b1crap51(INPUT v_coop,
                                                     INPUT INT(v_pac),
                                                     INPUT INT(v_caixa),
                                                     INPUT v_operador,
                                                     INPUT INT(v_nroconta)).

        DELETE PROCEDURE h-b1crap51.

        /* Buscar os totais de Cheque Cooperativa */
        FIND FIRST crapmrw WHERE crapmrw.cdcooper  = crapcop.cdcooper
                             AND crapmrw.cdagenci  = INT(v_pac)
                             AND crapmrw.nrdcaixa  = INT(v_caixa)
                             NO-LOCK NO-ERROR.

        IF  AVAIL crapmrw  THEN 
            ASSIGN v_chequescoop = STRING(crapmrw.vlchqcop,"zzz,zzz,zzz,zz9.99")
                   v_totdepos    = STRING(DEC(v_totdepos) + crapmrw.vlchqcop,"zzz,zzz,zzz,zz9.99").

        /* Buscar os totais de cheque maior e menor da Praca ou fora Praca */
        FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper
                           AND crapmdw.cdagenci = INT(v_pac)
                           AND crapmdw.nrdcaixa = INT(v_caixa)
                           NO-LOCK:
                
            ASSIGN v_qtdchqs = STRING(INT(v_qtdchqs) + 1).
        
            FIND tt-cheques WHERE tt-cheques.dtlibera = crapmdw.dtlibcom
                              AND tt-cheques.nrdocmto = crapmdw.nrdocmto
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
            IF  NOT AVAIL tt-cheques  THEN
                CREATE tt-cheques.
                
            IF  crapmdw.cdhistor = 2433  THEN
                ASSIGN tt-cheques.nrdocmto = 6
                       tt-cheques.dtlibera = crapmdw.dtlibcom
                       tt-cheques.vlcompel = tt-cheques.vlcompel + crapmdw.vlcompel
                       v_totdepos = STRING(DEC(v_totdepos) + crapmdw.vlcompel,"zzz,zzz,zzz,zz9.99").
                
            FIND CURRENT tt-cheques NO-LOCK.
            
        END.

        ASSIGN vetorcheque = "".
            
        FOR EACH tt-cheques WHERE tt-cheques.nrdocmto = 6 NO-LOCK:
            
              IF TRIM(vetorcheque) <> "" AND TRIM(vetorcheque) <> ? THEN
                  ASSIGN vetorcheque = vetorcheque + ",".
                    
              ASSIGN vetorcheque = vetorcheque + "~{vlcheque:'" + TRIM(STRING(tt-cheques.vlcompel,"zzz,zzz,zzz,zz9.99"))
                                               + "',dtcheque:'" + TRIM(STRING(tt-cheques.dtlibera,"99/99/99"))+ "'~}".                            
        END.

        {&OUT} '<script language="JavaScript">var cheques = new Array(); cheques.push(' + STRING(vetorcheque) + ');</script>'.  
        
        /*** Fim da montagem dos dados do resumo ***/
 
        RUN displayFields.   
        RUN enableFields.

        RUN outputFields.

    END.

    /* Show error messages. */
    IF AnyMessage() THEN DO:
       
        ShowDataMessages().
    END.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME