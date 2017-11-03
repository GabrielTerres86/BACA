/******************************** INCLUDE ZOOM *********************************
PROGRAMA.....:zwpgd0013.i
AUTOR........:B&T/Solusoft 
DESCRIÇÃO....:Zoom da Tabela de Locais para Eventos

Alterações...: 11/12/2008 - Melhoria de performance para a tabela gnapses (Guilherme).
						  - Utilizar variaveis ValorCampo (Guilherme).
						  
			   05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
				            busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
                            
			   04/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                			
*******************************************************************************/

&GLOBAL-DEFINE TituloDoPrograma Tabela de Locais para Eventos 
&GLOBAL-DEFINE NomeDoProgramaDeZoom zwpgd0013.w
&GLOBAL-DEFINE TabelaPadrao crapldp

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE CampoDePesquisa  crapldp.dslocal
&GLOBAL-DEFINE CampoDePesquisa1 crapldp.dslocal
&GLOBAL-DEFINE CampoDePesquisa2 crapldp.dslocal
&GLOBAL-DEFINE CampoDePesquisa3 crapldp.dslocal

/* *** Nomes dos campos de pesquisa. Deixar em branco as opções não usadas *** */
&GLOBAL-DEFINE NomeCampoDePesquisa  Descrição
&GLOBAL-DEFINE NomeCampoDePesquisa1 
&GLOBAL-DEFINE NomeCampoDePesquisa2 
&GLOBAL-DEFINE NomeCampoDePesquisa3 

/* *** Demais campos relacionados com o layout *** */
&GLOBAL-DEFINE CamposDisplay "<td class='txtNormal' height='22px'>&nbsp; &nbsp;" aux_nmrescop "</td><td class='txtNormal' height='22px'>&nbsp; &nbsp;" aux_nmresage "</td><td class='txtNormal' height='22px'>&nbsp; &nbsp;" crapldp.dslocal format "x(40)" "</td>" 
&GLOBAL-DEFINE ListaDeCampos crapldp.idevento crapldp.cdcooper crapldp.nrseqdig crapldp.dslocal crapldp.cdagenci
&GLOBAL-DEFINE NomeDoProgramaPrincipal  /wpgd0013.w
&GLOBAL-DEFINE CampoChaveParaRetorno    crapldp.idevento 
&GLOBAL-DEFINE CampoCompltoParaRetorno  crapldp.nrseqdig 
&GLOBAL-DEFINE CampoCompltoParaRetorno2 crapldp.dslocal

/* *** Linhas do cabecalho *** */
&GLOBAL-DEFINE LinhaDeCabecalho1  <td background="/cecred/images/menu/fnd_title.jpg" class="txtNormal" height="22px">&nbsp; &nbsp;Cooperativa</td><td background="/cecred/images/menu/fnd_title.jpg" class="txtNormal" height="22px">&nbsp; &nbsp;PA</td><td background="/cecred/images/menu/fnd_title.jpg" class="txtNormal" height="22px">&nbsp; &nbsp;Descrição</td>
&GLOBAL-DEFINE LinhaDeCabecalho2  -------------- ------- -------------------

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE Criterio  BEGINS
&GLOBAL-DEFINE Criterio1 MATCHES
&GLOBAL-DEFINE Criterio2 =

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE NomeCriterio  Inicia
&GLOBAL-DEFINE NomeCriterio1 Contém 
&GLOBAL-DEFINE NomeCriterio2 

DEFINE VARIABLE pesquisa            AS CHARACTER          NO-UNDO.
DEFINE VARIABLE opcao-pesquisa      AS CHARACTER          NO-UNDO.
DEFINE VARIABLE OpcaoNavegacao      AS CHARACTER          NO-UNDO.
DEFINE VARIABLE NomeDoCampo         AS CHARACTER          NO-UNDO.
DEFINE VARIABLE vtippesquisa        AS CHARACTER          NO-UNDO.
DEFINE VARIABLE vcriterio           AS CHARACTER          NO-UNDO.
DEFINE VARIABLE ContadorDeRegistros AS INTEGER            NO-UNDO.
DEFINE VARIABLE conta               AS INTEGER            NO-UNDO.
DEFINE VARIABLE PonteiroDeInicio    AS ROWID              NO-UNDO. 
DEFINE VARIABLE PonteiroDeFim       AS ROWID              NO-UNDO.
DEFINE VARIABLE valorcampo          as CHAR               NO-UNDO.
DEFINE VARIABLE aux_idevento        LIKE crapldp.idevento NO-UNDO.
DEFINE VARIABLE v-identificacao     AS CHAR               NO-UNDO.
DEFINE VARIABLE ValorCampo2			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo3			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo4			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo5			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo6			AS CHAR		 NO-UNDO.

DEFINE VARIABLE aux_nmrescop        AS CHAR               NO-UNDO.
DEFINE VARIABLE aux_nmresage        AS CHAR               NO-UNDO.

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

       /* Agnaldo 24/11 - Assume idevento para local sempre como 1 afim de servir tanto para PROGRID quanto para ASSEMBLÉIA */
       aux_idevento     = INT(get-value("ValorCampo"))

       valorcampo       = get-value("ValorCampo")
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

  IF vtippesquisa = "{&NomeCampoDePesquisa}"  AND "{&NomeCampoDePesquisa}" <> ""  THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN DO:
        CASE gnapses.nvoperad:
            /* Operadores e Supervisores */
            WHEN 1 OR 
            WHEN 2 THEN
            DO:
                FIND FIRST {&TabelaPadrao} WHERE {&CampoDePesquisa} {&Criterio} pesquisa AND
                        {&TabelaPadrao}.idevento = aux_idevento AND
                        {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
                        {&TabelaPadrao}.cdagenci = gnapses.cdagenci
                        USE-INDEX crapldp2 NO-LOCK NO-ERROR.
            END.
            /* Gerentes */
            WHEN 3 OR
			WHEN 0 THEN
            DO:
                FIND FIRST {&TabelaPadrao} WHERE {&CampoDePesquisa} {&Criterio} pesquisa AND
                    {&TabelaPadrao}.idevento = aux_idevento AND
                    {&TabelaPadrao}.cdcooper = gnapses.cdcooper 
                    USE-INDEX crapldp2 NO-LOCK NO-ERROR.
            END.
        END CASE.
    END.
    ELSE DO:
        CASE gnapses.nvoperad:
            /* Operadores e Supervisores */
            WHEN 1 OR
            WHEN 2 THEN
            DO:
                FIND FIRST {&TabelaPadrao} WHERE {&CampoDePesquisa} {&Criterio1} "*" + pesquisa + "*" AND
                    {&TabelaPadrao}.idevento = aux_idevento AND
                    {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
                    {&TabelaPadrao}.cdagenci = gnapses.cdagenci
                    USE-INDEX crapldp2 NO-LOCK NO-ERROR.
            END.
            /* Gerentes - Pessoal da CECRED*/
            WHEN 3 OR
			WHEN 0 THEN
            DO:
                FIND FIRST {&TabelaPadrao} WHERE {&CampoDePesquisa} {&Criterio1} "*" + pesquisa + "*" AND
                    {&TabelaPadrao}.idevento = aux_idevento AND
                    {&TabelaPadrao}.cdcooper = gnapses.cdcooper 
                    USE-INDEX crapldp2 NO-LOCK NO-ERROR.
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
                  OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapldp2
                                            WHERE {&CampoDePesquisa} {&Criterio} pesquisa     AND
                                                  {&TabelaPadrao}.idevento = aux_idevento     AND
                                                  {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
                                                  {&TabelaPadrao}.cdagenci = gnapses.cdagenci
                                       NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
              END.
              /* Gerentes - Pessoal da CECRED */
              WHEN 3 OR
			  WHEN 0 THEN
              DO:
                  OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapldp2
                                            WHERE {&CampoDePesquisa} {&Criterio} pesquisa     AND
                                                  {&TabelaPadrao}.idevento = aux_idevento     AND
                                                  {&TabelaPadrao}.cdcooper = gnapses.cdcooper
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
                  OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapldp2
                                            WHERE {&CampoDePesquisa} {&Criterio1} "*" + pesquisa + "*" AND
                                                  {&TabelaPadrao}.idevento = aux_idevento     AND
                                                  {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
                                                  {&TabelaPadrao}.cdagenci = gnapses.cdagenci
                                       NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
              END.
              /* Gerentes - Pessoal da CECRED */
              WHEN 3  OR
			  WHEN 0 THEN
              DO:
                  OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapldp2
                                            WHERE {&CampoDePesquisa} {&Criterio1} "*" + pesquisa + "*" AND
                                                  {&TabelaPadrao}.idevento = aux_idevento     AND
                                                  {&TabelaPadrao}.cdcooper = gnapses.cdcooper 
                                       NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
              END.
          END CASE.
      END. /* ELSE DO: */
  END. /* IF vtippesquisa = "{&NomeCampoDePesquisa}" */

END PROCEDURE.

PROCEDURE TrocaCaracter:

    FIND FIRST crapcop WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcooper    NO-LOCK NO-ERROR.
    IF AVAIL crapcop THEN 
        aux_nmrescop = crapcop.nmrescop.
    ELSE
        aux_nmrescop = "&nbsp;".

    FIND FIRST crapage WHERE crapage.cdcooper = {&TabelaPadrao}.cdcooper    AND
                             crapage.cdagenci = {&TabelaPadrao}.cdagenci    NO-LOCK NO-ERROR.
    IF AVAIL crapage THEN 
        aux_nmresage = crapage.nmresage.
    ELSE
        aux_nmresage = "&nbsp;".

END PROCEDURE.

PROCEDURE PosicionaPonteiro:
END PROCEDURE.
