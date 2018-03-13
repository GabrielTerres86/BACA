/******************************** INCLUDE ZOOM *********************************
PROGRAMA.....:zwpgd0031.i
AUTOR........:B&T/Solusoft 
DESCRIÇÃO....:Zoom da Tabela de Grupos de Avaliação

ALTERAÇÕES...: Incluído campo "Ordem" (Diego).
               12/12/2008 - Utilizar variaveis ValorCampo
			              - Inicia utilizar BEGINS (Guilherme).
               
               09/06/2016 - Alterar para apresentar a opçao contem como DEFAULT 
                            PRJ229 - Melhorias OQS (Odirlei-AMcom) 
*******************************************************************************/

&GLOBAL-DEFINE TituloDoPrograma Tabela de Grupos de Avaliação 
&GLOBAL-DEFINE NomeDoProgramaDeZoom zwpgd0031.w
&GLOBAL-DEFINE TabelaPadrao crapgap

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE CampoDePesquisa  crapgap.dsgruava
&GLOBAL-DEFINE CampoDePesquisa1 crapgap.dsgruava
&GLOBAL-DEFINE CampoDePesquisa2 crapgap.dsgruava
&GLOBAL-DEFINE CampoDePesquisa3 crapgap.dsgruava

/* *** Nomes dos campos de pesquisa. Deixar em branco as opções não usadas *** */
&GLOBAL-DEFINE NomeCampoDePesquisa  Descrição
&GLOBAL-DEFINE NomeCampoDePesquisa1 
&GLOBAL-DEFINE NomeCampoDePesquisa2 
&GLOBAL-DEFINE NomeCampoDePesquisa3 

/* *** Demais campos relacionados com o layout *** */
&GLOBAL-DEFINE CamposDisplay "<td class='txtNormal' height='22px'>&nbsp; &nbsp;" crapgap.dsgruava format "x(60)" "</td><td class='txtNormal' height='22px'>&nbsp; &nbsp;" crapgap.nrordgru format "zz9" "</td>" 
&GLOBAL-DEFINE ListaDeCampos crapgap.idevento crapgap.cdcooper crapgap.cdgruava crapgap.dsgruava crapgap.nrordgru 
&GLOBAL-DEFINE NomeDoProgramaPrincipal  /wpgd0031.w
&GLOBAL-DEFINE CampoChaveParaRetorno    crapgap.idevento  
&GLOBAL-DEFINE CampoCompltoParaRetorno  crapgap.cdgruava 
&GLOBAL-DEFINE CampoCompltoParaRetorno2 crapgap.dsgruava 

/* *** Linhas do cabecalho *** */
&GLOBAL-DEFINE LinhaDeCabecalho1  <td background="/cecred/images/menu/fnd_title.jpg" class="txtNormal" height="22px">&nbsp; &nbsp;Descrição</td><td background="/cecred/images/menu/fnd_title.jpg" class="txtNormal" height="22px">&nbsp; &nbsp;Ordem</td>
&GLOBAL-DEFINE LinhaDeCabecalho2  ----------------------------------------

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE Criterio  BEGINS
&GLOBAL-DEFINE Criterio1 MATCHES
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
DEFINE VARIABLE aux_idevento        LIKE crapgap.idevento NO-UNDO.
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
    IF vcriterio = "{&NomeCriterio1}" THEN DO:
        FIND FIRST {&TabelaPadrao} WHERE {&CampoDePesquisa} {&Criterio} pesquisa AND
            {&TabelaPadrao}.idevento = aux_idevento USE-INDEX crapgap2 NO-LOCK NO-ERROR.
      
    END.
    ELSE DO:
        FIND FIRST {&TabelaPadrao} WHERE {&CampoDePesquisa} {&Criterio1} "*" + pesquisa + "*" AND
            {&TabelaPadrao}.idevento = aux_idevento USE-INDEX crapgap2 NO-LOCK NO-ERROR.
    END.
  END.

END PROCEDURE.

PROCEDURE OpenQuery:

  IF vtippesquisa = "{&NomeCampoDePesquisa}" AND "{&NomeCampoDePesquisa}" <> ""  THEN DO:
    IF vcriterio = "{&NomeCriterio1}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapgap2
                                WHERE {&CampoDePesquisa} {&Criterio} pesquisa AND
                                      {&TabelaPadrao}.idevento = aux_idevento
                           NO-LOCK /*BY {&CampoDePesquisa}*/ INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapgap2
                                WHERE {&CampoDePesquisa} {&Criterio1} "*" + pesquisa + "*" AND
                                      {&TabelaPadrao}.idevento = aux_idevento
                           NO-LOCK /*BY {&CampoDePesquisa}*/ INDEXED-REPOSITION MAX-ROWS 10.
  END.

END PROCEDURE.

PROCEDURE TrocaCaracter:
END PROCEDURE.

PROCEDURE PosicionaPonteiro:
END PROCEDURE.
