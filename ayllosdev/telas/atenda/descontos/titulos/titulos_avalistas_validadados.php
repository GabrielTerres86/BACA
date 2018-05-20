<?
/*!
 * FONTE        : titulos_avalistas_validadados.php
 * CRIA��O      : Guilherme (CECRED)
 * DATA CRIA��O : Janeiro/2009
 * OBJETIVO     : Validar Dados de Avalistas
 * --------------
 * ALTERA��ES   :
 * --------------
 * 000: [10/06/2010] David          (CECRED) : Adapta��o para RATING
 * 001: [04/05/2011] Rodolpho Telmo (DB1) : Adapta��o formul�rio gen�rico avalistas e endere�o
 * 002: [28/03/2018] Andre Avila    (GFT) : Altera��o de mensagem para op��o A [Altera��o].
 */
?> 
 
<?	
	session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');		
	require_once('../../../../includes/controla_secao.php');
	require_once('../../../../class/xmlfile.php');		
	isPostMethod();	 
	
	// Verifica se os par�metros necess�rios foram informados
	$params = array('nrdconta','nrctaav1','nmdaval1','nrcpfav1','cpfcjav1','ende1av1',
	                'nrctaav2','nmdaval2','nrcpfav2','cpfcjav2','ende1av2','redirect','cddopcao');

	foreach ($params as $nomeParam) {
		if (!in_array($nomeParam,array_keys($_POST))) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	}
	$tipo = (isset($_POST['tipo'])) ? $_POST['tipo'] : "CONTRATO";
	$nrdconta = $_POST['nrdconta'];
	$nrctaav1 = $_POST['nrctaav1'];
	$nmdaval1 = $_POST['nmdaval1'];
	$nrcpfav1 = $_POST['nrcpfav1'];
	$cpfcjav1 = $_POST['cpfcjav1'];
	$ende1av1 = $_POST['ende1av1'];
	$nrcepav1 = $_POST['nrcepav1'];
	$nrctaav2 = $_POST['nrctaav2'];
	$nmdaval2 = $_POST['nmdaval2'];
	$nrcpfav2 = $_POST['nrcpfav2'];
	$cpfcjav2 = $_POST['cpfcjav2'];
	$ende1av2 = $_POST['ende1av2'];
	$nrcepav2 = $_POST['nrcepav2'];
	$cddopcao = $_POST['cddopcao'];

	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	// Verifica se n�mero da conta do 1� avalista � um inteiro v�lido
	if (!validaInteiro($nrctaav1)) exibirErro('error','Conta/dv do 1o Avalista inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	// Verifica se n�mero da conta do 2� avalista � um inteiro v�lido
	if (!validaInteiro($nrctaav2)) exibirErro('error','Conta/dv do 2o Avalista inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	// Verifica se CPF do 1� avalista � um inteiro v�lido
	if (!validaInteiro($nrcpfav1)) exibirErro('error','CPF do 1o Avalista inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	// Verifica se CPF do Conjug� do 1� avalista � um inteiro v�lido
	if (!validaInteiro($cpfcjav1)) exibirErro('error','CPF do Conjug&ecirc; do 1o Avalista inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);

	// Verifica se CPF do 2� avalista � um inteiro v�lido
	if (!validaInteiro($nrcpfav2)) exibirErro('error','CPF do 2o Avalista inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);

	// Verifica se CPF do Conjug� do 2� avalista � um inteiro v�lido
	if (!validaInteiro($cpfcjav2)) exibirErro('error','CPF do Conjug&ecirc; do 2o Avalista inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	// Monta o xml de requisi��o
	$xmlValidaAvalista  = "";
	$xmlValidaAvalista .= "<Root>";
	$xmlValidaAvalista .= "	<Cabecalho>";
	$xmlValidaAvalista .= "		<Bo>b1wgen0019.p</Bo>";
	$xmlValidaAvalista .= "		<Proc>valida-dados-avalistas</Proc>";
	$xmlValidaAvalista .= "	</Cabecalho>";
	$xmlValidaAvalista .= "	<Dados>";
	$xmlValidaAvalista .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlValidaAvalista .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlValidaAvalista .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlValidaAvalista .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlValidaAvalista .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlValidaAvalista .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlValidaAvalista .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlValidaAvalista .= "		<idseqttl>1</idseqttl>";
	$xmlValidaAvalista .= "		<nrctaav1>".$nrctaav1."</nrctaav1>";
	$xmlValidaAvalista .= "		<nmdaval1>".$nmdaval1."</nmdaval1>";
	$xmlValidaAvalista .= "		<nrcpfav1>".$nrcpfav1."</nrcpfav1>";
	$xmlValidaAvalista .= "		<cpfcjav1>".$cpfcjav1."</cpfcjav1>";
	$xmlValidaAvalista .= "		<ende1av1>".$ende1av1."</ende1av1>";
	$xmlValidaAvalista .= "		<nrcepav1>".$nrcepav1."</nrcepav1>";
	$xmlValidaAvalista .= "		<nrctaav2>".$nrctaav2."</nrctaav2>";
	$xmlValidaAvalista .= "		<nmdaval2>".$nmdaval2."</nmdaval2>";
	$xmlValidaAvalista .= "		<nrcpfav2>".$nrcpfav2."</nrcpfav2>";
	$xmlValidaAvalista .= "		<cpfcjav2>".$cpfcjav2."</cpfcjav2>";
	$xmlValidaAvalista .= "		<ende1av2>".$ende1av2."</ende1av2>";
	$xmlValidaAvalista .= "		<nrcepav2>".$nrcepav2."</nrcepav2>";
	$xmlValidaAvalista .= "	</Dados>";
	$xmlValidaAvalista .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlValidaAvalista);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAvalista = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjAvalista->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjAvalista->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	} 
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'bloqueiaFundo(divRotina);';
	
	if ($cddopcao == "I") { // Incluir
		echo 'validaNrContrato(\''.$tipo.'\');';
	}elseif ($cddopcao == "A") { // Alterar
		//echo 'showConfirmacao("Deseja alterar os dados do limite de desconto de t&iacute;tulos?","Confirma&ccedil;&atilde;o - Ayllos","gravaLimiteDscTit(\'A\')","bloqueiaFundo(divRotina);","sim.gif","nao.gif");';
		echo 'showConfirmacao("Deseja alterar os dados da Proposta?","Confirma&ccedil;&atilde;o - Ayllos","gravaLimiteDscTit(\'A\', \''.$tipo.'\')","bloqueiaFundo(divRotina);","sim.gif","nao.gif");';
	}
?>
