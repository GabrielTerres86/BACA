<?php 

	/************************************************************************
	 Fonte: excluir_novo_plano.php                                    
	 Autor: David                                                     
	 Data : Outubro/2007                       Última alteração: 22/03/2017
	                                                                  
	 Objetivo  : Excluir Novo Plano de Capital - rotina de Capital da 
	             tela ATENDA                                          
	                                                                  
	 Alterações: 22/03/2017 - Ajuste para solicitar a senha do cooperado e não gerar o termo
                            para coleta da assinatura 
                           (Jonata - RKAM / M294).
						   
				 13/11/2018 - Ajuste para gravar o tipo de Autorizacao (Andrey Formigari - Mouts)
                           
                           
                           
                           
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"P")) <> "") {
		exibeErro($msgError);		
	}		
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$tpautori = $_POST["tpautori"];

	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlExcluirPlano  = "";
	$xmlExcluirPlano .= "<Root>";
	$xmlExcluirPlano .= "	<Cabecalho>";
	$xmlExcluirPlano .= "		<Bo>b1wgen0021.p</Bo>";
	$xmlExcluirPlano .= "		<Proc>cancelar-plano-atual</Proc>";
	$xmlExcluirPlano .= "	</Cabecalho>";
	$xmlExcluirPlano .= "	<Dados>";
	$xmlExcluirPlano .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlExcluirPlano .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlExcluirPlano .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlExcluirPlano .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlExcluirPlano .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlExcluirPlano .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlExcluirPlano .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlExcluirPlano .= "		<idseqttl>1</idseqttl>";
	$xmlExcluirPlano .= "		<tpautori>".$tpautori."</tpautori>";
	$xmlExcluirPlano .= "	</Dados>";
	$xmlExcluirPlano .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlExcluirPlano);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjExcluirPlano = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjExcluirPlano->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjExcluirPlano->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	
	// Procura ind&iacute;ce da op&ccedil;&atilde;o "P"
	$idPrincipal = array_search("P",$glbvars["opcoesTela"]);
	
	// Se &iacute;ndice da op&ccedil;&atilde;o "P" foi encontrado
	if (!($idPrincipal === false)) {
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',\''.$glbvars["opcoesTela"][$idPrincipal].'\');';	
	} else {
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,\''.$glbvars["opcoesTela"][0].'\');';	
	}
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
	
?>