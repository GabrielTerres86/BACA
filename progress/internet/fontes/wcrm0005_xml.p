/*..............................................................................

   Programa: wcrm0005_xml.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Junho/2006                   Ultima Atualizacao: 01/11/2016
   
   Dados referentes ao programa:
   
   Frequencia: Diario (internet)
   Objetivo  : Gerar arquivo XML para a tela wcrm0005-divulgação da programação
   
   Alteracoes: 03/11/2008 - Inclusao widget-pool (martin)
   
               17/08/2011 - Liberar alteracao efetuada no fonte em producao.
                            Nao tinha comentario sobre o ajuste, mas a alteracao
                            corrige o a leitura da agenda para PAC's que estao
                            agregados a outro PAC (David).
                            
               24/11/2011 - Ajuste na data da agenda (David).
               
               06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
 
			   29/10/2015 - Incluida verificacao de qtmaxtur na crapeap antes
                            da atribuicao da crapedp Projeto 229 (Jean Michel).
 
               27/06/2016 - Apensa apresentar os eventos que possuam data final 
                            de evento maior ou igual a data atual.
                            PRJ229 - Melhorias OQS (Odirlei-AMcom)
 
			   01/11/2016 - Correcao na query que filtra a agenda para filtrar
							a data correta ocasionando menos fetch na base
							SD 549857. (Carlos Rafael Tanholi)
..............................................................................*/
 
CREATE WIDGET-POOL.
 
DEFINE VARIABLE par_cdcooper AS INTEGER                                NO-UNDO.
DEFINE VARIABLE par_cdagenci AS INTEGER                                NO-UNDO.
DEFINE VARIABLE aux_qtmaxtur AS INTEGER                                NO-UNDO.
DEFINE VARIABLE aux_nmresage AS CHARACTER                              NO-UNDO.
DEFINE VARIABLE aux_dtinieve AS CHARACTER                              NO-UNDO.
DEFINE VARIABLE aux_flgexist AS LOGICAL   INIT FALSE                   NO-UNDO.
DEFINE VARIABLE aux_nmcidade AS CHARACTER                              NO-UNDO.
DEFINE VARIABLE aux_tpevento AS CHARACTER                              NO-UNDO.
DEFINE VARIABLE aux_dtanoage LIKE gnpapgd.dtanoage                     NO-UNDO.

DEFINE VARIABLE vetormes     AS CHAR EXTENT 12
       INITIAL ["JANEIRO","FEVEREIRO","MARÇO","ABRIL","MAIO","JUNHO",
                "JULHO","AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"]
                                                                       NO-UNDO.

/* Variaveis de controle do XML */
DEFINE VARIABLE xDoc         AS HANDLE                                 NO-UNDO.
DEFINE VARIABLE xRoot        AS HANDLE                                 NO-UNDO.
DEFINE VARIABLE xRoot2       AS HANDLE                                 NO-UNDO.
DEFINE VARIABLE xField       AS HANDLE                                 NO-UNDO.
DEFINE VARIABLE xText        AS HANDLE                                 NO-UNDO.

DEFINE BUFFER crabedp FOR crapedp.

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

/* Configura a saída como XML */
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
    aux_nmresage = "NÃO ENCONTRADO".

/* Cria a raiz principal */
xDoc:CREATE-NODE(xRoot,"CECRED","ELEMENT").
xDoc:APPEND-CHILD(xRoot).
xRoot:SET-ATTRIBUTE("CDAGENCI",STRING(par_cdagenci)).
xRoot:SET-ATTRIBUTE("NMRESAGE",aux_nmresage).

/* A agenda mostrada será sempre a do ano vigente */
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
        xText:NODE-VALUE = "PA agrupador não cadastrado!".
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
						crapadp.dtfineve >= (TODAY - 1)      AND						
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

	ASSIGN aux_qtmaxtur = 0.
	
	/*FIND crapeap WHERE crapeap.cdcooper = par_cdcooper AND
					   crapeap.idevento = 1            AND
					   crapeap.cdagenci = par_cdagenci AND
					   crapeap.cdevento = crapedp.cdevento AND
					   crapeap.dtanoage = crapadp.dtanoage NO-LOCK NO-ERROR NO-WAIT.
         
	ASSIGN aux_qtmaxtur = crapeap.qtmaxtur.
	
	IF aux_qtmaxtur <= 0 THEN
	  ASSIGN aux_qtmaxtur = crapedp.qtmaxtur.*/
    
    /***************/
        FIND FIRST crapeap WHERE crapeap.cdcooper = crapadp.cdcooper AND
                                 crapeap.idevento = crapadp.idevento AND                                     
                                 crapeap.cdevento = crapadp.cdevento AND
                                 crapeap.dtanoage = crapadp.dtanoage AND
                                 crapeap.cdagenci = crapadp.cdagenci NO-LOCK.
         
        IF AVAILABLE crapeap THEN
          DO:
            IF crapeap.qtmaxtur > 0 THEN
              ASSIGN aux_qtmaxtur = aux_qtmaxtur + crapeap.qtmaxtur.
            ELSE
              DO:
                /* para a frequencia minima */
                FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento AND 
                                         crabedp.cdcooper = crapadp.cdcooper AND
                                         crabedp.dtanoage = crapadp.dtanoage AND 
                                         crabedp.cdevento = crapadp.cdevento NO-LOCK. 
                IF AVAILABLE crabedp THEN
                  DO:
                    IF crabedp.qtmaxtur > 0 THEN
                      ASSIGN aux_qtmaxtur = aux_qtmaxtur + crabedp.qtmaxtur.
                    ELSE
                      DO:
                        FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento AND 
                                             crabedp.cdcooper = 0 AND
                                             crabedp.dtanoage = 0 AND 
                                             crabedp.cdevento = crapadp.cdevento NO-LOCK.
                                            
                        IF AVAILABLE crabedp THEN
                          ASSIGN aux_qtmaxtur = aux_qtmaxtur + crabedp.qtmaxtur.
                      END.
                  END.
              END.
          END.
        ELSE
          DO:
            /* para a frequencia minima */
            FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento AND 
                                     crabedp.cdcooper = crapadp.cdcooper AND
                                     crabedp.dtanoage = crapadp.dtanoage AND 
                                     crabedp.cdevento = crapadp.cdevento NO-LOCK. 
            IF AVAILABLE crabedp THEN
              DO:
                IF crabedp.qtmaxtur > 0 THEN
                  ASSIGN aux_qtmaxtur = aux_qtmaxtur + crabedp.qtmaxtur.
                ELSE
                  DO:
                    FIND FIRST crabedp WHERE crabedp.idevento = crapadp.idevento AND 
                                         crabedp.cdcooper = 0 AND
                                         crabedp.dtanoage = 0 AND 
                                         crabedp.cdevento = crapadp.cdevento NO-LOCK.
                                        
                    IF AVAILABLE crapedp THEN
                      ASSIGN aux_qtmaxtur = aux_qtmaxtur + crabedp.qtmaxtur.
                  END.
              END.
          END.
		  
        /****************/ 
		
    criaCampo("QTMAXTUR",STRING(aux_qtmaxtur)).
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
        xText:NODE-VALUE = "A agenda do seu PA ainda não esta liberada!".
    END.

xDoc:SAVE("STREAM","WEBSTREAM").

DELETE OBJECT xDoc.
DELETE OBJECT xRoot.
DELETE OBJECT xField.
DELETE OBJECT xText.
  
/*............................................................................*/