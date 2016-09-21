/* .............................................................................

   Programa: siscaixa/web/crap062.w
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Lucas Lunelli
   Data    : Abril/2016                      Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Atendimendo  - Cadastro de Número para Notificaçao por SMS DEBAUT [PROJ320]

   Alteracoes: 
   
............................................................................ */

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions */
DEFINE TEMP-TABLE ab_unmap
       FIELD vh_foco       AS CHARACTER FORMAT "X(256)":U 
       FIELD v_action      AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa       AS CHARACTER FORMAT "X(256)":U 
       FIELD v_conta       AS CHARACTER FORMAT "X(256)":U
       FIELD v_cartao      AS CHARACTER FORMAT "X(256)":U
       FIELD v_dsdcartao   AS CHARACTER FORMAT "X(256)":U
       FIELD v_coop        AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data        AS CHARACTER FORMAT "X(256)":U 
       FIELD v_mensagem    AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg         AS CHARACTER FORMAT "X(256)":U 
       FIELD v_infocry     AS CHARACTER FORMAT "X(256)":U               
       FIELD v_chvcry      AS CHARACTER FORMAT "X(256)":U       
       FIELD v_nrdocard    AS CHARACTER FORMAT "X(256)":U               
       FIELD v_nome        AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador    AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac         AS CHARACTER FORMAT "X(256)":U 
       FIELD vok           AS CHARACTER FORMAT "X(256)":U 
       FIELD vexcl         AS CHARACTER FORMAT "X(256)":U 
       FIELD cancela       AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nrDDD       AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nrtelefo    AS CHARACTER FORMAT "X(256)":U 
       FIELD v_senha       AS CHARACTER FORMAT "X(256)":U.

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

DEF VAR h-b1crap62 AS HANDLE            NO-UNDO.
DEF VAR h-b1crap02 AS HANDLE            NO-UNDO.
DEF VAR h-b1crap00 AS HANDLE            NO-UNDO.

DEF VAR p-conta              AS DECI    NO-UNDO.
DEF VAR p-registro           AS RECID   NO-UNDO.
DEF VAR c-autentica          AS CHAR    FORMAT "x(58)" NO-UNDO.
DEF VAR p-programa           AS CHAR    INITIAL "CRAP062".
DEF VAR aux_dsmsgsms         AS CHAR.
DEF VAR aux_idtipcar         AS INTE.

DEF VAR l-houve-erro    AS LOG          NO-UNDO.

DEF TEMP-TABLE w-craperr  NO-UNDO
     FIELD cdcooper   LIKE craperr.cdcooper
     FIELD cdagenci   LIKE craperr.cdagenc
     FIELD nrdcaixa   LIKE craperr.nrdcaixa
     FIELD nrsequen   LIKE craperr.nrsequen
     FIELD cdcritic   LIKE craperr.cdcritic
     FIELD dscritic   LIKE craperr.dscritic
     FIELD erro       LIKE craperr.erro.

DEF VAR i-campo      AS INT NO-UNDO.
DEF VAR p-nrcartao   AS DEC NO-UNDO.
DEF VAR p-idtipcar   AS INT NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE web/crap062.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS   ab_unmap.v_nrdocard ab_unmap.v_infocry ab_unmap.v_chvcry ab_unmap.v_action ab_unmap.v_senha ab_unmap.v_nome ab_unmap.v_mensagem ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_cartao ab_unmap.v_dsdcartao ab_unmap.v_conta ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_nrDDD ab_unmap.v_nrtelefo ab_unmap.cancela ab_unmap.vok ab_unmap.vexcl
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.v_nrdocard ab_unmap.v_infocry ab_unmap.v_chvcry ab_unmap.v_action ab_unmap.v_senha ab_unmap.v_nome ab_unmap.v_mensagem ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_cartao ab_unmap.v_dsdcartao ab_unmap.v_conta ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_nrDDD ab_unmap.v_nrtelefo ab_unmap.cancela ab_unmap.vok ab_unmap.vexcl

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
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
     ab_unmap.v_action AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_senha AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nome AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_mensagem AT ROW 1 COL 1 HELP
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
    ab_unmap.v_cartao AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_dsdcartao AT ROW 1 COL 1 HELP
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
     ab_unmap.v_nrDDD AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_nrtelefo  AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.cancela  AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.vok  AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.vexcl  AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 45.2 BY 10.76.
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
          FIELD cancela AS CHARACTER FORMAT "X(256)":U 
          FIELD ok AS CHARACTER FORMAT "X(256)":U 
          FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
          FIELD v_action AS CHARACTER FORMAT "X(256)":U 
          FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
          FIELD v_opcao AS CHARACTER FORMAT "X(256)":U 
          FIELD v_conta AS CHARACTER FORMAT "X(256)":U 
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_mensagem AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msgtrf AS CHARACTER FORMAT "X(256)":U 
          FIELD v_nome AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD v_senha AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valor AS CHARACTER FORMAT "X(256)":U 
          FIELD v_saldo_conta AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 10.76
         WIDTH              = 45.2.
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
/* SETTINGS FOR FILL-IN ab_unmap.cancela IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.ok IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.vh_foco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_action IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_caixa IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cod IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP  
/* SETTINGS FOR FILL-IN ab_unmap.v_opcao IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */                              */
/* SETTINGS FOR FILL-IN ab_unmap.v_conta IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_mensagem IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_msgtrf IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_nome IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_senha IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_valor IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_saldo_conta IN FRAME Web-Frame
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
    ("v_action":U,"ab_unmap.v_action":U,ab_unmap.v_action:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_caixa":U,"ab_unmap.v_caixa":U,ab_unmap.v_caixa:HANDLE IN FRAME {&FRAME-NAME}).  
  RUN htmAssociate
    ("v_cartao":U,"ab_unmap.v_cartao":U,ab_unmap.v_cartao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_dsdcartao":U,"ab_unmap.v_dsdcartao":U,ab_unmap.v_dsdcartao:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_conta":U,"ab_unmap.v_conta":U,ab_unmap.v_conta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_mensagem":U,"ab_unmap.v_mensagem":U,ab_unmap.v_mensagem:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_infocry":U,"ab_unmap.v_infocry":U,ab_unmap.v_infocry:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("v_chvcry":U,"ab_unmap.v_chvcry":U,ab_unmap.v_chvcry:HANDLE IN FRAME {&FRAME-NAME}).            
  RUN htmAssociate
    ("v_nrdocard":U,"ab_unmap.v_nrdocard":U,ab_unmap.v_nrdocard:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nome":U,"ab_unmap.v_nome":U,ab_unmap.v_nome:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_senha":U,"ab_unmap.v_senha":U,ab_unmap.v_senha:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nrDDD":U,"ab_unmap.v_nrDDD":U,ab_unmap.v_nrDDD:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nrtelefo":U,"ab_unmap.v_nrtelefo":U,ab_unmap.v_nrtelefo:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("cancela":U,"ab_unmap.cancela":U,ab_unmap.cancela:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("vok":U,"ab_unmap.vok":U,ab_unmap.vok:HANDLE IN FRAME {&FRAME-NAME}).    
  RUN htmAssociate
    ("vexcl":U,"ab_unmap.vexcl":U,ab_unmap.vexcl:HANDLE IN FRAME {&FRAME-NAME}).    
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

    DEFINE VARIABLE cMsgAux         AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE cdopcao         AS CHARACTER    NO-UNDO.

    RUN outputHeader.
    {include/i-global.i}

    IF REQUEST_METHOD = "POST":U THEN DO:
           
        RUN inputFields.
   
        RUN findRecords.
        
        {include/assignfields.i}

        RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.

        RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                           INPUT int(v_pac), 
                                           INPUT int(v_caixa)).
        DELETE PROCEDURE h-b1crap00.

        IF RETURN-VALUE = "NOK" THEN DO:
            {include/i-erro.i}
        END.            
        ELSE DO:
            IF get-value("cancela") <> "" THEN DO:
                ASSIGN v_conta     = ""
                       p-conta     = 0
                       v_cartao    = ""
                       v_dsdcartao = ""
                       v_nome      = ""
                       v_senha     = "" 
                       vh_foco     = "9"
                       v_action    = ""
                       cancela     = ""
                       vok         = ""
                       vexcl       = ""
                       v_nrDDD     = ""
                       v_nrtelefo  = ""
                       v_nrdocard  = ""
                       v_infocry   = ""
                       v_chvcry    = "".            
            END.
            ELSE DO:
            
                RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
                RUN verifica-abertura-boletim IN h-b1crap00(INPUT v_coop,
                                                            INPUT int(v_pac),
                                                            INPUT int(v_caixa),
                                                            INPUT v_operador).

                DELETE PROCEDURE h-b1crap00.
                
                IF  RETURN-VALUE <> "OK" THEN DO:
                    ASSIGN v_senha     = "".
                    
                    {include/i-erro.i}
                END.
                ELSE DO:                    
                    IF  v_dsdcartao <> ''  THEN
                        DO:
                            RUN dbo/b1crap62.p PERSISTENT SET h-b1crap62.
                            RUN verifica-cartao IN h-b1crap62 (INPUT v_coop,
                                                               INPUT INT(v_pac),
                                                               INPUT INT(v_caixa),
                                                               INPUT DECI(v_dsdcartao),
                                                              OUTPUT p-conta,
                                                              OUTPUT v_cartao,
                                                              OUTPUT aux_idtipcar).
                                                              
                            DELETE PROCEDURE h-b1crap62.
                            
                            IF  RETURN-VALUE = "NOK" THEN  
                                DO: 
                                    {include/i-erro.i}
                                     ASSIGN vh_foco  = "9"
                                            v_conta  = ""
                                            p-conta  = 0.
                                END.
                        END.
                        
                    IF  INT(p-conta) <> 0  THEN
                        DO:
                            RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.
                            RUN consulta-conta IN h-b1crap02 (INPUT v_coop,         
                                                              INPUT INT(v_pac),
                                                              INPUT INT(v_caixa),
                                                              INPUT INT(p-conta),
                                                              OUTPUT TABLE tt-conta).
                            DELETE PROCEDURE h-b1crap02.
                            
                            IF  RETURN-VALUE = "NOK" THEN  
                                DO: 
                                    {include/i-erro.i}
                                     ASSIGN vh_foco  = "9".
                                END.
                            ELSE
                                DO:
                                    FIND FIRST tt-conta NO-LOCK NO-ERROR.
                                    
                                    ASSIGN v_nome      = tt-conta.nome-tit                                           
                                           v_conta     = STRING(p-conta,"zzzz,zzz,9").
                                    
                                    IF  AVAIL tt-conta AND get-value("vok") = ""  THEN
                                        DO:                                                                                       
                                            RUN dbo/b1crap62.p PERSISTENT SET h-b1crap62.
                                            RUN opera-telefone-sms-debaut IN h-b1crap62 (INPUT v_coop,
                                                                                         INPUT INT(v_pac),
                                                                                         INPUT INT(v_caixa),
                                                                                         INPUT  v_operador,
                                                                                         INPUT "C",
                                                                                         INPUT DECI(p-conta),
                                                                                         INPUT FALSE,
                                                                                  INPUT-OUTPUT v_nrDDD,
                                                                                  INPUT-OUTPUT v_nrtelefo,
                                                                                        OUTPUT aux_dsmsgsms,
                                                                                        OUTPUT vh_foco).
                                            DELETE PROCEDURE h-b1crap62.
                                            
                                            IF  RETURN-VALUE = "NOK" THEN  
                                                DO:
                                                    {include/i-erro.i}
                                                END.
                                                
                                            IF  DECI(v_nrDDD) = 0 AND DECI(v_nrtelefo) = 0 THEN
                                                ASSIGN v_nrDDD     = ""
                                                       v_nrtelefo  = "".
                                                       
                                            ASSIGN vh_foco     = "15".                                                       
                                        END.
                                END.                        
                        END.
                        
                    IF  get-value("vok")   <> "" OR 
                        get-value("vexcl") <> "" THEN
                        DO:                                                            
                            IF  get-value("vok")   <> "" THEN
                                ASSIGN cdopcao = "A".
                                
                            IF  get-value("vexcl") <> "" THEN
                                ASSIGN cdopcao = "E".
                            
                            RUN dbo/b1crap62.p PERSISTENT SET h-b1crap62.
                            RUN valida-senha-cartao IN h-b1crap62 (INPUT v_coop,         
                                                                   INPUT INT(v_pac),
                                                                   INPUT INT(v_caixa),
                                                                   INPUT  v_operador,
                                                                   INPUT DEC(p-conta),
                                                                   INPUT v_cartao,
                                                                   INPUT v_senha,
                                                                   INPUT aux_idtipcar,
                                                                   INPUT v_infocry,
                                                                   INPUT v_chvcry).
                            DELETE PROCEDURE h-b1crap62.
                            IF  RETURN-VALUE = "NOK" THEN  
                                DO:
                                    {include/i-erro.i}
                                    ASSIGN vh_foco  = "16".
                                END.
                            ELSE
                                DO:                                
                                    RUN dbo/b1crap62.p PERSISTENT SET h-b1crap62.
                                    RUN opera-telefone-sms-debaut IN h-b1crap62 (INPUT v_coop,
                                                                                 INPUT INT(v_pac),
                                                                                 INPUT INT(v_caixa),
                                                                                 INPUT  v_operador,
                                                                                 INPUT cdopcao,
                                                                                 INPUT DECI(p-conta),
                                                                                 INPUT TRUE,
                                                                          INPUT-OUTPUT v_nrDDD,
                                                                          INPUT-OUTPUT v_nrtelefo,
                                                                                OUTPUT aux_dsmsgsms,
                                                                                OUTPUT vh_foco).
                                    DELETE PROCEDURE h-b1crap62.
                                    
                                    IF  RETURN-VALUE = "NOK" THEN  
                                        DO:
                                            {include/i-erro.i}                                            
                                            vh_foco     = "15".
                                        END.
                                    ELSE 
                                        DO:
                                            {include/i-erro.i}
                                            
                                            ASSIGN v_conta     = ""
                                                   p-conta     = 0
                                                   v_cartao    = ""
                                                   v_dsdcartao = ""
                                                   v_nome      = ""
                                                   v_senha     = "" 
                                                   vh_foco     = "9"
                                                   v_action    = ""
                                                   cancela     = ""
                                                   vok         = ""
                                                   vexcl       = ""
                                                   v_nrDDD     = ""
                                                   v_nrtelefo  = ""
                                                   v_nrdocard  = ""
                                                   v_infocry   = ""
                                                   v_chvcry    = "".                                                   
                                        END.
                                               
                                END.
                        END.                
                END.
            END.
        END.

        RUN displayFields.
        RUN enableFields.
        RUN outputFields.
    
    END. /* Form has been submitted. */
 
    /* REQUEST-METHOD = GET */ 
    ELSE DO:
    
        RUN dbo/b1crap62.p PERSISTENT SET h-b1crap62.
        RUN opera-telefone-sms-debaut IN h-b1crap62 (INPUT v_coop,
                                                     INPUT INT(v_pac),
                                                     INPUT INT(v_caixa),
                                                     INPUT  v_operador,
                                                     INPUT "C",
                                                     INPUT 999,
                                                     INPUT FALSE,
                                              INPUT-OUTPUT v_nrDDD,
                                              INPUT-OUTPUT v_nrtelefo,
                                                    OUTPUT aux_dsmsgsms,
                                                    OUTPUT vh_foco).
        DELETE PROCEDURE h-b1crap62.
        
        IF  RETURN-VALUE = "NOK" THEN  
            DO:
                {include/i-erro.i}                
            END.
            
        ASSIGN vh_foco     = "9"
               v_nrDDD     = ""
               v_nrtelefo  = "".
            
        ASSIGN v_mensagem = SUBSTRING(aux_dsmsgsms, 1, (INDEX(aux_dsmsgsms, "#") - 1)).

        RUN findRecords.       
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


