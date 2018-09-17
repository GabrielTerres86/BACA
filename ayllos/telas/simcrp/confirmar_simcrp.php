<? 
/***************************************************************************************
 * FONTE        : confirmar_simcrp.php				Última alteração: --/--/----
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
	$ls_vlcontrata            = (isset($_POST['ls_vlcontrata'])) ?            $_POST['ls_vlcontrata'] : '';
	$idparame_reciproci       = (isset($_POST['idparame_reciproci'])) ?       $_POST['idparame_reciproci'] : '';
	$idcalculo_reciproci      = (isset($_POST['idcalculo_reciproci'])) ?      $_POST['idcalculo_reciproci'] : '';
	$qtdmes_retorno_reciproci = (isset($_POST['qtdmes_retorno_reciproci'])) ? $_POST['qtdmes_retorno_reciproci'] : '';
	$flgreversao_tarifa       = (isset($_POST['flgreversao_tarifa'])) ?       $_POST['flgreversao_tarifa'] : '';
	$flgdebito_reversao       = (isset($_POST['flgdebito_reversao'])) ?       $_POST['flgdebito_reversao'] : '';
	$modo                     = (isset($_POST['modo'])) ?                     $_POST['modo'] : '';
	$totaldesconto            = (isset($_POST['totaldesconto'])) ?            $_POST['totaldesconto'] : '';
    $cp_idcalculo             = (isset($_POST['cp_idcalculo'])) ?             $_POST['cp_idcalculo'] : '';
    $cp_desmensagem           = (isset($_POST['cp_desmensagem'])) ?           $_POST['cp_desmensagem'] : '';
    $cp_totaldesconto         = (isset($_POST['cp_totaldesconto'])) ?         $_POST['cp_totaldesconto'] : '';
    $executafuncao            = (isset($_POST['executafuncao'])) ?            $_POST['executafuncao'] : '';
    $divanterior              = (isset($_POST['divanterior'])) ?              $_POST['divanterior'] : '';
    
    $xmlConfirmaConf  = "";
	$xmlConfirmaConf .= "<Root>";
	$xmlConfirmaConf .= "   <Dados>";
	$xmlConfirmaConf .= "	   <ls_vlcontrata>".$ls_vlcontrata."</ls_vlcontrata>";
	$xmlConfirmaConf .= "	   <idparame_reciproci>".$idparame_reciproci."</idparame_reciproci>";
	$xmlConfirmaConf .= "	   <idcalculo_reciproci>".$idcalculo_reciproci."</idcalculo_reciproci>";
	$xmlConfirmaConf .= "	   <qtdmes_retorno_reciproci>".$qtdmes_retorno_reciproci."</qtdmes_retorno_reciproci>";
	$xmlConfirmaConf .= "	   <flgreversao_tarifa>".$flgreversao_tarifa."</flgreversao_tarifa>";
	$xmlConfirmaConf .= "	   <flgdebito_reversao>".$flgdebito_reversao."</flgdebito_reversao>";
	$xmlConfirmaConf .= "	   <modo>".$modo."</modo>";
	$xmlConfirmaConf .= "   </Dados>";
	$xmlConfirmaConf .= "</Root>";
  
	// Executa script para envio do XML	
	$xmlResult = mensageria($xmlConfirmaConf, "SIMCRP", "CONF_SIMC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjConfirmaConf = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjConfirmaConf->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjConfirmaConf->roottag->tags[0]->tags[0]->tags[4]->cdata;
				 
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);		
							
	} 
  
  $idcalculo_reciproci = $xmlObjConfirmaConf->roottag->tags[0]->cdata;
  $desmensagem         = $xmlObjConfirmaConf->roottag->tags[1]->cdata;
  
  $str_populadados  = '$(\'#'.$cp_idcalculo.'\').val(\''.$idcalculo_reciproci.'\');';
  $str_populadados .= '$(\'#'.$cp_desmensagem.'\').val(\''.$desmensagem.'\');';
  $str_populadados .= '$(\'#'.$cp_totaldesconto.'\').val(\''.$totaldesconto.'\');';
  $str_populadados .= 'fechaRotina($(\'#divUsoGenerico\'));';
  $str_populadados .= $executafuncao;
  $str_populadados .= 'bloqueiaFundo($(\'#'.$divanterior.'\'));';

  echo $str_populadados;
  //exibirErro('inform','Configura&ccedil;&atilde;o efetuada com sucesso.','Alerta - Ayllos',$str_populadados,false);
  
?>