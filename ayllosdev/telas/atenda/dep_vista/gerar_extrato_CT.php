<?php 

	/************************************************************************
	   Fonte: gerar_extrato_CT.php
	   Autor: Diego Simas (AMcom)
	   Data : Julho/2018                   Última Alteração: 

	   Objetivo  : Gerar o extrato da Bloqueado Prejuízo (Conta Transitória)

	   Alterações: 
     
	************************************************************************/
	
	session_cache_limiter("private");
	session_start();
  
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	//require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
  if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Verifica se n&uacute;mero da conta foi informado
	if (!isset($_POST["nrdconta"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	

	$nrdconta = $_POST["nrdconta"];
	
	// Verifica se n&uacute;mero da conta &eacute; um inteiro v&aacute;lido
	if (!validaInteiro($nrdconta)) {
		?><script language="javascript">alert('Conta/dv inv&aacute;lida.');</script><?php
		exit();
	}
		
	$dtiniper = isset($_POST["dtiniper"]) && validaData($_POST["dtiniper"]) ? $_POST["dtiniper"] : $glbvars["dtmvtolt"];
	$dtfimper = isset($_POST["dtfimper"]) && validaData($_POST["dtfimper"]) ? $_POST["dtfimper"] : $glbvars["dtmvtolt"];
	$dsiduser = session_id();	
  
  //Mensageria referente a lançamentos da conta transitória
  $xml  = "";
  $xml .= "<Root>";
  $xml .= "  <Dados>";
  $xml .= "    <nrdconta>".$nrdconta."</nrdconta>";
  $xml .= "    <dtiniper>".$dtiniper."</dtiniper>";
  $xml .= "    <dtfimper>".$dtfimper."</dtfimper>";
  $xml .= "  </Dados>";
  $xml .= "</Root>";

  $xmlResult = mensageria($xml, "PREJ0004", "IMPRIME_RELATO_CT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
  $xmlObjeto = getObjectXML($xmlResult);	

  // Se ocorrer um erro, mostra cr&iacute;tica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		?><script language="javascript">alert('<?php echo $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata; ?>');window.close();</script><?php
		exit();
	} 
	
	// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = getByTagName($xmlObjeto->roottag->tags,'nmarqpdf');
  	
	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);	
	
?>
