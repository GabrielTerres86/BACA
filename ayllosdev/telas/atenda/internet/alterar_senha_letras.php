<?php 

	/***************************************************************************
	      Fonte: alterar_senha_letras.php                                  
	      Autor: Lucas Lunelli                                             
	      Data : Novembro/2012                Ultima Alteracao:  20/10/2015     
	                                                                  
	      Objetivo  : Alterar Senha Letras   							   
	                                                                  	 
	      Alteracoes:  20/10/2015 - Reformulacao cadastral (Gabriel-RKAM).                                                    
	****************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	
	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"H")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["idseqttl"]) ||  !isset($_POST["dssennov"]) || !isset($_POST["dssencon"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$dssennov = $_POST["dssennov"];
	$dssencon = $_POST["dssencon"];
	$idseqttl = $_POST["idseqttl"];
	$executandoProdutos = $_POST['executandoProdutos'];
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se a sequ&ecirc;ncia de titular &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idseqttl)) {
		exibeErro("Sequ&ecirc;ncia de titular inv&aacute;lida.");
	}	
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlSetSenha  = "";
	$xmlSetSenha .= "<Root>";
	$xmlSetSenha .= "	<Cabecalho>";
	$xmlSetSenha .= "		<Bo>b1wgen0032.p</Bo>";
	$xmlSetSenha .= "		<Proc>grava-senha-letras</Proc>";
	$xmlSetSenha .= "	</Cabecalho>";
	$xmlSetSenha .= "	<Dados>";
	$xmlSetSenha .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetSenha .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetSenha .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetSenha .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetSenha .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetSenha .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSetSenha .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetSenha .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetSenha .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xmlSetSenha .= "		<dssennov>".$dssennov."</dssennov>";
	$xmlSetSenha .= "		<dssencon>".$dssencon."</dssencon>";
	$xmlSetSenha .= "	</Dados>";
	$xmlSetSenha .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetSenha);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjSenha = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjSenha->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjSenha->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Procura ind&iacute;ce da op&ccedil;&atilde;o "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	$dsmensag = "Operacao efetuada com sucesso!";
	
	if ($executandoProdutos == 'true') {
		echo 'showError("inform","'.$dsmensag.'","Notifica&ccedil;&atilde;o - Ayllos","encerraRotina();");';
	} else {
		// Se o �ndice da op��o "@" foi encontrado 
		if (!($idPrincipal === false)) {
			echo 'showError("inform","'.$dsmensag.'","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));acessaOpcaoAba(\''.count($glbvars["opcoesTela"]).'\',\''.$idPrincipal.'\',\''.$glbvars["opcoesTela"][$idPrincipal].'\');");';
		
		}	else {
			echo 'showError("inform","'.$dsmensag.'","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));acessaOpcaoAba(\''.count($glbvars["opcoesTela"]).'\',0,\''.$glbvars["opcoesTela"][0].'\');");';
			
		}		
	}
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>