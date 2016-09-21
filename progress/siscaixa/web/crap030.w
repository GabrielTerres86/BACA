/*..............................................................................

   Programa: siscaixa/web/crap030.w
   Sistema : Caixa On-Line
   Sigla   : CRED
   Autor   : Lucas Lunelli
   Data    : 15/09/2014                         Ultima atualizacao:

   Dados referentes ao programa: Incluir débito automático

   Alteracoes: 
   
..............................................................................*/

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW                             

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap     
       FIELD opcao             AS CHARACTER FORMAT "X(256)":U 
       FIELD vh_foco           AS CHARACTER FORMAT "X(256)":U 
       FIELD vh_nome           AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa           AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop            AS CHARACTER FORMAT "X(256)":U 
       FIELD v_conta           AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nome            AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data            AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg             AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador        AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac             AS CHARACTER FORMAT "X(256)":U
       FIELD v_segmento        AS CHARACTER
       FIELD v_indempre        AS CHARACTER FORMAT "X(256)":U
       FIELD v_cntanter        AS CHARACTER FORMAT "X(256)":U
       FIELD v_cdempcon        AS CHARACTER FORMAT "X(256)":U
       FIELD v_cdrefere        AS CHARACTER FORMAT "X(256)":U
       FIELD inlimite          AS CHARACTER FORMAT "X(256)":U
       FIELD v_vlrmaxdb        AS CHARACTER FORMAT "X(256)":U
       FIELD v_dshisext        AS CHARACTER FORMAT "X(256)":U
       FIELD v_cddsenha        AS CHARACTER FORMAT "X(256)":U.

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

DEF VAR aux_foco        AS CHAR                        NO-UNDO.
DEF VAR cListAux        AS CHAR                        NO-UNDO.
DEF VAR aux_cdsegmto    AS INTE                        NO-UNDO.
DEF VAR aux_cdempcon    AS INTE                        NO-UNDO.


DEF VAR h-b1crap02      AS HANDLE                      NO-UNDO.
DEF VAR h-b1crap30      AS HANDLE                      NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE F:/web/crap030.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.vh_foco ab_unmap.vh_nome ab_unmap.v_caixa  ab_unmap.v_coop ab_unmap.v_conta ab_unmap.v_nome ab_unmap.v_data  ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_segmento ab_unmap.v_indempre ab_unmap.v_cntanter ab_unmap.v_cdempcon ab_unmap.v_cdrefere ab_unmap.inlimite ab_unmap.inantlim ab_unmap.v_vlrmaxdb ab_unmap.v_dshisext ab_unmap.v_cddsenha
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.vh_foco ab_unmap.vh_nome ab_unmap.v_caixa ab_unmap.v_coop ab_unmap.v_conta ab_unmap.v_nome ab_unmap.v_data  ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_segmento ab_unmap.v_indempre ab_unmap.v_cntanter ab_unmap.v_cdempcon ab_unmap.v_cdrefere ab_unmap.inlimite  ab_unmap.inantlim ab_unmap.v_vlrmaxdb ab_unmap.v_dshisext ab_unmap.v_cddsenha

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
    ab_unmap.vh_nome AT ROW 1 COL 1 HELP
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
    ab_unmap.v_conta AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_nome AT ROW 1 COL 1 HELP
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
    ab_unmap.v_segmento AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
    ab_unmap.v_cdempcon AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
    ab_unmap.v_cdrefere AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_indempre AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_cntanter AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1        
    ab_unmap.inlimite AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS 
          "incooper 1", "1":U,
          "incooper 2", "2":U
    ab_unmap.v_vlrmaxdb AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_dshisext AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    ab_unmap.v_cddsenha AT ROW 1 COL 1 HELP
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
            FIELD dtapurac AS CHARACTER FORMAT "X(256)":U
            FIELD nrcpfcgc AS CHARACTER FORMAT "X(256)":U
            FIELD cdtribut AS CHARACTER FORMAT "X(256)":U
            FIELD cdrefere AS CHARACTER FORMAT "X(256)":U
            FIELD dtlimite AS CHARACTER FORMAT "X(256)":U
            FIELD vlrecbru AS CHARACTER FORMAT "X(256)":U
            FIELD vlpercen AS CHARACTER FORMAT "X(256)":U
            FIELD vllanmto AS CHARACTER FORMAT "X(256)":U
            FIELD vlrmulta AS CHARACTER FORMAT "X(256)":U
            FIELD vlrjuros AS CHARACTER FORMAT "X(256)":U
            FIELD vlrtotal AS CHARACTER FORMAT "X(256)":U.
	        FIELD vh_foco    AS CHARACTER FORMAT "X(256)":U 
            FIELD v_caixa    AS CHARACTER FORMAT "X(256)":U 
            FIELD v_conta    AS CHARACTER FORMAT "X(256)":U 
            FIELD v_coop     AS CHARACTER FORMAT "X(256)":U 
            FIELD v_data     AS CHARACTER FORMAT "X(256)":U 
            FIELD v_msg      AS CHARACTER FORMAT "X(256)":U 
            FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
            FIELD v_pac      AS CHARACTER FORMAT "X(256)":U 
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
/* SETTINGS FOR fill-in ab_unmap.ok IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.vh_foco IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_ano IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_caixa IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_codigo IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_conta IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_identificador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_v_nrcpfcgc IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */   
/* SETTINGS FOR fill-in ab_unmap.v_mes IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_nome IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_valorins IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_valorjur IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_valorout IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR fill-in ab_unmap.v_valortot IN FRAME Web-Frame
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
    ("vh_nome":U,"ab_unmap.vh_nome":U,ab_unmap.vh_nome:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_conta":U,"ab_unmap.v_conta":U,ab_unmap.v_conta:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_nome":U,"ab_unmap.v_nome":U,ab_unmap.v_nome:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_segmento":U,"ab_unmap.v_segmento":U,ab_unmap.v_segmento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cdempcon":U,"ab_unmap.v_cdempcon":U,ab_unmap.v_cdempcon:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_indempre":U,"ab_unmap.v_indempre":U,ab_unmap.v_indempre:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cntanter":U,"ab_unmap.v_cntanter":U,ab_unmap.v_cntanter:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cdrefere":U,"ab_unmap.v_cdrefere":U,ab_unmap.v_cdrefere:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("inlimite":U,"ab_unmap.inlimite":U,ab_unmap.inlimite:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_vlrmaxdb":U,"ab_unmap.v_vlrmaxdb":U,ab_unmap.v_vlrmaxdb:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_dshisext":U,"ab_unmap.v_dshisext":U,ab_unmap.v_dshisext:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cddsenha":U,"ab_unmap.v_cddsenha":U,ab_unmap.v_cddsenha:HANDLE IN FRAME {&FRAME-NAME}).

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

   ASSIGN v_segmento:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = 'Todas,99,' +
                                                              'Prefeituras,1,' +
                                                              'Saneamento,2,' +
                                                              'Energia Eletrica e Gas,3,' +
                                                              'Telecomunicacoes,4,' +
                                                              'Orgaos Governamentais,5,' +
                                                              'Orgaos identificados atraves do CNPJ,6,' +
                                                              'Multas de Transito,7,' +
                                                              'Uso interno do banco,9'.

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


    IF  GET-VALUE("cancela") <> "" THEN
        ASSIGN opcao       = ""
               vh_foco     = "10"
               v_segmento  = ""
               vh_nome     = ""
               v_indempre  = ""
               v_cntanter  = ""
               v_conta     = ""
               v_cdempcon  = ""
               v_cdrefere  = ""
               inlimite    = "2"
               v_vlrmaxdb  = ""
               v_dshisext  = ""
               v_cddsenha  = "".
     ELSE
        DO:
             ASSIGN opcao       = ""
                    aux_foco    = ""
                    v_cdrefere  = ab_unmap.v_cdrefere                    
                    inlimite    = ab_unmap.inlimite  
                    v_vlrmaxdb  = ab_unmap.v_vlrmaxdb
                    v_dshisext  = ab_unmap.v_dshisext
                    v_cddsenha  = ab_unmap.v_cddsenha.

             IF  INT(get-value("v_conta")) > 0  THEN
                 DO:
                     /* Se Contas mudarem */
                     IF  INT(ab_unmap.v_cntanter) <> INT(ab_unmap.v_conta) THEN                 
                         DO:
                            ASSIGN opcao       = ""                           
                                   v_indempre  = ""
                                   v_cdempcon  = ""
                                   v_cdrefere  = ""
                                   inlimite    = "2"
                                   v_vlrmaxdb  = ""
                                   v_dshisext  = ""
                                   v_cddsenha  = "".
        
                            
                            RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.
                            RUN consulta-conta IN h-b1crap02 (INPUT v_coop,         
                                                              INPUT INT(v_pac),
                                                              INPUT INT(v_caixa),
                                                              INPUT INT(v_conta),
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
                                    IF  AVAIL tt-conta  THEN
                                        ASSIGN v_nome      = tt-conta.nome-tit
                                               v_segmento  = "99"
                                               vh_foco     = "12".
                                END.
                         END.
                     ELSE
                         ASSIGN v_nome = vh_nome.
                 END.
           
             RUN dbo/b1crap30.p PERSISTENT SET h-b1crap30.

             RUN retorna-convenios-por-segmto IN h-b1crap30 (INPUT STRING(v_coop),
                                                             INPUT INTEGER(v_segmento),
                                                            OUTPUT cListAux).
             DELETE PROCEDURE h-b1crap30.

             ASSIGN v_cdempcon:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = cListAux.

            IF  get-value("sok") <> "" THEN
                 DO:
                    RUN dbo/b1crap30.p PERSISTENT SET h-b1crap30.

                    RUN valida-campos-debaut IN h-b1crap30 (INPUT STRING(v_coop),
                                                            INPUT INTE(v_pac),
                                                            INPUT INTE(v_caixa),
                                                            INPUT DECI(GET-VALUE("v_conta")),
                                                            INPUT STRING(GET-VALUE("v_cdempcon")),
                                                            INPUT DECI(ab_unmap.v_cdrefere),
                                                            INPUT INTE(ab_unmap.inlimite),
                                                            INPUT DECI(ab_unmap.v_vlrmaxdb),
                                                            INPUT ab_unmap.v_dshisext,
                                                            INPUT INTE(ab_unmap.v_cddsenha),
                                                           OUTPUT aux_foco).
                    DELETE PROCEDURE h-b1crap30.

                    IF  RETURN-VALUE = "NOK" THEN
                        DO: 

                           {include/i-erro.i}
                           ASSIGN vh_foco    = aux_foco
                                  v_indempre = ab_unmap.v_indempre.
                        END.
                    ELSE
                        DO:
                            RUN dbo/b1crap30.p PERSISTENT SET h-b1crap30.

                            IF  INTEGER(v_segmento) = 99 THEN /* TODOS */
                                ASSIGN aux_cdsegmto = INTEGER(ENTRY(2, GET-VALUE("v_cdempcon"), "/"))
                                       aux_cdempcon = INTEGER(ENTRY(1, GET-VALUE("v_cdempcon"), "/")).
                            ELSE
                                ASSIGN aux_cdsegmto = INTEGER(GET-VALUE("v_segmento"))
                                       aux_cdempcon = INTEGER(GET-VALUE("v_cdempcon")).

                            RUN inclui-debito-automatico IN h-b1crap30 (INPUT STRING(v_coop),
                                                                        INPUT INTE(v_pac),
                                                                        INPUT INTE(v_caixa),
                                                                        INPUT v_operador,
                                                                        INPUT DECI(GET-VALUE("v_conta")),
                                                                        INPUT aux_cdsegmto,
                                                                        INPUT aux_cdempcon,
                                                                        INPUT DECI(ab_unmap.v_cdrefere),
                                                                        INPUT DECI(ab_unmap.v_vlrmaxdb),
                                                                        INPUT ab_unmap.v_dshisext,
                                                                       OUTPUT aux_foco).
                            DELETE PROCEDURE h-b1crap30.

                            IF  RETURN-VALUE = "NOK" THEN
                                DO: 
                                   {include/i-erro.i}
                                   ASSIGN vh_foco    = aux_foco
                                          v_indempre = ab_unmap.v_indempre.
                                END.
                            ELSE
                                DO:
                                    {include/i-erro.i}
                                    {&OUT} '<script> window.location = "crap030.htm" </script>'.
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

      ASSIGN ab_unmap.inlimite = "2".

      IF  GET-VALUE("v_conta") <> "" THEN
          DO:
               RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.             
               RUN consulta-conta IN h-b1crap02 (INPUT v_coop,         
                                                 INPUT INT(v_pac),
                                                 INPUT INT(v_caixa),
                                                 INPUT INT(GET-VALUE("v_conta")),
                                              OUTPUT TABLE tt-conta).
               DELETE PROCEDURE h-b1crap02.
               IF   RETURN-VALUE = "NOK" THEN  
                    DO: 
                        {include/i-erro.i}
                         ASSIGN vh_foco  = "9".
                    END.
                ELSE
                    DO:
                        FIND FIRST tt-conta NO-LOCK NO-ERROR.
                        IF  AVAIL tt-conta  THEN
                            ASSIGN v_nome      = tt-conta.nome-tit
                                   v_conta     = STRING(INTE(GET-VALUE("v_conta")), "zzzz,zz9,9").
                    END.
          END.

    IF   get-value("v_cdempcon") <> "" THEN
         DO:
             RUN dbo/b1crap30.p PERSISTENT SET h-b1crap30.
    
             RUN retorna-convenios-por-segmto IN h-b1crap30 (INPUT STRING(v_coop),
                                                             INPUT INTEGER(get-value("v_segmento")),
                                                            OUTPUT cListAux).
             DELETE PROCEDURE h-b1crap30.
    
             ASSIGN v_cdempcon:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = cListAux.     

             ASSIGN vh_foco  = "15".
             
         END.
    
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

    IF  get-value("v_cdempcon") <> "" THEN
        DO:
            {&OUT} '<script> document.getElementById("v_cdempcon").value = "' +  STRING(INTE(get-value("v_cdempcon"))) + '"; </script>'.
            {&OUT} '<script> document.getElementById("v_segmento").value = "' +  STRING(INTE(get-value("v_segmento"))) + '"; </script>'.
        END.
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

