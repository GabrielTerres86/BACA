/*...............................................................................

Alterações: 10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).

            04/05/2009 - Utilizar cdcooper = 0 nas consultas (David).
                        
                        05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
                                                 busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).

            23/10/2012 - Tratar nova estrutura gnappob (Gabriel).
...............................................................................*/


&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI adm2
&ANALYZE-RESUME
/* Connected Databases 
          banco            PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW

/* Temp-Table and Buffer definitions                                    */
DEFINE TEMP-TABLE ab_unmap
       FIELD nmresage AS CHARACTER FORMAT "x(50)" .


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
DEFINE VARIABLE ProgramaEmUso AS CHARACTER INITIAL ["wpgd0039a"].
DEFINE VARIABLE NmeDoPrograma AS CHARACTER INITIAL ["wpgd0039a.w"].

DEFINE VARIABLE v-identificacao       AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE IdentificacaoDaSessao AS CHARACTER FORMAT "x(47)"       NO-UNDO.

DEFINE VARIABLE vetoritens            AS CHARACTER                      NO-UNDO.
DEFINE VARIABLE aux_dsdtroca          AS CHARACTER                      NO-UNDO.

DEFINE VARIABLE aux_contador_1        AS INTEGER                        NO-UNDO.
DEFINE VARIABLE aux_contador_2        AS INTEGER                        NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Web-Object
&Scoped-define DB-AWARE no

&Scoped-define WEB-FILE fontes/wpgd0039a.htm

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Web-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-FIELDS crapedp.nmevento 
&Scoped-define ENABLED-TABLES ab_unmap crapedp
&Scoped-define FIRST-ENABLED-TABLE ab_unmap
&Scoped-define SECOND-ENABLED-TABLE crapedp
&Scoped-Define ENABLED-OBJECTS ab_unmap.nmresage 
&Scoped-Define DISPLAYED-FIELDS crapedp.nmevento 
&Scoped-define DISPLAYED-TABLES ab_unmap crapedp
&Scoped-define FIRST-DISPLAYED-TABLE ab_unmap
&Scoped-define SECOND-DISPLAYED-TABLE crapedp
&Scoped-Define DISPLAYED-OBJECTS ab_unmap.nmresage 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Web-Frame
     ab_unmap.nmresage AT ROW 1 COL 1 HELP
          "" NO-LABEL FORMAT "x(50)"
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
     crapedp.nmevento AT ROW 1 COL 1 NO-LABEL
          VIEW-AS FILL-IN 
          SIZE 20 BY 1
    WITH 1 DOWN KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS 
         AT COL 1 ROW 1
         SIZE 45 BY 24.71.


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
          FIELD nmresage AS CHARACTER FORMAT "x(50)" 
      END-FIELDS.
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW w-html ASSIGN
         HEIGHT             = 24.71
         WIDTH              = 45.
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
/* SETTINGS FOR FILL-IN crapedp.nmevento IN FRAME Web-Frame
   ALIGN-L EXP-LABEL                                                    */
/* SETTINGS FOR FILL-IN ab_unmap.nmresage IN FRAME Web-Frame
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
    ("nmevento":U,"crapedp.nmevento":U,crapedp.nmevento:HANDLE IN FRAME {&FRAME-NAME}).
  RUN htmAssociate
    ("nmresage":U,"ab_unmap.nmresage":U,ab_unmap.nmresage:HANDLE IN FRAME {&FRAME-NAME}).
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
  
RUN outputHeader.
RUN inputFields.


/* Busca o evento */
FIND crapadp WHERE crapadp.idevento = INT(GET-VALUE("aux_idevento"))   AND
                   crapadp.cdcooper = INT(GET-VALUE("aux_cdcooper"))   AND
                   crapadp.nrseqdig = INT(GET-VALUE("aux_nrseqdig"))   NO-LOCK NO-ERROR.

/* Busca o PAC */
FIND crapage WHERE crapage.cdcooper = crapadp.cdcooper   AND
                   crapage.cdagenci = crapadp.cdagenci   NO-LOCK NO-ERROR.

ASSIGN ab_unmap.nmresage = crapage.nmresage.

/* se for PROGRID, verifica se há PAC's agrupados */
IF   crapadp.idevento = 1    THEN
     FOR EACH crapagp WHERE crapagp.cdcooper  = crapadp.cdcooper  AND
                            crapagp.cdagenci <> crapagp.cdageagr  AND
                            crapagp.cdageagr  = crapadp.cdagenci  NO-LOCK:
     
         FIND crapage WHERE crapage.cdcooper = crapagp.cdcooper   AND
                            crapage.cdagenci = crapagp.cdagenci   NO-LOCK NO-ERROR.
     
         ASSIGN ab_unmap.nmresage = ab_unmap.nmresage + " ~/ " +
                                    crapage.nmresage.
     END.

/* Busca o nome do EVENTO */
FIND crapedp WHERE crapedp.idevento = crapadp.idevento   AND
                   crapedp.cdcooper = crapadp.cdcooper   AND
                   crapedp.dtanoage = crapadp.dtanoage   AND
                   crapedp.cdevento = crapadp.cdevento   NO-LOCK NO-ERROR.

/* Verificação para ver quais dados do evento estão INCOMPLETOS */
ASSIGN vetoritens = "".
                                                                                                
/* restrições somente para o PROGRID */
IF   crapadp.idevento = 1   THEN
     DO:
        IF   crapadp.dtfineve = ?   THEN
             vetoritens = vetoritens + "~{campo:'Data Final'~},".
                                                                                        
        /* Custo do evento */
        FIND FIRST crapcdp WHERE crapcdp.idevento = crapadp.idevento   AND
                                 crapcdp.cdcooper = crapadp.cdcooper   AND
                                 crapcdp.cdagenci = crapadp.cdagenci   AND
                                 crapcdp.dtanoage = crapadp.dtanoage   AND
                                 crapcdp.cdevento = crapadp.cdevento
                                 NO-LOCK NO-ERROR.

        IF   AVAILABLE crapcdp   THEN
             DO:
                 /* Fornecedor ("pertence" a TODAS as cooperativas) */
                 FIND gnapfdp WHERE gnapfdp.idevento = crapadp.idevento   AND
                                    gnapfdp.cdcooper = 0                  AND
                                    gnapfdp.nrcpfcgc = crapcdp.nrcpfcgc
                                    NO-LOCK NO-ERROR.

                 IF   AVAILABLE gnapfdp   THEN
                      DO:
                          /* Proposta do fornecedor ("pertence" a TODAS as cooperativas) */
                          FIND gnappdp WHERE gnappdp.idevento = crapadp.idevento   AND
                                             gnappdp.cdcooper = 0                  AND
                                             gnappdp.nrcpfcgc = crapcdp.nrcpfcgc   AND
                                             gnappdp.nrpropos = crapcdp.nrpropos
                                             NO-LOCK NO-ERROR.

                          IF   AVAILABLE gnappdp    THEN
                               DO:
                                   FIND gnappob WHERE 
                                        gnappob.idevento = gnappdp.idevento AND
                                        gnappob.cdcooper = gnappdp.cdcooper AND
                                        gnappob.nrcpfcgc = gnappdp.nrcpfcgc AND
                                        gnappob.nrpropos = gnappdp.nrpropos
                                        NO-LOCK NO-ERROR.
                               
                                   IF   AVAIL gnappob   THEN
                                        IF   gnappob.dsobjeti = ""   THEN
                                             vetoritens = vetoritens + 
                                                "~{campo:'Objetivo'~},".
                                        ELSE 
                                             .
                                   ELSE
                                        vetoritens = vetoritens +
                                                "~{campo:'Objetivo'~},".

                                   IF   gnappdp.dsconteu = ""   THEN
                                        vetoritens = vetoritens + "~{campo:'Conteúdo Programático'~},".

                                   IF   gnappdp.qtcarhor = 0    THEN
                                        vetoritens = vetoritens + "~{campo:'Carga Horária'~},".
                                                     
                                                     
                                   /* Se não tiver facilitadores */
                                   IF   NOT CAN-FIND(FIRST gnfacep WHERE gnfacep.idevento = gnappdp.idevento   AND
                                                                         gnfacep.cdcooper = 0                  AND
                                                                         gnfacep.nrcpfcgc = gnappdp.nrcpfcgc   AND
                                                                         gnfacep.nrpropos = gnappdp.nrpropos   NO-LOCK)   THEN
                                        vetoritens = vetoritens + "~{campo:'Facilitador'~},".
                                   ELSE                          
                                        /* Facilitador(es) da proposta */
                                        FOR EACH gnfacep WHERE gnfacep.idevento = gnappdp.idevento   AND
                                                               gnfacep.cdcooper = 0                  AND
                                                               gnfacep.nrcpfcgc = gnappdp.nrcpfcgc   AND
                                                               gnfacep.nrpropos = gnappdp.nrpropos   NO-LOCK:
                                        
                                            /* Cadastro do facilitador */
                                            FIND gnapfep WHERE gnapfep.idevento = gnfacep.idevento   AND
                                                               gnapfep.cdcooper = 0                  AND
                                                               gnapfep.nrcpfcgc = gnfacep.nrcpfcgc   AND
                                                               gnapfep.cdfacili = gnfacep.cdfacili   NO-LOCK NO-ERROR.
                                        
                                            IF  (AVAILABLE gnapfep        AND
                                                 gnapfep.dscurric = "")   OR
                                                 NOT AVAILABLE gnapfep    THEN
                                                 vetoritens = vetoritens + "~{campo:'Curriculum do Facilitador'~},".
                                        END.
                               END.
                          ELSE
                               vetoritens = vetoritens + "~{campo:'Proposta'~},".
                      END.
                 ELSE
                      vetoritens = vetoritens + "~{campo:'Fornecedor'~},".
             END.                                                                                               
        ELSE
             vetoritens = vetoritens + "~{campo:'Custo'~},".


                /* Verifica dados do local */
                IF   crapadp.cdlocali <> 0   THEN
                     DO:
                                  FIND crapldp WHERE crapldp.idevento = crapadp.idevento   AND
                                                                         crapldp.cdcooper = crapadp.cdcooper   AND
                                                                        crapldp.cdagenci = crapadp.cdagenci   AND
                                                                        crapldp.nrseqdig = crapadp.cdlocali   NO-LOCK NO-ERROR.
                                                                        
                                 IF   NOT AVAILABLE crapldp   THEN
                      vetoritens = vetoritens + "~{campo:'Cadastro do Local'~},".
                 ELSE
                      DO:
                                          IF   crapldp.dsendloc = ""   THEN
                               vetoritens = vetoritens + "~{campo:'Endereco'~},".
                          
                                          IF   crapldp.nmbailoc = ""   THEN
                               vetoritens = vetoritens + "~{campo:'Bairro'~},".
                          
                                          IF   LENGTH(STRING(crapldp.nrtelefo)) < 8   THEN
                               vetoritens = vetoritens + "~{campo:'Telefone'~},".
                          
                                          IF   crapldp.nmcidloc = ""   THEN
                                               vetoritens = vetoritens + "~{campo:'Cidade'~},".
                      END.
                         END. 

     END. /* Progrid */

/* Validações tanto para PROGRID quanto ASSEMBLÉIA */
IF   crapadp.cdlocali = 0    THEN
     vetoritens = vetoritens + "~{campo:'Local'~},".

IF   crapadp.dshroeve = ""   THEN
     vetoritens = vetoritens + "~{campo:'Hora'~},".

IF   crapadp.dtinieve = ?    THEN
     vetoritens = vetoritens + "~{campo:'Data Inicial'~},".


IF   vetoritens <> ""   THEN
     DO:
        /* Faz a ordenação dos campos por ordem alfabética */
        DO aux_contador_1 = 2 TO NUM-ENTRIES(vetoritens,"~{") - 1:
        
           DO aux_contador_2 = 2 TO NUM-ENTRIES(vetoritens,"~{") - 1:
        
              /* se o elemento analisado foi maior que o elemento posterior, faz a troca dos dois */
              IF   ENTRY(aux_contador_2,vetoritens,"~{") > ENTRY(aux_contador_2 + 1,vetoritens,"~{")   THEN
                          /* guarda o elemento posterior para a troca */
                   ASSIGN aux_dsdtroca = ENTRY(aux_contador_2 + 1,vetoritens,"~{")

                          /* o elemento posterior passa a ser o elemento analisado */
                          ENTRY(aux_contador_2 + 1,vetoritens,"~{") = ENTRY(aux_contador_2,vetoritens,"~{")

                          /* o elemento analisado passa a ser o elemento que era o posterior */
                          ENTRY(aux_contador_2,vetoritens,"~{") = aux_dsdtroca.
           END.
        END.

        /* Tira a última vírgula */
        vetoritens = SUBSTRING(vetoritens,1,LENGTH(vetoritens) - 1).
     END.
         
/* Cria o vetor de itens não preenchidos */
RUN RodaJavaScript("var mitens=new Array();mitens=["  + vetoritens + "]"). 

RUN displayFields.
RUN enableFields.
RUN outputFields.


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

