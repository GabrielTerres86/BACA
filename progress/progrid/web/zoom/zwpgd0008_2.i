/******************************** INCLUDE ZOOM *********************************
PROGRAMA.....:zwpgd0008_2.i
AUTOR........:B&T/Solusoft 
DESCRIÇÃO....:Zoom da Tabela de Recursos por Eventos

Alterações...: 15/12/2015 - Utilizar variaveis ValorCampo (Jean Michel).
               
               22/12/2015 - Utilizar "CAN-FIND" nas consultas da procedure
                            FindFirst e alterado display dos campos na
                            procura. Projeto 229 - Melhorias OQS (Lombardi).
*******************************************************************************/

&GLOBAL-DEFINE TituloDoPrograma Tabela de Recursos por Eventos
&GLOBAL-DEFINE NomeDoProgramaDeZoom zwpgd0008_2.w
&GLOBAL-DEFINE TabelaPadrao craprpe

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE CampoDePesquisa  gnaprdp.dsrecurs
&GLOBAL-DEFINE CampoDePesquisa1 crapage.nmresage
&GLOBAL-DEFINE CampoDePesquisa2 crapcop.nmrescop
&GLOBAL-DEFINE CampoDePesquisa3 craprpe.cdcopage
&GLOBAL-DEFINE CampoDePesquisa4 craprpe.cdagenci

/* *** Nomes dos campos de pesquisa. Deixar em branco as opções não usadas *** */
&GLOBAL-DEFINE NomeCampoDePesquisa  Recurso
&GLOBAL-DEFINE NomeCampoDePesquisa1 PA
&GLOBAL-DEFINE NomeCampoDePesquisa2 Cooperativa
&GLOBAL-DEFINE NomeCampoDePesquisa3 
&GLOBAL-DEFINE NomeCampoDePesquisa4 

/* *** Demais campos relacionados com o layout *** */
&GLOBAL-DEFINE CamposDisplay "<td class='txtNormal' height='22px'>&nbsp; &nbsp;" crapcop.nmrescop "</td><td class='txtNormal' height='22px'>&nbsp; &nbsp;" crapage.nmresage "</td>" "</td><td class='txtNormal' height='22px'>&nbsp; &nbsp;" gnaprdp.dsrecurs "</td><td class='txtNormal' height='22px'>&nbsp; &nbsp;" craprpe.qtrecage "</td><td class='txtNormal' height='22px'>&nbsp; &nbsp;" craprpe.qtgrppar "</td>"
&GLOBAL-DEFINE QuantidadeRecursos
&GLOBAL-DEFINE ListaDeCampos craprpe.nrseqdig craprpe.cdcopage craprpe.cdagenci craprpe.qtrecage craprpe.qtgrppar
&GLOBAL-DEFINE NomeDoProgramaPrincipal  /wpgd0008.w
&GLOBAL-DEFINE CampoChaveParaRetorno    craprpe.cdcopage
&GLOBAL-DEFINE CampoCompltoParaRetorno  craprpe.cdagenci 
&GLOBAL-DEFINE CampoCompltoParaRetorno2 craprpe.nrseqdig
&GLOBAL-DEFINE CampoCompltoParaRetorno3 craprpe.qtrecage
&GLOBAL-DEFINE CampoCompltoParaRetorno4 craprpe.qtgrppar

/* *** Linhas do cabecalho *** */
&GLOBAL-DEFINE LinhaDeCabecalho1 <td class="txtNormal" background="/cecred/images/menu/fnd_title.jpg" height="22px">&nbsp; &nbsp;Cooperativa</td><td class="txtNormal" background="/cecred/images/menu/fnd_title.jpg" height="22px">&nbsp; &nbsp;PA</td><td class="txtNormal" background="/cecred/images/menu/fnd_title.jpg" height="22px">&nbsp; &nbsp;Recurso </td><td class="txtNormal" background="/cecred/images/menu/fnd_title.jpg" height="22px">&nbsp; &nbsp;Qtde Por Evento </td><td class="txtNormal" background="/cecred/images/menu/fnd_title.jpg" height="22px">&nbsp; &nbsp;A cada "N" Participantes </td>
&GLOBAL-DEFINE LinhaDeCabecalho2 -------------------------------  -------------------------------   

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE Criterio MATCHES
&GLOBAL-DEFINE Criterio1 BEGINS
&GLOBAL-DEFINE Criterio2 =

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE NomeCriterio Contém 
&GLOBAL-DEFINE NomeCriterio1 Inicia
&GLOBAL-DEFINE NomeCriterio2 

DEFINE VARIABLE pesquisa            AS CHARACTER NO-UNDO.
DEFINE VARIABLE opcao-pesquisa      AS CHARACTER NO-UNDO.
DEFINE VARIABLE OpcaoNavegacao      AS CHARACTER NO-UNDO.
DEFINE VARIABLE NomeDoCampo         AS CHARACTER NO-UNDO.
DEFINE VARIABLE vtippesquisa        AS CHARACTER NO-UNDO.
DEFINE VARIABLE vcriterio           AS CHARACTER NO-UNDO.
DEFINE VARIABLE ContadorDeRegistros AS INTEGER   NO-UNDO.
DEFINE VARIABLE cdevento            AS INTEGER   NO-UNDO.
DEFINE VARIABLE conta               AS INTEGER   NO-UNDO.
DEFINE VARIABLE PonteiroDeInicio    AS ROWID     NO-UNDO. 
DEFINE VARIABLE PonteiroDeFim       AS ROWID     NO-UNDO.
DEFINE VARIABLE valorcampo          as CHAR      no-undo.
DEFINE VARIABLE aux_idevento            LIKE crapedp.idevento NO-UNDO.
DEFINE VARIABLE aux_cdevento            LIKE crapedp.idevento NO-UNDO.
DEFINE VARIABLE ValorCampo2			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo3			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo4			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo5			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo6			AS CHAR		 NO-UNDO.

DEFINE QUERY QueryPadrao FOR {&TabelaPadrao} FIELDS({&ListaDeCampos}), crapcop, crapage, gnaprdp SCROLLING.

ASSIGN pesquisa         = GET-VALUE("pesquisa")
       opcao-pesquisa   = SUBSTRING(pesquisa,1,1)
       pesquisa         = SUBSTRING(pesquisa,2,LENGTH(pesquisa))
       NomeDoCampo      = GET-VALUE("NomeDoCampo")
       PonteiroDeInicio = TO-ROWID(GET-VALUE("PonteiroDeInicio"))
       PonteiroDeFim    = TO-ROWID(GET-VALUE("PonteiroDeFim")) 
       vtippesquisa     = GET-VALUE("vtippesquisa")
       vcriterio        = GET-VALUE("vcriterio")
       OpcaoNavegacao   = GET-VALUE("btnopcao")
       aux_idevento     = INT(GET-VALUE("ValorCampo"))
       aux_cdevento     = INT(GET-VALUE("ValorCampo2"))
       ValorCampo       = GET-VALUE("ValorCampo")
	     ValorCampo2      = GET-VALUE("ValorCampo2")
	     ValorCampo3      = GET-VALUE("ValorCampo3")
	     ValorCampo4      = GET-VALUE("ValorCampo4")
	     ValorCampo5      = GET-VALUE("ValorCampo5")
	     ValorCampo6      = GET-VALUE("ValorCampo6").

PROCEDURE FindFirst:
  
  IF vtippesquisa = "{&NomeCampoDePesquisa2}"  AND "{&NomeCampoDePesquisa2}" <> "" THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN
      FOR FIRST {&TabelaPadrao} WHERE {&TabelaPadrao}.idevento = aux_idevento
                                  AND {&TabelaPadrao}.cdevento = aux_cdevento
                                  AND {&TabelaPadrao}.cdcooper = 0
                                  AND CAN-FIND(
          FIRST crapcop WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcopage
                          AND {&CampoDePesquisa2} {&Criterio} "*" + pesquisa + "*"
                          AND CAN-FIND(
          FIRST crapage WHERE crapage.cdcooper = crapcop.cdcooper
                          AND crapage.cdagenci = {&TabelaPadrao}.cdagenci
                          AND CAN-FIND(
          FIRST gnaprdp WHERE gnaprdp.nrseqdig = {&TabelaPadrao}.nrseqdig))) 
        NO-LOCK. /* BY crapcop.nmrescop BY crapage.nmresage BY gnaprdp.dsrecurs.*/
        MESSAGE "1-Cdevento: " + STRING(aux_cdevento).
      END.
    ELSE
    IF vcriterio = "{&NomeCriterio1}" THEN
      FOR FIRST {&TabelaPadrao} WHERE {&TabelaPadrao}.idevento = aux_idevento
                                  AND {&TabelaPadrao}.cdevento = aux_cdevento
                                  AND {&TabelaPadrao}.cdcooper = 0
                                  AND CAN-FIND(
        FIRST crapcop WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcopage
                        AND {&CampoDePesquisa2} {&Criterio1} pesquisa
                        AND CAN-FIND(
        FIRST crapage WHERE crapage.cdcooper = crapcop.cdcooper
                        AND crapage.cdagenci = {&TabelaPadrao}.cdagenci
                        AND CAN-FIND(
        FIRST gnaprdp WHERE gnaprdp.nrseqdig = {&TabelaPadrao}.nrseqdig)))
        NO-LOCK. /* BY crapcop.nmrescop BY crapage.nmresage BY gnaprdp.dsrecurs.*/
        MESSAGE "2-Cdevento: " + STRING(aux_cdevento).
      END.
    ELSE
      FOR FIRST {&TabelaPadrao} WHERE {&TabelaPadrao}.idevento = aux_idevento
                                  AND {&TabelaPadrao}.cdevento = aux_cdevento
                                  AND {&TabelaPadrao}.cdcooper = 0
                                  AND CAN-FIND(
        FIRST crapcop WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcopage
                        AND CAN-FIND(
        FIRST crapage WHERE crapage.cdcooper = crapcop.cdcooper
                        AND crapage.cdagenci = {&TabelaPadrao}.cdagenci
                        AND CAN-FIND(
        FIRST gnaprdp WHERE gnaprdp.nrseqdig = {&TabelaPadrao}.nrseqdig)))
        NO-LOCK. /* BY crapcop.nmrescop BY crapage.nmresage BY gnaprdp.dsrecurs.*/
        MESSAGE "3-Cdevento: " + STRING(aux_cdevento).
      END.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa1}"  AND "{&NomeCampoDePesquisa1}" <> "" THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN
      FOR FIRST {&TabelaPadrao} WHERE {&TabelaPadrao}.idevento = aux_idevento
                                  AND {&TabelaPadrao}.cdevento = aux_cdevento
                                  AND {&TabelaPadrao}.cdcooper = 0
                                  AND CAN-FIND(
        FIRST crapcop WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcopage
                        AND CAN-FIND(
        FIRST crapage WHERE crapage.cdcooper = crapcop.cdcooper
                        AND crapage.cdagenci = {&TabelaPadrao}.cdagenci
                        AND {&CampoDePesquisa1} {&Criterio} "*" + pesquisa + "*"
                        AND CAN-FIND(
        FIRST gnaprdp WHERE gnaprdp.nrseqdig = {&TabelaPadrao}.nrseqdig)))
        NO-LOCK. /*BY crapcop.nmrescop BY crapage.nmresage BY gnaprdp.dsrecurs.*/
        MESSAGE "4-Cdevento: " + STRING(aux_cdevento).
      END.
    ELSE
    IF vcriterio = "{&NomeCriterio1}" THEN
      FOR FIRST {&TabelaPadrao} WHERE {&TabelaPadrao}.idevento = aux_idevento
                                  AND {&TabelaPadrao}.cdevento = aux_cdevento
                                  AND {&TabelaPadrao}.cdcooper = 0
                                  AND CAN-FIND(
        FIRST crapcop WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcopage
                        AND CAN-FIND(
        FIRST crapage WHERE crapage.cdcooper = crapcop.cdcooper
                        AND crapage.cdagenci = {&TabelaPadrao}.cdagenci
                        AND {&CampoDePesquisa1} {&Criterio1} pesquisa
                        AND CAN-FIND(
        FIRST gnaprdp WHERE gnaprdp.nrseqdig = {&TabelaPadrao}.nrseqdig)))
        NO-LOCK. /* BY crapcop.nmrescop BY crapage.nmresage BY gnaprdp.dsrecurs.*/
        MESSAGE "5-Cdevento: " + STRING(aux_cdevento).
      END.
    ELSE
      FOR FIRST {&TabelaPadrao} WHERE {&TabelaPadrao}.idevento = aux_idevento
                                  AND {&TabelaPadrao}.cdevento = aux_cdevento
                                  AND {&TabelaPadrao}.cdcooper = 0
                                  AND CAN-FIND(
        FIRST crapcop WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcopage
                        AND CAN-FIND(
        FIRST crapage WHERE crapage.cdcooper = crapcop.cdcooper
                        AND crapage.cdagenci = {&TabelaPadrao}.cdagenci
                        AND CAN-FIND(
        FIRST gnaprdp WHERE gnaprdp.nrseqdig = {&TabelaPadrao}.nrseqdig)))
        NO-LOCK. /* BY crapcop.nmrescop BY crapage.nmresage BY gnaprdp.dsrecurs.*/
        MESSAGE "6-Cdevento: " + STRING(aux_cdevento).
      END.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa}"  AND "{&NomeCampoDePesquisa}" <> "" THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN
      FOR FIRST {&TabelaPadrao} WHERE {&TabelaPadrao}.idevento = aux_idevento
                                  AND {&TabelaPadrao}.cdevento = aux_cdevento
                                  AND {&TabelaPadrao}.cdcooper = 0
                                  AND CAN-FIND(
        FIRST crapcop WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcopage
                        AND CAN-FIND(
        FIRST crapage WHERE crapage.cdcooper = crapcop.cdcooper
                        AND crapage.cdagenci = {&TabelaPadrao}.cdagenci
                        AND CAN-FIND(
        FIRST gnaprdp WHERE gnaprdp.nrseqdig = {&TabelaPadrao}.nrseqdig
                        AND {&CampoDePesquisa} {&Criterio} "*" + pesquisa + "*")))
        NO-LOCK. /* BY crapcop.nmrescop BY crapage.nmresage BY gnaprdp.dsrecurs.*/
        MESSAGE "7-Cdevento: " + STRING(aux_cdevento).
      END.
    ELSE
    IF vcriterio = "{&NomeCriterio1}" THEN
      FOR FIRST {&TabelaPadrao} WHERE {&TabelaPadrao}.idevento = aux_idevento
                                  AND {&TabelaPadrao}.cdevento = aux_cdevento
                                  AND {&TabelaPadrao}.cdcooper = 0
                                  AND CAN-FIND(
        FIRST crapcop WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcopage
                        AND CAN-FIND(
        FIRST crapage WHERE crapage.cdcooper = crapcop.cdcooper
                        AND crapage.cdagenci = {&TabelaPadrao}.cdagenci
                        AND CAN-FIND(
        FIRST gnaprdp WHERE gnaprdp.nrseqdig = {&TabelaPadrao}.nrseqdig
                        AND {&CampoDePesquisa} {&Criterio1} pesquisa )))
        NO-LOCK. /* BY crapcop.nmrescop BY crapage.nmresage BY gnaprdp.dsrecurs.*/
        MESSAGE "8-Cdevento: " + STRING(aux_cdevento).
      END.
    ELSE
      FOR FIRST {&TabelaPadrao} WHERE {&TabelaPadrao}.idevento = aux_idevento
                                  AND {&TabelaPadrao}.cdevento = aux_cdevento
                                  AND {&TabelaPadrao}.cdcooper = 0
                                  AND CAN-FIND( 
        FIRST crapcop WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcopage
                        AND CAN-FIND(
        FIRST crapage WHERE crapage.cdcooper = crapcop.cdcooper
                        AND crapage.cdagenci = {&TabelaPadrao}.cdagenci
                        AND CAN-FIND(
        FIRST gnaprdp WHERE gnaprdp.nrseqdig = {&TabelaPadrao}.nrseqdig )))
        NO-LOCK. /* BY crapcop.nmrescop BY crapage.nmresage BY gnaprdp.dsrecurs.*/
        MESSAGE "9-Cdevento: " + STRING(aux_cdevento).
      END.
  END.

END PROCEDURE.

PROCEDURE OpenQuery:
  
  IF vtippesquisa = "{&NomeCampoDePesquisa2}" AND "{&NomeCampoDePesquisa2}" <> ""  THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN
      DO:
        OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} NO-LOCK WHERE {&TabelaPadrao}.idevento = aux_idevento
                                                                  AND {&TabelaPadrao}.cdevento = aux_cdevento
                                                                  AND {&TabelaPadrao}.cdcooper = 0,
                               EACH crapcop NO-LOCK WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcopage
                                                      AND {&CampoDePesquisa2} {&Criterio} "*" + pesquisa + "*",
                               EACH crapage NO-LOCK WHERE crapage.cdcooper = crapcop.cdcooper
                                                      AND crapage.cdagenci = {&TabelaPadrao}.cdagenci,
                               FIRST gnaprdp NO-LOCK WHERE gnaprdp.nrseqdig = {&TabelaPadrao}.nrseqdig
                               /*BY crapcop.nmrescop BY crapage.nmresage BY gnaprdp.dsrecurs*/ INDEXED-REPOSITION MAX-ROWS 10.
         MESSAGE "10-Cdevento: " + STRING(aux_cdevento).
      END.
    ELSE
    IF vcriterio = "{&NomeCriterio1}" THEN
      DO:
        OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} NO-LOCK WHERE {&TabelaPadrao}.idevento = aux_idevento
                                                                  AND {&TabelaPadrao}.cdevento = aux_cdevento
                                                                  AND {&TabelaPadrao}.cdcooper = 0,
                               EACH crapcop NO-LOCK WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcopage
                                                      AND {&CampoDePesquisa2} {&Criterio1} pesquisa,
                               EACH crapage NO-LOCK WHERE crapage.cdcooper = crapcop.cdcooper
                                                      AND crapage.cdagenci = {&TabelaPadrao}.cdagenci,
                               FIRST gnaprdp NO-LOCK WHERE gnaprdp.nrseqdig = {&TabelaPadrao}.nrseqdig
                               /*BY crapcop.nmrescop BY crapage.nmresage BY gnaprdp.dsrecurs*/ INDEXED-REPOSITION MAX-ROWS 10.
        MESSAGE "11-Cdevento: " + STRING(aux_cdevento).                       
      END.
    ELSE
      DO:
        OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} NO-LOCK WHERE {&TabelaPadrao}.idevento = aux_idevento
                                                                  AND {&TabelaPadrao}.cdevento = aux_cdevento
                                                                  AND {&TabelaPadrao}.cdcooper = 0,
                               EACH crapcop NO-LOCK WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcopage,
                               EACH crapage NO-LOCK WHERE crapage.cdcooper = crapcop.cdcooper
                                              AND crapage.cdagenci = {&TabelaPadrao}.cdagenci,
                               FIRST gnaprdp NO-LOCK WHERE gnaprdp.nrseqdig = {&TabelaPadrao}.nrseqdig
                               /*BY crapcop.nmrescop BY crapage.nmresage BY gnaprdp.dsrecurs*/ INDEXED-REPOSITION MAX-ROWS 10.
        MESSAGE "12-Cdevento: " + STRING(aux_cdevento). 
      END.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa1}"  AND "{&NomeCampoDePesquisa1}" <> "" THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN
      DO:
        OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} NO-LOCK WHERE {&TabelaPadrao}.idevento = aux_idevento
                                                                  AND {&TabelaPadrao}.cdevento = aux_cdevento
                                                                  AND {&TabelaPadrao}.cdcooper = 0,
                               EACH crapcop NO-LOCK WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcopage,
                               EACH crapage NO-LOCK WHERE crapage.cdcooper = crapcop.cdcooper
                                                      AND crapage.cdagenci = {&TabelaPadrao}.cdagenci
                                                      AND {&CampoDePesquisa1} {&Criterio} "*" + pesquisa + "*",
                               FIRST gnaprdp NO-LOCK WHERE gnaprdp.nrseqdig = {&TabelaPadrao}.nrseqdig
                               /*BY crapcop.nmrescop BY crapage.nmresage BY gnaprdp.dsrecurs*/ INDEXED-REPOSITION MAX-ROWS 10.   
        MESSAGE "13-Cdevento: " + STRING(aux_cdevento). 
      END.
    ELSE
    IF vcriterio = "{&NomeCriterio1}" THEN
      DO:
        OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} NO-LOCK WHERE {&TabelaPadrao}.idevento = aux_idevento
                                                                  AND {&TabelaPadrao}.cdevento = aux_cdevento
                                                                  AND {&TabelaPadrao}.cdcooper = 0,
                               EACH crapcop NO-LOCK WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcopage,
                               EACH crapage NO-LOCK WHERE crapage.cdcooper = crapcop.cdcooper
                                                      AND crapage.cdagenci = {&TabelaPadrao}.cdagenci
                                                      AND {&CampoDePesquisa1} {&Criterio1} pesquisa,
                               FIRST gnaprdp NO-LOCK WHERE gnaprdp.nrseqdig = {&TabelaPadrao}.nrseqdig
                               /*BY crapcop.nmrescop BY crapage.nmresage BY gnaprdp.dsrecurs*/ INDEXED-REPOSITION MAX-ROWS 10.
        MESSAGE "14-Cdevento: " + STRING(aux_cdevento).
      END.
    ELSE
      DO:
        OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} NO-LOCK WHERE {&TabelaPadrao}.idevento = aux_idevento
                                                                  AND {&TabelaPadrao}.cdevento = aux_cdevento
                                                                  AND {&TabelaPadrao}.cdcooper = 0,
                               EACH crapcop NO-LOCK WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcopage,
                               EACH crapage NO-LOCK WHERE crapage.cdcooper = crapcop.cdcooper
                                              AND crapage.cdagenci = {&TabelaPadrao}.cdagenci,
                               FIRST gnaprdp NO-LOCK WHERE gnaprdp.nrseqdig = {&TabelaPadrao}.nrseqdig
                               /*BY crapcop.nmrescop BY crapage.nmresage BY gnaprdp.dsrecurs*/ INDEXED-REPOSITION MAX-ROWS 10.
        MESSAGE "15-Cdevento: " + STRING(aux_cdevento).                       
      END.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa}"  AND "{&NomeCampoDePesquisa}" <> "" THEN DO:
    
    IF vcriterio = "{&NomeCriterio}" THEN
      DO:
        OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} NO-LOCK WHERE {&TabelaPadrao}.idevento = aux_idevento
                                                                  AND {&TabelaPadrao}.cdevento = aux_cdevento
                                                                  AND {&TabelaPadrao}.cdcooper = 0,
                               EACH crapcop NO-LOCK WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcopage,
                               EACH crapage NO-LOCK WHERE crapage.cdcooper = crapcop.cdcooper
                                                      AND crapage.cdagenci = {&TabelaPadrao}.cdagenci,
                               FIRST gnaprdp NO-LOCK WHERE gnaprdp.nrseqdig = {&TabelaPadrao}.nrseqdig
                                                       AND {&CampoDePesquisa} {&Criterio} "*" + pesquisa + "*"
                               /*BY crapcop.nmrescop BY crapage.nmresage BY gnaprdp.dsrecurs*/ INDEXED-REPOSITION MAX-ROWS 10.
        MESSAGE "16-Cdevento: " + STRING(aux_cdevento).                       
      END.
    ELSE
      IF vcriterio = "{&NomeCriterio1}" THEN DO:
        OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} NO-LOCK WHERE {&TabelaPadrao}.idevento = aux_idevento
                                                                  AND {&TabelaPadrao}.cdevento = aux_cdevento
                                                                  AND {&TabelaPadrao}.cdcooper = 0,
                               EACH crapcop NO-LOCK WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcopage,
                               EACH crapage NO-LOCK WHERE crapage.cdcooper = crapcop.cdcooper
                                              AND crapage.cdagenci = {&TabelaPadrao}.cdagenci,
                               FIRST gnaprdp NO-LOCK WHERE gnaprdp.nrseqdig = {&TabelaPadrao}.nrseqdig
                                                       AND {&CampoDePesquisa} {&Criterio1} pesquisa
                               /*BY crapcop.nmrescop BY crapage.nmresage BY gnaprdp.dsrecurs*/ INDEXED-REPOSITION MAX-ROWS 10.
        MESSAGE "17-Cdevento: " + STRING(aux_cdevento).                       
      END.
    ELSE
      DO:
        OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} NO-LOCK WHERE {&TabelaPadrao}.idevento = aux_idevento
                                                                  AND {&TabelaPadrao}.cdevento = aux_cdevento
                                                                  AND {&TabelaPadrao}.cdcooper = 0,
                               EACH crapcop NO-LOCK WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcopage,
                               EACH crapage NO-LOCK WHERE crapage.cdcooper = crapcop.cdcooper
                                              AND crapage.cdagenci = {&TabelaPadrao}.cdagenci,
                               FIRST gnaprdp NO-LOCK WHERE gnaprdp.nrseqdig = {&TabelaPadrao}.nrseqdig
                               /*BY crapcop.nmrescop BY crapage.nmresage BY gnaprdp.dsrecurs*/ INDEXED-REPOSITION MAX-ROWS 10.
        MESSAGE "18-Cdevento: " + STRING(aux_cdevento).                                              
      END.  
  END.

END PROCEDURE.

PROCEDURE TrocaCaracter:
END PROCEDURE.

PROCEDURE PosicionaPonteiro:
END PROCEDURE.

