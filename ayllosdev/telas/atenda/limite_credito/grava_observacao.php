<?
/*!
 * FONTE        : grava_observacoes.php
 * CRIAÇÃO      : Jonata (RKAM)
 * DATA CRIAÇÃO : Julho/2014
 * OBJETIVO     : Gravar a observacao da proposta
 * --------------
 * ALTERAÇÕES   : 08/07/2015 - Remoção de acentuação do campo de observação
 *							  (Lunelli - SD SD 300819 | 300893) 
 *
 *				  22/12/2015 - Removido alert (Lucas Lunelli)
 * --------------
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
	$params = array('nrdconta','nrctrlim','dsobserv');

	foreach ($params as $nomeParam) {
		if (!in_array($nomeParam,array_keys($_POST))) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);			
	}

	$nrdconta = $_POST['nrdconta'];
	$nrctrlim = $_POST['nrctrlim'];
	$dsobserv = $_POST['dsobserv'];
	
	$dsobserv = utf8_decode($dsobserv);
	$dsobserv = removeCaracteresInvalidos($dsobserv);
	$dsobserv = retiraAcentos($dsobserv);
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Verifica se o contrato é valido
	if (!validaInteiro($nrctrlim)) exibirErro('error','Contrato inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Monta o xml de requisição
	$xmlGravaObservacoes  = "";
	$xmlGravaObservacoes .= "<Root>";
	$xmlGravaObservacoes .= "	<Cabecalho>";
	$xmlGravaObservacoes .= "		<Bo>b1wgen0019.p</Bo>";
	$xmlGravaObservacoes .= "		<Proc>altera-observacao</Proc>";
	$xmlGravaObservacoes .= "	</Cabecalho>";
	$xmlGravaObservacoes .= "	<Dados>";
	$xmlGravaObservacoes .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGravaObservacoes .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGravaObservacoes .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGravaObservacoes .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGravaObservacoes .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGravaObservacoes .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGravaObservacoes .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGravaObservacoes .= "		<idseqttl>1</idseqttl>";
	$xmlGravaObservacoes .= "		<nrctrlim>".$nrctrlim."</nrctrlim>";
	$xmlGravaObservacoes .= "		<dsobserv>".$dsobserv."</dsobserv>";
	$xmlGravaObservacoes .= "	</Dados>";
	$xmlGravaObservacoes .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGravaObservacoes);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAvalista = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjAvalista->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjAvalista->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	} 
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
    echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
    echo 'escondeObservacoes();';
	echo '$("#dsobserv","#frmDadosLimiteCredito").val("' . $dsobserv . '");';
	
?>