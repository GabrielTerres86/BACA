<? 
/***************************************************************************************
 * FONTE        : pct_desconto_indicador.php				�ltima altera��o: --/--/----
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
	$idcalculo   = (isset($_POST['idcalculo'])) ? $_POST['idcalculo'] : 0;
	$idparame    = (isset($_POST['idparame'])) ? $_POST['idparame'] : 0;
	$idindicador = (isset($_POST['idindicador'])) ? $_POST['idindicador'] : 0;
	$vlrbase     = (isset($_POST['vlrbase'])) ? $_POST['vlrbase'] : 0;
	
  $xmlPctDescontoIndicador  = "";
	$xmlPctDescontoIndicador .= "<Root>";
	$xmlPctDescontoIndicador .= "   <Dados>";
	$xmlPctDescontoIndicador .= "	   <idcalculo>".$idcalculo."</idcalculo>";
	$xmlPctDescontoIndicador .= "	   <idparame>".$idparame."</idparame>";
	$xmlPctDescontoIndicador .= "	   <idindicador>".$idindicador."</idindicador>";
	$xmlPctDescontoIndicador .= "	   <vlrbase>".$vlrbase."</vlrbase>";
	$xmlPctDescontoIndicador .= "   </Dados>";
	$xmlPctDescontoIndicador .= "</Root>";
  
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlPctDescontoIndicador, "SIMCRP", "PCT_DESCIND", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjPctDescontoIndicador = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjPctDescontoIndicador->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjPctDescontoIndicador->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);		
							
	}
  
  echo $xmlObjPctDescontoIndicador->roottag->cdata;
  
?>