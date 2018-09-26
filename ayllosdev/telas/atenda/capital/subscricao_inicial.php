<?php 

	//************************************************************************//
	//*** Fonte: subscricao_inicial.php                                    ***//
	//*** Autor: David                                                     ***//
	//*** Data : Outubro/2007                 &Uacute;ltima Altera&ccedil;&atilde;o: 04/09/2009 ***//
	//***                                                                  ***//
	//*** Objetivo  : Mostrar opcao Subscri&ccedil;&atilde;o Inicial da rotina de        ***//
	//****						Capital da tela ATENDA      												 ***//
	//***                                                                  ***//	 
	//*** Altera&ccedil;&otilde;es: 04/09/2009 - Tratar tamanho do div (David).          ***//
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"S")) <> "") {
		exibeErro($msgError);		
	}		
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];

	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetSubscricao  = "";
	$xmlGetSubscricao .= "<Root>";
	$xmlGetSubscricao .= "	<Cabecalho>";
	$xmlGetSubscricao .= "		<Bo>b1wgen0021.p</Bo>";
	$xmlGetSubscricao .= "		<Proc>proc-subscricao</Proc>";
	$xmlGetSubscricao .= "	</Cabecalho>";
	$xmlGetSubscricao .= "	<Dados>";
	$xmlGetSubscricao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetSubscricao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetSubscricao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetSubscricao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetSubscricao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetSubscricao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetSubscricao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetSubscricao .= "		<idseqttl>1</idseqttl>";
	$xmlGetSubscricao .= "	</Dados>";
	$xmlGetSubscricao .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetSubscricao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjSubscricao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjSubscricao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjSubscricao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	$subscricao = $xmlObjSubscricao->roottag->tags[0]->tags;
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}

?>

<? include('tabela_subscricao.php'); ?>
	
<script type="text/javascript">
// Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
$("#divConteudoOpcao").css("height","145px");

controlaLayout('SUBS_INICIAL');

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>