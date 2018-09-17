<? 
/*!
 * FONTE        : busca_lislot.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 20/02/2014
 * OBJETIVO     : Rotina para buscar lista de históricos do sistema - LISLOT
 * --------------
 * ALTERAÇÕES   : 11/03/2015 - Uso da função formataMoeda() no valor total (Carlos)
 * -------------- 
 *                05/01/2016 - Corrigido opcao de acesso da tela, de 'C' para 'T'.
 *                             (Chamado 377898) - (Fabricio)
 *
 *                05/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
 *                             departamento como parametros e passar o o código (Renato Darosci)
 * -------------- 
 */
?>
 
<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	// Inicializa
	$procedure 		= '';
		
	// Recebe a operação que está sendo realizada
		
	$cddopcao	= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$tpdopcao	= (isset($_POST['tpdopcao'])) ? $_POST['tpdopcao'] : '';
	$cdagenci	= (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0;
	$cdhistor	= (isset($_POST['cdhistor'])) ? $_POST['cdhistor'] : 0;
	$nrdconta	= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '?';
	$dtinicio	= (isset($_POST['dtinicio'])) ? $_POST['dtinicio'] : '?';
	$dttermin	= (isset($_POST['dttermin'])) ? $_POST['dttermin'] : '?';
	$nrregist	= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0;
	$nriniseq	= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0;
		
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'T')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
			
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0184.p</Bo>';
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
	$xml .= '       <dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '       <tpdopcao>'.$tpdopcao.'</tpdopcao>';
	$xml .= '       <cdagenci>'.$cdagenci.'</cdagenci>';
	$xml .= '       <cdhistor>'.$cdhistor.'</cdhistor>';
	$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '       <dtinicio>'.$dtinicio.'</dtinicio>';
	$xml .= '       <dttermin>'.$dttermin.'</dttermin>';
	$xml .= '       <nrregist>'.$nrregist.'</nrregist>';
	$xml .= '       <nriniseq>'.$nriniseq.'</nriniseq>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
			
	$xmlResult = getDataXML($xml);
	
	$xmlObjeto = getObjectXML($xmlResult);
		
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	

		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];	
		if (!empty($nmdcampo)) { $mtdErro = " $('#".$nmdcampo."','#frmCab').focus();"; }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);		
	} 
    
	$registros     = $xmlObjeto->roottag->tags[0]->tags;
	$registroCaixa = $xmlObjeto->roottag->tags[2]->tags;
	$registroLote  = $xmlObjeto->roottag->tags[3]->tags;
	
	// Quantidade total de cooperados na pesquisa
	$qtregist = $xmlObjeto->roottag->tags[0]->attributes["QTREGIST"];
	
	$vllanmta = $xmlObjeto->roottag->tags[0]->attributes["VLLANMTO"];
	
	switch ($tpdopcao) {
		case "COOPERADO":
			include ('tab_lislot.php');
			break;
		case "CAIXA":
			include ('tab_caixa.php');
			break;
		case "LOTE P/PA":
			include ('tab_lote.php');
			break;
		default:
			
			break;

	}
	
	include ('form_detalhe.php');
		
?>
<script>

	if(cTpdopcao.val() == "COOPERADO"){

		formataTabela();
		
	}else if(cTpdopcao.val() == "CAIXA"){
	
		formataTabCaixa();
	
	}else if(cTpdopcao.val() == "LOTE P/PA"){
	
		formataTabLote();
	
	}
	
	cTotregis.val("<? echo $qtregist ?>");	
	cVllanmto.val("<? echo formataMoeda($vllanmta)?>");
		
</script>
