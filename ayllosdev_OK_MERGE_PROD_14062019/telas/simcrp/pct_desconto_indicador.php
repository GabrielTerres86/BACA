<? 
/***************************************************************************************
 * FONTE        : pct_desconto_indicador.php				Última alteração: --/--/----
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
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjPctDescontoIndicador->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjPctDescontoIndicador->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);		
							
	}
  
  echo $xmlObjPctDescontoIndicador->roottag->cdata;
  
?>