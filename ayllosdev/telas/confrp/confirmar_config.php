<?php 
/***************************************************************************************
 * FONTE        : Confirma_config.php				�ltima altera��o: --/--/----
 * CRIA��O      : Lombardi
 * DATA CRIA��O : Mar�o/2016
 * OBJETIVO     : 
 
	 Altera��es   : 
  
 
 **************************************************************************************/

	session_start();
		
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../class/xmlfile.php');
	
	isPostMethod();		
	  
	// Guardo os par�metos do POST em vari�veis	
	$ls_configrp           = (isset($_POST['ls_configrp']))           ? $_POST['ls_configrp'] : '';
	$ls_vinculacoesrp      = (isset($_POST['ls_vinculacoesrp']))      ? $_POST['ls_vinculacoesrp'] : '';
	$vldescontomax_coo     = (isset($_POST['vldescontomax_coo']))     ? $_POST['vldescontomax_coo'] : '';
	$vldescontomax_cee     = (isset($_POST['vldescontomax_cee']))     ? $_POST['vldescontomax_cee'] : '';
	$idparame_reciproci    = (isset($_POST['idparame_reciproci']))    ? $_POST['idparame_reciproci'] : 0;
	$dslogcfg              = (isset($_POST['dslogcfg']))              ? $_POST['dslogcfg'] : 0;
	$cp_idparame_reciproci = (isset($_POST['cp_idparame_reciproci'])) ? $_POST['cp_idparame_reciproci'] : '';
    $cp_desmensagem        = (isset($_POST['cp_desmensagem']))        ? $_POST['cp_desmensagem'] : '';
	$cp_deslogconfrp       = (isset($_POST['cp_deslogconfrp']))       ? $_POST['cp_deslogconfrp'] : '';
    $executafuncao         = (isset($_POST['executafuncao']))         ? $_POST['executafuncao'] : '';
    $divanterior           = (isset($_POST['divanterior']))           ? $_POST['divanterior'] : '';
	
    $xmlConfirmaConf  = "";
	$xmlConfirmaConf .= "<Root>";
	$xmlConfirmaConf .= "   <Dados>";
	$xmlConfirmaConf .= "	   <idparame_reciproci>".$idparame_reciproci."</idparame_reciproci>";
	$xmlConfirmaConf .= "	   <configrp>".$ls_configrp."</configrp>";
	$xmlConfirmaConf .= "	   <vinculacoesrp>".$ls_vinculacoesrp."</vinculacoesrp>";
	$xmlConfirmaConf .= "	   <vldescontomax_coo>".$vldescontomax_coo."</vldescontomax_coo>";
	$xmlConfirmaConf .= "	   <vldescontomax_cee>".$vldescontomax_cee."</vldescontomax_cee>";
	$xmlConfirmaConf .= "	   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlConfirmaConf .= "   </Dados>";
	$xmlConfirmaConf .= "</Root>";
  
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlConfirmaConf, "CONFRP", "CONFIRMA_CONF", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjConfirmaConf = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjConfirmaConf->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjConfirmaConf->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjConfirmaConf->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "nrrecben";
		}
				 
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);		
							
	} 
  
  $idparame_reciproci = $xmlObjConfirmaConf->roottag->tags[0]->cdata;
  $desmensagem        = $xmlObjConfirmaConf->roottag->tags[1]->cdata;
  
  // Incrementar o LOG com o j� existente
  $deslogconfrp       = $dslogcfg.$xmlObjConfirmaConf->roottag->tags[2]->cdata;
    
  $str_populadados  = '$(\'#'.$cp_idparame_reciproci.'\').val(\''.$idparame_reciproci.'\');';
  $str_populadados .= '$(\'#'.$cp_desmensagem.'\').val(\''.$desmensagem.'\');';
  $str_populadados .= '$(\'#'.$cp_deslogconfrp.'\').val(\''.$deslogconfrp.'\');';
  $str_populadados .= 'fechaRotina($(\'#divUsoGenerico\'));';
  $str_populadados .= $executafuncao;
  if ($divanterior != "")
    $str_populadados .= 'bloqueiaFundo($(\'#'.$divanterior.'\'));';
  
  echo $str_populadados;
  
?>