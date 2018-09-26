<? 
/*!
 * FONTE        : cria_seguro.php
 * CRIAÇÃO      : Michel M Candido
 * DATA CRIAÇÃO : 23/09/2011
 * OBJETIVO     : Efetuar a insercao dos dados
 * ALTEREÇÕES   : 20/12/2011 - Incluido a passagem do paramaetro dtnascsg (Adriano).
				  28/02/2013 - Incluir nrctrseg em POST (Lucas R.)
                  05/03/2015 - Incluir tratamento de dia dos proximos debitos para seguro de vida(Odirlei-AMcom)
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

$nrdconta = isset($_POST["nrdconta"])?$_POST["nrdconta"]:'';
$tpseguro = isset($_POST["tpseguro"])?$_POST["tpseguro"]:'';
$nmdsegur = isset($_POST["nmdsegur"])?$_POST["nmdsegur"]:'';
$dsendere = isset($_POST["dsendere"])?$_POST["dsendere"]:'';
$nrendere = isset($_POST["nrendere"])?$_POST["nrendere"]:'';
$nmbairro = isset($_POST["nmbairro"])?$_POST["nmbairro"]:'';
$nmcidade = isset($_POST["nmcidade"])?$_POST["nmcidade"]:'';
$cdufende = isset($_POST["cdufende"])?$_POST["cdufende"]:'';
$nrcepend = isset($_POST["nrcepend"])?$_POST["nrcepend"]:'';
$nrcepend = str_replace('-','',$nrcepend);
$vlplaseg = isset($_POST["vlplaseg"])?$_POST["vlplaseg"]:'';
$vlplaseg = (intval($vlplaseg) > 0)?$vlplaseg:'0';
$vlmorada = isset($_POST["vlmorada"])?$_POST["vlmorada"]:'';
$vlmorada = (intval($vlmorada) > 0)?$vlmorada:'0';
$nmprimtl = isset($_POST["nmprimtl"])?$_POST["nmprimtl"]:'';
$cdsitdct = isset($_POST["cdsitdct"])?$_POST["cdsitdct"]:'';

$vlcapseg = (intval($_POST["vlcapseg"]) > 0)?$_POST["vlcapseg"]:'0';
$tpplaseg = isset($_POST["tpplaseg"])?$_POST["tpplaseg"]:'';
$vlpreseg = isset($_POST["vlpreseg"])?$_POST["vlpreseg"]:'';

$dsgraupr1 = isset($_POST["dsgraupr1"])?$_POST["dsgraupr1"]:'';
$dsgraupr2 = isset($_POST["dsgraupr2"])?$_POST["dsgraupr2"]:'';
$dsgraupr3 = isset($_POST["dsgraupr3"])?$_POST["dsgraupr3"]:'';
$dsgraupr4 = isset($_POST["dsgraupr4"])?$_POST["dsgraupr4"]:'';
$dsgraupr5 = isset($_POST["dsgraupr5"])?$_POST["dsgraupr5"]:'';

$nmbenvid1 = $_POST['nmbenefi1'];
$nmbenvid2 = $_POST['nmbenefi2'];
$nmbenvid3 = $_POST['nmbenefi3'];
$nmbenvid4 = $_POST['nmbenefi4'];
$nmbenvid5 = $_POST['nmbenefi5'];

$txpartic1 = isset($_POST["txpartic1"])?$_POST["txpartic1"]:'';
$txpartic2 = isset($_POST["txpartic2"])?$_POST["txpartic2"]:'';
$txpartic3 = isset($_POST["txpartic3"])?$_POST["txpartic3"]:'';
$txpartic4 = isset($_POST["txpartic4"])?$_POST["txpartic4"]:'';
$txpartic5 = isset($_POST["txpartic5"])?$_POST["txpartic5"]:'';
$operacao  = isset($_POST["operacao"])?$_POST["operacao"]:'';
$cdempres  = isset($_POST["cdempres"])?$_POST["cdempres"]:'';
$cdsexosg  = isset($_POST["cdsexosg"])?$_POST["cdsexosg"]:'';
$dtfimvig  = isset($_POST["dtfimvig"])?$_POST["dtfimvig"]:'';
$cdsegura  = (intval($_POST['cdsegura']) > 0)?$_POST['cdsegura']:'0';
$nrcpfcgc  = isset($_POST['nrcpfcgc'])?$_POST['nrcpfcgc']:'';
$dtnascsg  = isset($_POST['dtnascsg'])?$_POST['dtnascsg']:'';
//$nrctrseg  = isset($_POST['nrctrseg'])?$_POST['nrctrseg']:'';

$nmresseg = '';
$nrctrseg = '0';
$ddpripag = '';
$ddvencto = '';
$flgclabe = 'false'; 
$nmbenvid = ''; 
$tpendcor = 1;

if($operacao == 'I_CASA'){
	$tpseguro = 11;
	$nmresseg = $_POST["nmresseg"];
	$nrctrseg = $_POST["nrctrseg"];
	$ddpripag = $_POST["ddpripag"];
	$ddvencto = $_POST["ddvencto"];
	$flgclabe = $_POST['flgclabe']; 
	$nmbenvid = $_POST['nmbenvid']; 
	$cdufende = $_POST['cdufresd']; 
	$nmprimtl = '';
	
	// Endereço
	$dsendere = $_POST["dsendres"];
	$tpendcor = $_POST["tpendcor"];
	
	// validação pelo número da página 
	$nrpagina = $_POST['nrpagina'];
}else{
  // buscar no post o dia dos proximos debitos
  if ($tpseguro == 3) {
     $ddvencto = $_POST["ddvencto"];
  }
}

// Verifica se número da conta é um inteiro válido
if (!validaInteiro($nrdconta)) {
	exibeErro("Conta/dv inv&aacute;lida.");
}

// Monta o xml de requisição
$xml  = "";
$xml .= "<Root>";
$xml .= "	<Cabecalho>";
$xml .= "		<Bo>b1wgen0033.p</Bo>";
$xml .= "		<Proc>validar_criacao</Proc>";
$xml .= "	</Cabecalho>";
$xml .= "	<Dados>";
$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
$xml .= "		<dtultdia>".$glbvars["dtmvtolt"]."</dtultdia>";
$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
$xml .= "       <idseqttl>1</idseqttl>";
$xml .= "		<nmdatela>".$glbvars['nmdatela']."</nmdatela>";
$xml .= "		<idorigem>".$glbvars['idorigem']."</idorigem>";
$xml .= "		<cdsegura>".$cdsegura."</cdsegura>";
$xml .= "		<cdsitseg>1</cdsitseg>";
$xml .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";

$xml .= "		<dtaltseg>".$glbvars["dtmvtolt"]."</dtaltseg>";
$xml .= "		<dtcancel>?</dtcancel>";
$xml .= "		<dtiniseg>".$glbvars["dtmvtolt"]."</dtiniseg>";
$xml .= "		<dtinivig>".$glbvars["dtmvtolt"]."</dtinivig>";
$xml .= "		<dtprideb>".$glbvars["dtmvtolt"]."</dtprideb>";
$xml .= "		<dtultalt>".$glbvars["dtmvtolt"]."</dtultalt>";
$xml .= "		<dtultpag>".$glbvars["dtmvtolt"]."</dtultpag>";
$xml .= "		<nrctrseg>".$nrctrseg."</nrctrseg>";
$xml .= "		<flgclabe>$flgclabe</flgclabe>";
$xml .= "		<flgconve>false</flgconve>";
$xml .= "		<flgunica>false</flgunica>";
$xml .= "		<indebito>0</indebito>";
$xml .= "		<lsctrant></lsctrant>";
$xml .= "		<nrctratu>0</nrctratu>";
$xml .= "		<nrdolote>0</nrdolote>";
$xml .= "		<nrseqdig>0</nrseqdig>";
$xml .= "		<qtparcel>0</qtparcel>";
$xml .= "		<qtprepag>0</qtprepag>";
$xml .= "		<qtprevig>0</qtprevig>";
$xml .= "		<tpdpagto>0</tpdpagto>";
$xml .= "		<tpoperac>0</tpoperac>";
$xml .= "		<tpplaseg>$tpplaseg</tpplaseg>";
$xml .= "		<tpseguro>$tpseguro</tpseguro>";
$xml .= "		<vldifseg>0</vldifseg>";
$xml .= "		<vlpremio>0</vlpremio>";
$xml .= "		<vlpreseg>$vlpreseg</vlpreseg>";
$xml .= "		<vlcapseg>$vlcapseg</vlcapseg>";
$xml .= "		<cdbccxlt>0</cdbccxlt>";

$xml .= "		<nmdsegur>".$nmdsegur."</nmdsegur>";
$xml .= "		<nmprimtl>$nmprimtl</nmprimtl>";
$xml .= "		<vltotpre>0</vltotpre>";
$xml .= "		<cdcalcul>0</cdcalcul>";
$xml .= "       <dtnascsg>".$dtnascsg."</dtnascsg>";


/*infoemacoes do plano seguro*/
$xml .= "		<vlseguro>$vlplaseg</vlseguro>";
$xml .= "		<vlmorada>$vlmorada</vlmorada>";

/*informacoes do endereco*/
$xml .= "		<tpendcor>$tpendcor</tpendcor>";
$xml .= "		<dsendres>$dsendere</dsendres>";
$xml .= "		<nmbairro>$nmbairro</nmbairro>";
$xml .= "		<nmcidade>$nmcidade</nmcidade>";
$xml .= "		<cdufresd>$cdufende</cdufresd>";
$xml .= "		<nrcepend>$nrcepend</nrcepend>";
$xml .= "		<nrendres>$nrendere</nrendres>";

if($operacao == 'I_CASA'){
	if($ddvencto == '' || $ddvencto == 0)
		$ddvencto = $glbvars["dtmvtolt"];
	else
		$ddvencto = $ddvencto."/".substr($glbvars["dtmvtolt"], -7);

	$xml .= "		<nmresseg>".$nmresseg."</nmresseg>";
	$xml .= "		<ddpripag>".$glbvars["dtmvtolt"]."</ddpripag>";
	$xml .= "		<nmbenvid1>".$nmbenvid."</nmbenvid1>";
	$xml .= "		<dtdebito>".$ddvencto."</dtdebito>";
	$xml .= "		<dtfimvig>".$dtfimvig."</dtfimvig>";	
	$xml .= "		<nrpagina>".$nrpagina."</nrpagina>";
}
else{
	
	$xml .= "		<dtfimvig>".$glbvars["dtmvtolt"]."</dtfimvig>";
    
    // se for seguro de vida, definir a data do primeiro debito para a data atual
    // e definir dia dos proximos debitos
    if ($tpseguro == 3) {
        
        if($ddvencto == '' || $ddvencto == 0)
            $ddvencto = $glbvars["dtmvtolt"];
        else
            $ddvencto = $ddvencto."/".substr($glbvars["dtmvtolt"], -7);
        
        $xml .= "		<ddpripag>".$glbvars["dtmvtolt"]."</ddpripag>";
        $xml .= "		<dtdebito>".$ddvencto."</dtdebito>";    
    }
    else{
        $xml .= "		<dtdebito>".$glbvars["dtmvtolt"]."</dtdebito>";
        }
    
}
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

//Cria objeto para classe de tratamento de XML
$xmlObjeto = getObjectXML($xmlResult);

if(strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO' ) {
	$mtdErro = 'bloqueiaFundo(divRotina);';
	exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$mtdErro,false);
}

