<?php
/*!
 * FONTE        : consulta_linha_credito.php                    Última alteração: 27/03/2017
 * CRIAÇÃO      : Andrei (RKAM)
 * DATA CRIAÇÃO : Julho/2016 
 * OBJETIVO     : Rotina para buscar informações da linha de crédito
 * --------------
 * ALTERAÇÕES   : 27/03/2017 - Listagem dos indexadores. (Jaison/James - PRJ298)
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
  
  $cdlcremp = (isset($_POST["cdlcremp"])) ? $_POST["cdlcremp"] : 0;
  $nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 0;
  $nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 0;

  validaDados();
  
  // Monta o xml de requisição		
	$xml  		= "";
	$xml 	   .= "<Root>";
	$xml 	   .= "  <Dados>";
	$xml 	   .= "     <cdlcremp>".$cdlcremp."</cdlcremp>";
	$xml 	   .= "     <cddopcao>".$cddopcao."</cddopcao>";
  $xml 	   .= "     <nrregist>".$nrregist."</nrregist>";
  $xml 	   .= "     <nriniseq>".$nriniseq."</nriniseq>";
	$xml 	   .= "  </Dados>";
	$xml 	   .= "</Root>";
	
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_LCREDI", "CONSLINHA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "cdlcremp";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
    
		exibirErro('error',$msgErro,'Alerta - Ayllos','formataFiltro(); focaCampoErro(\''.$nmdcampo.'\',\'frmFiltro\');',false);		
		
	} 
		
	$linha     = $xmlObj->roottag->tags[0]->tags[0];
  $registros = $xmlObj->roottag->tags[0]->tags[1]->tags;
  
  $qtregist  = $xmlObj->roottag->attributes["QTREGIST"];

  $xmlResult = mensageria($xml, "TELA_PRMPOS", "PRMPOS_BUSCA_INDEX", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
  $xmlObject = getObjectXML($xmlResult);

  if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
      $msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
      exibirErro('error',$msgErro,'Alerta - Ayllos','formataFiltro()',false);
  }

  $xmlIndexa = $xmlObject->roottag->tags[0]->tags;

  include('form_consulta.php');	
	
	
	function validaDados(){
			
		IF($GLOBALS["cdlcremp"] == 0 ){ 
			exibirErro('error','Linha de cr&eacute;dito inv&aacute;lida.','Alerta - Ayllos','formataFiltro(); focaCampoErro(\'cdlcremp\',\'frmFiltro\');',false);
		}
   
				
	}	
  
 ?>
