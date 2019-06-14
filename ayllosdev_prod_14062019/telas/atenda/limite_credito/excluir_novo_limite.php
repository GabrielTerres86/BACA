<?php 

	//************************************************************************//
	//*** Fonte: excluir_novo_limite.php                                  
	//*** Autor: David                                                    
	//*** Data : Mar�o/2008                   �ltima Altera��o: 23/12/2015
	//***                                                                 
	//*** Objetivo  : Excluir Novo Limite de Cr�dito - rotina de Limite de
	//***             Cr�dito da tela ATENDA                              
	//***                               
	//*** Altera��es: Ao fim da opera��o, direcionar para CONSULTA  (Lucas Lunelli - SD 360072 [M175])
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"N")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	
	// Verifica se n�mero da conta �um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Monta o xml de requisi��o
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
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjLimite->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLimite->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	
	// Procura �ndice da op��o "@"
	$idPrincipal = array_search("@",$glbvars["opcoesTela"]);
	
	// Se o �ndice da op��o "@" foi encontrado 
	if (!($idPrincipal === false)) {
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).','.$idPrincipal.',"'.$glbvars["opcoesTela"][$idPrincipal].'");';
	}	else {
		echo 'acessaOpcaoAba('.count($glbvars["opcoesTela"]).',0,"'.$glbvars["opcoesTela"][0].'");';
	}	
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>