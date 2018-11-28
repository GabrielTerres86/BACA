/*..............................................................................

   Programa: siscaixa/web/crap039.w
   Sistema : Caixa On-Line
   Sigla   : CRED
   Autor   : Peter Rausch
   Data    : 19/10/2018                         Ultima atualizacao: 19/10/2018

   Dados referentes ao programa: Recebimento de tarifas
   
..............................................................................*/

&Scoped-define WINDOW-NAME CURRENT-WINDOW                             

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap     
       FIELD v_caixa           AS CHARACTER FORMAT "X(256)":U 
       FIELD v_coop            AS CHARACTER FORMAT "X(256)":U 
       FIELD v_conta           AS CHARACTER FORMAT "X(256)":U 
       FIELD v_nome            AS CHARACTER FORMAT "X(256)":U 
       FIELD v_data            AS CHARACTER FORMAT "X(256)":U 
       FIELD v_msg             AS CHARACTER FORMAT "X(256)":U 
       FIELD v_operador        AS CHARACTER FORMAT "X(256)":U 
       FIELD v_pac             AS CHARACTER FORMAT "X(256)":U

       FIELD v_tipo_tarifa     AS CHARACTER
       FIELD v_documento       AS CHARACTER FORMAT "X(256)":U
       FIELD v_cod_historico   AS CHARACTER FORMAT "X(256)":U
       FIELD v_desc_historico  AS CHARACTER FORMAT "X(256)":U
       FIELD v_hist_contabil   AS CHARACTER FORMAT "X(256)":U
       FIELD v_conta_debito    AS CHARACTER FORMAT "X(256)":U
       FIELD v_conta_credito   AS CHARACTER FORMAT "X(256)":U
       FIELD v_valor_tarifa    AS CHARACTER FORMAT "X(256)":U
       
       
       FIELD v_btn_ok          AS CHARACTER FORMAT "X(256)":U
       FIELD v_btn_cancela     AS CHARACTER FORMAT "X(256)":U.

CREATE WIDGET-POOL.

{ sistema/generico/includes/b1wgen0092tt.i }

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


DEF VAR v_digita        AS INTEGER INIT 1              NO-UNDO.
DEF VAR l-houve-erro    AS LOG                         NO-UNDO.
DEF VAR h-b1crap02      AS HANDLE                      NO-UNDO.
DEF VAR h-b1crap39      AS HANDLE                      NO-UNDO.
DEF VAR err_cdcritic    AS  CHAR                       NO-UNDO.
DEF VAR err_dscritic    AS  CHAR                       NO-UNDO.


/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE F:/web/crap039.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS   ab_unmap.v_caixa ab_unmap.v_coop ab_unmap.v_conta ab_unmap.v_nome ab_unmap.v_data ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_btn_ok ab_unmap.v_btn_cancela ab_unmap.v_tipo_tarifa ab_unmap.v_documento ab_unmap.v_cod_historico ab_unmap.v_desc_historico ab_unmap.v_hist_contabil ab_unmap.v_conta_debito ab_unmap.v_conta_credito ab_unmap.v_valor_tarifa
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.v_caixa ab_unmap.v_coop ab_unmap.v_conta ab_unmap.v_nome ab_unmap.v_data ab_unmap.v_msg ab_unmap.v_operador ab_unmap.v_pac ab_unmap.v_btn_ok ab_unmap.v_btn_cancela ab_unmap.v_tipo_tarifa ab_unmap.v_documento ab_unmap.v_cod_historico ab_unmap.v_desc_historico ab_unmap.v_hist_contabil ab_unmap.v_conta_debito ab_unmap.v_conta_credito ab_unmap.v_valor_tarifa


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame    
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
     ab_unmap.v_btn_ok AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_btn_cancela AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_tipo_tarifa AT ROW 1 COL 1 HELP
          "" NO-LABEL
          VIEW-AS SELECTION-LIST SINGLE NO-DRAG 
          SIZE 20 BY 4
     ab_unmap.v_documento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1    
     ab_unmap.v_cod_historico AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1    
     ab_unmap.v_desc_historico AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1    
     ab_unmap.v_hist_contabil AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     ab_unmap.v_conta_debito AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1    
     ab_unmap.v_conta_credito AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1    
     ab_unmap.v_valor_tarifa AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1    
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 80 BY 20.


/* *********************** Procedure Settings ************************ */

/* *************************  Create Window  ************************** */

/* *********************** Included-Libraries ************************* */

{src/web2/html-map.i}

/* ************************  Main Code Block  ************************* */

{src/web2/template/hmapmain.i}


/* **********************  Internal Procedures  *********************** */

PROCEDURE adm-create-objects :
  /*------------------------------------------------------------------------------
    Purpose:     Create handles for all SmartObjects used in this procedure.
                After SmartObjects are initialized, then SmartLinks are added.
    Parameters:  <none>
  ------------------------------------------------------------------------------*/

END PROCEDURE.

PROCEDURE htmOffsets :
  /*------------------------------------------------------------------------------
    Purpose:     Runs procedure to associate each HTML field with its
                corresponding widget name and handle.
    Parameters:  
    Notes:       
  ------------------------------------------------------------------------------*/
  RUN readOffsets ("{&WEB-FILE}":U).  
  RUN htmAssociate
    ("v_caixa":U,"ab_unmap.v_caixa":U,ab_unmap.v_caixa:HANDLE IN FRAME {&FRAME-NAME}).
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
    ("v_btn_ok":U,"ab_unmap.v_btn_ok":U,ab_unmap.v_btn_ok:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_btn_cancela":U,"ab_unmap.v_btn_cancela":U,ab_unmap.v_btn_cancela:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_tipo_tarifa":U,"ab_unmap.v_tipo_tarifa":U,ab_unmap.v_tipo_tarifa:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_documento":U,"ab_unmap.v_documento":U,ab_unmap.v_documento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_cod_historico":U,"ab_unmap.v_cod_historico":U,ab_unmap.v_cod_historico:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_desc_historico":U,"ab_unmap.v_desc_historico":U,ab_unmap.v_desc_historico:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_hist_contabil":U,"ab_unmap.v_hist_contabil":U,ab_unmap.v_hist_contabil:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_conta_debito":U,"ab_unmap.v_conta_debito":U,ab_unmap.v_conta_debito:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_conta_credito":U,"ab_unmap.v_conta_credito":U,ab_unmap.v_conta_credito:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("v_valor_tarifa":U,"ab_unmap.v_valor_tarifa":U,ab_unmap.v_valor_tarifa:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.


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

PROCEDURE process-web-request :
  /*------------------------------------------------------------------------
    Purpose:     Process the web request.
    Notes:       
  ------------------------------------------------------------------------*/
   
  RUN outputHeader.

  {include/i-global.i}

  ASSIGN v_tipo_tarifa:LIST-ITEM-PAIRS IN FRAME {&FRAME-NAME} = ',0,' +
                                                             'Exclusao CCF,1'.

  IF REQUEST_METHOD = "POST":U THEN 
  DO:

    RUN inputFields.
    RUN findRecords.
    
    {include/assignfields.i} 

    // <CARREGAR CONTA DO COOPERADO>
    IF int(v_conta) > 0 AND l-houve-erro = FALSE THEN 
    DO:
      RUN dbo/b1crap02.p PERSISTENT SET h-b1crap02.
      RUN consulta-conta IN h-b1crap02 (INPUT v_coop,
                                        INPUT INT(v_pac),
                                        INPUT INT(v_caixa),
                                        INPUT INT(v_conta),
                                        OUTPUT TABLE tt-conta).
      DELETE PROCEDURE h-b1crap02.
      
      IF RETURN-VALUE = "NOK" THEN 
      DO:
        {include/i-erro.i}
        ASSIGN v_nome  = "".
      END.
      ELSE 
      DO:
        FIND FIRST tt-conta NO-LOCK NO-ERROR.
        IF AVAIL tt-conta THEN
        DO:
          ASSIGN v_nome = tt-conta.nome-tit.
        END.
      END.
    END.
    // </CARREGAR CONTA DO COOPERADO>


    IF int(v_conta) > 0 AND int(v_tipo_tarifa) > 0 AND l-houve-erro = FALSE THEN
    DO:

      RUN dbo/b1crap39.p PERSISTENT SET h-b1crap39.
      RUN retorna-tarifa IN h-b1crap39 (INPUT int(v_coop),
                                        INPUT "EXCLUCCFPF",
                                        INPUT "CRAP039",
                                        OUTPUT v_cod_historico,
                                        OUTPUT v_valor_tarifa,
                                        OUTPUT err_cdcritic,
                                        OUTPUT err_dscritic).

      DELETE PROCEDURE h-b1crap39.

      IF  RETURN-VALUE = "NOK" THEN DO:
         ASSIGN  v_cod_historico = ""
                 v_valor_tarifa = ""
                 v_msg = "Erro ao buscar dados da tarifa."
                 l-houve-erro = TRUE.
        
        {include/i-erro.i}
      END.  
      
      RUN dbo/b1crap39.p PERSISTENT SET h-b1crap39.
      RUN retorna-valor-historico IN h-b1crap39 ( INPUT v_coop,
                                                  INPUT int(v_pac),
                                                  INPUT int(v_cod_historico),
                                                  OUTPUT v_conta_credito,
                                                  OUTPUT v_conta_debito,
                                                  OUTPUT v_hist_contabil,
                                                  OUTPUT v_digita,
                                                  OUTPUT v_desc_historico ).
      DELETE PROCEDURE h-b1crap39.

      IF  RETURN-VALUE = "NOK" THEN DO:
        ASSIGN  v_cod_historico = ""
                v_msg = "Erro ao encontrar histórico."
                l-houve-erro = TRUE.
        
        {include/i-erro.i}
      END.  
    END.


    RUN displayFields. 
    RUN enableFields.
    RUN outputFields.
  END.
  ELSE 
  DO:

    RUN findRecords.
    RUN displayFields.
    RUN enableFields.
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

// TODO: b2crap14.p tem funções sobre retorno de valor e lançamento de tarifas.