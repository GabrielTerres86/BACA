<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 27/10/2011
 * OBJETIVO     : Capturar dados para tela SUMLOT
 * --------------
 * ALTERAÇÕES   : 
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

	$retornoAposErro  = "";
	
	// Recebe o POST
	$cdagenci 			= (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0  ;
	$cdbccxlt 			= (isset($_POST['cdbccxlt'])) ? $_POST['cdbccxlt'] : 0  ;
	$dsiduser 			= session_id();
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0121.p</Bo>';
	$xml .= '		<Proc>Gera_Criticas</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<dtmvtoan>'.$glbvars['dtmvtoan'].'</dtmvtoan>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '		<cdagencx>'.$cdagenci.'</cdagencx>';
	$xml .= '		<cdbccxlt>'.$cdbccxlt.'</cdbccxlt>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult 	= getDataXML($xml);
	$xmlObjeto 	= getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		if (!empty($nmdcampo)) { $retornoAposErro = $retornoAposErro . " $('#".$nmdcampo."','#frmCab').focus();"; }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	} 

	$qtcompln	= $xmlObjeto->roottag->tags[0]->attributes['QTCOMPLN'];
	$vlcompap	= $xmlObjeto->roottag->tags[0]->attributes['VLCOMPAP'];
	$nmarqpdf	= $xmlObjeto->roottag->tags[0]->attributes['NMARQPDF'];
	
	echo "cQtcompln.val('".mascara($qtcompln,'#.###.###') ."');";
	echo "cVlcompap.val('".formataMoeda($vlcompap)."');";
	echo "cNmarqpdf.val('".$nmarqpdf."');";
	
	echo "Gera_Criticas();";
?>