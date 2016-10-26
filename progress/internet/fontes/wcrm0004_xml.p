/*..............................................................................................
   Programa: wcrm0004_xml.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Junho/2006                   Ultima Atualizacao: 26/08/2016
   Dados referentes ao programa:
   Frequencia: Diario (internet)
   Objetivo  : Gerar arquivo XML para a tela wcrm0004 - historico do cooperado
   Alteracoes:
               03/11/2008 - Inclusao widget-pool (Martin)
			         
               03/10/2012 - Tratamento para listagem de eventos de contas migradas (Lucas).
               
               11/01/2013 - Incluida condicao (craptco.tpctatrf <> 3) na
                            busca da craptco (Tiago).
                            
               06/10/2015 - Alterar forma do for each crapidp para utilizar o 
                            indice e listar os eventos corretamente (Lucas Ranghetti #328446)
														
							 26/08/2016 - Alteração para impressão do certificado, Prj. 229 (Jean Michel).							
														
..............................................................................................*/
 
create widget-pool.
 
DEFINE VARIABLE par_cdcooper AS INTEGER                               NO-UNDO.
DEFINE VARIABLE par_nrdconta AS INTEGER                               NO-UNDO.
DEFINE VARIABLE par_dtinihis AS DATE                                  NO-UNDO.
DEFINE VARIABLE par_dtfimhis AS DATE                                  NO-UNDO.
DEFINE VARIABLE par_idseqttl AS INTEGER                               NO-UNDO.
DEFINE VARIABLE aux_dtinieve AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_dtfineve AS CHARACTER                             NO-UNDO.
DEFINE VARIABLE aux_flgexist AS LOGICAL         INIT FALSE            NO-UNDO.
DEFINE VARIABLE aux_nrctaant AS INTE                           		  NO-UNDO.
DEFINE VARIABLE aux_cdcopant AS INTE                          		  NO-UNDO.
DEFINE VARIABLE aux_nmevento AS CHAR                          		  NO-UNDO.
DEFINE VARIABLE aux_lsmesctb AS CHAR                          		  NO-UNDO.

/* Variaveis de controle do XML */
DEFINE VARIABLE xDoc         AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xRoot        AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xRoot2       AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xRoot3       AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xField       AS HANDLE                                NO-UNDO.
DEFINE VARIABLE xText        AS HANDLE                                NO-UNDO.

/* Cria um campo com seu valor no XML */
FUNCTION criaCampo RETURNS LOGICAL
    (INPUT nomeCampo  AS CHAR,
     INPUT textoCampo AS CHAR):
    xDoc:CREATE-NODE(xField,CAPS(nomeCampo),"ELEMENT").
    xRoot3:APPEND-CHILD(xField).
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
       par_idseqttl = INT(GET-VALUE("aux_idseqttl"))
       par_dtinihis = DATE(GET-VALUE("aux_dtinihis"))
       par_dtfimhis = DATE(GET-VALUE("aux_dtfimhis")).
       
CREATE X-DOCUMENT xDoc.
CREATE X-NODEREF  xRoot.
CREATE X-NODEREF  xRoot2.
CREATE X-NODEREF  xRoot3.
CREATE X-NODEREF  xField.
CREATE X-NODEREF  xText.

/* Cria a raiz principal */
xDoc:CREATE-NODE( xRoot, "CECRED", "ELEMENT" ).
xDoc:APPEND-CHILD( xRoot ).

/* Verificar se eh conta migrada */
FIND craptco WHERE craptco.cdcooper = par_cdcooper AND
				           craptco.nrdconta = par_nrdconta AND
                   craptco.tpctatrf <> 3          
				           NO-LOCK NO-ERROR NO-WAIT.

IF  AVAIL craptco THEN
	  ASSIGN aux_cdcopant = craptco.cdcopant
		       aux_nrctaant = craptco.nrctaant.
ELSE
	  ASSIGN aux_cdcopant = par_cdcooper
		       aux_nrctaant = par_nrdconta.

/* Inscrições feitas na conta */
FOR EACH crapidp WHERE (crapidp.cdcooper =  par_cdcooper 	   AND
                        crapidp.nrdconta =  par_nrdconta     AND
                        crapidp.idseqttl =  par_idseqttl     AND 
                        crapidp.idstains =  2)                OR
                       (crapidp.cdcooper =  aux_cdcopant     AND
                        crapidp.nrdconta =  aux_nrctaant     AND
                        crapidp.idseqttl =  par_idseqttl     AND 
                        crapidp.idstains =  2)               NO-LOCK, /*2=confirmado*/
    EACH crapadp WHERE  crapadp.idevento =  crapidp.idevento AND  
                        crapadp.cdcooper =  crapidp.cdcooper AND
                        crapadp.dtanoage =  crapidp.dtanoage AND
                        crapadp.cdevento =  crapidp.cdevento AND
                        crapadp.nrseqdig =  crapidp.nrseqeve AND
                        crapadp.dtinieve >= par_dtinihis     AND
                        crapadp.dtfineve <= par_dtfimhis     NO-LOCK
                        BREAK BY crapidp.nminseve
                              BY crapadp.dtinieve DESC
                              BY crapidp.nrseqeve:
    
    /* Dados do evento */
    FIND crapedp WHERE crapedp.idevento = crapidp.idevento
                   AND crapedp.cdcooper = crapidp.cdcooper
                   AND crapedp.dtanoage = crapidp.dtanoage
                   AND crapedp.cdevento = crapidp.cdevento NO-LOCK NO-ERROR.
           
    IF FIRST-OF(crapidp.nrseqeve) THEN
        DO:                               
            /* Se percentual de faltas passar do percentual mínimo exigido, nao pode considerar */
            IF ((crapidp.qtfaleve * 100) / crapadp.qtdiaeve) > (100 - crapedp.prfreque)   THEN
              NEXT.
            
            /* Datas de inicio e fim do evento */
            IF   crapadp.dtinieve <> ?   THEN
                 aux_dtinieve = STRING(crapadp.dtinieve,"99/99/9999").
            ELSE
                 aux_dtinieve = "Indefinido".
           
            IF   crapadp.dtfineve <> ?   THEN
                 aux_dtfineve = STRING(crapadp.dtfineve,"99/99/9999").
            ELSE
                 aux_dtfineve = "Indefinido".
				 
            /* Nome do inscrito */
            IF   FIRST-OF(crapidp.nminseve)   THEN
                 DO:
                     xDoc:CREATE-NODE( xRoot2, "ASSOCIADO", "ELEMENT" ).
                     xRoot:APPEND-CHILD( xRoot2 ).
                     xRoot2:SET-ATTRIBUTE("NMINSEVE",crapidp.nminseve).
                 END.
				 
            IF aux_cdcopant <> par_cdcooper    AND
               crapidp.cdcooper = aux_cdcopant AND
               crapidp.nrdconta = aux_nrctaant THEN
               DO:
                   FIND crapcop WHERE crapcop.cdcooper = aux_cdcopant
                                NO-LOCK NO-ERROR NO-WAIT.
                                
                                
                   ASSIGN aux_nmevento = STRING(crapedp.nmevento + " (" + CAPS(crapcop.nmrescop) + ")").

                    xDoc:CREATE-NODE( xRoot3, "EVENTO", "ELEMENT" ).
                    xRoot2:APPEND-CHILD( xRoot3 ).
                    
                    FOR FIRST gnpapgd FIELDS(lsmesctb) WHERE gnpapgd.idevento = crapidp.idevento
                                                         AND gnpapgd.cdcooper = crapidp.cdcooper
                                                         AND gnpapgd.dtanoage = crapidp.dtanoage NO-LOCK. END.

                    
                    IF CAN-DO(gnpapgd.lsmesctb,STRING(INT(SUBSTR(aux_dtfineve,4,2)))) THEN
                      DO:
                        ASSIGN aux_lsmesctb = "1".
                      END.
                    ELSE
                      DO:
                        ASSIGN aux_lsmesctb = "0".
                      END.
                    
                    criaCampo("NMEVENTO",aux_nmevento).
                    criaCampo("DTINIEVE",aux_dtinieve).
                    criaCampo("DTFINEVE",aux_dtfineve).
                    criaCampo("FLGCERTI",STRING(INT(crapedp.flgcerti))).
                    criaCampo("LSMESCTB",STRING(INT(aux_lsmesctb))).
                    criaCampo("TPEVENTO",STRING(crapedp.tpevento)).
                    criaCampo("DTANOAGE",STRING(crapidp.dtanoage)).
                    criaCampo("IDEVENTO",STRING(crapidp.idevento)).
                    criaCampo("CDEVENTO",STRING(crapidp.cdevento)).
                    criaCampo("CDAGENCI",STRING(crapidp.cdagenci)).
                    criaCampo("NRSEQEVE",STRING(crapidp.nrseqeve)).
										
                    aux_flgexist = TRUE.

                   NEXT.

               END.				 
				
            xDoc:CREATE-NODE( xRoot3, "EVENTO", "ELEMENT" ).
            xRoot2:APPEND-CHILD( xRoot3 ).
            
            FOR FIRST gnpapgd FIELDS(lsmesctb) WHERE gnpapgd.idevento = crapidp.idevento
                                                 AND gnpapgd.cdcooper = crapidp.cdcooper
                                                 AND gnpapgd.dtanoage = crapidp.dtanoage NO-LOCK. END.

            
            IF CAN-DO(gnpapgd.lsmesctb,STRING(INT(SUBSTR(aux_dtfineve,4,2)))) THEN
              DO:
                ASSIGN aux_lsmesctb = "1".
              END.
            ELSE
              DO:
                ASSIGN aux_lsmesctb = "0".
              END.
              
            criaCampo("NMEVENTO",crapedp.nmevento).
            criaCampo("DTINIEVE",aux_dtinieve).
            criaCampo("DTFINEVE",aux_dtfineve).
            criaCampo("FLGCERTI",STRING(INT(crapedp.flgcerti))).
            criaCampo("LSMESCTB",STRING(aux_lsmesctb)).
						criaCampo("TPEVENTO",STRING(crapedp.tpevento)).
            criaCampo("DTANOAGE",STRING(crapidp.dtanoage)).
            criaCampo("IDEVENTO",STRING(crapidp.idevento)).
            criaCampo("CDEVENTO",STRING(crapidp.cdevento)).
            criaCampo("CDAGENCI",STRING(crapidp.cdagenci)).
            criaCampo("NRSEQEVE",STRING(crapidp.nrseqeve)).
                    
            aux_flgexist = TRUE.
        END.
END.
                       
IF   NOT aux_flgexist   THEN
     DO:
         /* Cria o elemento de erro no XML */
         xDoc:CREATE-NODE( xRoot2, "ERRO", "ELEMENT" ).
         xRoot:APPEND-CHILD( xRoot2 ).
         xDoc:CREATE-NODE(xText,"","TEXT").
         xRoot2:APPEND-CHILD(xText).
         xText:NODE-VALUE = "Não há registros de histórico para as datas informadas!".
     END.
     
xDoc:SAVE("STREAM","WEBSTREAM").

DELETE OBJECT xDoc.
DELETE OBJECT xRoot.
DELETE OBJECT xField.
DELETE OBJECT xText.