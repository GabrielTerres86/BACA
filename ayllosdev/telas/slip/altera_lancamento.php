<?php
	/*!
    * FONTE        : altera_lancamento.php
	* CRIAÇÃO      : Alcemir Junior - Mout's
	* DATA CRIAÇÃO : 10/10/2018
	* OBJETIVO     : Inserir lancamento tela SLIP
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
	$cdhistor   = (isset($_POST["cdhistor"]))    ? $_POST["cdhistor"]    : ""; // 
	$nrctadeb   = (isset($_POST["nrctadeb"]))    ? $_POST["nrctadeb"]    : ""; // 
	$nrctacrd   = (isset($_POST["nrctacrd"]))    ? $_POST["nrctacrd"]    : ""; // 
	$vllanmto   = (isset($_POST["vllanmto"]))    ? $_POST["vllanmto"]    : ""; // 
	$dslancamento   = (isset($_POST["dslancamento"]))    ? $_POST["dslancamento"]    : ""; // 
	$vltotrat = (isset($_POST["vltotrat"]))    ? $_POST["vltotrat"]    : ""; // valor total do rateio
	$cdhistor_padrao = (isset($_POST["cdhistor_padrao"]))    ? $_POST["cdhistor_padrao"]    : ""; 
    $nrseqlan = (isset($_POST["nrseqlan"]))    ? $_POST["nrseqlan"]    : ""; 
	//LISTA COM GERENCIAIS
	$lscdgerencial   = (isset($_POST["lscdgerencial"]))    ? $_POST["lscdgerencial"]    : ""; //
	$lsvllanmto   = (isset($_POST["lsvllanmto"]))    ? $_POST["lsvllanmto"]    : ""; //
	
	//LISTA COM RISCOS OPERACIONAIS
	$lscdrisco_operacional   = (isset($_POST["lscdrisco_operacional"]))    ? $_POST["lscdrisco_operacional"]    : ""; //

	$vllanmto  = str_replace('.', '', $vllanmto);

	$vllanmto = abs(str_replace(",",".",$vllanmto));

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
    $xml .= "   <nrseqlan>".$nrseqlan."</nrseqlan>";
	$xml .= "   <cdhistor>".$cdhistor."</cdhistor>";
	$xml .= "   <nrctadeb>".$nrctadeb."</nrctadeb>";
	$xml .= "   <nrctacrd>".$nrctacrd."</nrctacrd>";
	$xml .= "   <vllanmto>".$vllanmto."</vllanmto>";	
	$xml .= "   <cdhistor_padrao>".$cdhistor_padrao."</cdhistor_padrao>";
	$xml .= "   <dslancamento>".$dslancamento."</dslancamento>";
	$xml .= "   <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";	
	$xml .= "   <lscdgerencial>".$lscdgerencial."</lscdgerencial>";
	$xml .= "   <lsvllanmto>".$lsvllanmto."</lsvllanmto>";
	$xml .= "   <lscdrisco_operacional>".$lscdrisco_operacional."</lscdrisco_operacional>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "SLIP", "ALTERA_LANCAMENTO", 
							$glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], 
							$glbvars["idorigem"] , $glbvars["cdoperad"], "</Root>");

	//Cria objeto para classe de tratamento de XML
	//$xmlObjeto = getObjectXML($xmlResult);
	$xmlObjeto = simplexml_load_string($xmlResult);
	$dscritic = $xmlObjeto->Erro->Registro->dscritic;

	// Se ocorrer um erro, mostra crítica
 	if ($dscritic != "") {			 			
		//showError('error',,'Alerta - Aimaro','');
		exibirErro('error',utf8ToHtml($dscritic),'Alerta - Aimaro','',false);
	}else{		
		echo "hideMsgAguardo();concluirLancamentoAlteracao();";
	}

	
?>

