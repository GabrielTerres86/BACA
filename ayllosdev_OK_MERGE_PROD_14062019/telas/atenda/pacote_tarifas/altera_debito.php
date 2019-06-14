<? 
/***************************************************************************************
 * FONTE        : altera_debito.php				Última alteração: --/--/----
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
	$cdpacote    = (isset($_POST['cdpacote']))    ? $_POST['cdpacote']    : 0;
	$nrdconta    = (isset($_POST['nrdconta']))    ? $_POST['nrdconta']    : 0;
	$dtadesao    = (isset($_POST['dtadesao']))    ? $_POST['dtadesao']    : 0;
	$dtdiadebito = (isset($_POST['dtdiadebito'])) ? $_POST['dtdiadebito'] : 0;
	
    $xmlValidaInclusao  = "";
	$xmlValidaInclusao .= "<Root>";
	$xmlValidaInclusao .= "   <Dados>";
	$xmlValidaInclusao .= "	   <cdpacote>".$cdpacote."</cdpacote>";
	$xmlValidaInclusao .= "	   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlValidaInclusao .= "	   <dtadesao>".$dtadesao."</dtadesao>";
	$xmlValidaInclusao .= "	   <dtdiadebito>".$dtdiadebito."</dtdiadebito>";
	$xmlValidaInclusao .= "   </Dados>";
	$xmlValidaInclusao .= "</Root>";
  
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlValidaInclusao, "ADEPAC", "ALTERA_DEBI", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjValidaInclusao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjValidaInclusao->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjValidaInclusao->roottag->tags[0]->tags[0]->tags[4]->cdata;
				 
		exibirErro('error',$msgErro,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);		
							
	} 
	
	exibirErro('inform','Opera&ccedil;&atilde;o efetuada com sucesso!','Alerta - Aimaro','acessaOpcaoAba(1,0,0);',false);
	
?>