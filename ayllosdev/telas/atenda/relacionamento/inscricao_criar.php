<?php 

	/************************************************************************
	 Fonte: Inscricao_criar.php                                             
	 Autor: Gabriel                                                 
	 Data : Junho/2010                �ltima Altera��o: 20/06/2012

	 Objetivo  : Incluir a inscricao ao evento.

	 Altera��es: 25/10/2010 - Adicionar valida��o de permiss�o (David).    
	*			 
	*			 19/06/2012 - Adicionado confirmacao para impressao (Jorge)
				  17/06/2016 - M181 - Alterar o CDAGENCI para passar o CDPACTRA (Rafael Maciel - RKAM)

	*
	************************************************************************/	
	
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Verifica permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"I")) <> "") {
		exibeErro($msgError);		
	}
	
	// Se par�metros necess�rios n�o foram informados
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
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Monta o xml de requisi��o
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
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjDadosNovaInscricao->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjDadosNovaInscricao->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}	
	
	$acessaaba = 'mostraEventosEmAndamento(\'\');';		
	
	// Se contem termo para assinar e dispensou confirmacao imprime termo
	if ($imptermo == "yes" && $flgdispe == "yes") {		   
		echo "callafterRelacionamento = \"".$acessaaba."\";";
		
		// Efetua a impress�o do termo de entrega
		echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","gerarImpressao(1,\''.$nrdrowid.'\');","'.$acessaaba.'","sim.gif","nao.gif");';
	} else {
		echo $acessaaba;
	}	
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();		
	}
			
		
?>