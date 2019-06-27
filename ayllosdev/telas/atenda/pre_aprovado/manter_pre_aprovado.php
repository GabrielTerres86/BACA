<?php
/*!
 * FONTE        : manter_pre_aprovado.php
 * CRIAÇÃO      : Petter Rafael - Envolti
 * DATA CRIAÇÃO : Janeiro/2019
 * OBJETIVO     : Mostrar opcao pre-aprovado da rotina de Pre-Aprovado da tela ATENDA
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
    session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();

	function formata_number($valor) {
		return number_format($valor, 2, ',', '.');
	}

    $operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;	
	
	switch( $operacao ) {
		case 'MA': $op = "A"; break;
		case 'AM': $op = "@"; break;
		default  : $op = "@"; break;
	}

    // Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars["nmdatela"], $glbvars["nmrotina"], $op)) <> "") 
		exibirErro('error', $msgError, 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)', false);
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST["nrdconta"])) 
		exibirErro('error', 'Par&acirc;metros incorretos.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)', false);
    
    $nrdconta = $_POST["nrdconta"] == "" ? 0 : $_POST["nrdconta"];
	
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error', 'Conta/dv inv&aacute;lida.', 'Alerta - Ayllos','bloqueiaFundo(divRotina)', false);

    // Monta o xml de requisição
	$xml = "<Root>";
	$xml .= "	<Dados>";
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= "	</Dados>";
	$xml .= "</Root>";

    $xmlResult = mensageria($xml, "TELA_ATENDA_PREAPV", "RESUMO_PREAPV", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

    if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;

		if ($msgErro == "") {
			$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		}

		exibirErro('error', htmlentities($msgErro), 'Alerta - Ayllos', 'bloqueiaFundo(divRotina);', false);
	}

	$xmlValCalc = $xmlObjeto->roottag->tags[0]->tags[0]->tags[6];

    include('form_pre_aprovado.php');
?>
<script type='text/javascript'>
	$('#idmotivo','#frmPreAprovado').val('<? echo $xmlObjeto->roottag->tags[0]->tags[0]->tags[1]->cdata; ?>');
	$('#dsmotivo','#frmPreAprovado').val('<? echo $xmlObjeto->roottag->tags[0]->tags[0]->tags[2]->cdata; ?>');
	$('#dtatualiza','#frmPreAprovado').val('<? echo $xmlObjeto->roottag->tags[0]->tags[0]->tags[3]->cdata; ?>');
	$('#tipoCarga','#frmPreAprovado').val('<? echo $xmlValCalc->tags[25]->cdata; ?>');
	$('#nrfimpre','#frmPreAprovado').val('<? echo $xmlValCalc->tags[1]->cdata; ?>');
  $('#sumempr','#frmPreAprovado').val('<? echo $xmlValCalc->tags[29]->cdata; ?>');
	$('#vlparcel','#frmPreAprovado').val('<? echo $xmlValCalc->tags[3]->cdata; ?>');
	$('#vldispon','#frmPreAprovado').val('<? echo $xmlValCalc->tags[5]->cdata; ?>');
	$('#vlpotLimMax','#frmPreAprovado').val('<? echo $xmlValCalc->tags[7]->cdata; ?>');
	$('#vlpotParcMax','#frmPreAprovado').val('<? echo $xmlValCalc->tags[9]->cdata; ?>');
	$('#uValorParc','#frmPreAprovado').val('<? echo $xmlValCalc->tags[9]->cdata; ?>');
	$('#vlScr6190','#frmPreAprovado').val('<? echo $xmlValCalc->tags[13]->cdata; ?>');
	$('#vlScr6190Cje','#frmPreAprovado').val('<? echo $xmlValCalc->tags[15]->cdata; ?>');
	$('#vlopePosScr','#frmPreAprovado').val('<? echo $xmlValCalc->tags[17]->cdata; ?>');
	$('#vlopePosScrCje','#frmPreAprovado').val('<? echo $xmlValCalc->tags[19]->cdata; ?>');
	$('#vlpropAndamt','#frmPreAprovado').val('<? echo $xmlValCalc->tags[21]->cdata; ?>');
	$('#vlpropAndamtCje','#frmPreAprovado').val('<? echo $xmlValCalc->tags[23]->cdata; ?>');

	var operacao = '<? echo $operacao;  ?>';
	controlaLayout(operacao);
</script>