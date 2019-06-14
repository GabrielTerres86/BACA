<? 
/*!
 * FONTE        : altera_seguro.php
 * CRIAÇÃO      : Michel M Candido
 * DATA CRIAÇÃO : 23/09/2011
 * OBJETIVO     : Entrada de dados responsável pela atualização do seguro (tipo vida)
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

// Atribuição de valores para as variáveis utilizadas no envio de dados
$nrdconta = $_POST["nrdconta"];
$tpseguro = $_POST["tpseguro"];
$nmdsegur = $_POST["nmdsegur"];
$nrcepend = $_POST["nrcepend"];
$dsendere = $_POST["dsendere"];
$cdufende = $_POST["cdufende"];
$nrendere = $_POST["nrendere"];
$nmbairro = $_POST["nmbairro"];
$nmcidade = $_POST["nmcidade"];
$vlplaseg = $_POST["vlplaseg"];
$vlmorada = $_POST["vlmorada"];
$cdsitdct = $_POST["cdsitdct"];
$nrcpfcgc = $_POST["nrcpfcgc"];
$vlcapseg = $_POST["vlcapseg"];
$tpplaseg = $_POST["tpplaseg"];
$vlpreseg = $_POST['vlpreseg']; 
$dsgraupr1 = $_POST['dsgraupr1'];
$dsgraupr2 = $_POST['dsgraupr2'];
$dsgraupr3 = $_POST['dsgraupr3'];
$dsgraupr4 = $_POST['dsgraupr4'];
$dsgraupr5 = $_POST['dsgraupr5'];
$nmbenvid1 = $_POST['nmbenefi1'];
$nmbenvid2 = $_POST['nmbenefi2'];
$nmbenvid3 = $_POST['nmbenefi3'];
$nmbenvid4 = $_POST['nmbenefi4'];
$nmbenvid5 = $_POST['nmbenefi5'];
$txpartic1 = $_POST['txpartic1'];
$txpartic2 = $_POST['txpartic2'];
$txpartic3 = $_POST['txpartic3'];
$txpartic4 = $_POST['txpartic4'];
$txpartic5 = $_POST['txpartic5'];
$operacao  = $_POST['operacao'];
$cdempres  = $_POST['cdempres'];
$cdsexosg  = $_POST['cdsexosg'];
$cdsegura  = $_POST['cdsegura'];
$nrctrseg  = $_POST['nrctrseg'];
$cdsitseg  = $_POST['cdsitseg'];
$qtparcel  = $_POST['qtparcel'];
$qtprepag  = $_POST['qtprepag'];

// Verifica se número da conta é um inteiro válido
if (!validaInteiro($nrdconta)) {
	exibeErro("Conta/dv inv&aacute;lida.");
}
// Monta o xml de requisição
$xml  = "";
$xml .= "<Root>";
$xml .= "	<Cabecalho>";
$xml .= "		<Bo>b1wgen0033.p</Bo>";
$xml .= "		<Proc>atualizar_seguro</Proc>";
$xml .= "	</Cabecalho>";
$xml .= "	<Dados>";
$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
$xml .= "       <idseqttl>1</idseqttl>";
$xml .= "		<nmdatela>".$glbvars['nmdatela']."</nmdatela>";
$xml .= "		<flgerlog>FALSE</flgerlog>";
$xml .= "		<tpseguro>".$tpseguro."</tpseguro>";
$xml .= "		<nrctrseg>".$nrctrseg."</nrctrseg>";
$xml .= "		<cdmotcan></cdmotcan>";
$xml .= "		<cdsegura>".$cdsegura."</cdsegura>";
$xml .= "		<cdsitseg>".$cdsitseg."</cdsitseg>";
$xml .= "		<idorigem>".$glbvars['idorigem']."</idorigem>";
$xml .= "		<dtaltseg>".$glbvars["dtmvtolt"]."</dtaltseg>";
$xml .= "		<dtcancel></dtcancel>";
$xml .= "		<dtdebito>".$glbvars["dtmvtolt"]."</dtdebito>";
$xml .= "		<dtfimvig></dtfimvig>";
$xml .= "		<dtiniseg>".$glbvars["dtmvtolt"]."</dtiniseg>";
$xml .= "		<dtinivig>".$glbvars["dtmvtolt"]."</dtinivig>";
$xml .= "		<dtprideb>".$glbvars["dtmvtolt"]."</dtprideb>";
$xml .= "		<dtultalt>".$glbvars["dtmvtolt"]."</dtultalt>";
$xml .= "		<dtultpag>".$glbvars["dtmvtolt"]."</dtultpag>";
$xml .= "		<flgclabe>false</flgclabe>";
$xml .= "		<flgconve>false</flgconve>";
$xml .= "		<flgunica>false</flgunica>";
$xml .= "		<indebito>0</indebito>";
$xml .= "		<lsctrant></lsctrant>";
$xml .= "		<nrctratu>0</nrctratu>";
$xml .= "		<nrdolote>0</nrdolote>";
$xml .= "		<nrseqdig>0</nrseqdig>";
$xml .= "		<qtparcel>$qtparcel</qtparcel>";
$xml .= "		<qtprepag>$qtprepag</qtprepag>";
$xml .= "		<qtprevig>0</qtprevig>";
$xml .= "		<tpdpagto>0</tpdpagto>";
$xml .= "		<tpoperac>0</tpoperac>";
$xml .= "		<tpplaseg>$tpplaseg</tpplaseg>";
$xml .= "		<vldifseg>0</vldifseg>";
$xml .= "		<vlpremio>0</vlpremio>";
$xml .= "		<vlpreseg>$vlpreseg</vlpreseg>";
$xml .= "		<vlcapseg>$vlcapseg</vlcapseg>";
$xml .= "		<cdbccxlt>0</cdbccxlt>";
$xml .= "		<nrcpfcgc>$nrcpfcgc</nrcpfcgc>";
$xml .= "		<nmdsegur>$nmdsegur</nmdsegur>";
$xml .= "		<vltotpre>0</vltotpre>";
$xml .= "		<cdcalcul>0</cdcalcul>";


// informações do plano seguro
$xml .= "		<vlseguro>$vlplaseg</vlseguro>";
$xml .= "		<vlmorada>$vlmorada</vlmorada>";

//informações do endereço
$xml .= "		<tpendcor>1</tpendcor>";
$xml .= "		<dsendres>$dsendere</dsendres>";
$xml .= "		<nrendere>$nrendere</nrendere>";
$xml .= "		<nmbairro>$nmbairro</nmbairro>";
$xml .= "		<nmcidade>$nmcidade</nmcidade>";
$xml .= "		<cduferes>$cdufende</cduferes>";
$xml .= "		<nrcepend>$nrcepend</nrcepend>";

if($tpseguro != 4){
	$xml .= "		<dsgraupr1>$dsgraupr1</dsgraupr1>";
	$xml .= "		<dsgraupr2>$dsgraupr2</dsgraupr2>";
	$xml .= "		<dsgraupr3>$dsgraupr3</dsgraupr3>";
	$xml .= "		<dsgraupr4>$dsgraupr4</dsgraupr4>";
	$xml .= "		<dsgraupr5>$dsgraupr5</dsgraupr5>";
	
	$xml .= "		<nmbenvid1>$nmbenvid1</nmbenvid1>";
	$xml .= "		<nmbenvid2>$nmbenvid2</nmbenvid2>";
	$xml .= "		<nmbenvid3>$nmbenvid3</nmbenvid3>";
	$xml .= "		<nmbenvid4>$nmbenvid4</nmbenvid4>";
	$xml .= "		<nmbenvid5>$nmbenvid5</nmbenvid5>";
	
	$xml .= "		<txpartic1>$txpartic1</txpartic1>";
	$xml .= "		<txpartic2>$txpartic2</txpartic2>";
	$xml .= "		<txpartic3>$txpartic3</txpartic3>";
	$xml .= "		<txpartic4>$txpartic4</txpartic4>";
	$xml .= "		<txpartic5>$txpartic5</txpartic5>";
}
	$xml .= "		<cdsexosg>$cdsexosg</cdsexosg>";
	$xml .= "		<cdempres>$cdempres</cdempres>";
	
$xml .= "	</Dados>";
$xml .= "</Root>";

// Executa script para envio do XML
$xmlResult = getDataXML($xml);

$xml = new DOMDocument();
$xml->load(xmlResult);
//Cria objeto para classe de tratamento de XML
$xmlObjeto = getObjectXML($xmlResult);

if(strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO' ) {
	$mtdErro = 'bloqueiaFundo(divRotina);';
	exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$mtdErro,false);
}
$seguros  = $xmlObjeto->roottag->tags[0]->tags[0];