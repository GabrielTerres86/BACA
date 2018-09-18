<?php 

	/***************************************************************************
	 Fonte: aplicacoes_programadas_carregar.php                             
	 Autor: David                                                     
     Data : Mar�o/2010                   Ultima Alteracao: 27/07/2018
	 
	 Objetivo  : Mostrar op��o para alterar Aplica��o Programada      
	                                                                  
	 Altera��es: 04/04/2018 - Chamada da rotina para verificar se o tipo de conta permite produto 
				              16 - Poupan�a Programada. PRJ366 (Lombardi).
							  
				 27/07/2018 - Deriva��o para Aplica��o Programada 
				 
	***************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];
	$cdprodut = $_POST["cdprodut"];
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o contrato da "poupan�a" � um inteiro v�lido
	if (!validaInteiro($nrctrrpp)) {
		exibeErro("N&uacute;mero de contrato inv&aacute;lido.");
	}	
			
	// Montar o xml de Requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";	
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <cdprodut>". 16 ."</cdprodut>"; //Poupan�a Programada
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "CADA0006", "VALIDA_ADESAO_PRODUTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObject = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibeErro(utf8_encode($msgErro));
	}
	
	// Monta o xml de requisi��o
	$xmlAlterar  = "";
	$xmlAlterar .= "<Root>";
	$xmlAlterar .= "	<Cabecalho>";
	$xmlAlterar .= "		<Bo>b1wgen0006.p</Bo>";
	$xmlAlterar .= "		<Proc>obtem-dados-alteracao</Proc>";
	$xmlAlterar .= "	</Cabecalho>";
	$xmlAlterar .= "	<Dados>";
	$xmlAlterar .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlAlterar .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlAlterar .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlAlterar .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlAlterar .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlAlterar .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlAlterar .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlAlterar .= "		<idseqttl>1</idseqttl>";
	$xmlAlterar .= "		<nrctrrpp>".$nrctrrpp."</nrctrrpp>";
	$xmlAlterar .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlAlterar .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";
	$xmlAlterar .= "		<inproces>".$glbvars["inproces"]."</inproces>";
	$xmlAlterar .= "		<cdprogra>".$glbvars["nmdatela"]."</cdprogra>";	
	$xmlAlterar .= "	</Dados>";
	$xmlAlterar .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlAlterar);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjAlterar = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjAlterar->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjAlterar->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$poupanca = $xmlObjAlterar->roottag->tags[0]->tags[0]->tags;	
	
	// Flags para montagem do formul�rio
	$flgAlterar   = true;
	$flgSuspender = false;	
	$legend 	  = "Alterar";
	include("aplicacoes_programadas_formulario_dados.php");
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}	
	
?>											