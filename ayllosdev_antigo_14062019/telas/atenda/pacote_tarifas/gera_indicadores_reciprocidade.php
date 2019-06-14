<? 
/***************************************************************************************
 * FONTE        : gera_indicadores_reciprocidade.php				Última alteração: --/--/----
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : Abril/2016
 * OBJETIVO     : 
 
	 Alterações   : 
  
 
 **************************************************************************************/

	session_start();
		
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../class/xmlfile.php');
	
	isPostMethod();		
	
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta  = (isset($_POST['nrdconta']))  ? $_POST['nrdconta']  : 0;
	$dtadesao = (isset($_POST['dtadesao']))  ? $_POST['dtadesao']  : 0;
	
    $xmlGeraExtratoRecip  = "";
	$xmlGeraExtratoRecip .= "<Root>";
	$xmlGeraExtratoRecip .= "   <Dados>";
	$xmlGeraExtratoRecip .= "	   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlGeraExtratoRecip .= "	   <dtadesao>".$dtadesao."</dtadesao>";
	$xmlGeraExtratoRecip .= "   </Dados>";
	$xmlGeraExtratoRecip .= "</Root>";
  
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlGeraExtratoRecip, "ADEPAC", "IMPR_IN_RECIP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjGeraExtratoRecip = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjGeraExtratoRecip->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjGeraExtratoRecip->roottag->tags[0]->tags[0]->tags[4]->cdata;
				 
		exibirErro('error',$msgErro,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);		
							
	} 
	
	echo $xmlObjGeraExtratoRecip->roottag->tags[0]->cdata;
	
?>