<? 
/***************************************************************************************
 * FONTE        : busca_minmax.php				�ltima altera��o: --/--/----
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
	$ls_vlcontrata = (isset($_POST['ls_vlcontrata'])) ? $_POST['ls_vlcontrata'] : '';
	$idcalculo          = (isset($_POST['idcalculo'])) ? $_POST['idcalculo'] : 0;
	$idparame_reciproci = (isset($_POST['idparame_reciproci'])) ? $_POST['idparame_reciproci'] : 0;
	
    $xmlBuscaMinMax  = "";
	$xmlBuscaMinMax .= "<Root>";
	$xmlBuscaMinMax .= "   <Dados>";
	$xmlBuscaMinMax .= "	   <ls_vlcontrata>".$ls_vlcontrata."</ls_vlcontrata>";
	$xmlBuscaMinMax .= "	   <idcalculo>".$idcalculo."</idcalculo>";
	$xmlBuscaMinMax .= "	   <idparame_reciproci>".$idparame_reciproci."</idparame_reciproci>";
	$xmlBuscaMinMax .= "   </Dados>";
	$xmlBuscaMinMax .= "</Root>";
  
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlBuscaMinMax, "SIMCRP", "BUSCA_MINMAX", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjBuscaMinMax = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjBuscaMinMax->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjBuscaMinMax->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);		
							
	}
  
  echo $xmlObjBuscaMinMax->roottag->cdata;
  
?>