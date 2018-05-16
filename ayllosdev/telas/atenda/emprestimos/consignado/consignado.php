<?php 
/***************************************************************************************
 * FONTE        : consignado.php				Última alteração: --/--/----
 * CRIAÇÃO      : Leonardo - GFT
 * DATA CRIAÇÃO : 13/03/2018
 * OBJETIVO     : Acionar operação consignado
 *
 * Alterações   : 
 *
 *
 **************************************************************************************/

	session_start();
		
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../class/xmlfile.php');
	require_once('../../../../includes/rest/restRequest.php');
	
	isPostMethod();		
	  
	// cdacesso para buscar parametro com o valor da uri 
	$cdacesso_uri = "URI_BARRAMENTO_CALC";

    $xml  = "";
	$xml .= "<Root>";
	$xml .= "   <Dados>";
	$xml .= "	   <cdacesso>".$cdacesso_uri."</cdacesso>";
	$xml .= "   </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML	
	$xmlResult = mensageria(
		$xml, 
		"BARRAMENTO", 
		"BUSCAR_PARAMS", 
		$glbvars["cdcooper"], 
		$glbvars["cdagenci"], 
		$glbvars["nrdcaixa"], 
		$glbvars["idorigem"], 
		$glbvars["cdoperad"], 
		"</Root>");
	
	$xmlObj = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		if ($msgErro == "") {
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
		}

		exibirErro(
			"error",
			htmlentities($msgErro),
			"Alerta - Ayllos",
			"controlaOperacao(''); return false;",
			false);
		exit;

	}
	
	$host = getByTagName($xmlObj->roottag->tags[0]->tags, "host");
	$uri = 	getByTagName($xmlObj->roottag->tags[0]->tags, "uri");

	//Executar chamada ao barramento
	$restRequest = new RestRequest($host);
  	$restRequest->setParams(array(
  							"val1"=>15,
  							"val2"=>7,
  							"operation"=>"+"
  						));
	$errorDesc = null;

	//Tratamento de resposta do barramento
  	if($restRequest->post($uri)){
  		
  		switch($restRequest->getStatus()){
  			case 400:
  			    $errorDesc = utf8ToHtml('Requisição inválida');
  				break;
  			case 500:
  				$errorDesc = utf8ToHtml('Erro interno do servidor');
  				break;
  			case 200:
  		  		$objResponse = $restRequest->getArrayResponse();

  		  		$result = $objResponse->result;
  		  		$desc = $objResponse->desc;

  		  		echo "showError(
						\"inform\",
						\"Opera&ccedil;&atilde;o efetuada com sucesso! ".$desc." \",
						\"Alerta - Ayllos\",
						\"controlaOperacao(''); return false;\");";
				exit;
  		  		break;
  		  	default:
     			$errorDesc = utf8ToHtml('Erro não tratado do servidor');
  				break;
  		}
  	} else {
  		$errorDesc = utf8ToHtml('Não foi possivel realizar a requisição.');
  	}
  	exibirErro(
			"error",
			$errorDesc,
			"Alerta - Ayllos",
			"controlaOperacao(''); return false;",
			false);
		exit;
	
?>