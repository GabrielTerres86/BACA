<?php
/*!
 * FONTE        : manter_alterar.php
 * CRIA??O      : Petter Rafael - Envolti
 * DATA CRIA??O : Janeiro/2019
 * OBJETIVO     : Mostrar opcao pre-aprovado da rotina de Alterar Motivos da tela ATENDA
 * --------------
 * ALTERA??ES   : 
 * --------------
 */
    session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();

    $operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ;
	$opcaoAcao = (isset($_POST['opcaoAcao'])) ? $_POST['opcaoAcao'] : 'cons' ;
	$flglibera = (isset($_POST['flglibera'])) ? $_POST['flglibera'] : '' ;
	$idmotivo = $_POST['idmotivo'];
	$dtatualiza = (isset($_POST['dtatualiza']) && $flglibera==0) ? $_POST['dtatualiza'] : null ;
	$alterar = (isset($_POST['alterar'])) ? $_POST['alterar'] : 0 ;

	switch($operacao){
		case 'MA': $op = "A"; break;
		case 'AM': $op = "@"; break;
		default  : $op = "@"; break;
	}

    // Verifica permissões de acessa a tela
	if(($msgError = validaPermissao($glbvars["nmdatela"], $glbvars["nmrotina"], $op)) <> "") 
		exibirErro('error', $msgError, 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)', false);

	// Verifica se o número da conta foi informado
	if(!isset($_POST["nrdconta"])) 
		exibirErro('error', 'Par&acirc;metros incorretos.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)', false);

    // Verifica se o n?mero da conta e o titular são inteiros válidos
	if(!validaInteiro($nrdconta)) exibirErro('error', 'Conta/dv inv&aacute;lida.', 'Alerta - Ayllos','bloqueiaFundo(divRotina)', false);

	if($opcaoAcao == "ins"){
		
		$xml = "<Root>";
		$xml .= "	<Dados>";
		$xml .= '		<nrdconta>' . $nrdconta . '</nrdconta>'; //pr_nrdconta
		$xml .= '		<flglibera_pre_aprv>' . $flglibera . '</flglibera_pre_aprv>'; //pr_flglibera_pre_aprv
		$xml .= '		<dtatualiza_pre_aprv>' . $dtatualiza . '</dtatualiza_pre_aprv>'; //pr_dtatualiza_pre_aprv
		$xml .= '		<idmotivo>' . $idmotivo . '</idmotivo>'; //pr_idmotivo
		$xml .= "	</Dados>";
		$xml .= "</Root>";

		$xmlResultIns = mensageria($xml, "TELA_ATENDA_PREAPV", "GRAVA_PARAM_PREAPV", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjetoIns = getObjectXML($xmlResultIns);

		if(strtoupper($xmlObjetoIns->roottag->tags[0]->name) == "ERRO"){
			$msgErro = $xmlObjetoIns->roottag->tags[0]->tags[0]->tags[4]->cdata == "" ? $xmlObjetoIns->roottag->tags[0]->cdata : $xmlObjetoIns->roottag->tags[0]->tags[0]->tags[4]->cdata;

			exibirErro('error', htmlentities($msgErro), 'Alerta - Ayllos', 'bloqueiaFundo(divRotina);', false);
		}
	}

	// Monta o xml de requisi??o
	$xml = "<Root>";
	$xml .= "	<Dados>";
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_ATENDA_PREAPV", "RESUMO_PREAPV", $glbvars["cdcooper"], 
							$glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], 
							$glbvars["cdoperad"], "</Root>");
	$xmlObjetoHistorico = getObjectXML($xmlResult);

	if (strtoupper($xmlObjetoHistorico->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjetoHistorico->roottag->tags[0]->tags[0]->tags[4]->cdata == "" ? 
			$xmlObjetoHistorico->roottag->tags[0]->cdata : 
			$xmlObjetoHistorico->roottag->tags[0]->tags[0]->tags[4]->cdata;

		exibirErro('error', htmlentities($msgErro), 'Alerta - Ayllos', 'bloqueiaFundo(divRotina);', false);
	}

	include("form_alterar.php");
?>
<script>
	<? if($alterar != 1){ ?>formataRegraAltera(false);<? } ?>
	$('#idCarga').val('<? echo $xmlObjetoHistorico->roottag->tags[0]->tags[0]->tags[8]->cdata; ?>');
	$('#vigInicial').val('<? echo $xmlObjetoHistorico->roottag->tags[0]->tags[0]->tags[9]->cdata; ?>');
	$('#vigFinal').val('<? echo $xmlObjetoHistorico->roottag->tags[0]->tags[0]->tags[10]->cdata; ?>');

    hideMsgAguardo();
    blockBackground(parseInt($("#divRotina").css("z-index")));
</script>