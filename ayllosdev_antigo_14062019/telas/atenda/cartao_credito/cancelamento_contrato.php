 <?
 
session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');
isPostMethod();

$nrctrcrd = $_POST["nrctrcrd"];
$nrdconta = $_POST["nrdconta"];

if(!($_POST["nrctrcrd"]) && !($_POST["nrctrcrd"])){
	exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro);
}

	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <nrdconta>$nrdconta</nrdconta>";
	$xml .= "   <nrctrcrd>$nrctrcrd</nrctrcrd>";
    $xml .= " </Dados>";
    $xml .= "</Root>";
 
    $admresult = mensageria($xml, "ATENDA_CRD", "CANCELAR_PROPOSTA_CRD", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$admxmlObj = getObjectXML($admresult);
	$procXML = simplexml_load_string($admresult);
	if(isset($procXML->Erro)){
		$hasError  = true;
		$errorMsg  = $procXML->Erro->Registro->dscritic."";
		$errorCod  = $procXML->Erro->Registro->cdcritic;
		echo "/*acao: aqui ALTERAR_CARTAO_BANCOOB \n enviado:\n $xml \n Recebido \n    $admresult \n */ \n";
		echo 'showError("error","'.utf8ToHtml($errorMsg).'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	}else{
		echo " /* retorno: \n $admresult \n */";
		echo 'showError("inform","'.utf8ToHtml($procXML->Dados->inf->mensagem).'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo "voltarParaTelaPrincipal();";
	}
 
 
 ?>