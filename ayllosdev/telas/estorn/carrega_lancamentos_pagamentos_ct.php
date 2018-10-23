<? 
/*!
 * FONTE        : carrega_lancamentos_pagamentos_ct.php
 * CRIAÇÃO      : Diego Simas (AMcom)
 * DATA CRIAÇÃO : 06/08/2018
 * OBJETIVO     : Rotina para carregar o lançamento da Conta Transitória em Prejuízo
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'ECT')) <> ''){
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}

	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	
	$xml  = "<Root>";
	$xml .= " <Dados>";
    $xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "PREJ0003", "BUSCA_PAGTO_ESTORNO_PRJ", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	$param = $xmlObj->roottag->tags[0]->tags[0];
	
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
		}		
		exibeErroNew($msgErro);
	}

	$totestor = getByTagName($param->tags,'totestor');	
	$datalanc = getByTagName($param->tags,'datalanc');	
		
	require_once("tab_lancamentos_pagamentos_ct.php");
	
function exibeErroNew($msgErro) {	
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","trocaBotao(\'estadoInicial()\',\'ajustaBotaoContinuar()\',\'Continuar\');$(\'#nrctremp\',\'#frmEstornoPagamento\').focus();");';
	exit();
}	
	
?>
<script>
    var operacao = 'ESTORNO_CT';
    trocaBotao('carregaTelaFiltrarContrato()','showConfirmacao(\'Confirma a opera&ccedil;&atilde;o?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'manterRotina(operacao);\',\'\',\'sim.gif\',\'nao.gif\')','Estornar');
    $('#nrdconta','#frmEstornoPagamentoCT').desabilitaCampo();
    $('#totalest','#frmEstornoPagamentoCT').val('<?php echo formataMoeda($totestor); ?>');    
</script>