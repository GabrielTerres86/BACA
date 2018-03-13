&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
/* Procedure Description
"CECRED - Ajudante para HTML Mapping
Evandro Rafael Ochner"
*/

&ANALYZE-RESUME
/* Connected Databases 
          banco            PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD template AS CHARACTER FORMAT "X(256)":U.


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
DEFINE VARIABLE ProgramaEmUso AS CHARACTER INITIAL ["wpgdXXXX"].
DEFINE VARIABLE NmeDoPrograma AS CHARACTER INITIAL ["wpgdXXXX.w"].

DEFINE VARIABLE opcao                 AS CHARACTER.
DEFINE VARIABLE msg-erro              AS CHARACTER.
DEFINE VARIABLE msg-erro-aux          AS INTEGER.
DEFINE VARIABLE ponteiro-auxiliar     AS CHARACTER.
DEFINE VARIABLE pesquisa              AS CHARACTER.     
DEFINE VARIABLE FlagPermissoes        AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER FORMAT "x(47)".
DEFINE VARIABLE vauxsenha             AS CHARACTER FORMAT "X(16)".

DEFINE VARIABLE i                     AS INTEGER                        NO-UNDO.
DEFINE VARIABLE m-erros               AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE v-qtdeerro            AS INTEGER                        NO-UNDO.
DEFINE VARIABLE v-descricaoerro       AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE v-identificacao       AS CHARACTER                      NO-UNDO.

/*** Declaração de BOs ***/
DEFINE VARIABLE h-b1wpgdXXXX          AS HANDLE                         NO-UNDO.

/*** Temp Tables ***/
DEFINE TEMP-TABLE cratxxx             LIKE crapxxx.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE templates/template001.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS crapetp.cdeixtem crapetp.dseixtem 
&Scoped-define ENABLED-TABLES ab_unmap crapetp
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapetp
&Scoped-Define ENABLED-OBJECTS ab_unmap.template
&Scoped-Define DISPLAYED-FIELDS crapetp.cdeixtem
&Scoped-define DISPLAYED-TABLES ab_unmap crapetp
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapetp
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.template

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.template AT ROW 1 COL 1 HELP
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
          FIELD template AS CHARACTER FORMAT "X(256)":U 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 24.71
         WIDTH              = 71.4.
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
/* SETTINGS FOR fill-in ab_unmap.template IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "HTML Wizard" w-html _INLINE
/* Actions: P:/web/templates/_wizard.w ? ? ? P:/web/templates/_wizdel.p */
/* CECRED - Ajudante para HTML Mapping
Bem-vindo ao Ajudante para HTML Mapping - CECRED! O ajudante irá auxiliá-lo a criar um mapeamento de campos HTML com o banco de dados.... Pressione 'Next' para prosseguir.
P:/web/templates/_wizntro.w,P:/web/templates/_wizhtml.w,P:/web/templates/_wizds.w,P:/web/templates/_wizmap.w,P:/web/templates/_wizend.w
*/
/* _UIB-CODE-BLOCK-END */
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
    ("template":U,"ab_unmap.template":U,ab_unmap.template:HANDLE IN FRAME {&FRAME-NAME}).
END PROCEDURE.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-assign-record w-html 
PROCEDURE local-assign-record :
DEFINE INPUT PARAMETER opcao AS CHARACTER.

/* Instancia a BO para executar as procedures */
RUN dbo/b1wpgdXXXX.p PERSISTENT SET h-b1wpgdXXXX.

/* Se BO foi instanciada */
IF VALID-HANDLE(h-b1wpgdXXXX) THEN
   DO:
      DO WITH FRAME {&FRAME-NAME}:
         IF opcao = "inclusao" THEN
            DO: 
                CREATE cratxxx.
                ASSIGN cratxxx.campo = INPUT crapxxx.campo.

                RUN inclui-registro IN h-b1wpgdXXXX(INPUT TABLE cratxxx, INPUT 1, OUTPUT msg-erro).
            END.
         ELSE  /* alteracao */
            DO:
                /* cria a temp-table e joga o novo valor digitado para o campo */
                CREATE cratxxx.
                BUFFER-COPY crapxxx EXCEPT crapxxx.campox TO cratxxx.

                ASSIGN cratxxx.campo = INPUT crapxxx.campo.
                 
                RUN altera-registro IN h-b1wpgdXXXX(INPUT TABLE cratxxx, INPUT 1, OUTPUT msg-erro).
            END.    
      END. /* DO WITH FRAME {&FRAME-NAME} */
   
      /* "mata" a instância da BO */
      DELETE PROCEDURE h-b1wpgdXXXX NO-ERROR.
   
   END. /* IF VALID-HANDLE(h-b1wpgdXXXX) */
      
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-delete-record w-html 
PROCEDURE local-delete-record :

/* Instancia a BO para executar as procedures */
RUN dbo/b1wpgdXXXX.p PERSISTENT SET h-b1wpgdXXXX.
 
/* Se BO foi instanciada */
IF VALID-HANDLE(h-b1wpgdXXXX) THEN
   DO:
      CREATE cratxxx.
      BUFFER-COPY crapxxx TO cratxxx.
          
      RUN exclui-registro IN h-b1wpgdXXXX(INPUT TABLE cratxxx, INPUT 1, OUTPUT msg-erro).

      /* "mata" a instância da BO */
      DELETE PROCEDURE h-b1wpgdXXXX NO-ERROR.
   END.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-display-fields w-html 
PROCEDURE local-display-fields :
RUN displayFields.

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

  output-content-type ("text/html":U).
  
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PermissaoDeAcesso w-html 
PROCEDURE PermissaoDeAcesso :
{includes/wpgd0009.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoAnterior w-html 
PROCEDURE PosicionaNoAnterior :

/* O pre-processador {&SECOND-ENABLED-TABLE} tem como valor, o nome da tabela usada */

FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.ponteiro) NO-LOCK NO-WAIT NO-ERROR.

IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
   DO:
       FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.idevento) NO-LOCK NO-WAIT NO-ERROR.

       IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
           DO:
               ASSIGN ab_unmap.ponteiro = STRING(ROWID({&SECOND-ENABLED-TABLE})).

               FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.idevento) NO-LOCK NO-WAIT NO-ERROR.

               IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN ab_unmap.statuspos = "".
               ELSE
                   ASSIGN ab_unmap.statuspos = "".

               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.ponteiro) NO-LOCK NO-WAIT NO-ERROR.
           END.
       ELSE
           DO:
               RUN RodaJavaScript("alert('Este já é o primeiro registro.')"). 
               
               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.ponteiro) NO-LOCK NO-WAIT NO-ERROR.

               IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN ab_unmap.statuspos = "".
               ELSE
                   ASSIGN ab_unmap.statuspos = "?".

           END.
   END.
ELSE 
   RUN PosicionaNoPrimeiro.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoPrimeiro w-html 
PROCEDURE PosicionaNoPrimeiro :

FIND FIRST {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.idevento) NO-LOCK NO-WAIT NO-ERROR.


IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
    ASSIGN ab_unmap.ponteiro  = "?"
           ab_unmap.statuspos = "".
ELSE
    ASSIGN ab_unmap.ponteiro  = STRING(ROWID({&SECOND-ENABLED-TABLE}))
           ab_unmap.statuspos = "".  /* aqui p */

/* Não traz inicialmente nenhum registro */ 
RELEASE {&SECOND-ENABLED-TABLE}.

ASSIGN ab_unmap.ponteiro  = "?"
       ab_unmap.statuspos = "".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoSeguinte w-html 
PROCEDURE PosicionaNoSeguinte :

FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.ponteiro) NO-LOCK NO-WAIT NO-ERROR.


IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
    DO:
       FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.idevento) NO-LOCK NO-WAIT NO-ERROR.

       IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
           DO:
               ASSIGN ab_unmap.ponteiro = STRING(ROWID({&SECOND-ENABLED-TABLE})).

               FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.idevento) NO-LOCK NO-WAIT NO-ERROR.

               IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN ab_unmap.statuspos = "".
               ELSE
                   ASSIGN ab_unmap.statuspos = "".

               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.ponteiro) NO-LOCK NO-WAIT NO-ERROR.
           END.
       ELSE
           DO:
               RUN RodaJavaScript("alert('Este já é o último registro.')").

               FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.ponteiro) NO-LOCK NO-WAIT NO-ERROR.

               IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                   ASSIGN ab_unmap.statuspos = "".
               ELSE
                   ASSIGN ab_unmap.statuspos = "?".
           END.
    END.
ELSE
    RUN PosicionaNoUltimo.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PosicionaNoUltimo w-html 
PROCEDURE PosicionaNoUltimo :

FIND LAST {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.idevento) NO-LOCK NO-WAIT NO-ERROR.

IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
    ASSIGN ab_unmap.ponteiro = "?".
ELSE
    ASSIGN ab_unmap.ponteiro  = STRING(ROWID({&SECOND-ENABLED-TABLE}))
           ab_unmap.statuspos = "".   /* aqui u */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE process-web-request w-html 
PROCEDURE process-web-request :
/*------------------------------------------------------------------------------
   Tipo: Procedure interna
   Nome: includes/webreq.i - Versão WebSpeed 2.1
  Autor: B&T/Solusoft
 Função: Processo de requisição web p/ cadastros simples na web - Versão WebSpeed 3.0
  Notas: Este é o procedimento principal onde terá as requisições GET e POST.
         GET - É ativa quando o formulário é chamado pela 1a vez
         POST - Após o get somente ocorrerá POST no formulário      
         Caso seja necessário custimizá-lo para algum programa específico 
         Favor cópiar este procedimento para dentro do procedure process-web-requeste 
         faça lá alterações necessárias.
-------------------------------------------------------------------------------*/

v-identificacao = get-cookie("cookie-usuario-em-uso").
FIND cra-sessao WHERE cra-sessao.identificacao = v-identificacao NO-LOCK NO-ERROR.
  
ASSIGN opcao              = GET-FIELD("op")
       pesquisa           = GET-VALUE("pesq")
       FlagPermissoes     = GET-VALUE("permi")
       msg-erro-aux       = 0
       ab_unmap.idevento  = INTEGER(get-value("idevento"))
       ab_unmap.cabecalho = AppURL                        
       ab_unmap.permi     = FlagPermissoes                
       ab_unmap.ponteiro  = GET-VALUE("ponteiro")         
       ab_unmap.statuspos = GET-VALUE("statuspos").

RUN outputHeader.
   
/* método POST */
IF REQUEST_METHOD = "POST":U THEN 
   DO:
      RUN inputFields.

      /* Instancia a BO para executar as procedures */
      RUN dbo/b1wpgdXXXX.p PERSISTENT SET h-b1wpgdXXXX.

      /* Se BO foi instanciada */
      IF VALID-HANDLE(h-b1wpgdXXXX) THEN
         DO:
            RUN posiciona-registro IN h-b1wpgdXXXX(INPUT TO-ROWID(ab_unmap.ponteiro), OUTPUT msg-erro).
            DELETE PROCEDURE h-b1wpgdXXXX NO-ERROR.
         END.

      CASE opcao:
           WHEN "sa" THEN /* salvar */
                DO:
                    IF ab_unmap.statuspos = "i" THEN /* inclusao */
                        DO:
                            RUN local-assign-record ("inclusao"). 
                            IF msg-erro <> "" THEN
                               ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                            ELSE 
                               ASSIGN msg-erro-aux = 10.
                        END.  /* fim inclusao */
                    ELSE     /* alteração */ 
                        DO: 
                            FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.ponteiro) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

                            IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                               IF LOCKED {&SECOND-ENABLED-TABLE} THEN
                                  DO:
                                      ASSIGN msg-erro-aux = 1. /* registro em uso por outro usuário */  
                                      FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.ponteiro) NO-LOCK NO-WAIT NO-ERROR.
                                  END.
                               ELSE
                                  DO: 
                                      ASSIGN msg-erro-aux = 2. /* registro não existe */
                                      RUN PosicionaNoSeguinte.
                                  END.
                            ELSE
                               DO:
                                  RUN local-assign-record ("alteracao").  
                                  IF msg-erro = "" THEN
                                     ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
                                  ELSE
                                     ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                               END.     
                        END. /* fim alteração */
                END. /* fim salvar */

           WHEN "in" THEN /* inclusao */
                DO:
                    IF ab_unmap.statuspos <> "i" THEN
                       DO:
                          CLEAR FRAME {&FRAME-NAME}.
                          ASSIGN ab_unmap.statuspos = "i".
                       END.
                END. /* fim inclusao */

           WHEN "ex" THEN /* exclusao */
                DO:
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.ponteiro) NO-LOCK NO-WAIT NO-ERROR.

                    
                    /* busca o próximo registro para fazer o reposicionamento */
                    FIND NEXT {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = INTEGER(ab_unmap.idevento) NO-LOCK NO-WAIT NO-ERROR.

                    IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                       ASSIGN ponteiro-auxiliar = STRING(ROWID({&SECOND-ENABLED-TABLE})).
                    ELSE
                       DO:
                           /* nao encontrou próximo registro então procura pelo registro anterior para o reposicionamento */
                           FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.ponteiro) NO-LOCK NO-WAIT NO-ERROR.
                           
                           FIND PREV {&SECOND-ENABLED-TABLE} WHERE {&SECOND-ENABLED-TABLE}.idevento = int(ab_unmap.idevento) NO-LOCK NO-WAIT NO-ERROR.

                           IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                              ASSIGN ponteiro-auxiliar = STRING(ROWID({&SECOND-ENABLED-TABLE})).
                           ELSE
                              ASSIGN ponteiro-auxiliar = "?".
                       END.          
                       
                    /*** PROCURA TABELA PARA VALIDAR -> COM NO-LOCK ***/
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.ponteiro) NO-LOCK NO-WAIT NO-ERROR.
                    
                    /*** PROCURA TABELA PARA EXCLUIR -> COM EXCLUSIVE-LOCK ***/
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.ponteiro) EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
                    
                    IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                       IF LOCKED {&SECOND-ENABLED-TABLE} THEN
                          DO:
                              ASSIGN msg-erro-aux = 1. /* registro em uso por outro usuário */ 
                              FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.ponteiro) NO-LOCK NO-WAIT NO-ERROR.
                          END.
                       ELSE
                          ASSIGN msg-erro-aux = 2. /* registro não existe */
                    ELSE
                       DO:
                          IF msg-erro = "" THEN
                             DO:
                                RUN local-delete-record.
                                DO i = 1 TO ERROR-STATUS:NUM-MESSAGES:
                                   ASSIGN m-erros = m-erros + ERROR-STATUS:GET-MESSAGE(i).
                                END.    

                                IF m-erros = " " THEN
                                   DO:
                                       IF ponteiro-auxiliar = "?" THEN
                                          RUN PosicionaNoPrimeiro.
                                       ELSE
                                          DO:
                                              ASSIGN ab_unmap.ponteiro = ponteiro-auxiliar.
                                              FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.ponteiro) NO-LOCK NO-WAIT NO-ERROR.
                                              
                                              IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                                 RUN PosicionaNoSeguinte.
                                          END.   
                                          
                                       ASSIGN msg-erro-aux = 10. /* Solicitação realizada com sucesso */ 
                                   END.
                                ELSE
                                   ASSIGN msg-erro-aux = 4. /* Exclusao rejeitada */ 
                             END.
                          ELSE
                             ASSIGN msg-erro-aux = 3. /* erros da validação de dados */
                       END.  
                END. /* fim exclusao */

           WHEN "pe" THEN /* pesquisar */
                DO:   
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.ponteiro) NO-LOCK NO-WAIT NO-ERROR.
                    IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN 
                       RUN PosicionaNoSeguinte.
                END. /* fim pesquisar */

           WHEN "li" THEN /* listar */
                DO:
                    FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.ponteiro) NO-LOCK NO-WAIT NO-ERROR.
                    IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN 
                       RUN PosicionaNoSeguinte.
                END. /* fim listar */

           WHEN "pr" THEN /* primeiro */
                RUN PosicionaNoPrimeiro.
      
           WHEN "ul" THEN /* ultimo */
                RUN PosicionaNoUltimo.
      
           WHEN "an" THEN /* anterior */
                RUN PosicionaNoAnterior.
      
           WHEN "se" THEN /* seguinte */
                RUN PosicionaNoSeguinte.
    
      END CASE.

      IF msg-erro-aux = 10 OR (opcao <> "sa" AND opcao <> "ex" AND opcao <> "in") THEN
         RUN displayFields.
 
      RUN enableFields.
      RUN outputFields.

      CASE msg-erro-aux:
           WHEN 1 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = 'Registro esta em uso por outro usuário. Solicitação não pode ser executada. Espere alguns instantes e tente novamente.'.

                    RUN RodaJavaScript(' top.frames[0].MostraResultado(' + STRING(v-qtdeerro) + ',"'+ v-descricaoerro + '"); ').
                END.

           WHEN 2 THEN
                RUN RodaJavaScript(" top.frames[0].MostraMsg('Registro foi excluído. Solicitação não pode ser executada.')").
      
           WHEN 3 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = msg-erro.

                    RUN RodaJavaScript('top.frames[0].MostraResultado(' + STRING(v-qtdeerro) + ',"'+ v-descricaoerro + '"); ').
                END.

           WHEN 4 THEN
                DO:
                    ASSIGN v-qtdeerro      = 1
                           v-descricaoerro = m-erros.

                    RUN RodaJavaScript('top.frames[0].MostraResultado(' + STRING(v-qtdeerro) + ',"'+ v-descricaoerro + '"); ').
                END.

           WHEN 10 THEN
                RUN RodaJavaScript('alert("Atualizacao executada com sucesso.")'). 
         
      END CASE.     

      RUN RodaJavaScript('top.frames[0].ZeraOp()').   

   END. /* Fim do método POST */
ELSE /* Método GET */ 
   DO:
      RUN PermissaoDeAcesso(INPUT ProgramaEmUso, OUTPUT IdentificacaoDaSessao, OUTPUT ab_unmap.permi).

      CASE ab_unmap.permi:
           WHEN "1" THEN /* get-cookie em usuario-em-uso voltou valor nulo */
                RUN RodaJavaScript('top.close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').

           WHEN "2" THEN /* identificacao vinda do cookie bao existe na tabela de log de sessao */ 
                DO: 
                    DELETE-COOKIE("cookie-usuario-em-uso",?,?).
                    RUN RodaJavaScript('top.close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').
                END.
  
           WHEN "3" THEN /* usuario nao tem permissao para acessa o programa */
                RUN RodaJavaScript('window.location.href = "' + ab_unmap.cabecalho + '/gerenciador/negado"').
          
           OTHERWISE
                DO:
                    IF GET-VALUE("LinkRowid") <> "" THEN
                       DO:
                           FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(GET-VALUE("LinkRowid")) NO-LOCK NO-WAIT NO-ERROR.
                           
                           IF AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                              DO:
                                  ASSIGN ab_unmap.ponteiro = STRING(ROWID({&SECOND-ENABLED-TABLE}))
                                         ab_unmap.idevento = {&SECOND-ENABLED-TABLE}.idevento.

                                  FIND NEXT {&SECOND-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.

                                  IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                     ASSIGN ab_unmap.statuspos = "u".
                                  ELSE
                                     DO:
                                         FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.ponteiro) NO-LOCK NO-WAIT NO-ERROR.
                                         
                                         FIND PREV {&SECOND-ENABLED-TABLE} NO-LOCK NO-WAIT NO-ERROR.

                                         IF NOT AVAILABLE {&SECOND-ENABLED-TABLE} THEN
                                            ASSIGN ab_unmap.statuspos = "p".        
                                         ELSE
                                            ASSIGN ab_unmap.statuspos = "?".
                                     END.

                                  FIND {&SECOND-ENABLED-TABLE} WHERE ROWID({&SECOND-ENABLED-TABLE}) = TO-ROWID(ab_unmap.ponteiro) NO-LOCK NO-WAIT NO-ERROR.
                              END.  
                           ELSE
                              ASSIGN ab_unmap.ponteiro = "?"
                                     ab_unmap.statuspos = "?".
                       END.  
                    ELSE                    
                       RUN PosicionaNoPrimeiro.

                    RUN displayFields.
                    RUN enableFields.
                    RUN outputFields.
                    RUN RodaJavaScript('top.frcod.FechaZoom()').
                    RUN RodaJavaScript('CarregaPrincipal()').
                    
                    IF GET-VALUE("LinkRowid") = "" THEN
                       DO:
                           RUN RodaJavaScript('LimparCampos();').
                           RUN RodaJavaScript('top.frcod.Incluir();').
                       END.
                END. /* fim otherwise */                  
      END CASE. 
END. /* fim do método GET */

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE RodaJavaScript w-html 
PROCEDURE RodaJavaScript :

{includes/rodajava.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

