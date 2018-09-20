<?php 

	//************************************************************************//
	//*** Fonte: poupanca_consultar.php                                    ***//
	//*** Autor: David                                                     ***//
	//*** Data : Mar�o/2010                   �ltima Altera��o: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar op��o de consulta para Poupan�a Programada   ***//	
	//***                                                                  ***//	 
	//*** Altera��es:                                                      ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibeErro($msgError);		
	}
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o contrato da poupan�a � um inteiro v�lido
	if (!validaInteiro($nrctrrpp)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}	
		
	// Monta o xml de requisi��o
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
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjConsultar->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjConsultar->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$poupanca = $xmlObjConsultar->roottag->tags[0]->tags[0]->tags;	
	
	// Flags para montagem do formul�rio
	$flgAlterar   = false;
	$flgSuspender = false;	
	$legend 	  = "Consultar";
	
	include("poupanca_formulario_dados.php");
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}	
	
?>											