<?php 

	//************************************************************************//
	//*** Fonte: valida_senha.php                                          ***//
	//*** Autor: David                                                     ***//
	//*** Data : Outubro/2008               Última Alteração: 10/05/2018   ***//
	//***                                                                  ***//
	//*** Objetivo  : Validar senha de Operador/Coordenador/Gerente para   ***//
	//***             liberação da operação                                ***//
	//***                                                                  ***//	 
	//*** Alterações: 15/10/2010 - Focar campo cdopelib quando houver um   ***//
	//***                          erro retornado (David).                 ***//
	//***                                                                  ***//
	//***             22/10/2010 - Incluir novo parametro para a funcao    ***//
	//***                          getDataXML (David).                     ***//
	//***                                                                  ***//
	//***             10/05/2018 - Salvar o usuário que autorizou a    	   ***//
	//***                          liberação na sessão (SM404).            ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("config.php");
	require_once("funcoes.php");		
	require_once("controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../class/xmlfile.php");	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nvopelib"]) || !isset($_POST["cdopelib"]) || !isset($_POST["cddsenha"]) || !isset($_POST["nmfuncao"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nvopelib = $_POST["nvopelib"];
	$cdopelib = $_POST["cdopelib"];
	$cddsenha = $_POST["cddsenha"];
	$nmfuncao = $_POST["nmfuncao"];
	
	$cddsenha = mb_convert_encoding(urldecode($cddsenha), "Windows-1252", "UTF-8");
	
	/*
	// Monta o xml de requisição
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
	*/
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '       <idseqttl>1</idseqttl>';
	$xml .= '       <nvoperad>'.$nvopelib.'</nvoperad>';
	$xml .= '		<operador>'.$cdopelib.'</operador>';	
	$xml .= '		<nrdsenha><![CDATA['.$cddsenha.']]></nrdsenha>';
	$xml .= '		<flgerlog>1</flgerlog>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "CADSCR", "VALIDASENHACOORD", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}else{
		$_SESSION['cdopelib'] = $cdopelib;
	} 	
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo '$("#divUsoGenerico").html("");';
	echo '$("#divUsoGenerico").css("visibility","hidden");';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Chamada da função principal da rotina
	echo $nmfuncao;
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","$(\'#cdopelib\',\'#frmSenhaCoordenador\').focus();blockBackground(parseInt($(\'#divUsoGenerico\').css(\'z-index\')))");';
		exit();
	}
	
?>