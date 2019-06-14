<? 
/*!
 * FONTE        : busca_seguro.php
 * CRIAÇÃO      : Michel M Candido
 * DATA CRIAÇÃO : 22/09/2011
 * OBJETIVO     : retorna  informacoes do segurado
 *
 * ALTERACOES   : 10/03/2015 - Incluir a variavel vlseguro. (James) 
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
$tpplaseg = $_POST['tpplaseg'];
$tpseguro = $_POST['tpseguro'];
$nrctrseg = $_POST['nrctrseg'];
$cdsegura = $_POST['cdsegura'];

// Verifica se número da conta é um inteiro válido
if (!validaInteiro($nrdconta)) {
	exibeErro("Conta/dv inv&aacute;lida.");
}

// Monta o xml de requisição
$xml  = "";
$xml .= "<Root>";
$xml .= "	<Cabecalho>";
$xml .= "		<Bo>b1wgen0033.p</Bo>";
$xml .= "		<Proc>buscar_seguro_geral</Proc>";
$xml .= "	</Cabecalho>";
$xml .= "	<Dados>";
$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
$xml .= "		<idseqttl>1</idseqttl>";
$xml .= "		<nmdatela>".$glbvars['nmdatela']."</nmdatela>";
$xml .= "		<idorigem>".$glbvars['idorigem']."</idorigem>";
$xml .= "		<nrctrseg>$nrctrseg</nrctrseg>";
$xml .= "		<flgerlog>FALSE</flgerlog>";
$xml .= "		<cdsegura>$cdsegura</cdsegura>";
$xml .= "		<tpseguro>$tpseguro</tpseguro>";
$xml .= "	</Dados>";
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xml);
$xmlObjeto = getObjectXML($xmlResult);

if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO' ) {
		$mtdErro = 'bloqueiaFundo(divRotina);';
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$mtdErro,false);
}
$seguro  		= $xmlObjeto->roottag->tags[0]->tags[0];
$dtultalt 		= getByTagName($seguro->tags,'dtultalt');
$dscobert 		= getByTagName($seguro->tags,'dscobert');
$dspesseg 		= getByTagName($seguro->tags,'dspesseg');
$dsseguro 		= getByTagName($seguro->tags,'dsseguro');
$vlcapseg 		= number_format(getByTagName($seguro->tags,'vlcapseg'),2,',','.');
$vl_morada 		= number_format(getByTagName($seguro->tags,'vlmorada'),2,',','.');

echo "
	dsseguro  = '{$dsseguro}';
	vlmorada  = '{$vl_morada }';	
	dtultalt  = '{$dtultalt }';	
	dscobert  = '{$dscobert }';
	dspesseg  = '{$dspesseg }';	
	vlseguro  = '{$vlcapseg }';	
";



