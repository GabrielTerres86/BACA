<?php 

	/************************************************************************
	  Fonte: entregar.php
	  Autor: Guilherme
	  Data : Marco/2008                 �ltima Altera��o: 15/05/2014

	  Objetivo  : Mostrar op��o Entregar da rotina de Cart�es de Cr�dito da 
	              tela ATENDA

	  Altera��es: 14/05/2009 - Alterar nome dtvalchr para dtvalida (David)
	  
	              04/11/2010 - Adapta��o Cart�o PJ (David)
				  
				  08/07/2011 - Alterado para layout padr�o ( Gabriel - DB1 )
				  
				  15/05/2014 - Ajuste para verificar qual formulario irar abrir na
							   entrega de cartao de credito. (James)						   
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"F")) <> "") {
		exibeErro($msgError);		
	}			
	
	// Verifica se os par�metros necess�rios foram informados
	if (!isset($_POST["nrdconta"]) ||
    !isset($_POST["nrctrcrd"])){
		exibeErro("Par&acirc;metros incorretos.");
	}

	$nrdconta = $_POST["nrdconta"];
	$nrctrcrd = $_POST["nrctrcrd"];
	$cdadmcrd = $_POST["cdadmcrd"];
	$flgcchip = $_POST["flgcchip"];

	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se n�mero do contrato � um inteiro v�lido
	if (!validaInteiro($nrctrcrd)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}	

	// Monta o xml de requisi��o
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>valida_entrega_cartao</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetCartao .= "		<idseqttl>1</idseqttl>";
	$xmlSetCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetCartao .= "		<inconfir>0</inconfir>";
	$xmlSetCartao .= "		<nrctrcrd>".$nrctrcrd."</nrctrcrd>";
	$xmlSetCartao .= "		<nrcrcard></nrcrcard>";
	$xmlSetCartao .= "		<nrcrcard2></nrcrcard2>";
	$xmlSetCartao .= "		<dtvalida></dtvalida>";
	$xmlSetCartao .= "		<repsolic></repsolic>";
	$xmlSetCartao .= "	</Dados>";
	$xmlSetCartao .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCartao);

	// Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 		

	include('form_entrega_cartao.php');	
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}
?>
<script type="text/javascript">
// Mostra o div da Tela da op��o
$("#divOpcoesDaOpcao1").css("display","block");
// Esconde os cart&otilde;es
$("#divConteudoCartoes").css("display","none");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte�do que est� atr�s do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
