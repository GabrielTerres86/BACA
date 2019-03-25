<? 
/*!
 * FONTE        : carrega_lancamentos_pagamentos.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : 14/09/2015
 * OBJETIVO     : Rotina para carregar os lancamentos de pagamentos
 * --------------
 * ALTERAÇÕES   : 29/10/2018 - Adicionado variavel cdtpprod no xml (Cássia de Oliveitra - GFT)
 * -------------- 
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'E')) <> ''){
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}

	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
	$cdtpprod = (isset($_POST['cdtpprod'])) ? $_POST['cdtpprod'] : 0;
	
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "	<cdtpprod>".$cdtpprod."</cdtpprod>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrctremp>".$nrctremp."</nrctremp>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "ESTORN", "ESTORN_CON_LANCTO_EST", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
		}
		
		exibeErroNew($msgErro);
	//	exibirErro('error',$msgErro,'Alerta - Ayllos',"trocaBotao('estadoInicial()','ajustaBotaoContinuar()','Continuar');$('#nrctremp','#frmEstornoPagamento').focus();",true);
	
	}
		
	$aRegistros = $xmlObj->roottag->tags[0]->tags;	
	require_once("tab_lancamentos_pagamentos.php");
	
function exibeErroNew($msgErro) {	
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","trocaBotao(\'estadoInicial()\',\'ajustaBotaoContinuar()\',\'Continuar\');$(\'#nrctremp\',\'#frmEstornoPagamento\').focus();");';
	exit();
}	
	
?>
<script>
var operacao = 'VALIDA_DADOS';
trocaBotao('carregaTelaFiltrarContrato()','showConfirmacao(\'Confirma a opera&ccedil;&atilde;o?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'manterRotina(operacao, 0);\',\'\',\'sim.gif\',\'nao.gif\')','Estornar');
$('#nrdconta','#frmEstornoPagamento').desabilitaCampo();
$('#nrctremp','#frmEstornoPagamento').desabilitaCampo();
$('#totalest','#frmEstornoPagamento').val('<?php echo formataMoeda(getByTagName($xmlObj->roottag->tags[1]->tags,'vlpagtot')) ?>');
$('#qtdlacto','#frmEstornoPagamento').val('<?php echo getByTagName($xmlObj->roottag->tags[1]->tags,'qtdlacto') ?>');
</script>