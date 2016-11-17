/******************************** INCLUDE ZOOM *********************************
PROGRAMA.....:zwpgd0011.i
AUTOR........:B&T/Solusoft 
DESCRIÇÃO....:Zoom da Tabela de Sugestões

Alterações...: 11/12/2008 - Utilizar variaveis ValorCampo (Guilherme).

			   05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
				            busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
			   
               11/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero). 			
               
               03/05/2016 - Alteracao na opcao procura que sera no modo contém
                            (Carlos Rafael Tanholi).
                            
               17/08/2016 - Revertido ajustes mencionado acima, e tratado para 
                            para exibir a opçao default pelo .htm 
                            PRJ229 - Melhorias OQS (Odirlei-AMcom)
                            
                            
*******************************************************************************/

&GLOBAL-DEFINE TituloDoPrograma Tabela de Sugestões 
&GLOBAL-DEFINE NomeDoProgramaDeZoom zwpgd0011.w
&GLOBAL-DEFINE TabelaPadrao crapsdp

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE CampoDePesquisa  crapsdp.nrseqdig
&GLOBAL-DEFINE CampoDePesquisa1 crapsdp.dssugeve
&GLOBAL-DEFINE CampoDePesquisa2 crapsdp.dssugeve
&GLOBAL-DEFINE CampoDePesquisa3 crapsdp.dssugeve

/* *** Nomes dos campos de pesquisa. Deixar em branco as opções não usadas *** */
&GLOBAL-DEFINE NomeCampoDePesquisa  Sugestão
&GLOBAL-DEFINE NomeCampoDePesquisa1 Descrição
&GLOBAL-DEFINE NomeCampoDePesquisa2 
&GLOBAL-DEFINE NomeCampoDePesquisa3 

/* *** Demais campos relacionados com o layout *** */
&GLOBAL-DEFINE CamposDisplay "<td class='txtNormal' height='22px'>&nbsp; &nbsp;" aux_nmrescop FORMAT "x(20)" "</td><td class='txtNormal' height='22px'>&nbsp; &nbsp;"  aux_nmresage FORMAT "x(20)" "</td><td class='txtNormal' height='22px'>&nbsp; &nbsp;" crapsdp.dtmvtolt FORMAT "99/99/9999" "</td><td class='txtNormal' height='22px'>&nbsp; &nbsp;" crapsdp.nrseqdig FORMAT "zzzzz9" "</td><td class='txtNormal' height='22px'>&nbsp; &nbsp;" crapsdp.dssugeve FORMAT "x(40)" "</td>"
&GLOBAL-DEFINE ListaDeCampos crapsdp.dssugeve crapsdp.nrseqdig crapsdp.dtmvtolt crapsdp.cdcooper crapsdp.cdagenci crapsdp.idevento
&GLOBAL-DEFINE NomeDoProgramaPrincipal  /wpgd0011.w
&GLOBAL-DEFINE CampoChaveParaRetorno    crapsdp.nrseqdig
&GLOBAL-DEFINE CampoCompltoParaRetorno  crapsdp.dssugeve 
&GLOBAL-DEFINE CampoCompltoParaRetorno2 crapsdp.nrseqdig

/* *** Linhas do cabecalho *** */
&GLOBAL-DEFINE LinhaDeCabecalho1 <td background="/cecred/images/menu/fnd_title.jpg" class="txtNormal" height="22px">&nbsp; &nbsp;Cooper</td><td background="/cecred/images/menu/fnd_title.jpg" class="txtNormal" height="22px">&nbsp; &nbsp;PA</td><td background="/cecred/images/menu/fnd_title.jpg" class="txtNormal" height="22px">&nbsp; &nbsp;Data</td><td background="/cecred/images/menu/fnd_title.jpg" class="txtNormal" height="22px">&nbsp; &nbsp;Sugest</td><td background="/cecred/images/menu/fnd_title.jpg" class="txtNormal" height="22px">&nbsp; &nbsp;Descrição</td>
&GLOBAL-DEFINE LinhaDeCabecalho2 ------  ----- ----------- ------- ----------------------------------------

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE Criterio  >=
&GLOBAL-DEFINE Criterio1 MATCHES
&GLOBAL-DEFINE Criterio2 =

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE NomeCriterio  >=
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
DEFINE VARIABLE v-identificacao     AS CHAR      NO-UNDO.
DEFINE VARIABLE ValorCampo2			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo3			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo4			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo5			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo6			AS CHAR		 NO-UNDO.

DEFINE VARIABLE aux_nmrescop        AS CHAR      NO-UNDO.
DEFINE VARIABLE aux_nmresage        AS CHAR      NO-UNDO.

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
	   ValorCampo2      = GET-VALUE("ValorCampo2") /* Cooperativa selecionada no select */
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

  IF vtippesquisa = "{&NomeCampoDePesquisa}"   AND "{&NomeCampoDePesquisa}" <> ""  THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN DO:
        CASE gnapses.nvoperad:
            /* Operadores e Supervisores */
            WHEN 1 OR
            WHEN 2 THEN
            DO:
                FIND FIRST {&TabelaPadrao} USE-INDEX crapsdp1
                    WHERE {&CampoDePesquisa} {&Criterio} int(pesquisa) AND
                           {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
                           {&TabelaPadrao}.cdagenci = gnapses.cdagenci NO-LOCK NO-ERROR.
            END.
            /* Gerentes - Pessoal da CECRED */
            WHEN 3 OR
			WHEN 0 THEN
            DO:
                FIND FIRST {&TabelaPadrao} USE-INDEX crapsdp1
                    WHERE {&CampoDePesquisa} {&Criterio} int(pesquisa) AND
                    {&TabelaPadrao}.cdcooper = INT(ValorCampo2)
                    NO-LOCK NO-ERROR.
            END.
        END CASE.
    END.
    ELSE IF vcriterio = "{&NomeCriterio1}" THEN DO:
        CASE gnapses.nvoperad:
            /* Operadores e Supervisores */
            WHEN 1 OR
            WHEN 2 THEN
            DO:
                FIND FIRST {&TabelaPadrao} USE-INDEX crapsdp1
                    WHERE STRING({&CampoDePesquisa}) {&Criterio1} "*" + string(pesquisa) + "*" AND
                           {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
                           {&TabelaPadrao}.cdagenci = gnapses.cdagenci NO-LOCK NO-ERROR.
            END.
            /* Gerentes */
            WHEN 3 OR
			WHEN 0 THEN
            DO:
                FIND FIRST {&TabelaPadrao} USE-INDEX crapsdp1
                    WHERE STRING({&CampoDePesquisa}) {&Criterio1} "*" + string(pesquisa) + "*" AND
                    {&TabelaPadrao}.cdcooper = INTEGER(ValorCampo2) NO-LOCK NO-ERROR.
            END.
        END CASE.
    END.
  END.
  ELSE
  IF vtippesquisa = "{&NomeCampoDePesquisa1}"  AND "{&NomeCampoDePesquisa1}" <> "" THEN DO:
      IF vcriterio = "{&NomeCriterio}" THEN DO:
          CASE gnapses.nvoperad:
              /* Operadores e Supervisores */
              WHEN 1 OR
              WHEN 2 THEN
              DO:
                  FIND FIRST {&TabelaPadrao} USE-INDEX crapsdp2
                      WHERE {&CampoDePesquisa1} {&Criterio} pesquisa    AND
                           {&TabelaPadrao}.cdcooper = gnapses.cdcooper  AND
                           {&TabelaPadrao}.cdagenci = gnapses.cdagenci
                      NO-LOCK NO-WAIT NO-ERROR.
              END.
              /* Gerentes - Pessoal da CECRED*/
              WHEN 3 OR
			        WHEN 0 THEN
              DO:
                  FIND FIRST {&TabelaPadrao} USE-INDEX crapsdp2
                      WHERE {&CampoDePesquisa1} {&Criterio} pesquisa AND
                    {&TabelaPadrao}.cdcooper = INTEGER(ValorCampo2) NO-LOCK NO-WAIT NO-ERROR.
              END.
          END CASE.
      END.
      ELSE IF vcriterio = "{&NomeCriterio1}" THEN DO:
      
          CASE gnapses.nvoperad:
              /* Operadores e Supervisores */
              WHEN 1 OR
              WHEN 2 THEN
              DO:
                  FIND FIRST {&TabelaPadrao} USE-INDEX crapsdp1
                      WHERE STRING({&CampoDePesquisa1}) {&Criterio1} "*" + string(pesquisa) + "*" AND
                           {&TabelaPadrao}.cdcooper = gnapses.cdcooper AND
                           {&TabelaPadrao}.cdagenci = gnapses.cdagenci NO-LOCK NO-ERROR.
              END.
              /* Gerentes - Pessoal da CECRED */
              WHEN 3 OR
			        WHEN 0 THEN
              DO:
                  FIND FIRST {&TabelaPadrao} USE-INDEX crapsdp1
                      WHERE STRING({&CampoDePesquisa1}) {&Criterio1} "*" + string(pesquisa) + "*" AND
                    {&TabelaPadrao}.cdcooper = INTEGER(ValorCampo2) NO-LOCK NO-ERROR.
              END.
              
          END CASE.
      END.
  END.
  
END PROCEDURE.

PROCEDURE OpenQuery:
    IF vtippesquisa = "{&NomeCampoDePesquisa}"   AND "{&NomeCampoDePesquisa}" <> ""  THEN DO:
        IF vcriterio = "{&NomeCriterio}" THEN DO:
            CASE gnapses.nvoperad:
                /* Operadores e Supervisores */
                WHEN 1 OR 
                WHEN 2 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapsdp1
                                              WHERE {&CampoDePesquisa} {&Criterio} int(pesquisa) AND
                                                  {&TabelaPadrao}.cdcooper = gnapses.cdcooper    AND
                                                  {&TabelaPadrao}.cdagenci = gnapses.cdagenci
                                           NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                END.
                /* Gerentes - Pessoal da CECRED */
                WHEN 3 OR
				WHEN 0 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapsdp1
                                              WHERE {&CampoDePesquisa} {&Criterio} int(pesquisa) AND
                                                  {&TabelaPadrao}.cdcooper = INTEGER(ValorCampo2)
                                           NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                END.
            END CASE.
        END.
        ELSE IF vcriterio = "{&NomeCriterio1}" THEN DO:
            CASE gnapses.nvoperad:
                /* Operadores e Supervisores */
                WHEN 1 OR 
                WHEN 2 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapsdp1
                                              WHERE STRING({&CampoDePesquisa}) {&Criterio1} "*" + string(pesquisa) + "*" AND
                                                  {&TabelaPadrao}.cdcooper = gnapses.cdcooper    AND
                                                  {&TabelaPadrao}.cdagenci = gnapses.cdagenci
                                           NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                END.
                /* Gerentes */
                WHEN 3 OR
				WHEN 0 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapsdp1
                                              WHERE STRING({&CampoDePesquisa}) {&Criterio1} "*" + string(pesquisa) + "*" AND
                                                  {&TabelaPadrao}.cdcooper = INTEGER(ValorCampo2)
                                           NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                END.
            END CASE.
        END.
    END.
    ELSE
    IF vtippesquisa = "{&NomeCampoDePesquisa1}"  AND "{&NomeCampoDePesquisa1}" <> "" THEN DO:
        IF vcriterio = "{&NomeCriterio}" THEN DO:
            CASE gnapses.nvoperad:
                /* Operadores e Supervisores */
                WHEN 1 OR 
                WHEN 2 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapsdp2
                                              WHERE {&CampoDePesquisa1} {&Criterio} pesquisa    AND
                                                  {&TabelaPadrao}.cdcooper = gnapses.cdcooper    AND
                                                  {&TabelaPadrao}.cdagenci = gnapses.cdagenci
                                           NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                END.
                /* Gerentes */
                WHEN 3 OR
				WHEN 0 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapsdp2
                                              WHERE {&CampoDePesquisa1} {&Criterio} pesquisa AND
                                                  {&TabelaPadrao}.cdcooper = INTEGER(ValorCampo2)
                                           NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                END.
            END CASE.
        END.
        ELSE IF vcriterio = "{&NomeCriterio1}" THEN DO:
            CASE gnapses.nvoperad:
                /* Operadores e Supervisores */
                WHEN 1 OR 
                WHEN 2 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapsdp2
                                              WHERE STRING({&CampoDePesquisa1}) {&Criterio1} "*" + pesquisa + "*" AND
                                                  {&TabelaPadrao}.cdcooper = gnapses.cdcooper    AND
                                                  {&TabelaPadrao}.cdagenci = gnapses.cdagenci
                                           NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                END.
                /* Gerentes */
                WHEN 3 OR
				WHEN 0 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} USE-INDEX crapsdp2
                                              WHERE STRING({&CampoDePesquisa1}) {&Criterio1} "*" + pesquisa + "*" AND
                                                  {&TabelaPadrao}.cdcooper = INTEGER(ValorCampo2)
                                           NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                END.
            END CASE.
        END.
    END.
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
