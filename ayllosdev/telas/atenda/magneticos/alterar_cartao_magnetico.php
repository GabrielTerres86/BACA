<?php 

	//*****************************************************************************************//
	//*** Fonte: alterar_cartao_magnetico.php                              					***//
	//*** Autor: David                                                     					***//
	//*** Data : Outubro/2008                							   					***//
	//***                                                                  					***//
	//*** Objetivo  : Alterar solicita&ccedil;&atilde;o do Cart&atilde;o Magn&eacute;tico   ***//
	//***                                                                  					***//	 
	//*** Alterações: 04/06/2009 - Permitir selecionar titular quando for  					***//
	//***                          op&ccedil;&atilde;o "Alterar" (David)   					***//
	//***                                                                  					***//
	//***             23/07/2015 - Remover os campos Limite, Forma de Saque e Recibo		***//
	//***		   				   de entrega. (James)										***//
	//*****************************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrcartao"]) || !isset($_POST["tpusucar"]) || !isset($_POST["nmtitcrd"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrcartao = $_POST["nrcartao"];
	$tpusucar = $_POST["tpusucar"];
	$nmtitcrd = $_POST["nmtitcrd"];
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o n&uacute;mero do cart&atilde;o &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcartao)) {
		exibeErro("N&uacute;mero do cart&atilde;o inv&aacute;lido.");
	}
	
	// Verifica se o identificador do titular &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($tpusucar)) {
		exibeErro("Titular inv&aacute;lido.");
	}	
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlDadosAlteracao  = "";
	$xmlDadosAlteracao .= "<Root>";
	$xmlDadosAlteracao .= "	<Cabecalho>";
	$xmlDadosAlteracao .= "		<Bo>b1wgen0032.p</Bo>";
	$xmlDadosAlteracao .= "		<Proc>alterar-cartao-magnetico</Proc>";
	$xmlDadosAlteracao .= "	</Cabecalho>";
	$xmlDadosAlteracao .= "	<Dados>";
	$xmlDadosAlteracao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlDadosAlteracao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlDadosAlteracao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlDadosAlteracao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlDadosAlteracao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlDadosAlteracao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlDadosAlteracao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlDadosAlteracao .= "		<idseqttl>1</idseqttl>";
	$xmlDadosAlteracao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlDadosAlteracao .= "		<nrcartao>".$nrcartao."</nrcartao>";
	$xmlDadosAlteracao .= "		<tpusucar>".$tpusucar."</tpusucar>";
	$xmlDadosAlteracao .= "		<nmtitcrd>".$nmtitcrd."</nmtitcrd>";	
	$xmlDadosAlteracao .= "		<flgerlog>YES</flgerlog>";
	$xmlDadosAlteracao .= "	</Dados>";
	$xmlDadosAlteracao .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlDadosAlteracao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAlteracao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjAlteracao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjAlteracao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Procura ind&iacute;ce da op&ccedil;&atilde;o "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	// Se o &iacute;ndice da op&ccedil;&atilde;o "@" foi encontrado 
	if (!($idPrincipal === false)) {
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',"'.$glbvars["opcoesTela"][$idPrincipal].'");';
	}	else {
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,"'.$glbvars["opcoesTela"][0].'");';
	}	
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>