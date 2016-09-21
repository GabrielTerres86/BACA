/******************************** INCLUDE ZOOM *********************************
PROGRAMA.....:zwpgd0032.i
AUTOR........:B&T/Solusoft 
DESCRIÇÃO....:Zoom da Tabela de Item de Avaliação

Alterações...: 10/12/2008 - Utilizar variaveis ValorCampo (Guilherme).
               
               10/06/2016 - Apresentar opcao contem como DEFAULT 
                            PRJ229 - Melhorias OQS (Odirlei-AMcom) 

*******************************************************************************/

&GLOBAL-DEFINE TituloDoPrograma Tabela de Item de Avaliação 
&GLOBAL-DEFINE NomeDoProgramaDeZoom zwpgd0032.w
&GLOBAL-DEFINE TabelaPadrao crapiap

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE CampoDePesquisa  crapiap.dsiteava
&GLOBAL-DEFINE CampoDePesquisa1 crapiap.cdgruava
&GLOBAL-DEFINE CampoDePesquisa2 crapiap.cditeava
&GLOBAL-DEFINE CampoDePesquisa3 crapgap.dsgruava

/* *** Nomes dos campos de pesquisa. Deixar em branco as opções não usadas *** */
&GLOBAL-DEFINE NomeCampoDePesquisa  Nom.ITEM
&GLOBAL-DEFINE NomeCampoDePesquisa1 
&GLOBAL-DEFINE NomeCampoDePesquisa2 
&GLOBAL-DEFINE NomeCampoDePesquisa3 Nom.Grupo

/* *** Demais campos relacionados com o layout *** */
&GLOBAL-DEFINE CamposDisplay "<td class='txtNormal' height='22px'>&nbsp; &nbsp;" crapiap.dsiteava format "x(40)" "</td><td class='txtNormal' height='22px'>&nbsp; &nbsp;" crapgap.dsgruava format "x(40)" "</td>"
&GLOBAL-DEFINE ListaDeCampos crapiap.cditeava crapiap.cdgruava crapiap.dsiteava crapiap.cdcooper
&GLOBAL-DEFINE NomeDoProgramaPrincipal  /wpgd0032.w
&GLOBAL-DEFINE CampoChaveParaRetorno    crapiap.cditeava
&GLOBAL-DEFINE CampoCompltoParaRetorno  crapiap.cdgruava 
&GLOBAL-DEFINE CampoCompltoParaRetorno2 crapiap.dsiteava
&GLOBAL-DEFINE CampoCompltoParaRetorno3 crapgap.dsgruava

/* *** Linhas do cabecalho *** */
&GLOBAL-DEFINE LinhaDeCabecalho1 <td class="txtNormal" background="/cecred/images/menu/fnd_title.jpg" height="22px">&nbsp; &nbsp;Descrição Item </td><td class="txtNormal" background="/cecred/images/menu/fnd_title.jpg" height="22px">&nbsp; &nbsp;Descrição Grupo </td>
&GLOBAL-DEFINE LinhaDeCabecalho2 -------------------------------  -------------------------------   

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
DEFINE VARIABLE idevento            LIKE crapiap.idevento NO-UNDO.
DEFINE VARIABLE ValorCampo2			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo3			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo4			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo5			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo6			AS CHAR		 NO-UNDO.

DEFINE QUERY QueryPadrao FOR {&TabelaPadrao} FIELDS({&ListaDeCampos}), crapgap SCROLLING.

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
    IF vcriterio = "{&NomeCriterio1}" THEN
      FIND FIRST {&TabelaPadrao} USE-INDEX crapiap2 WHERE {&CampoDePesquisa} {&Criterio} pesquisa and
        {&TabelaPadrao}.idevento = idevento AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK NO-WAIT NO-ERROR.
    ELSE
    IF vcriterio = "{&NomeCriterio}" THEN
      FIND FIRST {&TabelaPadrao} USE-INDEX crapiap2 WHERE {&CampoDePesquisa} {&Criterio1} "*" + pesquisa + "*" AND 
        {&TabelaPadrao}.idevento = idevento AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK NO-WAIT NO-ERROR.
    ELSE
      FIND FIRST {&TabelaPadrao} USE-INDEX crapiap2 WHERE {&CampoDePesquisa} {&Criterio2} pesquisa AND 
          {&TabelaPadrao}.idevento = idevento AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK NO-WAIT NO-ERROR.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa1}"  AND "{&NomeCampoDePesquisa1}" <> "" THEN DO:
    IF vcriterio = "{&NomeCriterio1}" THEN
      FIND FIRST {&TabelaPadrao} USE-INDEX crapiap2 WHERE STRING({&CampoDePesquisa1}) {&Criterio} pesquisa AND 
        {&TabelaPadrao}.idevento = idevento AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK NO-WAIT NO-ERROR.
    ELSE
    IF vcriterio = "{&NomeCriterio}" THEN
      FIND FIRST {&TabelaPadrao} USE-INDEX crapiap2 WHERE STRING({&CampoDePesquisa1}) {&Criterio1} "*" + pesquisa + "*" AND 
        {&TabelaPadrao}.idevento = idevento AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK NO-WAIT NO-ERROR.
    ELSE
      FIND FIRST {&TabelaPadrao} USE-INDEX crapiap2 WHERE STRING({&CampoDePesquisa1}) {&Criterio2} pesquisa AND 
          {&TabelaPadrao}.idevento = idevento AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK NO-WAIT NO-ERROR.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa2}"   AND "{&NomeCampoDePesquisa2}" <> ""  THEN DO:
    IF vcriterio = "{&NomeCriterio1}" THEN
      FIND FIRST {&TabelaPadrao} USE-INDEX crapiap2 WHERE STRING({&CampoDePesquisa2}) {&Criterio} pesquisa AND 
        {&TabelaPadrao}.idevento = idevento AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK NO-WAIT NO-ERROR.
    ELSE
    IF vcriterio = "{&NomeCriterio}" THEN
      FIND FIRST {&TabelaPadrao} USE-INDEX crapiap2 WHERE STRING({&CampoDePesquisa2}) {&Criterio1} "*" + pesquisa + "*" AND
        {&TabelaPadrao}.idevento = idevento AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK NO-WAIT NO-ERROR.
    ELSE
      FIND FIRST {&TabelaPadrao} USE-INDEX crapiap2 WHERE STRING({&CampoDePesquisa2}) {&Criterio2} pesquisa AND 
          {&TabelaPadrao}.idevento = idevento AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK NO-WAIT NO-ERROR.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa3}"  AND "{&NomeCampoDePesquisa3}" <> "" THEN DO:
    IF vcriterio = "{&NomeCriterio1}" THEN
      FOR FIRST {&TabelaPadrao} USE-INDEX crapiap2 WHERE {&TabelaPadrao}.idevento = idevento, 
        FIRST crapgap USE-INDEX crapgap2 WHERE crapgap.cdgruava = crapiap.cdgruava AND 
        crapgap.dsgruava {&Criterio} pesquisa /*WHERE {&CampoDePesquisa3} {&Criterio} pesquisa*/  AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK /*NO-WAIT NO-ERROR*/.
      END.
    ELSE
    IF vcriterio = "{&NomeCriterio}" THEN
      /*FIND FIRST {&TabelaPadrao}  WHERE {&CampoDePesquisa3} {&Criterio1} pesquisa NO-LOCK NO-WAIT NO-ERROR.*/
      FOR FIRST {&TabelaPadrao} USE-INDEX crapiap2 WHERE {&TabelaPadrao}.idevento = idevento, 
        FIRST crapgap USE-INDEX crapgap2 WHERE crapgap.cdgruava = crapiap.cdgruava AND 
        crapgap.dsgruava {&Criterio1} "*" + pesquisa + "*" /*WHERE {&CampoDePesquisa3} {&Criterio} pesquisa*/ AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK /*NO-WAIT NO-ERROR*/.
      END.
    ELSE
      /*FIND FIRST {&TabelaPadrao}  WHERE {&CampoDePesquisa3} {&Criterio2} pesquisa NO-LOCK NO-WAIT NO-ERROR.*/
      FOR FIRST {&TabelaPadrao} USE-INDEX crapiap2 WHERE {&TabelaPadrao}.idevento = idevento, 
          FIRST crapgap USE-INDEX crapgap2 WHERE crapgap.cdgruava = crapiap.cdgruava AND 
          crapgap.dsgruava {&Criterio2} pesquisa /*WHERE {&CampoDePesquisa3} {&Criterio} pesquisa*/ AND
        {&TabelaPadrao}.cdcooper = 0 NO-LOCK /*NO-WAIT NO-ERROR*/.
      END.
  END.

END PROCEDURE.

PROCEDURE OpenQuery:

  IF vtippesquisa = "{&NomeCampoDePesquisa}"   AND "{&NomeCampoDePesquisa}" <> ""  THEN DO:
    IF vcriterio = "{&NomeCriterio1}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapiap2
                                WHERE {&CampoDePesquisa} {&Criterio} pesquisa AND
                                      {&TabelaPadrao}.cdcooper = 0 AND
                                      {&TabelaPadrao}.idevento = idevento NO-LOCK,
                                FIRST crapgap USE-INDEX crapgap2 WHERE crapgap.cdgruava = crapiap.cdgruava 
                           NO-LOCK /*BY {&CampoDePesquisa}*/ INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
    IF vcriterio = "{&NomeCriterio}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapiap2
                                WHERE {&CampoDePesquisa} {&Criterio1} "*" + pesquisa + "*" AND
                                      {&TabelaPadrao}.cdcooper = 0 AND
                                      {&TabelaPadrao}.idevento = idevento NO-LOCK,
                                FIRST crapgap USE-INDEX crapgap2 WHERE crapgap.cdgruava = crapiap.cdgruava
                           NO-LOCK /*BY {&CampoDePesquisa}*/ INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapiap2
                                WHERE {&CampoDePesquisa} {&Criterio2} pesquisa AND
                                      {&TabelaPadrao}.cdcooper = 0 AND
                                      {&TabelaPadrao}.idevento = idevento NO-LOCK,
                                FIRST crapgap USE-INDEX crapgap2 WHERE crapgap.cdgruava = crapiap.cdgruava
                           NO-LOCK /*BY {&CampoDePesquisa}*/ INDEXED-REPOSITION MAX-ROWS 10.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa1}"  AND "{&NomeCampoDePesquisa1}" <> "" THEN DO:
    IF vcriterio = "{&NomeCriterio1}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapiap2
                                WHERE STRING({&CampoDePesquisa1}) {&Criterio} pesquisa AND
                                      {&TabelaPadrao}.cdcooper = 0 AND
                                      {&TabelaPadrao}.idevento = idevento NO-LOCK,
                                FIRST crapgap USE-INDEX crapgap2 WHERE crapgap.cdgruava = crapiap.cdgruava
                           NO-LOCK /*BY {&CampoDePesquisa1}*/ INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
    IF vcriterio = "{&NomeCriterio}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapiap2
                                WHERE STRING({&CampoDePesquisa1}) {&Criterio1} "*" + pesquisa + "*" AND
                                      {&TabelaPadrao}.cdcooper = 0 AND
                                      {&TabelaPadrao}.idevento = idevento NO-LOCK,
                                FIRST crapgap USE-INDEX crapgap2 WHERE crapgap.cdgruava = crapiap.cdgruava
                           NO-LOCK /*BY {&CampoDePesquisa1}*/ INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapiap2
                                WHERE STRING({&CampoDePesquisa1}) {&Criterio2} pesquisa AND
                                      {&TabelaPadrao}.cdcooper = 0 AND
                                      {&TabelaPadrao}.idevento = idevento NO-LOCK,
                                FIRST crapgap USE-INDEX crapgap2 WHERE crapgap.cdgruava = crapiap.cdgruava
                           NO-LOCK /*BY {&CampoDePesquisa1}*/ INDEXED-REPOSITION MAX-ROWS 10.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa2}"  AND "{&NomeCampoDePesquisa2}" <> "" THEN DO:
    IF vcriterio = "{&NomeCriterio1}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapiap2
                                WHERE STRING({&CampoDePesquisa2}) {&Criterio} pesquisa AND
                                      {&TabelaPadrao}.cdcooper = 0 AND
                                      {&TabelaPadrao}.idevento = idevento NO-LOCK,
                                FIRST crapgap USE-INDEX crapgap2 WHERE crapgap.cdgruava = crapiap.cdgruava
                           NO-LOCK /*BY {&CampoDePesquisa2}*/ INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
    IF vcriterio = "{&NomeCriterio}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapiap2
                                WHERE STRING({&CampoDePesquisa2}) {&Criterio1} "*" + pesquisa + "*" AND
                                      {&TabelaPadrao}.cdcooper = 0 AND
                                      {&TabelaPadrao}.idevento = idevento NO-LOCK,
                                FIRST crapgap USE-INDEX crapgap2 WHERE crapgap.cdgruava = crapiap.cdgruava
                           NO-LOCK /*BY {&CampoDePesquisa2}*/ INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapiap2
                                WHERE STRING({&CampoDePesquisa2}) {&Criterio2} pesquisa AND
                                      {&TabelaPadrao}.cdcooper = 0 AND
                                      {&TabelaPadrao}.idevento = idevento NO-LOCK,
                                FIRST crapgap USE-INDEX crapgap2 WHERE crapgap.cdgruava = crapiap.cdgruava
                           NO-LOCK /*BY {&CampoDePesquisa2}*/ INDEXED-REPOSITION MAX-ROWS 10.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa3}"  AND "{&NomeCampoDePesquisa3}" <> "" THEN DO:
    IF vcriterio = "{&NomeCriterio1}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapiap2
                                /*WHERE {&CampoDePesquisa3} {&Criterio} pesquisa*/ WHERE
                                      {&TabelaPadrao}.idevento = idevento AND
                                      {&TabelaPadrao}.cdcooper = 0 NO-LOCK,
                                FIRST crapgap USE-INDEX crapgap2 WHERE crapgap.cdgruava = crapiap.cdgruava AND
                                      crapgap.dsgruava {&Criterio} pesquisa
                           NO-LOCK /*BY {&CampoDePesquisa3}*/ INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
    IF vcriterio = "{&NomeCriterio}" THEN
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapiap2
                                /*WHERE {&CampoDePesquisa3} {&Criterio1} pesquisa*/ WHERE
                                      {&TabelaPadrao}.idevento = idevento AND
                                      {&TabelaPadrao}.cdcooper = 0 NO-LOCK,
                                FIRST crapgap USE-INDEX crapgap2 WHERE crapgap.cdgruava = crapiap.cdgruava AND
                                      crapgap.dsgruava {&Criterio1} "*" + pesquisa + "*"
                           NO-LOCK /*BY {&CampoDePesquisa3}*/ INDEXED-REPOSITION MAX-ROWS 10.
    ELSE
      OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapiap2
                                /*WHERE {&CampoDePesquisa3} {&Criterio2} pesquisa*/ WHERE
                                      {&TabelaPadrao}.idevento = idevento AND
                                      {&TabelaPadrao}.cdcooper = 0 NO-LOCK,
                                FIRST crapgap USE-INDEX crapgap2 WHERE crapgap.cdgruava = crapiap.cdgruava AND
                                      crapgap.dsgruava {&Criterio2} pesquisa
                           NO-LOCK /*BY {&CampoDePesquisa3}*/ INDEXED-REPOSITION MAX-ROWS 10.
  END.

END PROCEDURE.

PROCEDURE TrocaCaracter:
END PROCEDURE.

PROCEDURE PosicionaPonteiro:
END PROCEDURE.
