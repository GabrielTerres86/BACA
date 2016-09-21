/******************************** INCLUDE ZOOM *********************************
PROGRAMA.....:zwpgd0015.i
AUTOR........:Evandro
DESCRIÇÃO....:Zoom da Tabela de Recursos

Alterações...: 11/12/2008 - Utilizar variaveis ValorCampo (Guilherme).
*******************************************************************************/

&GLOBAL-DEFINE TituloDoPrograma Tabela de Recursos 
&GLOBAL-DEFINE NomeDoProgramaDeZoom zwpgd0015.w
&GLOBAL-DEFINE TabelaPadrao gnaprdp

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE CampoDePesquisa  gnaprdp.dsrecurs
&GLOBAL-DEFINE CampoDePesquisa1 gnaprdp.dsrecurs
&GLOBAL-DEFINE CampoDePesquisa2 gnaprdp.dsrecurs
&GLOBAL-DEFINE CampoDePesquisa3 gnaprdp.dsrecurs

/* *** Nomes dos campos de pesquisa. Deixar em branco as opções não usadas *** */
&GLOBAL-DEFINE NomeCampoDePesquisa  Descrição
&GLOBAL-DEFINE NomeCampoDePesquisa1 
&GLOBAL-DEFINE NomeCampoDePesquisa2 
&GLOBAL-DEFINE NomeCampoDePesquisa3 

/* *** Demais campos relacionados com o layout *** */
&GLOBAL-DEFINE CamposDisplay "<td class='txtNormal' height='22px'>&nbsp; &nbsp;" gnaprdp.dsrecurs format "x(80)" "</td>"
&GLOBAL-DEFINE ListaDeCampos gnaprdp.nrseqdig gnaprdp.dsrecurs gnaprdp.idevento
&GLOBAL-DEFINE NomeDoProgramaPrincipal  /wpgd0015.w
&GLOBAL-DEFINE CampoChaveParaRetorno    gnaprdp.idevento 
&GLOBAL-DEFINE CampoCompltoParaRetorno  gnaprdp.nrseqdig
&GLOBAL-DEFINE CampoCompltoParaRetorno2 gnaprdp.dsrecurs

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
DEFINE VARIABLE idevento            LIKE gnapetp.idevento NO-UNDO.
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
       idevento         = INT(get-value("NomeDoCampo"))
	   ValorCampo2      = GET-VALUE("ValorCampo2")
	   ValorCampo3      = GET-VALUE("ValorCampo3")
	   ValorCampo4      = GET-VALUE("ValorCampo4")
	   ValorCampo5      = GET-VALUE("ValorCampo5")
	   ValorCampo6      = GET-VALUE("ValorCampo6").

PROCEDURE FindFirst:

  IF vtippesquisa = "{&NomeCampoDePesquisa}"  AND "{&NomeCampoDePesquisa}" <> ""  THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN
      FIND FIRST {&TabelaPadrao} USE-INDEX gnaprdp2
        WHERE {&CampoDePesquisa} {&Criterio} pesquisa and
        {&TabelaPadrao}.idevento = idevento NO-LOCK NO-WAIT NO-ERROR.
    ELSE
    IF vcriterio = "{&NomeCriterio1}" THEN
      FIND FIRST {&TabelaPadrao} USE-INDEX gnaprdp2
        WHERE STRING({&CampoDePesquisa}) {&Criterio1} "*" + pesquisa + "*" and
        {&TabelaPadrao}.idevento = idevento NO-LOCK NO-WAIT NO-ERROR.
    ELSE
      FIND FIRST {&TabelaPadrao} USE-INDEX gnaprdp2
        WHERE {&CampoDePesquisa} {&Criterio2}  pesquisa and
        {&TabelaPadrao}.idevento = idevento NO-LOCK NO-WAIT NO-ERROR.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa1}"  AND "{&NomeCampoDePesquisa1}" <> "" THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN
      FIND FIRST {&TabelaPadrao}  WHERE {&CampoDePesquisa1} {&Criterio} pesquisa and
        {&TabelaPadrao}.idevento = idevento NO-LOCK NO-WAIT NO-ERROR.
    ELSE
    IF vcriterio = "{&NomeCriterio1}" THEN
      FIND FIRST {&TabelaPadrao}  WHERE STRING({&CampoDePesquisa1}) {&Criterio1} "*" + pesquisa + "*" and
        {&TabelaPadrao}.idevento = idevento NO-LOCK NO-WAIT NO-ERROR.
    ELSE
      FIND FIRST {&TabelaPadrao}  WHERE {&CampoDePesquisa1} {&Criterio2} pesquisa and
        {&TabelaPadrao}.idevento = idevento NO-LOCK NO-WAIT NO-ERROR.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa2}"  AND "{&NomeCampoDePesquisa2}" <> "" THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN
      FIND FIRST {&TabelaPadrao}  WHERE {&CampoDePesquisa2} {&Criterio} pesquisa and
        {&TabelaPadrao}.idevento = idevento NO-LOCK NO-WAIT NO-ERROR.
    ELSE
    IF vcriterio = "{&NomeCriterio1}" THEN
      FIND FIRST {&TabelaPadrao}  WHERE {&CampoDePesquisa2} {&Criterio1} "*" + pesquisa + "*" and
        {&TabelaPadrao}.idevento = idevento NO-LOCK NO-WAIT NO-ERROR.
    ELSE
      FIND FIRST {&TabelaPadrao}  WHERE {&CampoDePesquisa2} {&Criterio2} pesquisa and
        {&TabelaPadrao}.idevento = idevento NO-LOCK NO-WAIT NO-ERROR.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa3}"  AND "{&NomeCampoDePesquisa3}" <> "" THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN
      FIND FIRST {&TabelaPadrao}  WHERE {&CampoDePesquisa3} {&Criterio} pesquisa and
        {&TabelaPadrao}.idevento = idevento NO-LOCK NO-WAIT NO-ERROR.
    ELSE
    IF vcriterio = "{&NomeCriterio1}" THEN
      FIND FIRST {&TabelaPadrao}  WHERE {&CampoDePesquisa3} {&Criterio1} "*" + pesquisa + "*" and
        {&TabelaPadrao}.idevento = idevento NO-LOCK NO-WAIT NO-ERROR.
    ELSE
      FIND FIRST {&TabelaPadrao}  WHERE {&CampoDePesquisa3} {&Criterio2} pesquisa and
        {&TabelaPadrao}.idevento = idevento NO-LOCK NO-WAIT NO-ERROR.
  END.

END PROCEDURE.

PROCEDURE OpenQuery:

  IF vtippesquisa = "{&NomeCampoDePesquisa}" AND "{&NomeCampoDePesquisa}" <> ""  THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX gnaprdp2
                                WHERE {&CampoDePesquisa} {&Criterio} pesquisa and
                                      {&TabelaPadrao}.idevento = idevento 
                           NO-LOCK BY {&CampoDePesquisa} INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
    IF vcriterio = "{&NomeCriterio1}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX gnaprdp2
                                WHERE STRING({&CampoDePesquisa}) {&Criterio1} "*" + pesquisa + "*" and
                                      {&TabelaPadrao}.idevento = idevento
                           NO-LOCK BY {&CampoDePesquisa} INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX gnaprdp2
                                WHERE {&CampoDePesquisa} {&Criterio2} pesquisa and
                                      {&TabelaPadrao}.idevento = idevento
                           NO-LOCK BY {&CampoDePesquisa} INDEXED-REPOSITION MAX-ROWS 10.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa1}"  AND "{&NomeCampoDePesquisa1}" <> "" THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                                WHERE {&CampoDePesquisa1} {&Criterio} pesquisa and
                                      {&TabelaPadrao}.idevento = idevento
                           NO-LOCK BY {&CampoDePesquisa1} INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
    IF vcriterio = "{&NomeCriterio1}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                                WHERE STRING({&CampoDePesquisa1}) {&Criterio1} "*" + pesquisa + "*" and
                                      {&TabelaPadrao}.idevento = idevento
                           NO-LOCK BY {&CampoDePesquisa1} INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                                WHERE {&CampoDePesquisa1} {&Criterio2} pesquisa and
                                      {&TabelaPadrao}.idevento = idevento
                           NO-LOCK BY {&CampoDePesquisa1} INDEXED-REPOSITION MAX-ROWS 10.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa2}"  AND "{&NomeCampoDePesquisa2}" <> "" THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                                WHERE {&CampoDePesquisa2} {&Criterio} pesquisa and
                                      {&TabelaPadrao}.idevento = idevento
                           NO-LOCK BY {&CampoDePesquisa2} INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
    IF vcriterio = "{&NomeCriterio1}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                                WHERE {&CampoDePesquisa2} {&Criterio1} "*" + pesquisa + "*" and
                                      {&TabelaPadrao}.idevento = idevento
                           NO-LOCK BY {&CampoDePesquisa2} INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                                WHERE {&CampoDePesquisa2} {&Criterio2} pesquisa and
                                      {&TabelaPadrao}.idevento = idevento
                           NO-LOCK BY {&CampoDePesquisa2} INDEXED-REPOSITION MAX-ROWS 10.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa3}"  AND "{&NomeCampoDePesquisa3}" <> "" THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                                WHERE {&CampoDePesquisa3} {&Criterio} pesquisa and
                                      {&TabelaPadrao}.idevento = idevento
                           NO-LOCK BY {&CampoDePesquisa3} INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
    IF vcriterio = "{&NomeCriterio1}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                                WHERE {&CampoDePesquisa3} {&Criterio1} "*" + pesquisa + "*" and
                                      {&TabelaPadrao}.idevento = idevento
                           NO-LOCK BY {&CampoDePesquisa3} INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                                WHERE {&CampoDePesquisa3} {&Criterio2} pesquisa and
                                      {&TabelaPadrao}.idevento = idevento
                           NO-LOCK BY {&CampoDePesquisa3} INDEXED-REPOSITION MAX-ROWS 10.
  END.

END PROCEDURE.

PROCEDURE TrocaCaracter:
END PROCEDURE.

PROCEDURE PosicionaPonteiro:
END PROCEDURE.
