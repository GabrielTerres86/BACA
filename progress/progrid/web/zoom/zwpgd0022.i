/******************************** INCLUDE ZOOM *********************************
PROGRAMA.....:zwpgd0022.i
AUTOR........:B&T/Solusoft 
DESCRIÇÃO....:Zoom da Tabela de Custos Realizados

Alterações...: 10/12/2008 - Melhoria de performance para a tabela gnapses (Evandro).
						  - Utilizar variaveis ValorCampo (Guilherme).
						  
			   05/06/2012 - Adaptação dos fontes para projeto Oracle. Alterado
							busca na gnapses de CONTAINS para MATCHES (Guilherme Maba).
			   
               11/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).			
*******************************************************************************/

&GLOBAL-DEFINE TituloDoPrograma Tabela de Custos Realizados 
&GLOBAL-DEFINE NomeDoProgramaDeZoom zwpgd0022.w
&GLOBAL-DEFINE TabelaPadrao crapcrp

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE CampoDePesquisa  crapedp.nmevento
&GLOBAL-DEFINE CampoDePesquisa1 crapcrp.cdagenci
&GLOBAL-DEFINE CampoDePesquisa2 crapcrp.cdevento
&GLOBAL-DEFINE CampoDePesquisa3 crapcrp.dsobserv

/* *** Nomes dos campos de pesquisa. Deixar em branco as opções não usadas *** */
&GLOBAL-DEFINE NomeCampoDePesquisa  Evento
&GLOBAL-DEFINE NomeCampoDePesquisa1 
&GLOBAL-DEFINE NomeCampoDePesquisa2 
&GLOBAL-DEFINE NomeCampoDePesquisa3 

&GLOBAL-DEFINE CamposDisplay "<td class='txtNormal' height='22px' width='50'>&nbsp; &nbsp;" STRING(crapcrp.dtanoage) "</td>" ~
                             "<td class='txtNormal' height='22px'>&nbsp; &nbsp;" crapcop.nmrescop format "x(40)" "</td>" ~
                             "<td class='txtNormal' height='22px'>&nbsp; &nbsp;" aux_nmresage format "x(40)" "</td>" ~
                             "<td class='txtNormal' height='22px'>&nbsp; &nbsp;" aux_cdcuseve "</td>" ~
                             "<td class='txtNormal' height='22px'>&nbsp; &nbsp;" crapedp.nmevento format "x(40)" "</td>" ~
                             "<td class='txtNormal' height='22px'>&nbsp; &nbsp;" STRING(crapcrp.dtmvtolt)  "</td>" ~
                             "<td class='txtNormal' height='22px' style='text-align:right'>&nbsp; &nbsp;" STRING(crapcrp.vlcusrea, "->>>,>>9.99")  "</td>"
&GLOBAL-DEFINE ListaDeCampos crapcrp.cdevento crapcrp.dsobserv crapcrp.dtanoage crapcrp.cdcooper crapcrp.idevento ~
                             crapcrp.cdcuseve crapcrp.tpcuseve crapcrp.dtmvtolt crapcrp.vlcusrea crapcrp.cdagenci ~
                             crapcrp.nrseqdig
&GLOBAL-DEFINE NomeDoProgramaPrincipal  /wpgd0022.w
&GLOBAL-DEFINE CampoChaveParaRetorno    crapcrp.cdevento
&GLOBAL-DEFINE CampoCompltoParaRetorno  crapcrp.cdevento 
&GLOBAL-DEFINE CampoCompltoParaRetorno2 crapcrp.dsobserv
&GLOBAL-DEFINE CampoCompltoParaRetorno3 crapcrp.dsobserv

/* *** Linhas do cabecalho *** */
&GLOBAL-DEFINE LinhaDeCabecalho1 <td class="txtNormal" background="/cecred/images/menu/fnd_title.jpg" height="22px">&nbsp; &nbsp;Agenda </td> ~
                                 <td class="txtNormal" background="/cecred/images/menu/fnd_title.jpg" height="22px">&nbsp; &nbsp;Cooper </td> ~
                                 <td class="txtNormal" background="/cecred/images/menu/fnd_title.jpg" height="22px">&nbsp; &nbsp;PA     </td> ~
                                 <td class="txtNormal" background="/cecred/images/menu/fnd_title.jpg" height="22px">&nbsp; &nbsp;Custo  </td> ~
                                 <td class="txtNormal" background="/cecred/images/menu/fnd_title.jpg" height="22px">&nbsp; &nbsp;Evento </td> ~
                                 <td class="txtNormal" background="/cecred/images/menu/fnd_title.jpg" height="22px">&nbsp; &nbsp;Data   </td> ~
                                 <td class="txtNormal" background="/cecred/images/menu/fnd_title.jpg" height="22px">&nbsp; &nbsp;Valor  </td>
&GLOBAL-DEFINE LinhaDeCabecalho2 -------------------------------  -------------------------------   

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE Criterio  BEGINS
&GLOBAL-DEFINE Criterio1 MATCHES
&GLOBAL-DEFINE Criterio2 =

/* *** campos para pesquisa. Devem ser preenchidos mesmo não sendo usados *** */
&GLOBAL-DEFINE NomeCriterio  Inicia
&GLOBAL-DEFINE NomeCriterio1  
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
DEFINE VARIABLE valorcampo          as CHAR               no-undo.
DEFINE VARIABLE idevento            LIKE crapcrp.idevento NO-UNDO.
DEFINE VARIABLE v-identificacao     AS CHAR               NO-UNDO.
DEFINE VARIABLE ValorCampo2			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo3			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo4			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo5			AS CHAR		 NO-UNDO.
DEFINE VARIABLE ValorCampo6			AS CHAR		 NO-UNDO.

DEFINE VARIABLE aux_cdcuseve        AS CHAR               NO-UNDO.
DEFINE VARIABLE aux_tpcuseve        AS CHAR               NO-UNDO.
DEFINE VARIABLE aux_nmresage        AS CHAR               NO-UNDO.

DEFINE QUERY QueryPadrao FOR {&TabelaPadrao} FIELDS({&ListaDeCampos}) , crapedp, crapcop SCROLLING.

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
	   ValorCampo2      = GET-VALUE("ValorCampo2") /* Ano da Agenda */
	   ValorCampo3      = GET-VALUE("ValorCampo3") /* Cooperativa selecionada no select */
	   ValorCampo4      = GET-VALUE("ValorCampo4")
	   ValorCampo5      = GET-VALUE("ValorCampo5")
	   ValorCampo6      = GET-VALUE("ValorCampo6").

v-identificacao = get-cookie("cookie-usuario-em-uso").

/* Usado FOR EACH para poder utilizar o CONTAINS e WORD-INDEX */
FOR EACH gnapses WHERE gnapses.idsessao MATCHES "*" + v-identificacao + "*" NO-LOCK:
    LEAVE.
END.

PROCEDURE FindFirst:

  /* Filtro por Observação */
  IF vtippesquisa = "{&NomeCampoDePesquisa}"  AND "{&NomeCampoDePesquisa}" <> "" THEN DO:
    IF vcriterio = "{&NomeCriterio}" THEN DO:
        CASE gnapses.nvoperad:
            /* Pessoal da CECRED */
            WHEN 0 THEN
            DO:
				
                FOR FIRST {&TabelaPadrao} WHERE 
                        {&TabelaPadrao}.idevento = idevento                         AND 
						{&TabelaPadrao}.cdcooper = INT(ValorCampo3)                 AND
						{&TabelaPadrao}.dtanoage = INT(ValorCampo2) NO-LOCK,
                    FIRST crapedp WHERE 
                        {&CampoDePesquisa} {&Criterio} pesquisa                     and
                        (crapedp.cdevento = {&TabelaPadrao}.cdevento                OR
                        {&TabelaPadrao}.cdevento = 0)                               AND
                        crapedp.dtanoage = {&TabelaPadrao}.dtanoage                 AND
                        crapedp.cdcooper = {&TabelaPadrao}.cdcooper                 NO-LOCK ,
                    FIRST crapcop WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcooper NO-LOCK:
                END.
            END.
            /* Operadores e Supervisores */
            WHEN 1 OR
            WHEN 2 THEN
            DO:
                FOR FIRST {&TabelaPadrao} WHERE 
                        {&TabelaPadrao}.idevento = idevento                         AND 
                        {&TabelaPadrao}.cdcooper = gnapses.cdcooper                 AND
						{&TabelaPadrao}.dtanoage = INT(ValorCampo2)					AND
                        ({&TabelaPadrao}.cdagenci = gnapses.cdagenci                OR
                        {&TabelaPadrao}.cdagenci = 0)                               NO-LOCK, 
                    FIRST crapedp WHERE 
                        {&CampoDePesquisa} {&Criterio} pesquisa                     and  
                        (crapedp.cdevento = {&TabelaPadrao}.cdevento                OR
                        {&TabelaPadrao}.cdevento = 0)                               AND
                        crapedp.dtanoage = {&TabelaPadrao}.dtanoage                 AND
                        crapedp.cdcooper = {&TabelaPadrao}.cdcooper                 NO-LOCK,
                    FIRST crapcop WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcooper NO-LOCK:
                END.
            END.
            /* Gerentes */
            WHEN 3 THEN
            DO:
                FOR FIRST {&TabelaPadrao} WHERE 
                        {&TabelaPadrao}.idevento = idevento                         AND
						{&TabelaPadrao}.dtanoage = INT(ValorCampo2)					AND
                        {&TabelaPadrao}.cdcooper = gnapses.cdcooper                 NO-LOCK, 
                    FIRST crapedp WHERE 
                        {&CampoDePesquisa} {&Criterio} pesquisa                     AND
                        (crapedp.cdevento = {&TabelaPadrao}.cdevento                OR
                        {&TabelaPadrao}.cdevento = 0)                               AND
                        crapedp.dtanoage = {&TabelaPadrao}.dtanoage                 AND
                        crapedp.cdcooper = {&TabelaPadrao}.cdcooper                 NO-LOCK,
                    FIRST crapcop WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcooper NO-LOCK:
                END.
            END.
        END CASE.
    END.
  END.
END PROCEDURE.

PROCEDURE OpenQuery:

  IF vtippesquisa = "{&NomeCampoDePesquisa}"   AND "{&NomeCampoDePesquisa}" <> ""  THEN DO:
      IF vcriterio = "{&NomeCriterio}" THEN DO:
          CASE gnapses.nvoperad:
              /* Pessoal da CECRED */
                WHEN 0 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                            WHERE {&TabelaPadrao}.idevento = idevento           AND
								  {&TabelaPadrao}.cdcooper = INT(ValorCampo3)   AND
								  {&TabelaPadrao}.dtanoage = INT(ValorCampo2)   NO-LOCK,
                            FIRST crapedp WHERE 
                                  {&CampoDePesquisa} {&Criterio} pesquisa       AND
                                  (crapedp.cdevento = {&TabelaPadrao}.cdevento  OR
                                   {&TabelaPadrao}.cdevento = 0)                AND
                                  crapedp.dtanoage = {&TabelaPadrao}.dtanoage   AND
                                  crapedp.cdcooper = {&TabelaPadrao}.cdcooper   NO-LOCK,
                            FIRST crapcop WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcooper 
                       NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                END.
                /* Operadores e Supervisores */
                WHEN 1 OR 
                WHEN 2 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao} 
                            WHERE {&TabelaPadrao}.idevento = idevento           AND
                                  {&TabelaPadrao}.cdcooper = gnapses.cdcooper   AND
								  {&TabelaPadrao}.dtanoage = INT(ValorCampo2)   AND
                                  ({&TabelaPadrao}.cdagenci = gnapses.cdagenci  OR
                                   {&TabelaPadrao}.cdagenci = 0)                NO-LOCK,
                            FIRST crapedp WHERE 
                                  {&CampoDePesquisa} {&Criterio} pesquisa       AND
                                  (crapedp.cdevento = {&TabelaPadrao}.cdevento  OR
                                   {&TabelaPadrao}.cdevento = 0)                AND
                                  crapedp.dtanoage = {&TabelaPadrao}.dtanoage   AND
                                  crapedp.cdcooper = {&TabelaPadrao}.cdcooper   NO-LOCK,
                            FIRST crapcop WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcooper
                       NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                    
                END.
                /* Gerentes */
                WHEN 3 THEN
                DO:
                    OPEN QUERY QueryPadrao FOR EACH {&TabelaPadrao}
                            WHERE {&TabelaPadrao}.idevento = idevento           AND
								  {&TabelaPadrao}.dtanoage = INT(ValorCampo2)   AND
                                  {&TabelaPadrao}.cdcooper = gnapses.cdcooper   NO-LOCK,
                            FIRST crapedp WHERE 
                                  {&CampoDePesquisa} {&Criterio} pesquisa       AND
                                  (crapedp.cdevento = {&TabelaPadrao}.cdevento  OR
                                   {&TabelaPadrao}.cdevento = 0)                AND
                                  crapedp.dtanoage = {&TabelaPadrao}.dtanoage   AND
                                  crapedp.cdcooper = {&TabelaPadrao}.cdcooper   NO-LOCK,
                            FIRST crapcop WHERE crapcop.cdcooper = {&TabelaPadrao}.cdcooper
                       NO-LOCK INDEXED-REPOSITION MAX-ROWS 10.
                END.
          END CASE.
      END.
  END.
  
END PROCEDURE.

PROCEDURE TrocaCaracter:

    FIND FIRST craptab WHERE craptab.cdcooper = 0               AND
                             craptab.nmsistem = "CRED"          AND
                             craptab.tptabela = "CONFIG"        AND
                             craptab.cdempres = 0               AND
                             craptab.cdacesso = "PGDCUSTEVE"    AND
                             craptab.tpregist = 0               NO-LOCK NO-ERROR.

    IF AVAIL {&TabelaPadrao} THEN
    DO:
        ASSIGN 
            aux_tpcuseve = IF {&TabelaPadrao}.tpcuseve = 1 THEN "Evento" ELSE "Diverso".
        IF {&TabelaPadrao}.tpcuseve = 1 THEN DO:
            ASSIGN aux_cdcuseve = ENTRY(LOOKUP(STRING({&TabelaPadrao}.cdcuseve), craptab.dstextab) - 1, craptab.dstextab).
        END.
        IF {&TabelaPadrao}.tpcuseve = 2 THEN
        DO:
            FIND FIRST crapcdi WHERE crapcdi.nrseqdig = {&TabelaPadrao}.cdcuseve    NO-LOCK NO-ERROR.
            IF AVAIL crapcdi THEN
                aux_cdcuseve = crapcdi.dscusind.
            ELSE
                aux_cdcuseve = "".
        END.
        FIND FIRST crapage WHERE crapage.cdcooper = {&TabelaPadrao}.cdcooper        AND
                                 crapage.cdagenci = {&TabelaPadrao}.cdagenci        NO-LOCK NO-ERROR.
        IF AVAIL crapage THEN
            ASSIGN aux_nmresage = crapage.nmresage.
        ELSE
            ASSIGN aux_nmresage = "".
    END.
    ELSE
        ASSIGN 
            aux_tpcuseve = "0"
            aux_cdcuseve = "0".

    
END PROCEDURE.

PROCEDURE PosicionaPonteiro:
END PROCEDURE.
