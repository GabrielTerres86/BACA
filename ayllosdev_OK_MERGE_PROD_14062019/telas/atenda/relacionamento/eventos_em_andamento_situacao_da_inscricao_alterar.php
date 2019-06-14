<?php 

	/************************************************************************
	 Fonte: eventos_em_andamento_situacao_da_inscricao_alterar.php                                            
	 Autor: Guilherme                                                 
	 Data : Setembro/2009                Última Alteração: 27/07/2016     
	                                                                  
	 Objetivo  : Alterar o status de participação no evento
	                                                                  	 
	 Alterações: 25/10/2010 - Adicionar validação de permissão (David).                                                      
				 27/07/2016 - Corrigi o tratamento do retorno XML. SD 479874 (Carlos R.)                                                    
	************************************************************************/

	session_start();

	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"A")) <> "") {
		exibeErro($msgError);		
	}
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["rowididp"]) ||
		!isset($_POST["imptermo"]) ||
		!isset($_POST["opcaosit"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$rowididp = $_POST["rowididp"];
	$imptermo = $_POST["imptermo"];
	$opcaosit = $_POST["opcaosit"];

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	

	// Monta o xml de requisição
	$xmlGetAlteraSituacaoInscricao  = "";
	$xmlGetAlteraSituacaoInscricao .= "<Root>";
	$xmlGetAlteraSituacaoInscricao .= "	<Cabecalho>";
	$xmlGetAlteraSituacaoInscricao .= "		<Bo>b1wgen0039.p</Bo>";
	$xmlGetAlteraSituacaoInscricao .= "		<Proc>grava-nova-situacao</Proc>";
	$xmlGetAlteraSituacaoInscricao .= "	</Cabecalho>";
	$xmlGetAlteraSituacaoInscricao .= "	<Dados>";
	$xmlGetAlteraSituacaoInscricao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetAlteraSituacaoInscricao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetAlteraSituacaoInscricao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetAlteraSituacaoInscricao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetAlteraSituacaoInscricao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetAlteraSituacaoInscricao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetAlteraSituacaoInscricao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetAlteraSituacaoInscricao .= "		<idseqttl>1</idseqttl>";
	$xmlGetAlteraSituacaoInscricao .= "		<rowididp>".$rowididp."</rowididp>";
	$xmlGetAlteraSituacaoInscricao .= "		<opcaosit>".$opcaosit."</opcaosit>";
	$xmlGetAlteraSituacaoInscricao .= "	</Dados>";
	$xmlGetAlteraSituacaoInscricao .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetAlteraSituacaoInscricao);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjSituacaoInscricao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjSituacaoInscricao->roottag->tags[0]->name) && strtoupper($xmlObjSituacaoInscricao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjSituacaoInscricao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

	/* Se confirmou e tem termo */
	if ($opcaosit == 2 && $imptermo == "yes") {
		echo 'callafterRelacionamento = \'mostraEventosEmAndamento("");\';';
		echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","gerarImpressao(1,\'\');",callafterRelacionamento,"sim.gif","nao.gif");';			
	} else {
		echo 'mostraEventosEmAndamento("");';
	}

?>