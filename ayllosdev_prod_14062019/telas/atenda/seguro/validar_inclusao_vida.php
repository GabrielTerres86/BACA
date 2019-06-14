<? 
/*!
 * FONTE        : valida_inclusao_vida.php
 * CRIAÇÃO      : Michel M Candido
 * DATA CRIAÇÃO : 21/09/2011
 * OBJETIVO     : valida inclusão de um seguro do tipo Vida.
 */
session_start();
	
// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");		
require_once("../../../includes/controla_secao.php");
// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");
	
// Verifica se tela foi chamada pelo método POST
isPostMethod();	
	
if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
	exibeErro($msgError);		
}
	
// Verifica se número da conta foi informado
if (!isset($_POST["nrdconta"])) {
	exibeErro("Par&acirc;metros incorretos.");
}

$nrdconta = $_POST["nrdconta"];

// Verifica se número da conta é um inteiro válido
if (!validaInteiro($nrdconta)) {
	exibeErro("Conta/dv inv&aacute;lida.");
}

/*recupera os valores*/
$inpessoa = $_POST['inpessoa'];
$cdtipo   = $_POST['tipo'];
$dtnasc   = $_POST['dtnascsg'];
$vlpreseg   = $_POST['vlpreseg'];
$vlmorada   = $_POST['vlmorada'];
$nmdsegur   = $_POST['nmdsegur'];
// Monta o xml de requisição
$xml  = "";
$xml .= "<Root>";
$xml .= "	<Cabecalho>";
$xml .= "		<Bo>b1wgen0033.p</Bo>";
$xml .= "		<Proc>validar_inclusao_vida</Proc>";
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
$xml .= "		<nmdsegur>".$nmdsegur."</nmdsegur>";
$xml .= "		<vlplaseg>".$vlpreseg."</vlplaseg>";
$xml .= "		<vlcapseg >".$vlpreseg."</vlcapseg >";
$xml .= "		<inpessoa>".$inpessoa."</inpessoa>";
$xml .= "		<cdsitdct>".$cdtipo."</cdsitdct>";
$xml .= "		<dtnascsg>".$dtnasc."</dtnascsg>";
$xml .= "	</Dados>";
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xml);
// Cria objeto para classe de tratamento de XML
$xmlObjeto = getObjectXML($xmlResult);

if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO' ) {
		$mtdErro = 'bloqueiaFundo(divRotina);';
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$mtdErro,false);
}






