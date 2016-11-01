<? 
/***************************************************************************************
 * FONTE        : emite_crrl713.php				Última alteração: --/--/----
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : Março/2016
 * OBJETIVO     : 
 
	 Alterações   : 
  
 
 **************************************************************************************/
?>
<?
	session_start();
		
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../class/xmlfile.php');
	
	isPostMethod();		
	  
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta  = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idcalculo = (isset($_POST['idcalculo'])) ? $_POST['idcalculo'] : 0;
	$idparame  = (isset($_POST['idparame'])) ? $_POST['idparame'] : 0;
	
  $xmlEmiteOcorrencias  = "";
	$xmlEmiteOcorrencias .= "<Root>";
	$xmlEmiteOcorrencias .= "   <Dados>";
	$xmlEmiteOcorrencias .= "	   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlEmiteOcorrencias .= "	   <nrdconta>".$nrdconta."</nrdconta>";
	$xmlEmiteOcorrencias .= "	   <idcalculo>".$idcalculo."</idcalculo>";
	$xmlEmiteOcorrencias .= "	   <idparame>".$idparame."</idparame>";
	$xmlEmiteOcorrencias .= "   </Dados>";
	$xmlEmiteOcorrencias .= "</Root>";
  
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlEmiteOcorrencias, "SIMCRP", "EMITE_CRRL713", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjEmiteOcorrencias = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjEmiteOcorrencias->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjEmiteOcorrencias->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);		
							
	} 
  
  echo $xmlObjEmiteOcorrencias->roottag->cdata;
  
?>