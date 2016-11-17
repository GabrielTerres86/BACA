<?php 

	/************************************************************************
	 Fonte: cheques_limite_incluir_validaeconfirma.php
	 Autor: Guilherme                                                 
	 Data : Març/2009               Última Alteração:   /  / 
	                                                                  
	 Objetivo  : Validar número do contrato e confirma a inclusao
	                                                                  	 
	 Alterações:                                                      
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../../includes/config.php");
	require_once("../../../../includes/funcoes.php");
	require_once("../../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../../class/xmlfile.php");
	
	// Verifica se os parâmetros necessários foram informados
	$params = array("nrdconta","nrctrlim","antnrctr","nrctaav1","nrctaav2","redirect");

	foreach ($params as $nomeParam) {
		if (!in_array($nomeParam,array_keys($_POST))) {			
			exibeErro("Par&acirc;metros incorretos.");
		}	
	}				  
	
	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];
	$antnrctr = $_POST["antnrctr"];
	$nrctaav1 = $_POST["nrctaav1"];
	$nrctaav2 = $_POST["nrctaav2"];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Verifica se o do contrato é um inteiro válido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}
	
	// Verifica se o do contrato de validação é um inteiro válido
	if (!validaInteiro($antnrctr)) {
		exibeErro("N&uacute;mero do contrato de valida&ccedil;&atilde;o inv&aacute;lido.");
	}	
	
	// Verifica se número da conta do 1° avalista é um inteiro válido
	if (!validaInteiro($nrctaav1)) {
		exibeErro("Conta/dv do 1o Avalista inv&aacute;lida.");
	}
	
	// Verifica se número da conta do 2° avalista é um inteiro válido
	if (!validaInteiro($nrctaav2)) {
		exibeErro("Conta/dv do 2o Avalista inv&aacute;lida.");
	}	

	// Monta o xml de requisição
	$xmlGetDadosLimIncluir  = "";
	$xmlGetDadosLimIncluir .= "<Root>";
	$xmlGetDadosLimIncluir .= "	<Cabecalho>";
	$xmlGetDadosLimIncluir .= "		<Bo>b1wgen0009.p</Bo>";
	$xmlGetDadosLimIncluir .= "		<Proc>valida_nrctrato_avl</Proc>";
	$xmlGetDadosLimIncluir .= "	</Cabecalho>";
	$xmlGetDadosLimIncluir .= "	<Dados>";
	$xmlGetDadosLimIncluir .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDadosLimIncluir .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDadosLimIncluir .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDadosLimIncluir .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDadosLimIncluir .= "		<idseqttl>1</idseqttl>";	
	$xmlGetDadosLimIncluir .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDadosLimIncluir .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDadosLimIncluir .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetDadosLimIncluir .= "		<nrctrlim>".$nrctrlim."</nrctrlim>";
	$xmlGetDadosLimIncluir .= "		<antnrctr>".$antnrctr."</antnrctr>";
	$xmlGetDadosLimIncluir .= "		<nrctaav1>".$nrctaav1."</nrctaav1>";
	$xmlGetDadosLimIncluir .= "		<nrctaav2>".$nrctaav2."</nrctaav2>";
	$xmlGetDadosLimIncluir .= "	</Dados>";
	$xmlGetDadosLimIncluir .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDadosLimIncluir);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosLimIncluir = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDadosLimIncluir->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosLimIncluir->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	echo 'hideMsgAguardo();';
	echo 'showConfirmacao("Deseja incluir o limite de desconto de cheques?","Confirma&ccedil;&atilde;o - Ayllos","gravaLimiteDscChq(\'I\');","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
		
	
?>