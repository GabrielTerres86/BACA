<?php
	/*!
	 * FONTE        : grava_ratings.php
	 * CRIAÇÃO      : Jonathan - RKAM
	 * DATA CRIAÇÃO : 08/02/2016
	 * OBJETIVO     : Rotina para gravar os ratings 
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
	$rating = isset($_POST["rating"]) ? $_POST["rating"] : '';	
		
	validaDados();	
	
	$vlrating = '';

	foreach($rating as $dados){

		$valores = '';

		foreach($dados as $valor){

			if($valores == ''){

				$valores = $valor;
				
			}else{
				
				$valores = $valores.'|'.$valor;
				
			}
		
		}

		if($vlrating == ''){

			$vlrating = $valores;

		}else{

			$vlrating = $vlrating.'#'.$valores;

		}

	}

	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <vlrating>".$vlrating."</vlrating>";			
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "RATING", "GRAVARRATING", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
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
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesRating\').focus();',false);		
		
	} else if(strtoupper($xmlObj->roottag->tags[0]->name == 'MENSAGEM')){
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "nrdconta";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);	
	
	}else{
		
		exibirErro('inform','Operação efetuada com sucesso!','Alerta - Ayllos','estadoInicial();',false);		
			
	}
	
	function validaDados(){
			
		IF($GLOBALS["nrdconta"] == '' ){ 
			exibirErro('error','Conta in&acute;lida.','Alerta - Ayllos','$(\'#btVoltar\',\'#divBotoesRating\').focus();',false);
		}
				
	}	
		
?>
