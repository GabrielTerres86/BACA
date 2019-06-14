<?php
	/*!
    * FONTE        : busca_conta_contabil.php
	* CRIAÇÃO      : Alcemir Junior - Mout's
	* DATA CRIAÇÃO : 10/10/2018
	* OBJETIVO     : buscar conta contabil usadas no risco operacional tela SLIP
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
	$cdrisco_operacional   = (isset($_POST["cdrisco_operacional"]))    ? $_POST["cdrisco_operacional"]    : ""; // conta contabil a ser validada

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "   <cdrisco_operacional>".$cdrisco_operacional."</cdrisco_operacional>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";


	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "SLIP", "BUSCA_CONTA_CONTABIL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"]                   
                        , $glbvars["cdoperad"],  "</Root>");


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
		
		$command .= "limpaTabelaCtaContabil();";
	    $flgconsulta = False;	    
		foreach($xmlObjeto->lsconta as $lsconta){
        
			$flgconsulta = True;
			$command .=  "criarLinhaCtaContabil('".$lsconta->nrconta_contabil."');";			
		}

     	if (!$flgconsulta){
     		$command .=  "criarLinhaCtaContabil('');";
		}
		
		
		
	}

	echo "hideMsgAguardo();".$command."formatarTabelaCtaContabil();";		
	
?>

