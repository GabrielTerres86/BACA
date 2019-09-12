<? 
/*!
 * FONTE        : valida_avalistas.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 10/03/2011 
 * OBJETIVO     : Verificas conta e traz dados do associados.
 *
 * 000: [15/07/2014] Incluso novos parametros inpessoa e dtnascto (Daniel).
 * 001: [08/05/2017] Incluso de validação para CPF/CNPJ de avalistas sem
 *				     sem conta. (Andrey Formigari - Mouts) SD: 644056
 */
?>
 
<?
	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');	
	require_once('../../../../class/xmlfile.php');
	isPostMethod();		
	
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
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
		
	/* Apenas validar CPF/CNPJ se o avalista não possuir conta.
	   Validação feita antes da chamada Progress para evitar requisições desnecessárias. 
	*/
	if ($nrcpfcgc && (!$nrctaava || !$nrctaav1)) {
		if ($inpessoa == 1)
			$isValidCpfOrCnpj = validar_cpf( str_pad($nrcpfcgc, 11, '0', STR_PAD_LEFT) );
		else if ($inpessoa == 2)
			$isValidCpfOrCnpj = validar_cnpj( str_pad($nrcpfcgc, 14, '0', STR_PAD_LEFT) );
		else
			$isValidCpfOrCnpj = false;
		
		if (!$isValidCpfOrCnpj){
			exibirErro('error', (($inpessoa==1) ? 'CPF' : 'CNPJ') . ' é inválido.','Alerta - Aimaro', 'focaCampoErro(\'nrcpfcgc\',\'' + $nomeform + '\');bloqueiaFundo(divRotina);', false);
			exit();
		}
	}
		
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
	$xml .= "		<idseqttl>1</idseqttl>";
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "		<qtpreemp>0</qtpreemp>";
	$xml .= "		<qtpromis>0</qtpromis>";
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
		exibirErro('error', $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$mtdErro,false);
	}
		
?>