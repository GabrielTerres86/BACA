<? 
/*!
 * FONTE        : busca_endereco_correspondencia.php
 * CRIAÇÃO      : Rogério Giacomini de Almeida
 * DATA CRIAÇÃO : 28/09/2011
 * OBJETIVO     : retorna  o endereco de correspondência de acordo com o tipo do endereço que for passado (1 - Local do Risco/2 - Residencial/3 - Comercial
 * ALTERAÇÕES   : 25/07/2013 - Incluído o campo Complemento no endereço. (James).		
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

// Atribuição de valores
$nrdconta = $_POST["nrdconta"];
$tpendcor = $_POST["tpendcor"]; // tipo do endereço de correspondência
$idseqttl = isset($_POST["idseqttl"])?$_POST["idseqttl"]:1;

// Verifica se número da conta é um inteiro válido
if (!validaInteiro($nrdconta)) {
	exibeErro("Conta/dv inv&aacute;lida.");
}

// Monta o xml de requisição
$xml  = "";
$xml .= "<Root>";
$xml .= "	<Cabecalho>";
$xml .= "		<Bo>b1wgen0033.p</Bo>";
$xml .= "		<Proc>busca_end_cor</Proc>";
$xml .= "	</Cabecalho>";
$xml .= "	<Dados>";
$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
$xml .= "		<nmdatela>".$glbvars['nmdatela']."</nmdatela>";
$xml .= "		<idorigem>".$glbvars['idorigem']."</idorigem>";
$xml .= "		<flgerlog>FALSE</flgerlog>";
$xml .= "		<tpendcor>".$tpendcor."</tpendcor>";
$xml .= "	</Dados>";
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xml);
// Cria objeto para classe de tratamento de XML
$xmlObjeto = getObjectXML($xmlResult);

if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo($(\'#divRotina\'));',false);
}
$endereco  = $xmlObjeto->roottag->tags[0]->tags[0];

$dsendere  = getByTagName($endereco->tags,'dsendres');
$nrendere  = getByTagName($endereco->tags,'nrendres');
$complend  = getByTagName($endereco->tags,'complend');
$nmbairro  = getByTagName($endereco->tags,'nmbairro');
$nmcidade  = getByTagName($endereco->tags,'nmcidade');
$cdufende  = getByTagName($endereco->tags,'cdufresd');
$nrcepend  = getByTagName($endereco->tags,'nrcepend');
$nrcepend  = substr($nrcepend,0,5)."-".substr($nrcepend,5,3);

echo "
	$('#nrcepend2', '#frmSeguroCasa').val('{$nrcepend}');  
	$('#dsendres2', '#frmSeguroCasa').val('{$dsendere}');  
	$('#nrendere2', '#frmSeguroCasa').val('{$nrendere}');  
	$('#nmbairro2', '#frmSeguroCasa').val('{$nmbairro}');  
	$('#nmcidade2', '#frmSeguroCasa').val('{$nmcidade}');  
	$('#cdufresd2', '#frmSeguroCasa').val('{$cdufende}');
	$('#complend2', '#frmSeguroCasa').val('{$complend}');
";

echo 'formataCep();';