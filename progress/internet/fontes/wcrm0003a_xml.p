/* .............................................................................

   Programa: wcrm0003a_xml.p
   Sistema : CRM 
   Sigla   : CRM
   Autor   : David
   Data    : Dezembro/2006                   Ultima Atualizacao: 06/09/2013

   Dados referentes ao programa:

   Frequencia: esporadica(internet)
   Objetivo  : gera arquivo com dados para inscrição em assembleias

   Alteracoes: 15/02/2007 - Incluir critica se evento ja foi realizado (David).

               04/11/2008 - Inclusao do widget-pool. (Martin)
               
               05/01/2010 - Carregar agenda através do campo tpevento para
                            nao utilizar cdevento fixo. Retornar campo cdevento
                            para utilizacao no script PHP (David).
                            
               29/07/2011 - Ajuste para assembleias extraordinarias (David). 
               
               02/04/2012 - Ampliar limite de mes para controle de assembleias
                            extraordinarias (David).
               
               06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
............................................................................. */

CREATE WIDGET-POOL.

DEFINE VARIABLE par_cdcooper AS INTEGER                               NO-UNDO.
DEFINE VARIABLE par_nrdconta AS INTEGER                               NO-UNDO.
DEFINE VARIABLE par_tpevento AS INTEGER                               NO-UNDO.

DEFINE VARIABLE aux_dscritic AS CHAR                                  NO-UNDO.
DEFINE VARIABLE aux_cdagenci AS INTEGER                               NO-UNDO.
DEFINE VARIABLE aux_cdevento AS INTEGER                               NO-UNDO.

/* Variaveis de controle do XML */
DEFINE VARIABLE xDoc         AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xRoot        AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xField       AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xText        AS HANDLE                                NO-UNDO.

/* Cria um campo com seu valor no XML */
FUNCTION criaCampo RETURNS LOGICAL
    (INPUT nomeCampo  AS CHAR,
     INPUT textoCampo AS CHAR):

    xDoc:CREATE-NODE(xField,CAPS(nomeCampo),"ELEMENT").
    xRoot:APPEND-CHILD(xField).
    xDoc:CREATE-NODE(xText,"","TEXT").
    xField:APPEND-CHILD(xText).
    xText:NODE-VALUE = STRING(textoCampo).

    RETURN TRUE.

END FUNCTION.


/* Include para usar os comandos para WEB */
{src/web2/wrap-cgi.i}

/* Configura a saída como XML */
OUTPUT-CONTENT-TYPE ("text/xml":U).

ASSIGN par_cdcooper = INT(GET-VALUE("aux_cdcooper"))
       par_nrdconta = INT(GET-VALUE("aux_nrdconta"))
       par_tpevento = INT(GET-VALUE("aux_tpevento")).

CREATE X-DOCUMENT xDoc.
CREATE X-NODEREF  xRoot.
CREATE X-NODEREF  xField.
CREATE X-NODEREF  xText.

/* Cria a raiz principal */
xDoc:CREATE-NODE(xRoot,"CECRED","ELEMENT").
xDoc:APPEND-CHILD(xRoot).

ASSIGN aux_dscritic = "".

/* busca a lista de grau de parentesco */
FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                   crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crapass  THEN
    ASSIGN aux_dscritic = "0-Conta/DV invalida!".
ELSE
    DO:
        IF  par_tpevento = 8  THEN  /** Pre-Assembleia **/
            ASSIGN aux_cdagenci = crapass.cdagenci.
        ELSE
        IF  par_tpevento = 7  THEN  /** Assembleia Geral **/
            ASSIGN aux_cdagenci = 0.
        
        /* busca ano de formacao da agenda */
        FIND LAST gnpapgd WHERE gnpapgd.cdcooper = par_cdcooper AND
                                gnpapgd.idevento = 2            
                                NO-LOCK NO-ERROR.

        /** Logica temporaria para controlar assembleias extraordinais **/
        IF  MONTH(TODAY) > 5  THEN
            DO:
                ASSIGN aux_cdevento = IF par_tpevento = 7 THEN 398 ELSE 533.

                FIND FIRST crapedp WHERE crapedp.cdcooper = par_cdcooper     AND
                                         crapedp.idevento = gnpapgd.idevento AND
                                         crapedp.dtanoage = gnpapgd.dtanonov AND
                                         crapedp.tpevento = par_tpevento     AND
                                         crapedp.cdevento = aux_cdevento
                                         NO-LOCK NO-ERROR.
            END.
        ELSE    
            DO:
                ASSIGN aux_cdevento = IF par_tpevento = 7 THEN 665 ELSE 4.

                FIND FIRST crapedp WHERE crapedp.cdcooper = par_cdcooper     AND
                                         crapedp.idevento = gnpapgd.idevento AND
                                         crapedp.dtanoage = gnpapgd.dtanonov AND
                                         crapedp.cdevento = aux_cdevento     AND
                                         crapedp.tpevento = par_tpevento    
                                         NO-LOCK NO-ERROR.
            END.
               
        IF  AVAILABLE crapedp  THEN
            /* busca agenda da assembleia */ 
            FIND crapadp WHERE crapadp.cdcooper = par_cdcooper     AND
                               crapadp.idevento = crapedp.idevento AND 
                               crapadp.cdevento = crapedp.cdevento AND
                               crapadp.cdagenci = aux_cdagenci     AND
                               crapadp.dtanoage = crapedp.dtanoage      
                               NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapedp  OR 
            NOT AVAILABLE crapadp  OR
            crapadp.dtinieve = ?   OR
            crapadp.dshroeve = ""  THEN
            ASSIGN aux_dscritic = IF  par_tpevento = 8  THEN
                                      "1-A data da Pre-Assembleia do seu" + 
                                      " PA ainda nao foi definida!"
                                  ELSE
                                      "1-A data da Assembleia ainda nao" +
                                      " foi definida!".
        ELSE
        IF  crapadp.dtinieve < TODAY                   OR
           (crapadp.dtinieve = TODAY                   AND 
            crapadp.dshroeve <= STRING(TIME,"HH:MM"))  THEN 
            ASSIGN aux_dscritic = IF  par_tpevento = 8  THEN
                                      "0-          A pre-assembleia " + 
                                      "de seu PA ja ocorreu em " + 
                                      STRING(crapadp.dtinieve,"99/99/9999")
                                      + ".\nCaso queira participar em " + 
                                      "outra data, entre em contato com " +
                                      "seu PA."
                                  ELSE
                                      "0-A assembleia ja ocorreu em " + 
                                      STRING(crapadp.dtinieve,"99/99/9999")
                                      + ".".
    END. 
                
IF  aux_dscritic <> ""  THEN
    criaCampo("ERRO",aux_dscritic).
ELSE
    DO:
        criaCampo("cdagenci",STRING(crapass.cdagenci)).
        criaCampo("nrseqdig",STRING(crapadp.nrseqdig)).
        criaCampo("dtinieve",STRING(crapadp.dtinieve,"99/99/99")).
        criaCampo("dshroeve",crapadp.dshroeve).
        criaCampo("dtanoage",STRING(crapadp.dtanoage,"9999")).
        criaCampo("cdevento",STRING(crapedp.cdevento)).
    END.
    
xDoc:SAVE("STREAM","WEBSTREAM").

DELETE OBJECT xDoc.
DELETE OBJECT xRoot.
DELETE OBJECT xField.
DELETE OBJECT xText.
  
/* .......................................................................... */
