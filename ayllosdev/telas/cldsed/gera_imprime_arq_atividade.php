<? 
/*!
 * FONTE        : gera_imprime_Arq_atividade.php
 * CRIAÇÃO      : Cristian Filipe Fernandes (GATI)
 * DATA CRIAÇÃO : 16/09/2013 
 * OBJETIVO     : Rotina para impressao da atividade - opção T
 */

	session_cache_limiter("private");
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
	// Guardo os parâmetos do POST em variáveis	
	$dtrefini  = $_POST["dtrefini"];
	$dtreffim  = $_POST["dtreffim"];
	$saida     = $_POST['saida'];
	$nmarquivo = $_POST['nmarquivo'];
	$opcao     = $_POST['opcao'];
	$excel     = $_POST['excel'];
	$dsiduser  = session_id();	
	
	if( !isset($_POST["dtrefini"]) || !validaData($dtrefini)){
		exibeErro("Data de inicio invalida.");
	}

	if( !isset($_POST["dtreffim"]) || !validaData($dtreffim)){
		exibeErro("Data final invalida.");
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
	$xmlSetPesquisa .= "    <Proc>Gera_imprime_arq_atividade</Proc>";
	$xmlSetPesquisa .= "  </Cabecalho>";
	$xmlSetPesquisa .= "  <Dados>";
	$xmlSetPesquisa .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xmlSetPesquisa .= "    <cdagenci>".$glbvars['cdagenci']."</cdagenci>";
	$xmlSetPesquisa .= "    <nrdcaixa>".$glbvars['nrdcaixa']."</nrdcaixa>";
	$xmlSetPesquisa .= "    <cdoperad>".$glbvars['cdoperad']."</cdoperad>";
	$xmlSetPesquisa .= "    <idorigem>".$glbvars['idorigem']."</idorigem>";
	$xmlSetPesquisa .= "    <nmdatela>".$glbvars['nmdatela']."</nmdatela>";
	$xmlSetPesquisa .= "    <cdprogra>".$glbvars['cdprogra']."</cdprogra>";
	$xmlSetPesquisa .= "    <dtrefini>".$dtrefini."</dtrefini>";
	$xmlSetPesquisa .= "    <dtreffim>".$dtreffim."</dtreffim>";
	$xmlSetPesquisa .= "    <tpdsaida>".$saida."</tpdsaida>";
	$xmlSetPesquisa .= "    <dsiduser>".$dsiduser."</dsiduser>";
	if($saida == "A"){
		$xmlSetPesquisa .= "    <nmarquiv>".$nmarquivo."</nmarquiv>";	
		$xmlSetPesquisa .= "    <gerexcel>".$excel."</gerexcel>";	
	}
	$xmlSetPesquisa .= "  </Dados>";
	$xmlSetPesquisa .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetPesquisa);
	$xmlObj = getObjectXML($xmlResult);
	
	if(strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibeErro($msg);
	}
	
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