<?php 

	/**************************************************************************
	 Fonte: aplicacoes_programadas_incluir.php                                      
	 Autor: David                                                     
	 Data : Março/2010                   Última Alteração: 27/07/2018 
	                                                                  
	 Objetivo  : Script para incluir aplicação programada              
	                                                                  
	 Alterações:  27/07/2018 - Derivação para Aplicação Programada              
                               (Proj. 411.2 - CIS Corporate)      
							   
				  09/09/2018 - Inclusão Finalidade             
                               (Proj. 411.2 - CIS Corporate)      
							   
	***************************************************************************/
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"I")) <> "") {
		exibeErro($msgError);		
	}	

	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["dtinirpp"]) || !isset($_POST["diadtvct"]) ||
	    !isset($_POST["mesdtvct"]) || !isset($_POST["anodtvct"]) || !isset($_POST["vlprerpp"]) ||
		!isset($_POST["tpemiext"]) || !isset($_POST["cdprodut"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$dtinirpp = $_POST["dtinirpp"];	
	$diadtvct = $_POST["diadtvct"];	
	$mesdtvct = $_POST["mesdtvct"];	
	$anodtvct = $_POST["anodtvct"];	
	$vlprerpp = $_POST["vlprerpp"];	
	$tpemiext = $_POST["tpemiext"];
	$cdprodut = $_POST["cdprodut"];
	$dsfinali = $_POST["dsfinali"];

	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se a data de início é válida
	if (!validaData($dtinirpp)) {
		exibeErro("Data de in&iacute;cio inv&aacute;lida.");
	}
	
	// Verifica se dia para vencimento é um inteiro válido
	if (!validaInteiro($diadtvct)) {
		exibeErro("Dia para vencimento inv&aacute;lido.");
	}
	
	// Verifica se mês para vencimento é um inteiro válido
	if (!validaInteiro($mesdtvct)) {
		exibeErro("M&ecirc;s para vencimento inv&aacute;lido.");
	}

	// Verifica se ano para vencimento é um inteiro válido
	if (!validaInteiro($anodtvct)) {
		exibeErro("Ano para vencimento inv&aacute;lido.");
	}	
	
	// Verifica se a data de vencimento é válida
	if (!validaData($diadtvct."/".$mesdtvct."/".$anodtvct)) {
		exibeErro("Data de vencimento inv&aacute;lida.");
	}
	
	// Verifica se o valor da prestação é um decimal válido
	if (!validaDecimal($vlprerpp)) {
		exibeErro("Valor de presta&ccedil;&atilde;o inv&aacute;lido.");
	}
	
	// Verifica se o tipo de impressao é um inteiro válido
	if (!validaInteiro($tpemiext)) {
		exibeErro("Tipo de impressao do extrato inv&aacute;lido.");			
	}
	
	// Verifica se o produto é válido
	if (!validaInteiro($cdprodut) || $cdprodut < 1 ) {
		exibeErro("Aplica&ccedil;&atilde;o programada inv&aacute;lida.");			
	}	
	
	// Monta o xml de requisição
	$xmlIncluir  = ""; 
	$xmlIncluir .= "<Root>";
	$xmlIncluir .= "	<Cabecalho>";
	$xmlIncluir .= "		<Bo>b1wgen0006.p</Bo>";
	$xmlIncluir .= "		<Proc>incluir-aplicacao-programada</Proc>";
	$xmlIncluir .= "	</Cabecalho>";	
	$xmlIncluir .= "	<Dados>";
	$xmlIncluir .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlIncluir .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xmlIncluir .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlIncluir .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlIncluir .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlIncluir .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlIncluir .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlIncluir .= "		<idseqttl>1</idseqttl>";
	$xmlIncluir .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xmlIncluir .= "		<dtinirpp>".$dtinirpp."</dtinirpp>"; 			
	$xmlIncluir .= "		<mesdtvct>".$mesdtvct."</mesdtvct>";
	$xmlIncluir .= "		<anodtvct>".$anodtvct."</anodtvct>";	
	$xmlIncluir .= "		<vlprerpp>".$vlprerpp."</vlprerpp>"; 	
	$xmlIncluir .= "		<tpemiext>".$tpemiext."</tpemiext>";
	$xmlIncluir .= "		<cdprodut>".$cdprodut."</cdprodut>";	
	$xmlIncluir .= "		<dsfinali>".$dsfinali."</dsfinali>"; 	
	$xmlIncluir .= "		<flgteimo>0</flgteimo>";
	$xmlIncluir .= "		<flgdbpar>0</flgdbpar>";
	$xmlIncluir .= "	</Dados>";	
	$xmlIncluir .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlIncluir);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjIncluir = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjIncluir->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjIncluir->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}

	$nrdrowid = $xmlObjIncluir->roottag->tags[0]->attributes["NRDROWID"];	
	$nrrdcapp = $xmlObjIncluir->roottag->tags[0]->attributes["NRRDCAPP"];	

	// Procura índice da opção "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);	
	
	// Se o índice da opção "@" foi encontrado, carrega poupanças novamente
	if (!($idPrincipal === false)) {
		//Se esta tela foi chamada pela rotina "Produtos" então encerra a tela, do contrário, chama uma opção da tela. 	
		$acessaaba = '(executandoProdutos == true) ? encerraRotina(true) : acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',\''.$glbvars["opcoesTela"][$idPrincipal].'\');';
	}	else {
		//Se esta tela foi chamada pela rotina "Produtos" então encerra a tela, do contrário, chama uma opção da tela. 	
		$acessaaba = '(executandoProdutos == true) ? encerraRotina(true) : acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,\''.$glbvars["opcoesTela"][0].'\');';
	}
	
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));';				
	
	//Se esta tela foi chamada pela rotina "Produtos" então encerra a tela, do contrário, chama uma opção da tela. 	
	echo "(executandoProdutos == true) ? callafterPoupanca = \"encerraRotina(true)\" : callafterPoupanca = \"".$acessaaba."\";";	

	echo "nrctrrpp=".$nrrdcapp.";";

	// Efetua a impressão do termo de entrega
	echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","imprimirAutorizacao(\''.$nrdrowid.'\',\'1\',\''.$cdprodut.'\');","'.$acessaaba.'","sim.gif","nao.gif");';	

	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>
