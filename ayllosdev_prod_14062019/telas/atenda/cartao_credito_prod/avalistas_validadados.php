<?
/*!
 * FONTE        : avalistas_validadados.php
 * CRIAÇÃO      : Guilherme (CECRED)
 * DATA CRIAÇÃO : Março/2008
 * OBJETIVO     : Validar Dados de Avalistas - rotina de Cartão de Crédito da tela ATENDA
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 000: [04/09/2008] David          (CECRED) : Adaptação para solicitação de 2 via de senha de cartão de crédito
 * 000: [01/11/2010] David          (CECRED) : Adaptação para Cartão PJ
 * 001: [04/05/2011] Rodolpho Telmo    (DB1) : Adaptação formulário genérico avalistas e endereço
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
	                'nrctaav2','nmdaval2','nrcpfav2','cpfcjav2','ende1av2','redirect','tipoacao');

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
	$tipoacao = $_POST['tipoacao'];

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
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjAvalista->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjAvalista->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	} 
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'bloqueiaFundo(divRotina);';

	if ($tipoacao == 1) {
		echo 'showConfirmacao("Deseja cadastrar o novo limite de cr&eacute;dito do cart&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","alteraLimCre()","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
	} elseif ($tipoacao == 2) {
		echo 'showConfirmacao("Deseja cadastrar entrega de segunda via do cr&eacute;dito do cart&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","efetuaEntrega2viaCartao()","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
	} elseif ($tipoacao == 3) {
		echo 'showConfirmacao("Deseja renovar o cart&atilde;o de cr&eacute;dito?","Confirma&ccedil;&atilde;o - Aimaro","efetuaRenovacaoCartao()","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
	} elseif ($tipoacao == 4) {
	 	echo 'showConfirmacao("Deseja cadastrar a proposta de novo cart&atilde;o de cr&eacute;dito?","Confirma&ccedil;&atilde;o - Aimaro","cadastrarNovoCartao()","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
	} elseif ($tipoacao == 5) {
	 	echo 'showConfirmacao("Deseja gravar os dados de habilita&ccedil;&atilde;o para cart&atilde;o de cr&eacute;dito?","Confirma&ccedil;&atilde;o - Aimaro","gravarDadosHabilitacao()","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
	} else {
		exibirErro('error','Tipo de a&ccedil;&atilde;o inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	}
?>