
/***********************************************************************************/
/** TO-DO: retirar &OUT de dentro das procedures e concatenar apenas na variavel
           aux_funcaojs para ser excutado apenas no fim da requisicao dentro de 
           process-web-request.
           
           verificar na procedure processa-fatura como ele trabalha com a temp
           table de erro crawerr para simplificar.
           
           terminar a parte de processo automatico (processo-automatico).
           
           comecar a parte de processo manual.
           
           criar cabecalho com glossario e avisos de como trabalhar com este fonte
           
           procedures da b1crap14 e b1crap00 na maioria das vezes que tem o parametro
           p_coop esta se referindo a nmrescop e nao a cdcooper, verificar as chamadas
           pois dentro desta procedure e feito find dentro da tabela crapcop
           buscando por nmrescop =/ . 



*/

/*..............................................................................

Programa: siscaixa/web/crap014.w
Sistema : CAIXA ON-LINE
Sigla   : CRED                               Ultima atualizacao: 07/10/2017
   
Dados referentes ao programa:

Objetivo  : Entrada de Arrecadacoes - Titulos/Faturas.

Alteracoes: 22/08/2007 - Alterado os parametros nas chamadas para as 
                         BO's dos programas dbo/b1crap14.p e
                         dbo/b2crap14.p (Elton).

            15/04/2008 - Adaptacao para agendamentos (David).

            16/12/2008 - Ajustes para unificacao dos bancos de dados (Evandro).
            
            20/07/2009 - Mostrar mensagem de confirmacao se o titulo estiver
                         vencido e for da cooperativa (David).
                         
            07/10/2009 - Trocado o caractere "\" por "~" para compilar no
                         RoundTable - Linha 1196 (Evandro).
                         
            20/10/2010 - Inclusao de parametros nas procedures gera-faturas e
                         gera-titulos-iptu (Vitor).
                         
            03/01/2010 - Tratamento para pagamento de titulos atraves de cheques
                         (Elton).
                         
            16/02/2011 - Tratamento para Projeto DDA (David).
            
            02/05/2011 - Incluso parametro pagamento por cheque na 
                         gera-titulos-iptu 
                       - Incluso parametros cobranca registrada na 
                         retorna-valores-titulo-iptu e gera-titulos-iptu  
                         (Guilherme).
                         
            12/07/2011 - Incluido novos parametros na procedure gera-titulos-iptu
                         (Elton).
                         
            15/04/2013 - Adicionado verificacao de sangria de caixa no
                         REQUEST-METHOD = GET. (Fabricio)
                         
            20/05/2013 - Adicionado tratamento para impressão de comprovante
                         para DARFs (Lucas).
                         
            19/07/2013 - Nao permite pagamento de faturas com valor informado 
                         diferente do valor da fatura (Elton). 
            
            11/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
            28/11/2013 - Adicionado DO TRANSACTION na procedure processa-fatura
                         e processa-iptu após o "IF  NOT AVAILABLE w-craperr".
                         (Reinert)
                         
            28/02/2014 - Incluso VALIDATE (Daniel).    
            
            15/09/2014 - Campo para indicar Cooperado ou Não Cooperado, 
                         chamar rotina 14g e habilitação de campos de 
                         nome e conta/dv, dentre outras alterações 
                         referentes ao Projeto Débito Automático 
                         Fácil. (Lucas Lunelli - Out/2014)
                         
            16/09/2014 - Alterado forma de execução da procedure b2crap14
                         gera-titulos-iptu para procedure Oracle package
                         CXON0014.pc_gera_titulos_iptu_prog. 
                         (Rafael). Liberação Out/2014
                       - Alterado forma de execução da procedure b2crap14
                         retorna-valores-titulo-iptu para procedure Oracle 
                         package CXON0014.pc_retorna_vlr_titulo_iptu. 
                         (Rafael). Liberação Out/2014
                         
           28/04/2015 - Verificar se autenticação existe antes de 
                        realizar impressão (Lunelli - SD. 254917)
                        
           18/03/2015 - Melhoria SD 260475 (Lunelli).
           
           29/06/2015 - Refatorado a rotina 14 devido ao acumulo de chamadas
                        e desvio de rotina que nao sao mais utilizados e ao
                        uso de ponteiros de registros de tabela e de variaveis
                        dentro de procedures fugindo totalmente do padrao e
                        a busca varias vezes da mesma informacao de utilidade
                        aparente, implementado tambem a identificacao 
                        automatica do tipo de pagamento para otimizar este
                        processo (Tiago/Fabricio).
                        
           05/05/2016 - Na procedure processa-fatura, alterado UNDO pelo 
                        Return "NOK" pois estava limpando a critica retornada 
                        tambem (Lucas Ranghetti #436077)

		   03/10/2016 - Ajustes referente a melhoria M271. (Kelvin)

		   01/12/2016 - Adicionado tratamento de erro na chamada Oracle para devolver 
		                o valor do boleto (correcao M271) (Douglas - Chamado 563281)

           29/12/2016 - Tratamento Nova Plataforma de cobrança PRJ340 - NPC (Odirlei-AMcom)     

           04/10/2017 - Ajustar chamada do autentica.html no processa-fatura e também retirar 
                        a limpeza das variaves v_codbarras e v_fmtcodbar para titulos
                        (Lucas Ranghetti #760721)

           12/12/2017 - Alterar campo flgcnvsi por tparrecd.
                        PRJ406-FGTS (Odirlei-AMcom)    
                        
           16/05/2018 - Ajustes prj420 - Resolucao - Heitor (Mouts)
                        
           18/05/2018 - Alteraçoes para usar as rotinas mesmo com o processo 
                        norturno rodando (Douglas Pagel - AMcom).


..............................................................................*/

/* comentado pq dentro da include  {dbo/bo-erro1.i} tbem tem o var_oracle
  { sistema/generico/includes/var_oracle.i } */

/*Include que contem procedure para criar eliminar e verificar
  erros na tabela de erros do caixaonline (craperr)*/
{dbo/bo-erro1.i}

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
    
/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD radio         AS CHARACTER
       FIELD vh_foco       AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa       AS CHARACTER FORMAT "X(256)":U 
       FIELD v_codbarras   AS CHARACTER FORMAT "X(256)":U 
       FIELD v_conta       AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop        AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data        AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg         AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nome        AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador    AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac         AS CHARACTER FORMAT "X(256)":U 
       FIELD v_valor       AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nmbenefi    AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg_vencido AS CHARACTER FORMAT "X(256)":U
       FIELD v_fmtcodbar   AS CHARACTER FORMAT "X(256)":U
       FIELD v_tipdocto    AS CHARACTER FORMAT "X(256)":U
       FIELD v_tpproces    AS CHARACTER FORMAT "X(256)":U
       FIELD v_flblqval    AS CHARACTER FORMAT "X(256)":U
       FIELD v_tppagmto    AS CHARACTER FORMAT "X(256)":U
       FIELD v_cod         AS CHARACTER FORMAT "X(256)":U
       FIELD v_senha       AS CHARACTER FORMAT "X(256)":U
       FIELD hdnEstorno    AS CHARACTER FORMAT "X(256)":U
       FIELD hdnVerifEstorno    AS CHARACTER FORMAT "X(256)":U
       FIELD hdnValorAcima AS CHARACTER FORMAT "X(256)":U.
       


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

DEFINE VARIABLE h_b1crap14   AS HANDLE     NO-UNDO.
DEFINE VARIABLE h_b2crap14   AS HANDLE     NO-UNDO.
DEFINE VARIABLE h-b1crap00   AS HANDLE     NO-UNDO.
DEFINE VARIABLE h-b1crap02   AS HANDLE  NO-UNDO.
DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.

/***********************************************************************
 * GLOBAIS carregadas dentro de i-global.i que eh chamado dentro de    *
 * process-web-request                                                 *
 ***********************************************************************/
DEFINE VARIABLE glb_cdcooper LIKE crapcop.cdcooper              NO-UNDO.
DEFINE VARIABLE glb_nmrescop LIKE crapcop.nmrescop              NO-UNDO.
DEFINE VARIABLE glb_dtmvtolt LIKE crapdat.dtmvtolt              NO-UNDO.
DEFINE VARIABLE glb_dtmvtocd LIKE crapdat.dtmvtocd              NO-UNDO.
DEFINE VARIABLE glb_dtmvtopr LIKE crapdat.dtmvtopr              NO-UNDO.
DEFINE VARIABLE glb_dtmvtoan LIKE crapdat.dtmvtoan              NO-UNDO.
DEFINE VARIABLE glb_cdagenci LIKE crapass.cdagenci              NO-UNDO.
DEFINE VARIABLE glb_cdbccxlt LIKE craptit.cdbccxlt              NO-UNDO.
DEFINE VARIABLE glb_cdoperad LIKE crapope.cdoperad              NO-UNDO.

DEFINE VARIABLE vr_cdcriticEstorno AS INTEGER NO-UNDO INIT 0.
DEFINE VARIABLE vr_cdcriticValorAcima AS INTEGER NO-UNDO INIT 0.


DEF VAR h_b1crap00           AS HANDLE     NO-UNDO.
                                      
DEF TEMP-TABLE w-craperr  NO-UNDO
     FIELD cdcooper   LIKE craperr.cdcooper
     FIELD cdagenci   LIKE craperr.cdagenci
     FIELD nrdcaixa   LIKE craperr.nrdcaixa
     FIELD nrsequen   LIKE craperr.nrsequen
     FIELD cdcritic   LIKE craperr.cdcritic
     FIELD dscritic   LIKE craperr.dscritic
     FIELD erro       LIKE craperr.erro.

DEF TEMP-TABLE tt-crapcbl NO-UNDO LIKE crapcbl
    FIELD dsdonome LIKE crapass.nmprimtl.
    

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE crap014.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.v_nome ab_unmap.v_conta ab_unmap.v_valor ~
ab_unmap.radio ab_unmap.v_codbarras ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_coop ~
ab_unmap.v_data ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_msg_vencido ~
ab_unmap.v_fmtcodbar ab_unmap.v_tipdocto ab_unmap.v_tpproces ab_unmap.v_flblqval ab_unmap.v_tppagmto ~
ab_unmap.v_senha  ab_unmap.v_cod ab_unmap.hdnEstorno ab_unmap.hdnVerifEstorno ab_unmap.hdnValorAcima

&Scoped-Define DISPLAYED-OBJECTS ab_unmap.v_nome ab_unmap.v_conta ab_unmap.v_valor ~
ab_unmap.radio ab_unmap.v_codbarras ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_coop ~
ab_unmap.v_data ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_msg_vencido ~
ab_unmap.v_fmtcodbar ab_unmap.v_tipdocto ab_unmap.v_tpproces ab_unmap.v_flblqval ab_unmap.v_tppagmto ~
ab_unmap.v_senha ab_unmap.v_cod ab_unmap.hdnEstorno ab_unmap.hdnVerifEstorno ab_unmap.hdnValorAcima

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.v_nome AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_conta AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_valor AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1    
     ab_unmap.radio AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
                    "radio 1", "1":U,
"radio 2", "2":U
          SIZE 20 BY 4
     ab_unmap.v_fmtcodbar AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN
          SIZE 20 BY 1
     ab_unmap.v_codbarras AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.vh_foco AT ROW 1 COL 1 HELP
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
     ab_unmap.v_msg_vencido AT ROW 1 COL 1 HELP
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
     ab_unmap.v_tipdocto AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN
          SIZE 20 BY 1
     ab_unmap.v_tpproces AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN
          SIZE 20 BY 1
     ab_unmap.v_flblqval AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN
          SIZE 20 BY 1
     ab_unmap.v_tppagmto AT ROW 1 COL 1 HELP
          "" NO-LABEL VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
           "v_tppagmto 0", "0":U,
           "v_tppagmto 1", "1":U 
           SIZE 20 BY 2
     ab_unmap.v_cod AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1          
     ab_unmap.v_senha AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.hdnEstorno AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN
          SIZE 20 BY 1 
     ab_unmap.hdnVerifEstorno AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN
          SIZE 20 BY 1 
     ab_unmap.hdnValorAcima AT ROW 1 COL 1 HELP
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
          FIELD radio AS CHARACTER 
          FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
          FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
          FIELD v_codbarras AS CHARACTER FORMAT "X(256)":U 
          FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valor AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msg_vencido AS CHARACTER FORMAT "X(256)":U
          FIELD v_tppagmto AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cod AS CHARACTER FORMAT "X(256)":U
          FIELD v_senha AS CHARACTER FORMAT "X(256)":U
          FIELD hdnEstorno AS CHARACTER FORMAT "X(256)":U
          FIELD hdnVerifEstorno AS CHARACTER FORMAT "X(256)":U
          FIELD hdnValorAcima AS CHARACTER FORMAT "X(256)":U
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
/* SETTINGS FOR RADIO-SET ab_unmap.radio IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.vh_foco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_caixa IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_codbarras IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_conta IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nome IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_valor IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_msg_vencido IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_tppagmto IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_senha IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.hdnEstorno IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.hdnVerifEstorno IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.hdnValorAcima IN FRAME Web-Frame
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
    ("radio":U,"ab_unmap.radio":U,ab_unmap.radio:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("vh_foco":U,"ab_unmap.vh_foco":U,ab_unmap.vh_foco:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("v_caixa":U,"ab_unmap.v_caixa":U,ab_unmap.v_caixa:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_codbarras":U,"ab_unmap.v_codbarras":U,ab_unmap.v_codbarras:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_conta":U,"ab_unmap.v_conta":U,ab_unmap.v_conta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg_vencido":U,"ab_unmap.v_msg_vencido":U,ab_unmap.v_msg_vencido:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nome":U,"ab_unmap.v_nome":U,ab_unmap.v_nome:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_valor":U,"ab_unmap.v_valor":U,ab_unmap.v_valor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_fmtcodbar":U,"ab_unmap.v_fmtcodbar":U,ab_unmap.v_fmtcodbar:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_tipdocto":U,"ab_unmap.v_tipdocto":U,ab_unmap.v_tipdocto:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_tpproces":U,"ab_unmap.v_tpproces":U,ab_unmap.v_tpproces:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_flblqval":U,"ab_unmap.v_flblqval":U,ab_unmap.v_flblqval:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("v_tppagmto":U,"ab_unmap.v_tppagmto":U,ab_unmap.v_tppagmto:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("v_cod":U,"ab_unmap.v_cod":U,ab_unmap.v_cod:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("v_senha":U,"ab_unmap.v_senha":U,ab_unmap.v_senha:HANDLE IN FRAME {&FRAME-NAME}). 
  RUN htmAssociate
    ("hdnEstorno":U,"ab_unmap.hdnEstorno":U,ab_unmap.hdnEstorno:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("hdnVerifEstorno":U,"ab_unmap.hdnVerifEstorno":U,ab_unmap.hdnVerifEstorno:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("hdnValorAcima":U,"ab_unmap.hdnValorAcima":U,ab_unmap.hdnValorAcima:HANDLE IN FRAME {&FRAME-NAME}).    
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
PROCEDURE process-web-request:

  /* usar no lugar de c-fnc-javascript*/
  DEF VAR aux_funcaojs             AS CHAR                           NO-UNDO. 
  DEF VAR aux_vltitulo             AS DECI                           NO-UNDO. 
  DEF VAR aux_vlrjuros             AS DECI                           NO-UNDO. 
  DEF VAR aux_vlrmulta             AS DECI                           NO-UNDO. 
  DEF VAR aux_fltitven             AS INTE                           NO-UNDO. 
  DEF VAR aux_nmbenefi             AS CHAR                           NO-UNDO. 
  DEF VAR aux_inpesbnf             AS INTE                           NO-UNDO. 
  DEF VAR aux_nrdocbnf             AS DECI                           NO-UNDO. 
  DEF VAR aux_cdctrlcs             AS CHAR                           NO-UNDO. 
  DEF VAR aux_des_erro             AS CHAR                           NO-UNDO. 
  DEF VAR aux_dscritic             AS CHAR                           NO-UNDO. 
  DEF VAR hdnEstorno               AS CHAR                           NO-UNDO.
  DEF VAR hdnVerifEstorno          AS CHAR                           NO-UNDO.
  DEF VAR hdnValorAcima            AS CHAR                           NO-UNDO.
  DEF VAR aux_cdcritic             AS INTE                           NO-UNDO.

  RUN outputHeader.

  /*******************************************************************
   *                   IMPORTANTE                                    *
   ******************************************************************* 
   *  Include Carrega dados da cooperativa e da data de movimento    *
   *  para temp-table ab_unmap (include/i-global.i)                  *
   *******************************************************************/
  {include/i-global.i}
  /*******************************************************************
   * Estes dados foram carregados para variaveis criadas com prefixo *
   * de "glb_" para simplicar o uso dentro do fonte seguindo padrao  *
   * do ayllos, o find das tabelas esta dentro da include            *
   * (include/i-global.i)                                            *
   *******************************************************************/
  ASSIGN glb_cdcooper = crapcop.cdcooper
         glb_nmrescop = crapcop.nmrescop
         glb_dtmvtolt = crapdat.dtmvtolt
         glb_dtmvtocd = crapdat.dtmvtocd
         glb_dtmvtopr = crapdat.dtmvtopr
         glb_dtmvtoan = crapdat.dtmvtoan
         glb_cdagenci = INTE(get-value("user_pac"))
         glb_cdbccxlt = INTE(get-value("user_cx"))
         glb_cdoperad = get-value("operador")
         ab_unmap.hdnVerifEstorno = get-value("hdnVerifEstorno ")
		 v_tppagmto   = get-value("v_tppagmto").

  ASSIGN vh_foco          = "8"
         v_msg_vencido    = "no"
         aux_funcaojs     = "".

  IF  GET-VALUE("v_fmtcodbar") <> "" THEN
      DO:
          ASSIGN v_codbarras = GET-VALUE("v_codbarras")
                 v_fmtcodbar = GET-VALUE("v_fmtcodbar")
                 v_valor     = GET-VALUE("v_valor").
      END.

  /* apaga tabela de erros include dbo/bo-erro1.i */
  RUN elimina-erro(INPUT glb_nmrescop,
                   INPUT glb_cdagenci,
                   INPUT glb_cdbccxlt).


  IF REQUEST_METHOD = "POST":U THEN DO:

     RUN inputFields.
     RUN findRecords.

     {include/assignfields.i}
 
     RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
     RUN valida-transacao2 IN h-b1crap00(INPUT glb_nmrescop,  /*nome resumido coop*/
                                        INPUT glb_cdagenci,  /*PA*/
                                        INPUT glb_cdbccxlt). /*Caixa*/
     DELETE PROCEDURE h-b1crap00.

     IF RETURN-VALUE = "NOK" THEN DO: 
         RUN gera-erro(INPUT glb_cdcooper,
                       INPUT glb_cdagenci,
                       INPUT glb_cdbccxlt).
     END.
     ELSE DO: 

         RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
         RUN verifica-abertura-boletim IN h-b1crap00(INPUT glb_nmrescop,
                                                     INPUT glb_cdagenci,
                                                     INPUT glb_cdbccxlt,
                                                     INPUT glb_cdoperad).
         DELETE PROCEDURE h-b1crap00.

         IF RETURN-VALUE = "NOK" THEN DO:
            RUN gera-erro(INPUT glb_cdcooper,
                          INPUT glb_cdagenci,
                          INPUT glb_cdbccxlt).
         END.
         ELSE DO:
              
             IF  get-value("cancela") = "NOK" THEN 
                 DO:
                     ASSIGN radio       = "1"
                            v_valor     = ""
                            v_codbarras = ""
                            v_msg       = ""
                            vh_foco     = "7"
                            /*v_tppagmto  = "0"*/
							.
                 END.
             ELSE 
             DO:    
                 /* Obtem informações do BL, caso haja */
                 RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
                 RUN retorna-dados-bl IN h-b1crap00(INPUT glb_nmrescop,
                                                    INPUT glb_cdagenci,
                                                    INPUT glb_cdbccxlt,
                                                    OUTPUT TABLE tt-crapcbl).
                 DELETE PROCEDURE h-b1crap00.
             
                 IF  TEMP-TABLE tt-crapcbl:HAS-RECORDS THEN
                     DO:
                         FIND FIRST tt-crapcbl NO-LOCK NO-ERROR.
                         ASSIGN v_conta = TRIM(STRING(tt-crapcbl.nrdconta, "zzzz,zzz,9"))
                                v_nome  = TRIM(tt-crapcbl.dsdonome).
                     END.
                     
                 ASSIGN aux_des_erro = "OK".

                 /*se o cod barras estiver preenchido verifica o campo 
                   de valor e volta o foco para ele caso haja algum problema
                   ou o campo nao estiver preenchido*/
                 IF get-value("v_codbarras") <> "" AND 
                    v_tipdocto <> "2" THEN
                    DO:       
                        /*v_tpproces (1-Automatico(leitora)|2-Manual(digitado p ope)*/
                        IF  INT(v_tpproces) = 1 THEN
                        DO:
                            /* Limpar as variaveis de critica */
                            ASSIGN aux_des_erro = ""
                                   aux_dscritic = "".
                           
                            RUN retorna-vlr-tit-vencto(INPUT INT(glb_cdcooper),     
                                                       INPUT IF TRIM(v_conta) = "" THEN 0 ELSE INT(v_conta),    
                                                       INPUT 1,     
                                                       INPUT INT(glb_cdagenci),     
                                                       INPUT INT(glb_cdbccxlt),     
                                                       INPUT glb_cdoperad,    /*Operador*/
                                                       INPUT 0,
                                                       INPUT 0,
                                                       INPUT 0,
                                                       INPUT 0,
                                                       INPUT 0,
                                                       INPUT v_codbarras,
                                                      OUTPUT aux_vltitulo,    
                                                      OUTPUT aux_vlrjuros,    
                                                      OUTPUT aux_vlrmulta,    
                                                      OUTPUT aux_fltitven,    
                                                      OUTPUT v_flblqval,
                                                      OUTPUT aux_nmbenefi,
                                                      OUTPUT aux_inpesbnf,
                                                      OUTPUT aux_nrdocbnf,
                                                      OUTPUT aux_cdctrlcs,
                                                      OUTPUT aux_des_erro,    
                                                      OUTPUT aux_dscritic).   
                          
                            /* Tratamento de erro */ 
                            IF  aux_des_erro <> "OK" THEN
                            DO:
                                IF aux_dscritic = "" THEN
                                DO:
                                    ASSIGN aux_dscritic = "Erro na busca do valor do titulo. " + 
                                                          "Retornou NOK porem sem mensagem de erro. " +
                                                          "(Processo automatico)".
                                END.
                                
                                /* Limpar as criticas */
                                RUN elimina-erro(INPUT glb_nmrescop,
                                                 INPUT glb_cdagenci,
                                                 INPUT glb_cdbccxlt).
                                /* Criar o erro novo */
                                RUN cria-erro(INPUT glb_nmrescop,
                                              INPUT glb_cdagenci,
                                              INPUT glb_cdbccxlt,
                                              INPUT 0,
                                              INPUT aux_dscritic,
                                              INPUT YES).
                                /* Exibir o erro */ 
                                RUN gera-erro(INPUT glb_cdcooper,
                                              INPUT glb_cdagenci,
                                              INPUT glb_cdbccxlt).                                   
                                
                                /* Setar o foco no campo Codigo de Barras */ 
                                ASSIGN vh_foco = "10".
                            END.
                            ELSE
                                DO:
                                    /* Atribuir valor e setar foco no campo de VALOR */
                                    ASSIGN v_valor = TRIM(STRING(aux_vltitulo,'zzz,zzz,zz9.99')).
                                END.
                        END.
                        ELSE 
                            DO:
                            
                               /* Limpar as variaveis de critica */
                               ASSIGN aux_des_erro = ""
                                      aux_dscritic = "".
                                      
                               RUN retorna-vlr-tit-vencto(INPUT INT(glb_cdcooper),     
                                                          INPUT IF TRIM(v_conta) = "" THEN 0 ELSE INT(v_conta),    
                                                          INPUT 1,     
                                                          INPUT INT(glb_cdagenci),     
                                                          INPUT INT(glb_cdbccxlt),     
                                                          INPUT glb_cdoperad,    /*Operador*/
                                                          INPUT DEC(SUBSTR(v_codbarras,1,10)),
                                                          INPUT DEC(SUBSTR(v_codbarras,11,11)),
                                                          INPUT DEC(SUBSTR(v_codbarras,22,11)),
                                                          INPUT DEC(SUBSTR(v_codbarras,33,1)),
                                                          INPUT DEC(SUBSTR(v_codbarras,34,14)),
                                                          INPUT "",
                                                         OUTPUT aux_vltitulo,    
                                                         OUTPUT aux_vlrjuros,    
                                                         OUTPUT aux_vlrmulta,    
                                                         OUTPUT aux_fltitven,    
                                                         OUTPUT v_flblqval,
                                                         OUTPUT aux_nmbenefi,
                                                         OUTPUT aux_inpesbnf,
                                                         OUTPUT aux_nrdocbnf,
                                                         OUTPUT aux_cdctrlcs,
                                                         OUTPUT aux_des_erro,    
                                                         OUTPUT aux_dscritic).   
                          
                               /* Tratamento de erro */ 
                               IF  aux_des_erro <> "OK" THEN
                               DO:
                                   IF aux_dscritic = "" THEN
                                   DO:
                                       ASSIGN aux_dscritic = "Erro na busca do valor do titulo. " + 
                                                             "Retornou NOK porem sem mensagem de erro."+
                                                             "(Processo manual)".
                                   END.
                                   
                                   /* Limpar as criticas */
                                   RUN elimina-erro(INPUT glb_nmrescop,
                                                    INPUT glb_cdagenci,
                                                    INPUT glb_cdbccxlt).
                                                    
                                   /* Criar o erro novo */
                                   RUN cria-erro(INPUT glb_nmrescop,
                                                 INPUT glb_cdagenci,
                                                 INPUT glb_cdbccxlt,
                                                 INPUT 0,
                                                 INPUT aux_dscritic,
                                                 INPUT YES).
                                                 
                                   /* Exibir o erro */ 
                                   RUN gera-erro(INPUT glb_cdcooper,
                                                 INPUT glb_cdagenci,
                                                 INPUT glb_cdbccxlt).                                   
                                   
                                   /* Setar o foco no campo Codigo de Barras */ 
                                   ASSIGN vh_foco = "10".
                               END.
                               ELSE
                                   DO:
                                       /* Atribuir valor e setar foco no campo de VALOR */
                                       ASSIGN v_valor = TRIM(STRING(aux_vltitulo,'zzz,zzz,zz9.99')).
                                   END.
                            END.
                    END.
                
               IF aux_des_erro = "OK" THEN
               DO:
                   /*v_tpproces (1-Automatico(leitora)|2-Manual(digitado p ope)*/
                   IF  INT(v_tpproces) = 1 THEN
                       DO:
                           /*pagamento de titulo ou fatura lido pela leitora, 
                             processo automatico*/  
                           RUN processo-automatico(INPUT glb_cdcooper,    /*Cooperativa*/
                                                   INPUT glb_nmrescop,    /*Nome resumido coop*/
                                                   INPUT glb_cdoperad,    /*Operador*/
                                                   INPUT glb_cdagenci,    /*PA*/
                                                   INPUT glb_cdbccxlt,    /*Caixa*/
                                                   INPUT glb_dtmvtocd,    /*Data Movimento*/
                                                   INPUT INT(v_tipdocto), /*1-TIT | 2-FAT*/
                                                   INPUT get-value("v_codbarras"),  /*Codigo de Barras*/
                                                   INPUT v_conta,                   /*Numero da conta*/
                                                   INPUT DEC(GET-VALUE("v_valor")), /*Valor do titulo ou fatura*/
                                                   INPUT v_msg_vencido,   /*Titulo vencido (yes | no)*/
                                                   INPUT 0, /*CPF/CNPJ CEDENTE */
                                                   INPUT 0, /*CPF/CNPJ SACADO */
                                                   INPUT aux_nmbenefi,
                                                   INPUT aux_inpesbnf,
                                                   INPUT aux_nrdocbnf,
                                                   INPUT aux_cdctrlcs,
                                                   INPUT INT(v_tppagmto), /*0-Conta | 1-Especie*/
                                                   OUTPUT aux_funcaojs,
                                                   OUTPUT vh_foco).       /*Foco do campo da tela*/


                           
                           IF  RETURN-VALUE = "NOK" THEN
                               DO:
                                  RUN gera-erro(INPUT glb_cdcooper,
                                                INPUT glb_cdagenci,
                                                INPUT glb_cdbccxlt).

            END.
                           ELSE
                               DO:
                                 aux_funcaojs = aux_funcaojs + "$('#v_valor').val('');".
        END.
                           
                           ASSIGN aux_funcaojs = aux_funcaojs + "$('#v_fmtcodbar').val('');"
                                  aux_funcaojs = aux_funcaojs + "$('#v_codbarras').val('');". 
     END.
                   ELSE     
                       DO:
                            RUN processo-manual(INPUT glb_cdcooper,
                                                INPUT glb_nmrescop,
                                                INPUT glb_cdoperad,
                                                INPUT glb_cdagenci,
                                                INPUT glb_cdbccxlt,
                                                INPUT glb_dtmvtocd,
                                                INPUT INT(v_tipdocto), /*1-TIT | 2-FAT*/
                                                INPUT get-value("v_codbarras"),  /*Codigo de Barras*/
                                                INPUT v_conta,                   /*Numero da conta*/
                                                INPUT DEC(GET-VALUE("v_valor")), /*Valor do titulo ou fatura*/
                                                INPUT v_msg_vencido,   /*Titulo vencido (yes | no)*/
                                                INPUT 0, /*CPF/CNPJ CEDENTE */
                                                INPUT 0, /*CPF/CNPJ SACADO */
                                                INPUT aux_nmbenefi,
                                                INPUT aux_inpesbnf,
                                                INPUT aux_nrdocbnf,
                                                INPUT aux_cdctrlcs,
                                                INPUT INT(v_tppagmto), /*0-Conta | 1-Especie*/
                                                OUTPUT aux_funcaojs,
                                                OUTPUT vh_foco).

                            IF  RETURN-VALUE = "NOK" THEN
                                DO:
                                   RUN gera-erro(INPUT glb_cdcooper,
                                                 INPUT glb_cdagenci,
                                                 INPUT glb_cdbccxlt).
                                END.
                       END. 
               END.
            END.
        END.
     END.

     /* aux_funcaojs = aux_funcaojs + "$('#v_fmtcodbar').val('');". */

     /*se houver retorno na var aux_funcaojs executar via OUT*/
     IF  aux_funcaojs <> "" THEN
         DO:
             {&out} '<script language="javascript">' aux_funcaojs '</script>'.
         END.

     RUN displayFields.
     RUN enableFields.
     RUN outputFields.

     IF vr_cdcriticEstorno = 1 AND INT(ab_unmap.hdnVerifEstorno) = 0 THEN
      DO:
        {&out} '<script>var conf = confirm("ATENCAO, este pagamento nao pode ser estornado, deseja continuar?");</script>'.
        {&out} '<script>((!conf) ? $("#hdnVerifEstorno").val(0) : $("#hdnVerifEstorno").val(1))</script>'.
        {&out} '<script>((!conf) ? window.location = "crap014.html?v_tppagmto=" + STRING(v_tppagmto) : document.forms[0].submit())</script>'.
      END.
     
       
     IF vr_cdcriticValorAcima = 1 THEN
       {&out} '<script>$("#hdnValorAcima").val(1);</script>'.
     ELSE
       {&out} '<script>$("#hdnValorAcima").val(0);</script>'.       
     
     {&out} '<script>habilitarCampos();</script>'.
          
  END. /* Form has been submitted. */
 
  /* REQUEST-METHOD = GET */ 
  ELSE DO:

    /* Obtem informações do BL, caso haja */
    RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
    RUN retorna-dados-bl IN h-b1crap00(INPUT v_coop,
                                       INPUT v_pac,
                                       INPUT v_caixa,
                                       OUTPUT TABLE tt-crapcbl).
    DELETE PROCEDURE h-b1crap00.

    IF  TEMP-TABLE tt-crapcbl:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-crapcbl NO-LOCK NO-ERROR.
            ASSIGN v_conta = TRIM(STRING(tt-crapcbl.nrdconta, "zzzz,zzz,9"))
                   v_nome  = TRIM(tt-crapcbl.dsdonome).
        END.
        

    IF GET-VALUE("v_sangria") <> "" THEN
    DO:
        RUN dbo/b1crap00 PERSISTENT SET h_b1crap00.

        RUN verifica-sangria-caixa IN h_b1crap00 (INPUT v_coop,
                                                  INPUT INT(v_pac),
                                                  INPUT INT(v_caixa),
                                                  INPUT v_operador).

        DELETE PROCEDURE h_b1crap00.

        IF RETURN-VALUE = "MAX" THEN
        DO:
            {include/i-erro.i}

            {&OUT} '<script> window.location = "crap002.html" </script>'.
        
        END.

        IF RETURN-VALUE = "MIN" THEN
            {include/i-erro.i}

        IF RETURN-VALUE = "NOK" THEN
        DO:
            {include/i-erro.i}

            {&OUT} '<script> window.location = "crap002.html" </script>'.
        END.
    END.
    
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE processa-titulo w-html 

PROCEDURE processa-titulo:

    DEF INPUT  PARAM par_cdcooper    AS  INTEGER                 NO-UNDO.
    DEF INPUT  PARAM par_nmrescop    AS  CHARACTER               NO-UNDO.
    DEF INPUT  PARAM par_cdagenci    AS  INTEGER                 NO-UNDO.
    DEF INPUT  PARAM par_cdbccxlt    AS  INTEGER                 NO-UNDO.
    DEF INPUT  PARAM par_cdoperad    AS  CHARACTER               NO-UNDO.
    DEF INPUT  PARAM par_nrdconta    AS  INTEGER                 NO-UNDO.
    DEF INPUT  PARAM par_ptitulo1    AS DECIMAL                  NO-UNDO. 
    DEF INPUT  PARAM par_ptitulo2    AS DECIMAL                  NO-UNDO. 
    DEF INPUT  PARAM par_ptitulo3    AS DECIMAL                  NO-UNDO. 
    DEF INPUT  PARAM par_ptitulo4    AS DECIMAL                  NO-UNDO. 
    DEF INPUT  PARAM par_ptitulo5    AS DECIMAL                  NO-UNDO. 
    DEF INPUT  PARAM par_dscodbar    AS  CHARACTER               NO-UNDO.
    DEF INPUT  PARAM par_vltitulo    AS  DECIMAL                 NO-UNDO.
    DEF INPUT  PARAM par_titvenci    AS  CHARACTER               NO-UNDO.
    DEF INPUT  PARAM par_cpfcdnte    AS  DECIMAL                 NO-UNDO.
    DEF INPUT  PARAM par_cpfsacad    AS  DECIMAL                 NO-UNDO.
    DEF INPUT  PARAM par_flmanual    AS  LOGICAL                 NO-UNDO.
    DEF INPUT  PARAM par_nmbenefi    AS  CHARACTER               NO-UNDO.
    DEF INPUT  PARAM par_inpesbnf    AS  INTEGER                 NO-UNDO.
    DEF INPUT  PARAM par_nrdocbnf    AS  DECIMAL                 NO-UNDO.    
    DEF INPUT  PARAM par_cdctrlcs    AS CHAR                     NO-UNDO. /* Numero de controle consulta NPC*/
    DEF INPUT  PARAM par_tppagmto    AS INTEGER                  NO-UNDO.

    DEF OUTPUT PARAM par_funcaojs    AS  CHARACTER               NO-UNDO.
    DEF OUTPUT PARAM par_setafoco    AS  CHARACTER               NO-UNDO.
     
    DEFINE VARIABLE aux_nrdconta_cob AS INTEGER.
    DEFINE VARIABLE aux_bloqueto     AS DECIMAL.
    DEFINE VARIABLE aux_contaconve   AS INTEGER.
    DEFINE VARIABLE aux_convenio     AS DECIMAL.
    DEFINE VARIABLE aux_insittit     AS INTEGER.
    DEFINE VARIABLE aux_intitcop     AS INTEGER.
    DEFINE VARIABLE aux_dtdifere     AS INTEGER.
    DEFINE VARIABLE aux_vldifere     AS INTEGER.
    DEFINE VARIABLE aux_cobregis     AS INTEGER.
    DEFINE VARIABLE aux_cdcritic     AS INTEGER.
    DEFINE VARIABLE aux_dscritic     AS CHAR.
    DEFINE VARIABLE aux_recidcob     AS INT64.

    DEFINE VARIABLE aux_vltitfat     AS DECIMAL                        NO-UNDO.
    DEFINE VARIABLE flg_confdata     AS LOGICAL                        NO-UNDO.
    DEFINE VARIABLE flg_confvalor    AS LOGICAL                        NO-UNDO.
    DEFINE VARIABLE flg_cobregis     AS LOGICAL                        NO-UNDO.
    DEFINE VARIABLE aux_codbarras    AS CHARACTER                      NO-UNDO.
    DEFINE VARIABLE aux_msgalert     AS CHARACTER                      NO-UNDO.
    DEFINE VARIABLE aux_vlrjuros     AS DECIMAL                        NO-UNDO.
    DEFINE VARIABLE aux_vlrmulta     AS DECIMAL                        NO-UNDO.
    DEFINE VARIABLE aux_vldescto     AS DECIMAL                        NO-UNDO.
    DEFINE VARIABLE aux_vlabatim     AS DECIMAL                        NO-UNDO.
    DEFINE VARIABLE aux_vloutdeb     AS DECIMAL                        NO-UNDO.
    DEFINE VARIABLE aux_vloutcre     AS DECIMAL                        NO-UNDO.
    DEFINE VARIABLE aux_nmprimtl     AS CHARACTER                      NO-UNDO.
    DEFINE VARIABLE aux_vlvrbole     AS DECIMAL                        NO-UNDO.
    DEFINE VARIABLE aux_inpessoa     AS INTEGER                        NO-UNDO.
    DEFINE VARIABLE flg_validcpf     AS LOGICAL                        NO-UNDO.

    DEFINE VARIABLE de_tit1          AS DECIMAL                        NO-UNDO. 
    DEFINE VARIABLE de_tit2          AS DECIMAL                        NO-UNDO. 
    DEFINE VARIABLE de_tit3          AS DECIMAL                        NO-UNDO. 
    DEFINE VARIABLE de_tit4          AS DECIMAL                        NO-UNDO. 
    DEFINE VARIABLE de_tit5          AS DECIMAL                        NO-UNDO. 

	DEF VAR aux_vllimite_especie     AS DECIMAL                  NO-UNDO.

    FIND FIRST ab_unmap.

    DEF VAR aux_fltitven             AS INTE                           NO-UNDO.                                                   
    DEF VAR aux_des_erro             AS CHAR                           NO-UNDO.
    
    
    /*inicializa variaveis*/
    ASSIGN de_tit1     = 0
           de_tit2     = 0
           de_tit3     = 0
           de_tit4     = 0
           de_tit5     = 0
           aux_inpessoa = 1
           flg_validcpf = TRUE
           par_funcaojs = ""
           aux_nmprimtl = ""
           aux_vlvrbole = 250000. /*Valor que caracteriza um VRBOLETO*/

    /*Procura nome cooperado*/
    FIND crapass WHERE crapass.cdcooper = par_cdcooper
                   AND crapass.nrdconta = par_nrdconta
                   NO-LOCK NO-ERROR.

    IF  AVAIL(crapass) THEN
        DO:
            ASSIGN aux_nmprimtl = crapass.nmprimtl.
        END.

    /* apaga tabela de erros include dbo/bo-erro1.i */
    RUN elimina-erro(INPUT par_nmrescop,
                     INPUT par_cdagenci,
                     INPUT par_cdbccxlt).

    
    IF par_vltitulo > 0 THEN
       DO:
    DO TRANSACTION ON ERROR UNDO:

            DO:
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_retorna_vlr_titulo_iptu
            aux_handproc = PROC-HANDLE NO-ERROR
            (INPUT par_cdcooper,
             INPUT par_nrdconta,
             INPUT 0,   
             INPUT par_cdoperad,
             INPUT par_cdagenci,
             INPUT par_cdbccxlt,
             INPUT par_ptitulo1,
             INPUT par_ptitulo2,
             INPUT par_ptitulo3,
             INPUT par_ptitulo4,
             INPUT par_ptitulo5,
             INPUT par_dscodbar,
             INPUT 0, /* NO */
             INPUT par_vltitulo,
             INPUT 0,
             INPUT 0,
             INPUT ?,
             INPUT par_cdctrlcs,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT "",
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT 0,
             OUTPUT "").

        CLOSE STORED-PROC pc_retorna_vlr_titulo_iptu
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN de_tit1 = pc_retorna_vlr_titulo_iptu.pr_titulo1  /*       IN OUT NUMBER             -- FORMAT "99999,99999" */
               de_tit2 = pc_retorna_vlr_titulo_iptu.pr_titulo2  /*       IN OUT NUMBER             -- FORMAT "99999,999999"  */
               de_tit3 = pc_retorna_vlr_titulo_iptu.pr_titulo3  /*       IN OUT NUMBER             -- FORMAT "99999,999999"  */
               de_tit4 = pc_retorna_vlr_titulo_iptu.pr_titulo4  /*       IN OUT NUMBER             -- FORMAT "9"            */
               de_tit5 = pc_retorna_vlr_titulo_iptu.pr_titulo5  /*       IN OUT NUMBER             -- FORMAT "zz,zzz,zzz,zzz999" */
               aux_codbarras = pc_retorna_vlr_titulo_iptu.pr_codigo_barras  /*  IN OUT VARCHAR2     --Codigo de Barras */
               aux_vltitfat = pc_retorna_vlr_titulo_iptu.pr_vlfatura  /*      OUT NUMBER          --Valor da Fatura  */
               aux_dtdifere = pc_retorna_vlr_titulo_iptu.pr_outra_data /*     OUT PLS_INTEGER        --Outra data  */ 
               aux_vldifere = pc_retorna_vlr_titulo_iptu.pr_outro_valor /*    OUT PLS_INTEGER        --Outro valor   */ 
               aux_nrdconta_cob = pc_retorna_vlr_titulo_iptu.pr_nrdconta_cob /*   OUT INTEGER        --Numero Conta Cobranca */
               aux_insittit = pc_retorna_vlr_titulo_iptu.pr_insittit    /*    OUT INTEGER        --Situacao Titulo       */
               aux_intitcop = pc_retorna_vlr_titulo_iptu.pr_intitcop    /*    OUT INTEGER        --Titulo da Cooperativa */
               aux_convenio = pc_retorna_vlr_titulo_iptu.pr_convenio   /*     OUT NUMBER         --Numero Convenio       */
               aux_bloqueto = pc_retorna_vlr_titulo_iptu.pr_bloqueto   /*     OUT NUMBER         --Numero Bloqueto       */
               aux_contaconve = pc_retorna_vlr_titulo_iptu.pr_contaconve /*     OUT INTEGER        --Numero Conta Convenio */
               aux_cobregis = pc_retorna_vlr_titulo_iptu.pr_cobregis   /*     OUT PLS_INTEGER    --Cobranca Registrada   */
               aux_msgalert = pc_retorna_vlr_titulo_iptu.pr_msgalert   /*     OUT VARCHAR2       --Mensagem de alerta    */
               aux_vlrjuros = pc_retorna_vlr_titulo_iptu.pr_vlrjuros   /*     OUT NUMBER         --Valor dos Juros       */
               aux_vlrmulta = pc_retorna_vlr_titulo_iptu.pr_vlrmulta   /*     OUT NUMBER         --Valor da Multa        */
               aux_vldescto = pc_retorna_vlr_titulo_iptu.pr_vldescto   /*     OUT NUMBER         --Valor do Desconto     */
               aux_vlabatim = pc_retorna_vlr_titulo_iptu.pr_vlabatim   /*     OUT NUMBER         --Valor do Abatimento   */
               aux_vloutdeb = pc_retorna_vlr_titulo_iptu.pr_vloutdeb   /*     OUT NUMBER         --Valor Saida Debitado  */
               aux_vloutcre = pc_retorna_vlr_titulo_iptu.pr_vloutcre   /*     OUT NUMBER         --Valor Saida Creditado */

               aux_cdcritic = 0
               aux_dscritic = ""
               aux_cdcritic = pc_retorna_vlr_titulo_iptu.pr_cdcritic 
                              WHEN pc_retorna_vlr_titulo_iptu.pr_cdcritic <> ?
               aux_dscritic = pc_retorna_vlr_titulo_iptu.pr_dscritic 
                              WHEN pc_retorna_vlr_titulo_iptu.pr_dscritic <> ?.

        ASSIGN flg_confdata  = (aux_dtdifere = 1)
               flg_confvalor = (aux_vldifere = 1)
               flg_cobregis  = (aux_cobregis = 1).
    
            
            END.
              
    END. /* fim transaction */

    /** Verifica se foi criada critica para titulo vencido **/
    FIND FIRST craperr WHERE craperr.cdcooper = par_cdcooper AND
                             craperr.cdagenci = par_cdagenci AND
                             craperr.nrdcaixa = par_cdbccxlt 
                             NO-LOCK NO-ERROR.

    IF  AVAIL(craperr) AND 
        craperr.cdcritic <> 13 THEN 
        DO: 

            IF  UPPER(craperr.dscritic) MATCHES "*VALOR*" THEN
                ASSIGN par_setafoco = "11". 
            ELSE
                ASSIGN par_setafoco = "10". 


            RETURN "NOK".
        END.


    /* Verifica critica de pc_retorna_vlr_titulo_iptu */
        
    IF  (aux_cdcritic > 0 OR aux_dscritic <> "") AND 
         aux_cdcritic <> 13 THEN 
        DO: 
           ASSIGN par_setafoco = "10".
           RETURN "NOK".
        END. 
     
	
	 IF par_tppagmto = 1 THEN
	   DO:
		 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
		 RUN STORED-PROCEDURE pc_lim_pagto_especie_pld
			 aux_handproc = PROC-HANDLE NO-ERROR
			 (INPUT par_cdcooper,
			  OUTPUT 0,
			  OUTPUT 0,
			  OUTPUT "").

		 CLOSE STORED-PROC pc_lim_pagto_especie_pld
			   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

		 { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
		
		 ASSIGN aux_cdcritic = 0
				aux_dscritic = ""
				aux_vllimite_especie = 0
				aux_cdcritic = pc_lim_pagto_especie_pld.pr_cdcritic 
							   WHEN pc_lim_pagto_especie_pld.pr_cdcritic <> ?
				aux_dscritic = pc_lim_pagto_especie_pld.pr_dscritic 
							   WHEN pc_lim_pagto_especie_pld.pr_dscritic <> ?
				aux_vllimite_especie = pc_lim_pagto_especie_pld.pr_vllimite_pagto_especie 
							   WHEN pc_lim_pagto_especie_pld.pr_vllimite_pagto_especie <> ?.
		
		 IF aux_vllimite_especie <= par_vltitulo THEN
		 DO:
		   /* Limpar as criticas */
		   RUN elimina-erro(INPUT glb_nmrescop,
							INPUT glb_cdagenci,
							INPUT glb_cdbccxlt).
		  
		   /* Criar o erro novo */
		   RUN cria-erro(INPUT glb_nmrescop,
						 INPUT glb_cdagenci,
						 INPUT glb_cdbccxlt,
						 INPUT 0,
						 INPUT "Valor de pagamento excede o permitido para a operação em espécie. Serão aceitos somente pagamentos inferiores a R$ " + TRIM(STRING(aux_vllimite_especie,'zzz,zzz,zz9.99'))
						 + " (Resolução CMN 4.648/18).",
						 INPUT YES).

           RUN cria-erro(INPUT glb_nmrescop,
						 INPUT glb_cdagenci,
						 INPUT glb_cdbccxlt,
						 INPUT 0,
						 INPUT "Necessário depositar o recurso em conta e após isso proceder com o pagamento nos canais digitais ou no caixa online - Rotina 14 opção ~"Conta~".",
						 INPUT YES).
						 
		   /* Exibir o erro */ 
		   RUN gera-erro(INPUT glb_cdcooper,
						 INPUT glb_cdagenci,
						 INPUT glb_cdbccxlt).
			
		   /* Setar o foco no campo Codigo de Barras */ 
		   ASSIGN par_setafoco = "10".
		   RETURN "NOK".
		 END.
	   END.
	   
	
    /* ***Passou pelas validacoes*** */
    IF  par_titvenci = "no" AND 
        aux_intitcop = 1     THEN /** Titulo da cooperativa **/
        DO:
            /** Verifica se foi criada critica para titulo vencido **/
            FIND FIRST craperr WHERE craperr.cdcooper = par_cdcooper AND
                                     craperr.cdagenci = par_cdagenci AND
                                     craperr.nrdcaixa = par_cdbccxlt AND
                                     craperr.cdcritic = 13
                                     NO-LOCK NO-ERROR.
                               
            IF  AVAIL(craperr) THEN 
                DO: 
                            
              {&out}   '<script>if (confirm("Titulo vencido. Deseja ' +
                                   'Continuar?")) ~{' +
                                   'document.forms[0].v_msg_vencido.value = ' +
                                   '"yes";' +
                                   'preenchimento(event,0,document.forms[0].' +
                                   'v_codbarras,44,"submit");' +   
                                   '~} else ~{' +
                                   ' window.location = "crap014.html";' +
                                   '~}</script>'. 

                END.
        END.
    
    IF  par_funcaojs = "" THEN
        DO:
            IF  flg_confvalor AND aux_intitcop = 0 AND par_cdctrlcs = "" THEN  
                DO:
                    ASSIGN par_funcaojs = 'alert("O  Valor Digitado difere do Valor Codificado");'.
                END.
    
            ASSIGN par_funcaojs = par_funcaojs + 'window.location = "crap014b.html?v_pvalor=' 
                   par_funcaojs = par_funcaojs + STRING(par_vltitulo,"zzz,zzz,zz9.99")
                   par_funcaojs = par_funcaojs + "&v_pbarras="  + par_dscodbar
                   par_funcaojs = par_funcaojs + "&v_pnome="    + aux_nmprimtl
                   par_funcaojs = par_funcaojs + "&v_pconta="   + STRING(par_nrdconta,"zzzz,zzz,9")
                   par_funcaojs = par_funcaojs + "&v_intitcop=" + STRING(aux_intitcop)
                   par_funcaojs = par_funcaojs + "&ptitulo1=" + STRING(par_ptitulo1)
                   par_funcaojs = par_funcaojs + "&ptitulo2=" + STRING(par_ptitulo2)
                   par_funcaojs = par_funcaojs + "&ptitulo3=" + STRING(par_ptitulo3)
                   par_funcaojs = par_funcaojs + "&ptitulo4=" + STRING(par_ptitulo4)
                   par_funcaojs = par_funcaojs + "&ptitulo5=" + STRING(par_ptitulo5)
                   par_funcaojs = par_funcaojs + "&v_nmbenefi=" + STRING(par_nmbenefi)
                   par_funcaojs = par_funcaojs + "&v_inpesbnf=" + STRING(par_inpesbnf)
                   par_funcaojs = par_funcaojs + "&v_nrdocbnf=" + STRING(par_nrdocbnf)
                   par_funcaojs = par_funcaojs + "&v_cdctrlcs=" + STRING(par_cdctrlcs)
                   par_funcaojs = par_funcaojs + "&v_tppagmto=" + STRING(par_tppagmto). 
                   

            IF  par_flmanual = TRUE THEN
                DO:
                    ASSIGN par_funcaojs = par_funcaojs + "&manual=MANUAL".
                END.
                
            ASSIGN par_funcaojs = par_funcaojs + '";'.

        END.
    
    RETURN "OK".
       END.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE processa-fatura w-html 
PROCEDURE processa-fatura:

    DEF INPUT PARAM par_cdcooper    AS  INTEGER                 NO-UNDO.
    DEF INPUT PARAM par_nmrescop    AS  CHARACTER               NO-UNDO.
    DEF INPUT PARAM par_cdoperad    AS  CHARACTER               NO-UNDO.
    DEF INPUT PARAM par_cdagenci    AS  INTEGER                 NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt    AS  INTEGER                 NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    AS  DATE                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta    AS  INTEGER                 NO-UNDO.
    DEF INPUT PARAM par_vlfatura    AS  DECIMAL                 NO-UNDO.
    DEF INPUT PARAM par_dscodbar    AS  CHARACTER               NO-UNDO.
    DEF INPUT PARAM par_tpproces    AS  INTEGER                 NO-UNDO.
    DEF INPUT PARAM par_tppagmto    AS INTEGER                  NO-UNDO.

    DEF OUTPUT PARAM par_funcaojs   AS  CHARACTER               NO-UNDO.
    DEF OUTPUT PARAM par_setafoco   AS  CHARACTER               NO-UNDO.

    DEF VAR aux_vltitfat            AS  DECIMAL                 NO-UNDO.
    DEF VAR aux_vllimite            AS  INTEGER                 NO-UNDO.
    DEF VAR p_sequencia             AS  DECIMAL                 NO-UNDO.
    DEF VAR p_digito                AS  DECIMAL                 NO-UNDO.
    DEF VAR p_iptu                  AS  LOGICAL                 NO-UNDO.
    DEF VAR p-histor                AS  INTEGER                 NO-UNDO.
    DEF VAR p-pg                    AS  LOGICAL                 NO-UNDO.
    DEF VAR p-docto                 AS  INTEGER                 NO-UNDO.
    DEF VAR p-literal               AS  CHARACTER               NO-UNDO.
    DEF VAR p-ult-sequencia         AS  INTEGER                 NO-UNDO.
    DEF VAR l-houve-erro            AS  LOGICAL                 NO-UNDO.
    DEF VAR c_codbarras             AS  CHARACTER               NO-UNDO.
    DEF VAR par_cdcoptfn            AS  INTEGER                 NO-UNDO.
    DEF VAR par_cdagetfn            AS  INTEGER                 NO-UNDO.
    DEF VAR par_nrterfin            AS  INTEGER                 NO-UNDO.
    DEF VAR aux_fatura1             AS  DECIMAL                 NO-UNDO.
    DEF VAR aux_fatura2             AS  DECIMAL                 NO-UNDO.
    DEF VAR aux_fatura3             AS  DECIMAL                 NO-UNDO.
    DEF VAR aux_fatura4             AS  DECIMAL                 NO-UNDO.
    DEF VAR aux_debitaut            AS  LOG                     NO-UNDO.
    DEF VAR aux_des_erro            AS CHARACTER                NO-UNDO.
    DEF VAR aux_dscritic            AS CHARACTER                NO-UNDO.
	DEF VAR aux_cdcritic            AS INTEGER                  NO-UNDO.
	DEF VAR aux_vllimite_especie    AS DECIMAL                  NO-UNDO.

    FIND FIRST ab_unmap.

    ASSIGN c_codbarras = par_dscodbar
           aux_fatura1 = 0
           aux_fatura2 = 0
           aux_fatura3 = 0
           aux_fatura4 = 0
           aux_debitaut = FALSE.

    IF  par_tpproces = 2 THEN /*Digitado manualmente*/
        DO:
            /*Manda o codigo de barras sem os digitos e
              separado em cada variavel tambem*/
            ASSIGN c_codbarras = SUBSTR(par_dscodbar,1,11)  + 
                                 SUBSTR(par_dscodbar,13,11) +
                                 SUBSTR(par_dscodbar,25,11) +
                                 SUBSTR(par_dscodbar,37,11)
                   aux_fatura1 = DEC(SUBSTR(par_dscodbar,1,12))
                   aux_fatura2 = DEC(SUBSTR(par_dscodbar,13,12))
                   aux_fatura3 = DEC(SUBSTR(par_dscodbar,25,12))
                   aux_fatura4 = DEC(SUBSTR(par_dscodbar,37,12)).
        END.

    RUN elimina-erro(INPUT par_nmrescop,
                     INPUT par_cdagenci,
                     INPUT par_cdbccxlt).

    RUN dbo/b1crap14.p PERSISTENT SET h_b1crap14.
    RUN retorna-valores-fatura IN h_b1crap14(INPUT par_nmrescop,
                                             INPUT par_nrdconta,
                                             INPUT 0,   
                                             INPUT par_cdoperad,
                                             INPUT par_cdagenci,
                                             INPUT par_cdbccxlt,
                                             INPUT aux_fatura1,
                                             INPUT aux_fatura2,
                                             INPUT aux_fatura3,
                                             INPUT aux_fatura4,
                                             INPUT-OUTPUT c_codbarras,
                                             OUTPUT p_sequencia,
                                             OUTPUT aux_vltitfat,
                                             OUTPUT p_digito,
                                             OUTPUT p_iptu).
    DELETE PROCEDURE h_b1crap14.

    VALIDATE craperr.

    /*--- Assumir Valor Informado(Fatura)- Qdo valor codigo barras = 0 ---*/
    IF  aux_vltitfat = 0   THEN
        ASSIGN aux_vltitfat = par_vlfatura.
    /*----------------------------------------------------*/
    IF  RETURN-VALUE = "NOK" THEN DO:

        FIND FIRST craperr 
             WHERE craperr.cdcooper = par_cdcooper
               AND craperr.cdagenci = par_cdagenci
               AND craperr.nrdcaixa = par_cdbccxlt
               NO-LOCK NO-ERROR.
        
        IF  AVAIL(craperr) THEN 
            DO: 
                RETURN "NOK".
            END.

        RETURN "NOK".
    END.
    ELSE DO:
	 /* Heitor */
	 IF par_tppagmto = 1 THEN
	   DO:
		 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
		 RUN STORED-PROCEDURE pc_lim_pagto_especie_pld
	 		 aux_handproc = PROC-HANDLE NO-ERROR
			 (INPUT par_cdcooper,
			  OUTPUT 0,
			  OUTPUT 0,
			  OUTPUT "").

		 CLOSE STORED-PROC pc_lim_pagto_especie_pld
	 		   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

		 { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

		 ASSIGN aux_cdcritic = 0
		 	    aux_dscritic = ""
			    aux_vllimite_especie = 0
			    aux_cdcritic = pc_lim_pagto_especie_pld.pr_cdcritic 
							   WHEN pc_lim_pagto_especie_pld.pr_cdcritic <> ?
			    aux_dscritic = pc_lim_pagto_especie_pld.pr_dscritic 
							   WHEN pc_lim_pagto_especie_pld.pr_dscritic <> ?
			    aux_vllimite_especie = pc_lim_pagto_especie_pld.pr_vllimite_pagto_especie 
							   WHEN pc_lim_pagto_especie_pld.pr_vllimite_pagto_especie <> ?.
		
		 IF aux_vllimite_especie <= aux_vltitfat THEN
		 DO:
		   /* Limpar as criticas */
		   RUN elimina-erro(INPUT glb_nmrescop,
						    INPUT glb_cdagenci,
						    INPUT glb_cdbccxlt).
		  
		   /* Criar o erro novo */
		   RUN cria-erro(INPUT glb_nmrescop,
						 INPUT glb_cdagenci,
						 INPUT glb_cdbccxlt,
						 INPUT 0,
						 INPUT "Valor de pagamento excede o permitido para a operação em espécie. Serão aceitos somente pagamentos inferiores a R$ " + TRIM(STRING(aux_vllimite_especie,'zzz,zzz,zz9.99'))
						 + " (Resolução CMN 4.648/18).",
						 INPUT YES).

           RUN cria-erro(INPUT glb_nmrescop,
						 INPUT glb_cdagenci,
						 INPUT glb_cdbccxlt,
						 INPUT 0,
						 INPUT "Necessário depositar o recurso em conta e após isso proceder com o pagamento nos canais digitais ou no caixa online - Rotina 14 opção ~"Conta~".",
						 INPUT YES).

		   /* Exibir o erro */ 
		   RUN gera-erro(INPUT glb_cdcooper,
						 INPUT glb_cdagenci,
						 INPUT glb_cdbccxlt).                                   
			
		   /* Setar o foco no campo Codigo de Barras */ 
		   ASSIGN vh_foco = "10".
		   RETURN "NOK".
		 END.
	   END.
	   
		
	    /* Valida o valor do limite do PA / Cooperativa */    
        RUN validar-valor-limite(INPUT par_cdcooper,
                                 INPUT v_cod,
                                 INPUT par_cdagenci,
                                 INPUT par_cdbccxlt,
                                 INPUT aux_vltitfat,
                                 INPUT v_senha,
                                 INPUT DEC(SUBSTR(c_codbarras,16,4)),
                                 OUTPUT aux_des_erro,
                                 OUTPUT aux_dscritic).
                                 
        IF RETURN-VALUE = 'NOK' THEN  
         DO:
            ASSIGN vh_foco = "10".
            RUN gera-erro(INPUT glb_cdcooper,
                            INPUT glb_cdagenci,
                            INPUT glb_cdbccxlt).
            RETURN "NOK".
         END.

        DO  TRANSACTION ON ERROR UNDO:           

            IF  par_vlfatura <> 0            AND 
                aux_vltitfat <> par_vlfatura THEN
                DO: 
                    /*Mostra alerta e chama tela novamente*/
                    ASSIGN par_funcaojs = 'alert("Valor digitado difere do valor codificado!!"); window.location = "crap014.html";'.
                    RETURN "NOK".
                END.       
            ELSE        
                DO:
                    RUN dbo/b1crap14.p PERSISTENT SET h_b1crap14.
                    RUN gera-faturas IN h_b1crap14(INPUT par_nmrescop,
                                                   INPUT par_nrdconta,
                                                   INPUT 0,   
                                                   INPUT par_cdoperad,
                                                   INPUT par_cdagenci,
                                                   INPUT par_cdbccxlt,
                                                   INPUT c_codbarras,
                                                   INPUT p_sequencia,
                                                   INPUT aux_vltitfat,
                                                   INPUT p_digito,
                                                   INPUT par_vlfatura,
                                                   INPUT par_cdcoptfn,
                                                   INPUT par_cdagetfn,
                                                   INPUT par_nrterfin,
                                                   INPUT par_tpproces,
                                                   INPUT  par_tppagmto,  /*indicador do tipo pagamento 0-Conta | 1-Especie*/
                                                   OUTPUT p-histor,
                                                   OUTPUT p-pg,    
                                                   OUTPUT p-docto,
                                                   OUTPUT p-literal,
                                                   OUTPUT p-ult-sequencia).
                    DELETE PROCEDURE h_b1crap14.

                    EMPTY TEMP-TABLE w-craperr. 

                    IF  RETURN-VALUE = "NOK" THEN
                        DO:
                            FIND FIRST craperr 
                                 WHERE craperr.cdcooper = par_cdcooper
                                   AND craperr.cdagenci = par_cdagenci
                                   AND craperr.nrdcaixa = par_cdbccxlt
                                   NO-LOCK NO-ERROR.

                            IF  AVAIL(craperr) THEN 
                                DO:
                                    RUN gera-erro(INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_cdbccxlt).
                                END.
                            ELSE
                                DO:
                               RUN elimina-erro(INPUT par_nmrescop,
                                                    INPUT par_cdagenci,
                                                    INPUT par_cdbccxlt).

                               RUN cria-erro(INPUT par_nmrescop,
                                                 INPUT par_cdagenci,
                                                 INPUT par_cdbccxlt,
                                                 INPUT 0,
                                                 INPUT "ERRO!!! PA ZERADO. FECHE O CAIXA E AVISE O CPD",
                                                 INPUT YES).

                                   RUN gera-erro(INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_cdbccxlt).
                                END.

                        RETURN "NOK".
                        END.
                END.

        /* Verifica se autenticação existe antes de realizar impressão */
        FIND FIRST crapaut  WHERE
                   crapaut.cdcooper = par_cdcooper AND
                   crapaut.dtmvtolt = par_dtmvtolt AND 
                   crapaut.cdagenci = par_cdagenci AND 
                   crapaut.nrdcaixa = par_cdbccxlt AND 
                   crapaut.nrsequen = INTE(p-ult-sequencia)
                       NO-LOCK NO-ERROR.
           
        IF  NOT AVAIL crapaut THEN
            DO:
                    RUN elimina-erro(INPUT par_nmrescop,
                                 INPUT par_cdagenci,
                                 INPUT par_cdbccxlt).
    
                    RUN cria-erro(INPUT par_nmrescop,
                          INPUT par_cdagenci,
                          INPUT par_cdbccxlt,
                          INPUT 0,
                          INPUT "Pagamento não efetuado. Repita a operação.",
                          INPUT YES).

                ASSIGN par_funcaojs = 'window.location = "crap014.html"'. 
                RETURN "NOK".                                                                
            END.
        /* FIM Verificação da autenticação */

        FIND FIRST crapcon WHERE crapcon.cdcooper = par_cdcooper
                             AND crapcon.cdempcon = INT(SUBSTRING(c_codbarras,16,4))
                             AND crapcon.cdsegmto = INT(SUBSTRING(c_codbarras,2,1))                                                        
                             NO-LOCK NO-ERROR.
                             
        IF  AVAILABLE crapcon THEN           
            DO:                
                IF  crapcon.tparrecd = 1 THEN
                    DO:                    
                        /* Verificar se convênio possui debito automatico */
                        FIND FIRST crapscn WHERE (crapscn.cdempcon = crapcon.cdempcon          AND
                                                  crapscn.cdempcon <> 0)                       AND
                                                  crapscn.cdsegmto = STRING(crapcon.cdsegmto)  AND
                                                  crapscn.dsoparre = 'E'                       AND
                                                 (crapscn.cddmoden = 'A'                       OR
                                                  crapscn.cddmoden = 'C') NO-LOCK NO-ERROR.
                        IF  AVAILABLE crapscn THEN
                            ASSIGN aux_debitaut = TRUE. /* Convenio sicredi */
                    END.
                ELSE
                    DO:
                       IF  crapcon.cdhistor <> 1154 THEN
                           ASSIGN aux_debitaut = TRUE. /* Convenio proprio */
                    END.
            END.            

        IF  par_nrdconta > 0  AND aux_debitaut THEN   /* Cooperado */
            DO:
                 /* Chama fonte que oferece débito automático da fatura paga para o cooperado */
                 ASSIGN par_funcaojs = 'window.location = "crap014g.html?v_conta='
                        par_funcaojs = par_funcaojs + STRING(par_nrdconta) + "&v_nome=" + v_nome
						par_funcaojs = par_funcaojs + "&v_tppagmto=" + STRING(v_tppagmto)
                        par_funcaojs = par_funcaojs + "&v_codbarras=" + c_codbarras + '";'.
            END.
        
        /* ****Se estiver tudo OK**** */
        IF  LENGTH(p-literal) > 120 THEN
            DO:
                 IF  par_nrdconta > 0  AND aux_debitaut  THEN
                     ASSIGN par_funcaojs = par_funcaojs + 'window.open("autentica.html?v_plit='.
                 ELSE 
                     ASSIGN par_funcaojs = 'window.location = "crap014.html?v_tppagmto=' + STRING(v_tppagmto) + '";'
                            par_funcaojs = par_funcaojs + 'window.open("autentica.html?v_plit='.
                     
                 ASSIGN par_funcaojs = par_funcaojs + p-literal
                       par_funcaojs = par_funcaojs + "&v_pseq=" + STRING(p-ult-sequencia)
                       par_funcaojs = par_funcaojs + "&v_prec=YES"
                       par_funcaojs = par_funcaojs + "&v_psetcook=yes"
                       par_funcaojs = par_funcaojs + '","waut","width=250,height=145,scrollbars=auto,alwaysRaised=true");'.
            END.
        ELSE
            DO:
                IF  par_nrdconta > 0  AND aux_debitaut  THEN
                     ASSIGN par_funcaojs = par_funcaojs + 'window.open("autentica.html?v_plit='.
                 ELSE 
                     ASSIGN par_funcaojs = 'window.location = "crap014.html?v_tppagmto=' + STRING(v_tppagmto) + '";'
                            par_funcaojs = par_funcaojs + 'window.open("autentica.html?v_plit='.
                     
                 ASSIGN par_funcaojs = par_funcaojs + p-literal
                       par_funcaojs = par_funcaojs + "&v_pseq=" + STRING(p-ult-sequencia)
                       par_funcaojs = par_funcaojs + "&v_prec=NO"
                       par_funcaojs = par_funcaojs + "&v_psetcook=yes"
                       par_funcaojs = par_funcaojs + '","waut","width=250,height=145,scrollbars=auto,alwaysRaised=true");'.
            END.
    
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
        
        RUN STORED-PROCEDURE pc_consultar_parmon_pld_car
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapcop.cdcooper,
                                                     OUTPUT 0,
                                                     OUTPUT 0,
                                                     OUTPUT 0,
                                                     OUTPUT 0,
                                                     OUTPUT 0,
                                                     OUTPUT "").

        CLOSE STORED-PROC pc_consultar_parmon_pld_car
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                          
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN aux_vllimite = pc_consultar_parmon_pld_car.pr_vlmonitoracao_pagamento. 
        
        IF par_tppagmto = 1 THEN
            DO:
               /**** Busca parametro através da rotina ORACLE. ***/
               IF aux_vltitfat > aux_vllimite THEN
                  ASSIGN par_funcaojs = par_funcaojs + 'window.location = "crap051e.html?v_pvalor='
                                        par_funcaojs = par_funcaojs + STRING(aux_vltitfat,"zzz,zzz,zz9.99")
                                        par_funcaojs = par_funcaojs + "&v_pult_sequencia=" + STRING(p-ult-sequencia)
                                        par_funcaojs = par_funcaojs + "&v_pprograma=CRAP014"
                                        par_funcaojs = par_funcaojs + "&v_ptpdocmto=1"
                                        par_funcaojs = par_funcaojs + '";'.
            END.
        
        END.        
   END.
   
   RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE processo-automatico w-html 

/* procedure automatico processo de titulo - fatura (leitora) */
PROCEDURE processo-automatico:

    DEF INPUT PARAM par_cdcooper AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_nmrescop AS CHARACTER                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHARACTER                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_tipdocto AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_dscodbar AS CHARACTER                       NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_vltitfat AS DECIMAL                         NO-UNDO.
    DEF INPUT PARAM par_titvenci AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_cpfcdnte AS DECIMAL                         NO-UNDO.
    DEF INPUT PARAM par_cpfsacad AS DECIMAL                         NO-UNDO.
    DEF INPUT PARAM par_nmbenefi AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_inpesbnf AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_nrdocbnf AS DECIMAL                         NO-UNDO.    
    DEF INPUT PARAM par_cdctrlcs AS CHAR                            NO-UNDO. /* Numero de controle consulta NPC*/
    DEF INPUT PARAM par_tppagmto AS INTEGER                         NO-UNDO.

    DEF OUTPUT PARAM par_funcaojs AS CHARACTER                      NO-UNDO.
    DEF OUTPUT PARAM par_setafoco AS CHARACTER                      NO-UNDO.
    

    RUN dbo/b1crap14.p PERSISTENT SET h_b1crap14.
    RUN valida-codigo-barras IN h_b1crap14(INPUT par_nmrescop,
                                           INPUT 0, 
                                           INPUT 0, 
                                           INPUT par_cdoperad,
                                           INPUT par_cdagenci,
                                           INPUT par_cdbccxlt,
                                           INPUT par_dscodbar).
    DELETE PROCEDURE h_b1crap14.
    
    IF RETURN-VALUE = "NOK" THEN
       DO:                    
           ASSIGN par_setafoco    = "11".
           RETURN "NOK".
       END.
    ELSE
       DO: 
           /* par_tipdocto = 1 - Titulo | 2 - Fatura */
           IF  par_tipdocto = 1 THEN  /*TITULO*/
               DO:
                   RUN processa-titulo(INPUT  par_cdcooper,  /*Cooperativa*/
                                       INPUT  par_nmrescop,  /*Nome resumido coop*/
                                       INPUT  par_cdagenci,  /*PA*/
                                       INPUT  par_cdbccxlt,  /*Caixa*/
                                       INPUT  par_cdoperad,  /*Operador*/
                                       INPUT  par_nrdconta,  /*Conta*/
                                       INPUT  0,             /*Parte do titulo 1, processo manual*/
                                       INPUT  0,             /*Parte do titulo 2, processo manual*/
                                       INPUT  0,             /*Parte do titulo 3, processo manual*/
                                       INPUT  0,             /*Parte do titulo 4, processo manual*/
                                       INPUT  0,             /*Parte do titulo 5, processo manual*/
                                       INPUT  par_dscodbar,  /*Codigo de barras*/
                                       INPUT  par_vltitfat,  /*Valor titulo*/
                                       INPUT  par_titvenci,  /*Titulo vencido msg*/
                                       INPUT  par_cpfcdnte,  /*CPF/CNPJ cedente*/
                                       INPUT  par_cpfsacad,  /*CPF/CNPJ sacado*/
                                       INPUT  FALSE,          /*Manual?*/
                                       INPUT  par_nmbenefi,  /* Nome do beneficiario retornado da NPC*/
                                       INPUT  par_inpesbnf,  /* Tipo de pessoa beneficiario*/
                                       INPUT  par_nrdocbnf,  /* CPF/CNPJ Beneficiario */
                                       INPUT  par_cdctrlcs,  /*Numero de controle consulta NPC*/  
                                       INPUT  par_tppagmto,  /*indicador do tipo pagamento 0-Conta | 1-Especie*/
                                       OUTPUT par_funcaojs,  /*Funcao javascript de retorno*/
                                       OUTPUT par_setafoco). 

                   IF  RETURN-VALUE <> "OK" THEN
                       DO:
                           RETURN "NOK".
                       END.
               END.
           ELSE  
               DO:
                   IF  par_tipdocto = 2 THEN  /*FATURA*/
                       DO:
                           RUN processa-fatura(INPUT par_cdcooper,   /*Cooperativa*/                  
                                               INPUT par_nmrescop,   /*Nome resumido coop*/           
                                               INPUT par_cdoperad,   /*Operador*/                     
                                               INPUT par_cdagenci,   /*PA*/                        
                                               INPUT par_cdbccxlt,   /*Caixa*/                     
                                               INPUT par_dtmvtolt,   /*Data movimento*/                        
                                               INPUT par_nrdconta,   /*Conta*/             
                                               INPUT par_vltitfat,   /*Valor fatura*/                 
                                               INPUT par_dscodbar,   /*Cod barras*/
                                               INPUT 1,   /*Tipo processo - automatico*/
                                               INPUT  par_tppagmto,  /*indicador do tipo pagamento 0-Conta | 1-Especie*/
                                               OUTPUT par_funcaojs,
                                               OUTPUT par_setafoco). /*Campo que indica onde deve setar foco da tela*/

                           IF  RETURN-VALUE <> "OK" THEN
                               DO:
                                   RETURN "NOK".
                               END.

                       END.
               END.
       END.

    RETURN "OK".
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE processo-manual w-html 

/* procedure manual processo de titulo - fatura (leitora) */
PROCEDURE processo-manual:

    DEF INPUT PARAM par_cdcooper AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_nmrescop AS CHARACTER                       NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHARACTER                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_tipdocto AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_dscodbar AS CHARACTER                       NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_vltitfat AS DECIMAL                         NO-UNDO.
    DEF INPUT PARAM par_titvenci AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_cpfcdnte AS DECIMAL                         NO-UNDO.
    DEF INPUT PARAM par_cpfsacad AS DECIMAL                         NO-UNDO.
    DEF INPUT PARAM par_nmbenefi AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_inpesbnf AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_nrdocbnf AS DECIMAL                         NO-UNDO.    
    DEF INPUT PARAM par_cdctrlcs AS CHAR                            NO-UNDO. /* Numero de controle consulta NPC*/
    DEF INPUT PARAM par_tppagmto AS INTEGER                         NO-UNDO.
    
    DEF OUTPUT PARAM par_funcaojs AS CHARACTER                      NO-UNDO.
    DEF OUTPUT PARAM par_setafoco AS CHARACTER                      NO-UNDO.
    
    DEF VAR aux_ptitulo1         AS DECIMAL                         NO-UNDO.
    DEF VAR aux_ptitulo2         AS DECIMAL                         NO-UNDO.
    DEF VAR aux_ptitulo3         AS DECIMAL                         NO-UNDO.
    DEF VAR aux_ptitulo4         AS DECIMAL                         NO-UNDO.
    DEF VAR aux_ptitulo5         AS DECIMAL                         NO-UNDO.

 /*
    RUN dbo/b1crap14.p PERSISTENT SET h_b1crap14.
    RUN valida-codigo-barras IN h_b1crap14(INPUT par_nmrescop,
                                           INPUT 0, 
                                           INPUT 0, 
                                           INPUT par_cdoperad,
                                           INPUT par_cdagenci,
                                           INPUT par_cdbccxlt,
                                           INPUT par_dscodbar).
    DELETE PROCEDURE h_b1crap14.
    
    IF RETURN-VALUE = "NOK" THEN
       DO:                    
           ASSIGN par_setafoco    = "10".
           RETURN "NOK".
       END.
    ELSE
       DO:  */
           /* par_tipdocto = 1 - Titulo | 2 - Fatura */
           IF  par_tipdocto = 1 THEN  /*TITULO*/
               DO:
      
                   ASSIGN aux_ptitulo1 = DEC( SUBSTR(par_dscodbar,1,10) )
                          aux_ptitulo2 = DEC( SUBSTR(par_dscodbar,11,11) )
                          aux_ptitulo3 = DEC( SUBSTR(par_dscodbar,22,11) )
                          aux_ptitulo4 = DEC( SUBSTR(par_dscodbar,33,1) )
                          aux_ptitulo5 = DEC( SUBSTR(par_dscodbar,34,14) ).
                          /* par_dscodbar = "". */

                   RUN processa-titulo(INPUT  par_cdcooper,  /*Cooperativa*/
                                       INPUT  par_nmrescop,  /*Nome resumido coop*/
                                       INPUT  par_cdagenci,  /*PA*/
                                       INPUT  par_cdbccxlt,  /*Caixa*/
                                       INPUT  par_cdoperad,  /*Operador*/
                                       INPUT  par_nrdconta,  /*Conta*/
                                       INPUT  aux_ptitulo1,  /*Parte do cod barras titulo 1*/
                                       INPUT  aux_ptitulo2,  /*Parte do cod barras titulo 2*/
                                       INPUT  aux_ptitulo3,  /*Parte do cod barras titulo 3*/
                                       INPUT  aux_ptitulo4,  /*Parte do cod barras titulo 4*/
                                       INPUT  aux_ptitulo5,  /*Parte do cod barras titulo 5*/
                                       INPUT  par_dscodbar,  /*Codigo de barras*/
                                       INPUT  par_vltitfat,  /*Valor titulo*/
                                       INPUT  par_titvenci,  /*Titulo vencido msg*/
                                       INPUT  par_cpfcdnte,  /*CPF/CNPJ cedente*/
                                       INPUT  par_cpfsacad,  /*CPF/CNPJ sacado*/
                                       INPUT  TRUE,          /*Manual?*/
                                       INPUT  par_nmbenefi,  /* Nome do beneficiario retornado da NPC*/
                                       INPUT  par_inpesbnf,  /* Tipo de pessoa beneficiario*/
                                       INPUT  par_nrdocbnf,  /* CPF/CNPJ Beneficiario */
                                       INPUT  par_cdctrlcs,  /*Numero de controle consulta NPC*/  
                                       INPUT  par_tppagmto,  /*indicador do tipo pagamento 0-Conta | 1-Especie*/
                                       OUTPUT par_funcaojs,  /*Funcao javascript de retorno*/
                                       OUTPUT par_setafoco). 

                   IF  RETURN-VALUE <> "OK" THEN
                       DO:
                           RETURN "NOK".
                       END.
               END.
           ELSE  
               DO:
                   IF  par_tipdocto = 2 THEN  /*FATURA*/
                       DO:
                           RUN processa-fatura(INPUT par_cdcooper,   /*Cooperativa*/                  
                                               INPUT par_nmrescop,   /*Nome resumido coop*/           
                                               INPUT par_cdoperad,   /*Operador*/                     
                                               INPUT par_cdagenci,   /*PA*/                        
                                               INPUT par_cdbccxlt,   /*Caixa*/                     
                                               INPUT par_dtmvtolt,   /*Data movimento*/                        
                                               INPUT par_nrdconta,   /*Conta*/             
                                               INPUT par_vltitfat,   /*Valor fatura*/                 
                                               INPUT par_dscodbar,   /*Cod barras*/
                                               INPUT 2, /*Tipo processo - manual*/
                                               INPUT par_tppagmto,  /*indicador do tipo pagamento 0-Conta | 1-Especie*/
                                               OUTPUT par_funcaojs,
                                               OUTPUT par_setafoco). /*Campo que indica onde deve setar foco da tela*/

                           IF  RETURN-VALUE <> "OK" THEN
                               DO:
                                   RETURN "NOK".
                               END.

                       END.
               END.
    /*   END. */

    RETURN "OK".
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gera-erro w-html 

/* procedure para gerar erro em tela 
   pois a include que era usada {include/i-erro.i} 
   ja esperava variaveis carregas entao foi trazido a logica
   pra ca e eliminado o uso da include, as outras procedures
   referentes a erro estao na include bo-erro1.i*/
PROCEDURE gera-erro:

    DEF INPUT PARAM par_cdcooper AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTEGER                         NO-UNDO.

    FIND FIRST craperr 
         WHERE craperr.cdcooper = par_cdcooper AND
               craperr.cdagenci = par_cdagenci AND 
               craperr.nrdcaixa = par_cdbccxlt NO-LOCK NO-ERROR.

    IF AVAIL craperr THEN 
       DO:
        {&out} "<script>window.open('mensagem.p','werro','height=220,width=400,scrollbars=yes,alwaysRaised=true')</script>".
       END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gera-erro w-html 

/*Procedure para retornar o valor da fatura com multa e juros atualizados*/
PROCEDURE retorna-vlr-tit-vencto:
    DEF INPUT PARAM par_cdcooper       AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_nrdconta       AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_idseqttl       AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci       AS INTE                       NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa       AS INTE										   NO-UNDO.
    DEF INPUT PARAM par_cdoperad       AS CHAR										   NO-UNDO.
    DEF INPUT PARAM par_titulo1        AS DECI										   NO-UNDO.
    DEF INPUT PARAM par_titulo2        AS DECI										   NO-UNDO.
    DEF INPUT PARAM par_titulo3        AS DECI								       NO-UNDO.
    DEF INPUT PARAM par_titulo4        AS DECI								 		   NO-UNDO.
    DEF INPUT PARAM par_titulo5        AS DECI				 						   NO-UNDO.
    DEF INPUT PARAM par_codigo_barras  AS CHAR      								 NO-UNDO.
    DEF OUTPUT PARAM par_vlfatura      AS DECI                       NO-UNDO.
    DEF OUTPUT PARAM par_vlrjuros      AS DECI                       NO-UNDO.
    DEF OUTPUT PARAM par_vlrmulta      AS DECI                       NO-UNDO.
    DEF OUTPUT PARAM par_fltitven      AS INTE                       NO-UNDO.    
    DEF OUTPUT PARAM par_flblqval      AS INTE                       NO-UNDO.
    DEF OUTPUT PARAM par_nmbenefi      AS CHAR                       NO-UNDO.
    DEF OUTPUT PARAM par_inpesbnf      AS INTE                       NO-UNDO.
    DEF OUTPUT PARAM par_nrdocbnf      AS DECI                       NO-UNDO.
    DEF OUTPUT PARAM par_cdctrlcs      AS CHAR                       NO-UNDO. /* Numero de controle consulta NPC*/
    DEF OUTPUT PARAM par_des_erro      AS CHAR                       NO-UNDO.
    DEF OUTPUT PARAM par_dscritic      AS CHAR                       NO-UNDO.
    
    DEF VAR aux_tppesbenf AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtvencto  AS CHAR                                    NO-UNDO.	
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_consultar_valor_titulo
      aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper       /* Cooperativa             */
                         ,INPUT par_nrdconta       /* Número da conta         */
                         ,INPUT par_cdagenci       /* Agencia                 */
                         ,INPUT par_nrdcaixa       /* Número do caixa         */
                         ,INPUT par_idseqttl       /* Titular da conta        */
                         ,INPUT 0                  /* Indicador origem Mobile */
                         ,INPUT par_titulo1
                         ,INPUT par_titulo2
                         ,INPUT par_titulo3
                         ,INPUT par_titulo4
                         ,INPUT par_titulo5
                         ,INPUT par_codigo_barras /* Codigo de Barras */
                         ,INPUT par_cdoperad      /* Código do operador */
                         ,INPUT 2        /* pr_idorigem */
                         /* OUTPUT */
                         ,OUTPUT 0       /* pr_nrdocbenf    -- Documento do beneficiário emitente */
                         ,OUTPUT ""      /* pr_tppesbenf    -- Tipo de pessoa beneficiaria */
                         ,OUTPUT ""      /* pr_dsbenefic    -- Descriçao do beneficiário emitente */
                         ,OUTPUT 0       /* pr_vlrtitulo    -- Valor do título */
                         ,OUTPUT 0       /* pr_vlrjuros     -- Valor dos Juros */
                         ,OUTPUT 0       /* pr_vlrmulta	    -- Valor da multa */
                         ,OUTPUT 0       /* pr_vlrdescto	  -- Valor do desconto */
                         ,OUTPUT ""      /* pr_nrctrlcs     -- Numero do controle da consulta */
                         ,OUTPUT 0       /* pr_flblq_valor  -- Flag para bloquear o valor de pagamento */
                         ,OUTPUT 0       /* pr_fltitven     -- Flag indicador de titulo vencido */
                         ,OUTPUT ""      /* pr_dtvencto  Márcio Mouts -RITM0011951*/					 						 
                         ,OUTPUT ""      /* pr_des_erro     -- Indicador erro OK/NOK */
                         ,OUTPUT 0       /* pr_cdcritic     -- Código do erro  */
                         ,OUTPUT "").    /* pr_dscritic     -- Descricao do erro  */
    
    CLOSE STORED-PROC pc_consultar_valor_titulo aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

        ASSIGN par_des_erro = ""
               par_dscritic = ""
               par_vlfatura = 0
               par_vlrjuros = 0
               par_vlrmulta = 0
               par_flblqval = 0
               par_fltitven = 0
		       aux_dtvencto = "".
       ASSIGN  aux_tppesbenf = ""
               par_nrdocbnf = 0
               par_nmbenefi = ""
               par_cdctrlcs = "".
       ASSIGN  par_vlfatura = pc_consultar_valor_titulo.pr_vlrtitulo
                              WHEN pc_consultar_valor_titulo.pr_vlrtitulo <> ?        
               par_vlrjuros = pc_consultar_valor_titulo.pr_vlrjuros
                              WHEN pc_consultar_valor_titulo.pr_vlrjuros <> ?
               par_vlrmulta = pc_consultar_valor_titulo.pr_vlrmulta
                              WHEN pc_consultar_valor_titulo.pr_vlrmulta <> ?
               par_fltitven = pc_consultar_valor_titulo.pr_fltitven
                              WHEN pc_consultar_valor_titulo.pr_fltitven <> ?
               aux_dtvencto  = pc_consultar_valor_titulo.pr_dtvencto
                               WHEN pc_consultar_valor_titulo.pr_dtvencto <> ?.
       ASSIGN  aux_tppesbenf = pc_consultar_valor_titulo.pr_tppesbenf
                              WHEN pc_consultar_valor_titulo.pr_tppesbenf <> ?
               par_nrdocbnf = pc_consultar_valor_titulo.pr_nrdocbenf
                              WHEN pc_consultar_valor_titulo.pr_nrdocbenf <> ?
               par_nmbenefi = pc_consultar_valor_titulo.pr_dsbenefic
                              WHEN pc_consultar_valor_titulo.pr_dsbenefic <> ?
               par_cdctrlcs = pc_consultar_valor_titulo.pr_cdctrlcs
                              WHEN pc_consultar_valor_titulo.pr_cdctrlcs <> ?               
               par_flblqval  = pc_consultar_valor_titulo.pr_flblq_valor
                              WHEN pc_consultar_valor_titulo.pr_flblq_valor <> ?               
               par_des_erro = pc_consultar_valor_titulo.pr_des_erro
                              WHEN pc_consultar_valor_titulo.pr_des_erro <> ?
               par_dscritic = pc_consultar_valor_titulo.pr_dscritic
                              WHEN pc_consultar_valor_titulo.pr_dscritic <> ?. 

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    IF aux_tppesbenf = 'F' THEN
      ASSIGN par_inpesbnf = 1.
    ELSE
      ASSIGN par_inpesbnf = 2.
    
    IF  par_des_erro <> "OK" OR
        par_dscritic <> ""   THEN DO: 

        RETURN "NOK".
        
    END.

    RETURN "OK".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE validar-valor-limite w-html 

/* valida o valor recebido como parâmetro com o limite da agencia / cooperativa e solicita senha do coordenador se for maior */
PROCEDURE validar-valor-limite:

    DEF INPUT PARAM par_cdcooper  AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_cdoperad  AS CHARACTER                       NO-UNDO.
    DEF INPUT PARAM par_cdagenci  AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_nrocaixa  AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_vltitfat  AS DECIMAL                         NO-UNDO.
    DEF INPUT PARAM par_senha     AS CHARACTER                       NO-UNDO.
    DEF INPUT PARAM par_codconv   AS DECIMAL                         NO-UNDO.
    DEF OUTPUT PARAM par_des_erro AS CHARACTER                       NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHARACTER                       NO-UNDO.

    DEF VAR aux_inssenha          AS INTEGER                         NO-UNDO.
    DEF VAR h_b1crap14            AS HANDLE                          NO-UNDO.
    
    IF INT(ab_unmap.hdnVerifEstorno) = 1 THEN    
       RETURN "OK".
      
    RUN dbo/b1crap14.p PERSISTENT SET h_b1crap14.
          
    RUN valida-valor-limite IN h_b1crap14(INPUT par_cdcooper,
                                          INPUT par_cdoperad,
                                          INPUT par_cdagenci,
                                          INPUT par_nrocaixa,
                                          INPUT par_vltitfat,
                                          INPUT par_senha,
                                          OUTPUT par_des_erro,
                                          OUTPUT par_dscritic,
                                          OUTPUT aux_inssenha).
  DELETE PROCEDURE h_b1crap14.

  IF RETURN-VALUE = 'NOK' THEN  
   DO:
   
      ASSIGN vr_cdcriticValorAcima = 1. 
   
      ASSIGN ab_unmap.vh_foco = "10".
      RUN gerar-mensagem-tela(INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrocaixa,
                              INPUT par_dscritic).
                              
      RETURN "NOK".
   END.
        
   ASSIGN vr_cdcriticValorAcima = 0.

   /* Solicita confirmaçao operacao depois de inserida a senha DO coordenador, mas apenas para os pagamentos que nao podem ser estornados */
   IF (aux_inssenha > 0 AND (par_codconv = 119 OR par_codconv = 24 OR par_codconv = 98 OR par_codconv = 64 OR par_codconv = 153 OR par_codconv = 385 OR par_codconv = 328)) THEN
     DO:
       IF INT(ab_unmap.hdnVerifEstorno) = 1 THEN
        DO:
          RETURN "OK".
        END.
       ELSE
         DO:
           ASSIGN vr_cdcriticEstorno = 1.
           RETURN "NOK".
         END.         
    END.

    RETURN "OK".

END PROCEDURE.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gerar-mensagem-tela w-html 

/* valida o valor recebido como parâmetro com o limite da agencia / cooperativa e solicita senha do coordenador se for maior */
PROCEDURE gerar-mensagem-tela:
    DEF INPUT PARAM par_cdcooper  AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_cdagenci  AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_nrocaixa  AS INTEGER                         NO-UNDO.
    DEF INPUT PARAM par_dscritic AS CHARACTER                        NO-UNDO.
    
    /* Limpar as criticas */
    RUN elimina-erro(INPUT glb_nmrescop,
                     INPUT par_cdagenci,
                     INPUT par_nrocaixa).
    /* Criar o erro novo */
    RUN cria-erro(INPUT glb_nmrescop,
                  INPUT par_cdagenci,
                  INPUT par_nrocaixa,
                  INPUT 0,
                  INPUT par_dscritic,
                  INPUT YES).
    /* Exibir o erro */ 
    RUN gera-erro(INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrocaixa).                                   
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

