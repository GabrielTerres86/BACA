/* .............................................................................

   Programa: siscaixa/web/crap002.w
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 03/06/2015

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Consulta Conta

   Alteracoes: 11/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)
                            
               09/03/2006 - Usar o codigo da cooperativa nas buscas (Evandro).
               
               10/12/2008 - Incluido campos de Capital e Aplicacoes (Elton).

               10/03/2009 - Ajuste para unificacao dos bancos de dados
                            (Evandro).
                            
               18/06/2009 - Tratamento para impressão do SALDO EM APLICACAO 
                            (Diego).
                            
               25/08/2009 - Incluido campo "Poup. Prog" (Elton).             
               
               07/02/2013 - Incluir chamada da procedure valida_restricao_operador
                            (Lucas R.).
                            
               03/10/2014 - Associado codigo da cooperativa e nome do servidor
                            do GED ao form principal da rotina 2, para 
                            utilizacao na consulta do cartao de assinatura.
                            (Chamado 174180) - (Fabricio)
                            
               03/06/2015 - Tratamento para reload de rotina ao abrir/fechar
                            o BL. Melhoria SD 260475 (Lunelli).
                            
............................................................................ */

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
       FIELD v_acertoc AS CHARACTER FORMAT "X(256)":U 
       FIELD v_agencia AS CHARACTER FORMAT "X(256)":U 
       FIELD v_bloq AS CHARACTER FORMAT "X(256)":U 
       FIELD v_bloqfpraca AS CHARACTER FORMAT "X(256)":U 
       FIELD v_bloqpraca AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cpf AS CHARACTER FORMAT "X(256)":U 
       FIELD v_csal AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data AS CHARACTER FORMAT "X(256)":U 
       FIELD v_dbcpmf AS CHARACTER FORMAT "X(256)":U 
       FIELD v_descsit AS CHARACTER FORMAT "X(256)":U 
       FIELD v_dev AS CHARACTER FORMAT "X(256)":U 
       FIELD v_disp AS CHARACTER FORMAT "X(256)":U 
       FIELD v_emp AS CHARACTER FORMAT "X(256)":U 
       FIELD v_est AS CHARACTER FORMAT "X(256)":U 
       FIELD v_fcheque AS CHARACTER FORMAT "X(256)":U 
       FIELD v_ident AS CHARACTER FORMAT "X(256)":U 
       FIELD v_limcred AS CHARACTER FORMAT "X(256)":U 
       FIELD v_log AS CHARACTER FORMAT "X(256)":U 
       FIELD v_magnet AS CHARACTER FORMAT "X(256)":U 
       FIELD v_magnet1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msgtrf AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nomconj AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_orgao AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
       FIELD v_smax AS CHARACTER FORMAT "X(256)":U 
       FIELD v_stotal AS CHARACTER FORMAT "X(256)":U 
       FIELD v_tpconta AS CHARACTER FORMAT "X(256)":U 
       FIELD v_ultatual AS CHARACTER FORMAT "X(256)":U 
       FIELD v_capital  AS CHARACTER FORMAT "X(256)":U
       FIELD v_aplica   AS CHARACTER FORMAT "X(256)":U
       FIELD v_poupanca AS CHARACTER FORMAT "X(256)":U
       FIELD vh_cdcooper AS CHARACTER FORMAT "X(256)":U
       FIELD vh_gedserv AS CHARACTER FORMAT "X(256)":U.


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


DEF TEMP-TABLE tt-conta
    FIELD situacao           as char format "x(21)"
    field tipo-conta         as char format "x(21)"
    field empresa            AS  char format "x(15)"
    field devolucoes         AS inte format "99"
    field agencia            AS char format "x(15)"
    field magnetico          as inte format "z9"     
    field estouros           as inte format "zzz9"
    field folhas             as inte format "zzz,zz9"
    field identidade         AS CHAR 
    field orgao              AS CHAR 
    field cpfcgc             AS CHAR 
    field disponivel         AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    FIELD bloqueado          AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    field bloq-praca         AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    field bloq-fora-praca    AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    field cheque-salario     AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    field saque-maximo       AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    field acerto-conta       AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    field db-cpmf            AS DEC FORMAT "zzz,zzz,zzz,zz9.99-" 
    field limite-credito     AS DEC 
    field ult-atualizacao    AS DATE
    field saldo-total        AS DEC FORMAT "zzz,zzz,zzz,zz9.99-"
    FIELD nome-tit           AS CHAR
    FIELD nome-seg-tit       AS CHAR
    FIELD capital            AS DEC FORMAT "zzz,zzz,zzz,zz9.99-".
    
DEFINE VARIABLE h-b1crap00         AS HANDLE  NO-UNDO.
DEFINE VARIABLE h-b1crap02         AS HANDLE  NO-UNDO.

DEFINE VARIABLE i-qtd-taloes       AS INT     NO-UNDO.
DEFINE VARIABLE dt-data            AS DATE    NO-UNDO.

DEFINE VARIABLE p-literal          AS CHAR    NO-UNDO.
DEFINE VARIABLE p-ult-sequencia    AS INTE    NO-UNDO.

DEFINE VARIABLE    aux_vltotrda    AS DECI    NO-UNDO. 
DEFINE VARIABLE    aux_vltotrpp    AS DECI    NO-UNDO. 
DEFINE VARIABLE    aux_tpimpres    AS INT     NO-UNDO.
DEFINE VARIABLE    aux_dscritic    AS CHAR    NO-UNDO.
DEFINE VARIABLE    h-b1wgen9998    AS HANDLE  NO-UNDO.

DEFINE TEMP-TABLE  craterr         LIKE craperr. 
  
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE crap002.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.v_msgtrf ab_unmap.v_magnet1 ab_unmap.v_log ab_unmap.v_msg ab_unmap.vh_foco ab_unmap.v_nomconj ab_unmap.v_nome ab_unmap.v_agencia ab_unmap.v_acertoc ab_unmap.v_bloq ab_unmap.v_bloqfpraca ab_unmap.v_bloqpraca ab_unmap.v_caixa ab_unmap.v_conta ab_unmap.v_coop ab_unmap.v_cpf ab_unmap.v_csal ab_unmap.v_data ab_unmap.v_dbcpmf ab_unmap.v_descsit ab_unmap.v_dev ab_unmap.v_disp ab_unmap.v_emp ab_unmap.v_est ab_unmap.v_fcheque ab_unmap.v_ident ab_unmap.v_limcred ab_unmap.v_magnet ab_unmap.v_operador ab_unmap.v_orgao ab_unmap.v_pac ab_unmap.v_smax ab_unmap.v_stotal ab_unmap.v_tpconta ab_unmap.v_ultatual ab_unmap.v_capital ab_unmap.v_aplica ab_unmap.v_poupanca ab_unmap.vh_cdcooper ab_unmap.vh_gedserv
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.v_msgtrf ab_unmap.v_magnet1 ab_unmap.v_log ab_unmap.v_msg ab_unmap.vh_foco ab_unmap.v_nomconj ab_unmap.v_nome ab_unmap.v_agencia ab_unmap.v_acertoc ab_unmap.v_bloq ab_unmap.v_bloqfpraca ab_unmap.v_bloqpraca ab_unmap.v_caixa ab_unmap.v_conta ab_unmap.v_coop ab_unmap.v_cpf ab_unmap.v_csal ab_unmap.v_data ab_unmap.v_dbcpmf ab_unmap.v_descsit ab_unmap.v_dev ab_unmap.v_disp ab_unmap.v_emp ab_unmap.v_est ab_unmap.v_fcheque ab_unmap.v_ident ab_unmap.v_limcred ab_unmap.v_magnet ab_unmap.v_operador ab_unmap.v_orgao ab_unmap.v_pac ab_unmap.v_smax ab_unmap.v_stotal ab_unmap.v_tpconta ab_unmap.v_ultatual ab_unmap.v_capital ab_unmap.v_aplica ab_unmap.v_poupanca ab_unmap.vh_cdcooper ab_unmap.vh_gedserv

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.v_msgtrf AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_magnet1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_log AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_msg AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.vh_foco AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nomconj AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nome AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_agencia AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_acertoc AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_bloq AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_bloqfpraca AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_bloqpraca AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_caixa AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_conta AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_coop AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cpf AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_csal AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_data AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_dbcpmf AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_descsit AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_dev AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_disp AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_emp AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_est AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_fcheque AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.vh_cdcooper AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.vh_gedserv AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 60.6 BY 14.14.

/* DEFINE FRAME statement is approaching 4K Bytes.  Breaking it up   */
DEFINE FRAME Web-Frame
     ab_unmap.v_ident AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_limcred AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_magnet AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_operador AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_orgao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_pac AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_smax AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_stotal AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_tpconta AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_ultatual AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_capital AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN
          SIZE 20 BY 1
     ab_unmap.v_aplica  AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN
          SIZE 20 BY 1
     ab_unmap.v_poupanca AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN
          SIZE 20 BY 1    
     WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 60.6 BY 14.14.


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
          FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
          FIELD v_acertoc AS CHARACTER FORMAT "X(256)":U 
          FIELD v_agencia AS CHARACTER FORMAT "X(256)":U 
          FIELD v_bloq AS CHARACTER FORMAT "X(256)":U 
          FIELD v_bloqfpraca AS CHARACTER FORMAT "X(256)":U 
          FIELD v_bloqpraca AS CHARACTER FORMAT "X(256)":U 
          FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
          FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cpf AS CHARACTER FORMAT "X(256)":U 
          FIELD v_csal AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_dbcpmf AS CHARACTER FORMAT "X(256)":U 
          FIELD v_descsit AS CHARACTER FORMAT "X(256)":U 
          FIELD v_dev AS CHARACTER FORMAT "X(256)":U 
          FIELD v_disp AS CHARACTER FORMAT "X(256)":U 
          FIELD v_emp AS CHARACTER FORMAT "X(256)":U 
          FIELD v_est AS CHARACTER FORMAT "X(256)":U 
          FIELD v_fcheque AS CHARACTER FORMAT "X(256)":U 
          FIELD v_ident AS CHARACTER FORMAT "X(256)":U 
          FIELD v_limcred AS CHARACTER FORMAT "X(256)":U 
          FIELD v_log AS CHARACTER FORMAT "X(256)":U 
          FIELD v_magnet AS CHARACTER FORMAT "X(256)":U 
          FIELD v_magnet1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msgtrf AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nomconj AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_orgao AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD v_smax AS CHARACTER FORMAT "X(256)":U 
          FIELD v_stotal AS CHARACTER FORMAT "X(256)":U 
          FIELD v_tpconta AS CHARACTER FORMAT "X(256)":U 
          FIELD v_ultatual AS CHARACTER FORMAT "X(256)":U 
          FIELD v_capital AS CHARACTER FORMAT "X(256)":U
          FIELD v_aplica  AS CHARACTER FORMAT "X(256)":U
          FIELD v_poupanca AS CHARACTER FORMAT "X(256)":U
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS                              

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 14.14
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
/* SETTINGS FOR FILL-IN ab_unmap.vh_foco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_acertoc IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_agencia IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_bloq IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_bloqfpraca IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_bloqpraca IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_caixa IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_conta IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cpf IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_csal IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_dbcpmf IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_descsit IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_dev IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_disp IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_emp IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_est IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_fcheque IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_ident IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_limcred IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_log IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_magnet IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_magnet1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_msgtrf IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nomconj IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nome IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_orgao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_smax IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_stotal IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_tpconta IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_ultatual IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_capital  IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_aplica   IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_poupanca   IN FRAME Web-Frame
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
    ("vh_foco":U,"ab_unmap.vh_foco":U,ab_unmap.vh_foco:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_acertoc":U,"ab_unmap.v_acertoc":U,ab_unmap.v_acertoc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_agencia":U,"ab_unmap.v_agencia":U,ab_unmap.v_agencia:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_bloq":U,"ab_unmap.v_bloq":U,ab_unmap.v_bloq:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_bloqfpraca":U,"ab_unmap.v_bloqfpraca":U,ab_unmap.v_bloqfpraca:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_bloqpraca":U,"ab_unmap.v_bloqpraca":U,ab_unmap.v_bloqpraca:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_caixa":U,"ab_unmap.v_caixa":U,ab_unmap.v_caixa:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_conta":U,"ab_unmap.v_conta":U,ab_unmap.v_conta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cpf":U,"ab_unmap.v_cpf":U,ab_unmap.v_cpf:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_csal":U,"ab_unmap.v_csal":U,ab_unmap.v_csal:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_dbcpmf":U,"ab_unmap.v_dbcpmf":U,ab_unmap.v_dbcpmf:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_descsit":U,"ab_unmap.v_descsit":U,ab_unmap.v_descsit:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_dev":U,"ab_unmap.v_dev":U,ab_unmap.v_dev:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_disp":U,"ab_unmap.v_disp":U,ab_unmap.v_disp:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_emp":U,"ab_unmap.v_emp":U,ab_unmap.v_emp:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_est":U,"ab_unmap.v_est":U,ab_unmap.v_est:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_fcheque":U,"ab_unmap.v_fcheque":U,ab_unmap.v_fcheque:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_ident":U,"ab_unmap.v_ident":U,ab_unmap.v_ident:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_limcred":U,"ab_unmap.v_limcred":U,ab_unmap.v_limcred:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_log":U,"ab_unmap.v_log":U,ab_unmap.v_log:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_magnet":U,"ab_unmap.v_magnet":U,ab_unmap.v_magnet:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_magnet1":U,"ab_unmap.v_magnet1":U,ab_unmap.v_magnet1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msgtrf":U,"ab_unmap.v_msgtrf":U,ab_unmap.v_msgtrf:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nomconj":U,"ab_unmap.v_nomconj":U,ab_unmap.v_nomconj:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nome":U,"ab_unmap.v_nome":U,ab_unmap.v_nome:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_orgao":U,"ab_unmap.v_orgao":U,ab_unmap.v_orgao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_smax":U,"ab_unmap.v_smax":U,ab_unmap.v_smax:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_stotal":U,"ab_unmap.v_stotal":U,ab_unmap.v_stotal:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_tpconta":U,"ab_unmap.v_tpconta":U,ab_unmap.v_tpconta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_ultatual":U,"ab_unmap.v_ultatual":U,ab_unmap.v_ultatual:HANDLE IN FRAME {&FRAME-NAME}).       
  RUN htmAssociate
     ("v_capital":U,"ab_unmap.v_capital":U,ab_unmap.v_capital:HANDLE IN FRAME
      {&FRAME-NAME}).   
  RUN htmAssociate
     ("v_aplica":U,"ab_unmap.v_aplica":U,ab_unmap.v_aplica:HANDLE IN FRAME
      {&FRAME-NAME}).
  RUN htmAssociate
     ("v_poupanca":U,"ab_unmap.v_poupanca":U,ab_unmap.v_poupanca:HANDLE IN FRAME
      {&FRAME-NAME}).
  RUN htmAssociate
     ("vh_cdcooper":U,"ab_unmap.vh_cdcooper":U,ab_unmap.vh_cdcooper:HANDLE IN FRAME
      {&FRAME-NAME}).
  RUN htmAssociate
     ("vh_gedserv":U,"ab_unmap.vh_gedserv":U,ab_unmap.vh_gedserv:HANDLE IN FRAME
      {&FRAME-NAME}).
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
     
  /* STEP 0 -
   * Output the MIME header and set up the object as state-less or state-aware. 
   * This is required if any HTML is to be returned to the browser. 
   *
   * NOTE: Move 'RUN outputHeader.' to the GET section below if you are going
   * to simulate another Web request by running a Web Object from this
   * procedure.  Running outputHeader precludes setting any additional cookie
   * information.
   */ 
  RUN outputHeader.
  {include/i-global.i}
  
  /* Describe whether to receive FORM input for all the fields.  For example,
   * check particular input fields (using GetField in web-utilities-hdl). 
   * Here we look at REQUEST_METHOD. 
   */
  IF REQUEST_METHOD = "POST":U THEN DO:
    /* STEP 1 -
     * Copy HTML input field values to the Progress form buffer. */
    RUN inputFields.

    /* STEP 2 -
     * Open the database or SDO query and and fetch the first record. 
    RUN findRecords.                                                  */
    
    /* STEP 3 -    
     * AssignFields will save the data in the frame.
     * (it automatically upgrades the lock to exclusive while doing the update)
     * 
     *  If a new record needs to be created set AddMode to true before 
        running assignFields.  
     *     setAddMode(TRUE).   */

    {include/assignfields.i} /* Colocado a chamada do assignFields dentro da include */
    
    /* STEP 4 -
     * Decide what HTML to return to the user. Choose STEP 4.1 to simulate
     * another Web request -OR- STEP 4.2 to return the original form (the
     * default action).
     *
     * STEP 4.1 -
     * To simulate another Web request, change the REQUEST_METHOD to GET
     * and RUN the Web object here.  For example,
     *
     *  ASSIGN REQUEST_METHOD = "GET":U.
     *  RUN run-web-object IN web-utilities-hdl ("myobject.w":U).
     */
     
    /* STEP 4.2 -
     * To return the form again, set data values, display them, and output 
     * them to the WEB stream.  
     *
     * STEP 4.2a -
     * Set any values that need to be set, then display them. */


             
        

     IF  get-value("cancela1") <> "" THEN DO:
         ASSIGN v_conta    = ""
                v_nome     = ""
                v_agencia  = ""
                v_nomconj  = ""
                v_tpconta  = ""
                v_descsit  = ""
                v_ident    = ""
                v_orgao    = ""
                v_cpf      = ""
                v_emp      = ""
                v_magnet   = ""
                v_magnet1  = ""
                v_fcheque  = ""
                v_dev      = ""  
                v_est      = ""  
                v_disp     = ""
                v_smax     = "" 
                v_bloq     = ""
                v_acertoc  = ""
                v_bloqpraca  = ""  
                v_dbcpmf   = ""
                v_bloqfpraca = ""
                v_limcred  = ""
                v_csal     = ""
                v_ultatual = ""
                v_stotal   = "" 
                v_capital  = ""
                v_aplica   = ""
                v_poupanca = ""
                vh_foco = "9"
                vh_cdcooper = ""
                vh_gedserv  = "".
     END.
     ELSE DO:


         RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.
         
         RUN valida_restricao_operador IN h-b1crap02
                                      (INPUT v_operador,
                                       INPUT INT(v_conta),
                                       INPUT v_coop,
                                       INPUT INT(v_pac),  
                                       INPUT INT(v_caixa)).

         IF  VALID-HANDLE(h-b1crap02) THEN
             DELETE OBJECT h-b1crap02.
             
         IF RETURN-VALUE <> "OK" THEN
            DO:
                ASSIGN v_conta = " ".
                {include/i-erro.i}
            END. 
         ELSE
         IF  get-value("saldo") <> " "  OR
             get-value("saldo_aplica") <> " " THEN  DO:
             
             RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.
             
             RUN consulta-conta IN h-b1crap02 (INPUT v_coop,         
                                               INPUT INT(v_pac),
                                               INPUT INT(v_caixa),
                                               INPUT INT(v_conta),
                                               OUTPUT TABLE tt-conta).

             IF  RETURN-VALUE = "NOK" THEN  
                 DO:
                    ASSIGN v_conta = " ".
                    {include/i-erro.i}
                 END.
                   
             ELSE DO:
                    
                 FIND FIRST tt-conta NO-LOCK NO-ERROR.
                 IF  AVAIL tt-conta  THEN  DO:

                     IF   get-value("saldo_aplica") <> " "  THEN 
                          DO:
                              ASSIGN aux_tpimpres = 1.  /* Saldo aplicação */       

                              RUN calcula_aplicacoes IN h-b1crap02 (INPUT v_coop,       
                                                                    INPUT INT(v_pac),
                                                                    INPUT INT(v_caixa),
                                                                    OUTPUT aux_vltotrda,
                                                                    OUTPUT TABLE craterr).                   
                              RUN calcula_poupanca IN h-b1crap02 
                                                         (INPUT v_coop,
                                                          OUTPUT aux_vltotrpp).
                                       
                          END.
                     ELSE
                          ASSIGN aux_tpimpres = 2.  /* Saldo conta corrente */  

                     RUN impressao-saldo IN h-b1crap02 
                                               (INPUT v_coop,        
                                                INPUT INT(v_pac),
                                                INPUT INT(v_caixa),
                                                INPUT v_operador,
                                                INPUT INT(v_conta),
                                                INPUT tt-conta.disponivel,
                                                INPUT tt-conta.bloqueado,
                                                INPUT tt-conta.bloq-praca,
                                                INPUT tt-conta.bloq-fora-praca,
                                                INPUT tt-conta.limite-credito,
                                                INPUT aux_vltotrda,
                                                INPUT aux_vltotrpp, 
                                                INPUT aux_tpimpres,
                                                OUTPUT p-literal).
                                                                                                                                               
                     ASSIGN p-ult-sequencia = 9999.
               
                     {&OUT} '<script> window.open("autentica.html?v_plit=" + 
                            "' p-literal '" + "&v_pseq=" + 
                            "' p-ult-sequencia '" + "&v_prec=" + "yes" +
                            "&v_psetcook=" + "no","waut", 
        "width=250,height=145,scrollbars=auto,alwaysRaised=true,left=0,top =0")
                            </script>'. 
                 END.
             END.

             DELETE PROCEDURE h-b1crap02.
         END.

         ELSE DO:

              RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
              
              RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                                 INPUT v_pac,
                                                 INPUT v_caixa).
    
              IF RETURN-VALUE = "NOK" THEN 
                 DO:
                     {include/i-erro.i}
                 END.
              ELSE  
                 DO:
    
                     RUN verifica-abertura-boletim IN h-b1crap00
                                                            (INPUT v_coop,
                                                             INPUT v_pac,
                                                             INPUT v_caixa,
                                                             INPUT v_operador).
                   
                     IF  RETURN-VALUE = "NOK" THEN 
                         DO:
                             {include/i-erro.i}
                         END.
                     ELSE 
                         DO:     
                             RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.
                            
                             RUN consulta-conta IN h-b1crap02 
                                                       (INPUT v_coop,        
                                                        INPUT INT(v_pac),
                                                        INPUT INT(v_caixa),
                                                        INPUT INT(v_conta),
                                                        OUTPUT TABLE tt-conta).
                             IF  RETURN-VALUE = "NOK" THEN  
                                 DO:
                                     ASSIGN v_conta = " ".
                                     {include/i-erro.i}
                                 END.
                             ELSE 
                                 DO:
                                 RUN retornaMsgTransferencia IN h-b1crap02
                                                       (INPUT v_coop,      
                                                        INPUT INTEGER(v_pac),
                                                        INPUT INTEGER(v_caixa),
                                                        INPUT INTEGER(v_conta),
                                                        OUTPUT v_msgtrf).
                            
                                  IF RETURN-VALUE = 'NOK' THEN 
                                  DO:
                                     {include/i-erro.i}
                                  END.
                                  ELSE 
                                  DO:
                                     FIND FIRST tt-conta NO-LOCK NO-ERROR.
                                     IF  AVAIL tt-conta  THEN 
                                     DO:
                                         IF tt-conta.ult-atualizacao = ? THEN
                                            ASSIGN v_ultatual = "".
                                         ELSE
                                            ASSIGN v_ultatual =
                                  string(tt-conta.ult-atualizacao,"99/99/9999").      
                            
                                         /*--- Qtdade Taloes retirados no mes */
                                         ASSIGN i-qtd-taloes = 0.
                            
                                         ASSIGN dt-data =
                                             date(MONTH(crapdat.dtmvtolt),01,
                                                  YEAR(crapdat.dtmvtolt)).
                            
                                         FOR EACH crapfdc NO-LOCK WHERE
                                             crapfdc.cdcooper = 
                                                     crapcop.cdcooper        AND
                                             crapfdc.nrdconta = INT(v_conta) AND
                                             crapfdc.dtretchq >= dt-data     AND
                                             crapfdc.tpcheque = 1
                                             BREAK BY crapfdc.nrseqems:
                                             IF   FIRST-OF(crapfdc.nrseqems)
                                                  THEN
                                             ASSIGN i-qtd-taloes = i-qtd-taloes 
                                                                            + 1.
                                         END.
                                         /*---------------------------------*/
                            
                                        ASSIGN 
                                            vh_cdcooper = STRING(crapcop.cdcooper)
                                            v_nome    = tt-conta.nome-tit
                                         v_nomconj  = tt-conta.nome-seg-tit
                                         v_descsit  = tt-conta.situacao     
                                         v_tpconta  = tt-conta.tipo-conta   
                                         v_emp      = tt-conta.empresa    
                                         v_dev      = 
                                         string(tt-conta.devolucoes)         
                                         v_agencia  = tt-conta.agencia
                                         v_magnet   = 
                                         string(tt-conta.magnetico) 
                                         v_magnet1    = string(i-qtd-taloes) 
                                         v_est        =
                                         string(tt-conta.estouros)           
                                         v_fcheque    =
                                         string(tt-conta.folhas)             
                                         v_ident      =
                                         tt-conta.identidade         
                                         v_orgao      = 
                                         tt-conta.orgao              
                                         v_cpf        =
                                         tt-conta.cpfcgc             
                                         v_disp       = 
                        string(tt-conta.disponivel,">>>,>>>,>>>,>>9.99-")
                                         v_bloq       =
                        string(tt-conta.bloqueado,">>>,>>>,>>>,>>9.99-")
                                         v_bloqpraca  = 
                        string(tt-conta.bloq-praca,">>>,>>>,>>>,>>9.99-")         
                                         v_bloqfpraca =
                        string(tt-conta.bloq-fora-praca,">>>,>>>,>>>,>>9.99-")    
                                         v_csal       = 
                        string(tt-conta.cheque-salario,">>>,>>>,>>>,>>9.99-")      
                                         v_smax       = 
                        string(tt-conta.saque-maximo,">>>,>>>,>>>,>>9.99-")         
                                         v_acertoc    = 
                        string(tt-conta.acerto-conta,">>>,>>>,>>>,>>9.99-")         
                                         v_dbcpmf     = 
                        string(tt-conta.db-cpmf,">>>,>>>,>>>,>>9.99-")             
                                         v_limcred    = 
                        string(tt-conta.limite-credito,">>>,>>>,>>>,>>9.99-")      
                                         v_stotal     =
                        string(tt-conta.saldo-total,">>>,>>>,>>>,>>9.99-")
                                         v_capital    =
                        STRING(tt-conta.capital,">>>,>>>,>>>,>>9.99-").
                           
                                         RUN verifica_anota IN h-b1crap02 
                                                          (INPUT v_coop,       
                                                           INPUT INT(v_pac),
                                                           INPUT INT(v_caixa),
                                                           INPUT INT(v_conta)).
                                 
                                         RUN calcula_aplicacoes IN h-b1crap02 
                                                        (INPUT v_coop,       
                                                         INPUT INT(v_pac),
                                                         INPUT INT(v_caixa),
                                                         OUTPUT aux_vltotrda,
                                                         OUTPUT TABLE craterr).


                                
                                         v_aplica  =
                                      STRING(aux_vltotrda,">>>,>>>,>>>,>>9.99-").
                                         
                                          
                                         RUN critica_aplicacao IN h-b1crap02
                                                         (INPUT v_coop,
                                                          INPUT INT(v_pac),
                                                          INPUT INT(v_caixa),
                                                          INPUT INT(v_conta),
                                                          INPUT TABLE craterr).
                                              
                                         RUN calcula_poupanca  IN h-b1crap02
                                                      (INPUT v_coop,
                                                       OUTPUT aux_vltotrpp). 
                                         v_poupanca =
                                      STRING(aux_vltotrpp,">>>,>>>,>>>,>>9.99-").
                                         
                                         ASSIGN vh_gedserv = IF OS-GETENV("PKGNAME") = "pkgprod" THEN
                                                                 "ged.cecred.coop.br"
                                                             ELSE
                                                                 "0303hmlged01".
                                         
                                         
                                         {include/i-erro.i}            
                                
                                     END.
                                  END.
                                 END.
                          
                             DELETE PROCEDURE h-b1crap02.
                            
                 END.  
              END.
              DELETE PROCEDURE h-b1crap00.

         END.    /* Saldo */
    END.   /* Cancela */
   
    RUN displayFields.
   
    /* STEP 4.2b -
     * Enable objects that should be enabled. */
    RUN enableFields.

    /* STEP 4.2c -
     * OUTPUT the Progress form buffer to the WEB stream. */
    RUN outputFields.
    
  END. /* Form has been submitted. */
 
  /* REQUEST-METHOD = GET */ 
  ELSE DO:
    /* This is the first time that the form has been called. Just return the
     * form.  Move 'RUN outputHeader.' here if you are going to simulate
     * another Web request. */ 
   
    /* STEP 1 -
     * Open the database or SDO query and and fetch the first record. */ 
    RUN findRecords.
    
    /* Return the form again. Set data values, display them, and output them
     * to the WEB stream.  
     *
     * STEP 2a -
     * Set any values that need to be set, then display them. */   

    /* Chamado da janela de  BL caso forem usadas as teclas F8/F7, pois o elemento opener assumido
       não é o menu, e sim o próprio frame das rotinas (pane). Então é necessário alguém para chamar a função js
       que recarrega a rotina que está aberta ao ser aberto/fechado o BL */
    IF get-value("opener") = "pane" THEN DO:
        {&OUT} '<script language=JavaScript src="/script/formatadadosie.js"></script>'.
        {&OUT} '<script>carregaRotinaFramePrincipal(this, "' + REPLACE(get-value("rotina"), "|", "=")  + '");</script>'.
    END.
    ELSE 
        DO:
            vh_foco = "9".
            IF get-value("v_log") = "yes" THEN DO:
        
                RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
        
                RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                                   INPUT v_pac,
                                                   INPUT v_caixa).
        
                IF RETURN-VALUE = "NOK" THEN DO:
                    {include/i-erro.i}
                END.
                ELSE  DO:
        
                    RUN verifica-abertura-boletim IN h-b1crap00(INPUT v_coop,
                                                                INPUT v_pac,
                                                                INPUT v_caixa,
                                                                INPUT v_operador).
                                                                                                                        
                    IF RETURN-VALUE = "NOK" THEN DO:
                       {include/i-erro.i}
                    END.
                    ELSE DO:
        
                        RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.
                        
                        RUN valida_restricao_operador IN h-b1crap02
                                                     (INPUT v_operador,
                                                      INPUT INT(GET-VALUE("v_conta")),
                                                      INPUT v_coop,
                                                      INPUT INT(v_pac),  
                                                      INPUT INT(v_caixa)).
                        
                        IF  VALID-HANDLE(h-b1crap02) THEN
                            DELETE OBJECT h-b1crap02.
                        
                        IF RETURN-VALUE <> "OK" THEN
                           DO:
                               ASSIGN v_conta = " ".
                               {include/i-erro.i}
                           END. 
                        ELSE DO:
                            RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.
                            
                            RUN consulta-conta 
                                     IN h-b1crap02 (INPUT v_coop,        
                                                    INPUT INT(v_pac),
                                                    INPUT INT(v_caixa),
                                                    INPUT INT(GET-VALUE("v_conta")),
                                                    OUTPUT TABLE tt-conta).
                            IF RETURN-VALUE = "NOK" THEN  DO:
                               ASSIGN v_conta = " ".
                               {include/i-erro.i}
                            END.
                            ELSE DO:
                          
                                RUN retornaMsgTransferencia IN h-b1crap02 
                                                      (INPUT v_coop,        
                                                       INPUT INTEGER(v_pac),
                                                       INPUT INTEGER(v_caixa),
                                                       INPUT INTEGER(get-value("v_conta")),
                                                       OUTPUT v_msgtrf).
                          
                                IF RETURN-VALUE = 'NOK' THEN DO:
                                    {include/i-erro.i}
                                END.
                                ELSE DO:
                                   FIND FIRST tt-conta NO-LOCK NO-ERROR.
                                   IF  AVAIL tt-conta  THEN DO:
                                       IF tt-conta.ult-atualizacao = ? THEN
                                          ASSIGN v_ultatual = "".
                                       ELSE
                                          ASSIGN v_ultatual = 
                                          string(tt-conta.ult-atualizacao,"99/99/9999").     
                                       
                                        /*--- Qtdade Taloes retirados no mes ---*/
                                        ASSIGN i-qtd-taloes = 0.
                          
                                        ASSIGN dt-data = date(MONTH(crapdat.dtmvtolt),01,
                                                              YEAR(crapdat.dtmvtolt)).
                            
                                        FOR EACH crapfdc NO-LOCK WHERE
                                                 crapfdc.cdcooper = crapcop.cdcooper AND
                                                 crapfdc.nrdconta = INT(v_conta) AND
                                                 crapfdc.dtretchq >= dt-data     AND
                                                 crapfdc.tpcheque = 1
                                                 BREAK BY crapfdc.nrseqems:
                                                 IF   FIRST-OF(crapfdc.nrseqems)   THEN
                                                ASSIGN i-qtd-taloes = i-qtd-taloes + 1.
                                        END.
                                        /*---------------------------------*/
                                          
                                       ASSIGN vh_cdcooper  = STRING(crapcop.cdcooper)
                                              v_conta      = get-value("v_conta")
                                              v_nome       = tt-conta.nome-tit
                                              v_nomconj    = tt-conta.nome-seg-tit
                                              v_descsit    = tt-conta.situacao           
                                              v_tpconta    = tt-conta.tipo-conta         
                                              v_emp        = tt-conta.empresa            
                                              v_dev        = string(tt-conta.devolucoes)  
                                              v_agencia    = tt-conta.agencia            
                                              v_magnet     = string(tt-conta.magnetico)  
                                              v_magnet1    = STRING(i-qtd-taloes)
                                              v_est        = string(tt-conta.estouros) 
                                              v_fcheque    = string(tt-conta.folhas)   
                                              v_ident      = tt-conta.identidade         
                                              v_orgao      = tt-conta.orgao              
                                              v_cpf        = tt-conta.cpfcgc             
                                              v_disp =  
                                   string(tt-conta.disponivel,">>>,>>>,>>>,>>9.99-")                                           v_bloq =
                                   string(tt-conta.bloqueado,">>>,>>>,>>>,>>9.99-")                                          v_bloqpraca  = 
                                   string(tt-conta.bloq-praca,">>>,>>>,>>>,>>9.99-")                                         v_bloqfpraca = 
                                   string(tt-conta.bloq-fora-praca,">>>,>>>,>>>,>>9.99-")                                    v_csal       = 
                                  string(tt-conta.cheque-salario,">>>,>>>,>>>,>>9.99-")                                        v_smax =  
                                 string(tt-conta.saque-maximo,">>>,>>>,>>>,>>9.99-")                                         v_acertoc  =
                              string(tt-conta.acerto-conta,">>>,>>>,>>>,>>9.99-")         
                                              v_dbcpmf   =
                              string(tt-conta.db-cpmf,">>>,>>>,>>>,>>9.99-")             
                                              v_limcred =
                                 string(tt-conta.limite-credito ,">>>,>>>,>>>,>>9.99-")                               v_stotal  =
                                       string(tt-conta.saldo-total,">>>,>>>,>>>,>>9.99-")
                                       v_capital  =
                                            STRING(tt-conta.capital,">>>,>>>,>>>,>>9.99-").
                                             
                                             RUN verifica_anota IN h-b1crap02 
                                                                  (INPUT v_coop,         
                                                                   INPUT INT(v_pac),
                                                                   INPUT INT(v_caixa),
                                                                   INPUT INT(v_conta)).
                                             
                                             RUN calcula_aplicacoes IN h-b1crap02 
                                                                     (INPUT v_coop,
                                                                      INPUT INT(v_pac),
                                                                      INPUT INT(v_caixa),
                                                                      OUTPUT aux_vltotrda,
                                                                      OUTPUT TABLE craterr).
                                             v_aplica  =
                                                STRING(aux_vltotrda,">>>,>>>,>>>,>>9.99-").
                          
                                             RUN critica_aplicacao IN h-b1crap02
                                                                     (INPUT v_coop,
                                                                      INPUT INT(v_pac),
                                                                      INPUT INT(v_caixa),
                                                                      INPUT INT(v_conta),
                                                                      INPUT TABLE craterr).
                                                         
                                             RUN calcula_poupanca  IN h-b1crap02
                                                                  (INPUT v_coop,
                                                                   OUTPUT aux_vltotrpp). 
                                             v_poupanca =
                                                STRING(aux_vltotrpp,">>>,>>>,>>>,>>9.99-").
                                             
                                             ASSIGN vh_gedserv = IF OS-GETENV("PKGNAME") = "pkgprod" THEN
                                                                         "ged.cecred.coop.br"
                                                                     ELSE
                                                                         "0303hmlged01".
                          
                                               
                                            {include/i-erro.i}            
                                    
                                   END.
                                END.
                            END.
                          
                            DELETE PROCEDURE h-b1crap02.
                        END.
                    END.
                END.
                DELETE PROCEDURE h-b1crap00.
            END.

        END. /* Fim end opener */

    RUN displayFields.

    /* STEP 2b -
     * Enable objects that should be enabled. */
    RUN enableFields.

    /* STEP 2c -
     * OUTPUT the Progress from buffer to the WEB stream. */
    RUN outputFields.
    
  END. 
  
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

/* ......................................................................... */


