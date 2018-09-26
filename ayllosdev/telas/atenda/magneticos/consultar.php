<?php 

	//************************************************************************//
	//*** Fonte: consultar.php                                             ***//
	//*** Autor: David                                                     ***//
	//*** Data : Outubro/2008                 &Uacute;ltima Altera&ccedil;&atilde;o: 00/00/0000 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opcao Consulta da rotina de Cart&otilde;es          ***//
	//****						Magn&eacute;ticos da tela ATENDA    												 ***//
	//***                                                                  ***//	 
	//*** Altera&ccedil;&otilde;es:                                                      ***//
	//*** 		13/07/2011 - Alterado para layout padrão (Rogerius - DB1). ***//	
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrcartao"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrcartao = $_POST["nrcartao"];
	
	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o n&uacute;mero do cart&atilde;o &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcartao)) {
		exibeErro("N&uacute;mero do cart&atilde;o inv&aacute;lido.");
	}	
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlDadosCartao  = "";
	$xmlDadosCartao .= "<Root>";
	$xmlDadosCartao .= "	<Cabecalho>";
	$xmlDadosCartao .= "		<Bo>b1wgen0032.p</Bo>";
	$xmlDadosCartao .= "		<Proc>consulta-cartao-magnetico</Proc>";
	$xmlDadosCartao .= "	</Cabecalho>";
	$xmlDadosCartao .= "	<Dados>";
	$xmlDadosCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlDadosCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlDadosCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlDadosCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlDadosCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlDadosCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlDadosCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlDadosCartao .= "		<idseqttl>1</idseqttl>";
	$xmlDadosCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlDadosCartao .= "		<nrcartao>".$nrcartao."</nrcartao>";
	$xmlDadosCartao .= "		<flgerlog>YES</flgerlog>";
	$xmlDadosCartao .= "	</Dados>";
	$xmlDadosCartao .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlDadosCartao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosCartao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjDadosCartao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosCartao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$magnetico = $xmlObjDadosCartao->roottag->tags[0]->tags[0]->tags;
	
	// Flags para montagem do formul&aacute;rio
	$flgSolicitacao = false;
	$flgLimite      = false;
	$flgRecibo      = false;
	$legend			= "Consultar";
	
	include("formulario_cartao.php");
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}	
	
?>											
<script type="text/javascript">
// Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
$("#divConteudoOpcao").css({"height":"295px","width":"490px"});

$("#divMagneticosPrincipal").css("display","none");
$("#divMagneticosOpcao01").css("display","block");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>