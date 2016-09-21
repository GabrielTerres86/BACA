<?php 

	/************************************************************************
	 Fonte: titulos_bordero_excluir.php                               
	 Autor: Guilherme                                                 
	 Data : Novembro/2008                �ltima Altera��o: 00/00/0000 
	                                                                  
	 Objetivo  : Excluir um bordero de desconto de t�tulos            
	                                                                  	 
	 Altera��es:                                                      
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");		
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"E")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrborder"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrborder = $_POST["nrborder"];
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o n�mero do contrato � um inteiro v�lido
	if (!validaInteiro($nrborder)) {
		exibeErro("N&uacute;mero do border&ocirc; inv&aacute;lido.");
	}
	
	// Monta o xml de requisi��o
	$xmlExcluir  = "";
	$xmlExcluir .= "<Root>";
	$xmlExcluir .= "	<Cabecalho>";
	$xmlExcluir .= "		<Bo>b1wgen0030.p</Bo>";
	$xmlExcluir .= "		<Proc>efetua_exclusao_bordero</Proc>";
	$xmlExcluir .= "	</Cabecalho>";
	$xmlExcluir .= "	<Dados>";
	$xmlExcluir .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlExcluir .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlExcluir .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlExcluir .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlExcluir .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlExcluir .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlExcluir .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlExcluir .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xmlExcluir .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlExcluir .= "		<nrborder>".$nrborder."</nrborder>";
	$xmlExcluir .= "		<flgelote>1</flgelote>";
	$xmlExcluir .= "	</Dados>";
	$xmlExcluir .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlExcluir);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjExcluir = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjExcluir->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjExcluir->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Esconde mensagem de aguardo
	echo 'idLinhaB = 0;';
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	

	// Recarrega os bordero
	echo 'carregaBorderosTitulos();';
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>