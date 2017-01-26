<?php
/*!
 * FONTE        : consulta_municipios.php                    Última alteração: 
 * CRIAÇÃO      : Andrei (RKAM)
 * DATA CRIAÇÃO : Agosto/2016 
 * OBJETIVO     : Rotina para buscar municipios
 * --------------
 * ALTERAÇÕES   :  
 */
?>

<?php	
 
  session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
	
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
  
  $nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 0;
  $nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 0;
   
  // Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= "  <Dados>";
	$xml 	   .= "     <cddopcao>".$cddopcao."</cddopcao>";
  $xml 	   .= "     <nrregist>".$nrregist."</nrregist>";
  $xml 	   .= "     <nriniseq>".$nriniseq."</nriniseq>";
  $xml 	   .= "  </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_CADCOP", "CONSULTAMUN", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);		
		
	} 
		
  $registros =  $xmlObj->roottag->tags[0]->tags;
	$qtregist  =  $xmlObj->roottag->attributes["QTREGIST"];
 
  include('tab_municipios.php');	
	
	  
 ?>
