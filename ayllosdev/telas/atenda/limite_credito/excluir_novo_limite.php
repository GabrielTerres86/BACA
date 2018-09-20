<?php 

	//************************************************************************//
	//*** Fonte: excluir_novo_limite.php                                  
	//*** Autor: David                                                    
	//*** Data : Março/2008                   Última Alteração: 23/12/2015
	//***                                                                 
	//*** Objetivo  : Excluir Novo Limite de Crédito - rotina de Limite de
	//***             Crédito da tela ATENDA                              
	//***                               
	//*** Alterações: Ao fim da operação, direcionar para CONSULTA  (Lucas Lunelli - SD 360072 [M175])
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"N")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	
	// Verifica se número da conta éum inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Monta o xml de requisição
	$xmlExcluirLimite  = "";
	$xmlExcluirLimite .= "<Root>";
	$xmlExcluirLimite .= "	<Cabecalho>";
	$xmlExcluirLimite .= "		<Bo>b1wgen0019.p</Bo>";
	$xmlExcluirLimite .= "		<Proc>excluir-novo-limite</Proc>";
	$xmlExcluirLimite .= "	</Cabecalho>";
	$xmlExcluirLimite .= "	<Dados>";
	$xmlExcluirLimite .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlExcluirLimite .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlExcluirLimite .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlExcluirLimite .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlExcluirLimite .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlExcluirLimite .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xmlExcluirLimite .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlExcluirLimite .= "		<idseqttl>1</idseqttl>";
	$xmlExcluirLimite .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlExcluirLimite .= "	</Dados>";
	$xmlExcluirLimite .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlExcluirLimite);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjLimite = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjLimite->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLimite->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Procura índice da opção "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	// Se o índice da opção "@" foi encontrado 
	if (!($idPrincipal === false)) {
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',"'.$glbvars["opcoesTela"][$idPrincipal].'");';
	}	else {
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,"'.$glbvars["opcoesTela"][0].'");';
	}	
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>