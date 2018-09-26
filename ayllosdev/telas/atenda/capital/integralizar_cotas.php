<?php 

	//************************************************************************//
	//*** Fonte: integralizar_cotas.php                                    ***//
	//*** Autor: Fabricio                                                  ***//
	//*** Data : Setembro/2013                Ultima Alteracao: 03/10/2015 ***//
	//***                                                                  ***//
	//*** Objetivo  : Integralizar no saldo capital do cooperado o valor   ***//
	//***             informado.                                           ***//
	//***                                                                  ***//	 
	//*** Alteracoes: 03/10/2015 - Reformulacao cadastral (Gabriel-RKAM)   ***//
    /*          17/06/2016 - M181 - Alterar o CDAGENCI para          
                      passar o CDPACTRA (Rafael Maciel - RKAM) */
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"I")) <> "") {
		exibeErro($msgError);		
	}		
	
	// Verifica se os par&acirc;metros necess&aacute;rios foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["vintegra"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$vintegra = $_POST["vintegra"];
	$flgsaldo = $_POST["flgsaldo"];
	$executandoProdutos = $_POST['executandoProdutos'];

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Verifica se valor informado &eacute; um decimal v&aacute;lido
	if (!validaDecimal($vintegra)) {
		exibeErro("Valor inv&aacute;lido para integraliza&ccedil;&atilde;o.");
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlIntegraliza  = "";
	$xmlIntegraliza .= "<Root>";
	$xmlIntegraliza .= "	<Cabecalho>";
	$xmlIntegraliza .= "		<Bo>b1wgen0021.p</Bo>";
	$xmlIntegraliza .= "		<Proc>integraliza_cotas</Proc>";
	$xmlIntegraliza .= "	</Cabecalho>";
	$xmlIntegraliza .= "	<Dados>";
	$xmlIntegraliza .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlIntegraliza .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xmlIntegraliza .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlIntegraliza .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlIntegraliza .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlIntegraliza .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlIntegraliza .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlIntegraliza .= "		<idseqttl>1</idseqttl>";
	$xmlIntegraliza .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlIntegraliza .= "		<vintegra>".$vintegra."</vintegra>";
	$xmlIntegraliza .= "		<flgsaldo>".$flgsaldo."</flgsaldo>";
	$xmlIntegraliza .= "	</Dados>";
	$xmlIntegraliza .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlIntegraliza);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjIntegra = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjIntegra->roottag->tags[0]->name) == "ERRO") {
		
		// se não houver saldo suficiente, verifica se quer negativar a conta 
		if(strpos($xmlObjIntegra->roottag->tags[0]->tags[0]->tags[4]->cdata, 'saldo suficiente') > 0) {
			$aux_flgsaldo = 'no'; // marca para não validar negativação de conta
		} else {
		exibeErro($xmlObjIntegra->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 	
	} 	
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	
	if ($aux_flgsaldo == "no")
		// Mensagem para confirmar se realiza a integralizacao mesmo com saldo insuficiente
		echo 'showConfirmacao("Saldo c/c insuficiente para esta opera&ccedil;&atilde;o. Confirma a opera&ccedil;&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","mostraSenha()","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))","sim.gif","nao.gif");';
	else {
		
		$metodo = "blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));";
		
		if ($executandoProdutos == 'true') {
			$metodo .= "encerraRotina();";
		}
		
		echo 'showError("inform","Integraliza&ccedil;&atilde;o realizada com sucesso!","Alerta - Aimaro","' . $metodo . '");';
		
		echo '$("#vintegra","#divIntegralizacao").val("");';
	}	
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
	
?>