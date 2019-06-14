<?php
/*!
 * FONTE        : consulta_conta.php                    Última alteração: 
 * CRIAÇÃO      : Tiago 
 * DATA CRIAÇÃO : Setembro/2017
 * OBJETIVO     : Rotina para buscar informações da conta
 * --------------
 * ALTERAÇÕES   :  
 */
?>

<?php	
	if( !ini_get('safe_mode') ){
		set_time_limit(300);
	}
	session_cache_limiter("private");
  session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		
	
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : '';
	$frmParametro = (isset($_POST["frmparametro"])) ? $_POST["frmparametro"] : '';
  
   
  // Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= "  <Dados>";
	$xml 	   .= "     <nrdconta>".$nrdconta."</nrdconta>";
    $xml 	   .= "  </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "PGTA0001", "CONSULTARCONTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);		
		
	} 
		
	$nmprimtl = $xmlObj->roottag->tags[0]->tags[0]->tags[1]->cdata;		  	
	$nrcpfcgc = $xmlObj->roottag->tags[0]->tags[0]->tags[2]->cdata;		  	
	$inpessoa = $xmlObj->roottag->tags[0]->tags[0]->tags[3]->cdata;		  	
	$cdagectl = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;		  	
	$flghomol = $xmlObj->roottag->tags[0]->tags[0]->tags[5]->cdata;		  	
	

	//exibirErro('error',$nmprimtl,'Alerta - Ayllos','estadoInicial();',false);		
    echo '$("#nmprimtl", "#'.$frmParametro.'").val("'.$nmprimtl.'");';
	echo '$("#nrcpfcgc", "#'.$frmParametro.'").val("'.$nrcpfcgc.'");';
	echo '$("#inpessoa", "#'.$frmParametro.'").val("'.$inpessoa.'");';
	echo '$("#cdagectl", "#'.$frmParametro.'").val("'.$cdagectl.'");';
	echo '$("#flghomol", "#'.$frmParametro.'").val("'.$flghomol.'");';
	echo '$("#nrdconta", "#'.$frmParametro.'").desabilitaCampo();';
	
	if($frmParametro == "frmConsulta" || $frmParametro == "frmRelatorio"){
		echo '$("#nmarquiv", "#'.$frmParametro.'").focus();';	
	}
	
	if($frmParametro == "frmConsultaLog"){
		echo '$("#dtiniper", "#'.$frmParametro.'").focus();';	
	}
	
	if($frmParametro == "frmArquivo"){
		echo '$("#userfile", "#'.$frmParametro.'").focus();';	
	}
	
	
	
	
 ?>
 
 
 
 
