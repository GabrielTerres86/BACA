/*...............................................................................
  
  Programa : Fontes/wpgd0051.w
  Autor    : David Kruger
  Data     : Abril/2013 
  OBJ      : Gera arquivo referente a participacoes de quadro social. 
                    
                    
  Ultima Atualizacao: 16/07/2014 - Segmentado por PA o relatorio 
                                   quadrosocial.lst, que é gerado na procedure 
                                   GeraRelatorio. (Chamado 176752) - (Fabricio)
                                   
                      04/02/2015 - Alterado busca da agencia na rotina das 
                                   Assembleias para buscar do crapidp.cdageins 
                                   pois as vezes o cdagenci do crapidp não está 
                                   cadastrada (Lucas R. #232389)

...............................................................................*/


&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD aux_agenda  AS CHAR 
       FIELD aux_dtfinal AS CHAR       FORMAT "X(256)":U
       FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
       FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U.

DEF TEMP-TABLE tt-progrid NO-UNDO
      FIELD cdcooper AS INTE
      FIELD dtanoage AS INTE FORMAT "9999"
      FIELD nrdconta AS INTE
      FIELD idseqttl AS INTE
      FIELD nmrescop LIKE crapcop.nmrescop.

DEF TEMP-TABLE tt-progrid-pa NO-UNDO
    FIELD cdcooper AS INTE
    FIELD cdagenci AS INTE
    FIELD nmresage AS CHAR
    FIELD dtanoage AS INTE FORMAT "9999"
    FIELD nrdconta AS INTE
    FIELD idseqttl AS INTE.

DEF TEMP-TABLE tt-pa-por-coop NO-UNDO
    FIELD cdcooper AS INTE
    FIELD menorpac AS INTE
    FIELD maiorpac AS INTE.

DEF STREAM str_1.


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
DEFINE VARIABLE ProgramaEmUso AS CHARACTER INITIAL ["wpgd0051"].
DEFINE VARIABLE NmeDoPrograma AS CHARACTER INITIAL ["wpgd0051.w"].

DEFINE VARIABLE opcao                 AS CHARACTER.
DEFINE VARIABLE msg-erro              AS CHARACTER.
DEFINE VARIABLE msg-erro-aux          AS INTEGER.
DEFINE VARIABLE aux_nrdrowid-auxiliar AS CHARACTER.
DEFINE VARIABLE pesquisa              AS CHARACTER.     
DEFINE VARIABLE FlagPermissoes        AS CHARACTER.
DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER FORMAT "x(47)".
DEFINE VARIABLE vauxsenha             AS CHARACTER FORMAT "X(16)".

DEFINE VARIABLE i                     AS INTEGER                        NO-UNDO.
DEFINE VARIABLE m-erros               AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE v-qtdeerro            AS INTEGER                        NO-UNDO.
DEFINE VARIABLE v-descricaoerro       AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE v-identificacao       AS CHARACTER                      NO-UNDO.


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0051.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ab_unmap.aux_agenda ab_unmap.aux_dtfinal ab_unmap.aux_idevento ab_unmap.aux_dsendurl ab_unmap.aux_lspermis 

&Scoped-Define DISPLAYED-OBJECTS ab_unmap.aux_agenda ab_unmap.aux_dtfinal ab_unmap.aux_idevento ab_unmap.aux_dsendurl ab_unmap.aux_lspermis 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.aux_agenda AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1

     ab_unmap.aux_dtfinal AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1

     ab_unmap.aux_idevento AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
  
     ab_unmap.aux_dsendurl AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    
     ab_unmap.aux_lspermis AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "X(256)":U
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
   
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 47 BY 24.71.


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
          FIELD aux_cdcooper AS CHARACTER 
          FIELD aux_detalhar AS LOGICAL  INITIAL no
          FIELD aux_dsendurl AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_dtanoage AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_idevento AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_lspermis AS CHARACTER FORMAT "X(256)":U 
          FIELD aux_tprelato AS CHARACTER 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 24.71
         WIDTH              = 47.
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
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_cdcooper IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR TOGGLE-BOX ab_unmap.aux_detalhar IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dsendurl IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_dtanoage IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_idevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR FILL-IN ab_unmap.aux_lspermis IN FRAME Web-Frame
   ALIGN-L EXP-LABEL EXP-FORMAT EXP-HELP                                */
/* SETTINGS FOR SELECTION-LIST ab_unmap.aux_tprelato IN FRAME Web-Frame
   EXP-LABEL EXP-FORMAT EXP-HELP                                        */
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
    ("aux_agenda":U,"ab_unmap.aux_agenda":U,ab_unmap.aux_agenda:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dtfinal":U,"ab_unmap.aux_dtfinal":U,ab_unmap.aux_dtfinal:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_dsendurl":U,"ab_unmap.aux_dsendurl":U,ab_unmap.aux_dsendurl:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_idevento":U,"ab_unmap.aux_idevento":U,ab_unmap.aux_idevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("aux_lspermis":U,"ab_unmap.aux_lspermis":U,ab_unmap.aux_lspermis:HANDLE IN FRAME {&FRAME-NAME}).
 
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

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + v-identificacao + "*" NO-LOCK:
    LEAVE.
END.
  
ASSIGN opcao                    = GET-FIELD("aux_cddopcao")
       FlagPermissoes           = GET-VALUE("aux_lspermis")
       msg-erro-aux             = 0
       ab_unmap.aux_idevento    = GET-VALUE("aux_idevento")
       ab_unmap.aux_dsendurl    = AppURL                        
       ab_unmap.aux_lspermis    = FlagPermissoes
       ab_unmap.aux_agenda    = GET-VALUE("aux_agenda")
       ab_unmap.aux_dtfinal   = GET-VALUE("aux_dtfinal").

RUN outputHeader.

/* Posiciona por DEFAULT, na agenda atual */
IF ab_unmap.aux_agenda = ""   THEN
   DO:
      FIND LAST gnpapgd NO-LOCK NO-ERROR.

      IF AVAILABLE gnpapgd THEN
         ab_unmap.aux_agenda = STRING(gnpapgd.dtanoage).
       
   END.

   
/* método POST */
IF REQUEST_METHOD = "POST":U THEN 
   DO:
      RUN inputFields.

      RUN GeraRelatorio.

      RUN displayFields.
      RUN enableFields.
      RUN RodaJavaScript("alert('Arquivo quadrosocial.lst gerado com sucesso. Verifique no L:~/Cecred');").
      RUN outputFields.
   END. /* Fim do método POST */

ELSE /* Método GET */ 
   DO:
      RUN PermissaoDeAcesso(INPUT ProgramaEmUso, OUTPUT IdentificacaoDaSessao, OUTPUT ab_unmap.aux_lspermis).

      CASE ab_unmap.aux_lspermis:
           WHEN "1" THEN /* get-cookie em usuario-em-uso voltou valor nulo */
                RUN RodaJavaScript('top.close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').

           WHEN "2" THEN /* identificacao vinda do cookie bao existe na tabela de log de sessao */ 
                DO: 
                    DELETE-COOKIE("cookie-usuario-em-uso",?,?).
                    RUN RodaJavaScript('top.close(); window.open("falha","janela_principal","toolbar=yes,location=yes,diretories=no,status=yes,menubar=yes,scrollbars=yes,resizable=yes"); ').
                END.
  
           WHEN "3" THEN /* usuario nao tem permissao para acessa o programa */
                RUN RodaJavaScript('window.location.href = "' + ab_unmap.aux_dsendurl + '/gerenciador/negado"').
          
           OTHERWISE
                DO:
                    RUN displayFields.
                    RUN enableFields.
                    RUN outputFields.
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


/* Procedure que gera relatorio participacoes quadro social */
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE GeraRelatorio w-html 
PROCEDURE GeraRelatorio :


  DEF VAR aux_qtdeprgd AS INTE.
  DEF VAR aux_qtdassoc AS INTE.
  DEF VAR aux_percprgd AS DECI.
  DEF VAR aux_indicador AS CHAR FORMAT "X(36)".
  DEF VAR aux_mes       AS CHAR FORMAT "X(10)".
  DEF VAR aux_data      AS DATE.
  DEF VAR tot_particip AS INTE.
  DEF VAR tot_qtdassoc AS INTE.
  DEF VAR tot_percent  AS DECI.

  DEF VAR aux_dsagenci AS CHAR          NO-UNDO.
  DEF VAR aux_menorpac AS INTE INIT 999 NO-UNDO.
  DEF VAR aux_maiorpac AS INTE          NO-UNDO.
  DEF VAR aux_contador AS INTE          NO-UNDO.

  DEF VAR aux_nmmesano AS CHAR EXTENT 12
      INIT ["janeiro","fevereiro","março","abril","maio","junho",
            "julho","agosto","setembro","outubro","novembro","dezembro"].

  FORM tt-progrid.nmrescop FORMAT "x(25)" ";"
       tt-progrid.dtanoage ";"
       aux_mes             ";"
       aux_qtdeprgd        ";"
       aux_qtdassoc        ";"
       aux_indicador       ";"
       aux_percprgd        ";"
       WITH WIDTH 262 NO-BOX NO-LABELS FRAME f_social.

  OUTPUT STREAM str_1 TO "/micros/cecred/quadrosocial.lst".
                                      
  
  PUT STREAM str_1 "PARTICIPACOES QUADRO SOCIAL" SKIP.

  PUT STREAM str_1 "Cooperativa;Ano;Mes;Participacoes;Associados;Indicador;Perc.(%);".  
  

  FOR EACH crapcop NO-LOCK :

       ASSIGN aux_menorpac = 999
              aux_maiorpac = 0.
  
       /* Pega o ano de resposta dos questionarios */
       FOR EACH crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                              YEAR(crapass.dtdevqst) = INT(ab_unmap.aux_agenda)
                              NO-LOCK:

           FIND crapage WHERE crapage.cdcooper = crapass.cdcooper AND
                              crapage.cdagenci = crapass.cdagenci 
                              NO-LOCK NO-ERROR.

           IF AVAIL crapage THEN
           DO:
               CREATE tt-progrid.
               ASSIGN tt-progrid.cdcooper = crapass.cdcooper
                      tt-progrid.dtanoage = year(crapass.dtdevqst)
                      tt-progrid.nrdconta = crapass.nrdconta
                      tt-progrid.idseqttl = 1
                      tt-progrid.nmrescop = crapcop.nmrescop.

               CREATE tt-progrid-pa.
               ASSIGN tt-progrid-pa.cdcooper = crapass.cdcooper
                      tt-progrid-pa.cdagenci = crapage.cdagenci
                      tt-progrid-pa.nmresage = crapage.nmresage
                      tt-progrid-pa.dtanoage = year(crapass.dtdevqst)
                      tt-progrid-pa.nrdconta = crapass.nrdconta
                      tt-progrid-pa.idseqttl = 1.

               IF aux_menorpac > crapage.cdagenci THEN
                   ASSIGN aux_menorpac = crapage.cdagenci.

               IF aux_maiorpac < crapage.cdagenci THEN
                   ASSIGN aux_maiorpac = crapage.cdagenci.
           END.
           
       END.
       
       /*Pega participacao dos cooperados*/     
       FOR EACH  crapadp  WHERE 
                          crapadp.idevento = 1                AND 
                          crapadp.cdcooper = crapcop.cdcooper AND
                          crapadp.dtanoage = INT(ab_unmap.aux_agenda) AND
                          crapadp.dtfineve <= TODAY           AND
                          crapadp.idstaeve <> 2 NO-LOCK,
           EACH crapedp WHERE  crapedp.idevento = crapadp.idevento    AND
                               crapedp.cdcooper = crapadp.cdcooper    AND
                               crapedp.dtanoage = crapadp.dtanoage    AND
                               crapedp.cdevento = crapadp.cdevento NO-LOCK,
                EACH crapidp WHERE   crapidp.idevento = crapadp.idevento     AND
                                     crapidp.cdcooper = crapadp.cdcooper     AND
                                     crapidp.dtanoage = crapadp.dtanoage     AND
                                     crapidp.cdagenci = crapadp.cdagenci     AND
                                     crapidp.cdevento = crapadp.cdevento     AND
                                     crapidp.nrseqeve = crapadp.nrseqdig     AND
                                     crapidp.tpinseve = 1                    AND
                                     crapidp.idstains = 2 NO-LOCK
                                     BREAK BY crapidp.cdcooper
                                             BY  crapidp.dtanoage     
                                               BY  crapidp.nrdconta
                                                 BY crapidp.idseqttl  :

           FIND crapage WHERE crapage.cdcooper = crapidp.cdcooper AND
                              crapage.cdagenci = crapidp.cdagenci
                              NO-LOCK NO-ERROR.
           
           IF  crapidp.qtfaleve = 0 AND AVAIL crapage THEN
               DO:
                   CREATE tt-progrid.
                   ASSIGN tt-progrid.cdcooper = crapidp.cdcooper 
                          tt-progrid.dtanoage = crapidp.dtanoage 
                          tt-progrid.nrdconta = crapidp.nrdconta
                          tt-progrid.idseqttl = crapidp.idseqttl
                          tt-progrid.nmrescop = crapcop.nmrescop.

                   CREATE tt-progrid-pa.
                   ASSIGN tt-progrid-pa.cdcooper = crapidp.cdcooper
                          tt-progrid-pa.cdagenci = crapage.cdagenci
                          tt-progrid-pa.nmresage = crapage.nmresage
                          tt-progrid-pa.dtanoage = crapidp.dtanoage
                          tt-progrid-pa.nrdconta = crapidp.nrdconta
                          tt-progrid-pa.idseqttl = crapidp.idseqttl.

                   IF aux_menorpac > crapage.cdagenci THEN
                       ASSIGN aux_menorpac = crapage.cdagenci.

                   IF aux_maiorpac < crapage.cdagenci THEN
                       ASSIGN aux_maiorpac = crapage.cdagenci.
               END.
           ELSE
           IF  (((crapidp.qtfaleve * 100) / Crapadp.QtDiaEve) < 
               (100 - crapedp.prfreque)) AND AVAIL crapage THEN                         
               DO:                             
                   CREATE tt-progrid.
                   ASSIGN tt-progrid.cdcooper = crapidp.cdcooper
                          tt-progrid.dtanoage = crapidp.dtanoage
                          tt-progrid.nrdconta = crapidp.nrdconta
                          tt-progrid.idseqttl = crapidp.idseqttl
                          tt-progrid.nmrescop = crapcop.nmrescop. 

                   CREATE tt-progrid-pa.
                   ASSIGN tt-progrid-pa.cdcooper = crapidp.cdcooper
                          tt-progrid-pa.cdagenci = crapage.cdagenci
                          tt-progrid-pa.nmresage = crapage.nmresage
                          tt-progrid-pa.dtanoage = crapidp.dtanoage
                          tt-progrid-pa.nrdconta = crapidp.nrdconta
                          tt-progrid-pa.idseqttl = crapidp.idseqttl.

                   IF aux_menorpac > crapage.cdagenci THEN
                       ASSIGN aux_menorpac = crapage.cdagenci.

                   IF aux_maiorpac < crapage.cdagenci THEN
                       ASSIGN aux_maiorpac = crapage.cdagenci.
  
               END.
       END.

       CREATE tt-pa-por-coop.
       ASSIGN tt-pa-por-coop.cdcooper = crapcop.cdcooper
              tt-pa-por-coop.menorpac = aux_menorpac
              tt-pa-por-coop.maiorpac = aux_maiorpac.

  END. /* Fim da leitura crapcop */
  

  /*Considera somente uma participacao nos questionarios e eventos*/
  FOR EACH tt-progrid NO-LOCK 
                      BREAK  BY tt-progrid.cdcooper
                               BY tt-progrid.dtanoage
                                 BY tt-progrid.nrdconta
                                   BY tt-progrid.idseqttl:
                                              
      IF  LAST-OF (tt-progrid.idseqttl) THEN
          ASSIGN aux_qtdeprgd = aux_qtdeprgd + 1
                 tot_particip = tot_particip + 1.

            
          /* Verifica o quadro social*/                  
      IF  LAST-OF (tt-progrid.dtanoage) THEN
          DO:  
              FOR EACH crapass WHERE 
                       crapass.cdcooper =  tt-progrid.cdcooper AND
                       crapass.dtadmiss <= DATE("31/12/" +
                               STRING(tt-progrid.dtanoage)) AND
                      (crapass.dtdemiss = ?  OR
                       crapass.dtdemiss > DATE("31/12/" +
                               STRING(tt-progrid.dtanoage))):
  
                 ASSIGN aux_qtdassoc = aux_qtdassoc + 1
                        tot_qtdassoc = tot_qtdassoc + 1.
                         
              END.
                 
              ASSIGN aux_percprgd = aux_qtdeprgd / aux_qtdassoc * 100 
                     aux_indicador = "%_Indice_participacao_Eventos"
                     aux_mes =  aux_nmmesano[MONTH(TODAY)].
                   
              DISP STREAM str_1   tt-progrid.nmrescop 
                                  tt-progrid.dtanoage 
                                  aux_mes             
                                  aux_qtdeprgd        
                                  aux_qtdassoc        
                                  aux_indicador       
                                  aux_percprgd        
                                  WITH FRAME f_social.
  
              DOWN STREAM str_1 WITH FRAME f_social.
                    
              ASSIGN  aux_qtdeprgd = 0  
                      aux_qtdassoc = 0
                      aux_percprgd = 0.

              /* pega o menor e o maior PA da cooperativa em questao */
              FIND FIRST tt-pa-por-coop WHERE tt-pa-por-coop.cdcooper = 
                                         tt-progrid.cdcooper NO-LOCK NO-ERROR.

              DO aux_contador = tt-pa-por-coop.menorpac TO 
                                tt-pa-por-coop.maiorpac:

                  ASSIGN aux_qtdeprgd = 0
                         aux_qtdassoc = 0.

                  /* busca a participacao dos cooperados em cada PA */
                  FOR EACH tt-progrid-pa NO-LOCK WHERE 
                                   tt-progrid-pa.cdcooper = tt-progrid.cdcooper AND
                                   tt-progrid-pa.cdagenci = aux_contador        AND
                                   tt-progrid-pa.dtanoage = tt-progrid.dtanoage
                                      BREAK BY tt-progrid-pa.dtanoage
                                              BY tt-progrid-pa.nrdconta
                                                BY tt-progrid-pa.idseqttl:
    
                      IF LAST-OF(tt-progrid-pa.idseqttl) THEN
                          ASSIGN aux_qtdeprgd = aux_qtdeprgd + 1.
    
                      IF LAST-OF(tt-progrid-pa.dtanoage) THEN
                      DO:
                          /* soma o total de associados por PA */
                          FOR EACH crapass WHERE crapass.cdcooper =  
                                                         tt-progrid-pa.cdcooper AND
                                                 crapass.cdagenci =  
                                                         tt-progrid-pa.cdagenci AND
                                                 crapass.dtadmiss <= DATE("31/12/" +
                                                   STRING(tt-progrid-pa.dtanoage)) AND
                                                (crapass.dtdemiss = ?  OR
                                                 crapass.dtdemiss > DATE("31/12/" +
                                                 STRING(tt-progrid-pa.dtanoage))):
      
                              ASSIGN aux_qtdassoc = aux_qtdassoc + 1.
                                     
                          END.
    
                          ASSIGN aux_percprgd = aux_qtdeprgd / aux_qtdassoc * 100 
                                 aux_indicador = "%_Indice_participacao_Eventos"
                                 aux_mes =  aux_nmmesano[MONTH(TODAY)]
                                 aux_dsagenci = 
                                STRING(tt-progrid-pa.cdagenci, "999") + " - " +
                                                tt-progrid-pa.nmresage.
    
                          DISP STREAM str_1 aux_dsagenci @ tt-progrid.nmrescop 
                                            tt-progrid.dtanoage 
                                            aux_mes             
                                            aux_qtdeprgd        
                                            aux_qtdassoc        
                                            aux_indicador       
                                            aux_percprgd        
                                            WITH FRAME f_social.
      
                          DOWN STREAM str_1 WITH FRAME f_social.
    
                          ASSIGN aux_qtdeprgd = 0
                                 aux_qtdassoc = 0.
                                 
                      END.
                  END.
              END.
          END. 
  
  END. /* Fim da leitura tt-progrid */
  
  /* Lista totalizador Sistema Cecred */
  ASSIGN tot_percent = tot_particip / tot_qtdassoc * 100.
  
  DISP STREAM str_1 "Sistema Cecred" @  tt-progrid.nmrescop
                    tt-progrid.dtanoage
                    aux_mes
                    tot_particip @ aux_qtdeprgd  
                    tot_qtdassoc @ aux_qtdassoc
                    aux_indicador
                    tot_percent @  aux_percprgd  
                    WITH FRAME f_social.
  
  DOWN STREAM str_1 WITH FRAME f_social.
  
  ASSIGN tot_percent  = 0 
         tot_particip = 0
         tot_qtdassoc = 0.

  
  EMPTY TEMP-TABLE tt-progrid.
  EMPTY TEMP-TABLE tt-progrid-pa.
  EMPTY TEMP-TABLE tt-pa-por-coop.

  /** NOVA LEITURA PARA REPATORIO DE ASSEMBLEIAS **/

  FOR EACH crapcop NO-LOCK :

      ASSIGN aux_menorpac = 999
             aux_maiorpac = 0.

     /*Pega participacao dos cooperados*/     
     FOR EACH crapadp WHERE 
                        crapadp.idevento = 2                AND 
                        crapadp.cdcooper = crapcop.cdcooper AND
                        crapadp.dtanoage = INT(ab_unmap.aux_agenda) AND
                        crapadp.idstaeve <> 2               AND
                        crapadp.dtfineve <= DATE(ab_unmap.aux_dtfinal) NO-LOCK,
         EACH crapedp WHERE  crapedp.idevento = crapadp.idevento    AND
                             crapedp.cdcooper = crapadp.cdcooper    AND
                             crapedp.dtanoage = crapadp.dtanoage    AND
                             crapedp.cdevento = crapadp.cdevento NO-LOCK,
              EACH crapidp WHERE   crapidp.idevento = crapadp.idevento     AND
                                   crapidp.cdcooper = crapadp.cdcooper     AND
                                   crapidp.dtanoage = crapadp.dtanoage     AND
                                   crapidp.cdagenci = crapadp.cdagenci     AND
                                   crapidp.cdevento = crapadp.cdevento     AND
                                   crapidp.nrseqeve = crapadp.nrseqdig     AND
                                   crapidp.tpinseve = 1                    AND
                                   crapidp.idstains = 2 NO-LOCK
                                   BREAK BY crapidp.cdcooper 
                                            BY  crapidp.dtanoage     
                                                BY  crapidp.nrdconta
                                                    BY crapidp.idseqttl  :

         FIND crapage WHERE crapage.cdcooper = crapidp.cdcooper AND
                            crapage.cdagenci = crapidp.cdageins
                            NO-LOCK NO-ERROR.
         
         IF  crapidp.qtfaleve = 0 AND AVAIL(crapage) THEN
             DO:
                 CREATE tt-progrid.
                 ASSIGN tt-progrid.cdcooper = crapidp.cdcooper 
                        tt-progrid.dtanoage = crapidp.dtanoage 
                        tt-progrid.nrdconta = crapidp.nrdconta
                        tt-progrid.idseqttl = crapidp.idseqttl
                        tt-progrid.nmrescop = crapcop.nmrescop.

                 CREATE tt-progrid-pa.
                 ASSIGN tt-progrid-pa.cdcooper = crapidp.cdcooper
                        tt-progrid-pa.cdagenci = crapage.cdagenci
                        tt-progrid-pa.nmresage = crapage.nmresage
                        tt-progrid-pa.dtanoage = crapidp.dtanoage
                        tt-progrid-pa.nrdconta = crapidp.nrdconta
                        tt-progrid-pa.idseqttl = crapidp.idseqttl.

                 IF aux_menorpac > crapage.cdagenci THEN
                     ASSIGN aux_menorpac = crapage.cdagenci.

                 IF aux_maiorpac < crapage.cdagenci THEN
                     ASSIGN aux_maiorpac = crapage.cdagenci.
             END.
         ELSE
         IF  (((crapidp.qtfaleve * 100) / Crapadp.QtDiaEve) < 
             (100 - crapedp.prfreque)) AND AVAIL(crapage) THEN
             DO:                             
                 CREATE tt-progrid.
                 ASSIGN tt-progrid.cdcooper = crapidp.cdcooper 
                        tt-progrid.dtanoage = crapidp.dtanoage 
                        tt-progrid.nrdconta = crapidp.nrdconta
                        tt-progrid.idseqttl = crapidp.idseqttl
                        tt-progrid.nmrescop = crapcop.nmrescop. 

                 CREATE tt-progrid-pa.
                 ASSIGN tt-progrid-pa.cdcooper = crapidp.cdcooper
                        tt-progrid-pa.cdagenci = crapage.cdagenci
                        tt-progrid-pa.nmresage = crapage.nmresage
                        tt-progrid-pa.dtanoage = crapidp.dtanoage
                        tt-progrid-pa.nrdconta = crapidp.nrdconta
                        tt-progrid-pa.idseqttl = crapidp.idseqttl.

                 IF aux_menorpac > crapage.cdagenci THEN
                     ASSIGN aux_menorpac = crapage.cdagenci.

                 IF aux_maiorpac < crapage.cdagenci THEN
                     ASSIGN aux_maiorpac = crapage.cdagenci.

             END.
     END.

     CREATE tt-pa-por-coop.
     ASSIGN tt-pa-por-coop.cdcooper = crapcop.cdcooper
            tt-pa-por-coop.menorpac = aux_menorpac
            tt-pa-por-coop.maiorpac = aux_maiorpac.

  END. /* Fim da leitura crapcop */

  /*Considera somente uma participacao */
  FOR EACH tt-progrid NO-LOCK 
                      BREAK BY tt-progrid.cdcooper 
                               BY  tt-progrid.dtanoage     
                                   BY  tt-progrid.nrdconta
                                       BY  tt-progrid.idseqttl  :
                                              
      IF  LAST-OF (tt-progrid.idseqttl) THEN    
          ASSIGN aux_qtdeprgd = aux_qtdeprgd + 1
                 tot_particip = tot_particip + 1.
  
      /* Verifica o quadro social*/                  
      IF  LAST-OF (tt-progrid.dtanoage) THEN
          DO:  
             FOR EACH crapass WHERE 
                      crapass.cdcooper =  tt-progrid.cdcooper  AND
                      crapass.dtadmiss <= DATE(ab_unmap.aux_dtfinal) AND
                     (crapass.dtdemiss = ?  OR
                      crapass.dtdemiss > DATE(ab_unmap.aux_dtfinal) ):
  
                ASSIGN aux_qtdassoc = aux_qtdassoc + 1
                       tot_qtdassoc = tot_qtdassoc + 1.
                        
             END.

             ASSIGN aux_percprgd = aux_qtdeprgd / aux_qtdassoc * 100 
                    aux_indicador = "%_Indice_participacao_Assembleias"
                    aux_mes =  aux_nmmesano[MONTH(DATE(ab_unmap.aux_dtfinal))].
             
             DISP STREAM str_1  tt-progrid.nmrescop
                                tt-progrid.dtanoage
                                aux_mes            
                                aux_qtdeprgd       
                                aux_qtdassoc       
                                aux_indicador      
                                aux_percprgd       
                                WITH FRAME f_social.

             DOWN STREAM str_1 WITH FRAME f_social.
                   
             ASSIGN  aux_qtdeprgd = 0  
                     aux_qtdassoc = 0
                     aux_percprgd = 0.

             /* pega o menor e o maior PA da cooperativa em questao */
              FIND FIRST tt-pa-por-coop WHERE tt-pa-por-coop.cdcooper = 
                                         tt-progrid.cdcooper NO-LOCK NO-ERROR.

              DO aux_contador = tt-pa-por-coop.menorpac TO 
                                tt-pa-por-coop.maiorpac:

                  ASSIGN aux_qtdeprgd = 0
                         aux_qtdassoc = 0.

              
                  FOR EACH tt-progrid-pa NO-LOCK WHERE 
                                   tt-progrid-pa.cdcooper = tt-progrid.cdcooper AND
                                   tt-progrid-pa.cdagenci = aux_contador        AND
                                   tt-progrid-pa.dtanoage = tt-progrid.dtanoage
                                      BREAK BY tt-progrid-pa.dtanoage
                                              BY tt-progrid-pa.nrdconta
                                                BY tt-progrid-pa.idseqttl:
    
                      IF LAST-OF(tt-progrid-pa.idseqttl) THEN
                          ASSIGN aux_qtdeprgd = aux_qtdeprgd + 1.
    
                      IF LAST-OF(tt-progrid-pa.dtanoage) THEN
                      DO:
                          /* soma o total de associados por PA */
                          FOR EACH crapass WHERE crapass.cdcooper =  
                                                         tt-progrid-pa.cdcooper AND
                                                 crapass.cdagenci =  
                                                         tt-progrid-pa.cdagenci AND
                                                 crapass.dtadmiss <= DATE(ab_unmap.aux_dtfinal) AND
                                                (crapass.dtdemiss = ?  OR
                                                 crapass.dtdemiss > DATE(ab_unmap.aux_dtfinal)):
      
                              ASSIGN aux_qtdassoc = aux_qtdassoc + 1.
                                     
                          END.
    
                          ASSIGN aux_percprgd = aux_qtdeprgd / aux_qtdassoc * 100 
                                 aux_indicador = "%_Indice_participacao_Assembleias"
                                 aux_mes =  aux_nmmesano[MONTH(DATE(ab_unmap.aux_dtfinal))]
                                 aux_dsagenci = 
                                STRING(tt-progrid-pa.cdagenci, "999") + " - " +
                                                tt-progrid-pa.nmresage.
    
                          DISP STREAM str_1 aux_dsagenci @ tt-progrid.nmrescop 
                                            tt-progrid.dtanoage 
                                            aux_mes             
                                            aux_qtdeprgd        
                                            aux_qtdassoc        
                                            aux_indicador       
                                            aux_percprgd        
                                            WITH FRAME f_social.
      
                          DOWN STREAM str_1 WITH FRAME f_social.
    
                          ASSIGN aux_qtdeprgd = 0
                                 aux_qtdassoc = 0.
                                 
                      END.
                  END.
              END.
          END.   
                            
  END. /* Fim da leitura tt-progrid */

   /* Lista totalizador Sistema Cecred */
  ASSIGN tot_percent = tot_particip / tot_qtdassoc * 100.
  
  DISP STREAM str_1 "Sistema Cecred" @  tt-progrid.nmrescop
                    tt-progrid.dtanoage
                    aux_mes
                    tot_particip @ aux_qtdeprgd  
                    tot_qtdassoc @ aux_qtdassoc
                    aux_indicador
                    tot_percent @  aux_percprgd  
                    WITH FRAME f_social.
  
  DOWN STREAM str_1 WITH FRAME f_social.
  
  ASSIGN tot_percent  = 0 
         tot_particip = 0
         tot_qtdassoc = 0.


  OUTPUT STREAM str_1 CLOSE.

  EMPTY TEMP-TABLE tt-progrid.
  EMPTY TEMP-TABLE tt-progrid-pa.
  EMPTY TEMP-TABLE tt-pa-por-coop.

END PROCEDURE.
/* Fim do gera relatorio */
&ANALYZE-RESUME

