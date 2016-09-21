<?php
	/*!
	 * FONTE        : gera_rating.php
	 * CRIAÇÃO      : Andrei - RKAM
	 * DATA CRIAÇÃO : Maio/2016
	 * OBJETIVO     : Rotina para gerar rating e apresentar-lo no relatório
	 * --------------
	 * ALTERAÇÕES   : 
	 * -------------- 
	 */		

  session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			
	
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$nrdconta = isset($_POST["nrdconta"]) ? $_POST["nrdconta"] : 0;
  $nrctrrat = isset($_POST["nrctrrat"]) ? $_POST["nrctrrat"] : 0;
  $tpctrrat = isset($_POST["tpctrrat"]) ? $_POST["tpctrrat"] : 0;

	validaDados();
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
  $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";	
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
  $xml .= "   <nrctrrat>".$nrctrrat."</nrctrrat>";	
  $xml .= "   <tpctrrat>".$tpctrrat."</tpctrrat>";	
  $xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_ATURAT", "GERARATING", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "nrdconta";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesRatings\').focus();',false);		
		
	} 
	
	$nmarqpdf = $xmlObj->roottag->tags[0]->tags[0]->cdata;	

	echo 'Gera_Impressao("'.$nmarqpdf.'","$(\'#btVoltar\',\'#divBotoesRatings\').focus();");';			
		
		
	function validaDados(){
			
		IF($GLOBALS["nrdconta"] == '' ){ 
			exibirErro('error','Conta inv&aacute;lida.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesRatings\').focus();',false);
		}
    
    IF($GLOBALS["nrctrrat"] == '' ){ 
			exibirErro('error','N&uacute;mero do contrato inv&aacute;lido.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesRatings\').focus();',false);
		}
    
    IF($GLOBALS["tpctrrat"] == '' ){ 
			exibirErro('error','Tipo do contrato inv&aacute;lido.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesRatings\').focus();',false);
		}
				
	}	
		
?>