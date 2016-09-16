<? 
/*!
 * FONTE        : gera_imprime_Arq_pesquisa.php
 * CRIAÇÃO      : Cristian Filipe Fernandes (GATI)
 * DATA CRIAÇÃO : 16/09/2013
 * OBJETIVO     : Rotina para impressao da pesquisa - opção P
 */

	session_cache_limiter("private");
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	// Guardo os parâmetos do POST em variáveis
	$nrdconta  = $_POST["nrdconta"];
	$cdincoaf  = $_POST["cdincoaf"];
	$cdstatus  = $_POST["cdstatus"];
	$dtrefini  = $_POST["dtrefini"];
	$dtreffim  = $_POST["dtreffim"];
	$saida     = $_POST['saida'];
	$nmarquivo = $_POST['nmarquivo'];
	$opcao     = $_POST['opcao'];
	$dsiduser = session_id();
	
	if( !isset($_POST["nrdconta"]) || !validaInteiro($nrdconta)){
		exibeErro("Numero da conta invalida.");
	}

	if( !isset($_POST["cdincoaf"]) || !validaInteiro($cdincoaf)){
		exibeErro("COAF invalida.");
	}

	if( !isset($_POST["dtrefini"]) || !validaData($dtrefini)){
		exibeErro("Data de inicio invalida.");
	}

	if( !isset($_POST["dtreffim"]) || !validaData($dtreffim)){
		exibeErro("Data final invalida.");
	}

	if( !isset($_POST['cdstatus']) || !validaInteiro($cdstatus)){
		exibeErro("Status invalido.");
	}

	if( !isset($_POST['nmarquivo']) || $nmarquivo == ""){
		exibeErro("Nome do arquivo invalido.");
	}

	if( !isset($_POST['saida']) || $saida == ""){
		exibeErro("Saida invalido.");
	}

	
	
	// Monta o xml de requisição
	$xmlSetPesquisa  = "";
	$xmlSetPesquisa .= "<Root>";
	$xmlSetPesquisa .= "  <Cabecalho>";
	$xmlSetPesquisa .= "    <Bo>b1wgen0173.p</Bo>";
	$xmlSetPesquisa .= "    <Proc>Gera_imprime_arq_pesquisa</Proc>";
	$xmlSetPesquisa .= "  </Cabecalho>";
	$xmlSetPesquisa .= "  <Dados>";
	$xmlSetPesquisa .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xmlSetPesquisa .= "    <cdagenci>".$glbvars['cdagenci']."</cdagenci>";
	$xmlSetPesquisa .= "    <nrdcaixa>".$glbvars['nrdcaixa']."</nrdcaixa>";
	$xmlSetPesquisa .= "    <cdoperad>".$glbvars['cdoperad']."</cdoperad>";
	$xmlSetPesquisa .= "    <idorigem>".$glbvars['idorigem']."</idorigem>";
	$xmlSetPesquisa .= "    <nmdatela>".$glbvars['nmdatela']."</nmdatela>";
	$xmlSetPesquisa .= "    <cdprogra>".$glbvars['cdprogra']."</cdprogra>";
	$xmlSetPesquisa .= "    <cdincoaf>".$cdincoaf."</cdincoaf>";
	$xmlSetPesquisa .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetPesquisa .= "    <cdstatus>".$cdstatus."</cdstatus>";
	$xmlSetPesquisa .= "    <dtrefini>".$dtrefini."</dtrefini>";
	$xmlSetPesquisa .= "    <dtreffim>".$dtreffim."</dtreffim>";
	$xmlSetPesquisa .= "    <tpdsaida>".$saida."</tpdsaida>";
	$xmlSetPesquisa .= "    <dsiduser>".$dsiduser."</dsiduser>";
	if($saida == 'A'){
		$xmlSetPesquisa .= "     <nmarquiv>".$nmarquivo."</nmarquiv>";	
	}
	$xmlSetPesquisa .= "  </Dados>";
	$xmlSetPesquisa .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetPesquisa);
	$xmlObj = getObjectXML($xmlResult);
	
	if($saida == "I"){
		// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
		$nmarqpdf = $xmlObj->roottag->tags[0]->attributes["NMARQPDF"];
		visualizaPDF($nmarqpdf);
	}

	function exibeErro($msgErro) {
		echo '<script>alert("'.$msgErro.'");</script>';
		exit();
	}
?>