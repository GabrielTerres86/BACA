<?php 

	/**************************************************************************
	 Fonte: principal.php                                             
	 Autor: David                                                     
	 Data : Fevereiro/2008               Ultima Alteracao: 25/07/2016
	                                                                  
	 Objetivo  : Obter dados da senha de Tele Atendimento             
	                                                                   
	 Alteracoes: 08/11/2013 - Validação para verificar se a senha ja  
	   					      existe (Cristian)                       
																	  
				 28/01/2014 - Alterada condicao para verificar senha 
						      URA inativa. (Reinert)				  
	                                                                  
	             27/10/2014 - Remover BREAK e ajustar o script para   
	                          esconder a mensagem de aguardo          
	                          (Douglas - Chamado 180542)              
	                                                                  
	             30/09/2015 - Ajuste para inclusão das novas telas "Produtos"
				              (Gabriel - Rkam -> Projeto 217).			  
					
				 25/07/2016 - Corrigi o tratamento do retorno de erro no XML.SD 479874 (Carlos R.)
					
	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$executandoProdutos = $_POST['executandoProdutos'];

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetDadosURA  = "";
	$xmlGetDadosURA .= "<Root>";
	$xmlGetDadosURA .= "	<Cabecalho>";
	$xmlGetDadosURA .= "		<Bo>b1wgen0015.p</Bo>";
	$xmlGetDadosURA .= "		<Proc>carrega_dados_ura</Proc>";
	$xmlGetDadosURA .= "	</Cabecalho>";
	$xmlGetDadosURA .= "	<Dados>";
	$xmlGetDadosURA .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDadosURA .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDadosURA .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDadosURA .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDadosURA .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDadosURA .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlGetDadosURA .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDadosURA .= "		<idseqttl>1</idseqttl>";
	$xmlGetDadosURA .= "	</Dados>";
	$xmlGetDadosURA .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDadosURA);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosURA = getObjectXML($xmlResult);
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (isset($xmlObjDadosURA->roottag->tags[0]->name) && strtoupper($xmlObjDadosURA->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosURA->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Caso senha de tele-atendimento esteja inativa
	if($xmlObjDadosURA->roottag->tags[0]->tags[0]->tags[2]->cdata == "0")
	{
		echo '$("#nmopeura","#frmCadURA").val("'.$glbvars['nmoperad'].'");';
		echo "senhaNaoCadastrada();";
		
		//Se esta tela foi chamada através da rotina "Produtos" então acessa a opção conforme definido pelos responsáveis do projeto 217
		if ($executandoProdutos == 'true') {
			echo 'mostraCriaSenhaURA();';
		}
		
	}else{
		// Mostra dados da senha de Tele Atendimento nos campos
		echo '$("#nmopeura","#frmURA").val("'.$xmlObjDadosURA->roottag->tags[0]->tags[0]->tags[0]->cdata.'");';
		echo '$("#dtaltsnh","#frmURA").val("'.$xmlObjDadosURA->roottag->tags[0]->tags[0]->tags[1]->cdata.'");';
		
		//Se esta tela esta foi chamada através da rotina "Produtos" então acessa a opção conforme definido pelos responsáveis do projeto 217
		if ($executandoProdutos == 'true') {
			echo 'senhaURA();';
		}
		else {
			echo '$("#divDadosSenhaURA").css("display","block");';
		}
		
		// Esconde mensagem de aguardo
		echo 'hideMsgAguardo();';
		echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	}
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
	
?>