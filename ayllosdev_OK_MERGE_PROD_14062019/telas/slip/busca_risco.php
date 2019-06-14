<?php
	/*!
    * FONTE        : busca_risco.php
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
	

	$nrseqlan   = (isset($_POST["nrseqlan"]))    ? $_POST["nrseqlan"]    : ""; // 
    $tipbusca   = (isset($_POST["tipbusca"]))    ? $_POST["tipbusca"]    : ""; // 
	
	$nmdacao = "BUSCA_RISCO_OPE";//padrão
	// Monta o xml
	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	if ($tipbusca == "L"){
		$xml .= "  <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xml .= "  <nrseqlan>".$nrseqlan."</nrseqlan>";
		$nmdacao = "BUSCA_RISCO_OPE_LANC"; 
	}			
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml,"SLIP", $nmdacao , $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], 
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

		if ($tipbusca == "L"){
			$command .= "limpaTabelaRiscoRat();";	
			$flgconsulta = False;	    
			foreach($xmlObjeto->riscos as $riscos){

				$flgconsulta = True;
				$command .=  "criarLinhaRiscoRat('".$riscos->cdrisco_operacional."');";
			}

			if (!$flgconsulta){
				$command .=  "criarLinhaRiscoRat('');";
			}
			
			$command .= "formatarTabelaRiscoRat();";
		}else{
				
			$command .= "limpaTabelaRisco();";	
			$flgconsulta = False;	    
			foreach($xmlObjeto->riscos as $riscos){

				$flgconsulta = True;
				$command .=  "criarLinhaRisco('".$riscos->cdrisco_operacional. 
										"','" .$riscos->dsrisco_operacional."');";
			}

			if (!$flgconsulta){
				$command .=  "criarLinhaRisco('','');";
			}
			
			$command .= "formatarTabelaRisco();";
			
		}

		echo "hideMsgAguardo();".$command;		
	}

	
?>

