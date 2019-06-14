<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	$dtvencto = $_POST["dtvencto"];
	$cdbandoc = $_POST["cdbandoc"];
	$vltitulo = str_replace(',','.',str_replace('.','',$_POST["vltitulo"]));
	$nrcnvcob = $_POST["nrcnvcob"];
	$nrdconta = $_POST["nrdconta"];
	$nrdocmto = $_POST["nrdocmto"];

	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <dtvencto>".$dtvencto."</dtvencto>";
	$xml .= "   <cdbandoc>".$cdbandoc."</cdbandoc>";
	$xml .= "   <vltitulo>".$vltitulo."</vltitulo>";
	$xml .= "   <nrcnvcob>".$nrcnvcob."</nrcnvcob>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrdocmto>".$nrdocmto."</nrdocmto>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "COBRAN", "BUSCA_CODIGO_BARRAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	  $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
	  if ($msgErro == "") {
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
	  }
	  
	  exibirErro('error',$msgErro,'Alerta - Ayllos','fechaRotina( $(\'#divRotina\') )', false);
	  exit();
	}
	$cdbarras = getByTagName($xmlObj->roottag->tags[0]->tags[0]->tags,'cdbarras');
	$lindigit = getByTagName($xmlObj->roottag->tags[0]->tags[0]->tags,'lindigit');
	
	echo "$('#cdbarras', '.complemento').html('$cdbarras');";
    echo "$('#lindigit', '.complemento').html('$lindigit');";
	