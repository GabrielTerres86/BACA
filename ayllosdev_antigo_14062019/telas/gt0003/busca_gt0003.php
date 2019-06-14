<? 
/*!
 * FONTE        : busca_gt0003.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 20/09/2013
 * OBJETIVO     : Rotina para buscar dados da tela - GT0003
 * --------------
 * ALTERAÇÕES   : 02/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
 *                             departamento como parametros e passar o o código (Renato Darosci)
 * -------------- 
 *
 * -------------- 
 */
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	// Recebe a operação que está sendo realizada
	
	$cdcooper	= (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
	$cddopcao	= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$dtmvtolt	= (isset($_POST['dtmvtolt'])) ? $_POST['dtmvtolt'] : '?';
	$cdconven   = (isset($_POST['cdconven'])) ? $_POST['cdconven'] : 0;
	$nrregist	= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0;
	$nriniseq	= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0;
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
			
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0177.p</Bo>';
	$xml .= '		<Proc>Busca_Dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';				
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '       <cddepart>'.$glbvars['cddepart'].'</cddepart>';	
	$xml .= '       <cdcooped>'.$cdcooper.'</cdcooped>';
	$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '       <dtmvtola>'.$dtmvtolt.'</dtmvtola>';
	$xml .= '       <cdconven>'.$cdconven.'</cdconven>';
	$xml .= '       <nrregist>'.$nrregist.'</nrregist>';
	$xml .= '       <nriniseq>'.$nriniseq.'</nriniseq>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
			
	$xmlResult = getDataXML($xml);
	
	$xmlObjeto = getObjectXML($xmlResult);
		
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	

		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];			
		                                         
		if (!empty($nmdcampo)) { $mtdErro = " habilitaConsulta(); focaCampoErro('".$nmdcampo."','frmConsulta');"; }
		
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);		
	} 

	// $registros  = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	$registros1 = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	$registros  = $xmlObjeto->roottag->tags[0]->tags;
	
	// Quantidade total de cooperados na pesquisa
	$qtregist = $xmlObjeto->roottag->tags[0]->attributes["QTREGIST"];
	$totqtdoc = $xmlObjeto->roottag->tags[0]->attributes["TOTQTDOC"];
	$totvldoc = $xmlObjeto->roottag->tags[0]->attributes["TOTVLDOC"];
	$tottarif = $xmlObjeto->roottag->tags[0]->attributes["TOTTARIF"];
	$totpagar = $xmlObjeto->roottag->tags[0]->attributes["TOTPAGAR"];

	if($GLOBALS['cddopcao'] != "R"){ 
		include('tab_gt0003.php');
		include('form_totais.php');
	}
?>
<script>
	
	cNmrescop.val("<? echo getByTagName($registros1,'nmrescop') ?>");
	cCdcopdom.val("<? echo getByTagName($registros1,'cdcopdom') ?>");
	cNrcnvfbr.val("<? echo getByTagName($registros1,'nrcnvfbr') ?>");
	cNmempres.val("<? echo getByTagName($registros1,'nmempres') ?>");
	cDtcredit.val("<? echo getByTagName($registros1,'dtcredit') ?>");
	cNmarquiv.val("<? echo getByTagName($registros1,'nmarquiv') ?>");
	cQtdoctos.val("<? echo mascara(getByTagName($registros1,'qtdoctos'),'###.###') ?>");
	cVldoctos.val("<? echo formataMoeda(getByTagName($registros1,'vldoctos')) ?>").trigger('blur');
	cVltarifa.val("<? echo formataMoeda(getByTagName($registros1,'vltarifa')) ?>").trigger('blur');
	cVlapagar.val("<? echo formataMoeda(getByTagName($registros1,'vlapagar')) ?>").trigger('blur');
	cNrsequen.val("<? echo getByTagName($registros1,'nrsequen') ?>");
			
	formataTabela();
		
	cTotqtdoc.val("<? echo mascara($totqtdoc,'###.###'); ?>");
	cTotvldoc.val("<? echo formataMoeda($totvldoc); ?>").trigger('blur');
	cTottarif.val("<? echo formataMoeda($tottarif); ?>").trigger('blur');
	cTotpagar.val("<? echo formataMoeda($totpagar); ?>").trigger('blur');
	
	
</script>