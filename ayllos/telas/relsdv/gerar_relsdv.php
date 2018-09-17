<?php
	/*!
	 * FONTE          : gerar_relsdv.php
	 * CRIAÇÃO      : Jean Calão (Mout´S)
	 * DATA CRIAÇÃO : 24/02/2017
	 * OBJETIVO     : Rotina para gerar o relatório de saldo devedor de empréstimo
	 * --------------
	 * ALTERAÇÕES   : 
    * -------------- 
	 */		

	session_start();

	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	require_once("../../class/xmlfile.php");
	isPostMethod();

	// Ler parametros passados via POST
	$nmdarqui      = (isset($_POST["nmdarqui"]))     ? $_POST["nmdarqui"]      : ""; // Nome do arquivo para importar
	$nmdarsai      = (isset($_POST["nmdarsai"]))     ? $_POST["nmdarsai"]      : "";  // Nome do arquivo para gerar
     
	// Identificar as operações/
	$procedure = "RELSDV_GERA_RELAT";
	
	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "		<nmdarqui>".$nmdarqui."</nmdarqui>";
	$xml .= "		<nmdarsai>".$nmdarsai."</nmdarsai>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "RELSDV", $procedure, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
 	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		//exibirErro("error",$msgErro,"Alerta - Ayllos","",false);
    exibirErro("error","Arquivo gerado, verifique LOG!","Alerta - Ayllos","",false);
	}
		
?>