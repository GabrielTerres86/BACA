<? 
/*!
 * FONTE        : cria_seguro.php
 * CRIAÇÃO      : Marcelo Leandro Pereira
 * DATA CRIAÇÃO : 28/09/2011
 * OBJETIVO     : Realiza criação proposta seguro
 * ALTERAÇÕES   : 20/12/2011 - Incluido a passagem dos parametros dtnascsg, nrcpfcgc (Adriano).
				  26/06/2012 - Alterado a passagem do parâmetro vlseguro, trocado campo vlplaseg
							   para vlmorada(Guilherme Maba).
			      18/12/2012 - Incluir alert para o plano 3 (Lucas R.).			
				  28/02/2013 - Incluir nrctrseg em POST (Lucas R.)
				  25/07/2013 - Incluído o campo Complemento no endereço. (James).	
                  05/03/2015 - Incluir tratamento de dia dos proximos debitos para seguro de vida(Odirlei-AMcom)
				  17/06/2016 - M181 - Alterar o CDAGENCI para passar o CDPACTRA (Rafael Maciel - RKAM)
				  06/09/2018 - PRJ 438 - Adicionado campo contrato. (Mateus Z - Mouts)

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
$tpseguro = $_POST["tpseguro"];
$nmdsegur = $_POST["nmdsegur"];
$dsendere = $_POST["dsendere"];
$nrendere = $_POST["nrendere"];
$complend = $_POST["complend"];
$nmbairro = $_POST["nmbairro"];
$nmcidade = $_POST["nmcidade"];
$cdufende = $_POST["cdufende"];
$nrcepend = $_POST["nrcepend"];
$nrcepend = str_replace('-','',$nrcepend);
$vlplaseg = (intval($_POST["vlplaseg"]) > 0)?$_POST["vlplaseg"]:'0';
$vlmorada = (intval($_POST["vlmorada"]) > 0)?$_POST["vlmorada"]:'0';
$nmprimtl = $_POST["nmprimtl"];
$cdsitdct = $_POST["cdsitdct"];
$vlcapseg = (intval($_POST["vlcapseg"]) > 0)?$_POST["vlcapseg"]:'0';
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
$dtfimvig  = $_POST['dtfimvig'];
$cdsegura  = (intval($_POST['cdsegura']) > 0)?$_POST['cdsegura']:'0';
$dtnascsg  = $_POST['dtnascsg'];
$nrcpfcgc  = $_POST['nrcpfcgc'];
$nrctrseg  = $_POST['nrctrseg'];
$nrctrato  = $_POST['nrctrato'];

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
	$vldifseg = isset($_POST['vldifseg'])?$_POST['vldifseg']:0;
	$vlpremio = isset($_POST['vlpremio'])?$_POST['vlpremio']:0;
	$vlcapseg = isset($_POST['vlcapseg'])?$_POST['vlcapseg']:0;

	// Endereço
	$dsendere = $_POST["dsendres"];
	$tpendcor = $_POST["tpendcor"];
	
	// validação pelo número da página 
	$nrpagina = $_POST["nrpagina"];
}else{
  // buscar no post o dia dos proximos debitos
  if ($tpseguro == 3) {
     $ddvencto = $_POST["ddvencto"];
  }
}

$data = explode("/", $glbvars["dtmvtolt"]);
$dtfimvig = date("d/m/Y", mktime(0, 0, 0, $data[1], $data[0] + 365, $data[2]) );

// Verifica se número da conta é um inteiro válido
if (!validaInteiro($nrdconta)) {
	exibeErro("Conta/dv inv&aacute;lida.");
}


// Monta o xml de requisição
$xml  = "";
$xml .= "<Root>";
$xml .= "	<Cabecalho>";
$xml .= "		<Bo>b1wgen0033.p</Bo>";
$xml .= "		<Proc>cria_seguro</Proc>";
$xml .= "	</Cabecalho>";
$xml .= "	<Dados>";
$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
$xml .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
$xml .= "       <idseqttl>1</idseqttl>";
$xml .= "		<nmdatela>".$glbvars['nmdatela']."</nmdatela>";
$xml .= "		<idorigem>".$glbvars['idorigem']."</idorigem>";
$xml .= "		<cdsegura>".$cdsegura."</cdsegura>";
$xml .= "		<cdsitseg>1</cdsitseg>";
$xml .= "		<dtcancel></dtcancel>";
$xml .= "		<dtiniseg>".$glbvars["dtmvtolt"]."</dtiniseg>";
$xml .= "		<dtinivig>".$glbvars["dtmvtolt"]."</dtinivig>";
$xml .= "		<dtfimvig>".$dtfimvig."</dtfimvig>";
$xml .= "		<dtprideb>".$glbvars["dtmvtolt"]."</dtprideb>";
$xml .= "		<dtultalt>".$glbvars["dtmvtolt"]."</dtultalt>";
$xml .= "		<dtultpag>".$glbvars["dtmvtolt"]."</dtultpag>";
$xml .= "		<flgclabe>".$flgclabe."</flgclabe>";
$xml .= "		<flgconve>false</flgconve>";
$xml .= "		<flgunica>false</flgunica>";
$xml .= "		<indebito>0</indebito>";
$xml .= "		<lsctrant></lsctrant>";
//$xml .= "		<nrctratu>0</nrctratu>";
$xml .= "		<nrctratu>".$nrctrato."</nrctratu>";//Contrato escolhido na tela
$xml .= "		<nrctrseg>".$nrctrseg."</nrctrseg>";
$xml .= "		<nrseqdig>0</nrseqdig>";
$xml .= "		<qtparcel>0</qtparcel>";
$xml .= "		<qtprepag>0</qtprepag>";
$xml .= "		<qtprevig>0</qtprevig>";
$xml .= "		<tpdpagto>0</tpdpagto>";
$xml .= "		<tpoperac>0</tpoperac>";
$xml .= "		<tpplaseg>".$tpplaseg."</tpplaseg>";
$xml .= "		<tpseguro>".$tpseguro."</tpseguro>";
$xml .= "		<vldifseg>".$vldifseg."</vldifseg>";
$xml .= "		<vlpremio>".$vlpremio."</vlpremio>";
$xml .= "		<vlpreseg>".$vlpreseg."</vlpreseg>";
$xml .= "		<vlcapseg>".$vlcapseg."</vlcapseg>";

$xml .= "		<nmdsegur>".$nmdsegur."</nmdsegur>";
$xml .= "		<nmprimtl>".$nmprimtl.".</nmprimtl>";
$xml .= "		<cdcalcul>0</cdcalcul>";
$xml .= "	    <dtnascsg>".$dtnascsg."</dtnascsg>";
$xml .= "	    <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";

// Informações do plano seguro
$xml .= "		<vlseguro>".$vlmorada."</vlseguro>";
$xml .= "		<vlmorada>".$vlmorada."</vlmorada>";

// Informações do endereco
$xml .= "		<tpendcor>".$tpendcor."</tpendcor>";
$xml .= "		<dsendres>".$dsendere."</dsendres>";
$xml .= "		<complend>".$complend."</complend>";
$xml .= "		<nmbairro>".$nmbairro."</nmbairro>";
$xml .= "		<nmcidade>".$nmcidade."</nmcidade>";
$xml .= "		<cdufresd>".$cdufende."</cdufresd>";
$xml .= "		<nrcepend>".$nrcepend."</nrcepend>";
$xml .= "		<nrendres>".$nrendere."</nrendres>";

if($operacao == 'I_CASA'){	
	if($ddvencto == '' || $ddvencto == 0)
		$ddvencto = $glbvars["dtmvtolt"];
	else
		$ddvencto = $ddvencto."/".substr($glbvars["dtmvtolt"], -7);
		
	$xml .= "		<nmresseg>".$nmresseg."</nmresseg>";
	$xml .= "		<ddpripag>".$glbvars["ddpripag"]."</ddpripag>";
	$xml .= "		<nmbenvid1>".$nmbenvid."</nmbenvid1>";
	$xml .= "		<dtdebito>".$ddvencto."</dtdebito>";
	$xml .= "		<nrdolote>4151</nrdolote>";
	$xml .= "		<cdbccxlt>200</cdbccxlt>";
	$xml .= "		<dtaltseg>?</dtaltseg>";
	$xml .= "		<vltotpre>".$vlpreseg."</vltotpre>";
	

	$xml .= "		<nrpagina>".$nrpagina."</nrpagina>";
}
else{
	// se for seguro de vida, definir a data do primeiro debito para a data atual
    // e definir o dia dos proximos debitos    
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
    
	$xml .= "		<dtaltseg>".$glbvars["dtmvtolt"]."</dtaltseg>";
	$xml .= "		<nrdolote>0</nrdolote>";
	$xml .= "		<cdbccxlt>0</cdbccxlt>";
	$xml .= "		<vltotpre>0</vltotpre>";
	
}
if($tpseguro != 4){
		$xml .= "		<dsgraupr1>".$dsgraupr1."</dsgraupr1>";
		$xml .= "		<dsgraupr2>".$dsgraupr2."</dsgraupr2>";
		$xml .= "		<dsgraupr3>".$dsgraupr3."</dsgraupr3>";
		$xml .= "		<dsgraupr4>".$dsgraupr4."</dsgraupr4>";
		$xml .= "		<dsgraupr5>".$dsgraupr5."</dsgraupr5>";
		
		$xml .= "		<nmbenvid1>".$nmbenvid1."</nmbenvid1>";
		$xml .= "		<nmbenvid2>".$nmbenvid2."</nmbenvid2>";
		$xml .= "		<nmbenvid3>".$nmbenvid3."</nmbenvid3>";
		$xml .= "		<nmbenvid4>".$nmbenvid4."</nmbenvid4>";
		$xml .= "		<nmbenvid5>".$nmbenvid5."</nmbenvid5>";
		
		$xml .= "		<txpartic1>".$txpartic1."</txpartic1>";
		$xml .= "		<txpartic2>".$txpartic2."</txpartic2>";
		$xml .= "		<txpartic3>".$txpartic3."</txpartic3>";
		$xml .= "		<txpartic4>".$txpartic4."</txpartic4>";
		$xml .= "		<txpartic5>".$txpartic5."</txpartic5>";
	}
	$xml .= "		<cdsexosg>".$cdsexosg."</cdsexosg>";
	$xml .= "		<cdempres>".$cdempres."</cdempres>";
	if($tpseguro == 4){
		$xml .= "		<nrctrato>".$nrctrato."</nrctrato>";
	}	
$xml .= "	</Dados>";
$xml .= "</Root>";
$agora=date("i:s");

// Executa script para envio do XML
$xmlResult = getDataXML($xml);
//Cria objeto para classe de tratamento de XML

$xmlObjeto = getObjectXML($xmlResult);
$flgsegur  = $xmlObjeto->roottag->tags[0]->attributes['FLGSEGUR'];
$reccraws  = $xmlObjeto->roottag->tags[0]->attributes['RECCRAWS'];

$alerta = "Aten&ccedil;&atilde;o! Para a contrata&ccedil;&atilde;o deste plano de seguro, nao h&aacute necessidade do envio da DPS - Declara&ccedil;&atilde;o Pessoal de Sa&uacute;de."; 

if($flgsegur == "yes"){
	exibirErro('alert',$alerta,'Alerta - Aimaro',"",false);
}

if(strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO' ) { 
	$mtdErro = 'bloqueiaFundo(divRotina);';
	exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$mtdErro,false);
	}  

echo "var reccraws = '{$reccraws}';";
echo "var flgsegur = '{$flgsegur}';";
