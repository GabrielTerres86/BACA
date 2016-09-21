<? 
/*!
 * FONTE        : valida_plano_seguro.php
 * CRIA��O      : Michel M Candido
 * DATA CRIA��O : 26/09/2011
 * OBJETIVO     : valida inclus�o de um seguro.
 */
session_start();
	
// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");
// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");
	
// Verifica se tela foi chamada pelo m�todo POST
isPostMethod();	
	
if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
	exibeErro($msgError);		
}
	
// Verifica se n�mero da conta foi informado
if (!isset($_POST["nrdconta"])) {
	exibeErro("Par&acirc;metros incorretos.");
}

$nrdconta = $_POST["nrdconta"];

// Verifica se n�mero da conta � um inteiro v�lido
if (!validaInteiro($nrdconta)) {
	exibeErro("Conta/dv inv&aacute;lida.");
}

$inpessoa = $_POST['inpessoa'];
$cdtipo   = $_POST['tipo'];
$dtnasc   = $_POST['dtnascsg'];

// Monta o xml de requisi��o
$xml  = "";
$xml .= "<Root>";
$xml .= "	<Cabecalho>";
$xml .= "		<Bo>b1wgen0033.p</Bo>";
$xml .= "		<Proc>validar_plano_seguro</Proc>";
$xml .= "	</Cabecalho>";
$xml .= "	<Dados>";
$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
$xml .= "		<nmdatela>".$glbvars['nmdatela']."</nmdatela>";
$xml .= "       <idseqttl>1</idseqttl>";
$xml .= "		<idorigem>".$glbvars['idorigem']."</idorigem>";
$xml .= "		<flgerlog>FALSE</flgerlog>";
$xml .= "		<cdsitpsg >1</cdsitpsg >";
$xml .= "	</Dados>";
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xml);


// Cria objeto para classe de tratamento de XML
$xmlObjeto = getObjectXML($xmlResult);

if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO' ) {
		$mtdErro = 'bloqueiaFundo(divRotina);';
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$mtdErro,false);
}






