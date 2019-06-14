<?php
 
    /*******************************************************************************
    Fonte: impressao_historico.php
    Autor: Gabriel
    Data : Fevereiro/2011						Ultima atualizacao: 04/07/2012

    Objetivo:  Mostrar o historico de participacao em PDF.

    Ultimas alteracoes: 04/07/2012 - Ajustes no alerta de erro. (Jorge) 

    *******************************************************************************/

	session_cache_limiter("private");
    session_start();

	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nrdconta"]) ||
		!isset($_POST["inipesqu"]) ||
		!isset($_POST["finpesqu"]) ||
		!isset($_POST["idevento"]) ||
		!isset($_POST["cdevento"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$inipesqu = $_POST["inipesqu"];
	$finpesqu = $_POST["finpesqu"];
	$idevento = $_POST["idevento"];	
	$cdevento = $_POST["cdevento"];

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		?><script language="javascript">alert('Conta/dv inv&aacute;lida.');</script><?php
		exit();
	}
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($inipesqu) && ($inipesqu > 0)) {
		?><script language="javascript">alert('Ano in&iacute;cio da pesquisa inv&aacute;lido.');</script><?php
		exit();
	}

	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($finpesqu) && ($finpesqu > 0)) {
		?><script language="javascript">alert('Ano fim da pesquisa inv&aacute;lido.');</script><?php
		exit();
	}
	
	// Verifica se o c&oacute;digo do identificador do evento &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($idevento)) {
		?><script language="javascript">alert('C&oacute;digo do identificador do evento inv&aacute;lido.');</script><?php
		exit();
	}	
	
	// Verifica se o c&oacute;digo do evento &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($cdevento)) {
		?><script language="javascript">alert('C&oacute;digo do evento inv&aacute;lido.');</script><?php
		exit();
	}	

	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlGetDadosEventosHistoricoCooperado  = "";
	$xmlGetDadosEventosHistoricoCooperado .= "<Root>";
	$xmlGetDadosEventosHistoricoCooperado .= "	<Cabecalho>";
	$xmlGetDadosEventosHistoricoCooperado .= "		<Bo>b1wgen0039.p</Bo>";
	$xmlGetDadosEventosHistoricoCooperado .= "		<Proc>obtem-historico</Proc>";
	$xmlGetDadosEventosHistoricoCooperado .= "	</Cabecalho>";
	$xmlGetDadosEventosHistoricoCooperado .= "	<Dados>";
	$xmlGetDadosEventosHistoricoCooperado .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetDadosEventosHistoricoCooperado .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetDadosEventosHistoricoCooperado .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetDadosEventosHistoricoCooperado .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetDadosEventosHistoricoCooperado .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetDadosEventosHistoricoCooperado .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";  
	$xmlGetDadosEventosHistoricoCooperado .= "		<nrdconta>".$nrdconta."</nrdconta>";   
	$xmlGetDadosEventosHistoricoCooperado .= "		<inipesqu>".$inipesqu."</inipesqu>"; // Ano atual para trazer por 
	$xmlGetDadosEventosHistoricoCooperado .= "		<finpesqu>".$finpesqu."</finpesqu>"; // default os eventos do ano 
	$xmlGetDadosEventosHistoricoCooperado .= "		<idevento>".$idevento."</idevento>"; 
	$xmlGetDadosEventosHistoricoCooperado .= "		<cdevento>".$cdevento."</cdevento>";  
	$xmlGetDadosEventosHistoricoCooperado .= "		<tpimpres>I</tpimpres>"; // Impressao do PDF 
	$xmlGetDadosEventosHistoricoCooperado .= "		<idseqttl>1</idseqttl>";
	$xmlGetDadosEventosHistoricoCooperado .= "	</Dados>";
	$xmlGetDadosEventosHistoricoCooperado .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetDadosEventosHistoricoCooperado);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDadosEventosHistoricoCooperado = getObjectXML($xmlResult);
	
	// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjDadosEventosHistoricoCooperado->roottag->tags[0]->attributes["NMARQPDF"];
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjDadosEventosHistoricoCooperado->roottag->tags[0]->name) == "ERRO") {
		?><script language="javascript">alert('<?php echo $xmlObjDadosEventosHistoricoCooperado->roottag->tags[0]->tags[0]->tags[4]->cdata; ?>');</script><?php
		exit();
	} 
	
	/// Chama função para mostrar PDF do impresso gerado no browser	 
	visualizaPDF($nmarqpdf);
		
?>