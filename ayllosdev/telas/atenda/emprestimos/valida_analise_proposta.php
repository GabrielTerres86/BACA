<? 
/*!
 * FONTE        : valida_analise_proposta
 * CRIAÇÃO      : Marcelo L. Pereira (GATI)
 * DATA CRIAÇÃO : 16/09/2011
 * OBJETIVO     : Verifica dados da análise 
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
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
		
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$dtcnsspc = (isset($_POST['dtcnsspc'])) ? $_POST['dtcnsspc'] : '';
	$nrinfcad = (isset($_POST['nrinfcad'])) ? $_POST['nrinfcad'] : '';
	$dtoutspc = (isset($_POST['dtoutspc'])) ? $_POST['dtoutspc'] : '';
	$dtdrisco = (isset($_POST['dtdrisco'])) ? $_POST['dtdrisco'] : '';
	$dtoutris = (isset($_POST['dtoutris'])) ? $_POST['dtoutris'] : '';
	$nrgarope = (isset($_POST['nrgarope'])) ? $_POST['nrgarope'] : '';
	$nrliquid = (isset($_POST['nrliquid'])) ? $_POST['nrliquid'] : '';
	$nrpatlvr = (isset($_POST['nrpatlvr'])) ? $_POST['nrpatlvr'] : '';
	$nrperger = (isset($_POST['nrperger'])) ? $_POST['nrperger'] : '';
	$nomeform = (isset($_POST['nomeform'])) ? $_POST['nomeform'] : '';
			
	// Monta o xml de requisição
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0002.p</Bo>";
	$xml .= "		<Proc>valida-analise-proposta</Proc>";
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
	$xml1 .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";		
	$xml1 .= "		<flgerlog>TRUE</flgerlog>";		
	$xml .= "		<dtcnsspc>".$dtcnsspc."</dtcnsspc>";
	$xml .= "		<nrinfcad>".$nrinfcad."</nrinfcad>";
	$xml .= "		<dtoutspc>".$dtoutspc."</dtoutspc>";
	$xml .= "		<dtdrisco>".$dtdrisco."</dtdrisco>";
	$xml .= "		<dtoutris>".$dtoutris."</dtoutris>";
	$xml .= "		<nrgarope>".$nrgarope."</nrgarope>";
	$xml .= "		<nrliquid>".$nrliquid."</nrliquid>";
	$xml .= "		<nrpatlvr>".$nrpatlvr."</nrpatlvr>";
	$xml .= "		<nrperger>".$nrperger."</nrperger>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	$nomeCampo = $xmlObj->roottag->tags[0]->attributes['NOMCAMPO'];
	
	if ( $nomeCampo != '' ) {
		$mtdErro = 'focaCampoErro(\''.$nomeCampo.'\',\''.$nomeform.'\');bloqueiaFundo(divRotina);';
	} else {
		$mtdErro = 'bloqueiaFundo(divRotina);';
	}
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$mtdErro,false);
	}
?>