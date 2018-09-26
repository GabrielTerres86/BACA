<?
/*!
 * FONTE        : validar_dados_avalistas.php
 * CRIAÇÃO      : David (CECRED)
 * DATA CRIAÇÃO : Junho/2008
 * OBJETIVO     : Validar Dados de Avalistas - rotina de Limite de Crédito da tela ATENDA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [04/05/2011] Rodolpho Telmo    (DB1) : Adaptação formulário genérico avalistas e endereço
 * 002: [09/01/2015] Tiago          (CECRED) : Acao de altercao da proposta (Melhoria Gielow)
 * 003: [08/06/2015] Gabriel           (RKAM): Cancelar proposta quando operador nao confirmar a alteracao.
 */
?> 

<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');		
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');		
	isPostMethod();	
	
	// Verifica se os parâmetros necessários foram informados
	$params = array('nrdconta','nrctaav1','nmdaval1','nrcpfav1','cpfcjav1','ende1av1',
	                'nrctaav2','nmdaval2','nrcpfav2','cpfcjav2','ende1av2', 'flgpropo', 'redirect');

	foreach ($params as $nomeParam) {
		if (!in_array($nomeParam,array_keys($_POST))) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);			
	}

	$nrdconta = $_POST['nrdconta'];
	$nrctaav1 = $_POST['nrctaav1'];
	$nmdaval1 = $_POST['nmdaval1'];
	$nrcpfav1 = $_POST['nrcpfav1'];
	$cpfcjav1 = $_POST['cpfcjav1'];
	$nrcepav1 = $_POST['nrcepav1'];	
	$ende1av1 = $_POST['ende1av1'];
	$nrctaav2 = $_POST['nrctaav2'];
	$nmdaval2 = $_POST['nmdaval2'];
	$nrcpfav2 = $_POST['nrcpfav2'];
	$cpfcjav2 = $_POST['cpfcjav2'];
	$nrcepav2 = $_POST['nrcepav2'];	
	$ende1av2 = $_POST['ende1av2'];
	$flgpropo = $_POST['flgpropo'];
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Verifica se número da conta do 1° avalista é um inteiro válido
	if (!validaInteiro($nrctaav1)) exibirErro('error','Conta/dv do 1o Avalista inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Verifica se número da conta do 2° avalista é um inteiro válido
	if (!validaInteiro($nrctaav2)) exibirErro('error','Conta/dv do 2o Avalista inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Verifica se CPF do 1° avalista é um inteiro válido
	if (!validaInteiro($nrcpfav1)) exibirErro('error','CPF do 1o Avalista inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Verifica se CPF do Conjugê do 1° avalista é um inteiro válido
	if (!validaInteiro($cpfcjav1)) exibirErro('error','CPF do Conjug&ecirc; do 1o Avalista inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);

	// Verifica se CPF do 2° avalista é um inteiro válido
	if (!validaInteiro($nrcpfav2)) exibirErro('error','CPF do 2o Avalista inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);

	// Verifica se CPF do Conjugê do 2° avalista é um inteiro válido
	if (!validaInteiro($cpfcjav2)) exibirErro('error','CPF do Conjug&ecirc; do 2o Avalista inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Monta o xml de requisição
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
	$xmlValidaAvalista .= "		<nrcepav1>".$nrcepav1."</nrcepav1>";
	$xmlValidaAvalista .= "		<ende1av1>".$ende1av1."</ende1av1>";
	$xmlValidaAvalista .= "		<nrctaav2>".$nrctaav2."</nrctaav2>";
	$xmlValidaAvalista .= "		<nmdaval2>".$nmdaval2."</nmdaval2>";
	$xmlValidaAvalista .= "		<nrcpfav2>".$nrcpfav2."</nrcpfav2>";
	$xmlValidaAvalista .= "		<cpfcjav2>".$cpfcjav2."</cpfcjav2>";
	$xmlValidaAvalista .= "		<nrcepav2>".$nrcepav2."</nrcepav2>";
	$xmlValidaAvalista .= "		<ende1av2>".$ende1av2."</ende1av2>";
	$xmlValidaAvalista .= "	</Dados>";
	$xmlValidaAvalista .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlValidaAvalista);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAvalista = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjAvalista->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjAvalista->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	} 
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'bloqueiaFundo(divRotina);';
	
	if($flgpropo){
		echo 'showConfirmacao("Deseja alterar o " + strTitRotinaLC + "?","Confirma&ccedil;&atilde;o - Aimaro","alterarNovoLimite();","acessaOpcaoAba(8,0,\'@\');","sim.gif","nao.gif");';
	}else{
		// Mostra mensagem para confirmar cadastro do novo limite de crédito
		echo 'showConfirmacao("Deseja cadastrar o novo " + strTitRotinaLC + "?","Confirma&ccedil;&atilde;o - Aimaro","cadastrarNovoLimite()","acessaOpcaoAba(8,0,\'@\');","sim.gif","nao.gif");';
	}	
?>