/* .............................................................................
 
   Programa: siscaixa/web/crap051a.w
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 09/05/2018.

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Depositos com Captura 

   Alteracoes: 11/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)

               13/03/2006 - Acrescentada leitura do campo cdcooper nas tabelas
                            craperr e crapmdw (Diego).

               24/10/2006 - Controle para exclusao das instancias das BO's
                            (Evandro).

               27/10/2009 - Projeto IF CECRED - CAF 
                            Inclus�o campo Processado(Guilherme).

               22/03/2010 - Repassar o parametro v_nrsequni e v_dtenvelo 
                            para as telas chamadas (Evandro).

               28/12/2010 - Tratamento para cheques de contas migradas 
                            (Guilherme).

               14/01/2013 - Tratamento para permitir pagamento e solicitar 
                            senha para cheques de contas migradas sem saldo em
                            conta pagos na cooperativa de origem  (Elton).

              19/02/2013 - Ajustado processo para chamar tela liberacao supervisor
                           somente apos valor total de cheque ser processado (Daniel).  

              20/06/2014 - Deposito Intercooperativas
                           - Novo parametro "Coop Destino"
                             -- valida-deposito-com-captura
                             -- valida-deposito-com-captura-migrado
                             -- valida-deposito-com-captura-migrado-host
                           (Guilherme/SUPERO)

			  08/01/2016 - Inserida Mensagem de teste (Lucas Lunelli SD 335441)

              09/05/2018 - Disponibilidade de utiliza�ao do caixa on-line mesmo com o
                           processo batch (noturno) executando (Fabio Adriano - AMcom).

............................................................................ */

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cmc7 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data AS CHARACTER FORMAT "X(256)":U 
       FIELD v_identifica AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
       FIELD v_poupanca AS CHARACTER FORMAT "X(256)":U 
       FIELD v_valor AS CHARACTER FORMAT "X(256)":U 
       FIELD v_valor1 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_valor2 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_valorproc AS CHARACTER FORMAT "X(256)":U
       FIELD v_nrsequni AS CHARACTER FORMAT "X(256)":U
       FIELD v_dtenvelo AS CHARACTER FORMAT "X(256)":U.


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
 

DEFINE VARIABLE h-b1crap00 AS HANDLE     NO-UNDO.
DEFINE VARIABLE h-b1crap51 AS HANDLE     NO-UNDO.

DEF var p-cdcmpchq       AS INT     FORMAT "zz9".               /* Comp */     
DEF VAR p-cdbanchq       AS INT     FORMAT "zz9".               /* Banco */
DEF var p-cdagechq       AS INT     FORMAT "zzz9".              /* Agencia */
DEF var p-nrddigc1       AS INT     FORMAT "9".                 /* C1 */
DEF var p-nrctabdb       AS DEC     FORMAT "zzz,zzz,zzz,9".     /* Conta */
DEF var p-nrddigc2       AS INT     FORMAT "9".                 /* C2 */
DEF var p-nrcheque       AS INT     FORMAT "zzz,zz9".           /* Cheque */
DEF var p-nrddigc3       AS INT     FORMAT "9".                  /* C3 */

DEF TEMP-TABLE w-compel
    FIELD dsdocmc7 AS CHAR    FORMAT "X(34)"
    FIELD cdcmpchq AS INT     FORMAT "zz9"
    FIELD cdbanchq AS INT     FORMAT "zz9"
    FIELD cdagechq AS INT     FORMAT "zzz9"
    FIELD nrddigc1 AS INT     FORMAT "9"   
    FIELD nrctaaux AS INT     
    FIELD nrctachq AS DECIMAL FORMAT "zzz,zzz,zzz,9"
    FIELD nrctabdb AS DECIMAL FORMAT "zzz,zzz,zzz,9"
    FIELD nrddigc2 AS INT     FORMAT "9"            
    FIELD nrcheque AS INT     FORMAT "zzz,zz9"      
    FIELD nrddigc3 AS INT     FORMAT "9"            
    FIELD vlcompel AS DECIMAL FORMAT "zzz,zzz,zz9.99"
    FIELD dtlibcom AS DATE    FORMAT "99/99/9999"
    FIELD lsdigctr AS CHAR
    FIELD tpdmovto AS INTE
    FIELD nrseqdig AS INTE
    FIELD cdtipchq AS INTE
    FIELD nrdocmto LIKE craplcm.nrdocmto
    FIELD nrposchq AS INTE
    INDEX compel1 AS UNIQUE PRIMARY
          dsdocmc7
    INDEX compel2 AS UNIQUE
          nrseqdig DESCENDING.

DEF VAR p-aux-indevchq   AS INTE NO-UNDO.
DEF VAR p-nrdocmto       AS INTE NO-UNDO.
DEF VAR p-conta-atualiza AS INTE no-undo.
DEF VAR p-histor         AS INTE NO-UNDO.

DEF VAR p-literal        AS CHAR  NO-UNDO.
DEF VAR p-ult-sequencia  AS INTE  NO-UNDO.
DEF var p-registro       AS RECID NO-UNDO.


DEF VAR l-houve-erro    AS LOG          NO-UNDO.

DEF TEMP-TABLE w-craperr  NO-UNDO
     FIELD cdagenci   LIKE craperr.cdagenc
     FIELD nrdcaixa   LIKE craperr.nrdcaixa
     FIELD nrsequen   LIKE craperr.nrsequen
     FIELD cdcritic   LIKE craperr.cdcritic
     FIELD dscritic   LIKE craperr.dscritic
     FIELD erro       LIKE craperr.erro.

DEF VAR v_mensagem1 AS CHAR NO-UNDO.
DEF VAR v_mensagem2 AS CHAR NO-UNDO.

DEF VAR v_pconta     AS CHAR NO-UNDO.
DEF VAR v_pnome      AS CHAR NO-UNDO.
DEF VAR v_ppoup      AS CHAR no-undo.
DEF VAR v_pvalor     AS CHAR NO-UNDO.
DEF VAR v_pvalor1    AS CHAR NO-UNDO.
DEF VAR v_pvalorproc AS CHAR NO-UNDO.
DEF VAR p-valor-disponivel AS DEC  NO-UNDO.
DEF VAR p-mensagem         AS CHAR no-undo.
DEF VAR de-saldo-cheque    AS DEC  NO-UNDO.
DEF VAR p-mensagem1        AS CHAR NO-UNDO.

DEF VAR p-flg-cta-migrada AS LOG NO-UNDO.
DEF VAR p-coop-migrada    AS CHAR NO-UNDO.
DEF VAR p-flg-coop-host   AS LOG NO-UNDO.
DEF VAR p-nro-conta-nova  AS INT NO-UNDO.
DEF VAR p-nro-conta-anti  AS INT NO-UNDO.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE F:/web/crap051a.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_cmc7 ab_unmap.v_conta ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_identifica ab_unmap.v_msg ab_unmap.v_nome ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_poupanca ab_unmap.v_valor ab_unmap.v_valor1 ab_unmap.v_valor2 ab_unmap.v_valorproc ab_unmap.nrsequni ab_unmap.dtenvelo
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_cmc7 ab_unmap.v_conta ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_identifica ab_unmap.v_msg ab_unmap.v_nome ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_poupanca ab_unmap.v_valor ab_unmap.v_valor1 ab_unmap.v_valor2 ab_unmap.v_valorproc ab_unmap.nrsequni ab_unmap.dtenvelo

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.vh_foco AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_caixa AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_cmc7 AT ROW 1 COL 1 HELP
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
     ab_unmap.v_data AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_identifica AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_msg AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nome AT ROW 1 COL 1 HELP
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
     ab_unmap.v_poupanca AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_valor AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_valor1 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_valor2 AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_valorproc AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nrsequni AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_dtenvelo AT ROW 1 COL 1 HELP
         "" NO-LABEL FORMAT "X(256)":U
         VIEW-AS FILL-IN 
         SIZE 20 BY 1    
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 80 BY 20.


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
          FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
          FIELD v_cmc7 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_identifica AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD v_poupanca AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valor AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valor1 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valor2 AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valorproc AS CHARACTER FORMAT "X(256)":U
          FIELD v_nrsequni AS CHARACTER FORMAT "X(256)":U
          FIELD v_dtenvelo AS CHARACTER FORMAT "X(256)":U
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
/* SETTINGS FOR fill-in ab_unmap.vh_foco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_caixa IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_cmc7 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_conta IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_identifica IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_nome IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_poupanca IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_valor IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_valor1 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_valor2 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_valorproc IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_nrsequni IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_dtenvelo IN FRAME Web-Frame
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
    ("v_caixa":U,"ab_unmap.v_caixa":U,ab_unmap.v_caixa:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cmc7":U,"ab_unmap.v_cmc7":U,ab_unmap.v_cmc7:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_conta":U,"ab_unmap.v_conta":U,ab_unmap.v_conta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_identifica":U,"ab_unmap.v_identifica":U,ab_unmap.v_identifica:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nome":U,"ab_unmap.v_nome":U,ab_unmap.v_nome:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_poupanca":U,"ab_unmap.v_poupanca":U,ab_unmap.v_poupanca:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_valor":U,"ab_unmap.v_valor":U,ab_unmap.v_valor:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_valor1":U,"ab_unmap.v_valor1":U,ab_unmap.v_valor1:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_valor2":U,"ab_unmap.v_valor2":U,ab_unmap.v_valor2:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_valorproc":U,"ab_unmap.v_valorproc":U,ab_unmap.v_valorproc:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nrsequni":U,"ab_unmap.v_nrsequni":U,ab_unmap.v_nrsequni:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_dtenvelo":U,"ab_unmap.v_dtenvelo":U,ab_unmap.v_dtenvelo:HANDLE IN FRAME {&FRAME-NAME}).
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
     * Open the database or SDO query and and fetch the first record. */ 
    RUN findRecords.
    
    /* STEP 3 -    
     * AssignFields will save the data in the frame.
     * (it automatically upgrades the lock to exclusive while doing the update)
     * 
     *  If a new record needs to be created set AddMode to true before 
        running assignFields.  
     *     setAddMode(TRUE).   
     * RUN assignFields. */
    
     {include/assignfields.i}

     IF  GET-VALUE("dep") <> "" THEN DO:
         {&OUT} "<script>window.location='crap051.w"           +
                "?v_pconta="      + GET-VALUE("v_pconta")      +
                "&v_pnome="       + GET-VALUE("v_pnome")       +
                "&v_ppoup="       + GET-VALUE("v_ppoup")       +
                "&v_pidentifica=" + GET-VALUE("v_pidentifica") +
                "&v_pvalor="      + GET-VALUE("v_pvalor")      +
                "&v_pvalor1="     + GET-VALUE("v_pvalor1")     +
                "&v_pnrsequni="   + GET-VALUE("v_pnrsequni")   +
                "&v_pdtenvelo="   + GET-VALUE("v_pdtenvelo")   +
                "'</script>".
     END.
     ELSE DO:
         ASSIGN v_conta      = GET-VALUE("v_pconta")
                v_nome       = GET-VALUE("v_pnome")
                v_poupanca   = GET-VALUE("v_ppoup")
                v_identifica = GET-VALUE("v_pidentifica")

                v_valor      = STRING(DEC(GET-VALUE("v_pvalor")),
                                          "zzz,zzz,zzz,zz9.99")

                v_valor1     = STRING(DEC(GET-VALUE("v_pvalor1")),
                                          "zzz,zzz,zzz,zz9.99")

                v_valorproc  = STRING(DEC(GET-VALUE("v_pvalorproc")),
                                          "zzz,zzz,zzz,zz9.99")
             
                v_nrsequni   = GET-VALUE("v_pnrsequni")
             
                v_dtenvelo   = GET-VALUE("v_pdtenvelo").

         
         /*isponibilidade de utiliza�ao do caixa on-line mesmo com o processo batch (noturno) executando*/
         RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
         RUN valida-transacao2 IN h-b1crap00(INPUT v_coop,
                                            INPUT v_pac,
                                            INPUT v_caixa).
         DELETE PROCEDURE h-b1crap00.

         IF RETURN-VALUE = "NOK" THEN DO:
            {include/i-erro.i}
         END.
         ELSE DO:
            
            RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
            RUN verifica-abertura-boletim 
                            IN h-b1crap00(INPUT v_coop,
                                          INPUT v_pac,
                                          INPUT v_caixa,
                                          INPUT v_operador).
            DELETE PROCEDURE h-b1crap00.

            IF RETURN-VALUE = "NOK" THEN DO:
               {include/i-erro.i}
            END.
            ELSE DO:

               IF  GET-VALUE("cancela") <> "" THEN DO:
                   ASSIGN v_valor2 = ""
                          v_cmc7   = ""
                          vh_foco  = "12".
               END.
               ELSE DO:

                   RUN dbo/b1crap51.p PERSISTENT SET h-b1crap51.
                   RUN critica-cheque-valor-individual 
                            IN h-b1crap51(INPUT v_coop,
                                          INPUT INT(v_pac),
                                          INPUT INT(v_caixa),
                                          INPUT DEC(v_valor2)).
                   DELETE PROCEDURE h-b1crap51.

                   IF RETURN-VALUE = "NOK" THEN DO:
                      {include/i-erro.i}
                   END.
                   ELSE DO:

                      IF  GET-VALUE("manual") <> "" THEN DO:
                         {&OUT} "<script>window.location='crap051a1.w"         +
                                "?v_pconta="      + GET-VALUE("v_pconta")      +
                                "&v_pnome="       + GET-VALUE("v_pnome")       +
                                "&v_ppoup="       + GET-VALUE("v_ppoup")       +
                                "&v_pidentifica=" + GET-VALUE("v_pidentifica") +
                                "&v_pvalor="      + GET-VALUE("v_pvalor")      + 
                                "&v_pvalor1="     + GET-VALUE("v_pvalor1")     +
                                "&v_pvalor2="     + GET-VALUE("v_valor2")      +
                                "&v_pnrsequni="   + GET-VALUE("v_pnrsequni")   +
                                "&v_pdtenvelo="   + GET-VALUE("v_pdtenvelo")   +
                                "'</script>".
                      END.
                      ELSE DO:

                         RUN dbo/b1crap51.p PERSISTENT SET h-b1crap51.
                         RUN critica-codigo-cheque-valor
                             IN h-b1crap51(INPUT v_coop,
                                           INPUT INT(v_pac),
                                           INPUT INT(v_caixa),
                                           INPUT v_cmc7,
                                           INPUT DEC(v_valor2)).
                         DELETE PROCEDURE h-b1crap51.
                         
                         IF  RETURN-VALUE = "OK" THEN  DO:
                             RUN dbo/b1crap51.p PERSISTENT SET h-b1crap51.
                             RUN valida-codigo-cheque 
                                 IN h-b1crap51(INPUT v_coop,
                                               INPUT INT(v_pac),
                                               INPUT INT(v_caixa),
                                               INPUT v_cmc7,
                                               INPUT " ",
                                               OUTPUT p-cdcmpchq,  
                                               OUTPUT p-cdbanchq,       
                                               OUTPUT p-cdagechq,       
                                               OUTPUT p-nrddigc1,       
                                               OUTPUT p-nrctabdb,       
                                               OUTPUT p-nrddigc2,       
                                               OUTPUT p-nrcheque,       
                                               OUTPUT p-nrddigc3). 
                             DELETE PROCEDURE h-b1crap51.
                         END.

                         FIND FIRST craperr WHERE
                                    craperr.cdcooper = crapcop.cdcooper  AND
                                    craperr.cdagenci = INT(v_pac)        AND
                                    craperr.nrdcaixa = INT(v_caixa)      AND
                                    craperr.cdcritic = 8 NO-ERROR.
                         IF  AVAIL craperr THEN DELETE craperr.
                         IF  RETURN-VALUE = "OK"  THEN DO:
                             RUN dbo/b1crap51.p PERSISTENT SET h-b1crap51.
                             RUN critica-contra-ordem 
                                 IN h-b1crap51(INPUT v_coop,
                                               INPUT INT(v_pac),           
                                               INPUT INT(v_caixa),         
                                               INPUT v_operador,           
                                               INPUT INT(v_conta),         
                                               INPUT v_cmc7,               
                                               INPUT " ",                  
                                               INPUT p-cdcmpchq,           
                                               INPUT p-cdbanchq,           
                                               INPUT p-cdagechq,           
                                               INPUT p-nrddigc1,           
                                               INPUT p-nrctabdb,           
                                               INPUT p-nrddigc2,           
                                               INPUT p-nrcheque,           
                                               INPUT p-nrddigc3,           
                                               INPUT DEC(v_valor2),        
                                               INPUT NO,                   
                                               OUTPUT v_mensagem1,         
                                               OUTPUT v_mensagem2,         
                                               OUTPUT p-mensagem,          
                                               OUTPUT p-valor-disponivel,
                                               
                                               OUTPUT p-flg-cta-migrada,
                                               OUTPUT p-coop-migrada,   
                                               OUTPUT p-flg-coop-host,  
                                               OUTPUT p-nro-conta-nova,
                                               OUTPUT p-nro-conta-anti). 

                             DELETE PROCEDURE h-b1crap51.
                         END.
                         
                         IF RETURN-VALUE = "OK"  THEN DO:
                            RUN dbo/b1crap51.p PERSISTENT SET h-b1crap51.

                            /* Validar os dados na cooperativa geradora do cheque */
                            IF  NOT p-flg-cta-migrada  THEN
                            RUN valida-deposito-com-captura
                                IN h-b1crap51(INPUT v_coop,
                                              INPUT INT(v_pac),
                                              INPUT INT(v_caixa),
                                              INPUT v_operador,
                                              INPUT " ",
                                              INPUT " ", /*Dep.Intercoop.*/
                                              INPUT INT(v_conta),
                                              INPUT v_cmc7,
                                              INPUT " ",
                                              INPUT p-cdcmpchq,  
                                              INPUT p-cdbanchq,       
                                              INPUT p-cdagechq,       
                                              INPUT p-nrddigc1,       
                                              INPUT p-nrctabdb,       
                                              INPUT p-nrddigc2,       
                                              INPUT p-nrcheque,       
                                              INPUT p-nrddigc3, 
                                              INPUT DEC(v_valor2),
                                              INPUT NO,
                                              OUTPUT v_mensagem1,
                                              OUTPUT v_mensagem2,
                                              OUTPUT p-mensagem,
                                              OUTPUT p-valor-disponivel).
                            ELSE
                            DO:
                                IF  NOT p-flg-coop-host  THEN
                                RUN valida-deposito-com-captura-migrado
                                    IN h-b1crap51(INPUT v_coop,
                                                  INPUT p-coop-migrada,
                                                  INPUT INT(v_pac),
                                                  INPUT INT(v_caixa),
                                                  INPUT v_operador,
                                                  INPUT " ",
                                                  INPUT " ", /*Dep.Intercoop.*/
                                                  INPUT INT(v_conta),
                                                  INPUT v_cmc7,
                                                  INPUT " ",
                                                  INPUT p-cdcmpchq,  
                                                  INPUT p-cdbanchq,       
                                                  INPUT p-cdagechq,       
                                                  INPUT p-nrddigc1,       
                                                  INPUT p-nrctabdb,       
                                                  INPUT p-nrddigc2,       
                                                  INPUT p-nrcheque,       
                                                  INPUT p-nrddigc3, 
                                                  INPUT DEC(v_valor2),
                                                  INPUT NO,
                                                  INPUT p-nro-conta-nova,
                                                  INPUT p-nro-conta-anti,
                                                  OUTPUT v_mensagem1,
                                                  OUTPUT v_mensagem2,
                                                  OUTPUT p-mensagem,
                                                  OUTPUT p-valor-disponivel).
                                ELSE
                                RUN valida-deposito-com-captura-migrado-host
                                    IN h-b1crap51(INPUT v_coop,
                                                  INPUT p-coop-migrada,
                                                  INPUT INT(v_pac),
                                                  INPUT INT(v_caixa),
                                                  INPUT v_operador,
                                                  INPUT " ",
                                                  INPUT " ", /*Dep.Intercoop.*/
                                                  INPUT INT(v_conta),
                                                  INPUT v_cmc7,
                                                  INPUT " ",
                                                  INPUT p-cdcmpchq,  
                                                  INPUT p-cdbanchq,       
                                                  INPUT p-cdagechq,       
                                                  INPUT p-nrddigc1,       
                                                  INPUT p-nrctabdb,       
                                                  INPUT p-nrddigc2,       
                                                  INPUT p-nrcheque,       
                                                  INPUT p-nrddigc3, 
                                                  INPUT DEC(v_valor2),
                                                  INPUT NO,
                                                  INPUT p-nro-conta-nova,
                                                  INPUT p-nro-conta-anti,
                                                  OUTPUT v_mensagem1,
                                                  OUTPUT v_mensagem2,
                                                  OUTPUT p-mensagem,
                                                  OUTPUT p-valor-disponivel).


                            END.
                            DELETE PROCEDURE h-b1crap51.
                         END.

                         IF  RETURN-VALUE = "NOK" THEN DO:

                             ASSIGN v_cmc7 = "".
                             vh_foco  = "13".
                             {include/i-erro.i}
                         END.
                         ELSE DO: 

                                  RUN dbo/b1crap51.p PERSISTENT SET h-b1crap51.

                                  IF  NOT p-flg-cta-migrada  THEN
                                  RUN valida-deposito-com-captura
                                       IN h-b1crap51  
                                                  (INPUT v_coop,
                                                   INPUT INT(v_pac),
                                                   INPUT INT(v_caixa),
                                                   INPUT v_operador,
                                                   INPUT " ",
                                                   INPUT " ", /*Dep.Intercoop.*/
                                                   INPUT INT(v_conta),
                                                   INPUT v_cmc7,
                                                   INPUT " ",
                                                   INPUT p-cdcmpchq,    
                                                   INPUT p-cdbanchq,       
                                                   INPUT p-cdagechq,       
                                                   INPUT p-nrddigc1,       
                                                   INPUT p-nrctabdb,       
                                                   INPUT p-nrddigc2,       
                                                   INPUT p-nrcheque,       
                                                   INPUT p-nrddigc3, 
                                                   INPUT DEC(v_valor2),
                                                   INPUT YES,
                                                   OUTPUT v_mensagem1,
                                                   OUTPUT v_mensagem2,
                                                   OUTPUT p-mensagem,
                                                   OUTPUT p-valor-disponivel).
                                  ELSE
                                  DO:
                                       IF  NOT p-flg-coop-host  THEN
                                       RUN valida-deposito-com-captura-migrado
                                            IN h-b1crap51  
                                                       (INPUT v_coop,
                                                        INPUT p-coop-migrada,
                                                        INPUT INT(v_pac),
                                                        INPUT INT(v_caixa),
                                                        INPUT v_operador,
                                                        INPUT " ",
                                                        INPUT " ", /*Dep.Intercoop.*/
                                                        INPUT INT(v_conta),
                                                        INPUT v_cmc7,
                                                        INPUT " ",
                                                        INPUT p-cdcmpchq,    
                                                        INPUT p-cdbanchq,       
                                                        INPUT p-cdagechq,       
                                                        INPUT p-nrddigc1,       
                                                        INPUT p-nrctabdb,       
                                                        INPUT p-nrddigc2,       
                                                        INPUT p-nrcheque,       
                                                        INPUT p-nrddigc3, 
                                                        INPUT DEC(v_valor2),
                                                        INPUT YES,
                                                        INPUT p-nro-conta-nova,
                                                        INPUT p-nro-conta-anti,
                                                        OUTPUT v_mensagem1,
                                                        OUTPUT v_mensagem2,
                                                        OUTPUT p-mensagem,
                                                        OUTPUT p-valor-disponivel).
                                       ELSE
                                       RUN valida-deposito-com-captura-migrado-host
                                           IN h-b1crap51(INPUT v_coop,
                                                         INPUT p-coop-migrada,
                                                         INPUT INT(v_pac),
                                                         INPUT INT(v_caixa),
                                                         INPUT v_operador,
                                                         INPUT " ",
                                                         INPUT " ", /*Dep.Intercoop.*/
                                                         INPUT INT(v_conta),
                                                         INPUT v_cmc7,
                                                         INPUT " ",
                                                         INPUT p-cdcmpchq,  
                                                         INPUT p-cdbanchq,       
                                                         INPUT p-cdagechq,       
                                                         INPUT p-nrddigc1,       
                                                         INPUT p-nrctabdb,       
                                                         INPUT p-nrddigc2,       
                                                         INPUT p-nrcheque,       
                                                         INPUT p-nrddigc3, 
                                                         INPUT DEC(v_valor2),
                                                         INPUT YES,
                                                         INPUT p-nro-conta-nova,
                                                         INPUT p-nro-conta-anti,
                                                         OUTPUT v_mensagem1,
                                                         OUTPUT v_mensagem2,
                                                         OUTPUT p-mensagem,
                                                         OUTPUT p-valor-disponivel).


                                  END.
                                  
                                  DELETE PROCEDURE h-b1crap51.

                                  IF RETURN-VALUE = "NOK"  THEN DO:

                                     ASSIGN vh_foco  = "13".
                                     {include/i-erro.i}
                                  END.
                                ELSE DO:
                                     
                                     IF   NOT (v_mensagem1 = " " AND
                                               v_mensagem2 = " " AND
                                               p-mensagem =  " " AND
                                               p-valor-disponivel = 0) THEN DO:

                                            FOR  EACH crapmdw WHERE
                                                      crapmdw.cdcooper = crapcop.cdcooper  AND
                                                      crapmdw.cdagenci = INT(v_pac)        AND
                                                      crapmdw.nrdcaixa = INT(v_caixa)      AND
                                                      crapmdw.nrcheque = p-nrcheque        AND
                                                      crapmdw.nrctabdb = p-nrctabdb EXCLUSIVE-LOCK:

                                                      ASSIGN crapmdw.dsmensa1 = TRIM(v_mensagem1)
                                                             crapmdw.dsmensa2 = TRIM(v_mensagem2)
                                                             crapmdw.dsmensa3 = TRIM(p-mensagem)
                                                             crapmdw.vldispon = DEC(p-valor-disponivel)
                                                             crapmdw.flgctami = p-flg-cta-migrada
                                                             crapmdw.flgcooph = p-flg-coop-host
                                                             crapmdw.nrctanov = p-nro-conta-nova
                                                             crapmdw.nrctaant = p-nro-conta-anti
                                                             crapmdw.flgautor = FALSE
                                                             crapmdw.dscoopmi = p-coop-migrada.                   
                                            END.
                                     END.

                                     ASSIGN de-saldo-cheque = 0.
                                     FOR  EACH crapmdw WHERE
                                          crapmdw.cdcooper = crapcop.cdcooper  AND
                                          crapmdw.cdagenci = INT(v_pac)        AND
                                          crapmdw.nrdcaixa = INT(v_caixa) NO-LOCK:
      
                                          ASSIGN de-saldo-cheque =
                                                 de-saldo-cheque +
                                                 crapmdw.vlcompel.

                                     END.

                                     IF  de-saldo-cheque = DEC(v_valor1) THEN DO:

                                          FOR EACH crapmdw 
                                            WHERE crapmdw.cdcooper = crapcop.cdcooper AND
                                                  crapmdw.cdagenci = INT(v_pac) AND
                                                  crapmdw.nrdcaixa = INT(v_caixa) NO-LOCK:

													   /* Mensagens de Testes (Rotina 51 - Lunelli) */
                                                       MESSAGE "-> (Valor Disp + Lim. Cred): " STRING(p-valor-disponivel)
                                                               " | Vlr Cheque: " STRING(crapmdw.vlcompel)                                                               
                                                               " | Autoriza Deposito: " CAPS(STRING(crapmdw.flgautor))
                                                               " | ContaDV: " STRING(GET-VALUE("v_pconta"))
                                                               " | ContaCHQ: " STRING(crapmdw.nrctabdb)
                                                               " | CMC7: " STRING(crapmdw.dsdocmc7)
                                                               " | MGS1: " crapmdw.dsmensa1 
                                                               " | MGS2: " crapmdw.dsmensa2
                                                               " | MGS3: " crapmdw.dsmensa3
                                                               " | Vlr MDW: " STRING(crapmdw.vldispon)
                                                               VIEW-AS ALERT-BOX INFO BUTTONS OK.
                                                       /* FIM Mensagens de Testes */
                
                                                       IF   NOT (crapmdw.dsmensa1 = " " AND
                                                                 crapmdw.dsmensa2 = " " AND
                                                                 crapmdw.dsmensa3 = " " AND
                                                                 crapmdw.vldispon = 0) THEN
                
                                                           IF crapmdw.flgautor = FALSE  THEN DO:
                                                              {&OUT} "<script>window.location='crap051a2.w"             +
                                                                    "?v_pconta="           + GET-VALUE("v_pconta")       +
                                                                    "&v_pnome="            + GET-VALUE("v_pnome")       +
                                                                    "&v_ppoup="            + GET-VALUE("v_ppoup")       +
                                                                    "&v_pidentifica="      + GET-VALUE("v_pidentifica")  +
                                                                    "&v_pvalor="           + GET-VALUE("v_pvalor")       +
                                                                    "&v_pvalor1="          + GET-VALUE("v_pvalor1")      +
                                                                    "&v_pvalor2="          + STRING(crapmdw.vlcompel)   +
                                                                    "&v_cmc7="             + crapmdw.dsdocmc7           +
                                                                    "&v_cdcmpchq="         + STRING(crapmdw.cdcmpchq)   +                    
                                                                    "&v_cdbanchq="         + STRING(crapmdw.cdbanchq)   +                    
                                                                    "&v_cdagechq="         + STRING(crapmdw.cdagechq)   +                    
                                                                    "&v_nrddigc1="         + STRING(crapmdw.nrddigc1)   +                    
                                                                    "&v_nrctabdb="         + STRING(crapmdw.nrctabdb)   +                    
                                                                    "&v_nrddigc2="         + STRING(crapmdw.nrddigc2)   +                    
                                                                    "&v_nrcheque="         + STRING(crapmdw.nrcheque)   +                    
                                                                    "&v_nrddigc3="         + STRING(crapmdw.nrddigc3)   +                   
                                                                    "&p-valor-disponivel=" + STRING(crapmdw.vldispon)   +
                                                                    "&v_pmensagem1="       + crapmdw.dsmensa1           +
                                                                    "&v_pmensagem2="       + crapmdw.dsmensa2           +
                                                                    "&p-mensagem="         + crapmdw.dsmensa3           +
                                                                    "&p-valor-disponivel=" + STRING(crapmdw.vldispon)   +
                                                                    "&v_pnrsequni="        + GET-VALUE("v_pnrsequni")    +
                                                                    "&v_pdtenvelo="        + GET-VALUE("v_pdtenvelo")    + 
                                                                    "&v_flg-cta-migrada="  + STRING(crapmdw.flgctami)   +
                                                                    "&v_coop-migrada="     + crapmdw.dscoopmi           +
                                                                    "&v_flg-coop-host="    + STRING(crapmdw.flgcooph)   +
                                                                    "&v_nro-conta-nova="   + STRING(crapmdw.nrctanov)   +
                                                                    "&v_nro-conta-anti="   + STRING(crapmdw.nrctaant)   +
                                                                    "'</script>". 
                                                           END.
                                          END.

                                             {&OUT} "<script>window.location='crap051c.htm"        +
                                                    "?v_pconta="           + GET-VALUE("v_pconta")      + 
                                                    "&v_pnome="            + GET-VALUE("v_pnome")       +
                                                    "&v_ppoup="            + GET-VALUE("v_ppoup")       +
                                                    "&v_pidentifica="      + GET-VALUE("v_pidentifica") +
                                                    "&v_coop="             + GET-VALUE("v_coop")        + 
                                                    "&v_pac="              + GET-VALUE("v_pac")         +
                                                    "&v_caixa="            + GET-VALUE("v_caixa")       + 
                                                    "&v_operador="         + GET-VALUE("v_operador")    + 
                                                    "&v_data="             + GET-VALUE("v_data")        +
                                                    "&v_pvalor="           + GET-VALUE("v_pvalor")      +
                                                    "&v_pvalor1="          + GET-VALUE("v_pvalor1")     +
                                                    "&v_pnrsequni="        + GET-VALUE("v_pnrsequni")   +
                                                    "&v_pdtenvelo="        + GET-VALUE("v_pdtenvelo")   +
                                                    "&v_flg-cta-migrada="   + STRING(p-flg-cta-migrada) +
                                                    "&v_coop-migrada="      + STRING(p-coop-migrada)    +
                                                    "&v_flg-coop-host="     + STRING(p-flg-coop-host)   +
                                                    "&v_nro-conta-nova="    + STRING(p-nro-conta-nova)  +
                                                    "&v_nro-conta-anti="    + STRING(p-nro-conta-anti)  +
    
                                                    "'</script>".
                                     END.
                                ELSE DO:

                                               {&OUT} "<script>window.location='crap051a.w"          +
                                                      "?v_pconta="      + GET-VALUE("v_pconta")      +
                                                      "&v_pnome="       + GET-VALUE("v_pnome")       + 
                                                      "&v_ppoup="       + GET-VALUE("v_ppoup")       + 
                                                      "&v_pidentifica=" + GET-VALUE("v_pidentifica") + 
                                                      "&v_pvalor="      + GET-VALUE("v_pvalor")      +
                                                      "&v_pvalor1="     + GET-VALUE("v_pvalor1")     +
                                                      "&v_pvalor2="     + GET-VALUE("v_valor2")      +
                                                      "&v_pvalorproc="  + STRING(de-saldo-cheque)    +
                                                      "&v_pnrsequni="   + GET-VALUE("v_pnrsequni")   +
                                                      "&v_pdtenvelo="   + GET-VALUE("v_pdtenvelo")   +
                                                      "'</script>". 
                                     END.  
                                  END. 

                         END.
                      END.   /* Automatico */
                   END.
               END.
            END.
         END.
     END.
 
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
    ASSIGN vh_foco      = "12"
           v_conta      = GET-VALUE("v_pconta")
           v_nome       = GET-VALUE("v_pnome")
           v_poupanca   = GET-VALUE("v_ppoup")
           v_identifica = GET-VALUE("v_pidentifica")
           v_valor      = STRING(DEC(GET-VALUE("v_pvalor")),
                                     "zzz,zzz,zzz,zz9.99")
                        
           v_valor1     = STRING(DEC(GET-VALUE("v_pvalor1")),
                                     "zzz,zzz,zzz,zz9.99")
                        
           v_valorproc  = STRING(DEC(GET-VALUE("v_pvalorproc")),
                                     "zzz,zzz,zzz,zz9.99")
        
           v_nrsequni   = GET-VALUE("v_nrsequni")
        
           v_dtenvelo   = GET-VALUE("v_dtenvelo").



    ASSIGN de-saldo-cheque = 0.
    FOR EACH crapmdw WHERE crapmdw.cdcooper = crapcop.cdcooper  AND
                           crapmdw.cdagenci = INT(v_pac)        AND
                           crapmdw.nrdcaixa = INT(v_caixa) NO-LOCK:

        ASSIGN de-saldo-cheque = de-saldo-cheque + crapmdw.vlcompel.

    END.

    IF  de-saldo-cheque <> 0  THEN
        ASSIGN v_valorproc = 
               STRING(de-saldo-cheque,"zzz,zzz,zzz,zz9.99").

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

