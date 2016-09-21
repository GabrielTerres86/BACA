<?php 
/***************************************************************************************
 * FONTE        : Confirma_config.php				Última alteração: --/--/----
 * CRIAÇÃO      : Lombardi
 * DATA CRIAÇÃO : Março/2016
 * OBJETIVO     : 
 
	 Alterações   : 
  
 
 **************************************************************************************/

	session_start();
		
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../class/xmlfile.php');
	
	isPostMethod();		
	  
	// Guardo os parâmetos do POST em variáveis	
	$ls_configrp           = (isset($_POST['ls_configrp']))           ? $_POST['ls_configrp'] : '';
	$perdesmax             = (isset($_POST['perdesmax']))             ? $_POST['perdesmax'] : '';
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
	$xmlConfirmaConf .= "	   <perdesmax>".$perdesmax."</perdesmax>";
	$xmlConfirmaConf .= "	   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlConfirmaConf .= "   </Dados>";
	$xmlConfirmaConf .= "</Root>";
  
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlConfirmaConf, "CONFRP", "CONFIRMA_CONF", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjConfirmaConf = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
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
  
  // Incrementar o LOG com o já existente
  $deslogconfrp       = $dslogcfg.$xmlObjConfirmaConf->roottag->tags[2]->cdata;
    
  $str_populadados  = '$(\'#'.$cp_idparame_reciproci.'\').val(\''.$idparame_reciproci.'\');';
  $str_populadados .= '$(\'#'.$cp_desmensagem.'\').val(\''.$desmensagem.'\');';
  $str_populadados .= '$(\'#'.$cp_deslogconfrp.'\').val(\''.$deslogconfrp.'\');';
  $str_populadados .= 'fechaRotina($(\'#divUsoGenerico\'));';
  $str_populadados .= $executafuncao;
  if ($divanterior != "")
    $str_populadados .= 'bloqueiaFundo($(\'#'.$divanterior.'\'));';
  
  echo $str_populadados;
  //exibirErro('inform','Configura&ccedil;&atilde;o efetuada com sucesso.','Alerta - Ayllos',$str_populadados,false);
  
?>