/* .............................................................................

   Programa: siscaixa/web/crap053.w
   Sistema : Caixa On-line
   Sigla   : CRED   
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 28/10/2015.

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Pagto de Cheque 

   Alteracoes: 26/08/2005 - Tratamentos para unificacao dos bancos, passar
                            codigo da cooperativa como parametro para as 
                            procedure (Julio)

               13/03/2006 - Acrescentada leitura do campo cdcooper as tabelas
                            (Diego).  
               
               25/10/2006 - Controle para exclusao das instancias das BO's
                            (Evandro).
                            
               18/12/2009 - Adicionado numero do lote na chamada da rotina
                            crap051f.w (Fernando).    
                            
               04/05/2010 - Adicionado parametro flgrebcc na chamada da rotina
                            crap051f (Fernando).   
                            
               05/11/2010 - Chama procedure atualiza-previa-caixa para 
                            verificar se caixa deve fazer previa dos cheques 
                            (Elton).
                            
               24/12/2010 - Tratamento para cheques de contas migradas 
                            (Guilherme).
                            
               14/01/2011 - Comentada as chamadas da procedure 
                            atualiza-previa-caixa (Elton).             
               
               13/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)
               
               28/10/2015 - #318705 Retirado o parametro p-flgdebcc (Carlos)
............................................................................ */

&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD vh_foco AS CHARACTER FORMAT "X(256)":U 
       FIELD v_caixa AS CHARACTER FORMAT "X(256)":U 
       FIELD v_cmc7 AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
       FIELD v_valor AS CHARACTER FORMAT "X(256)":U .


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
DEFINE VARIABLE h-b1crap53 AS HANDLE     NO-UNDO.
 
DEF VAR p-programa       AS CHAR INITIAL "CRAP053".
DEF VAR p-flgdebcc       AS LOGI INITIAL FALSE.
DEF var p-cdcmpchq       AS INT     FORMAT "zz9".               /* Comp */            
DEF VAR p-cdbanchq       AS INT     FORMAT "zz9".               /* Banco */
DEF var p-cdagechq       AS INT     FORMAT "zzz9".              /* Agencia */
DEF var p-nrddigc1       AS INT     FORMAT "9".                 /* C1 */
DEF var p-nrctabdb       AS DEC     FORMAT "zzz,zzz,zzz,9".     /* Conta */
DEF var p-nrddigc2       AS INT     FORMAT "9".                 /* C2 */
DEF var p-nrcheque       AS INT     FORMAT "zzz,zz9".           /* Cheque */
DEF var p-nrddigc3       AS INT     FORMAT "9".                  /* C3 */

DEF VAR p-mensagem AS CHAR NO-UNDO.
DEF VAR p-valor-disponivel AS DEC NO-UNDO.
DEF VAR p-flg-cta-migrada AS LOG NO-UNDO.
DEF VAR p-coop-migrada AS CHAR NO-UNDO.
DEF VAR p-flg-coop-host AS LOG NO-UNDO.
DEF VAR p-nro-conta-nova AS INT NO-UNDO.

DEF VAR p-mensagem1 AS CHAR NO-UNDO.
DEF VAR p-mensagem2 AS CHAR NO-UNDO.

DEF VAR p-aux-indevchq   AS INTE NO-UNDO.
DEF VAR p-nrdocmto       AS INTE NO-UNDO.
DEF VAR p-nrdolote       AS INTE NO-UNDO.
DEF VAR p-conta-atualiza AS INTE no-undo.


DEF VAR p-histor         AS INTE NO-UNDO.

DEF VAR p-literal        AS CHAR  NO-UNDO.
DEF VAR p-ult-sequencia  AS INTE  NO-UNDO.


DEF VAR l-houve-erro    AS LOG          NO-UNDO.

DEF TEMP-TABLE w-craperr  NO-UNDO
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

&Scoped-define WEB-FILE crap053.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_cmc7 ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_valor 
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.vh_foco ab_unmap.v_caixa ab_unmap.v_cmc7 ab_unmap.v_coop ab_unmap.v_data ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_valor 

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
     ab_unmap.v_valor AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 52.2 BY 14.1.


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
          FIELD v_coop AS CHARACTER FORMAT "X(256)":U 
          FIELD v_data AS CHARACTER FORMAT "X(256)":U 
          FIELD v_msg AS CHARACTER FORMAT "X(256)":U 
          FIELD v_operador AS CHARACTER FORMAT "X(256)":U 
          FIELD v_pac AS CHARACTER FORMAT "X(256)":U 
          FIELD v_valor AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 14.1
         WIDTH              = 52.2.
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
/* SETTINGS FOR FILL-IN ab_unmap.v_caixa IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_cmc7 IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_coop IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_data IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_msg IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_operador IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_pac IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.v_valor IN FRAME Web-Frame
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
    ("v_coop":U,"ab_unmap.v_coop":U,ab_unmap.v_coop:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_data":U,"ab_unmap.v_data":U,ab_unmap.v_data:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_msg":U,"ab_unmap.v_msg":U,ab_unmap.v_msg:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_operador":U,"ab_unmap.v_operador":U,ab_unmap.v_operador:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_pac":U,"ab_unmap.v_pac":U,ab_unmap.v_pac:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_valor":U,"ab_unmap.v_valor":U,ab_unmap.v_valor:HANDLE IN FRAME {&FRAME-NAME}).
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
         *     setAddMode(TRUE).   
         * RUN assignFields. */
        {include/assignfields.i}


        RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
        RUN valida-transacao IN h-b1crap00(INPUT v_coop,
                                           INPUT v_pac, INPUT v_caixa).
        DELETE PROCEDURE h-b1crap00.

        IF RETURN-VALUE = "NOK" THEN DO:
            {include/i-erro.i}
        END.
        ELSE DO:

            RUN dbo/b1crap00.p PERSISTENT SET h-b1crap00.
            RUN verifica-abertura-boletim IN h-b1crap00(INPUT v_coop,
                                                        INPUT inte(v_pac),
                                                        INPUT inte(v_caixa),
                                                        INPUT v_operador).
            DELETE PROCEDURE h-b1crap00.

            IF RETURN-VALUE = "NOK" THEN DO:
                {include/i-erro.i}
            END.
            ELSE DO:    
                IF get-value("cancela") <> "" THEN DO:
                    ASSIGN v_valor = ""
                           v_cmc7  = ""
                           v_msg   = ""
                           vh_foco = "7".
                END.
                ELSE DO:

                    IF get-value("manual") <> "" THEN DO:
                        RUN dbo/b1crap53.p PERSISTENT SET h-b1crap53.
                        RUN critica-valor IN h-b1crap53(INPUT v_coop,
                                                        INPUT INT(v_pac),
                                                        INPUT INT(v_caixa),
                                                        INPUT DEC(v_valor)).
                        DELETE PROCEDURE h-b1crap53.
                        
                        IF RETURN-VALUE = "NOK" THEN DO:
                            {include/i-erro.i}
                        END.
                        ELSE DO:
                            /*********** Comentado 14/01/2011 ********
                            /** Verifica se faz previa dos cheques **/
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
                                      *******************/

                            {&OUT}
                            '<script>window.location = "crap053a.w?v_valor=" + "'get-value("v_valor")'"</script>'.
                        END.
                    END.
                    ELSE DO:
                        RUN dbo/b1crap53.p PERSISTENT SET h-b1crap53.
                        RUN critica-codigo-cheque-valor
                               IN h-b1crap53(INPUT v_coop,
                                             INPUT INT(v_pac),
                                             INPUT INT(v_caixa),
                                             INPUT v_cmc7,
                                             INPUT DEC(v_valor)).
                        DELETE PROCEDURE h-b1crap53.

                        IF RETURN-VALUE = "NOK" THEN DO:
                            ASSIGN v_cmc7 = "".
                            ASSIGN vh_foco = "8".
                            {include/i-erro.i}
                        END.
                        ELSE DO:
                            RUN dbo/b1crap53.p PERSISTENT SET h-b1crap53.
                            RUN valida-codigo-cheque 
                                   IN h-b1crap53(INPUT v_coop,
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
                            DELETE PROCEDURE h-b1crap53.

                            IF RETURN-VALUE = "NOK" THEN DO:
                                ASSIGN vh_foco = "8".
                                {include/i-erro.i}
                            END.
                            ELSE DO:
                                RUN dbo/b1crap53.p PERSISTENT SET h-b1crap53.
                                RUN valida-pagto-cheque
                                          IN h-b1crap53
                                               (INPUT v_coop,      
                                                INPUT INT(v_pac),
                                                INPUT INT(v_caixa),
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
                                                INPUT DEC(v_valor),
                                                OUTPUT p-mensagem1,
                                                OUTPUT p-mensagem2,
                                                OUTPUT p-aux-indevchq, 
                                                OUTPUT p-nrdocmto,
                                                OUTPUT p-conta-atualiza,
                                                OUTPUT p-mensagem,
                                                OUTPUT p-valor-disponivel,
                                                OUTPUT p-flg-cta-migrada,
                                                OUTPUT p-coop-migrada,
                                                OUTPUT p-flg-coop-host,
                                                OUTPUT p-nro-conta-nova).

                                DELETE PROCEDURE h-b1crap53.
                                
                                IF RETURN-VALUE = "NOK" THEN DO:
                                    ASSIGN vh_foco = "8".
                                    {include/i-erro.i}
                                END.
                                ELSE DO:
                                    
                                    IF TRIM(p-mensagem1) = '' AND
                                       TRIM(p-mensagem2) = '' AND
                                       TRIM(p-mensagem)  = '' THEN DO:

                                        ASSIGN l-houve-erro = NO.

                                        DO TRANSACTION ON ERROR UNDO:

                                      RUN dbo/b1crap53.p 
                                          PERSISTENT SET h-b1crap53.

                                      IF  NOT p-flg-cta-migrada  THEN
                                      RUN atualiza-pagto-cheque 
                                                IN h-b1crap53
                                                   (INPUT v_coop,
                                                    INPUT INT(v_pac),
                                                    INPUT INT(v_caixa),
                                                    INPUT v_operador,
                                                    INPUT " ",
                                                    INPUT DEC(p-nrctabdb),
                                                    INPUT INT(p-nrcheque),
                                                    INPUT INT(p-nrddigc3),
                                                    INPUT DEC(v_valor),
                                                    INPUT p-aux-indevchq,
                                                    INPUT p-nrdocmto,
                                                    INPUT p-conta-atualiza,
                                                    INPUT p-cdbanchq,       
                                                    INPUT p-cdagechq,       
                                                    OUTPUT p-histor,  
                                                    OUTPUT p-literal,
                                                    OUTPUT p-ult-sequencia).
                                      ELSE
                                      DO:
                                          IF  NOT p-flg-coop-host  THEN
                                              RUN atualiza-pagto-cheque-migrado
                                                  IN h-b1crap53(INPUT v_coop,
                                                      INPUT p-coop-migrada,
                                                      INPUT INT(v_pac),
                                                      INPUT INT(v_caixa),
                                                      INPUT v_operador,
                                                      INPUT " ",
                                                      INPUT DEC(p-nrctabdb),
                                                      INPUT INT(p-nrcheque),
                                                      INPUT INT(p-nrddigc3),
                                                      INPUT DEC(v_valor),
                                                      INPUT p-aux-indevchq,
                                                      INPUT p-nrdocmto,
                                                      INPUT p-conta-atualiza,
                                                      INPUT p-cdbanchq,       
                                                      INPUT p-cdagechq,       
                                                      INPUT p-nro-conta-nova,
                                                      OUTPUT p-histor,  
                                                      OUTPUT p-literal,
                                                      OUTPUT p-ult-sequencia).
                                          ELSE
                                              RUN atualiza-pagto-cheque-migrado-host
                                                  IN h-b1crap53
                                                     (INPUT v_coop,
                                                      INPUT p-coop-migrada,
                                                      INPUT INT(v_pac),
                                                      INPUT INT(v_caixa),
                                                      INPUT v_operador,
                                                      INPUT " ",
                                                      INPUT DEC(p-nrctabdb),
                                                      INPUT INT(p-nrcheque),
                                                      INPUT INT(p-nrddigc3),
                                                      INPUT DEC(v_valor),
                                                      INPUT p-aux-indevchq,
                                                      INPUT p-nrdocmto,
                                                      INPUT p-conta-atualiza,
                                                      INPUT p-cdbanchq,       
                                                      INPUT p-cdagechq,       
                                                      INPUT p-nro-conta-nova,
                                                      OUTPUT p-histor,  
                                                      OUTPUT p-literal,
                                                      OUTPUT p-ult-sequencia).
                                              
                                      END.

                                      DELETE PROCEDURE h-b1crap53.
                                         

                                            IF RETURN-VALUE = "NOK" THEN DO:
                                                ASSIGN l-houve-erro = YES.
                                                FOR EACH w-craperr:
                                                    DELETE w-craperr.
                                                END.
                                                FOR EACH craperr NO-LOCK WHERE
                                                          craperr.cdcooper = 
                                                           crapcop.cdcooper AND
                                                          craperr.cdagenci = 
                                                           INT(v_pac)       AND
                                                          craperr.nrdcaixa =  
                                                          INT(v_caixa):

                                                   CREATE w-craperr.
                                                   ASSIGN  w-craperr.cdcooper =
                                                             craperr.cdcooper
                                                           w-craperr.cdagenci =
                                                             craperr.cdagenc
                                                           w-craperr.nrdcaixa =
                                                             craperr.nrdcaixa
                                                           w-craperr.nrsequen =
                                                             craperr.nrsequen
                                                           w-craperr.cdcritic =
                                                             craperr.cdcritic
                                                           w-craperr.dscritic =
                                                             craperr.dscritic
                                                           w-craperr.erro     =
                                                             craperr.erro.
                                                END.
                                                UNDO.
                                            END.
                                        END.   /* do transaction */

                                        IF l-houve-erro = YES  THEN DO:
                                            FOR EACH w-craperr NO-LOCK:
                                                CREATE craperr.
                                                ASSIGN craperr.cdcooper = 
                                                            w-craperr.cdcooper
                                                       craperr.cdagenci = 
                                                            w-craperr.cdagenc
                                                       craperr.nrdcaixa = 
                                                            w-craperr.nrdcaixa
                                                       craperr.nrsequen = 
                                                            w-craperr.nrsequen
                                                       craperr.cdcritic = 
                                                            w-craperr.cdcritic
                                                       craperr.dscritic = 
                                                            w-craperr.dscritic
                                                       craperr.erro     = 
                                                            w-craperr.erro.
                                                VALIDATE craperr.
                                            END.
                                            {include/i-erro.i}
                                        END.
                                          
                                        /**********  Comentado 14/01/2011 *****************
                                        /******Verifica se faz previa dos cheques *****/
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
                                        **********/

                                        IF l-houve-erro = NO THEN do:  
                                            {&OUT}
                                                '<script>window.open("autentica.html?v_plit=" + "' p-literal '" + 
                                                "&v_pseq=" + "' p-ult-sequencia '" + "&v_prec=" + "NO"  + "&v_psetcook=" + "yes","waut","width=250,height=145,scrollbars=auto,alwaysRaised=true")
                                                </script>'.


                                             /* Se o cheque for de uma conta migrada e estiver pagando na 
                                                cooperativa geradora do cheque, nao gerar crapcme 
                                                Guilherme/Magui/Mirtes - Migracao PAC Jan/2010 */
                                             IF  p-flg-cta-migrada  AND
                                                 p-flg-coop-host    THEN
                                             DO:
                                             END.
                                             ELSE
                                             DO:
                                             /*** Incluido por Magui 19/08/2003 ***/
                                             IF   DEC(v_valor) <> 0   THEN
                                                  DO:
                                          
                                                      FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND 
                                                                         craptab.nmsistem = "CRED"            AND
                                                                         craptab.tptabela = "GENERI"          AND
                                                                         craptab.cdempres = 0                 AND
                                                                         craptab.cdacesso = "VLCTRMVESP"      AND
                                                                         craptab.tpregist = 0   NO-LOCK NO-ERROR.
                                                      IF   AVAILABLE craptab   THEN             
                                                           DO:
                                                               IF  DEC(v_valor) >= DEC(craptab.dstextab)   THEN
                                                                   DO:
                                                                       ASSIGN p-nrdolote = 11000 + INT(v_caixa).

                                                                       {&OUT}
                                                                       '<script> window.location=
                                                                       "crap051f.w?v_pconta=' + STRING(p-nrctabdb) '" + 
                                                                       "&v_pvalor=" + "' get-value("v_valor") '" +
                                                                       "&v_pnrdocmto=" + "' p-nrdocmto '" +
                                                                       "&v_pult_sequencia=" + "' p-ult-sequencia '" +
                                                                       "&v_pconta_base=" + "' STRING(p-conta-atualiza) '" +
                                                                       "&v_nrdolote=" + "' STRING(p-nrdolote) '" +
                                                                       "&v_pprograma=" + "' p-programa '" </script>'.
                                            
                                                                   END.
                                                           END.
                                                  END.         
                                            /********************************/
                                            END.
                                            {&OUT}
                                                '<script>window.location = "crap053.html"
                                                </script>'.
                                        END.


                                    END. /* p-mensagem = " " */

                                    ELSE DO:

                                        /**********  Comentado 14/01/2011 *****************
                                        /******Verifica se faz previa dos cheques *****/
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

                                        ***********************/

                                        {&OUT}
                                            '<script>window.location = "crap053b.w?v_valor=" + "'get-value("v_valor")'" + "&v_cmc7=" + "'get-value("v_cmc7")'" 
                                            + "&v_cdcmpchq=" + "' p-cdcmpchq '"
                                            + "&v_cdbanchq=" + "' p-cdbanchq '"
                                            + "&v_cdagechq=" + "' p-cdagechq '"
                                            + "&v_nrddigc1=" + "' p-nrddigc1 '"
                                            + "&v_nrctabdb=" + "' p-nrctabdb '"
                                            + "&v_nrddigc2=" + "' p-nrddigc2 '"
                                            + "&v_nrcheque=" + "' p-nrcheque '"
                                            + "&v_nrddigc3=" + "' p-nrddigc3 '"
                                            + "&p-mensagem=" + "' p-mensagem '"
                                            + "&p-mensagem1=" + "' p-mensagem1 '"
                                            + "&p-mensagem2="  + "' p-mensagem2 '"
                                            + "&p-valor-disponivel="  + "' p-valor-disponivel '"
                                            </script>'.

                                    END.

                                END.
                            END.
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
        ASSIGN vh_foco = "7".
        RUN displayFields.

        /* STEP 2b -
         * Enable objects that should be enabled. */
        RUN enableFields.

        /* STEP 2c -
         * OUTPUT the Progress from buffer to the WEB stream. */
        RUN outputFields.
    END.

    /* Show error messages. */
    IF AnyMessage() THEN DO:
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

