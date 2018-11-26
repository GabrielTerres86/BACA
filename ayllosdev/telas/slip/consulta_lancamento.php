<?
	/*!
    * FONTE        : consulta_lancamentos.php
	* CRIAÇÃO      : Alcemir Junior - Mout's
	* DATA CRIAÇÃO : 10/10/2018
	* OBJETIVO     : consultar lancamento tela SLIP
	* --------------
	* ALTERAÇÕES   :
	* --------------
	*/
	
?>

<?
    session_cache_limiter("private");
    session_start();

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');

    // Verifica se tela foi chamada pelo método POST
	isPostMethod();

    // Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");

	$nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 30;
	$nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;

    $dtmvtolt = (isset($_POST["dtmvtolt"])) ? $_POST["dtmvtolt"] : "";
    $cdhistor = (isset($_POST["cdhistor"])) ? $_POST["cdhistor"] : "";
    $nrctadeb = (isset($_POST["nrctadeb"])) ? $_POST["nrctadeb"] : "";
    $nrctacrd = (isset($_POST["nrctacrd"])) ? $_POST["nrctacrd"] : "";
    $vllanmto = (isset($_POST["vllanmto"])) ? $_POST["vllanmto"] : 0;
    $cdhistor_padrao = (isset($_POST["cdhistor_padrao"])) ? $_POST["cdhistor_padrao"] : "";
    $dslancamento = (isset($_POST["dslancamento"])) ? $_POST["dslancamento"] : "";
    $cdoperad = (isset($_POST["cdoperad"])) ? $_POST["cdoperad"] : "";
    $opevlrlan = (isset($_POST["opevlrlan"])) ? $_POST["opevlrlan"] : "=";
    
	
	$vllanmto  = str_replace('.', '', $vllanmto);

	$vllanmto = abs(str_replace(",",".",$vllanmto));
	

	
	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";	
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
    $xml .= "   <dtmvtolt>".$dtmvtolt."</dtmvtolt>";	    
    $xml .= "   <cdhistor>".$cdhistor."</cdhistor>";
    $xml .= "   <nrctadeb>".$nrctadeb."</nrctadeb>";
    $xml .= "   <nrctacrd>".$nrctacrd."</nrctacrd>";
    $xml .= "   <vllanmto>".$vllanmto."</vllanmto>";
    $xml .= "   <cdhistor_padrao>".$cdhistor_padrao."</cdhistor_padrao>";
    $xml .= "   <dslancamento>".$dslancamento."</dslancamento>";
    $xml .= "   <cdoperad>".$cdoperad."</cdoperad>";
    $xml .= "   <nrregist>".$nrregist."</nrregist>";	
	$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "   <opevlrlan>".$opevlrlan."</opevlrlan>";
    $xml .= "  </Dados>";
	$xml .= "</Root>";
	


	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "SLIP", "CONSULTA_LANCAMENTOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"]                
                           , $glbvars["cdoperad"],  "</Root>");
	//Cria objeto para classe de tratamento de XML
	//$xmlObjeto = getObjectXML($xmlResult);
	$xmlObjeto = getObjectXML($xmlResult);
	//$xmlObjeto = simplexml_load_string($xmlResult);	

    
	//$dscritic = $xmlObjeto->Erro->Registro->dscritic;
	

    // ----------------------------------------------------------------------------------------------------------------------------------
	// Controle de Erros
	// ----------------------------------------------------------------------------------------------------------------------------------
	// Somente se for a consulta inicial

	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro','estadoInicial();',false);
	}	
	
	$qtregist = $xmlObjeto->roottag->tags[1]->cdata;
    $lancamentos = $xmlObjeto->roottag->tags[0]->tags;  
    $tipbusca = "C";
	include('tab_lancamentos.php');


?>