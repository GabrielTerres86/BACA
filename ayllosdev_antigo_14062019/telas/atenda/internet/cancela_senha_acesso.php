<?php 

	//*********************************************************************************//
	//*** Fonte: cancela_senha_acesso.php											***//
	//*** Autor: David																***//
	//*** Data : Junho/2008                   Última Alteração: 22/04/2010			***//
	//***																			***//
	//*** Objetivo  : Cancelar Senha de Acesso ao InternetBank - Rotina de			***//
	//***             Internet da tela ATENDA										***//
	//***																			***//	 
	//*** Alterações: 22/04/2010 - Mostrar mensagem de aviso se existirem			***// 
	//***                          agendamentos pendentes (David).					***//
	//***																			***//	 
	//***			  26/07/2016 - Corrigi o tratamento do retorno XML. SD 479874   ***//	 
	//***						   (Carlos R.)										***//
	//***																			***//
	//*********************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"X")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"]) || !isset($_POST["inconfir"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];
	$inconfir = $_POST["inconfir"];
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se sequência de titular é um inteiro válido
	if (!validaInteiro($idseqttl)) {
		exibeErro("Sequ&ecirc;ncia de titular inv&aacute;lida.");
	}	
	
	// Verifica se indicador de confirmação é um inteiro válido
	if (!validaInteiro($inconfir)) {
		exibeErro("Indicador de confirma&ccedil;&atilde;o inv&aacute;lido.");
	}	
		
	// Monta o xml de requisição
	$xmlSetCancelar  = "";
	$xmlSetCancelar .= "<Root>";
	$xmlSetCancelar .= "	<Cabecalho>";
	$xmlSetCancelar .= "		<Bo>b1wgen0015.p</Bo>";
	$xmlSetCancelar .= "		<Proc>cancelar-senha-internet</Proc>";
	$xmlSetCancelar .= "	</Cabecalho>";
	$xmlSetCancelar .= "	<Dados>";
	$xmlSetCancelar .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCancelar .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetCancelar .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCancelar .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCancelar .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetCancelar .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSetCancelar .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCancelar .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xmlSetCancelar .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetCancelar .= "		<inconfir>".$inconfir."</inconfir>";
	$xmlSetCancelar .= "	</Dados>";
	$xmlSetCancelar .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCancelar);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjCancelar = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjCancelar->roottag->tags[0]->name) && strtoupper($xmlObjCancelar->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCancelar->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Mostra se BO retornar mensagem de confirmação
	if (isset($xmlObjCancelar->roottag->tags[0]->name) && strtoupper($xmlObjCancelar->roottag->tags[0]->name) == "CONFIRMACAO") {
		$confirma = $xmlObjCancelar->roottag->tags[0]->tags[0]->tags;	

		if ($confirma[0]->cdata == 1) {
			echo 'hideMsgAguardo();';
			echo 'showError("inform","'.$confirma[1]->cdata.'","Notifica&ccedil;&atilde;o - Aimaro","cancelaSenhaAcesso('.($confirma[0]->cdata + 1).')");';
			
			exit();
		} else {					
			exibeConfirmacao($confirma[0]->cdata,$confirma[1]->cdata);			
		}
	}		
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Procura índice da opção "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	// Se o índice da opção "@" foi encontrado 
	if (!($idPrincipal === false)) {
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',"'.$glbvars["opcoesTela"][$idPrincipal].'");';
	}	
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgError) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgError.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
	// Função para mostrar mensagem de confirmação retornada pela BO
	function exibeConfirmacao($aux_inconfir,$msgConfirmacao) {
		echo 'hideMsgAguardo();';
		echo 'showConfirmacao("'.$msgConfirmacao.'","Confirma&ccedil;&atilde;o - Aimaro","cancelaSenhaAcesso('.($aux_inconfir + 1).')","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
		exit();	
	}	
	
?>