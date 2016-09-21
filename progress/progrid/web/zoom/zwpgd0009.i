/******************************** INCLUDE ZOOM *********************************
PROGRAMA.....:zwpgd0009.i
AUTOR........:B&T/Solusoft 
DESCRIÇÃO....:Zoom da Tabela de Inscrições

Alterações...: 11/12/2008 - Melhoria de performance para a tabela gnapses
				          - Utilizar variaveis ValorCampo
						  - Carregar a situação (Guilherme).
						  
			   05/05/2009 - Utilizar cdcooper = 0 nas consultas (David).

			   05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
				              busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
                      
         02/02/2016 - Ajustes na consulta para Prj. 229. (Jean Michel)             
							
*******************************************************************************/

&GLOBAL-DEFINE TituloDoPrograma Tabela de Inscrições 
&GLOBAL-DEFINE NomeDoProgramaDeZoom zwpgd0009.w
&GLOBAL-DEFINE TabelaPadrao crapidp

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE CampoDePesquisa  crapidp.nminseve
&GLOBAL-DEFINE CampoDePesquisa1 crapidp.nrdconta
&GLOBAL-DEFINE CampoDePesquisa2 crapidp.nminseve
&GLOBAL-DEFINE CampoDePesquisa3 crapidp.nminseve

/* *** Nomes dos campos de pesquisa. Deixar em branco as opções não usadas *** */
&GLOBAL-DEFINE NomeCampoDePesquisa  Inscrito
&GLOBAL-DEFINE NomeCampoDePesquisa1 Conta
&GLOBAL-DEFINE NomeCampoDePesquisa2 
&GLOBAL-DEFINE NomeCampoDePesquisa3 

/* *** Demais campos relacionados com o layout *** */
&GLOBAL-DEFINE CamposDisplay "<td class='txtNormal' height='22px'>&nbsp; &nbsp;" crapidp.nminseve FORMAT "x(80)" "</td>" "<td class='txtNormal' height='22px'>&nbsp; &nbsp;" crapidp.nrdconta "</td>" "<td class='txtNormal' height='22px'>&nbsp; &nbsp;" aux_dsstatus "</td>"
&GLOBAL-DEFINE ListaDeCampos crapidp.nminseve crapidp.idevento crapidp.nrseqdig crapidp.idstains crapidp.cdcooper crapidp.cdagenci crapidp.cdevento crapidp.nrdconta
&GLOBAL-DEFINE NomeDoProgramaPrincipal  /wpgd0009.w
&GLOBAL-DEFINE CampoChaveParaRetorno    crapidp.nrseqdig
&GLOBAL-DEFINE CampoCompltoParaRetorno   
&GLOBAL-DEFINE CampoCompltoParaRetorno2 

/* *** Linhas do cabecalho *** */
&GLOBAL-DEFINE LinhaDeCabecalho1 <td background="/cecred/images/menu/fnd_title.jpg" class="txtNormal" height="22px">&nbsp; &nbsp;Inscrito</td> <td background="/cecred/images/menu/fnd_title.jpg" class="txtNormal" height="22px">&nbsp; &nbsp;Conta</td> <td background="/cecred/images/menu/fnd_title.jpg" class="txtNormal" height="22px">&nbsp; &nbsp;Situação</td>
&GLOBAL-DEFINE LinhaDeCabecalho2 -------------------------------

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE Criterio  MATCHES
&GLOBAL-DEFINE Criterio1 BEGINS
&GLOBAL-DEFINE Criterio2 =

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE NomeCriterio  Contém
&GLOBAL-DEFINE NomeCriterio1 Inicia
&GLOBAL-DEFINE NomeCriterio2 

DEFINE VARIABLE pesquisa            AS CHARACTER NO-UNDO.
DEFINE VARIABLE opcao-pesquisa      AS CHARACTER NO-UNDO.
DEFINE VARIABLE OpcaoNavegacao      AS CHARACTER NO-UNDO.
DEFINE VARIABLE NomeDoCampo         AS CHARACTER NO-UNDO.
DEFINE VARIABLE vtippesquisa        AS CHARACTER NO-UNDO.
DEFINE VARIABLE vcriterio           AS CHARACTER NO-UNDO.
DEFINE VARIABLE ContadorDeRegistros AS INTEGER   NO-UNDO.
DEFINE VARIABLE conta               AS INTEGER   NO-UNDO.
DEFINE VARIABLE PonteiroDeInicio    AS ROWID     NO-UNDO. 
DEFINE VARIABLE PonteiroDeFim       AS ROWID     NO-UNDO.
DEFINE VARIABLE valorcampo          as CHAR      no-undo.
DEFINE VARIABLE v-identificacao     AS CHAR      NO-UNDO.
DEFINE VARIABLE ValorCampo2			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo3			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo4			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo5			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo6			AS CHAR		 NO-UNDO.

DEFINE VARIABLE aux_nmrescop        AS CHAR      NO-UNDO.
DEFINE VARIABLE aux_nmresage        AS CHAR      NO-UNDO.
DEFINE VARIABLE aux_dsstatus        AS CHAR      NO-UNDO.
DEFINE VARIABLE aux_nrseqeve        AS INT       NO-UNDO.

DEFINE QUERY QueryPadrao FOR {&TabelaPadrao} FIELDS({&ListaDeCampos}) SCROLLING.

ASSIGN pesquisa         = GET-VALUE("pesquisa")
       opcao-pesquisa   = SUBSTRING(pesquisa,1,1)
       pesquisa         = SUBSTRING(pesquisa,2,LENGTH(pesquisa))
       NomeDoCampo      = GET-VALUE("NomeDoCampo")
       PonteiroDeInicio = TO-ROWID(GET-VALUE("PonteiroDeInicio"))
       PonteiroDeFim    = TO-ROWID(GET-VALUE("PonteiroDeFim")) 
       vtippesquisa     = GET-VALUE("vtippesquisa")
       vcriterio        = GET-VALUE("vcriterio")
       OpcaoNavegacao   = GET-VALUE("btnopcao")
       valorcampo       = GET-VALUE("valorcampo")
       aux_nrseqeve     = INT(GET-VALUE("ValorCampo"))
	     ValorCampo2      = GET-VALUE("ValorCampo2")
	     ValorCampo3      = GET-VALUE("ValorCampo3")
	     ValorCampo4      = GET-VALUE("ValorCampo4")
	     ValorCampo5      = GET-VALUE("ValorCampo5")
	     ValorCampo6      = GET-VALUE("ValorCampo6").

v-identificacao = get-cookie("cookie-usuario-em-uso").

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + v-identificacao + "*" NO-LOCK:
	LEAVE.
END.

PROCEDURE FindFirst:
  
  /* NOME DO INSCRITO */
  IF vtippesquisa = "{&NomeCampoDePesquisa}"  AND "{&NomeCampoDePesquisa}" <> "" THEN 
    DO:
      
      IF vcriterio = "{&NomeCriterio1}" THEN
        DO:
        
          CASE gnapses.nvoperad:
              /* Pessoal da CECRED */
              WHEN 0 THEN
              DO:
                  FIND FIRST {&TabelaPadrao} 
                      WHERE {&CampoDePesquisa} {&Criterio1} pesquisa AND 
                      crapidp.nrseqeve = aux_nrseqeve
                      NO-LOCK NO-WAIT NO-ERROR.
              END.
              /* Operadores e Supervisores */
              WHEN 1 OR
              WHEN 2 THEN
              DO:
                  FIND FIRST {&TabelaPadrao} 
                      WHERE {&CampoDePesquisa} {&Criterio1} pesquisa    AND
                           {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
                           {&TabelaPadrao}.cdagenci = gnapses.cdagenci AND 
                           crapidp.nrseqeve = aux_nrseqeve
                      NO-LOCK NO-WAIT NO-ERROR.
              END.
              /* Gerentes */
              WHEN 3 THEN
              DO:
                  FIND FIRST {&TabelaPadrao}  WHERE 
                      {&CampoDePesquisa} {&Criterio1} pesquisa AND
                      {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND 
                      crapidp.nrseqeve = aux_nrseqeve 
                      NO-LOCK NO-WAIT NO-ERROR.
              END.
          END CASE.
        END.
      ELSE IF vcriterio = "{&NomeCriterio}" THEN
        DO:
      
          CASE gnapses.nvoperad:
              /* Pessoal da CECRED */
              WHEN 0 THEN
              DO:
                  FIND FIRST {&TabelaPadrao} 
                      WHERE STRING({&CampoDePesquisa}) {&Criterio} "*" + string(pesquisa) + "*" AND
                      crapidp.nrseqeve = aux_nrseqeve 
                      NO-LOCK NO-WAIT NO-ERROR.
              END.
              /* Operadores e Supervisores */
              WHEN 1 OR
              WHEN 2 THEN
              DO:
                  FIND FIRST {&TabelaPadrao} 
                      WHERE STRING({&CampoDePesquisa}) {&Criterio} "*" + string(pesquisa) + "*" AND
                           {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
                           {&TabelaPadrao}.cdagenci = gnapses.cdagenci AND 
                           crapidp.nrseqeve = aux_nrseqeve NO-LOCK NO-WAIT NO-ERROR.
              END.
              /* Gerentes */
              WHEN 3 THEN
              DO:
                  FIND FIRST {&TabelaPadrao} 
                      WHERE STRING({&CampoDePesquisa}) {&Criterio} "*" + string(pesquisa) + "*" AND
                    {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
                      crapidp.nrseqeve = aux_nrseqeve 
                      NO-LOCK NO-WAIT NO-ERROR.
              END.
          END CASE.
        END.
    END.
  ELSE IF vtippesquisa = "{&NomeCampoDePesquisa1}"  AND "{&NomeCampoDePesquisa1}" <> "" THEN /* CONTA DO INSCRITO */
    DO:
      /**/
      IF vcriterio = "{&NomeCriterio1}" THEN
        DO:
        
          CASE gnapses.nvoperad:
              /* Pessoal da CECRED */
              WHEN 0 THEN
              DO:
                  FIND FIRST {&TabelaPadrao} 
                      WHERE STRING({&CampoDePesquisa1}) {&Criterio1} pesquisa AND 
                      crapidp.nrseqeve = aux_nrseqeve
                      NO-LOCK NO-WAIT NO-ERROR.
              END.
              /* Operadores e Supervisores */
              WHEN 1 OR
              WHEN 2 THEN
              DO:
                  FIND FIRST {&TabelaPadrao} 
                      WHERE STRING({&CampoDePesquisa1}) {&Criterio1} pesquisa    AND
                           {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
                           {&TabelaPadrao}.cdagenci = gnapses.cdagenci AND 
                           crapidp.nrseqeve = aux_nrseqeve
                      NO-LOCK NO-WAIT NO-ERROR.
              END.
              /* Gerentes */
              WHEN 3 THEN
              DO:
                  FIND FIRST {&TabelaPadrao}  WHERE 
                      STRING({&CampoDePesquisa1}) {&Criterio1} pesquisa AND
                      {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND 
                      crapidp.nrseqeve = aux_nrseqeve 
                      NO-LOCK NO-WAIT NO-ERROR.
              END.
          END CASE.
        END.
      ELSE IF vcriterio = "{&NomeCriterio}" THEN
        DO:
      
          CASE gnapses.nvoperad:
              /* Pessoal da CECRED */
              WHEN 0 THEN
              DO:
                  FIND FIRST {&TabelaPadrao} 
                      WHERE STRING({&CampoDePesquisa1}) {&Criterio} "*" + string(pesquisa) + "*" AND
                      crapidp.nrseqeve = aux_nrseqeve 
                      NO-LOCK NO-WAIT NO-ERROR.
              END.
              /* Operadores e Supervisores */
              WHEN 1 OR
              WHEN 2 THEN
              DO:
                  FIND FIRST {&TabelaPadrao} 
                      WHERE STRING({&CampoDePesquisa1}) {&Criterio} "*" + string(pesquisa) + "*" AND
                           {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
                           {&TabelaPadrao}.cdagenci = gnapses.cdagenci AND 
                           crapidp.nrseqeve = aux_nrseqeve NO-LOCK NO-WAIT NO-ERROR.
              END.
              /* Gerentes */
              WHEN 3 THEN
              DO:
                  FIND FIRST {&TabelaPadrao} 
                      WHERE STRING({&CampoDePesquisa1}) {&Criterio} "*" + string(pesquisa) + "*" AND
                    {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
                      crapidp.nrseqeve = aux_nrseqeve 
                      NO-LOCK NO-WAIT NO-ERROR.
              END.
          END CASE.
        END.
      /**/
    END.
    
END PROCEDURE.

PROCEDURE OpenQuery:
  
    /*INICIO PESQUISA INSCRITO*/
    IF vtippesquisa = "{&NomeCampoDePesquisa}"  AND "{&NomeCampoDePesquisa}" <> "" THEN
      DO:
        IF vcriterio = "{&NomeCriterio1}" THEN DO:
            CASE gnapses.nvoperad:
                /* Pessoal da CECRED */
                WHEN 0 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                                              WHERE {&CampoDePesquisa} {&Criterio1} pesquisa AND
                                                    crapidp.nrseqeve = aux_nrseqeve 
                                           NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                    
                END.
                /* Operadores e Supervisores */
                WHEN 1 OR 
                WHEN 2 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                                              WHERE {&CampoDePesquisa} {&Criterio1} pesquisa   AND
                                                  {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
                                                  {&TabelaPadrao}.cdagenci = gnapses.cdagenci AND
                                                  crapidp.nrseqeve = aux_nrseqeve 
                                           NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                END.
                /* Gerentes */
                WHEN 3 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                                              WHERE {&CampoDePesquisa} {&Criterio1} pesquisa AND
                                                  {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
                                                  crapidp.nrseqeve = aux_nrseqeve 
                                           NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                END.
            END CASE.
        END.
        ELSE IF vcriterio = "{&NomeCriterio}" THEN DO:
            CASE gnapses.nvoperad:
                /* Pessoal da CECRED */
                WHEN 0 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                                              WHERE STRING({&CampoDePesquisa}) {&Criterio} "*" + pesquisa + "*" AND
                                                    crapidp.nrseqeve = aux_nrseqeve
                                           NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                END.
                /* Operadores e Supervisores */
                WHEN 1 OR 
                WHEN 2 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                                              WHERE STRING({&CampoDePesquisa}) {&Criterio} "*" + pesquisa + "*" AND
                                                  {&TabelaPadrao}.cdcooper = gnapses.cdcooper    AND
                                                  {&TabelaPadrao}.cdagenci = gnapses.cdagenci AND
                                                  crapidp.nrseqeve = aux_nrseqeve 
                                           NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                END.
                /* Gerentes */
                WHEN 3 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                                              WHERE STRING({&CampoDePesquisa}) {&Criterio} "*" + pesquisa + "*" AND
                                                  {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
                                                  crapidp.nrseqeve = aux_nrseqeve 
                                           NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                END.
            END CASE.
        END.
      END.
    /*FIM PESQUISA INSCRITO*/
    
    /*INICIO PESQUISA CONTA*/
    IF vtippesquisa = "{&NomeCampoDePesquisa1}"  AND "{&NomeCampoDePesquisa1}" <> "" THEN DO:
      MESSAGE "Pesquisa de Conta".
        IF vcriterio = "{&NomeCriterio1}" THEN DO:
            CASE gnapses.nvoperad:
                /* Pessoal da CECRED */
                WHEN 0 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                                              WHERE STRING({&CampoDePesquisa1}) {&Criterio1} pesquisa AND
                                                    crapidp.nrseqeve = aux_nrseqeve 
                                           NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                    
                END.
                /* Operadores e Supervisores */
                WHEN 1 OR 
                WHEN 2 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                                              WHERE STRING({&CampoDePesquisa1}) {&Criterio1} pesquisa   AND
                                                  {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
                                                  {&TabelaPadrao}.cdagenci = gnapses.cdagenci AND
                                                  crapidp.nrseqeve = aux_nrseqeve 
                                           NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                END.
                /* Gerentes */
                WHEN 3 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                                              WHERE STRING({&CampoDePesquisa1}) {&Criterio1} pesquisa AND
                                                  {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
                                                  crapidp.nrseqeve = aux_nrseqeve 
                                           NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                END.
            END CASE.
        END.
        ELSE IF vcriterio = "{&NomeCriterio}" THEN DO:
            CASE gnapses.nvoperad:
                /* Pessoal da CECRED */
                WHEN 0 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                                              WHERE STRING({&CampoDePesquisa1}) {&Criterio} "*" + pesquisa + "*" AND
                                                    crapidp.nrseqeve = aux_nrseqeve 
                                           NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                END.
                /* Operadores e Supervisores */
                WHEN 1 OR 
                WHEN 2 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                                              WHERE STRING({&CampoDePesquisa1}) {&Criterio} "*" + pesquisa + "*" AND
                                                  {&TabelaPadrao}.cdcooper = gnapses.cdcooper    AND
                                                  {&TabelaPadrao}.cdagenci = gnapses.cdagenci AND
                                                  crapidp.nrseqeve = aux_nrseqeve 
                                           NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                END.
                /* Gerentes */
                WHEN 3 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                                              WHERE STRING({&CampoDePesquisa1}) {&Criterio} "*" + pesquisa + "*" AND
                                                  {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
                                                  crapidp.nrseqeve = aux_nrseqeve 
                                           NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                END.
            END CASE.
        END.
    END.
    /*FIM PESQUISA CONTA*/
END PROCEDURE.

PROCEDURE TrocaCaracter:
    FIND FIRST crapcop WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcooper    NO-LOCK NO-ERROR.
    IF AVAIL crapcop THEN 
        aux_nmrescop = crapcop.nmrescop.
    ELSE
        aux_nmrescop = "&nbsp;".

    FIND FIRST crapage WHERE crapage.cdcooper = {&TabelaPadrao}.cdcooper    AND
                             crapage.cdagenci = {&TabelaPadrao}.cdagenci    NO-LOCK NO-WAIT NO-ERROR.
    IF AVAIL crapage THEN 
        aux_nmresage = crapage.nmresage.
    ELSE
        aux_nmresage = "&nbsp;".

	/*
	FIND FIRST craptab WHERE craptab.cdcooper = 0                           AND
                             craptab.nmsistem = "CRED"                      AND
                             craptab.tptabela = "CONFIG"                    AND    
                             craptab.cdempres = 0                           AND  
                             craptab.cdacesso = "PGSTINSCRI"                AND  
                             craptab.tpregist = 0                           NO-LOCK NO-ERROR.

    IF AVAIL craptab THEN
		ASSIGN aux_dsstatus = ENTRY(LOOKUP(STRING(crapidp.idstains), craptab.dstextab) - 1, craptab.dstextab).
	*/
	CASE crapidp.idstains:
		WHEN 1 THEN aux_dsstatus = "Pendente".
		WHEN 2 THEN aux_dsstatus = "Confirmado".
		WHEN 3 THEN aux_dsstatus = "Desistente".
		WHEN 4 THEN aux_dsstatus = "Excedente".
		WHEN 5 THEN aux_dsstatus = "Cancelado".
	END CASE.


END PROCEDURE.

PROCEDURE PosicionaPonteiro:
END PROCEDURE.
