<? 
/*!
 * FONTE        : busca_detalhes_estorno.php
 * CRIAÇÃO      : James Prust Júnior
 * DATA CRIAÇÃO : 16/09/2015
 * OBJETIVO     : Rotina para buscar os detalhes do estorno
 */
?> 
<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> ''){
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}
	
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta  = (isset($_POST['nrdconta']))  ? $_POST['nrdconta'] : 0;	
	$nrctremp  = (isset($_POST['nrctremp']))  ? $_POST['nrctremp'] : 0;	
	$cdestorno = (isset($_POST['cdestorno'])) ? $_POST['cdestorno'] : 0;	
	
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";	
	$xml .= "   <nrctremp>".$nrctremp."</nrctremp>";	
	$xml .= "   <cdestorno>".$cdestorno."</cdestorno>";	
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "ESTORN", "ESTORN_CONSULTAR_DET_EST", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos',"",true);
	}
	
    $aRegistros = $xmlObj->roottag->tags[1]->tags;
	include('tab_detalhes_estorno.php');
?>
<script>
$('#cdestorno','#frmDetalhesEstorno').val('<?php echo getByTagName($xmlObj->roottag->tags[0]->tags,'cdestorno') ?>');
$('#nmoperad','#frmDetalhesEstorno').val('<?php echo getByTagName($xmlObj->roottag->tags[0]->tags,'nmoperad') ?>');
$('#dtestorno','#frmDetalhesEstorno').val('<?php echo getByTagName($xmlObj->roottag->tags[0]->tags,'dtestorno') ?>');
$('#hrestorno','#frmDetalhesEstorno').val('<?php echo getByTagName($xmlObj->roottag->tags[0]->tags,'hrestorno') ?>');
$('#dsjustificativa','#frmDetalhesEstorno').val('<?php echo retiraCharEspecial(getByTagName($xmlObj->roottag->tags[0]->tags,'dsjustificativa')) ?>');
</script>