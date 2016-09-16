<?php 

/*************************************************************************
	Fonte: valida_habilitacao.php
	Autor: Gabriel						Ultima atualizacao: 29/04/2015
	Data : Dezembro/2010
	
	Objetivo: Valida os dados da inclusao.
	
	Alteracoes: 19/05/2011 - Tratar cob. regist. (Guilherme).
	
				29/04/2015 - Incluido campo cddbanco. (Reinert)

*************************************************************************/
session_start();

// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();	

// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");

if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
	exibeErro($msgError);		
}	

$nrdconta = $_POST["nrdconta"];
$nrconven = $_POST["nrconven"];
$dsorgarq = $_POST["dsorgarq"];


// Monta xml
$xmlValidaHabilitacao  = "";
$xmlValidaHabilitacao .= "<Root>";
$xmlValidaHabilitacao .= " <Cabecalho>";
$xmlValidaHabilitacao .= "  <Bo>b1wgen0082.p</Bo>";
$xmlValidaHabilitacao .= "  <Proc>valida-habilitacao</Proc>";
$xmlValidaHabilitacao .= " </Cabecalho>";
$xmlValidaHabilitacao .= " <Dados>";
$xmlValidaHabilitacao .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xmlValidaHabilitacao .= "   <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
$xmlValidaHabilitacao .= "   <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
$xmlValidaHabilitacao .= "   <cdoperad>".$glbvars["cdoperad"]."</cdoperad>"; 
$xmlValidaHabilitacao .= "   <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
$xmlValidaHabilitacao .= "   <idorigem>".$glbvars["idorigem"]."</idorigem>";           
$xmlValidaHabilitacao .= "   <nrdconta>".$nrdconta."</nrdconta>";
$xmlValidaHabilitacao .= "   <nrconven>".$nrconven."</nrconven>";
$xmlValidaHabilitacao .= "   <idseqttl>1</idseqttl>";         
$xmlValidaHabilitacao .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
$xmlValidaHabilitacao .= " </Dados>";
$xmlValidaHabilitacao .= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xmlValidaHabilitacao);

// Cria objeto para classe de tratamento de XML
$xmlObjDadosCobranca = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra cr&iacute;tica
if (strtoupper($xmlObjDadosCobranca->roottag->tags[0]->name) == "ERRO") {
	exibeErro($xmlObjDadosCobranca->roottag->tags[0]->tags[0]->tags[4]->cdata);
} 

echo 'hideMsgAguardo();';

$dsorgarq = $xmlObjDadosCobranca->roottag->tags[0]->attributes["DSORGARQ"];
$flgregis = $xmlObjDadosCobranca->roottag->tags[0]->attributes["FLGREGIS"];
$cddbanco = $xmlObjDadosCobranca->roottag->tags[0]->attributes["CDDBANCO"];
$flserasa = $xmlObjDadosCobranca->roottag->tags[0]->attributes["FLSERASA"];
$cddopcao = "I"; // Habilitacao (Inclusao)

echo '$("#dsorgarq","#divOpcaoIncluiAltera").val("'.$dsorgarq.'");';
echo '$("#flgregis","#divOpcaoIncluiAltera").val("'.$flgregis.'");';
echo '$("#cddbanco","#divOpcaoIncluiAltera").val("'.$cddbanco.'");';

echo '$("#flserasa","#divOpcaoIncluiAltera").val("'.$flserasa.'");';

echo 'consulta("'.$cddopcao.'" , "'.$nrconven.'" , "'.$dsorgarq.'" , "true" , "'.$flgregis.'", "'.$cddbanco.'");';

// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
function exibeErro($msgErro) {	
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
	exit();
}	

?>

