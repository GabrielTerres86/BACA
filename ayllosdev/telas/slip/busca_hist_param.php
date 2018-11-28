<?php
	/*!
    * FONTE        : busca_hist_param.php
	* CRIAÇÃO      : Alcemir Junior - Mout's
	* DATA CRIAÇÃO : 10/10/2018
	* OBJETIVO     : validar se já existe conta contabil tela SLIP
	* --------------
	* ALTERAÇÕES   :
	* --------------
	*/

	session_cache_limiter("private");
	session_start();

	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
	isPostMethod();

	// Ler parametros passados via POST	
	$cdhistor   = (isset($_POST["cdhistor"]))    ? $_POST["cdhistor"]    : ""; // conta contabil a ser validada

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "   <cdhistor>".$cdhistor."</cdhistor>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";


	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "SLIP", "BUSCA_HIST_PARAM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"]                    , $glbvars["cdoperad"],  "</Root>");


	//Cria objeto para classe de tratamento de XML
	//$xmlObjeto = getObjectXML($xmlResult);
	$xmlObjeto = simplexml_load_string($xmlResult);	
	$dscritic = $xmlObjeto->Erro->Registro->dscritic;
    $command = "";
    

	// Se ocorrer um erro, mostra crítica
 	if ($dscritic != "") {
		echo "showError('alert','".$dscritic."','Alerta - Aimaro','estadoInicial();')";
		//$msgErro = $xmlObjeto->Erro->Registro->dscritic;
		//exibirErro("error",utf8ToHtml($msgErro),"Alerta - Aimaro","",false);
	}else{
		
		
	    $flgconsulta = False;	    
		foreach($xmlObjeto->hist_param as $hist_param){

			$flgconsulta = True;
			$command .=  "setParaHist('".$hist_param->nrctadeb. 									  
			                          "','" .$hist_param->nrctacrd.
			                          "','" .$hist_param->cdhistor.
			                          "','" .$hist_param->idris.
									  "','" .$hist_param->idger."');";			
		}

     	if (!$flgconsulta){
     		$command .=  "setParaHist('','','','','');concluirBuscaHistorico('".$cdhistor."');";
		}
		
		
		
	}

	echo "hideMsgAguardo();".$command."controlaFoco();";		
	
?>

