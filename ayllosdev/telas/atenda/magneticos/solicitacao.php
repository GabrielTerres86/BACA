<?php 

	//**************************************************************************************//
	//*** Fonte: solicitacao.php                                           				 ***//
	//*** Autor: David                                                     				 ***//
	//*** Data : Outubro/2008                 Última Alteração: 08/10/2015 				 ***//
	//***                                                                  				 ***//
	//*** Objetivo  : Mostrar opcao para alterar/incluir Solicita&ccedil;&atilde;o de    ***//
	//***             Cart&atilde;o Magn&eacute;tico                                     ***//
	//***                                                                  				 ***//	 
	//*** Alterações                                                       				 ***//
	//*** 		13/07/2011 - Alterado para layout padrão (Rogerius - DB1). 				 ***//
	//***                                                                  				 ***//	 
	//***       23/07/2015 - Remover os campos Limite, Forma de Saque e Recibo  		 ***//	 
	//***                    de entrega. (James)                                         ***//	 
	//***                                                                                ***//
	//****       08/10/2015 - Reformulacao cadastral (Gabriel-RKAM)                      ***//
    //**** 		 17/06/2016 - M181 - Alterar o CDAGENCI para passar o CDPACTRA (Rafael Maciel - RKAM) **//
	//**************************************************************************************//
	
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
	if (!isset($_POST["cddopcao"]) || !isset($_POST["nrdconta"]) || !isset($_POST["nrcartao"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$cddopcao = $_POST["cddopcao"];
	$nrdconta = $_POST["nrdconta"];
	$nrcartao = $_POST["nrcartao"];
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
		exibeErro($msgError);		
	}
	
	// Verifica se o n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se o n&uacute;mero do cart&atilde;o &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcartao)) {
		exibeErro("N&uacute;mero do cart&atilde;o inv&aacute;lido.");
	}
	
	$qtPreposto = 0;
	
	// Solicita&ccedil;&atilde;o de novo cart&atilde;o
	if ($cddopcao == "I") {
		// Monta o xml de requisi&ccedil;&atilde;o
		$xmlPreposto  = "";
		$xmlPreposto .= "<Root>";
		$xmlPreposto .= "	<Cabecalho>";
		$xmlPreposto .= "		<Bo>b1wgen0032.p</Bo>";
		$xmlPreposto .= "		<Proc>obtem-prepostos</Proc>";
		$xmlPreposto .= "	</Cabecalho>";
		$xmlPreposto .= "	<Dados>";
		$xmlPreposto .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$xmlPreposto .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
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
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlDadosCartao  = "";
	$xmlDadosCartao .= "<Root>";
	$xmlDadosCartao .= "	<Cabecalho>";
	$xmlDadosCartao .= "		<Bo>b1wgen0032.p</Bo>";
	$xmlDadosCartao .= "		<Proc>obtem-permissao-solicitacao</Proc>";
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
	$titular   = $xmlObjDadosCartao->roottag->tags[1]->tags;
	
	if ($qtPreposto > 0) {
		include("formulario_preposto.php");
	}	
	
	// Flags para montagem do formul&aacute;rio
	$flgSolicitacao = true;
	$flgLimite      = false;
	$flgRecibo      = false;
	if ( $cddopcao == "A" ) {
		$legend	= "Alterar";
	} else {
		$legend	= "Solicitar";
	}
	
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
$("#divConteudoOpcao").css({"width":"540px"});
$("#nmtitcrd","#frmDadosCartaoMagnetico").setMask("STRING",28,charPermitido(),"");
$("#tpusucar","#frmDadosCartaoMagnetico").trigger("change");

<?php if ($qtPreposto > 0) { ?>
	mostraDivPreposto();
<?php } else { ?>
	escondeDivPreposto();
<?php } ?>

$("#divMagneticosPrincipal").css("display","none");
$("#divMagneticosOpcao01").css("display","block");

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));

$('#tpusucar', '#frmDadosCartaoMagnetico').focus();
</script>