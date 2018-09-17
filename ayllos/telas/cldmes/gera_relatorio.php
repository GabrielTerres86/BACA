<?php
	/******************************************************************************************
	 Fonte: gera_relatorio.php                                                       
	 Autor: Cristian Filipe (GATI)                                                   
	 Data : outubro/2013                                          Última alteração:22/12/2014
	 Objetivo  : Gera Relatorio tela CLDMES	                                         
	                                                                                 
	 Alterações: 25/11/2014 - Ajuste para liberação (Adriano).
	             22/12/2014 - Adicionar validação de parametros (Douglas - Chamado 143945)

	******************************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Verifica Permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$_POST['cddopcao'])) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();
	}
	
	if(!isset($_POST['nrdconta']) || !isset($_POST['tdtmvtol'])){
		?><script language="javascript">alert('Parametros invalidos');</script><?php
		exit();
	}

	// Verifica se os par&acirc;metros necess&aacute;rios foram informados
	$nrdconta = $_POST['nrdconta'];
	if (!validaInteiro($nrdconta)) {
		?><script language="javascript">alert('Numero da conta invalida');</script><?php
		exit();
	}
	
	$tdtmvtol = $_POST['tdtmvtol'];
	if (!validaData($tdtmvtol)) {
		?><script language="javascript">alert('Data invalida');</script><?php
		exit();
	}

	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0174.p</Bo>";
	$xml .= "        <Proc>gera_relatorio_diario</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= "        <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "        <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "        <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "        <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "        <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "        <idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "        <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "        <cdprogra>".$glbvars["cdprogra"]."</cdprogra>";
	$xml .= "        <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "        <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "        <tdtmvtol>".$tdtmvtol."</tdtmvtol>";
	$xml .= "        <texecweb>yes</texecweb>";
	$xml .= "        <tpimprim>yes</tpimprim>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";	

    // Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	$xmlObj = getObjectXML($xmlResult);
			
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;		
		exibeErro($msg);
	}
	
	// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObj->roottag->tags[0]->attributes["NMARQPDF"];
	visualizaPDF($nmarqpdf);
	
	function exibeErro($msgErro) {
		?><script language="javascript">alert('<?php echo $msgErro; ?>');</script><?php
		exit();
	}

?>