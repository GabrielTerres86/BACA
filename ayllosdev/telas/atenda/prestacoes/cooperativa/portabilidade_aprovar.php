<? 
/*!
 * FONTE        : portabilidade_aprovar.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 18/06/2015
 * OBJETIVO     : Gera o XML de aprovacao de portabilidade
 *************
 * ALTERAÇÃO: 
 *************
 */
    session_cache_limiter("private");
	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');		
	require_once('../../../../includes/controla_secao.php');
	require_once('../../../../class/xmlfile.php');
	isPostMethod();	

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();
	}

	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '';
    $nrunico_portabilidade = (isset($_POST['nrunico_portabilidade'])) ? $_POST['nrunico_portabilidade'] : '';

	// Monta o xml de requisição
	$xml = "";
	$xml.= "<Root>";
	$xml.= "	<Dados>";
	$xml.= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml.= "		<nrctremp>".$nrctremp."</nrctremp>";
    $xml.= "		<nrunico_portabilidade>".$nrunico_portabilidade."</nrunico_portabilidade>";
	$xml.= "	</Dados>";
	$xml.= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "PORTAB_CRED", "PORTAB_APRV", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO'){
		$msg = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">
        showError('error','<?php echo utf8_decode($msg); ?>','Alerta - Aimaro',"blockBackground(parseInt($('#divRotina').css('z-index')))");
        </script><?php
		exit();
	}
?>
<script language="javascript">
showError("inform",'<?php echo $xmlObj->roottag->tags[0]->cdata; ?>',"Alerta - Aimaro","blockBackground(parseInt($('#divRotina').css('z-index')))");
</script>