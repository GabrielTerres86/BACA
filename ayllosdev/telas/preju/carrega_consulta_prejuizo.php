<? 
/*!
 * FONTE        : carrega_consulta_prejuizo.php
 * CRIAÇÃO      : Jean Calao (Mout´S)
 * DATA CRIAÇÃO : 05/07/2017
 * OBJETIVO     : Rotina para carregar os prejuizos realizados
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
	
	
    $dtprejuz = (isset($_POST['dtprejuz'])) ? $_POST['dtprejuz'] : 0;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
	
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <dtprejuz>".$dtprejuz."</dtprejuz>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrctremp>".$nrctremp."</nrctremp>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";
    
	$xmlResult = mensageria($xml, "PREJU", "CONSULTA_PREJU", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
		
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		if ($msgErro == "") {
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
		}
		exibeErroNew($msgErro);
	
	}
	
	$aRegistros = $xmlObj->roottag->tags;	
	require_once("tab_prejuizos.php");
	
function exibeErroNew($msgErro) {	
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","trocaBotao(\'estadoInicial()\',\'ajustaBotaoContinuar()\',\'Continuar\');$(\'#nrctremp\',\'#frmEstornoPrejuizo\').focus();");';
	exit();
}	
	
?>	
<script>
	trocaBotao('carregaTelaFiltrarContrato()','carregaEstornarTodos()','Estornar Todos');
	$('#dtprejuz','#frmEstornoPrejuizo').desabilitaCampo();
	$('#nrdconta','#frmEstornoPrejuizo').desabilitaCampo();
	$('#nrctremp','#frmEstornoPrejuizo').desabilitaCampo();
</script>