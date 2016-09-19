/*..............................................................................

   Programa: wcrm0005_xml.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Junho/2006                   Ultima Atualizacao: 24/11/2011
   
   Dados referentes ao programa:
   
   Frequencia: Diario (internet)
   Objetivo  : Gerar arquivo XML para a tela wcrm0005-divulga��o da programa��o
   
   Alteracoes: 03/11/2008 - Inclusao widget-pool (martin)
   
               17/08/2011 - Liberar alteracao efetuada no fonte em producao.
                            Nao tinha comentario sobre o ajuste, mas a alteracao
                            corrige o a leitura da agenda para PAC's que estao
                            agregados a outro PAC (David).
                            
               24/11/2011 - Ajuste na data da agenda (David).
               
               06/09/2013 - Nova forma de chamar as ag�ncias, de PAC agora 
                            a escrita ser� PA (Andr� Euz�bio - Supero).             
 
..............................................................................*/
 
CREATE WIDGET-POOL.
 
DEFINE VARIABLE par_cdcooper AS INTEGER                                NO-UNDO.
DEFINE VARIABLE par_cdagenci AS INTEGER                                NO-UNDO.
DEFINE VARIABLE aux_nmresage AS CHARACTER                              NO-UNDO.
DEFINE VARIABLE aux_dtinieve AS CHARACTER                              NO-UNDO.
DEFINE VARIABLE aux_flgexist AS LOGICAL   INIT FALSE                   NO-UNDO.
DEFINE VARIABLE aux_nmcidade AS CHARACTER                              NO-UNDO.
DEFINE VARIABLE aux_tpevento AS CHARACTER                              NO-UNDO.
DEFINE VARIABLE aux_dtanoage LIKE gnpapgd.dtanoage                     NO-UNDO.

DEFINE VARIABLE vetormes     AS CHAR EXTENT 12
       INITIAL ["JANEIRO","FEVEREIRO","MAR�O","ABRIL","MAIO","JUNHO",
                "JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"]
                                                                       NO-UNDO.

/* Variaveis de controle do XML */
DEFINE VARIABLE xDoc         AS HANDLE                                 NO-UNDO.
DEFINE VARIABLE xRoot        AS HANDLE                                 NO-UNDO.
DEFINE VARIABLE xRoot2       AS HANDLE                                 NO-UNDO.
DEFINE VARIABLE xField       AS HANDLE                                 NO-UNDO.
DEFINE VARIABLE xText        AS HANDLE                                 NO-UNDO.

/* Cria um campo com seu valor no XML */
FUNCTION criaCampo RETURNS LOGICAL (INPUT nomeCampo  AS CHAR,
                                    INPUT textoCampo AS CHAR):

    xDoc:CREATE-NODE(xField,CAPS(nomeCampo),"ELEMENT").
    xRoot2:APPEND-CHILD(xField).
    xDoc:CREATE-NODE(xText,"","TEXT").
    xField:APPEND-CHILD(xText).
    xText:NODE-VALUE = STRING(textoCampo).
    
    RETURN TRUE.

END FUNCTION.

/* Include para usar os comandos para WEB */
{ src/web2/wrap-cgi.i }

/* Configura a sa�da como XML */
OUTPUT-CONTENT-TYPE ("text/xml":U).

ASSIGN par_cdcooper = INTE(GET-VALUE("aux_cdcooper"))
       par_cdagenci = INTE(GET-VALUE("aux_cdagenci")).

CREATE X-DOCUMENT xDoc.

CREATE X-NODEREF xRoot.
CREATE X-NODEREF xRoot2.
CREATE X-NODEREF xField.
CREATE X-NODEREF xText.

FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                   crapage.cdagenci = par_cdagenci NO-LOCK NO-ERROR.

IF  AVAILABLE crapage  THEN
    aux_nmresage = crapage.nmresage.
ELSE
    aux_nmresage = "N�O ENCONTRADO".

/* Cria a raiz principal */
xDoc:CREATE-NODE(xRoot,"CECRED","ELEMENT").
xDoc:APPEND-CHILD(xRoot).
xRoot:SET-ATTRIBUTE("CDAGENCI",STRING(par_cdagenci)).
xRoot:SET-ATTRIBUTE("NMRESAGE",aux_nmresage).

/* A agenda mostrada ser� sempre a do ano vigente */
ASSIGN aux_dtanoage = YEAR(TODAY).

FIND crapagp WHERE crapagp.cdcooper = par_cdcooper AND
                   crapagp.idevento = 1            AND /* Progrid */ 
                   crapagp.dtanoage = aux_dtanoage AND
                   crapagp.cdagenci = par_cdagenci NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crapagp  THEN
    DO:
        xDoc:CREATE-NODE(xRoot2,"ERRO","ELEMENT").
        xRoot:APPEND-CHILD(xRoot2).
        xDoc:CREATE-NODE(xText,"","TEXT").
        xRoot2:APPEND-CHILD(xText).
        xText:NODE-VALUE = "PA agrupador n�o cadastrado!".
    END.

FIND crapage WHERE crapage.cdcooper = crapagp.cdcooper AND
                   crapage.cdagenci = crapagp.cdagenci NO-LOCK NO-ERROR.

IF  AVAILABLE crapage  THEN
    ASSIGN aux_nmcidade = crapage.nmcidade.
ELSE
    ASSIGN aux_nmcidade = "".

/* Todos os eventos do PA liberados para a internet */
FOR EACH crapadp WHERE (crapadp.cdcooper =  par_cdcooper     AND
                        crapadp.idevento =  1                AND 
                        crapadp.cdagenci =  crapagp.cdageagr AND
                        crapadp.dtanoage =  aux_dtanoage     AND
                        crapadp.dtlibint <= TODAY            AND
                        crapadp.dtretint >= TODAY            AND
                        crapadp.idstaeve = 1)                OR
                       (crapadp.cdcooper =  par_cdcooper     AND
                        crapadp.idevento =  1                AND 
                        crapadp.cdagenci =  crapagp.cdageagr AND
                        crapadp.dtanoage =  aux_dtanoage     AND
                        crapadp.dtlibint <= TODAY            AND
                        crapadp.dtretint >= TODAY            AND
                        crapadp.idstaeve = 3)                OR
                       (crapadp.cdcooper =  par_cdcooper     AND
                        crapadp.idevento =  1                AND 
                        crapadp.cdagenci =  crapagp.cdageagr AND
                        crapadp.dtanoage =  aux_dtanoage     AND
                        crapadp.dtlibint <= TODAY            AND
                        crapadp.dtretint >= TODAY            AND
                        crapadp.idstaeve = 6)                NO-LOCK
                        BREAK BY crapadp.nrmeseve
                                 BY crapadp.dtinieve:

    /* Dados do evento */
    FIND crapedp WHERE crapedp.cdcooper = crapadp.cdcooper AND
                       crapedp.idevento = crapadp.idevento AND
                       crapedp.dtanoage = crapadp.dtanoage AND
                       crapedp.cdevento = crapadp.cdevento NO-LOCK NO-ERROR.
    
    /* Tipo de evento */
    IF  crapedp.tpevento = 1  OR   /* curso    */
        crapedp.tpevento = 3  OR   /* gincana  */
        crapedp.tpevento = 4  OR   /* palestra */
        crapedp.tpevento = 5  THEN /* teatro   */
        DO: 
            FIND FIRST craptab WHERE craptab.cdcooper = 0            AND
                                     craptab.nmsistem = "CRED"       AND
                                     craptab.tptabela = "CONFIG"     AND
                                     craptab.cdempres = 0            AND
                                     craptab.cdacesso = "PGTPEVENTO" AND
                                     craptab.tpregist = 0            
                                     NO-LOCK NO-ERROR.
            
            IF  AVAILABLE craptab  THEN
                ASSIGN aux_tpevento = ENTRY(LOOKUP(STRING(crapedp.tpevento),
                                        craptab.dstextab) - 1,craptab.dstextab).
            ELSE
                ASSIGN aux_tpevento = "".
        END.
    ELSE
        ASSIGN aux_tpevento = "Evento".

    FIND FIRST craptab WHERE craptab.cdcooper = 0            AND
                             craptab.nmsistem = "CRED"       AND
                             craptab.tptabela = "CONFIG"     AND
                             craptab.cdempres = 0            AND
                             craptab.cdacesso = "PGTPPARTIC" AND
                             craptab.tpregist = 0            NO-LOCK NO-ERROR.

    xDoc:CREATE-NODE(xRoot2,"EVENTO","ELEMENT").
    xRoot:APPEND-CHILD(xRoot2).
    
    /* Data de inicio do evento */
    IF  crapadp.dtinieve <> ?  THEN
        aux_dtinieve = STRING(crapadp.dtinieve,"99/99/9999").
    ELSE
        aux_dtinieve = vetormes[crapadp.nrmeseve].

    criaCampo("NMEVENTO",crapedp.nmevento).

    xField:SET-ATTRIBUTE("CDEVENTO",STRING(crapedp.cdevento)).
    
    criaCampo("DSEVENTO",CAPS(SUBSTRING(aux_tpevento,1,1)) + 
              LC(SUBSTRING(aux_tpevento,2))).
    
    criaCampo("DTINIEVE",aux_dtinieve).

    xField:SET-ATTRIBUTE("NRMESEVE",STRING(crapadp.nrmeseve)).

    criaCampo("QTMAXTUR",STRING(crapedp.qtmaxtur)).
    criaCampo("FLGCOMPR",STRING(crapedp.flgcompr)).
    criaCampo("TPPARTIC",ENTRY(LOOKUP(STRING(crapedp.tppartic),
                               craptab.dstextab) - 1, craptab.dstextab)).
    criaCampo("NRSEQDIG",STRING(crapadp.nrseqdig)).
    criaCampo("PRFREQUE",STRING(crapedp.prfreque)).

    /* Pa -> Codigo */
    criaCampo("NMCIDADE",STRING(aux_nmcidade)).
    criaCampo("DTANOAGE",STRING(crapadp.dtanoage)).
    
    aux_flgexist = TRUE.

END. /* Fim do FOR EACH crapadp */

IF  NOT aux_flgexist  THEN
    DO: 
        xDoc:CREATE-NODE(xRoot2,"ERRO","ELEMENT").
        xRoot:APPEND-CHILD(xRoot2).
        xDoc:CREATE-NODE(xText,"","TEXT").
        xRoot2:APPEND-CHILD(xText).
        xText:NODE-VALUE = "A agenda do seu PA ainda n�o esta liberada!".
    END.

xDoc:SAVE("STREAM","WEBSTREAM").

DELETE OBJECT xDoc.
DELETE OBJECT xRoot.
DELETE OBJECT xField.
DELETE OBJECT xText.
  
/*............................................................................*/
