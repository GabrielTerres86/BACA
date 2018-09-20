<?php 

	//************************************************************************//
	//*** Fonte: poupanca_consultar.php                                    ***//
	//*** Autor: David                                                     ***//
	//*** Data : Março/2010                   Última Alteração: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opção de consulta para Poupança Programada   ***//	
	//***                                                                  ***//	 
	//*** Alterações:                                                      ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibeErro($msgError);		
	}
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o contrato da poupança é um inteiro válido
	if (!validaInteiro($nrctrrpp)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}	
		
	// Monta o xml de requisição
	$xmlConsultar  = "";
	$xmlConsultar .= "<Root>";
	$xmlConsultar .= "	<Cabecalho>";
	$xmlConsultar .= "		<Bo>b1wgen0006.p</Bo>";
	$xmlConsultar .= "		<Proc>consulta-poupanca</Proc>";
	$xmlConsultar .= "	</Cabecalho>";
	$xmlConsultar .= "	<Dados>";
	$xmlConsultar .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlConsultar .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlConsultar .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlConsultar .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlConsultar .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlConsultar .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlConsultar .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlConsultar .= "		<idseqttl>1</idseqttl>";
	$xmlConsultar .= "		<nrctrrpp>".$nrctrrpp."</nrctrrpp>";
	$xmlConsultar .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlConsultar .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlConsultar .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlConsultar .= "		<cdprogra>".$glbvars["nmdatela"]."</cdprogra>";	
	$xmlConsultar .= "	</Dados>";
	$xmlConsultar .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlConsultar);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjConsultar = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjConsultar->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjConsultar->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$poupanca = $xmlObjConsultar->roottag->tags[0]->tags[0]->tags;	
	
	// Flags para montagem do formulário
	$flgAlterar   = false;
	$flgSuspender = false;	
	$legend 	  = "Consultar";
	
	include("poupanca_formulario_dados.php");
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}	
	
?>											