/*.............................................................................

   Programa: siscaixa/web/crap022a1.w
   Sistema : Caixa On-Line
   Autor   : Andre Santos - Supero
   Data    : Junho/2014                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia:  Diario (on-line)
   Objetivo  :  Transferencia e deposito entre cooperativas.

   Alteracoes:   
                          
-----------------------------------------------------------------------------*/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD TpDocto AS CHARACTER FORMAT "X(256)":U
       FIELD vh_doc AS CHARACTER FORMAT "X(256)":U 
       FIELD vh_foco AS CHARACTER FORMAT "X(256)":U
       FIELD vh_fl_coop_mig AS CHARACTER FORMAT "X(256)":U
       FIELD vh_fl_coop_host AS CHARACTER FORMAT "X(256)":U
       FIELD vh_coop_mig AS CHARACTER FORMAT "X(256)":U
       FIELD vh_TpDoctoAnt AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_codcoop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cpfcgc1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cpfcgc2 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cooppara AS CHARACTER 
       FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nome1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nome2 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nroconta AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
       FIELD v_vlrdocumento AS CHARACTER FORMAT "X(256)":U
       FIELD v_valor AS CHARACTER FORMAT "X(256)":U
       FIELD v_cmc7 AS CHARACTER FORMAT "X(256)":U
       FIELD v_btn_ok AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msgsaldo AS CHARACTER FORMAT "X(256)":U
       FIELD v_identificador AS CHARACTER FORMAT "X(256)":U
       FIELD v_cod AS CHARACTER FORMAT "X(256)":U   
       FIELD v_senha AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cod1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cod2 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cod3 AS CHARACTER FORMAT "X(256)":U
       FIELD v_comp AS CHARACTER FORMAT "X(256)":U
       FIELD v_banco AS CHARACTER FORMAT "X(256)":U
       FIELD v_agenc AS CHARACTER FORMAT "X(256)":U
       FIELD v_c1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_c2 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_c3 AS CHARACTER FORMAT "X(256)":U
       FIELD v_cheque AS CHARACTER FORMAT "X(256)":U
       FIELD v_mensagem1 AS CHARACTER FORMAT "X(256)":U
       FIELD v_conta1 AS CHARACTER FORMAT "X(256)":U
       FIELD v_mensagem2 AS CHARACTER FORMAT "X(256)":U.


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
DEF VAR p-programa      AS CHAR INITIAL "CRAP022a1"    NO-UNDO.
DEF VAR p-flgdebcc      AS CHAR INITIAL FALSE          NO-UNDO.

DEF VAR aux_vlsddisp    AS DECI                        NO-UNDO.

DEF VAR p-literal       AS CHAR                        NO-UNDO.
DEF VAR p-ult-sequencia AS INTE                        NO-UNDO.
DEF VAR p-nrdocmto      AS DECI                        NO-UNDO.
DEF VAR p-nrdoccre      AS DECI                        NO-UNDO.
DEF VAR p-cdlantar      LIKE craplat.cdlantar          NO-UNDO.

DEF VAR p-nro-lote      AS INTE                        NO-UNDO.
DEF VAR p-nrultaut      AS INTE                        NO-UNDO. 
DEF VAR i-cpfcgc-de     AS DEC FORMAT "zzzzzzzzzzzzz9" NO-UNDO.
DEF VAR i-cpfcgc-para   AS dec FORMAT "zzzzzzzzzzzzz9" NO-UNDO.
DEF VAR l-recibo        AS LOG NO-UNDO.

DEF VAR h-b1crap20      AS HANDLE                      NO-UNDO.
DEF VAR h-b1crap00      AS HANDLE                      NO-UNDO.
DEF VAR h-b1crap22      AS HANDLE                      NO-UNDO. 
DEF VAR h-b1crap51      AS HANDLE                      NO-UNDO.
DEF VAR h-b1crap54      AS HANDLE                      NO-UNDO.
DEF VAR h-b1wgen118     AS HANDLE                      NO-UNDO. 

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

DEF VAR p-mensagem-saldo   AS CHAR                     NO-UNDO.
DEF VAR p-valor-disponivel AS DEC                      NO-UNDO.
DEF VAR l-habilita         AS LOG INIT NO              NO-UNDO.

DEF VAR de-saldo-cheque    AS DEC                      NO-UNDO.

DEF VAR p-mensagem1  AS CHAR NO-UNDO.

DEF VAR p-flg-cta-migrada AS LOG                      NO-UNDO.
DEF VAR p-coop-migrada    AS CHAR                     NO-UNDO.
DEF VAR p-flg-coop-host   AS LOG                      NO-UNDO.
DEF VAR p-nro-conta-nova  AS INT                      NO-UNDO.
DEF VAR p-nro-conta-anti  AS INT                      NO-UNDO.

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



/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE crap022a1.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.v_codcoop ab_unmap.v_nroconta ab_unmap.v_cooppara ab_unmap.v_nome1 ab_unmap.v_nome2 ab_unmap.v_cpfcgc1 ab_unmap.v_cpfcgc2 ab_unmap.v_conta1 ab_unmap.TpDocto ab_unmap.vh_doc ab_unmap.vh_foco ab_unmap.vh_fl_coop_mig ab_unmap.vh_fl_coop_host ab_unmap.vh_coop_mig ab_unmap.vh_TpDoctoAnt ab_unmap.v_caixa ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_vlrdocumento ab_unmap.v_cmc7 ab_unmap.v_valor ab_unmap.v_btn_ok ab_unmap.v_msgsaldo ab_unmap.v_identificador ab_unmap.v_cod ab_unmap.v_senha ab_unmap.v_cod1 ab_unmap.v_cod2 ab_unmap.v_cod3 ab_unmap.v_comp ab_unmap.v_banco ab_unmap.v_agenc ab_unmap.v_c1 ab_unmap.v_c2 ab_unmap.v_c3 ab_unmap.v_cheque ab_unmap.v_mensagem1 ab_unmap.v_mensagem2
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.v_codcoop ab_unmap.v_nroconta ab_unmap.v_cooppara ab_unmap.v_nome1 ab_unmap.v_nome2 ab_unmap.v_cpfcgc1 ab_unmap.v_cpfcgc2 ab_unmap.v_conta1 ab_unmap.TpDocto ab_unmap.vh_doc ab_unmap.vh_foco ab_unmap.vh_fl_coop_mig ab_unmap.vh_fl_coop_host ab_unmap.vh_coop_mig ab_unmap.vh_TpDoctoAnt ab_unmap.v_caixa ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_vlrdocumento ab_unmap.v_cmc7 ab_unmap.v_valor ab_unmap.v_btn_ok ab_unmap.v_msgsaldo ab_unmap.v_identificador ab_unmap.v_cod ab_unmap.v_senha ab_unmap.v_cod1 ab_unmap.v_cod2 ab_unmap.v_cod3 ab_unmap.v_comp ab_unmap.v_banco ab_unmap.v_agenc ab_unmap.v_c1 ab_unmap.v_c2 ab_unmap.v_c3 ab_unmap.v_cheque ab_unmap.v_mensagem1 ab_unmap.v_mensagem2 

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
    ab_unmap.v_cod AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_senha AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_cod1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_cod2 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_cod3 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_comp AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_banco AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_agenc AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_conta1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_c1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_c2 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_c3 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_cheque AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_mensagem1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_mensagem2 AT ROW 1 COL 1 HELP
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
    ab_unmap.vh_fl_coop_mig AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.vh_fl_coop_host AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.vh_coop_mig AT ROW 1 COL 1 HELP
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
    ab_unmap.v_valor AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_cmc7 AT ROW 1 COL 1 HELP
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
    ("vh_fl_coop_mig":U,"ab_unmap.vh_fl_coop_mig":U,ab_unmap.vh_fl_coop_mig:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("vh_fl_coop_host":U,"ab_unmap.vh_fl_coop_host":U,ab_unmap.vh_fl_coop_host:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("vh_coop_mig":U,"ab_unmap.vh_coop_mig":U,ab_unmap.vh_coop_mig:HANDLE IN FRAME {&FRAME-NAME}).
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
    ("v_cmc7":U,"ab_unmap.v_cmc7":U,ab_unmap.v_cmc7:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_valor":U,"ab_unmap.v_valor":U,ab_unmap.v_valor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_btn_ok":U,"ab_unmap.v_btn_ok":U,ab_unmap.v_btn_ok:HANDLE IN FRAME {&FRAME-NAME}).   
  RUN htmAssociate
    ("v_msgsaldo":U,"ab_unmap.v_msgsaldo":U,ab_unmap.v_msgsaldo:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_identificador":U,"ab_unmap.v_identificador":U,ab_unmap.v_identificador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cod":U,"ab_unmap.v_cod":U,ab_unmap.v_cod:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_senha":U,"ab_unmap.v_senha":U,ab_unmap.v_senha:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cod1":U,"ab_unmap.v_cod1":U,ab_unmap.v_cod1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cod2":U,"ab_unmap.v_cod2":U,ab_unmap.v_cod2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cod3":U,"ab_unmap.v_cod3":U,ab_unmap.v_cod3:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_comp":U,"ab_unmap.v_comp":U,ab_unmap.v_comp:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_banco":U,"ab_unmap.v_banco":U,ab_unmap.v_banco:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_agenc":U,"ab_unmap.v_agenc":U,ab_unmap.v_agenc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_c1":U,"ab_unmap.v_c1":U,ab_unmap.v_c1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_c2":U,"ab_unmap.v_c2":U,ab_unmap.v_c2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_c3":U,"ab_unmap.v_c3":U,ab_unmap.v_c3:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cheque":U,"ab_unmap.v_cheque":U,ab_unmap.v_cheque:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_conta1":U,"ab_unmap.v_conta1":U,ab_unmap.v_conta1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_mensagem1":U,"v_mensagem1":U,v_mensagem1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_mensagem2":U,"v_mensagem2":U,v_mensagem2:HANDLE IN FRAME {&FRAME-NAME}).
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

        RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
                
        RUN enableFields.

        DISABLE v_cod v_senha WITH FRAME {&FRAME-NAME}.

        IF  get-value('dep') <> '' THEN DO: /* Botao Deposito */

            /* Limpa os campos */
            ASSIGN vh_foco           = '25' 
                   TpDocto           = 'Cheque'  
                   v_codcoop         = ''
                   v_cooppara        = ''
                   v_btn_ok          = ''
                   v_msgsaldo        = '' .
            
            RUN carregaCooperativa IN THIS-PROCEDURE ('Cheque').

            /* Retorno para a tela principal CRAP022 */
            {&OUT} "<script>window.location='crap022.w"               +
                   "?v_coop="          + GET-VALUE("v_cooppara")      +
                   "&v_nroconta="      + GET-VALUE("v_nroconta")      +
                   "&v_valortotchq="   + GET-VALUE("v_vlrdocumento")  +
                   "&v_identificador=" + GET-VALUE("v_identificador") +
                   "&v_nome1="         + GET-VALUE("v_nome1")         +
                   "&v_cpfcgc1="       + GET-VALUE("v_cpfcgc1")       +
                   "&v_nome2="         + GET-VALUE("v_nome2")         +
                   "&v_cpfcgc2="       + GET-VALUE("v_cpfcgc2")       +
                   "&v_cta-migrada="   + STRING(vh_fl_coop_mig)       +
                   "&v_coop-migrada="  + STRING(vh_coop_mig)          +
                   "&v_flg-coop-host=" + STRING(vh_fl_coop_host)      +
                   "&v_tela="          + "crap022a1"                  +
                   "'</script>".

        END.
        
        IF  get-value('cheque') <> '' THEN DO: /* Botao Cheque */

            /* Limpa os campos */
            ASSIGN vh_foco           = '25' 
                   TpDocto           = 'Cheque'  
                   v_codcoop         = ''
                   v_cooppara        = ''
                   v_btn_ok          = ''
                   v_msgsaldo        = '' .
            
            RUN carregaCooperativa IN THIS-PROCEDURE ('Cheque').

            /* Retorna para tela de Cheques CRAP022a */
            {&OUT} "<script>window.location='crap022a.w"              +
                   "?v_cooppara="      + GET-VALUE("v_cooppara")      +
                   "&v_nroconta="      + GET-VALUE("v_nroconta")      +
                   "&v_vlrdocumento="  + GET-VALUE("v_vlrdocumento")  +
                   "&v_identificador=" + GET-VALUE("v_identificador") +
                   "&v_nome1="         + GET-VALUE("v_nome1")         +
                   "&v_cpfcgc1="       + GET-VALUE("v_cpfcgc1")       +
                   "&v_nome2="         + GET-VALUE("v_nome2")         +
                   "&v_cpfcgc2="       + GET-VALUE("v_cpfcgc2")       +
                   "&v_cta-migrada="   + STRING(vh_fl_coop_mig)       +
                   "&v_coop-migrada="  + STRING(vh_coop_mig)          +
                   "&v_flg-coop-host=" + STRING(vh_fl_coop_host)      +
                   "&v_tela="          + "crap022a1"                  +
                   "'</script>".

        END.
        
        IF  get-value('cancela') <> '' THEN DO: /* Botao Cancela */

            /* Limpa os Campos */
            ASSIGN vh_foco           = '25' 
                   TpDocto           = 'Cheque'  
                   v_cooppara        = GET-VALUE("v_cooppara")
                   v_valor           = GET-VALUE("v_valor1")
                   v_btn_ok          = ''
                   v_msgsaldo        = ''
                   v_cmc7            = ''
                   v_cod             = ''
                   v_senha           = ''
                   v_cod1            = ''
                   v_cod2            = ''
                   v_cod3            = ''
                   v_comp            = ''
                   v_banco           = ''
                   v_agenc           = ''
                   v_c1              = ''
                   v_c2              = ''
                   v_c3              = ''
                   v_cheque          = ''
                   v_mensagem1       = ''
                   v_conta1          = ''
                   v_mensagem2       = ''.
        
            RUN carregaCooperativa IN THIS-PROCEDURE ('Cheque').

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

                ASSIGN v_cmc7 = "<" + v_cod1 + 
                       "<" + v_cod2 + ">" + v_cod3 + ":"
                       v_valor           = GET-VALUE("v_valor1").

                RUN dbo/b1crap51.p PERSISTENT SET h-b1crap51.
                RUN critica-codigo-cheque-dig IN h-b1crap51(INPUT v_coop,
                                                            INPUT v_pac,
                                                            INPUT v_caixa,
                                                            INPUT v_cmc7).
                DELETE PROCEDURE h-b1crap51.

                IF  RETURN-VALUE = "NOK" THEN DO:
                    ASSIGN v_cmc7 = ''.
                    {include/i-erro.i}
                END. 
                ELSE DO:
                    RUN dbo/b1crap51.p PERSISTENT SET h-b1crap51.
                    RUN valida-codigo-cheque
                                 IN h-b1crap51(INPUT v_coop,
                                               INPUT int(v_pac),    
                                               INPUT int(v_caixa),
                                               INPUT " ",
                                               INPUT v_cmc7,
                                               OUTPUT v_comp,   
                                               OUTPUT v_banco,       
                                               OUTPUT v_agenc,       
                                               OUTPUT v_c1,       
                                               OUTPUT v_conta1,       
                                               OUTPUT v_c2,       
                                               OUTPUT v_cheque,       
                                               OUTPUT v_c3). 
                    DELETE PROCEDURE h-b1crap51.
        
					IF  RETURN-VALUE = "NOK" THEN DO:
						 {include/i-erro.i}
						   
					 END. 
					 ELSE DO:
        
                    FIND FIRST craperr WHERE craperr.cdcooper = crapcop.cdcooper
                                         AND craperr.cdagenci = int(v_pac)
                                         AND craperr.nrdcaixa = int(v_caixa)
                                         AND craperr.cdcritic = 8 NO-ERROR.
                    
                    IF  AVAIL craperr THEN
                        DELETE craperr.
        
                    RUN dbo/b1crap51.p PERSISTENT SET h-b1crap51.
                    RUN critica-contra-ordem IN h-b1crap51(INPUT v_coop,
                                                           INPUT INT(v_pac),           
                                                           INPUT INT(v_caixa),         
                                                           INPUT v_operador,           
                                                           INPUT INT(v_nroconta),         
                                                           INPUT " ",                  
                                                           INPUT v_cmc7,          
                                                           INPUT INT(v_comp),          
                                                           INPUT INT(v_banco),         
                                                           INPUT INT(v_agenc),         
                                                           INPUT INT(v_c1),            
                                                           INPUT DEC(v_conta1),        
                                                           INPUT INT(v_c2),            
                                                           INPUT INT(v_cheque),        
                                                           INPUT INT(v_c3),            
                                                           INPUT DEC(v_valor),        
                                                           INPUT NO,                   
                                                           OUTPUT v_mensagem1,         
                                                           OUTPUT v_mensagem2,         
                                                           OUTPUT p-mensagem-saldo,    
                                                           OUTPUT p-valor-disponivel,
                                                           OUTPUT  p-flg-cta-migrada,
                                                           OUTPUT  p-coop-migrada,   
                                                           OUTPUT  p-flg-coop-host,  
                                                           OUTPUT p-nro-conta-nova,
                                                           OUTPUT p-nro-conta-anti). 
        
                    DELETE PROCEDURE h-b1crap51.
                    
                    IF RETURN-VALUE = "NOK" THEN DO:
                        ASSIGN v_cmc7 = ''.
                        {include/i-erro.i}
                    END.
                    ELSE DO:
                        RUN dbo/b1crap51.p PERSISTENT SET h-b1crap51.
        
                        /* Validar os dados na cooperativa geradora do cheque */
                        IF  NOT p-flg-cta-migrada  THEN
                        RUN valida-deposito-com-captura 
                                    IN h-b1crap51(INPUT v_coop,        
                                                  INPUT INT(v_pac),
                                                  INPUT INT(v_caixa),
                                                  INPUT v_operador,
                                                  INPUT " ",
                                                  INPUT v_cooppara,
                                                  INPUT INT(v_nroconta),
                                                  INPUT " ",
                                                  INPUT v_cmc7,
                                                  INPUT INT(v_comp),
                                                  INPUT INT(v_banco),       
                                                  INPUT INT(v_agenc),       
                                                  INPUT INT(v_c1), 
                                                  INPUT DEC(v_conta1),       
                                                  INPUT INT(v_c2), 
                                                  INPUT INT(v_cheque),       
                                                  INPUT INT(v_c3),
                                                  INPUT DEC(v_valor),
                                                  INPUT NO,
                                                  OUTPUT v_mensagem1,
                                                  OUTPUT v_mensagem2,
                                                  OUTPUT p-mensagem-saldo,
                                                  OUTPUT p-valor-disponivel).
                        ELSE DO:
                            IF  NOT p-flg-coop-host  THEN
                                
                                RUN valida-deposito-com-captura-migrado
                                    IN h-b1crap51(INPUT v_coop,  
                                                  INPUT p-coop-migrada,
                                                  INPUT INT(v_pac),
                                                  INPUT INT(v_caixa),
                                                  INPUT v_operador,
                                                  INPUT " ",
                                                  INPUT v_cooppara,
                                                  INPUT INT(v_nroconta),
                                                  INPUT " ",
                                                  INPUT v_cmc7,
                                                  INPUT INT(v_comp),
                                                  INPUT INT(v_banco),       
                                                  INPUT INT(v_agenc),       
                                                  INPUT INT(v_c1), 
                                                  INPUT DEC(v_conta1),       
                                                  INPUT INT(v_c2), 
                                                  INPUT INT(v_cheque),       
                                                  INPUT INT(v_c3),
                                                  INPUT DEC(v_valor),
                                                  INPUT NO,
                                                  INPUT p-nro-conta-nova,
                                                  INPUT p-nro-conta-anti,
                                                  OUTPUT v_mensagem1,
                                                  OUTPUT v_mensagem2,
                                                  OUTPUT p-mensagem-saldo,
                                                  OUTPUT p-valor-disponivel).
                            ELSE
                                RUN valida-deposito-com-captura-migrado-host
                                    IN h-b1crap51(INPUT v_coop,  
                                                  INPUT p-coop-migrada,
                                                  INPUT INT(v_pac),
                                                  INPUT INT(v_caixa),
                                                  INPUT v_operador,
                                                  INPUT " ",
                                                  INPUT v_cooppara,
                                                  INPUT INT(v_nroconta),
                                                  INPUT " ",
                                                  INPUT v_cmc7,
                                                  INPUT INT(v_comp),
                                                  INPUT INT(v_banco),       
                                                  INPUT INT(v_agenc),       
                                                  INPUT INT(v_c1), 
                                                  INPUT DEC(v_conta1),       
                                                  INPUT INT(v_c2), 
                                                  INPUT INT(v_cheque),       
                                                  INPUT INT(v_c3),
                                                  INPUT DEC(v_valor),
                                                  INPUT NO,
                                                  INPUT p-nro-conta-nova,
                                                  INPUT p-nro-conta-anti,
                                                  OUTPUT v_mensagem1,
                                                  OUTPUT v_mensagem2,
                                                  OUTPUT p-mensagem-saldo,
                                                  OUTPUT p-valor-disponivel).
        
                        END.
                        
                        DELETE PROCEDURE h-b1crap51.

                        ASSIGN vh_fl_coop_mig   = STRING(p-flg-cta-migrada)
                               vh_coop_mig      = STRING(p-coop-migrada)
                               vh_fl_coop_host  = STRING(p-flg-coop-host). 
        
                        IF  p-mensagem-saldo <> " "  THEN
                            ASSIGN v_mensagem2 = v_mensagem1 + v_mensagem2
                                   v_mensagem1 = p-mensagem-saldo.
        
                        IF  p-mensagem-saldo <> " "  THEN
                            ASSIGN l-habilita = YES.
        
                        IF  RETURN-VALUE = "OK" THEN DO:
                            
                            IF  v_btn_ok <> '' THEN DO:
        
                                RUN dbo/b1crap54.p PERSISTENT SET h-b1crap54.
                                RUN valida-permissao-saldo-conta
                                         IN h-b1crap54(INPUT  v_coop,         
                                                       INPUT  INT(v_pac),    
                                                       INPUT  INT(v_caixa),
                                                       INPUT  DEC(v_valor),
                                                       INPUT  v_operador,
                                                       INPUT  DEC(v_nroconta),
                                                       INPUT  0,
                                                       INPUT  "",
                                                       INPUT  "",
                                                       INPUT  v_cod,
                                                       INPUT  v_senha,
                                                       INPUT  p-valor-disponivel,
                                                       INPUT  p-mensagem-saldo,
                                                       INPUT 1,
                                                       INPUT "",
                                                       INPUT "").
                                DELETE PROCEDURE h-b1crap54.
        
                                IF  RETURN-VALUE = "OK"  THEN DO:
                                    RUN dbo/b1crap51.p PERSISTENT SET h-b1crap51.
                                    
                                    IF  NOT p-flg-cta-migrada  THEN
                                    RUN  valida-deposito-com-captura
                                         IN h-b1crap51(INPUT v_coop,         
                                                       INPUT INT(v_pac),
                                                       INPUT INT(v_caixa),
                                                       INPUT v_operador,
                                                       INPUT v_cod,
                                                       INPUT v_cooppara,
                                                       INPUT INT(v_nroconta),
                                                       INPUT " ",
                                                       INPUT v_cmc7,
                                                       INPUT INT(v_comp),     
                                                       INPUT INT(v_banco),       
                                                       INPUT INT(v_agenc),       
                                                       INPUT INT(v_c1),       
                                                       INPUT DEC(v_conta1),       
                                                       INPUT INT(v_c2),       
                                                       INPUT INT(v_cheque),       
                                                       INPUT INT(v_c3),
                                                       INPUT DEC(v_valor),
                                                       INPUT YES, 
                                                       OUTPUT v_mensagem1,
                                                       OUTPUT v_mensagem2,
                                                       OUTPUT p-mensagem-saldo,
                                                       OUTPUT p-valor-disponivel).
                                    ELSE
                                    DO:
        
                                    IF  NOT p-flg-coop-host  THEN
                                    RUN  valida-deposito-com-captura-migrado
                                         IN h-b1crap51(INPUT v_coop,         
                                                       INPUT p-coop-migrada,
                                                       INPUT INT(v_pac),
                                                       INPUT INT(v_caixa),
                                                       INPUT v_operador,
                                                       INPUT v_cod,
                                                       INPUT v_cooppara,
                                                       INPUT INT(v_nroconta),
                                                       INPUT " ",
                                                       INPUT v_cmc7,
                                                       INPUT INT(v_comp),     
                                                       INPUT INT(v_banco),       
                                                       INPUT INT(v_agenc),       
                                                       INPUT INT(v_c1),       
                                                       INPUT DEC(v_conta1),       
                                                       INPUT INT(v_c2),       
                                                       INPUT INT(v_cheque),       
                                                       INPUT INT(v_c3),
                                                       INPUT DEC(v_valor),
                                                       INPUT YES, 
                                                       INPUT p-nro-conta-nova,
                                                       INPUT p-nro-conta-anti,
                                                       OUTPUT v_mensagem1,
                                                       OUTPUT v_mensagem2,
                                                       OUTPUT p-mensagem-saldo,
                                                       OUTPUT p-valor-disponivel).
                                    ELSE
                                    RUN  valida-deposito-com-captura-migrado-host
                                         IN h-b1crap51(INPUT v_coop,         
                                                       INPUT p-coop-migrada,
                                                       INPUT INT(v_pac),
                                                       INPUT INT(v_caixa),
                                                       INPUT v_operador,
                                                       INPUT v_cod,
                                                       INPUT v_cooppara,
                                                       INPUT INT(v_nroconta),
                                                       INPUT " ",
                                                       INPUT v_cmc7,
                                                       INPUT INT(v_comp),     
                                                       INPUT INT(v_banco),       
                                                       INPUT INT(v_agenc),       
                                                       INPUT INT(v_c1),       
                                                       INPUT DEC(v_conta1),       
                                                       INPUT INT(v_c2),       
                                                       INPUT INT(v_cheque),       
                                                       INPUT INT(v_c3),
                                                       INPUT DEC(v_valor),
                                                       INPUT YES, 
                                                       INPUT p-nro-conta-nova,
                                                       INPUT p-nro-conta-anti,
                                                       OUTPUT v_mensagem1,
                                                       OUTPUT v_mensagem2,
                                                       OUTPUT p-mensagem-saldo,
                                                       OUTPUT p-valor-disponivel).
        
                                    END.
        
                                    DELETE PROCEDURE h-b1crap51.
        
                                    IF  p-mensagem-saldo <> " "  THEN
                                        ASSIGN v_mensagem2 = v_mensagem1 + v_mensagem2
                                               v_mensagem1 = p-mensagem-saldo.
                                END.
                            END.
                        END.
                        IF  RETURN-VALUE = "NOK"  THEN DO:
                            ASSIGN v_cmc7 = ''.
                            {include/i-erro.i}
                        END.
                        ELSE DO:
                            IF  v_btn_ok <> '' THEN DO:

                                ASSIGN de-saldo-cheque = 0.

                                FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper
                                                   AND crapmdw.cdagenci = INT(v_pac)
                                                   AND crapmdw.nrdcaixa = INT(v_caixa):
                                    ASSIGN de-saldo-cheque = de-saldo-cheque + crapmdw.vlcompel.
                                END.

                                IF  de-saldo-cheque = DEC(v_vlrdocumento) THEN DO:

                                    {&OUT} "<script>window.location='crap022c.w"              +
                                           "?v_pcoop="         + GET-VALUE("v_cooppara")      +
                                           "&v_nroconta="      + GET-VALUE("v_nroconta")      +
                                           "&v_vlrdocumento="  + GET-VALUE("v_vlrdocumento")  + 
                                           "&v_identificador=" + GET-VALUE("v_identificador") + 
                                           "&v_nome1="         + GET-VALUE("v_nome1")         +
                                           "&v_cpfcgc1="       + GET-VALUE("v_cpfcgc1")       +
                                           "&v_nome2="         + GET-VALUE("v_nome2")         +
                                           "&v_cpfcgc2="       + GET-VALUE("v_cpfcgc2")       +
                                           "&v_cta-migrada="   + STRING(vh_fl_coop_mig)       +
                                           "&v_coop-migrada="  + STRING(vh_coop_mig)          +
                                           "&v_flg-coop-host=" + STRING(vh_fl_coop_host)      +
                                           "'</script>".
                                END.
                                ELSE DO:

                                    {&OUT} "<script>window.location='crap022a.w"              +
                                           "?v_cooppara="      + GET-VALUE("v_cooppara")      +
                                           "&v_nroconta="      + GET-VALUE("v_nroconta")      +
                                           "&v_vlrdocumento="  + GET-VALUE("v_vlrdocumento")  +
                                           "&v_identificador=" + GET-VALUE("v_identificador") +
                                           "&v_nome1="         + GET-VALUE("v_nome1")         +
                                           "&v_cpfcgc1="       + GET-VALUE("v_cpfcgc1")       +
                                           "&v_nome2="         + GET-VALUE("v_nome2")         +
                                           "&v_cpfcgc2="       + GET-VALUE("v_cpfcgc2")       +
                                           "&v_cta-migrada="   + STRING(vh_fl_coop_mig)       +
                                           "&v_coop-migrada="  + STRING(vh_coop_mig)          +
                                           "&v_flg-coop-host=" + STRING(vh_fl_coop_host)      +
                                           "&v_tela="          + "crap022a1"                  +
                                           "'</script>".
                                END.
                            END.
                        END.
                    END.
                END.                
				end.				
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
                    {&OUT} "<script>window.location='crap022.w"      + 
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
                    {&OUT} "<script>window.location='crap022.w"      + 
                           "?tpDoctoSel=" + tpDocto                  +
                           "'</script>".
                END.
            END. /** Fim transferencia **/
            
        END.
         
        DELETE PROCEDURE h-b1crap00.
        
        RUN displayFields.
   
        RUN enableFields.
        IF l-habilita = YES THEN DO:
            ENABLE v_cod
                   v_senha WITH FRAME {&FRAME-NAME}.
        END.
        ELSE 
            DISABLE v_cod
                    v_senha WITH FRAME {&FRAME-NAME}.
    
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
                     '<script> window.location = "crap002.html" </script>'.
        
            END.

            IF RETURN-VALUE = "MIN" THEN
                {include/i-erro.i}

            IF  RETURN-VALUE = "NOK" THEN DO:
                {include/i-erro.i}

                {&OUT}
                     '<script> window.location = "crap002.html" </script>'.
            END.
        END.

        /* Carrega Dados da CRAP022a */
        ASSIGN vh_foco = '25'  
               tpDocto = 'Cheque'
               v_cooppara      = GET-VALUE("v_cooppara")
               v_nroconta      = GET-VALUE("v_nroconta")
               v_vlrdocumento  = GET-VALUE("v_vlrdocumento")
               v_valor         = GET-VALUE("v_valor1")
               v_identificador = GET-VALUE("v_identificador")
               v_nome1         = GET-VALUE("v_nome1")
               v_cpfcgc1       = GET-VALUE("v_cpfcgc1")
               v_nome2         = GET-VALUE("v_nome2")
               v_cpfcgc2       = GET-VALUE("v_cpfcgc2")
               vh_fl_coop_mig  = GET-VALUE("v_cta-migrada")
               vh_fl_coop_host = GET-VALUE("v_flg-coop-host")
               vh_coop_mig     = GET-VALUE("v_coop-migrada").

        IF GET-VALUE("crap022a2") = "crap022a2"  THEN DO:
           
           ASSIGN vh_foco = '28' 
                  v_cmc7          = GET-VALUE("v_cmc7")
                  v_cod1          = SUBSTR(v_cmc7,2,8)
                  v_cod2          = SUBSTR(v_cmc7,11,10)
                  v_cod3          = SUBSTR(v_cmc7,22,12)
                  v_comp          = GET-VALUE("v_cdcmpchq")
                  v_banco         = GET-VALUE("v_cdbanchq")
                  v_agenc         = GET-VALUE("v_cdagechq")
                  v_c1            = GET-VALUE("v_nrddigc1")
                  v_c2            = GET-VALUE("v_nrddigc2")
                  v_c3            = GET-VALUE("v_nrddigc3")
                  v_cheque        = GET-VALUE("v_nrctabdb")
                  v_conta1        = GET-VALUE("v_nrcheque")
                  v_mensagem2     = GET-VALUE("v_pmensagem1") + GET-VALUE("v_pmensagem2")
                  v_mensagem1     = GET-VALUE("p-mensagem").


            RUN carregaCooperativa  IN THIS-PROCEDURE (tpDocto).
    
            RUN displayFields.   
            RUN enableFields.

            ENABLE v_cod v_senha WITH FRAME {&FRAME-NAME}.

            RUN outputFields.
                  
        END.
        ELSE DO:
        
            RUN carregaCooperativa  IN THIS-PROCEDURE (tpDocto).
    
            RUN displayFields.   
            RUN enableFields.
    
            DISABLE v_cod v_senha WITH FRAME {&FRAME-NAME}.
    
            RUN outputFields.

        END.
    END.

    /* Show error messages. */
    IF AnyMessage() THEN DO:
       
        ShowDataMessages().
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
