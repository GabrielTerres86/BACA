<?php 

	//**************************************************************************************//
	//*** Fonte: incluir_cartao_magnetico.php                              			     ***//
	//*** Autor: David                                                     				 ***//
	//*** Data : Outubro/2008                 Ultima Alteracao: 08/10/2015 				 ***//
	//***                                                                  				 ***//
	//*** Objetivo  : Incluir solicitacao de Cartao Magnetico              				 ***//
	//***                                                                  				 ***//	 
	//*** Alteracoes: 19/06/2012 - Adicionado confirmacao para impressao   				 ***//
	//***						   (Jorge)                                 				 ***//
	//***																				 ***//
	//***			  23/07/2015 - Remover os campos Limite, Forma de Saque e Recido 	 ***//
	//***						   de entrega. (James)                               	 ***//
    //***                                                                                ***//
	//***             08/10/2015 - Reformulacao cadastral (Gabriel-RKAM)                 ***//
    //***				  17/06/2016 - M181 - Alterar o CDAGENCI para passar o CDPACTRA (Rafael Maciel - RKAM) ***//
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"I")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrcartao"]) || !isset($_POST["tpusucar"]) || !isset($_POST["nmtitcrd"]) || !isset($_POST["inpessoa"]) ||
			!isset($_POST["nrcpfppt"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$nrcartao = $_POST["nrcartao"];
	$tpusucar = $_POST["tpusucar"];
	$nmtitcrd = $_POST["nmtitcrd"];	
	$inpessoa = $_POST["inpessoa"];
	$nrcpfppt = $_POST["nrcpfppt"];
	$executandoProdutos = $_POST['executandoProdutos'];
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o n&uacute;mero do cart&atilde;o &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrcartao)) {
		exibeErro("N&uacute;mero do cart&atilde;o inv&aacute;lido.");
	}
	
	// Verifica se o identificador do titular &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($tpusucar)) {
		exibeErro("Titular inv&aacute;lido.");
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
	$xmlDadosInclusao  = "";
	$xmlDadosInclusao .= "<Root>";
	$xmlDadosInclusao .= "	<Cabecalho>";
	$xmlDadosInclusao .= "		<Bo>b1wgen0032.p</Bo>";
	$xmlDadosInclusao .= "		<Proc>incluir-cartao-magnetico</Proc>";
	$xmlDadosInclusao .= "	</Cabecalho>";
	$xmlDadosInclusao .= "	<Dados>";
	$xmlDadosInclusao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlDadosInclusao .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xmlDadosInclusao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlDadosInclusao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlDadosInclusao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlDadosInclusao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlDadosInclusao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlDadosInclusao .= "		<idseqttl>1</idseqttl>";
	$xmlDadosInclusao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlDadosInclusao .= "		<nrcartao>".$nrcartao."</nrcartao>";
	$xmlDadosInclusao .= "		<tpcarcta>1</tpcarcta>";
	$xmlDadosInclusao .= "		<tpusucar>".$tpusucar."</tpusucar>";
	$xmlDadosInclusao .= "		<nmtitcrd>".$nmtitcrd."</nmtitcrd>";	
	$xmlDadosInclusao .= "		<flgerlog>YES</flgerlog>";
	$xmlDadosInclusao .= "	</Dados>";
	$xmlDadosInclusao .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlDadosInclusao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjInclusao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjInclusao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjInclusao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Procura ind&iacute;ce da op&ccedil;&atilde;o "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	// Se o &iacute;ndice da op&ccedil;&atilde;o "@" foi encontrado
	if ($executandoProdutos == 'true') {
		$metodo = 'encerraRotina();';
	} else {
		if (!($idPrincipal === false)) {
			$metodo = 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',\''.$glbvars["opcoesTela"][$idPrincipal].'\');';
		}	else {
			$metodo = 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,\''.$glbvars["opcoesTela"][0].'\');';
		}	
	}
	
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));';		
	
	// Se for pessoa jur&iacute;dica, gerar termo de responsabilidade
	if (intval($inpessoa) > 1) {
		echo "metOpcaoAba = \"".$metodo."\";";
		echo "callafterMagneticos = metOpcaoAba;";	
		
		// Efetua a impressão do termo de entrega
		echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","geraTermoResponsabilidade();",metOpcaoAba,"sim.gif","nao.gif");';
	} else {		
		echo $metodo;
	}
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>