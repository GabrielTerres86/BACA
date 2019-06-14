<?php
	/*!
    * FONTE        : busca_gerenciais.php
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
	$cdcooper   = (isset($_POST["cdcooper"]))    ? $_POST["cdcooper"]    : ""; // cooperativa
	$nrseqlan = (isset($_POST["nrseqlan"]))    ? $_POST["nrseqlan"]    : ""; // esqueancia lancmaento slip
    $tipbusca = (isset($_POST["tipbusca"]))    ? $_POST["tipbusca"]    : ""; // tipo da busca, se for L, carregar na tabela de alteracao/inclusao lanc.

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	if ($tipbusca == "L"){
		$xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
		$xml .= "   <nrseqlan>".$nrseqlan."</nrseqlan>";
		$nmdacao = "BUSCA_GERENCIAIS_LANC";		
	}else{
		$xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
		$nmdacao = "BUSCA_GERENCIAIS";		
	}
	
	$xml .= "  </Dados>";
	$xml .= "</Root>";


	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "SLIP", $nmdacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"]                    , $glbvars["cdoperad"],  "</Root>");


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
			
			$command .= "limpaTabelaGerencialRat();";	
			$flgconsulta = False;	    
			foreach($xmlObjeto->gerenciais as $gerenciais){

				$flgconsulta = True;
				$command .=  "criarLinhaGerencialRat('".$gerenciais->cdgerencial. 
													   "','" .$gerenciais->vllanmto."');";
			}

			if (!$flgconsulta){
				$command .=  "criarLinhaGerencialRat('','');";
			}
			
			$command .= "formatarTabelaGerencialRat();";

		}else{			
			$command .= "limpaTabelaGerencial();";	
			$flgconsulta = False;	    
			foreach($xmlObjeto->gerenciais as $gerenciais){

				$flgconsulta = True;
				$command .=  "criarLinhaBuscaGerencial('".$gerenciais->cdgerencial. 
													"','" .$gerenciais->idativo."');";
			}

			if (!$flgconsulta){
				$command .=  "criarLinhaBuscaGerencial('','');";
			}
			
			$command .= "formatarTabelaGerencial();mostrarTabelaGerencial();";
		}
	}

	echo "hideMsgAguardo();".$command;		
	
?>

