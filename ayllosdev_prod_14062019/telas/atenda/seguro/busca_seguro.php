<? 
/*!
 * FONTE        : busca_seguro.php
 * CRIAÇÃO      : Michel M Candido
 * DATA CRIAÇÃO : 22/09/2011
 * OBJETIVO     : retorna  informacoes do segurado
 * ALTERAÇÕES   : 26/06/2012 - Alterado nome da variável de $vlseguro para $vlpreseg (Guilherme Maba).
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

// Verifica se número da conta é um inteiro válido
if (!validaInteiro($nrdconta)) {
	exibeErro("Conta/dv inv&aacute;lida.");
}

// Monta o xml de requisição
$xml  = "";
$xml .= "<Root>";
$xml .= "	<Cabecalho>";
$xml .= "		<Bo>b1wgen0033.p</Bo>";
$xml .= "		<Proc>buscar_plano_seguro</Proc>";
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
$xml .= "		<flgerlog>FALSE</flgerlog>";
$xml .= "		<cdsegura>0</cdsegura>";
$xml .= "		<tpseguro>$tpseguro</tpseguro>";
$xml .= "		<tpplaseg>$tpplaseg</tpplaseg>";
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

$vlpreseg 		= getByTagName($seguro->tags,'vlplaseg');
$vl_morada 		= getByTagName($seguro->tags,'vlmorada');

echo "
		vlplaseg  = '{$vlpreseg}';
		vlmorada = '{$vl_morada }';		
";



