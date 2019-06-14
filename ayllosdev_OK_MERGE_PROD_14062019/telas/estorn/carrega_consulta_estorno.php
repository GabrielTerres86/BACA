<? 
/*!
 * FONTE        : carrega_consulta_estorno.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : 14/09/2015
 * OBJETIVO     : Rotina para carregar os estornos realizados
 * --------------
 * ALTERAÇÕES   : 
 *  - 15/09/2018 - Inclusão do Desconto de Títulos (Vitor S. Assanuma - GFT)
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

	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0;
	$cdtpprod = (isset($_POST['cdtpprod'])) ? $_POST['cdtpprod'] : 0;

	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrctremp>".$nrctremp."</nrctremp>";	
	$xml .= "   <cdtpprod>".$cdtpprod."</cdtpprod>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "ESTORN", "ESTORN_CONSULTAR_EST", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
		}
		exibeErroNew($msgErro);
		//exibirErro('error',$msgErro,'Alerta - Ayllos',"trocaBotao('estadoInicial()','ajustaBotaoContinuar()','Continuar');$('#nrctremp','#frmEstornoPagamento').focus();",true);
	}
	
	$aRegistros = $xmlObj->roottag->tags;	
	require_once("tab_estornos.php");
	
function exibeErroNew($msgErro) {	
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","trocaBotao(\'estadoInicial()\',\'ajustaBotaoContinuar()\',\'Continuar\');$(\'#nrctremp\',\'#frmEstornoPagamento\').focus();");';
	exit();
}	
	
?>	
<script>
	trocaBotao('carregaTelaFiltrarContrato()','carregaTelaConsultarDetalhesEstorno();','Detalhes');
	$('#nrdconta','#frmEstornoPagamento').desabilitaCampo();
	$('#nrctremp','#frmEstornoPagamento').desabilitaCampo();
</script>