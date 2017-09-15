<? 
/*!
 * FONTE        : carrega_consulta_pagto.php
 * CRIAÇÃO      : Jean Calao (Mout´S)
 * DATA CRIAÇÃO : 05/08/2017
 * OBJETIVO     : Rotina para carregar os pagamentos realizados
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

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> ''){
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 0;
	$dtpagto  = (isset($_POST['dtpagto'])) ? $_POST['dtpagto'] : 0;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
	
	if ($cddopcao == "C") {
		$xml  = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <dtpagto>".$dtpagto."</dtpagto>";
		$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "   <nrctremp>".$nrctremp."</nrctremp>";	
		$xml .= " </Dados>";
		$xml .= "</Root>";
		
		$procedure = "CONSULTA_PAGPRJ";
	}
	else {
		$xml  = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <dtpagto>".$dtpagto."</dtpagto>";
		$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "   <nrctremp>".$nrctremp."</nrctremp>";	
		$xml .= " </Dados>";
		$xml .= "</Root>";
		
		$procedure = "BUSCA_VALORES";
	}
	$xmlResult = mensageria($xml, "PAGPRJ", $procedure, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
		
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		if ($msgErro == "") {
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
		}
		exibeErroNew($msgErro);
	
	}
	
	$aRegistros = $xmlObj->roottag->tags;	
	if ($cddopcao == "P") {
	    require_once("tab_efetiva_pagamento.php");
	}
    else {
	   require_once("tab_pagamentos.php");
	}
	
function exibeErroNew($msgErro) {	
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","trocaBotao(\'estadoInicial()\',\'ajustaBotaoContinuar()\',\'Continuar\');$(\'#nrctremp\',\'#frmEstornoPagto\').focus();");';
	exit();
}	
	
?>	
<script>
    
	if ( $('#cddopcao','#frmCab').val()  == 'C') {			
		trocaBotao('carregaTelaFiltrarContrato()','carregaEstornarTodos()','Estornar Todos');
	}
    else
	{
		trocaBotao('carregaTelaFiltrarContrato()','carregaPagtoEpr()','Continuar');
	}
	$('#dtpagto','#frmEstornoPagto').desabilitaCampo();
	$('#nrdconta','#frmEstornoPagto').desabilitaCampo();
	$('#nrctremp','#frmEstornoPagto').desabilitaCampo();
	
</script>