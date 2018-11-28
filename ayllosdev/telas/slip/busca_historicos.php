<?php
	/*!
    * FONTE        : busca_historicos.php
	* CRIAÇÃO      : Alcemir Junior - Mout's
	* DATA CRIAÇÃO : 10/10/2018
	* OBJETIVO     :  tela SLIP
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
	
	// Monta o xml
	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";	
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml,"SLIP", "BUSCA_HISTORICOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], 
		                    $glbvars["cdoperad"],  "</Root>");

	

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
		
		$command .= "limpaTabelaHistoricos();";	
	    $flgconsulta = False;	    
		foreach($xmlObjeto->historicos as $historicos){

			$flgconsulta = True;
			$command .=  "criarLinhaHistorico('".$historicos->cdhistor. 
				                            "','".$historicos->nrctadeb.
			                                "','".$historicos->nrctacrd."');";
		}

     	if (!$flgconsulta){
     		$command .=  "criarLinhaHistorico('','');";
		}
		
		$command .= "formatarTabelaHistorico();";

		echo "hideMsgAguardo();".$command;		
	}

	
?>

