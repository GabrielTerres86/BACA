<?php 

	/************************************************************************
	  Fonte: imprimir_anotacoes.php
	  Autor: Guilherme
	  Data : Julho/2008                 �ltima Altera��o: 18/03/2011

	  Objetivo  : Gerar o impresso das anota��es da conta

	  Altera��es: 18/03/2011 - Utilizar nova BO (David).
	************************************************************************/
	
	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Verifica Permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	
	
	// Verifica se os par�metros necess�rios foram informados
	if (!isset($_POST["nrdconta"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	

	$nrdconta = formataNumericos("99999999",$_POST["nrdconta"],"");	

	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		?><script language="javascript">alert('Conta/dv inv&aacute;lida.');</script><?php
		exit();
	}
	
	$dsiduser = session_id();
	
	// Monta o xml de requisi&ccedil;&atilde;o
	$xmlAnotacoes  = "";
	$xmlAnotacoes .= "<Root>";
	$xmlAnotacoes .= "  <Cabecalho>";
	$xmlAnotacoes .= "	  <Bo>b1wgen0085.p</Bo>";
	$xmlAnotacoes .= "    <Proc>Gera_Impressao</Proc>";
	$xmlAnotacoes .= "  </Cabecalho>";
	$xmlAnotacoes .= "  <Dados>";
	$xmlAnotacoes .= "      <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlAnotacoes .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlAnotacoes .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlAnotacoes .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlAnotacoes .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlAnotacoes .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlAnotacoes .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlAnotacoes .= "		<nrdconta>".$nrdconta."</nrdconta>";	
	$xmlAnotacoes .= "		<idseqttl>1</idseqttl>";	
	$xmlAnotacoes .= "		<nrseqdig>0</nrseqdig>";	
	$xmlAnotacoes .= "		<dsiduser>".$dsiduser."</dsiduser>";			
	$xmlAnotacoes .= "  </Dados>";
	$xmlAnotacoes .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlAnotacoes);

	// Cria objeto para classe de tratamento de XML
	$xmlObjAnotacoes = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjAnotacoes->roottag->tags[0]->name) == "ERRO") {
		?><script language="javascript">alert('<?php echo $xmlObjAnotacoes->roottag->tags[0]->tags[0]->tags[4]->cdata; ?>');</script><?php
		exit();
	} 
	
	// Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjAnotacoes->roottag->tags[0]->attributes["NMARQPDF"];
	
	// Chama fun��o para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);	

?>
