<?php 

	/************************************************************************
	  Fonte: validar_impressao_extrato_CT.php
	  Autor: Diego Simas (AMcom)
	  Data : Julho/2018                    Última Alteração: 

	  Objetivo  : Validar impressão do extrato dos lançamentos da conta transitória.

	  Alterações: 
    
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["dtiniper"]) || !isset($_POST["dtfimper"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$dtiniper = $_POST["dtiniper"];   
	$dtfimper = $_POST["dtfimper"];	

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se data inicial é válida
	if (!validaData($dtiniper)) {
		exibeErro("Data inicial inv&aacute;lida.");
	}
	
	// Verifica se data final é válida
	if (!validaData($dtfimper)) {
		exibeErro("Data final inv&aacute;lida.");
	}
  
    $hideblock = 'hideMsgAguardo();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));';
	
	$gerarimpr = 'imprimirExtratoCT();';	
		
	echo 'showConfirmacao("Deseja visualizar a impress&atilde;o?","Confirma&ccedil;&atilde;o - Ayllos","'.$hideblock.$gerarimpr.'","'.$hideblock.'","sim.gif","nao.gif");';// Efetua a impressão do termo de solicitação de 2 via de senha
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}

?>
