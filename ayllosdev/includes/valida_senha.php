<?php 

	//************************************************************************//
	//*** Fonte: valida_senha.php                                          ***//
	//*** Autor: David                                                     ***//
	//*** Data : Outubro/2008               �ltima Altera��o: 10/05/2018   ***//
	//***                                                                  ***//
	//*** Objetivo  : Validar senha de Operador/Coordenador/Gerente para   ***//
	//***             libera��o da opera��o                                ***//
	//***                                                                  ***//	 
	//*** Altera��es: 15/10/2010 - Focar campo cdopelib quando houver um   ***//
	//***                          erro retornado (David).                 ***//
	//***                                                                  ***//
	//***             22/10/2010 - Incluir novo parametro para a funcao    ***//
	//***                          getDataXML (David).                     ***//
	//***                                                                  ***//
	//***             10/05/2018 - Salvar o usu�rio que autorizou a    	   ***//
	//***                          libera��o na sess�o (SM404).            ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("config.php");
	require_once("funcoes.php");		
	require_once("controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../class/xmlfile.php");	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nvopelib"]) || !isset($_POST["cdopelib"]) || !isset($_POST["cddsenha"]) || !isset($_POST["nmfuncao"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nvopelib = $_POST["nvopelib"];
	$cdopelib = $_POST["cdopelib"];
	$cddsenha = $_POST["cddsenha"];
	$nmfuncao = $_POST["nmfuncao"];
	
	// Monta o xml de requisi��o
	$xmlSenha  = "";
	$xmlSenha .= "<Root>";
	$xmlSenha .= "	<Cabecalho>";
	$xmlSenha .= "		<Bo>b1wgen0000.p</Bo>";
	$xmlSenha .= "		<Proc>valida-senha-coordenador</Proc>";
	$xmlSenha .= "	</Cabecalho>";
	$xmlSenha .= "	<Dados>";
	$xmlSenha .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSenha .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSenha .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSenha .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSenha .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSenha .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlSenha .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSenha .= "		<idseqttl>1</idseqttl>";
	$xmlSenha .= "		<nvopelib>".$nvopelib."</nvopelib>";
	$xmlSenha .= "		<cdopelib>".$cdopelib."</cdopelib>";
	$xmlSenha .= "		<cddsenha>".$cddsenha."</cddsenha>";
	$xmlSenha .= "		<flgerlog>yes</flgerlog>";
	$xmlSenha .= "	</Dados>";
	$xmlSenha .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSenha,false);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjSenha = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjSenha->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjSenha->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}else{
		$_SESSION['cdopelib'] = $cdopelib;
	}		
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo '$("#divUsoGenerico").html("");';
	echo '$("#divUsoGenerico").css("visibility","hidden");';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Chamada da fun��o principal da rotina
	echo $nmfuncao;
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","$(\'#cdopelib\',\'#frmSenhaCoordenador\').focus();blockBackground(parseInt($(\'#divUsoGenerico\').css(\'z-index\')))");';
		exit();
	}
	
?>