<?php
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : Julho/2015
 * OBJETIVO     : Mostrar opcao Principal da rotina de Limite Saque TAA da tela de Atenda
 * --------------
 * ALTERAÇÕES   : 27/07/2016 - Corrigi o retorno de erro do XML. SD 479874 (Carlos R.)
 * --------------
 */	
	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();
		
	$operacao 	   = (isset($_POST['operacao']))      ? $_POST['operacao']      : '';	
	$nrdconta	   = (isset($_POST['nrdconta']))      ? $_POST['nrdconta']      : '';	
	$nomeRotinaPai = (isset($_POST['nomeRotinaPai'])) ? $_POST['nomeRotinaPai'] : '';	
	
	// Somente sera verificado o privilegio, quando a rotina for acessada da Atenda -> Limite de Saque TAA
	if (($nomeRotinaPai != 'magnetico') && ($nomeRotinaPai != 'cartao_credito')){
	
		switch($operacao){
			case 'CA': $op = "A"; break;
			case 'AC': $op = "@"; break;
			default:   $op = "@"; break;
		}
		
		// Verifica permissões de acessa a tela
		if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$op)) <> "")
			exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	}
	
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta))
		exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Monta o xml de requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	$xmlResult = mensageria($xml, "LIMITE_SAQUE_TAA", "LIMITE_SAQUE_TAA_CONSULTAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	}

	$oLimite = ( isset($xmlObjeto->roottag->tags[0]) ) ? $xmlObjeto->roottag->tags[0] : '';	
	include('form_limite_saque_taa.php');
?>
<script type='text/javascript'>
	$('#vllimite_saque','#frmLimiteSaqueTAA').val('<?php echo formataMoeda(getByTagName($oLimite->tags,'vllimite_saque')); ?>');
	$('#flgemissao_recibo_saque','#frmLimiteSaqueTAA').val('<?php echo ((getByTagName($oLimite->tags,'flgemissao_recibo_saque') != "") ? getByTagName($oLimite->tags,'flgemissao_recibo_saque') : 0); ?>');
	$('#dtalteracao_limite','#frmLimiteSaqueTAA').val('<?php echo getByTagName($oLimite->tags,'dtalteracao_limite'); ?>');
	$('#nmoperador_alteracao','#frmLimiteSaqueTAA').val('<?php echo getByTagName($oLimite->tags,'nmoperador_alteracao'); ?>');
	controlaLayoutLimiteSaqueTAA('<?php echo $operacao;  ?>');
</script>