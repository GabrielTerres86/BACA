<?php 

	//**************************************************************************//
	//*** Fonte: entregar_preposto.php                                       ***//
	//*** Autor: David                                                       ***//
	//*** Data : Fevereiro/2009             Ultima Atualização: 06/01/2012   ***//
	//***                                                                    ***//
	//*** Objetivo  : Mostrar Prepostos para Entregar Cartão Magnético       ***//
	//***                                                                    ***//	 
	//*** Alterações: 09/07/2009 - Utilizar procedure consiste-cartao        ***//
    //***                          (David).                                  ***//
    //***																     ***//
	//***			  06/01/2012 - Ajuste para alteração de senha do cartão  ***//
	//***						   quando for solicitado entrega (Adriano).  ***//
	//***																     ***//
	//***			  14/10/2015 - Incluido width da tela PRJ 215			 ***//
	//***						   (Jean Michel) 							 ***//
	//**************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica se o n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"]) || 
		!isset($_POST["nrcartao"]) ||
		!isset($_POST["operacao"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrcartao = $_POST["nrcartao"];
	$operacao = $_POST["operacao"];
	$cddopcao = "B";
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlConsiste  = "";
	$xmlConsiste .= "<Root>";
	$xmlConsiste .= "	<Cabecalho>";
	$xmlConsiste .= "		<Bo>b1wgen0032.p</Bo>";
	$xmlConsiste .= "		<Proc>consiste-cartao</Proc>";
	$xmlConsiste .= "	</Cabecalho>";
	$xmlConsiste .= "	<Dados>";
	$xmlConsiste .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlConsiste .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlConsiste .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlConsiste .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlConsiste .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlConsiste .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlConsiste .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlConsiste .= "		<idseqttl>1</idseqttl>";
	$xmlConsiste .= "		<nrcartao>".$nrcartao."</nrcartao>";
	$xmlConsiste .= "		<flgentrg>TRUE</flgentrg>";
	$xmlConsiste .= "	</Dados>";
	$xmlConsiste .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlConsiste);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjConsiste = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjConsiste->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjConsiste->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}		
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlPreposto  = "";
	$xmlPreposto .= "<Root>";
	$xmlPreposto .= "	<Cabecalho>";
	$xmlPreposto .= "		<Bo>b1wgen0032.p</Bo>";
	$xmlPreposto .= "		<Proc>obtem-prepostos</Proc>";
	$xmlPreposto .= "	</Cabecalho>";
	$xmlPreposto .= "	<Dados>";
	$xmlPreposto .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlPreposto .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlPreposto .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlPreposto .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlPreposto .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlPreposto .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlPreposto .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlPreposto .= "		<idseqttl>1</idseqttl>";
	$xmlPreposto .= "		<flgerlog>YES</flgerlog>";
	$xmlPreposto .= "	</Dados>";
	$xmlPreposto .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlPreposto);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjPreposto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjPreposto->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjPreposto->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}		
	
	$preposto   = $xmlObjPreposto->roottag->tags[0]->tags;
	$qtPreposto = count($preposto);

	if ($qtPreposto > 0) {
		include("formulario_preposto.php");
	}	
	
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
<?php if ($qtPreposto > 0) { ?>
$("#divMagneticosPrincipal").css("display","none");
$("#divMagneticosOpcao01").css("display","block");

// Aumenta tamanho do div onde o conte&uacute;do da op&ccedil;&atilde;o ser&aacute; visualizado
$("#divConteudoOpcao").css("height","220px");
$("#divConteudoOpcao").css("width","540px");
<?php } ?>

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

<?php if ($qtPreposto == 0) { ?>
acessaOpcaoSenha('E');
//confirmaEntregaCartaoMagnetico(); 
<?php } ?>
</script>