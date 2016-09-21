/******************************** INCLUDE ZOOM *********************************
PROGRAMA.....:zwpgd0007.i
AUTOR........:B&T/Solusoft 
DESCRIÇÃO....:Zoom da Tabela de Eixos Temáticos

Alterações...: 11/12/2008 - Melhoria de performance para a tabela gnapses (Guilherme).
						  - Utilizar variaveis ValorCampo (Guilherme).
*******************************************************************************/

&GLOBAL-DEFINE TituloDoPrograma Tabela de Eixos Temáticos 
&GLOBAL-DEFINE NomeDoProgramaDeZoom zwpgd0007.w
&GLOBAL-DEFINE TabelaPadrao gnapetp

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE CampoDePesquisa  gnapetp.dseixtem
&GLOBAL-DEFINE CampoDePesquisa1 gnapetp.dseixtem
&GLOBAL-DEFINE CampoDePesquisa2 gnapetp.dseixtem
&GLOBAL-DEFINE CampoDePesquisa3 gnapetp.dseixtem

/* *** Nomes dos campos de pesquisa. Deixar em branco as opções não usadas *** */
&GLOBAL-DEFINE NomeCampoDePesquisa  Descrição
&GLOBAL-DEFINE NomeCampoDePesquisa1 
&GLOBAL-DEFINE NomeCampoDePesquisa2 
&GLOBAL-DEFINE NomeCampoDePesquisa3 

/* *** Demais campos relacionados com o layout *** */
&GLOBAL-DEFINE CamposDisplay "<td class='txtNormal' height='22px'>&nbsp; &nbsp;" gnapetp.dseixtem format "x(40)" "</td>" 
&GLOBAL-DEFINE ListaDeCampos gnapetp.idevento gnapetp.cdcooper gnapetp.cdeixtem gnapetp.dseixtem 
&GLOBAL-DEFINE NomeDoProgramaPrincipal  /wpgd0007.w
&GLOBAL-DEFINE CampoChaveParaRetorno    gnapetp.idevento 
&GLOBAL-DEFINE CampoCompltoParaRetorno  gnapetp.cdeixtem 
&GLOBAL-DEFINE CampoCompltoParaRetorno2 gnapetp.dseixtem

/* *** Linhas do cabecalho *** */
&GLOBAL-DEFINE LinhaDeCabecalho1  <td background="/cecred/images/menu/fnd_title.jpg" class="txtNormal" height="22px">&nbsp; &nbsp;Descrição</td>
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
DEFINE VARIABLE valorcampo          as CHAR      no-undo.
DEFINE VARIABLE aux_idevento        LIKE gnapetp.idevento NO-UNDO.
DEFINE VARIABLE ValorCampo2			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo3			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo4			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo5			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo6			AS CHAR		 NO-UNDO.

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
       aux_idevento     = INT(get-value("ValorCampo"))
       valorcampo       = get-value("ValorCampo")
	   ValorCampo2      = GET-VALUE("ValorCampo2")
	   ValorCampo3      = GET-VALUE("ValorCampo3")
	   ValorCampo4      = GET-VALUE("ValorCampo4")
	   ValorCampo5      = GET-VALUE("ValorCampo5")
	   ValorCampo6      = GET-VALUE("ValorCampo6").
	   

PROCEDURE FindFirst:

  IF vtippesquisa = "{&NomeCampoDePesquisa}"  AND "{&NomeCampoDePesquisa}" <> ""  THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN DO:
	  FIND FIRST {&TabelaPadrao} WHERE {&CampoDePesquisa} {&Criterio} pesquisa AND
									   {&TabelaPadrao}.cdcooper = 0            AND
                                       {&TabelaPadrao}.idevento = aux_idevento USE-INDEX gnapetp2 NO-LOCK NO-ERROR.
	  
      
    END.
    ELSE DO:
        FIND FIRST {&TabelaPadrao} WHERE {&CampoDePesquisa} {&Criterio1} "*" + pesquisa + "*" AND
										 {&TabelaPadrao}.cdcooper = 0                         AND
										 {&TabelaPadrao}.idevento = aux_idevento USE-INDEX gnapetp2 NO-LOCK NO-ERROR.
		
    END.
  END.

END PROCEDURE.

PROCEDURE OpenQuery:

  IF vtippesquisa = "{&NomeCampoDePesquisa}" AND "{&NomeCampoDePesquisa}" <> ""  THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX gnapetp2
                                WHERE {&CampoDePesquisa} {&Criterio} pesquisa AND
									  {&TabelaPadrao}.cdcooper = 0            AND
                                      {&TabelaPadrao}.idevento = aux_idevento
						   NO-LOCK /*BY {&CampoDePesquisa}*/ INDEXED-REPOSITION MAX-ROWS 10.
		
    ELSE
	  OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX gnapetp2
                                WHERE {&CampoDePesquisa} {&Criterio1} "*" + pesquisa + "*" AND
									  {&TabelaPadrao}.cdcooper = 0                         AND
                                      {&TabelaPadrao}.idevento = aux_idevento
                           NO-LOCK /*BY {&CampoDePesquisa}*/ INDEXED-REPOSITION MAX-ROWS 10.
		
		
  END.

END PROCEDURE.

PROCEDURE TrocaCaracter:
END PROCEDURE.

PROCEDURE PosicionaPonteiro:
END PROCEDURE.
