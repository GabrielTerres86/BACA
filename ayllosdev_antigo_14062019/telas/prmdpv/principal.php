<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Lucas Afonso
 * DATA CRIAÇÃO : 17/09/2015
 * OBJETIVO     : Capturar dados para tela Principal
 * --------------
 * ALTERAÇÕES   :
 * -------------- 
 */
	
	session_cache_limiter("private");
	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;
	
	switch($operacao) {
		case ''  : $cddopcao = 'T'; break;
		case 'BT': $cddopcao = 'T'; break;
		case 'BC': $cddopcao = 'C'; break;
		case 'IC': $cddopcao = 'C'; break;
		case 'AC': $cddopcao = 'C'; break;
		default  : $cddopcao = 'T'; break;
	}
	
	if (($msgError = validaPermissao($glbvars["nmdatela"], $glbvars["nmrotina"], $cddopcao)) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$dsiduser = session_id();
	
	if ($operacao == 'BT') {
		 
		$xml = '';
		$xml .= '<Root>';
		$xml .= '	<Dados>';
		$xml .= '	</Dados>';
		$xml .= '</Root>';


		// Executa script para envio do XML
		$xmlResult = mensageria($xml, "PRMDPV", "BUSCA_TARIFA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");


		// Cria objeto para classe de tratamento de XML
		$xmlObjDados = getObjectXML($xmlResult);

		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
			$msg = $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;
			exibirErro('error', $msg, 'Alerta - Ayllos', '', false);
		}
		$caixa = $xmlObjDados->roottag->tags[0]->cdata != '' ? $xmlObjDados->roottag->tags[0]->cdata : '0,00';
		$internet = $xmlObjDados->roottag->tags[1]->cdata != '' ? $xmlObjDados->roottag->tags[1]->cdata : '0,00';;
		$taa = $xmlObjDados->roottag->tags[2]->cdata != '' ? $xmlObjDados->roottag->tags[2]->cdata : '0,00';;
	}
	
	include('form_cabecalho.php');
	
	if($operacao == 'BT')
		include('form_tarifa.php');
	else if($operacao == 'BC')
		include('form_custo.php');
	else if($operacao == 'IC') {
		$acao = 'Inclusão';
		include('form_grava_custo.php');
	} else if($operacao == 'AC') {
		$exercicio = (isset($_POST['exercicio'])) ? $_POST['exercicio'] : '';
		$integral  = (isset($_POST['integral']))  ? formataMoeda($_POST['integral'],2)  : '';
		$parcelado = (isset($_POST['parcelado'])) ? formataMoeda($_POST['parcelado'],2) : '';
		$acao = 'Alteração';
		include('form_grava_custo.php');
	}
?>
<script type='text/javascript'>
	
	// Alimenta as variáveis globais
	operacao = '<? echo $operacao; ?>';
	CehNovo = operacao == 'IC' ? 'S' : 'N';
	
	controlaLayout();
	
</script>
