<?php 

	/************************************************************************
	 Fonte: Inscricao_criar.php                                             
	 Autor: Gabriel                                                 
	 Data : Junho/2010                Última Alteração: 20/06/2012

	 Objetivo  : Incluir a inscricao ao evento.

	 Alterações: 25/10/2010 - Adicionar validação de permissão (David).    
	*			 
	*			 19/06/2012 - Adicionado confirmacao para impressao (Jorge)
	*			 17/06/2016 - M181 - Alterar o CDAGENCI para passar o CDPACTRA (Rafael Maciel - RKAM)
	*			 05/07/2019 - Destacar evento do cooperado - P484.2 - Gabriel Marcos (Mouts).
	*
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
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"I")) <> "") {
		exibeErro($msgError);		
	}
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["idseqttl"]) || 
		!isset($_POST["rowidedp"]) ||
		!isset($_POST["rowidadp"]) ||
		!isset($_POST["imptermo"]) ||
		!isset($_POST["tpinseve"]) ||
	  	!isset($_POST["cdgraupr"]) || 
		!isset($_POST["flgdispe"])) {
		exibeErro("Par&acirc;metros incorretos.");					
	}	
	
	if ($_POST["nminseve"] == "") {
		exibeErro("Nome do inscrito n&atilde;o pode ser branco.");
	}
		
	$nrdconta = $_POST["nrdconta"];
	$idseqttl = $_POST["idseqttl"];
	$rowidedp = $_POST["rowidedp"];
	$rowidadp = $_POST["rowidadp"];
	$imptermo = $_POST["imptermo"];
	$tpinseve = $_POST["tpinseve"];
	$cdgraupr = $_POST["cdgraupr"];
	$dsdemail = $_POST["dsdemail"];
	$dsobserv = $_POST["dsobserv"];
	$flgdispe = $_POST["flgdispe"];
 	$nminseve = $_POST["nminseve"];
	$nrdddins = $_POST["nrdddins"];
	$nrtelefo = $_POST["nrtelefo"];
	$nrcpfcgc = $_POST["nrcpfcgc"];
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Monta o xml de requisição
	$xmlGetDadosNovaInscricao  = "";
	$xmlGetDadosNovaInscricao .= "<Root>";
	$xmlGetDadosNovaInscricao .= " <Cabecalho>";
	$xmlGetDadosNovaInscricao .= "     <Bo>b1wgen0039.p</Bo>"; 
	$xmlGetDadosNovaInscricao .= "     <Proc>grava-pre-inscricao</Proc>";
    $xmlGetDadosNovaInscricao .= " </Cabecalho>";
	$xmlGetDadosNovaInscricao .= " <Dados>";
	$xmlGetDadosNovaInscricao .= "     <cdcooper>".$glbvars["cdcooper"]."</cdcooper>"; 
	$xmlGetDadosNovaInscricao .= "     <cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
	$xmlGetDadosNovaInscricao .= "	   <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDadosNovaInscricao .= "	   <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDadosNovaInscricao .= "     <nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetDadosNovaInscricao .= "     <rowidedp>".$rowidedp."</rowidedp>";
	$xmlGetDadosNovaInscricao .= "     <rowidadp>".$rowidadp."</rowidadp>";
	$xmlGetDadosNovaInscricao .= "	   <tpinseve>".$tpinseve."</tpinseve>";
	$xmlGetDadosNovaInscricao .= "     <cdgraupr>".$cdgraupr."</cdgraupr>";              
	$xmlGetDadosNovaInscricao .= "	   <dsdemail>".$dsdemail."</dsdemail>";
	$xmlGetDadosNovaInscricao .= "     <dsobserv>".$dsobserv."</dsobserv>";
	$xmlGetDadosNovaInscricao .= "	   <flgdispe>".$flgdispe."</flgdispe>";
 	$xmlGetDadosNovaInscricao .= "	   <nminseve>".$nminseve."</nminseve>";            
	$xmlGetDadosNovaInscricao .= "	   <nrdddins>".$nrdddins."</nrdddins>";
	$xmlGetDadosNovaInscricao .= "     <nrtelefo>".$nrtelefo."</nrtelefo>";
	$xmlGetDadosNovaInscricao .= "	   <idseqttl>".$idseqttl."</idseqttl>";
	$xmlGetDadosNovaInscricao .= "	   <nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xmlGetDadosNovaInscricao .= "	   <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlGetDadosNovaInscricao .= "     <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDadosNovaInscricao .= "     <flgerlog>NO</flgerlog>";
	$xmlGetDadosNovaInscricao .= " </Dados>";
	$xmlGetDadosNovaInscricao .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDadosNovaInscricao);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosNovaInscricao = getObjectXML($xmlResult);
	
	/* Rowid da inscricao p/ impressao do termo  */
	$nrdrowid = $xmlObjDadosNovaInscricao->roottag->tags[0]->attributes["NRDROWID"];
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDadosNovaInscricao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosNovaInscricao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}	
	
	$acessaaba = 'mostraEventosEmAndamento(\'\');';		
	
	// Se contem termo para assinar e dispensou confirmacao imprime termo
	if ($imptermo == "yes" && $flgdispe == "yes") {		   
		echo "callafterRelacionamento = \"".$acessaaba."\";";
		
		// Efetua a impressão do termo de entrega
		echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Aimaro","gerarImpressao(1,\''.$nrdrowid.'\');","'.$acessaaba.'","sim.gif","nao.gif");';
	} else {
		echo $acessaaba;
	}	
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();		
	}
			
		
?>