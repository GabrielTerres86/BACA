<?php 

session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');
isPostMethod();		
if(( !isset($_POST['cdcooper'])) || ( !isset($_POST['nrdconta'])) ||(!isset($_POST['nrctrcrd'])) ||(!isset($_POST['ds_justif'])) ||(!isset($_POST['inupgrad']))){
	echo "showError(\"error\", \"Erro ao atualizar justificativa.\", \"Alerta - Aimaro\", \"blockBackground(parseInt($('#divRotina').css('z-index')))\");";
	return;
}

$funcaoAposErro = 'bloqueiaFundo(divRotina);';
$cdcooper =  $_POST['cdcooper'];
$nrdconta =  $_POST['nrdconta'];
$nrctrcrd = $_POST['nrctrcrd'];
$ds_justif =  $_POST['ds_justif'];
$inupgrad = $_POST['inupgrad'];
$cdadmnov = $_POST['cdadmnov'];
$nrctrcrd_novo = $_POST['nrctrcrd_novo'];

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "ATENDA_CRD", "ENVIO_CARTAO_COOP_PA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjeto = getObjectXML($xmlResult);

$coop_envia_cartao = getByTagName($xmlObjeto->roottag->tags,"COOP_ENVIO_CARTAO");

$updContratoXML .= "<Root>";
$updContratoXML .= " <Dados>";
$updContratoXML .= "   <cdcooper>".$cdcooper."</cdcooper>";
$updContratoXML .= "   <nrdconta>".$nrdconta."</nrdconta>";
$updContratoXML .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
$updContratoXML .= "   <ds_justif>".$ds_justif."</ds_justif>";
$updContratoXML .= "   <inupgrad>".$inupgrad."</inupgrad>";
$updContratoXML .= "   <cdadmnov>".$cdadmnov."</cdadmnov>";
$updContratoXML .= " </Dados>";
$updContratoXML .= "</Root>";
$admresult = mensageria($updContratoXML, "ATENDA_CRD", "ATUALIZAR_JUSTIF_UPGR_DOWNGR", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$procXML = simplexml_load_string($admresult);
$xmlObject = getObjectXML($admresult);
if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
	$msg = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;		
	echo "/* $admresult */";
	echo "error = true;showError(\"error\", \" ".preg_replace( "/\r|\n/", "", addslashes($msg) )." \", \"Alerta - Aimaro\", \"blockBackground(parseInt($('#divRotina').css('z-index')))\");";
	exit();
}else{
	echo" /* \n $admresult \n */";
	
	$acao = "voltaDiv(0,1,4); bloqueiaFundo(divRotina,\'nrctaav1\',\'frmNovoCartao\',false);";
	if ($coop_envia_cartao) {
		$acao = "nrctrcrd = ".$nrctrcrd_novo."; nrctrcrd_updown = ".$nrctrcrd."; consultaEnderecos(2);";
	}
	
	echo 'showError("inform"," '.utf8ToHtml("Alteração de categoria efetuada com sucesso.").' ","Alerta - Aimaro", "'.$acao.'");';
}

?>


