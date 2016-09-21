<? 
/***************************************************************************************
 * FONTE        : emite_crrl713.php				�ltima altera��o: --/--/----
 * CRIA��O      : Lombardi
 * DATA CRIA��O : Mar�o/2016
 * OBJETIVO     : 
 
	 Altera��es   : 
  
 
 **************************************************************************************/
?>
<?
	session_start();
		
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../class/xmlfile.php');
	
	isPostMethod();		
	  
	// Guardo os par�metos do POST em vari�veis	
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
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjEmiteOcorrencias->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjEmiteOcorrencias->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);		
							
	} 
  
  echo $xmlObjEmiteOcorrencias->roottag->cdata;
  
?>