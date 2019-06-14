<?php 

	//*********************************************************************************//
	//*** Fonte: cancela_senha_acesso.php											***//
	//*** Autor: David																***//
	//*** Data : Junho/2008                   �ltima Altera��o: 22/04/2010			***//
	//***																			***//
	//*** Objetivo  : Cancelar Senha de Acesso ao InternetBank - Rotina de			***//
	//***             Internet da tela ATENDA										***//
	//***																			***//	 
	//*** Altera��es: 22/04/2010 - Mostrar mensagem de aviso se existirem			***// 
	//***                          agendamentos pendentes (David).					***//
	//***																			***//	 
	//***			  26/07/2016 - Corrigi o tratamento do retorno XML. SD 479874   ***//	 
	//***						   (Carlos R.)										***//
	//***																			***//
	//*********************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"X")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"]) || !isset($_POST["inconfir"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];
	$inconfir = $_POST["inconfir"];
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se sequ�ncia de titular � um inteiro v�lido
	if (!validaInteiro($idseqttl)) {
		exibeErro("Sequ&ecirc;ncia de titular inv&aacute;lida.");
	}	
	
	// Verifica se indicador de confirma��o � um inteiro v�lido
	if (!validaInteiro($inconfir)) {
		exibeErro("Indicador de confirma&ccedil;&atilde;o inv&aacute;lido.");
	}	
		
	// Monta o xml de requisi��o
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
	
	// Se ocorrer um erro, mostra cr�tica
	if (isset($xmlObjCancelar->roottag->tags[0]->name) && strtoupper($xmlObjCancelar->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCancelar->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Mostra se BO retornar mensagem de confirma��o
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
	
	// Procura �ndice da op��o "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	// Se o �ndice da op��o "@" foi encontrado 
	if (!($idPrincipal === false)) {
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',"'.$glbvars["opcoesTela"][$idPrincipal].'");';
	}	
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgError) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgError.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
	// Fun��o para mostrar mensagem de confirma��o retornada pela BO
	function exibeConfirmacao($aux_inconfir,$msgConfirmacao) {
		echo 'hideMsgAguardo();';
		echo 'showConfirmacao("'.$msgConfirmacao.'","Confirma&ccedil;&atilde;o - Aimaro","cancelaSenhaAcesso('.($aux_inconfir + 1).')","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
		exit();	
	}	
	
?>