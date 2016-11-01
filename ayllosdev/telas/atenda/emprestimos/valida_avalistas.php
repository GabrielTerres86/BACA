<? 
/*!
 * FONTE        : valida_avalistas.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 10/03/2011 
 * OBJETIVO     : Verificas conta e traz dados do associados.
 *
 * 000: [15/07/2014] Incluso novos parametros inpessoa e dtnascto (Daniel).
 */
?>
 
<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();		
	
	// Guardo os parâmetos do POST em variáveis	
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	$qtpreemp = (isset($_POST['qtpreemp'])) ? $_POST['qtpreemp'] : '';
	$qtpromis = (isset($_POST['qtpromis'])) ? $_POST['qtpromis'] : '';
	$nrcpfav1 = (isset($_POST['nrcpfav1'])) ? $_POST['nrcpfav1'] : '';
	$idavalis = (isset($_POST['idavalis'])) ? $_POST['idavalis'] : '';
	$nmdavali = (isset($_POST['nmdavali'])) ? $_POST['nmdavali'] : '';
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '';
	$nrctaava = (isset($_POST['nrctaava'])) ? $_POST['nrctaava'] : '';
	$nrctaav1 = (isset($_POST['nrctaav1'])) ? $_POST['nrctaav1'] : '';
	$nrcpfcjg = (isset($_POST['nrcpfcjg'])) ? $_POST['nrcpfcjg'] : '';
	$dsendre1 = (isset($_POST['dsendre1'])) ? $_POST['dsendre1'] : '';
	$cdufresd = (isset($_POST['cdufresd'])) ? $_POST['cdufresd'] : '';
	$nrcepend = (isset($_POST['nrcepend'])) ? $_POST['nrcepend'] : '';
	$nomeform = (isset($_POST['nomeform'])) ? $_POST['nomeform'] : '';
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '';
	$dtnascto = (isset($_POST['dtnascto'])) ? $_POST['dtnascto'] : '';
	$cddopcao = 'A';
		
	// Monta o xml de requisição
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0002.p</Bo>";
	$xml .= "		<Proc>valida-avalistas</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";		
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "		<qtpreemp>".$qtpreemp."</qtpreemp>";
	$xml .= "		<qtpromis>".$qtpromis."</qtpromis>";
	$xml .= "		<nrcpfav1>".$nrcpfav1."</nrcpfav1>";
	$xml .= "		<idavalis>".$idavalis."</idavalis>";
	$xml .= "		<nrctaava>".$nrctaava."</nrctaava>";
	$xml .= "		<nrctaav1>".$nrctaav1."</nrctaav1>";
	$xml .= "		<nmdavali>".$nmdavali."</nmdavali>";
	$xml .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xml .= "		<nrcpfcjg>".$nrcpfcjg."</nrcpfcjg>";
	$xml .= "		<dsendre1>".$dsendre1."</dsendre1>";
	$xml .= "		<cdufresd>".$cdufresd."</cdufresd>";
	$xml .= "		<nrcepend>".$nrcepend."</nrcepend>";
	$xml .= "		<inpessoa>".$inpessoa."</inpessoa>";
	$xml .= "		<dtnascto>".$dtnascto."</dtnascto>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	$nomeCampo = $xmlObj->roottag->tags[0]->attributes['NMDCAMPO'];
	
	if ( $nomeCampo != '' ) {
		$mtdErro = 'focaCampoErro(\''.$nomeCampo.'\',\''.$nomeform.'\');bloqueiaFundo(divRotina);';
	} else {
		$mtdErro = 'bloqueiaFundo(divRotina);';
	}
		
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error', $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$mtdErro,false);
	}
		
?>