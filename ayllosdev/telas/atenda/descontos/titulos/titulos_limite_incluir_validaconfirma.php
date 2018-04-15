<?php 

	/************************************************************************
	 Fonte: titulos_limite_incluir_validaconfirma.php
	 Autor: Guilherme                                                 
	 Data : Janeiro/2009                        �ltima Altera��o: 10/06/2010 
	                                                                  
	 Objetivo  : Validar n�mero do contrato e confirma a inclus�o
	                                                                  	 
	 Altera��es: 10/06/2010 - Adapta��o para RATNG (David).                                                     
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
	
	// Verifica se os par�metros necess�rios foram informados
	$params = array("nrdconta","nrctrlim","nrctaav1","nrctaav2","redirect");

	$tipo = (isset($_POST['tipo'])) ? $_POST['tipo'] : "CONTRATO";

	foreach ($params as $nomeParam) {
		if (!in_array($nomeParam,array_keys($_POST))) {			
			exibeErro("Par&acirc;metros incorretos.");
		}	
	}				  
	
	$nrdconta = $_POST["nrdconta"];
	$nrctrlim = $_POST["nrctrlim"];
	$nrctaav1 = $_POST["nrctaav1"];
	$nrctaav2 = $_POST["nrctaav2"];	

	// Verifica se o n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Verifica se o do contrato � um inteiro v�lido
	if (!validaInteiro($nrctrlim)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}	
	
	// Verifica se n�mero da conta do 1� avalista � um inteiro v�lido
	if (!validaInteiro($nrctaav1)) {
		exibeErro("Conta/dv do 1o Avalista inv&aacute;lida.");
	}
	
	// Verifica se n�mero da conta do 2� avalista � um inteiro v�lido
	if (!validaInteiro($nrctaav2)) {
		exibeErro("Conta/dv do 2o Avalista inv&aacute;lida.");
	}	

	// Monta o xml de requisi��o
	$xmlGetDadosLimIncluir  = "";
	$xmlGetDadosLimIncluir .= "<Root>";
	$xmlGetDadosLimIncluir .= "	<Cabecalho>";
	$xmlGetDadosLimIncluir .= "		<Bo>b1wgen0030.p</Bo>";
	$xmlGetDadosLimIncluir .= "		<Proc>valida_nrctrato_avl</Proc>";
	$xmlGetDadosLimIncluir .= "	</Cabecalho>";
	$xmlGetDadosLimIncluir .= "	<Dados>";
	$xmlGetDadosLimIncluir .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDadosLimIncluir .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDadosLimIncluir .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
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
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjDadosLimIncluir->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosLimIncluir->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	echo 'hideMsgAguardo();';
	echo 'showConfirmacao("Deseja incluir o limite de desconto de t&iacute;tulos?","Confirma&ccedil;&atilde;o - Ayllos","gravaLimiteDscTit(\'I\', \''.$tipo.'\');","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}		
	
?>