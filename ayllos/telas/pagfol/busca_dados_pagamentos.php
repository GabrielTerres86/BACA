<?
/*!
 * FONTE        : busca_dados_pagamentos.php
 * CRIAÇÃO      : Renato Darosci - SUPERO
 * DATA CRIAÇÃO : Junho/2015
 * OBJETIVO     : Rotina para buscar os estouros de folha de pagamento
 * --------------
 * ALTERAÇÕES   : 21/10/2015 - Envio da opção "P" para retornar os pagamentos na validaPermissao (Marcos-Supero)
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

	$retornoAposErro = '';
	$cdcooper = $_POST['cdcooper'];
	$cdempres = $_POST['cdempres'];
    $dtmvtolt = $_POST['dtmvtolt'];

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'P')) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
?>
<script type="text/javascript" src="../../scripts/funcoes.js"></script>
<?
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$cdcooper.'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<cdempres>'.$cdempres.'</cdempres>';
    $xml .= '		<dtmvtolt>'.$dtmvtolt.'</dtmvtolt>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "PAGFOL", "CONSFLPG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro);
	}

	// Recebendo os valores atraves de atriburos da TAG
	$nmcooper  = $xmlObjeto->roottag->attributes['NMCOOPER'];
	$dsempres  = $xmlObjeto->roottag->attributes['DSEMPRES'];
	$dsdregio  = $xmlObjeto->roottag->attributes['DSDREGIO'];
	$nmconspj  = $xmlObjeto->roottag->attributes['NMCONSPJ'];
	$nmagenci  = $xmlObjeto->roottag->attributes['NMAGENCI'];
    $nrdconta  = $xmlObjeto->roottag->attributes['NRDCONTA'];
    $dtultufp  = $xmlObjeto->roottag->attributes['DTULTUFP'];
	
	$pagamentosFolha = $xmlObjeto->roottag->tags;
	include('tab_folhas_pagto.php');
?>