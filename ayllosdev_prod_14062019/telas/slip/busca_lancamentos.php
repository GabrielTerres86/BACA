<?
	/*!
    * FONTE        : busca_lancamentos.php
	* CRIAÇÃO      : Alcemir Junior - Mout's
	* DATA CRIAÇÃO : 10/10/2018
	* OBJETIVO     :  tela SLIP
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
	
	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";	
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <nrregist>".$nrregist."</nrregist>";	
	$xml .= "   <nriniseq>".$nriniseq."</nriniseq>";	
	$xml .= "  </Dados>";
	$xml .= "</Root>";
	

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "SLIP", "BUSCA_LANCAMENTOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"]                    , $glbvars["cdoperad"],  "</Root>");
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
	$dtmvtolt = $glbvars["dtmvtolt"];	
    $lancamentos = $xmlObjeto->roottag->tags[0]->tags;
	$tipbusca = "";
	include('tab_lancamentos.php');


?>