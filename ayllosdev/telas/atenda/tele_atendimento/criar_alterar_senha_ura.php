<?php 

	//*************************************************************************//
	//*** Fonte: criar_alterar_senha_ura.php								***//
	//*** Autor: David														***//
	//*** Data : Fevereiro/2008 											***//
	//*** Ultima Alteracao: 26/07/2016 										***//
	//***																	***//
	//*** Objetivo  : Cadastrar e Alterar senha do Tele Atendimento			***//
	//***																	***//	 
	//*** Alteracoes: 18/11/2013 Adequação para a chamada da procedure		***//
	//*** 	Cria_senha_ura validando se a senha ja existia ou não, pois o	***//
	//***	XML de requisição é o mesmo 									***//
	//***																	***//
	//***		18/11/2013 - Alteração no nome e no objetivo do arquivo		***// 
	//***																	***//	
	//***		30/01/2014 - Movida validacao de acesso a opcao para o 		***//
	//***					 fonte valida_senha_ura.php. (Reinert)			***//
	//***																	***//
	//***		26/07/2016 - Corrigi o retorno XML. SD 479874 (Carlos R.)   ***//
	//*************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
		
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["cddsenha"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = ( isset($_POST["nrdconta"]) ) ? $_POST["nrdconta"] : null;
	$cddsenha = ( isset($_POST["cddsenha"]) ) ? $_POST["cddsenha"] : null;
	$exisenha = ( isset($_POST["exisenha"]) ) ? $_POST["exisenha"] : null;
	
	// verifica se a senha ja existe e chama a procedure para criação ou alteração da senha
	$procedure = ($exisenha) ? "altera_senha_ura" : "cria_senha_ura";
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se senha &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($cddsenha)) {
		exibeErro("Senha incorreta.");
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetSenhaURA  = "";
	$xmlSetSenhaURA .= "<Root>";
	$xmlSetSenhaURA .= "	<Cabecalho>";
	$xmlSetSenhaURA .= "		<Bo>b1wgen0015.p</Bo>";
	$xmlSetSenhaURA .= "		<Proc>{$procedure}</Proc>";
	$xmlSetSenhaURA .= "	</Cabecalho>";
	$xmlSetSenhaURA .= "	<Dados>";
	$xmlSetSenhaURA .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetSenhaURA .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetSenhaURA .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetSenhaURA .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetSenhaURA .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetSenhaURA .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSetSenhaURA .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetSenhaURA .= "		<idseqttl>1</idseqttl>";
	$xmlSetSenhaURA .= "		<cddsenha>".$cddsenha."</cddsenha>";
	$xmlSetSenhaURA .= "	</Dados>";
	$xmlSetSenhaURA .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetSenhaURA);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjSenhaURA = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjSenhaURA->roottag->tags[0]->name) && strtoupper($xmlObjSenhaURA->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjSenhaURA->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	
	// Retornar a tela principal da rotina
	echo 'retornarOpcaoPrincipal();';
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
	
?>