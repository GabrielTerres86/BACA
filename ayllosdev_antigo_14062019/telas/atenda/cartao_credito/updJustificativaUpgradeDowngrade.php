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
	
		$message= "Alteração de categoria efetuada com sucesso.";
	
	echo 'showError("inform"," '.utf8ToHtml( $message).' ","Alerta - Aimaro","voltaDiv(0,1,4); bloqueiaFundo(divRotina,\'nrctaav1\',\'frmNovoCartao\',false);");';
}
echo '  acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,"'.$glbvars["opcoesTela"][0].'");';

?>


