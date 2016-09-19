/******************************** INCLUDE ZOOM *********************************
PROGRAMA.....:zwpgd0008.i
AUTOR........:B&T/Solusoft 
DESCRIÇÃO....:Zoom da Tabela de Eventos

Alterações...: 11/12/2008 - Utilizar variaveis ValorCampo (Guilherme).
*******************************************************************************/

&GLOBAL-DEFINE TituloDoPrograma Tabela de Eventos 
&GLOBAL-DEFINE NomeDoProgramaDeZoom zwpgd0008.w
&GLOBAL-DEFINE TabelaPadrao crapedp

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE CampoDePesquisa  crapedp.nmevento
&GLOBAL-DEFINE CampoDePesquisa1 crapedp.cdeixtem
&GLOBAL-DEFINE CampoDePesquisa2 crapedp.cdevento
&GLOBAL-DEFINE CampoDePesquisa3 gnapetp.dseixtem

/* *** Nomes dos campos de pesquisa. Deixar em branco as opções não usadas *** */
&GLOBAL-DEFINE NomeCampoDePesquisa  Nom.Evento
&GLOBAL-DEFINE NomeCampoDePesquisa1 
&GLOBAL-DEFINE NomeCampoDePesquisa2 
&GLOBAL-DEFINE NomeCampoDePesquisa3 Nom.Eixo

/* *** Demais campos relacionados com o layout *** */
&GLOBAL-DEFINE CamposDisplay "<td class='txtNormal' height='22px'>&nbsp; &nbsp;" crapedp.nmevento format "x(40)" "</td><td class='txtNormal' height='22px'>&nbsp; &nbsp;" gnapetp.dseixtem format "x(40)" "</td>"
&GLOBAL-DEFINE ListaDeCampos crapedp.cdevento crapedp.cdeixtem crapedp.nmevento crapedp.cdcooper
&GLOBAL-DEFINE NomeDoProgramaPrincipal  /wpgd0008.w
&GLOBAL-DEFINE CampoChaveParaRetorno    crapedp.cdevento
&GLOBAL-DEFINE CampoCompltoParaRetorno  crapedp.cdeixtem 
&GLOBAL-DEFINE CampoCompltoParaRetorno2 crapedp.nmevento
&GLOBAL-DEFINE CampoCompltoParaRetorno3 gnapetp.dseixtem

/* *** Linhas do cabecalho *** */
&GLOBAL-DEFINE LinhaDeCabecalho1 <td class="txtNormal" background="/cecred/images/menu/fnd_title.jpg" height="22px">&nbsp; &nbsp;Descrição Evento </td><td class="txtNormal" background="/cecred/images/menu/fnd_title.jpg" height="22px">&nbsp; &nbsp;Descrição Eixo </td>
&GLOBAL-DEFINE LinhaDeCabecalho2 -------------------------------  -------------------------------   

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
DEFINE VARIABLE idevento            LIKE crapedp.idevento NO-UNDO.
DEFINE VARIABLE ValorCampo2			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo3			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo4			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo5			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo6			AS CHAR		 NO-UNDO.

DEFINE QUERY QueryPadrao FOR {&TabelaPadrao} FIELDS({&ListaDeCampos}), gnapetp SCROLLING.

ASSIGN pesquisa         = GET-VALUE("pesquisa")
       opcao-pesquisa   = SUBSTRING(pesquisa,1,1)
       pesquisa         = SUBSTRING(pesquisa,2,LENGTH(pesquisa))
       NomeDoCampo      = GET-VALUE("NomeDoCampo")
       PonteiroDeInicio = TO-ROWID(GET-VALUE("PonteiroDeInicio"))
       PonteiroDeFim    = TO-ROWID(GET-VALUE("PonteiroDeFim")) 
       vtippesquisa     = GET-VALUE("vtippesquisa")
       vcriterio        = GET-VALUE("vcriterio")
       OpcaoNavegacao   = GET-VALUE("btnopcao")
       Idevento         = int(GET-VALUE("ValorCampo"))
       ValorCampo       = GET-VALUE("ValorCampo")
	   ValorCampo2      = GET-VALUE("ValorCampo2")
	   ValorCampo3      = GET-VALUE("ValorCampo3")
	   ValorCampo4      = GET-VALUE("ValorCampo4")
	   ValorCampo5      = GET-VALUE("ValorCampo5")
	   ValorCampo6      = GET-VALUE("ValorCampo6").

PROCEDURE FindFirst:

  IF vtippesquisa = "{&NomeCampoDePesquisa}"  AND "{&NomeCampoDePesquisa}" <> "" THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN
      FIND FIRST {&TabelaPadrao} USE-INDEX crapedp2 WHERE {&CampoDePesquisa} {&Criterio} pesquisa and
        {&TabelaPadrao}.idevento = idevento AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK NO-WAIT NO-ERROR.
    ELSE
    IF vcriterio = "{&NomeCriterio1}" THEN
      FIND FIRST {&TabelaPadrao} USE-INDEX crapedp2 WHERE {&CampoDePesquisa} {&Criterio1} "*" + pesquisa + "*" AND 
        {&TabelaPadrao}.idevento = idevento AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK NO-WAIT NO-ERROR.
    ELSE
      FIND FIRST {&TabelaPadrao} USE-INDEX crapedp2 WHERE {&CampoDePesquisa} {&Criterio2} pesquisa AND 
          {&TabelaPadrao}.idevento = idevento AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK NO-WAIT NO-ERROR.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa1}"  AND "{&NomeCampoDePesquisa1}" <> "" THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN
      FIND FIRST {&TabelaPadrao} USE-INDEX crapedp2 WHERE STRING({&CampoDePesquisa1}) {&Criterio} pesquisa AND 
        {&TabelaPadrao}.idevento = idevento AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK NO-WAIT NO-ERROR.
    ELSE
    IF vcriterio = "{&NomeCriterio1}" THEN
      FIND FIRST {&TabelaPadrao} USE-INDEX crapedp2 WHERE STRING({&CampoDePesquisa1}) {&Criterio1} "*" + pesquisa + "*" AND 
        {&TabelaPadrao}.idevento = idevento AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK NO-WAIT NO-ERROR.
    ELSE
      FIND FIRST {&TabelaPadrao} USE-INDEX crapedp2 WHERE STRING({&CampoDePesquisa1}) {&Criterio2} pesquisa AND 
          {&TabelaPadrao}.idevento = idevento AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK NO-WAIT NO-ERROR.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa2}"   AND "{&NomeCampoDePesquisa2}" <> ""  THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN
      FIND FIRST {&TabelaPadrao} USE-INDEX crapedp2 WHERE STRING({&CampoDePesquisa2}) {&Criterio} pesquisa AND 
        {&TabelaPadrao}.idevento = idevento AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK NO-WAIT NO-ERROR.
    ELSE
    IF vcriterio = "{&NomeCriterio1}" THEN
      FIND FIRST {&TabelaPadrao} USE-INDEX crapedp2 WHERE STRING({&CampoDePesquisa2}) {&Criterio1} "*" + pesquisa + "*" AND
        {&TabelaPadrao}.idevento = idevento AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK NO-WAIT NO-ERROR.
    ELSE
      FIND FIRST {&TabelaPadrao} USE-INDEX crapedp2 WHERE STRING({&CampoDePesquisa2}) {&Criterio2} pesquisa AND 
          {&TabelaPadrao}.idevento = idevento AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK NO-WAIT NO-ERROR.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa3}"  AND "{&NomeCampoDePesquisa3}" <> "" THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN
      FOR FIRST {&TabelaPadrao} USE-INDEX crapedp2 WHERE {&TabelaPadrao}.idevento = idevento, 
        FIRST gnapetp USE-INDEX gnapetp2 WHERE gnapetp.cdeixtem = crapedp.cdeixtem AND 
        gnapetp.dseixtem {&Criterio} pesquisa /*WHERE {&CampoDePesquisa3} {&Criterio} pesquisa*/  AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK /*NO-WAIT NO-ERROR*/.
      END.
    ELSE
    IF vcriterio = "{&NomeCriterio1}" THEN
      /*FIND FIRST {&TabelaPadrao}  WHERE {&CampoDePesquisa3} {&Criterio1} pesquisa NO-LOCK NO-WAIT NO-ERROR.*/
      FOR FIRST {&TabelaPadrao} USE-INDEX crapedp2 WHERE {&TabelaPadrao}.idevento = idevento, 
        FIRST gnapetp USE-INDEX gnapetp2 WHERE gnapetp.cdeixtem = crapedp.cdeixtem AND 
        gnapetp.dseixtem {&Criterio1} "*" + pesquisa + "*" /*WHERE {&CampoDePesquisa3} {&Criterio} pesquisa*/ AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK /*NO-WAIT NO-ERROR*/.
      END.
    ELSE
      /*FIND FIRST {&TabelaPadrao}  WHERE {&CampoDePesquisa3} {&Criterio2} pesquisa NO-LOCK NO-WAIT NO-ERROR.*/
      FOR FIRST {&TabelaPadrao} USE-INDEX crapedp2 WHERE {&TabelaPadrao}.idevento = idevento, 
          FIRST gnapetp USE-INDEX gnapetp2 WHERE gnapetp.cdeixtem = crapedp.cdeixtem AND 
          gnapetp.dseixtem {&Criterio2} pesquisa /*WHERE {&CampoDePesquisa3} {&Criterio} pesquisa*/ AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK /*NO-WAIT NO-ERROR*/.
      END.
  END.

END PROCEDURE.

PROCEDURE OpenQuery:

  IF vtippesquisa = "{&NomeCampoDePesquisa}"   AND "{&NomeCampoDePesquisa}" <> ""  THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapedp2
                                WHERE {&CampoDePesquisa} {&Criterio} pesquisa AND
                                      {&TabelaPadrao}.cdcooper = 0 AND
                                      {&TabelaPadrao}.idevento = idevento,
                                FIRST gnapetp USE-INDEX gnapetp2 WHERE gnapetp.cdeixtem = crapedp.cdeixtem 
                           NO-LOCK /*BY {&CampoDePesquisa}*/ INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
    IF vcriterio = "{&NomeCriterio1}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapedp2
                                WHERE {&CampoDePesquisa} {&Criterio1} "*" + pesquisa + "*" AND
                                      {&TabelaPadrao}.cdcooper = 0 AND
                                      {&TabelaPadrao}.idevento = idevento,
                                FIRST gnapetp USE-INDEX gnapetp2 WHERE gnapetp.cdeixtem = crapedp.cdeixtem
                           NO-LOCK /*BY {&CampoDePesquisa}*/ INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapedp2
                                WHERE {&CampoDePesquisa} {&Criterio2} pesquisa AND
                                      {&TabelaPadrao}.cdcooper = 0 AND
                                      {&TabelaPadrao}.idevento = idevento,
                                FIRST gnapetp USE-INDEX gnapetp2 WHERE gnapetp.cdeixtem = crapedp.cdeixtem
                           NO-LOCK /*BY {&CampoDePesquisa}*/ INDEXED-REPOSITION MAX-ROWS 10.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa1}"  AND "{&NomeCampoDePesquisa1}" <> "" THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapedp2
                                WHERE STRING({&CampoDePesquisa1}) {&Criterio} pesquisa AND
                                      {&TabelaPadrao}.cdcooper = 0 AND
                                      {&TabelaPadrao}.idevento = idevento,
                                FIRST gnapetp USE-INDEX gnapetp2 WHERE gnapetp.cdeixtem = crapedp.cdeixtem
                           NO-LOCK /*BY {&CampoDePesquisa1}*/ INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
    IF vcriterio = "{&NomeCriterio1}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapedp2
                                WHERE STRING({&CampoDePesquisa1}) {&Criterio1} "*" + pesquisa + "*" AND
                                      {&TabelaPadrao}.cdcooper = 0 AND
                                      {&TabelaPadrao}.idevento = idevento,
                                FIRST gnapetp USE-INDEX gnapetp2 WHERE gnapetp.cdeixtem = crapedp.cdeixtem
                           NO-LOCK /*BY {&CampoDePesquisa1}*/ INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapedp2
                                WHERE STRING({&CampoDePesquisa1}) {&Criterio2} pesquisa AND
                                      {&TabelaPadrao}.cdcooper = 0 AND
                                      {&TabelaPadrao}.idevento = idevento,
                                FIRST gnapetp USE-INDEX gnapetp2 WHERE gnapetp.cdeixtem = crapedp.cdeixtem
                           NO-LOCK /*BY {&CampoDePesquisa1}*/ INDEXED-REPOSITION MAX-ROWS 10.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa2}"  AND "{&NomeCampoDePesquisa2}" <> "" THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapedp2
                                WHERE STRING({&CampoDePesquisa2}) {&Criterio} pesquisa AND
                                      {&TabelaPadrao}.cdcooper = 0 AND
                                      {&TabelaPadrao}.idevento = idevento,
                                FIRST gnapetp USE-INDEX gnapetp2 WHERE gnapetp.cdeixtem = crapedp.cdeixtem
                           NO-LOCK /*BY {&CampoDePesquisa2}*/ INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
    IF vcriterio = "{&NomeCriterio1}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapedp2
                                WHERE STRING({&CampoDePesquisa2}) {&Criterio1} "*" + pesquisa + "*" AND
                                      {&TabelaPadrao}.cdcooper = 0 AND
                                      {&TabelaPadrao}.idevento = idevento,
                                FIRST gnapetp USE-INDEX gnapetp2 WHERE gnapetp.cdeixtem = crapedp.cdeixtem
                           NO-LOCK /*BY {&CampoDePesquisa2}*/ INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapedp2
                                WHERE STRING({&CampoDePesquisa2}) {&Criterio2} pesquisa AND
                                      {&TabelaPadrao}.cdcooper = 0 AND
                                      {&TabelaPadrao}.idevento = idevento,
                                FIRST gnapetp USE-INDEX gnapetp2 WHERE gnapetp.cdeixtem = crapedp.cdeixtem
                           NO-LOCK /*BY {&CampoDePesquisa2}*/ INDEXED-REPOSITION MAX-ROWS 10.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa3}"  AND "{&NomeCampoDePesquisa3}" <> "" THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapedp2
                                /*WHERE {&CampoDePesquisa3} {&Criterio} pesquisa*/ WHERE
                                      {&TabelaPadrao}.idevento = idevento AND
                                      {&TabelaPadrao}.cdcooper = 0,
                                FIRST gnapetp USE-INDEX gnapetp2 WHERE gnapetp.cdeixtem = crapedp.cdeixtem AND
                                      gnapetp.dseixtem {&Criterio} pesquisa
                           NO-LOCK /*BY {&CampoDePesquisa3}*/ INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
    IF vcriterio = "{&NomeCriterio1}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapedp2
                                /*WHERE {&CampoDePesquisa3} {&Criterio1} pesquisa*/ WHERE
                                      {&TabelaPadrao}.idevento = idevento AND
                                      {&TabelaPadrao}.cdcooper = 0,
                                FIRST gnapetp USE-INDEX gnapetp2 WHERE gnapetp.cdeixtem = crapedp.cdeixtem AND
                                      gnapetp.dseixtem {&Criterio1} "*" + pesquisa + "*"
                           NO-LOCK /*BY {&CampoDePesquisa3}*/ INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapedp2
                                /*WHERE {&CampoDePesquisa3} {&Criterio2} pesquisa*/ WHERE
                                      {&TabelaPadrao}.idevento = idevento AND
                                      {&TabelaPadrao}.cdcooper = 0,
                                FIRST gnapetp USE-INDEX gnapetp2 WHERE gnapetp.cdeixtem = crapedp.cdeixtem AND
                                      gnapetp.dseixtem {&Criterio2} pesquisa
                           NO-LOCK /*BY {&CampoDePesquisa3}*/ INDEXED-REPOSITION MAX-ROWS 10.
  END.

END PROCEDURE.

PROCEDURE TrocaCaracter:
END PROCEDURE.

PROCEDURE PosicionaPonteiro:
END PROCEDURE.
