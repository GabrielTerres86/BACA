/******************************** INCLUDE ZOOM *********************************
PROGRAMA.....:zwpgd0013.i
AUTOR........:B&T/Solusoft 
DESCRIÇÃO....:Zoom da Tabela de Locais para Eventos

Alterações...: 10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
						  - Utilizar variaveis ValorCampo (Guilherme).
						  
			   05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
							busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
               
               04/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
*******************************************************************************/

&GLOBAL-DEFINE TituloDoPrograma Tabela de Abridores 
&GLOBAL-DEFINE NomeDoProgramaDeZoom zwpgd0024.w
&GLOBAL-DEFINE TabelaPadrao crapaep

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE CampoDePesquisa  crapaep.nmabreve
&GLOBAL-DEFINE CampoDePesquisa1 crapaep.nmabreve
&GLOBAL-DEFINE CampoDePesquisa2 crapaep.nmabreve
&GLOBAL-DEFINE CampoDePesquisa3 crapaep.nmabreve

/* *** Nomes dos campos de pesquisa. Deixar em branco as opções não usadas *** */
&GLOBAL-DEFINE NomeCampoDePesquisa  Descrição
&GLOBAL-DEFINE NomeCampoDePesquisa1 
&GLOBAL-DEFINE NomeCampoDePesquisa2 
&GLOBAL-DEFINE NomeCampoDePesquisa3 

/* *** Demais campos relacionados com o layout *** */
&GLOBAL-DEFINE CamposDisplay "<td class='txtNormal' height='22px'>&nbsp; &nbsp;" IF crapaep.cdagenci <> 0 THEN crapage.nmresage ELSE "--- TODOS ---" "</td><td class='txtNormal' height='22px'>&nbsp; &nbsp;" crapaep.nmabreve format "x(40)" "</td>"  
&GLOBAL-DEFINE ListaDeCampos crapaep.idevento crapaep.cdcooper crapaep.nrseqdig crapaep.nmabreve crapaep.cdagenci
&GLOBAL-DEFINE NomeDoProgramaPrincipal  /wpgd0024.w
&GLOBAL-DEFINE CampoChaveParaRetorno    crapaep.idevento 
&GLOBAL-DEFINE CampoCompltoParaRetorno  crapaep.nrseqdig 
&GLOBAL-DEFINE CampoCompltoParaRetorno2 crapaep.nmabreve

/* *** Linhas do cabecalho *** */
&GLOBAL-DEFINE LinhaDeCabecalho1  <td background="/cecred/images/menu/fnd_title.jpg" class="txtNormal" height="22px">&nbsp; &nbsp;PA</td><td background="/cecred/images/menu/fnd_title.jpg" class="txtNormal" height="22px">&nbsp; &nbsp;Descrição</td>
&GLOBAL-DEFINE LinhaDeCabecalho2  ----------------------------------------

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE Criterio  BEGINS
&GLOBAL-DEFINE Criterio1 MATCHES
&GLOBAL-DEFINE Criterio2 =

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE NomeCriterio  Inicia
&GLOBAL-DEFINE NomeCriterio1 Contém 
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
DEFINE VARIABLE valorcampo          as CHAR      NO-UNDO.
DEFINE VARIABLE aux_idevento        LIKE crapaep.idevento NO-UNDO.
DEFINE VARIABLE v-identificacao     AS CHAR      NO-UNDO.
DEFINE VARIABLE ValorCampo2			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo3			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo4			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo5			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo6			AS CHAR		 NO-UNDO.

DEFINE QUERY QueryPadrao FOR {&TabelaPadrao} FIELDS({&ListaDeCampos}),crapage  SCROLLING.

ASSIGN pesquisa         = GET-VALUE("pesquisa")
       opcao-pesquisa   = SUBSTRING(pesquisa,1,1)
       pesquisa         = SUBSTRING(pesquisa,2,LENGTH(pesquisa))
       NomeDoCampo      = GET-VALUE("NomeDoCampo")
       PonteiroDeInicio = TO-ROWID(GET-VALUE("PonteiroDeInicio"))
       PonteiroDeFim    = TO-ROWID(GET-VALUE("PonteiroDeFim")) 
       vtippesquisa     = GET-VALUE("vtippesquisa")
       vcriterio        = GET-VALUE("vcriterio")
       OpcaoNavegacao   = GET-VALUE("btnopcao")
       aux_idevento     = INT(get-value("ValorCampo"))
       valorcampo       = get-value("ValorCampo")
	   ValorCampo2      = GET-VALUE("ValorCampo2")
	   ValorCampo3      = GET-VALUE("ValorCampo3")
	   ValorCampo4      = GET-VALUE("ValorCampo4")
	   ValorCampo5      = GET-VALUE("ValorCampo5")
	   ValorCampo6      = GET-VALUE("ValorCampo6").

v-identificacao = get-cookie("cookie-usuario-em-uso").

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX, alterado para MATCHES */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + v-identificacao + "*" NO-LOCK:
    LEAVE.
END.

PROCEDURE FindFirst:

  IF vtippesquisa = "{&NomeCampoDePesquisa}"  AND "{&NomeCampoDePesquisa}" <> ""  THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN DO:
        CASE gnapses.nvoperad:
            /* Operadores e Supervisores */
            WHEN 1 OR 
            WHEN 2 THEN
            DO:
                FOR FIRST {&TabelaPadrao} USE-INDEX crapaep2 WHERE {&CampoDePesquisa} {&Criterio} pesquisa AND
                        {&TabelaPadrao}.idevento = aux_idevento AND
                        {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
                        {&TabelaPadrao}.cdagenci = gnapses.cdagenci NO-LOCK,
					FIRST crapage WHERE crapage.cdcooper = gnapses.cdcooper AND 
									   (crapage.cdagenci = {&TabelaPadrao}.cdagenci OR
										{&TabelaPadrao}.cdagenci = 0)
										
                        NO-LOCK:
				END.
            END.
            /* Gerentes - Pessoal da CECRED */
            WHEN 3 OR
			WHEN 0 THEN
            DO:
				message ValorCampo2 "Guilherme".
                FOR FIRST {&TabelaPadrao} USE-INDEX crapaep2 WHERE {&CampoDePesquisa} {&Criterio} pesquisa AND
						{&TabelaPadrao}.idevento = aux_idevento AND
						{&TabelaPadrao}.cdcooper = INT(ValorCampo2) NO-LOCK,
					FIRST crapage WHERE crapage.cdcooper = INT(ValorCampo2) AND 
									   (crapage.cdagenci = {&TabelaPadrao}.cdagenci OR
									    {&TabelaPadrao}.cdagenci = 0)
                        NO-LOCK:
				END.
            END.
        END CASE.
    END.
    ELSE DO:
        CASE gnapses.nvoperad:
            /* Operadores e Supervisores */
            WHEN 1 OR
            WHEN 2 THEN
            DO:
                FOR FIRST {&TabelaPadrao} USE-INDEX crapaep2  WHERE {&CampoDePesquisa} {&Criterio1} "*" + pesquisa + "*" AND
						{&TabelaPadrao}.idevento = aux_idevento AND
						{&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
						{&TabelaPadrao}.cdagenci = gnapses.cdagenci NO-LOCK,
                    FIRST crapage WHERE crapage.cdcooper = gnapses.cdcooper AND 
									   (crapage.cdagenci = {&TabelaPadrao}.cdagenci OR
									    {&TabelaPadrao}.cdagenci = 0)
                        NO-LOCK:
				END.
            END.
            /* Gerentes - Pessoal da CECRED */
            WHEN 3 OR
			WHEN 0 THEN
            DO:
                FOR FIRST {&TabelaPadrao} USE-INDEX crapaep2 WHERE {&CampoDePesquisa} {&Criterio1} "*" + pesquisa + "*" AND
						{&TabelaPadrao}.idevento = aux_idevento AND
						{&TabelaPadrao}.cdcooper = INT(ValorCampo2) NO-LOCK,
                    FIRST crapage WHERE crapage.cdcooper = INT(ValorCampo2) AND 
									   (crapage.cdagenci = {&TabelaPadrao}.cdagenci OR
									    {&TabelaPadrao}.cdagenci = 0)
                        NO-LOCK:
				END.
            END.
        END CASE.
    END.
  END.

END PROCEDURE.

PROCEDURE OpenQuery:

  IF vtippesquisa = "{&NomeCampoDePesquisa}" AND "{&NomeCampoDePesquisa}" <> ""  THEN DO:
      IF vcriterio = "{&NomeCriterio}" THEN DO:
          CASE gnapses.nvoperad:
              /* Operadores e Supervisores */
              WHEN 1 OR 
              WHEN 2 THEN
              DO:
                  OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapaep2
                                            WHERE {&CampoDePesquisa} {&Criterio} pesquisa     AND
                                                  {&TabelaPadrao}.idevento = aux_idevento     AND
                                                  {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
                                                  {&TabelaPadrao}.cdagenci = gnapses.cdagenci NO-LOCK,
											FIRST crapage WHERE crapage.cdcooper = gnapses.cdcooper AND 
															   (crapage.cdagenci = {&TabelaPadrao}.cdagenci OR
																{&TabelaPadrao}.cdagenci = 0)
											NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
              END.
              /* Gerentes - Pessoal da CECRED */
              WHEN 3 OR
			  WHEN 0 THEN
              DO:
                  OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapaep2
                                            WHERE {&CampoDePesquisa} {&Criterio} pesquisa     AND
                                                  {&TabelaPadrao}.idevento = aux_idevento     AND
                                                  {&TabelaPadrao}.cdcooper = INT(ValorCampo2) NO-LOCK,
											 FIRST crapage WHERE crapage.cdcooper = INT(ValorCampo2) AND 
																(crapage.cdagenci = {&TabelaPadrao}.cdagenci OR
																 {&TabelaPadrao}.cdagenci = 0)
											NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
              END.
    
          END CASE.
      END. /* IF vcriterio = "{&NomeCriterio}" */
      ELSE DO:
          CASE gnapses.nvoperad:
              /* Operadores e Supervisores */
              WHEN 1 OR
              WHEN 2 THEN
              DO:
                  OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapaep2
                                            WHERE {&CampoDePesquisa} {&Criterio1} "*" + pesquisa + "*" AND
                                                  {&TabelaPadrao}.idevento = aux_idevento     AND
                                                  {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
                                                  {&TabelaPadrao}.cdagenci = gnapses.cdagenci NO-LOCK,
											FIRST crapage WHERE crapage.cdcooper = gnapses.cdcooper AND 
															   (crapage.cdagenci = {&TabelaPadrao}.cdagenci OR
																{&TabelaPadrao}.cdagenci = 0)
											NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
              END.
              /* Gerentes - Pessoal da CECRED */
              WHEN 3 OR
			  WHEN 0 THEN
              DO:
                  OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapaep2
                                            WHERE {&CampoDePesquisa} {&Criterio1} "*" + pesquisa + "*" AND
                                                  {&TabelaPadrao}.idevento = aux_idevento     AND
                                                  {&TabelaPadrao}.cdcooper = INT(ValorCampo2) NO-LOCK,
											FIRST crapage WHERE crapage.cdcooper = INT(ValorCampo2) AND 
															   (crapage.cdagenci = {&TabelaPadrao}.cdagenci OR
															    {&TabelaPadrao}.cdagenci = 0)
											NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
              END.
          END CASE.
      END. /* ELSE DO: */
  END. /* IF vtippesquisa = "{&NomeCampoDePesquisa}" */

END PROCEDURE.

PROCEDURE TrocaCaracter:
END PROCEDURE.

PROCEDURE PosicionaPonteiro:
END PROCEDURE.
