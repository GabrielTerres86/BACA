/*.............................................................................

   Programa: siscaixa/web/crap022.w
   Sistema : Caixa On-Line
   Autor   : Elton
   Data    : Novembro/2011                      Ultima atualizacao: 16/03/2016

   Dados referentes ao programa:

   Frequencia:  Diario (on-line)
   Objetivo  :  Transferencia e deposito entre cooperativas.

  
   Alteracoes:  14/12/2011 - Incluido parametro para rotina na chamada da 
                             procedure valida-saldo (Elton).
                             
                16/04/2013 - Adicionado verificacao de sangria de caixa no
                             REQUEST-METHOD = GET. (Fabricio)
                             
                25/04/2013 - Transferencia intercooperativa (Gabriel).   
                
                22/07/2013 - Ajustes transferencia intercooperativa (Lucas).
                
                13/12/2013 - Alteracao referente a integracao Progress X 
                             Dataserver Oracle 
                             Inclusao do VALIDATE ( Andre Euzebio / SUPERO)
                             
                04/06/2014 - Incluido opcao de deposito de cheques entre
                             cooperativas. (Andre Santos - SUPERO) 
                             
                01/12/2014 - Desabilitar cooperativas inativas no browse (Diego).             
                          
                16/03/2016 - Tratamentos para utilizaçao do Cartao CECRED e 
                             PinPad Novo (Lucas Lunelli - [PROJ290])
                          
                25/05/2018 - Alteraçao para a procedure valida-transacao2 - Everton Deserto(AMCom).            
                          
-----------------------------------------------------------------------------**/

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
       FIELD vh_tpDoctoSel AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_opcao AS CHARACTER FORMAT "X(256)":U       
       FIELD v_infocry     AS CHARACTER FORMAT "X(256)":U               
       FIELD v_chvcry      AS CHARACTER FORMAT "X(256)":U       
       FIELD v_nrdocard    AS CHARACTER FORMAT "X(256)":U 
       FIELD v_dsimpvia AS CHARACTER FORMAT "X(256)":U
       FIELD v_dssencrd AS CHARACTER FORMAT "X(256)":U       
       FIELD v_cartao AS CHARACTER FORMAT "X(256)":U
       FIELD v_codcoop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cpfcgcde AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cpfcgcpara1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cpfcgcpara2 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cooppara AS CHARACTER 
       FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nomede AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nomepara1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nomepara2 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nrocontade AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nrocontapara AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
       FIELD v_valordocumento AS CHARACTER FORMAT "X(256)":U
       FIELD v_vlrdocumento AS CHARACTER FORMAT "X(256)":U
       FIELD v_cod AS CHARACTER FORMAT "X(256)":U 
       FIELD v_senha AS CHARACTER FORMAT "X(256)":U  
       FIELD v_btn_ok AS CHARACTER FORMAT "X(256)":U
       FIELD v_btn_cancela AS CHARACTER FORMAT "X(256)":U        
       FIELD v_captura AS CHARACTER FORMAT "X(256)":U
       FIELD v_msgsaldo AS CHARACTER FORMAT "X(256)":U
       FIELD v_identifica AS CHARACTER FORMAT "X(256)":U.


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
DEF VAR p-programa      AS CHAR INITIAL "CRAP022"      NO-UNDO.
DEF VAR p-flgdebcc      AS CHAR INITIAL FALSE          NO-UNDO.

DEF VAR aux_vlsddisp    AS DECI                        NO-UNDO.

DEF VAR p-literal       AS CHAR                        NO-UNDO.
DEF VAR p-ult-sequencia AS INTE                        NO-UNDO.
DEF VAR p-nrdocmto      AS DECI                        NO-UNDO.
DEF VAR p-nrdoccre      AS DECI                        NO-UNDO.
DEF VAR p-cdlantar      LIKE craplat.cdlantar          NO-UNDO.
DEF VAR p-cod-erro      AS INTE                        NO-UNDO.

DEF VAR p-nro-lote      AS INTE                        NO-UNDO.
DEF VAR p-nrultaut      AS INTE                        NO-UNDO. 
DEF VAR i-cpfcgc-de     AS DEC FORMAT "zzzzzzzzzzzzz9" NO-UNDO.
DEF VAR i-cpfcgc-para   AS dec FORMAT "zzzzzzzzzzzzz9" NO-UNDO.
DEF VAR l-recibo        AS LOG NO-UNDO.
DEF VAR l-finaliza      AS LOG NO-UNDO.

DEF VAR h-b1crap20      AS HANDLE                      NO-UNDO.
DEF VAR h-b1crap00      AS HANDLE                      NO-UNDO.
DEF VAR h-b1crap22      AS HANDLE                      NO-UNDO. 
DEF VAR h-b1crap51      AS HANDLE                      NO-UNDO. 
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
DEF VAR de-saldo-cheque AS DECI                        NO-UNDO.
DEF VAR v_flg-cta-migrada AS LOGICAL FORMAT "yes/no"   NO-UNDO.
DEF VAR p_flg-cta-migrada AS CHAR                      NO-UNDO.
DEF VAR v_flg-coop-host   AS LOGICAL                   NO-UNDO.
DEF VAR p_flg-coop-host   AS CHAR                      NO-UNDO.
DEF VAR v_coop-migrada    AS CHAR                      NO-UNDO.

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

&Scoped-define WEB-FILE crap022.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.v_codcoop ab_unmap.v_nrocontapara ab_unmap.v_cooppara ab_unmap.v_nomepara1 ab_unmap.v_nomepara2 ab_unmap.v_cpfcgcpara1 ab_unmap.v_cpfcgcpara2 ab_unmap.TpDocto ab_unmap.vh_doc ab_unmap.v_cpfcgcde ab_unmap.v_nomede ab_unmap.vh_foco ab_unmap.vh_fl_coop_mig ab_unmap.vh_fl_coop_host ab_unmap.vh_coop_mig ab_unmap.vh_TpDoctoAnt ab_unmap.vh_tpDoctoSel ab_unmap.v_caixa ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_msg ab_unmap.v_nrocontade ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_valordocumento ab_unmap.v_vlrdocumento ab_unmap.v_btn_ok ab_unmap.v_captura ab_unmap.v_msgsaldo ab_unmap.v_identifica ab_unmap.v_cod ab_unmap.v_senha ab_unmap.v_opcao ab_unmap.v_infocry ab_unmap.v_chvcry ab_unmap.v_nrdocard ab_unmap.v_dsimpvia ab_unmap.v_dssencrd ab_unmap.v_cartao ab_unmap.v_btn_cancela
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.v_codcoop ab_unmap.v_nrocontapara ab_unmap.v_cooppara ab_unmap.v_nomepara1 ab_unmap.v_nomepara2 ab_unmap.v_cpfcgcpara1 ab_unmap.v_cpfcgcpara2 ab_unmap.TpDocto ab_unmap.vh_doc ab_unmap.v_cpfcgcde ab_unmap.v_nomede ab_unmap.vh_foco ab_unmap.vh_fl_coop_mig ab_unmap.vh_fl_coop_host ab_unmap.vh_coop_mig ab_unmap.vh_TpDoctoAnt ab_unmap.vh_tpDoctoSel ab_unmap.v_caixa ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_msg ab_unmap.v_nrocontade ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_valordocumento ab_unmap.v_vlrdocumento ab_unmap.v_btn_ok ab_unmap.v_captura ab_unmap.v_msgsaldo ab_unmap.v_identifica ab_unmap.v_cod ab_unmap.v_senha ab_unmap.v_opcao ab_unmap.v_infocry ab_unmap.v_chvcry ab_unmap.v_nrdocard ab_unmap.v_dsimpvia ab_unmap.v_dssencrd ab_unmap.v_cartao ab_unmap.v_btn_cancela

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
     ab_unmap.v_nrocontapara AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cooppara AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.v_nomepara1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nomepara2 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cpfcgcpara1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cpfcgcpara2 AT ROW 1 COL 1 HELP
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
     ab_unmap.v_cpfcgcde AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nomede AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_opcao AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
           "v_opcao 1", "R":U,
           "v_opcao 2", "C":U 
           SIZE 20 BY 2
     ab_unmap.v_infocry AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1          
     ab_unmap.v_nrdocard AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1                   
     ab_unmap.v_chvcry AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1                     
     ab_unmap.v_dsimpvia AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
           "v_dsimpvia 1", "S":U,
           "v_dsimpvia 2", "N":U 
           SIZE 20 BY 2                      
     ab_unmap.v_dssencrd AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1     
     ab_unmap.v_cartao AT ROW 1 COL 1 HELP
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
     ab_unmap.vh_tpDoctoSel AT ROW 1 COL 1 HELP
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
     ab_unmap.v_nrocontade AT ROW 1 COL 1 HELP
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
     ab_unmap.v_valordocumento AT ROW 1 COL 1 HELP
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
    ab_unmap.v_btn_cancela AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1                    
    ab_unmap.v_captura AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_msgsaldo AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_identifica AT ROW 1 COL 1 HELP
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
          FIELD v_cpfcgcpara1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cpfcgcpara2 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cooppara AS CHARACTER 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nomede AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nomepara1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nomepara2 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nrocontade AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nrocontapara AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valordocumento AS CHARACTER FORMAT "X(256)":U    
          FIELD v_identifica AS CHARACTER FORMAT "X(256)":U    
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
/* SETTINGS FOR FILL-IN ab_unmap.v_cpfcgcpara1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cpfcgcpara2 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR SELECTION-LIST ab_unmap.v_cooppara IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nomede IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nomepara1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nomepara2 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nrocontade IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nrocontapara IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_valordocumento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_identifica IN FRAME Web-Frame
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
    
    IF  pTpDocto = 'Deposito' THEN
        DO: 
            FOR EACH crabcop WHERE crabcop.cdcooper <> 3 AND
                                   crabcop.cdcooper <> crapcop.cdcooper AND
                                   crabcop.flgativo
                                   NO-LOCK:
            
                ASSIGN cListAux = cListAux +
                                  (IF cListAux = '' THEN '' ELSE ',') +
                                  STRING(crabcop.nmrescop) + ',' +
                                  STRING(crabcop.nmrescop).
            END.
        END.
    ELSE
    IF  pTpDocto = 'Cheque' THEN
        DO: 
            FOR EACH crabcop WHERE crabcop.cdcooper <> 3 AND
                                   crabcop.cdcooper <> crapcop.cdcooper AND
                                   crabcop.flgativo
                                   NO-LOCK:
            
                ASSIGN cListAux = cListAux +
                                  (IF cListAux = '' THEN '' ELSE ',') +
                                  STRING(crabcop.nmrescop) + ',' +
                                  STRING(crabcop.nmrescop).
            END.
        END.
    ELSE   /** Transferencia **/
        DO:
            FOR EACH crabcop WHERE crabcop.cdcooper <> 3 AND
                                   crabcop.flgativo NO-LOCK:
    
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
    ("vh_tpDoctoSel":U,"ab_unmap.vh_tpDoctoSel":U,ab_unmap.vh_tpDoctoSel:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_caixa":U,"ab_unmap.v_caixa":U,ab_unmap.v_caixa:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_codcoop":U,"ab_unmap.v_codcoop":U,ab_unmap.v_codcoop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cpfcgcde":U,"ab_unmap.v_cpfcgcde":U,ab_unmap.v_cpfcgcde:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cpfcgcpara1":U,"ab_unmap.v_cpfcgcpara1":U,ab_unmap.v_cpfcgcpara1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cpfcgcpara2":U,"ab_unmap.v_cpfcgcpara2":U,ab_unmap.v_cpfcgcpara2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cooppara":U,"ab_unmap.v_cooppara":U,ab_unmap.v_cooppara:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nomede":U,"ab_unmap.v_nomede":U,ab_unmap.v_nomede:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nomepara1":U,"ab_unmap.v_nomepara1":U,ab_unmap.v_nomepara1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nomepara2":U,"ab_unmap.v_nomepara2":U,ab_unmap.v_nomepara2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nrocontade":U,"ab_unmap.v_nrocontade":U,ab_unmap.v_nrocontade:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nrocontapara":U,"ab_unmap.v_nrocontapara":U,ab_unmap.v_nrocontapara:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_valordocumento":U,"ab_unmap.v_valordocumento":U,ab_unmap.v_valordocumento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_vlrdocumento":U,"ab_unmap.v_vlrdocumento":U,ab_unmap.v_vlrdocumento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_btn_ok":U,"ab_unmap.v_btn_ok":U,ab_unmap.v_btn_ok:HANDLE IN FRAME {&FRAME-NAME}).   
  RUN htmAssociate
    ("v_btn_cancela":U,"ab_unmap.v_btn_cancela":U,ab_unmap.v_btn_cancela:HANDLE IN FRAME {&FRAME-NAME}).           
  RUN htmAssociate
    ("v_captura":U,"ab_unmap.v_captura":U,ab_unmap.v_captura:HANDLE IN FRAME {&FRAME-NAME}).   
  RUN htmAssociate
    ("v_msgsaldo":U,"ab_unmap.v_msgsaldo":U,ab_unmap.v_msgsaldo:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_identifica":U,"ab_unmap.v_identifica":U,ab_unmap.v_identifica:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cartao":U,"ab_unmap.v_cartao":U,ab_unmap.v_cartao:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("v_opcao":U,"ab_unmap.v_opcao":U,ab_unmap.v_opcao:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("v_infocry":U,"ab_unmap.v_infocry":U,ab_unmap.v_infocry:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("v_chvcry":U,"ab_unmap.v_chvcry":U,ab_unmap.v_chvcry:HANDLE IN FRAME {&FRAME-NAME}).            
  RUN htmAssociate
    ("v_nrdocard":U,"ab_unmap.v_nrdocard":U,ab_unmap.v_nrdocard:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("v_dsimpvia":U,"ab_unmap.v_dsimpvia":U,ab_unmap.v_dsimpvia:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("v_dssencrd":U,"ab_unmap.v_dssencrd":U,ab_unmap.v_dssencrd:HANDLE IN FRAME {&FRAME-NAME}).     
  RUN htmAssociate
    ("v_cod":U,"ab_unmap.v_cod":U,ab_unmap.v_cod:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_senha":U,"ab_unmap.v_senha":U,ab_unmap.v_senha:HANDLE IN FRAME {&FRAME-NAME}).
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
    DEFINE VARIABLE aux_nrcartao    AS DECIMAL      NO-UNDO .
    DEFINE VARIABLE aux_idtipcar    AS INTEGER      NO-UNDO .

    RUN outputHeader.
    {include/i-global.i}

    IF  REQUEST_METHOD = 'POST':U THEN DO:

        RUN inputFields.

        {include/assignfields.i}

        RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
                
        RUN enableFields.

        DISABLE v_cod v_senha WITH FRAME {&FRAME-NAME}.
        
        IF  v_btn_cancela <> '' THEN DO: /* Cancelou a Operacao */

            ASSIGN vh_foco          = '20' 
                   TpDocto          = 'Deposito'  
                   v_valordocumento = ''
                   v_vlrdocumento   = ''
                   
                   v_opcao          = "R"
                   v_dsimpvia       = "S"
                   l-finaliza       = FALSE 
                   v_dssencrd       = ''
                   v_nrdocard       = ""
                   v_infocry        = ""
                   v_chvcry         = ""
                   v_cartao         = ""
                   
                   v_identifica     = ''
                   v_nrocontade     = ''
                   v_nomede         = ''
                   v_cpfcgcde       = ''
                   v_nrocontapara   = ''
                   v_nomepara1      = ''
                   v_nomepara2      = ''
                   v_cpfcgcpara1    = ''
                   v_cpfcgcpara2    = ''
                   v_codcoop        = ''
                   v_cooppara       = ''
                   v_cod            = ''
                   v_senha          = ''
                   v_btn_ok         = ''
                   v_btn_cancela    = ''
                   v_msgsaldo       = '' .
        
            RUN carregaCooperativa IN THIS-PROCEDURE ('Deposito').

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

        END. /* Fim do Btn Cancela */
        ELSE DO:
            
            RUN valida-transacao2 IN h-b1crap00(INPUT v_coop,  /* 25/05/2018 - Alterada para procedure valida-transacao2 - Everton Deserto(AMCom) */
                                               INPUT v_pac,
                                               INPUT v_caixa).
          
            IF  RETURN-VALUE = "OK"  THEN DO:
                
                RUN  verifica-abertura-boletim IN h-b1crap00 (INPUT v_coop,
                                                              INPUT v_pac,
                                                              INPUT v_caixa,
                                                              INPUT v_operador).
            END.
          
            IF   RETURN-VALUE = "NOK" THEN DO:

                 ASSIGN v_btn_ok = ''
                        v_btn_cancela    = ''.
                 {include/i-erro.i}

            END.
            ELSE DO:
                       
                /* os valores dos selection-lists sao armazenados em variaveis
                hidden para depois serem resgatados para as variaves originais
                pois as lista de valores sao dinamicas e seus valores acabam se
                perdendo */
                ASSIGN v_cooppara     = v_codcoop.
                    
                IF  tpDocto = 'Deposito'  THEN DO: /* Configura as opcoes de Dinheiro*/

                    /* Limpa Valores Quando for Trocado de Opcao */
                    IF  vh_TpDoctoAnt <> tpDocto THEN DO:
                            
                        ASSIGN vh_foco          = '20' 
                               TpDocto          = 'Deposito'  
                               v_valordocumento = ''
                               v_vlrdocumento   = ''
                               v_identifica     = ''
                               v_nrocontade     = ''
                               
                               v_opcao          = "R"
                               v_dsimpvia       = "S"
                               l-finaliza       = FALSE 
                               v_dssencrd       = ''
                               v_nrdocard       = ""
                               v_infocry        = ""
                               v_chvcry         = ""
                               v_cartao         = ""
                   
                               v_nomede         = ''
                               v_cpfcgcde       = ''
                               v_nrocontapara   = ''
                               v_nomepara1      = ''
                               v_nomepara2      = ''
                               v_cpfcgcpara1    = ''
                               v_cpfcgcpara2    = ''
                               v_codcoop        = ''
                               v_cooppara       = ''
                               v_cod            = ''
                               v_senha          = ''
                               v_btn_ok         = ''
                               v_btn_cancela    = ''
                               v_msgsaldo       = ''
                               vh_TpDoctoAnt      = 'Deposito'.

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

                    END.
                        
                    IF  v_nrocontapara <> '' THEN DO:
                        
                        RUN dbo/b1crap22.p PERSISTENT SET h-b1crap22. 
                       
                        RUN verifica-conta IN h-b1crap22 (INPUT v_cooppara,
                                                          INPUT INTEGER(v_pac),
                                                          INPUT INTEGER(v_caixa),
                                                          INPUT v_coop,
                                                          INTEGER(v_nrocontapara),
                                                          OUTPUT v_nmtitular1,
                                                          OUTPUT v_nrcpfcgc1,
                                                          OUTPUT v_nmtitular2,
                                                          OUTPUT v_nrcpfcgc2).

                        DELETE PROCEDURE h-b1crap22.
                                        
                        IF  RETURN-VALUE = "NOK" THEN DO:

                            l-houve-erro = TRUE.
                            {include/i-erro.i} 
                            vh_foco = '18'. /** Foco no campo conta destino **/

                        END.
                        ELSE DO:

                            ASSIGN v_nomepara1   = v_nmtitular1
                                   v_cpfcgcpara1 = STRING(v_nrcpfcgc1)
                                   v_nomepara2   = v_nmtitular2
                                   v_cpfcgcpara2 = STRING(v_nrcpfcgc2)
                                   vh_foco       = '25'. /** Foco no campo Identificador **/
                        END.

                    END. /* Fim do v_nrocontapara <> '' */

                END. /* Fim Opcao Deposito */
                ELSE
                IF  tpDocto = 'Cheque'  THEN DO:  /* Configura as opcoes de Cheque */
                    
                    /* Limpa Valores Quando for Trocado de Opcao */
                    IF  vh_TpDoctoAnt <> tpDocto  THEN DO:

                        ASSIGN vh_foco          = '20' 
                               TpDocto          = 'Cheque'  
                               v_valordocumento = ''
                               v_vlrdocumento   = ''
                               v_identifica     = ''
                               v_nrocontade     = ''
                               
                               v_opcao          = "R"
                               v_dsimpvia       = "S"
                               l-finaliza       = FALSE 
                               v_dssencrd       = ''
                               v_nrdocard       = ""
                               v_infocry        = ""
                               v_chvcry         = ""
                               v_cartao         = ""
                               
                               v_nomede         = ''
                               v_cpfcgcde       = ''
                               v_nrocontapara   = ''
                               v_nomepara1      = ''
                               v_nomepara2      = ''
                               v_cpfcgcpara1    = ''
                               v_cpfcgcpara2    = ''
                               v_codcoop        = ''
                               v_cooppara       = ''
                               v_cod            = ''
                               v_senha          = ''
                               v_btn_ok         = ''
                               v_btn_cancela    = ''
                               v_msgsaldo       = ''
                               vh_TpDoctoAnt    = 'Cheque'.

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

                    END.

                    IF  v_nrocontapara <> '' THEN DO:
                        
                        RUN dbo/b1crap22.p PERSISTENT SET h-b1crap22. 

                        RUN verifica-conta IN h-b1crap22 (INPUT v_cooppara,
                                                          INPUT INTEGER(v_pac),
                                                          INPUT INTEGER(v_caixa),
                                                          INPUT v_coop,
                                                          INTEGER(v_nrocontapara),
                                                          OUTPUT v_nmtitular1,
                                                          OUTPUT v_nrcpfcgc1,
                                                          OUTPUT v_nmtitular2,
                                                          OUTPUT v_nrcpfcgc2).
                        DELETE PROCEDURE h-b1crap22.
                                        
                        IF  RETURN-VALUE = "NOK" THEN DO:
                            
                            l-houve-erro = TRUE.
                            {include/i-erro.i} 
                            vh_foco = '20'. /** Foco no campo conta **/

                        END.
                        ELSE DO:

                            ASSIGN v_nomepara1   = v_nmtitular1
                                   v_cpfcgcpara1 = STRING(v_nrcpfcgc1)
                                   v_nomepara2   = v_nmtitular2
                                   v_cpfcgcpara2 = STRING(v_nrcpfcgc2)
                                   vh_foco = '25'. /** Foco no campo Identificador **/
                                                
                            IF  GET-VALUE("v_captura") <> "" THEN DO:

                                RUN dbo/b1crap51.p PERSISTENT SET h-b1crap51.
                                RUN critica-valor  IN h-b1crap51(INPUT v_coop,
                                                                 INPUT INT(v_pac),
                                                                 INPUT INT(v_caixa),
                                                                 INPUT v_vlrdocumento,
                                                                 INPUT '',
                                                                 OUTPUT p-cod-erro).

                                DELETE PROCEDURE h-b1crap51.

                                IF  RETURN-VALUE = "NOK"  AND
                                     p-cod-erro <> 760     THEN DO:
                                     ASSIGN vh_foco = "32". 
                                     {include/i-erro.i}
                                END.
                                ELSE DO:
                                    IF  p-cod-erro = 760   THEN DO:
                                        {include/i-erro.i}
                                    END.

                                    {&OUT} "<script>window.location='crap022a.w"                +
                                           "?v_cooppara="      + GET-VALUE("v_cooppara")        +
                                           "&v_nroconta="      + GET-VALUE("v_nrocontapara")    +
                                           "&v_vlrdocumento="  + GET-VALUE("v_vlrdocumento")    +
                                           "&v_identificador=" + GET-VALUE("v_identifica")      +
                                           "&v_nome1="         + v_nmtitular1                   +
                                           "&v_cpfcgc1="       + v_nrcpfcgc1                    +
                                           "&v_nome2="         + v_nmtitular2                   +
                                           "&v_cpfcgc2="       + v_nrcpfcgc2                    +
                                           "&v_cta-migrada="   + STRING(vh_fl_coop_mig)         +
                                           "&v_coop-migrada="  + STRING(vh_coop_mig)            +
                                           "&v_flg-coop-host=" + STRING(vh_fl_coop_host)        +
                                           "'</script>".
                                END.

                            END.

                        END.

                    END.  /* Fim do v_nrocontapara <> '' */

                END. /* Fim Opcao Cheque */
                ELSE DO:  /** Configura as opcoes de Cheque Transferencia **/ 
                        
                    /* Limpa Valores Quando for Trocado de Opcao */
                    IF  vh_TpDoctoAnt <> tpDocto  THEN DO:

                        ASSIGN vh_foco          = '26' 
                               TpDocto          = 'Transferencia'  
                               v_valordocumento = ''
                               v_vlrdocumento   = ''
                               v_identifica     = ''
                               v_nrocontade     = ''
                               
                               v_opcao          = "R"
                               v_dsimpvia       = "S"
                               l-finaliza       = FALSE 
                               v_dssencrd       = ''
                               v_nrdocard       = ""
                               v_infocry        = ""
                               v_chvcry         = ""
                               v_cartao         = ""
                               
                               v_nomede         = ''
                               v_cpfcgcde       = ''
                               v_nrocontapara   = ''
                               v_nomepara1      = ''
                               v_nomepara2      = ''
                               v_cpfcgcpara1    = ''
                               v_cpfcgcpara2    = ''
                               v_codcoop        = ''
                               v_cooppara       = ''
                               v_cod            = ''
                               v_senha          = ''
                               v_btn_ok         = ''
                               v_btn_cancela    = ''
                               v_msgsaldo       = ''
                               vh_TpDoctoAnt      = 'Transferencia'.

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

                    END.

                    IF  v_cartao <> '' THEN
                        DO:
                            RUN dbo/b1crap22.p PERSISTENT SET h-b1crap22. 
                            
                            RUN retorna-conta-cartao IN h-b1crap22 (INPUT v_coop,
                                                                    INPUT v_pac,
                                                                    INPUT v_caixa,
                                                                    INPUT DECI(v_cartao),
                                                                   OUTPUT v_nrocontade,
                                                                   OUTPUT aux_nrcartao,
                                                                   OUTPUT aux_idtipcar).
                            DELETE PROCEDURE h-b1crap22.
                                                                   
                            IF  RETURN-VALUE <> "OK" THEN DO:
                            
                                ASSIGN l-houve-erro = YES
                                       v_btn_ok     = ''
                                       v_btn_cancela = ''
                                       v_nrocontade = '' 
                                       v_cartao     = ''
                                       v_dssencrd   = ''
                                       v_infocry    = ""
                                       v_chvcry     = ""
                                       v_nrdocard   = ""
                                       v_opcao      = "R"
                                       v_dsimpvia   = "S".
                                       
                                {include/i-erro.i}
                            END.
                        END.
                        
                    ASSIGN l-houve-erro = NO
                           v_nrdocard   = STRING(aux_nrcartao).

                    IF  v_btn_ok <> '' OR   v_nrocontade <> '' OR v_nrocontapara <> '' THEN DO:
                        
                        /*** Apos solicitar senha se for alterado 
                        numero da conta limpar valores ***/
                        IF  v_btn_ok = ' ' THEN DO:
                            ASSIGN  v_cod = ' '
                                    v_senha = ' '.
                        END.
                           
                        RUN dbo/b1crap22.p PERSISTENT SET h-b1crap22. 
                           
                        RUN verifica-conta IN h-b1crap22 (INPUT v_coop,
                                                          INPUT INTEGER(v_pac),
                                                          INPUT INTEGER(v_caixa),
                                                          INPUT v_coop,      /** para critica **/
                                                          INTEGER(v_nrocontade),
                                                          OUTPUT v_nmtitular1,
                                                          OUTPUT v_nrcpfcgc1,
                                                          OUTPUT v_nmtitular2,
                                                          OUTPUT v_nrcpfcgc2).
                        DELETE PROCEDURE h-b1crap22.

                        IF  RETURN-VALUE = "NOK" THEN DO:

                            l-houve-erro = TRUE.
                            {include/i-erro.i} 
                            vh_foco = '25'.

                        END.
                        ELSE DO:

                            ASSIGN v_nomede   = v_nmtitular1
                                   v_cpfcgcde = STRING(v_nrcpfcgc1)
                                   vh_foco = '29'.
                                   
                            IF  v_nrocontapara <> '' THEN DO:  
                           
                                RUN dbo/b1crap22.p PERSISTENT SET h-b1crap22.
                                           
                                RUN verifica-conta IN h-b1crap22 (INPUT v_cooppara,
                                                                  INPUT INTEGER(v_pac),
                                                                  INPUT INTEGER(v_caixa),
                                                                  INPUT v_coop, 
                                                                  INTEGER(v_nrocontapara),
                                                                  OUTPUT v_nmtitular1,
                                                                  OUTPUT v_nrcpfcgc1,
                                                                  OUTPUT v_nmtitular2,
                                                                  OUTPUT v_nrcpfcgc2).
                           
                                DELETE PROCEDURE h-b1crap22.
                                           
                                IF  RETURN-VALUE = "NOK" THEN DO:

                                    l-houve-erro = TRUE.
                                    {include/i-erro.i} 
                                    vh_foco = '31'.

                                END.
                                ELSE DO:

                                    ASSIGN v_nomepara1   = v_nmtitular1
                                           v_cpfcgcpara1 = STRING(v_nrcpfcgc1)
                                           v_nomepara2   = v_nmtitular2
                                           v_cpfcgcpara2 = STRING(v_nrcpfcgc2)
                                           vh_foco       = '32'.
                                END.
                                
                            END.

                        END. /* Fim do v_nrocontapara <> '' */

                    END. /** IF v_btn_ok **/

                END. /** Fim transferencia **/
                    
                RUN carregaCooperativa  IN THIS-PROCEDURE (tpDocto).

                IF  v_btn_ok <> '' AND NOT l-houve-erro THEN DO:

                    IF  tpDocto <> 'Cheque' THEN DO:

                        RUN dbo/b1crap22.p PERSISTENT SET h-b1crap22.

                        RUN valida-valores IN h-b1crap22 (INPUT v_coop,
                                                          INPUT v_cooppara,
                                                          INPUT INTEGER(v_pac),
                                                          INPUT INTEGER(v_caixa),
                                                          INPUT tpdocto,
                                                          INPUT INTEGER(v_nrocontade),
                                                          INPUT INTEGER(v_nrocontapara),
                                                          INPUT DECI(v_valordocumento)). /* Valor Dinheiro */
                    
                        DELETE PROCEDURE h-b1crap22.

                        IF  RETURN-VALUE = "NOK" THEN DO:
                        
                            ASSIGN  v_btn_ok = ''
                                    v_btn_cancela    = ''
                                    l-houve-erro = TRUE.

                            {include/i-erro.i} 

                        END.
                        ELSE DO:

                            IF  tpDocto = 'Deposito' THEN DO:  
                                RUN dbo/b1crap22.p PERSISTENT SET h-b1crap22.
                                        
                                RUN valida_identificacao_dep IN h-b1crap22 (INPUT v_cooppara, 
                                                                            INPUT v_coop,      
                                                                            INTEGER(v_pac),
                                                                            INTEGER(v_caixa),
                                                                            INTEGER(v_nrocontapara),
                                                                            v_identifica).
                                DELETE PROCEDURE h-b1crap22.

                                IF  RETURN-VALUE = "NOK" THEN DO:
                                    
                                    ASSIGN  v_btn_ok = '' 
                                            v_btn_cancela    = ''
                                            l-houve-erro = TRUE.
                                    
                                END.
                                ELSE DO:

                                    ASSIGN aux_vllanmto  = DEC(v_valordocumento)
                                           aux_nmcoppara = v_cooppara
                                           aux_nrdconta  = integer(v_nrocontapara).

                                    RUN dbo/b1crap22.p PERSISTENT SET h-b1crap22.

                                    DO  TRANSACTION ON ERROR UNDO:
    
                                        RUN realiza-deposito IN h-b1crap22 (INPUT v_coop,
                                                                            INPUT INTEGER(v_pac),
                                                                            INPUT INTEGER(v_caixa),
                                                                            INPUT v_operador,
                                                                            INPUT v_cooppara,
                                                                            INPUT INTEGER(v_nrocontapara),
                                                                            INPUT DECI(v_valordocumento),
                                                                            INPUT v_identifica, 
                                                                            OUTPUT p-nro-docto,
                                                                            OUTPUT p-nro-lote,
                                                                            OUTPUT  p-literal, 
                                                                            OUTPUT  p-ult-sequencia ).
                                                    
                                        DELETE PROCEDURE h-b1crap22.
                                                    
                                        IF  RETURN-VALUE = "NOK" THEN DO:

                                            ASSIGN l-houve-erro = YES.
                                                             
                                            EMPTY TEMP-TABLE w-craperr.
                                                             
                                            FOR EACH craperr NO-LOCK WHERE craperr.cdcooper =  crapcop.cdcooper
                                                                       AND craperr.cdagenci =  INT(v_pac)
                                                                       AND craperr.nrdcaixa =  INT(v_caixa):
                                        
                                                CREATE w-craperr.
                                                ASSIGN w-craperr.cdcooper   = craperr.cdcooper 
                                                       w-craperr.cdagenci   = craperr.cdagenc
                                                       w-craperr.nrdcaixa   = craperr.nrdcaixa
                                                       w-craperr.nrsequen   = craperr.nrsequen
                                                       w-craperr.cdcritic   = craperr.cdcritic
                                                       w-craperr.dscritic   = craperr.dscritic
                                                       w-craperr.erro       = craperr.erro.
                                            END.
                                            UNDO.
    
                                        END.
    
                                    END. /** Transaction **/
                                    
                                END. /* Fim do Retorno valida_identificacao_dep */

                            END. /* Fim Deposito */
                            ELSE DO:
                                IF  tpDocto = 'Transferencia' THEN DO:

                                    ASSIGN vh_foco          = '15'.
                                    ASSIGN v_msgsaldo = ' '. 

                                    IF  v_opcao = "C"   AND 
                                        l-houve-erro = NO   THEN
                                        DO:
                                            RUN dbo/b1crap22.p PERSISTENT SET h-b1crap22.
                                            
                                            RUN valida_senha_cartao IN h-b1crap22 (INPUT v_coop,
                                                                                   INPUT v_pac,
                                                                                   INPUT v_caixa,
                                                                                   INPUT v_nrocontade,
                                                                                   INPUT DECI(aux_nrcartao),
                                                                                   INPUT v_opcao,
                                                                                   INPUT v_dssencrd,
                                                                                   INPUT aux_idtipcar,
                                                                                   INPUT v_infocry,
                                                                                   INPUT v_chvcry). 
                                                                                   
                                            DELETE PROCEDURE h-b1crap22.
                                                                                                                                                                          
                                            IF  RETURN-VALUE <> "OK" THEN DO:                        
                                                ASSIGN l-houve-erro = YES
                                                       v_btn_ok     = ''
                                                       v_btn_cancela  = ''
                                                       v_dssencrd   = ''
                                                    /* v_infocry    = ""
                                                       v_chvcry     = ""
                                                       v_cartao     = "" */
                                                       
                                                       vh_foco      = "33"
                                                       v_opcao      = "C".                          
                                                       
                                                EMPTY TEMP-TABLE w-craperr.
                                            
                                                FOR EACH craperr NO-LOCK WHERE craperr.cdcooper =  crapcop.cdcooper
                                                                           AND craperr.cdagenci =  INT(v_pac)
                                                                           AND craperr.nrdcaixa =  INT(v_caixa):
                                                
                                                    CREATE w-craperr.
                                                    ASSIGN w-craperr.cdcooper   = craperr.cdcooper 
                                                           w-craperr.cdagenci   = craperr.cdagenc
                                                           w-craperr.nrdcaixa   = craperr.nrdcaixa
                                                           w-craperr.nrsequen   = craperr.nrsequen
                                                           w-craperr.cdcritic   = craperr.cdcritic
                                                           w-craperr.dscritic   = craperr.dscritic
                                                           w-craperr.erro       = craperr.erro.
                                                END.
                                            END.                        
                                        END.

                                    RUN dbo/b1crap20.p PERSISTENT SET h-b1crap20.

                                    RUN valida-saldo IN h-b1crap20 (INPUT v_coop,
                                                                    INPUT INTEGER(v_pac),
                                                                    INPUT INTEGER(v_caixa),
                                                                    INPUT INTEGER(v_nrocontade),
                                                                    INPUT DECIMAL(v_valordocumento),
                                                                    INPUT 22,  /** Rotina **/
                                                                    INPUT v_cooppara, 
                                                                    OUTPUT aux_mensagem,
                                                                    OUTPUT aux_vlsddisp).

                                    DELETE PROCEDURE h-b1crap20.

                                    IF  v_cod = '' THEN DO:
                                
                                        /* Cooperado tem saldo */
                                        IF  aux_mensagem = ' ' THEN
                                            ASSIGN v_msgsaldo = 'false'.
        
                                        IF  v_msgsaldo = ' '  THEN DO:
                                            
                                            ASSIGN v_msgsaldo = 'false'.
        
                                            /* Caso o cooperado nao tenha saldo */
                                            IF  aux_mensagem <> ' '  THEN DO:
                                                ASSIGN  v_btn_ok = ''
                                                        v_btn_cancela    = ''
                                                        l-houve-erro = TRUE.
                                                
                                                EMPTY TEMP-TABLE w-craperr.
                                            
                                                FOR EACH craperr NO-LOCK WHERE craperr.cdcooper =  crapcop.cdcooper
                                                                           AND craperr.cdagenci =  INT(v_pac)
                                                                           AND craperr.nrdcaixa =  INT(v_caixa):
                                                
                                                    CREATE w-craperr.
                                                    ASSIGN w-craperr.cdcooper   = craperr.cdcooper 
                                                           w-craperr.cdagenci   = craperr.cdagenc
                                                           w-craperr.nrdcaixa   = craperr.nrdcaixa
                                                           w-craperr.nrsequen   = craperr.nrsequen
                                                           w-craperr.cdcritic   = craperr.cdcritic
                                                           w-craperr.dscritic   = craperr.dscritic
                                                           w-craperr.erro       = craperr.erro.
                                                END.
                                                
                                                ENABLE v_cod v_senha WITH FRAME {&FRAME-NAME}.
                                            END.
        
                                        END.
                                                          
                                        /** Se transferencia for entre contas da mesma cooperativa 
                                        nao faz validaçao do TRFCOP.  **/
                                        IF  v_coop <> v_cooppara THEN DO:

                                            RUN dbo/b1crap22.p PERSISTENT SET h-b1crap22.
                                    
                                            RUN verifica-limite-coop IN h-b1crap22(INPUT v_coop,
                                                                                   INPUT INTEGER(v_pac),
                                                                                   INPUT INTEGER(v_caixa),
                                                                                   INPUT v_operador,
                                                                                   INPUT DECI(v_valordocumento)).
        
                                            DELETE PROCEDURE h-b1crap22.
                                        
                                            IF  RETURN-VALUE = "NOK" THEN DO:
                                                ASSIGN  v_btn_ok = ''       
                                                        v_btn_cancela    = ''
                                                        l-houve-erro = TRUE .
                                                                         
                                                ENABLE v_cod v_senha WITH FRAME {&FRAME-NAME}.
                                                
                                                
                                                EMPTY TEMP-TABLE w-craperr.
                                            
                                                FOR EACH craperr NO-LOCK WHERE craperr.cdcooper =  crapcop.cdcooper
                                                                           AND craperr.cdagenci =  INT(v_pac)
                                                                           AND craperr.nrdcaixa =  INT(v_caixa):
                                                
                                                    CREATE w-craperr.
                                                    ASSIGN w-craperr.cdcooper   = craperr.cdcooper 
                                                           w-craperr.cdagenci   = craperr.cdagenc
                                                           w-craperr.nrdcaixa   = craperr.nrdcaixa
                                                           w-craperr.nrsequen   = craperr.nrsequen
                                                           w-craperr.cdcritic   = craperr.cdcritic
                                                           w-craperr.dscritic   = craperr.dscritic
                                                           w-craperr.erro       = craperr.erro.
                                                END.

                                            END.
        
                                        END.

                                    END.
                                    ELSE DO:    
                                                     
                                        RUN dbo/b1crap20.p PERSISTENT SET h-b1crap20.
                                
                                        RUN verifica-operador IN h-b1crap20(INPUT v_coop,
                                                                            INPUT INT(v_pac),
                                                                            INPUT INT(v_caixa),
                                                                            INPUT v_cod,
                                                                            INPUT v_senha,
                                                                            INPUT DECIMAL(v_valordocumento),
                                                                            INPUT aux_vlsddisp).
                                                         
                                        ENABLE v_cod v_senha WITH FRAME {&FRAME-NAME}.  
                                    
                                        DELETE PROCEDURE h-b1crap20.
                                        
                                        IF  RETURN-VALUE = 'NOK' THEN  DO:
                                            ASSIGN v_btn_ok = ''
                                                   v_btn_cancela    = ''
                                                   l-houve-erro = TRUE.
                                                   {include/i-erro.i}
                                        END.

                                    END.
                                                                        
                                    IF  l-houve-erro = FALSE THEN DO:
                                        RUN dbo/b1crap22.p PERSISTENT SET h-b1crap22.
                                                     
                                        DO TRANSACTION ON ERROR UNDO:

                                            RUN realiza-transferencia IN h-b1crap22 (INPUT v_coop,
                                                                                     INPUT INTEGER(v_pac),
                                                                                     INPUT INTEGER(v_caixa),
                                                                                     INPUT v_operador,
                                                                                     INPUT 2, /* idorigem */
                                                                                     INPUT v_cooppara,
                                                                                     INPUT INTEGER(v_nrocontade),
                                                                                     INPUT 1, /* idseqttl */
                                                                                     INPUT INTEGER(v_nrocontapara),
                                                                                     INPUT DECI(v_valordocumento),
                                                                                     INPUT 0, /* nrsequni */
                                                                                     INPUT 1, /* idagenda */
                                                                                     INPUT 0, /* cdcoptfn */
                                                                                     INPUT 0, /* nrterfin */
                                                                                     INPUT aux_idtipcar,
                                                                                     INPUT v_opcao,
                                                                                     INPUT v_dsimpvia,
                                                                                     INPUT DECI(aux_nrcartao),
                                                                                     OUTPUT p-literal, 
                                                                                     OUTPUT p-ult-sequencia,
                                                                                     OUTPUT p-nrdocmto,
                                                                                     OUTPUT p-nrdoccre,
                                                                                     OUTPUT p-cdlantar,
                                                                                     OUTPUT aux_reciddeb, 
                                                                                     OUTPUT aux_recidcre,
                                                                                     OUTPUT p-nrultaut).
                                                             
                
                                            DELETE PROCEDURE h-b1crap22.
                                                                
                                            IF  RETURN-VALUE = "NOK" THEN DO:                   
                                            
                                                ASSIGN l-houve-erro = YES.

                                                EMPTY TEMP-TABLE w-craperr.
                                            
                                                FOR EACH craperr NO-LOCK WHERE craperr.cdcooper =  crapcop.cdcooper
                                                                           AND craperr.cdagenci =  INT(v_pac)
                                                                           AND craperr.nrdcaixa =  INT(v_caixa):
                                                
                                                    CREATE w-craperr.
                                                    ASSIGN w-craperr.cdcooper   = craperr.cdcooper 
                                                           w-craperr.cdagenci   = craperr.cdagenc
                                                           w-craperr.nrdcaixa   = craperr.nrdcaixa
                                                           w-craperr.nrsequen   = craperr.nrsequen
                                                           w-craperr.cdcritic   = craperr.cdcritic
                                                           w-craperr.dscritic   = craperr.dscritic
                                                           w-craperr.erro       = craperr.erro.
                                                END.
                                                UNDO.
        
                                            END.
        
                                        END. /** fim transaction **/
        
                                    END. /** fim houve-erro**/

                                END. /* Fim Transferencia */

                            END.

                            IF  l-houve-erro = TRUE THEN DO:
                    
                                    FOR EACH w-craperr NO-LOCK:
                                        
                                        CREATE craperr.
                                        ASSIGN craperr.cdcooper = crapcop.cdcooper
                                               craperr.cdagenci   = w-craperr.cdagenc
                                               craperr.nrdcaixa   = w-craperr.nrdcaixa
                                               craperr.nrsequen   = w-craperr.nrsequen
                                               craperr.cdcritic   = w-craperr.cdcritic
                                               craperr.dscritic   = w-craperr.dscritic
                                               craperr.erro       = w-craperr.erro.
                                    
                                        VALIDATE craperr.
            
                                    END.                              
                                    
                                    ASSIGN v_btn_ok = ''
                                           v_btn_cancela    = ''.                                    
                                    {include/i-erro.i}                
                        
                                END.                                      
        
                                IF  l-houve-erro = FALSE THEN DO:
                                    
                                    ASSIGN vh_foco          = '20'
                                           TpDocto          = 'Deposito'
                                           v_valordocumento = ''
                                           v_vlrdocumento   = ''
                                           v_identifica     = ''
                                           v_nrocontade     = ''
                                           
                                           l-finaliza       = TRUE
                                           v_dssencrd       = ''
                                           v_nrdocard       = ""
                                           v_infocry        = ""
                                           v_chvcry         = ""
                                           v_cartao         = ""
                                           
                                           v_nomede         = ''
                                           v_cpfcgcde       = ''
                                           v_nrocontapara   = ''
                                           v_nomepara1      = ''
                                           v_nomepara2      = ''
                                           v_cpfcgcpara1    = ''
                                           v_cpfcgcpara2    = ''
                                           v_codcoop        = ''
                                           v_cooppara       = ''
                                           v_btn_ok         = ''
                                           v_btn_cancela    = ''
                                           v_msgsaldo       = ''
                                           v_cod            = ''
                                           v_senha          = ''
                                           v_identifica     = ''.
                                        
                                    RUN carregaCooperativa  IN THIS-PROCEDURE (tpDocto).  
                                 
                                    ASSIGN l-recibo  = YES
                                           lOpenAutentica = YES.
            
                                END.

                        END.

                    END.
                    ELSE DO:
                        IF  tpDocto = 'Cheque' THEN DO:

                            /* Limpa Valores Quando for Trocado de Opcao */
                            IF  vh_TpDoctoAnt <> tpDocto  THEN DO:
        
                                ASSIGN vh_foco          = '13' 
                                       TpDocto          = 'Cheque'  
                                       v_valordocumento = ''
                                       v_vlrdocumento   = ''
                                       v_identifica     = ''
                                       v_nrocontade     = ''
                                       
                                       l-finaliza       = TRUE 
                                       v_dssencrd       = ''
                                       v_nrdocard       = ""
                                       v_infocry        = ""
                                       v_chvcry         = ""
                                       v_cartao         = ""
                                       
                                       v_nomede         = ''
                                       v_cpfcgcde       = ''
                                       v_nrocontapara   = ''
                                       v_nomepara1      = ''
                                       v_nomepara2      = ''
                                       v_cpfcgcpara1    = ''
                                       v_cpfcgcpara2    = ''
                                       v_codcoop        = ''
                                       v_cooppara       = ''
                                       v_cod            = ''
                                       v_senha          = ''
                                       v_btn_ok         = ''
                                       v_btn_cancela    = ''
                                       v_msgsaldo       = ''
                                       vh_TpDoctoAnt    = 'Cheque'.
                            END.

                            IF  v_nrocontapara <> '' THEN DO:
                                
                                RUN dbo/b1crap22.p PERSISTENT SET h-b1crap22. 
        
                                RUN verifica-conta IN h-b1crap22 (INPUT v_cooppara,
                                                                  INPUT INTEGER(v_pac),
                                                                  INPUT INTEGER(v_caixa),
                                                                  INPUT v_coop,
                                                                  INTEGER(v_nrocontapara),
                                                                  OUTPUT v_nmtitular1,
                                                                  OUTPUT v_nrcpfcgc1,
                                                                  OUTPUT v_nmtitular2,
                                                                  OUTPUT v_nrcpfcgc2).
                                DELETE PROCEDURE h-b1crap22.
                                                
                                IF  RETURN-VALUE = "NOK" THEN DO:
                                    
                                    l-houve-erro = TRUE.
                                    {include/i-erro.i} 
                                    vh_foco = '18'. /** Foco no campo conta destino **/
        
                                END.
                                ELSE DO:
        
                                    ASSIGN v_nomepara1   = v_nmtitular1
                                           v_cpfcgcpara1 = STRING(v_nrcpfcgc1)
                                           v_nomepara2   = v_nmtitular2
                                           v_cpfcgcpara2 = STRING(v_nrcpfcgc2)
                                           vh_foco = '20'.
        
                                    RUN dbo/b1crap51.p PERSISTENT SET h-b1crap51.
                                    RUN critica-valor  IN h-b1crap51(INPUT v_coop,
                                                       INPUT INT(v_pac),
                                                       INPUT INT(v_caixa),
                                                       INPUT v_vlrdocumento,
                                                       INPUT '',
                                                       OUTPUT p-cod-erro).
    
                                    DELETE PROCEDURE h-b1crap51.
    
                                    IF  RETURN-VALUE = "NOK"  AND
                                         p-cod-erro <> 760     THEN DO:
                                         ASSIGN vh_foco = "7". 
                                         {include/i-erro.i}
                                    END.
                                    ELSE DO:
                                        IF  p-cod-erro = 760   THEN DO:
                                            {include/i-erro.i}
                                        END.

                                        FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper
                                                           AND crapmdw.cdagenci = INT(v_pac)
                                                           AND crapmdw.nrdcaixa = INT(v_caixa)
                                                           NO-LOCK:
                  
                                            ASSIGN de-saldo-cheque = de-saldo-cheque + crapmdw.vlcompel.
            
                                        END.

                                        IF  de-saldo-cheque = DEC(v_vlrdocumento) THEN DO:
                                            {&OUT} "<script>window.location='crap022c.w"       +
                                            "?v_pcoop="         + GET-VALUE("v_cooppara")      + 
                                            "&v_nroconta="      + GET-VALUE("v_nrocontapara")  +
                                            "&v_vlrdocumento="  + GET-VALUE("v_vlrdocumento")  +
                                            "&v_identificador=" + GET-VALUE("v_identifica")    +
                                            "&v_nome1="         + v_nmtitular1                 + 
                                            "&v_cpfcgc1="       + v_nrcpfcgc1                  +
                                            "&v_nome2="         + v_nmtitular2                 + 
                                            "&v_cpfcgc2="       + v_nrcpfcgc2                  +
                                            "&v_cta-migrada="   + STRING(vh_fl_coop_mig)       +
                                            "&v_coop-migrada="  + STRING(vh_coop_mig)          +
                                            "&v_flg-coop-host=" + STRING(vh_fl_coop_host)      +
                                            "'</script>".
                                        END.
                                        ELSE DO:
                                               {&OUT} "<script>window.location='crap022a.w"         +
                                               "?v_cooppara="      + GET-VALUE("v_cooppara")        +
                                               "&v_nroconta="      + GET-VALUE("v_nrocontapara")    +
                                               "&v_vlrdocumento="  + GET-VALUE("v_vlrdocumento")    +
                                               "&v_identificador=" + GET-VALUE("v_identifica")      +
                                               "&v_nome1="         + v_nmtitular1                   +
                                               "&v_cpfcgc1="       + v_nrcpfcgc1                    +
                                               "&v_nome2="         + v_nmtitular2                   +
                                               "&v_cpfcgc2="       + v_nrcpfcgc2                    +
                                               "&v_cta-migrada="   + STRING(vh_fl_coop_mig)         +
                                               "&v_coop-migrada="  + STRING(vh_coop_mig)            +
                                               "&v_flg-coop-host=" + STRING(vh_fl_coop_host)        +
                                               "'</script>".
                                        END.

                                    END.
                                    
                                END.
        
                            END.  /* Fim do v_nrocontapara <> '' */

                        END.

                    END.

                END. /* Fim v_btn_ok <> '' AND NOT l-houve-erro */

            END. /* Fim do Else RETURN-VALUE = "NOK" */

        END.
         
        DELETE PROCEDURE h-b1crap00.
        
        IF  lOpenAutentica THEN DO:
            
            ASSIGN p-literal = "".

            /* Chama autentica para exibir nr da autenticaçao, porém nao 
              disponibiliza impressao */
           IF  v_opcao    = "C"  AND
               v_dsimpvia = "N"  THEN
               DO:
                  
                  {&OUT}
                      "<script>           
                          alert('Operaçao Realizada com Sucesso!'); 
                      </script>". 
               END.
           ELSE 
               DO:
            {&OUT}
               '<script language="JavaScript">' SKIP
               'window.open("autentica.html?v_plit=&v_pseq=' p-ult-sequencia 
               '&v_prec=' l-recibo '&v_psetcook=yes","waut","width=250,height=145,scrollbars=auto,alwaysRaised=true,left=0,top=0");' SKIP
               '</script>'.
               END.
               
               /*** Incluido por Fernando 26/11/2009 ***/
        
            IF  aux_vllanmto <> 0   THEN DO:  
                
                FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper
                               AND craptab.nmsistem = "CRED"
                               AND craptab.tptabela = "GENERI"
                               AND craptab.cdempres = 0
                               AND craptab.cdacesso = "VLCTRMVESP"
                               AND craptab.tpregist = 0
                               NO-LOCK NO-ERROR.
                    
                IF  AVAILABLE craptab   THEN DO:      
                     
                    IF (aux_vllanmto >= DEC(craptab.dstextab) AND
                        TpDocto = 'Deposito')    THEN DO:
                                  
                        FIND crabcop WHERE crabcop.nmrescop = aux_nmcoppara
                                           NO-LOCK NO-ERROR.
                                  
                        IF  AVAIL crabcop THEN
                            ASSIGN aux_cdcoppara = crabcop.cdcooper.
                                  
                        {&OUT}
                         '<script> window.location=
                            "crap051f.w?v_pconta=' + 
                               STRING(aux_nrdconta) '" + 
                            "&v_pvalor=" + 
                            "' aux_vllanmto '" +
                            "&v_pnrdocmto=" + 
                               "' p-nro-docto '" +
                            "&v_pult_sequencia=" + 
                               "' p-ult-sequencia '" +
                            "&v_pconta_base=" + 
                               "' STRING(aux_nrdconta) '" +
                            "&v_nrdolote=" +
                               "' STRING(p-nro-lote)'" +
                            "&v_pprograma=" + 
                               "' p-programa '" +
                            "&v_flgdebcc=" +
                               "' p-flgdebcc '" +
                            "&v_cooppara=" +      
                               "' aux_cdcoppara '" </script>'.
                    
                    END.
                    ELSE
                    IF  (aux_vllanmto >= DEC(craptab.dstextab) AND
                        TpDocto = 'Cheque')    THEN DO:
                                  
                        FIND crabcop WHERE crabcop.nmrescop = aux_nmcoppara
                                           NO-LOCK NO-ERROR.
                        
                        IF  AVAIL crabcop THEN
                            ASSIGN aux_cdcoppara = crabcop.cdcooper.
                                  
                        {&OUT}
                         '<script> window.location=
                            "crap051f.w?v_pconta=' + 
                               STRING(aux_nrdconta) '" + 
                            "&v_pvalor=" + 
                            "' aux_vllanmto '" +
                            "&v_pnrdocmto=" + 
                               "' p-nro-docto '" +
                            "&v_pult_sequencia=" + 
                               "' p-ult-sequencia '" +
                            "&v_pconta_base=" + 
                               "' STRING(aux_nrdconta) '" +
                            "&v_nrdolote=" +
                               "' STRING(p-nro-lote)'" +
                            "&v_pprograma=" + 
                               "' p-programa '" +
                            "&v_flgdebcc=" +
                               "' p-flgdebcc '" +
                            "&v_cooppara=" +      
                               "' aux_cdcoppara '" </script>'.
                    END.

                END.

            END.

        END.
        
        IF  l-finaliza THEN 
            ASSIGN v_opcao      = "R"
                   v_dsimpvia   = "S".
        
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

        /* Carrega os valores iniciais da tela */
        IF  GET-VALUE("tpDoctoSel") = "" THEN DO:
            ASSIGN vh_foco       = '20'
                   tpDocto       = 'Deposito'
                   vh_TpDoctoAnt = 'Deposito'.
        END.
        ELSE DO:
            ASSIGN vh_foco       = '20'  
                   vh_tpDoctoSel = GET-VALUE("tpDoctoSel")
                   tpDocto       = vh_tpDoctoSel
                   vh_TpDoctoAnt = vh_tpDoctoSel.
        END.

        /* Carrega os valores da tela crap022a ou crap022a1 para crap022 */
        IF  GET-VALUE("v_tela") = "crap022a"  OR
            GET-VALUE("v_tela") = "crap022a1" OR
            GET-VALUE("v_tela") = "crap022b" THEN DO:

            ASSIGN vh_foco          = '20'  
                   vh_tpDoctoSel    = "Cheque"
                   tpDocto          = "Cheque"
                   vh_TpDoctoAnt    = "Cheque"
                   v_cooppara       = GET-VALUE("v_coop")
                   v_nrocontapara   = GET-VALUE("v_nroconta")
                   v_nomepara1      = GET-VALUE("v_nome1")
                   v_cpfcgcpara1    = GET-VALUE("v_cpfcgc1")
                   v_nomepara2      = GET-VALUE("v_nome2")
                   v_cpfcgcpara2    = GET-VALUE("v_cpfcgc2")
                   v_identifica     = GET-VALUE("v_identificador")
                   v_vlrdocumento   = GET-VALUE("v_valortotchq")
                   p_flg-cta-migrada = GET-VALUE("v_cta-migrada")
                   v_flg-cta-migrada = LOGICAL(p_flg-cta-migrada)
                   p_flg-coop-host   = GET-VALUE("v_flg-coop-host")
                   v_flg-coop-host   = LOGICAL(p_flg-coop-host)
                   v_coop-migrada    = GET-VALUE("v_coop-migrada")
                   vh_fl_coop_mig    = GET-VALUE("v_cta-migrada")
                   vh_fl_coop_host   = GET-VALUE("v_flg-coop-host")
                   vh_coop_mig       = GET-VALUE("v_coop-migrada").

        END.

        RUN carregaCooperativa  IN THIS-PROCEDURE (tpDocto).

        RUN displayFields.   
        RUN enableFields.

        DISABLE v_cod v_senha WITH FRAME {&FRAME-NAME}.

        RUN outputFields.

    END.

    /* Show error messages. */
    IF AnyMessage() THEN DO:
       
        ShowDataMessages().
    END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
