<? 
/***************************************************************************************
 * FONTE        : cancela_pacote.php				Última alteração: --/--/----
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
	$cdpacote = (isset($_POST['cdpacote'])) ? $_POST['cdpacote'] : 0;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	$dtadesao = (isset($_POST['dtadesao'])) ? $_POST['dtadesao'] : 0;
	$dtinivig = (isset($_POST['dtinivig'])) ? $_POST['dtinivig'] : ' ';
	$dtcancel = $glbvars["dtmvtolt"];
	
    $xmlValidaInclusao  = "";
	$xmlValidaInclusao .= "<Root>";
	$xmlValidaInclusao .= "   <Dados>";
	$xmlValidaInclusao .= "	   <cdpacote>".$cdpacote."</cdpacote>";
	$xmlValidaInclusao .= "	   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlValidaInclusao .= "	   <dtadesao>".$dtadesao."</dtadesao>";
	$xmlValidaInclusao .= "   </Dados>";
	$xmlValidaInclusao .= "</Root>";
  
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlValidaInclusao, "ADEPAC", "CANCELA_PCT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjValidaInclusao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjValidaInclusao->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjValidaInclusao->roottag->tags[0]->tags[0]->tags[4]->cdata;
				 
		exibirErro('error',$msgErro,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);		
	} 

	$dtcancel = implode('', array_reverse(explode('/', $dtcancel)));
	$dtinivig = implode('', array_reverse(explode('/', $dtinivig)));
	
	if ($dtcancel >= $dtinivig){
		 exibirErro('inform','Opera&ccedil;&atilde;o efetuada com sucesso! </br> Os servi&ccedil;os permanecer&atilde;o vigentes at&eacute; o final deste m&ecirc;s.', 'Alerta - Aimaro', 'acessaOpcaoAba(1,0,0);', false);
	}else{
		exibirErro('inform','Opera&ccedil;&atilde;o efetuada com sucesso!', 'Alerta - Aimaro', 'acessaOpcaoAba(1,0,0);', false);
	}
?>