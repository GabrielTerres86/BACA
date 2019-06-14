<?php 

	//*************************************************************************//
	//*** Fonte: entregar.php                                               ***//
	//*** Autor: David                                                      ***//
	//*** Data : Fevereiro/2009               Ultima Alteração: 28/07/2015  ***//
	//***                                                                   ***//
	//*** Objetivo  : Entregar Cartão Magnético							    ***//
	//***                                                                   ***//	 
	//*** Alterações: 06/01/2012 - Ajuste para alterar senha do cartao	    ***//
    //***						   ao solicitar entrega (Adriano)           ***//
    //***																    ***//	
	//***			  19/06/2012 - Adicionado confirmacao para impressao    ***//
	//***						   (Jorge)                                  ***//
    //***																    ***//	
	//***             11/01/2013 - Requisitar cadastro de Letras ao         ***//
	//***                          entregar cartao (Lucas).                 ***//	 
    //***																    ***//
	//***             28/07/2015 - Ajuste na entrega do cartao. (James)	    ***//
    //***																    ***//
	//***             15/10/2015 - Incluido width na function 			    ***//
	//***						   voltarDivPrincipal, PRJ 215 (Jean Michel)***//
	//***																    ***//
	//*************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"B")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrcartao"]) || 
		!isset($_POST["inpessoa"]) || !isset($_POST["nrcpfppt"]) || 
		!isset($_POST["nrsenatu"]) || !isset($_POST["nrsencar"]) || 
		!isset($_POST["nrsencon"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrcartao = $_POST["nrcartao"];
	$inpessoa = $_POST["inpessoa"];
	$nrcpfppt = $_POST["nrcpfppt"];
	$nrsenatu = $_POST["nrsenatu"];
	$nrsencar = $_POST["nrsencar"];
	$nrsencon = $_POST["nrsencon"];
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o n&uacute;mero do cart&atilde;o &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcartao)) {
		exibeErro("N&uacute;mero do cart&atilde;o inv&aacute;lido.");
	}
	
	// Verifica se o tipo de pessoa &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($inpessoa)) {
		exibeErro("Tipo de pessoa inv&aacute;lido.");
	}	
	
	// Verifica se CPF do preposto &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcpfppt)) {
		exibeErro("CPF do preposto inv&aacute;lido.");
	}			
	
	if (intval($nrcpfppt) > 0) {
		include("atualizar_preposto.php");
	}	
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlEntregar  = "";
	$xmlEntregar .= "<Root>";
	$xmlEntregar .= "	<Cabecalho>";
	$xmlEntregar .= "		<Bo>b1wgen0032.p</Bo>";
	$xmlEntregar .= "		<Proc>entregar-cartao-magnetico</Proc>";
	$xmlEntregar .= "	</Cabecalho>";
	$xmlEntregar .= "	<Dados>";
	$xmlEntregar .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlEntregar .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlEntregar .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlEntregar .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlEntregar .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlEntregar .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlEntregar .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlEntregar .= "		<idseqttl>1</idseqttl>";
	$xmlEntregar .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlEntregar .= "		<nrcartao>".$nrcartao."</nrcartao>";
	$xmlEntregar .= "		<nrsenatu>".$nrsenatu."</nrsenatu>";
	$xmlEntregar .= "		<nrsencar>".$nrsencar."</nrsencar>";
	$xmlEntregar .= "		<nrsencon>".$nrsencon."</nrsencon>";
	$xmlEntregar .= "		<flgerlog>YES</flgerlog>";
	$xmlEntregar .= "	</Dados>";
	$xmlEntregar .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlEntregar);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjEntregar = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjEntregar->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjEntregar->roottag->tags[0]->tags[0]->tags[4]->cdata,true);
	} 
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	

	// Procura ind&iacute;ce da op&ccedil;&atilde;o "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	// Se o &iacute;ndice da op&ccedil;&atilde;o "@" foi encontrado 
	if (!($idPrincipal === false)) {
		$acessaaba = 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',\''.$glbvars["opcoesTela"][$idPrincipal].'\');';
	}	else {
		$acessaaba = 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,\''.$glbvars["opcoesTela"][0].'\');';
	}
	
	echo "metOpcaoAba = \"".$acessaaba."\";";
	echo "callafterMagneticos = metOpcaoAba;";	
	
	// Se foi atualizado o preposto, gerar termo de responsabilidade
	if ($nrcpfppt > 0) {		
		echo 'callafterMagneticos = \'showConfirmacao("Deseja visualizar o termo de responsabilidade?","Confirma&ccedil;&atilde;o - Aimaro","callafterMagneticos = metOpcaoAba;geraTermoResponsabilidade();",metOpcaoAba,"sim.gif","nao.gif");\';';
	}	
	
	echo 'showConfirmacao("Deseja visualizar a declara&ccedil;&atilde;o de recebimento?","Confirma&ccedil;&atilde;o - Aimaro","geraDeclaracaoRecebimento();","opcaoSolicitarLetras(\'E\');","sim.gif","nao.gif");';
		
	function exibeErro($msgErro,$erro=false) { 
		echo 'hideMsgAguardo();';
		
		if($erro == true){
			echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","voltarDivPrincipal(\'185\',\'490\');blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");';
		}else{
			echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");';
		}
		
		exit();
	}
	
?>