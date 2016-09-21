/* .............................................................................

   Programa: wcrm0001_xml.p
   Sistema : CRM 
   Sigla   : CRM
   Autor   : Rosangela
   Data    : Maio/2006                   Ultima Atualizacao: 24/11/2011
   
   Dados referentes ao programa:
   Frequencia: esporadica(internet)
   Objetivo  : Gerar arquivo XML para a tela wcrm0001
   
   Alteracoes: 03/11/2008 - Inclusao widget-pool (martin)
   
               24/11/2011 - Ajuste na data da agenda (David).
 
..............................................................................*/
 
CREATE WIDGET-POOL.
 
DEFINE VARIABLE par_cdcooper AS INTEGER                               NO-UNDO.
DEFINE VARIABLE aux_dscritic AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_flgexist AS LOGICAL         INIT FALSE            NO-UNDO.
DEFINE VARIABLE aux_dtanoage LIKE gnpapgd.dtanoage.

/* Variaveis de controle do XML */
DEFINE VARIABLE xDoc         AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xRoot        AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xRoot2       AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xField       AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xText        AS HANDLE                                NO-UNDO.

/* Cria um campo com seu valor no XML */
FUNCTION criaCampo RETURNS LOGICAL
    (INPUT nomeCampo  AS CHAR,
     INPUT textoCampo AS CHAR):
    xDoc:CREATE-NODE(xField,CAPS(nomeCampo),"ELEMENT").
    xRoot2:APPEND-CHILD(xField).
    xDoc:CREATE-NODE(xText,"","TEXT").
    xField:APPEND-CHILD(xText).
    xText:NODE-VALUE = STRING(textoCampo).
    RETURN TRUE.
END FUNCTION.

/* Include para usar os comandos para WEB */
{src/web2/wrap-cgi.i}

/* Configura a saída como XML */
OUTPUT-CONTENT-TYPE ("text/xml":U).

ASSIGN par_cdcooper = INT(GET-VALUE("aux_cdcooper")).

CREATE X-DOCUMENT xDoc.
CREATE X-NODEREF  xRoot.
CREATE X-NODEREF  xRoot2.
CREATE X-NODEREF  xField.
CREATE X-NODEREF  xText.

/* Cria a raiz principal */
xDoc:CREATE-NODE( xRoot, "CECRED", "ELEMENT" ).
xDoc:APPEND-CHILD( xRoot ).

/* A agenda mostrada será sempre a do ano vigente */
ASSIGN aux_dtanoage = YEAR(TODAY).

/* Eventos da Agenda */
FOR EACH crapedp WHERE crapedp.idevento = 1 /*Progrid*/    AND
                       crapedp.cdcooper = par_cdcooper     AND
                       crapedp.dtlibint <= TODAY           AND
                       crapedp.dtretint >= TODAY           AND
                       crapedp.dtanoage = aux_dtanoage     NO-LOCK
                       BREAK BY crapedp.nmevento:
         
    /* Cria o nó PROGRAMACAO */
    xDoc:CREATE-NODE( xRoot2, "AGENDA", "ELEMENT" ).
    xRoot:APPEND-CHILD( xRoot2 ).
    xRoot2:SET-ATTRIBUTE("DTANOAGE",string(crapedp.dtanoage)).
    
    criaCampo("cdevento",string(crapedp.cdevento)).
    criaCampo("nmevento",string(crapedp.nmevento)).
    aux_flgexist = TRUE.

END.

/* Se não encontrou registros, gera TAG de erro */
IF   NOT aux_flgexist   THEN
     DO:
         aux_dscritic = "A agenda para esse ano ainda não esta liberada. Aguarde mais alguns dias!".
         
         /* Cria o elemento de erro no XML */
         xDoc:CREATE-NODE( xRoot2, "ERRO", "ELEMENT" ).
         xRoot:APPEND-CHILD( xRoot2 ).
         xDoc:CREATE-NODE(xText,"","TEXT").
         xRoot2:APPEND-CHILD(xText).
         xText:NODE-VALUE = aux_dscritic.
     END.

xDoc:SAVE("STREAM","WEBSTREAM").

DELETE OBJECT xDoc.
DELETE OBJECT xRoot.
DELETE OBJECT xField.
DELETE OBJECT xText.
  
/* .......................................................................... */
