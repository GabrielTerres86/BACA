<?php 

	//************************************************************************//
	//*** Fonte: agendamento_validar_parametros.php                        ***//
	//*** Autor: Douglas Quisinski                                         ***//
	//*** Data : Outubro/2014                 �ltima Altera��o: 28/10/2014 ***//
	//***                                                                  ***//
	//*** Objetivo  : Valida��o dos parametros do agendamento de aplica��o ***//	
	//***             e resgate                                            ***//	
	//***                                                                  ***//	 
	//*** Altera��es: 28/10/2014 - Adicionar parametro qtdiaven (Douglas - ***//
	//***                          Projeto Capta��o Internet 2014/2)       ***//
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"G")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Primeiro vamos validar apenas os parametros do numero da conta e o tipo de agendamento (0 - Aplicacao / 1 - Resgate)
	if (!isset($_POST["nrdconta"]) || !isset($_POST["flgtipar"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$flgtipar = $_POST["flgtipar"];	
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se tipo de agendamendo � v�lido
	if (!validaInteiro($flgtipar) || $flgtipar < 0 || $flgtipar > 1) {
		exibeErro("Tipo de agendamento inv&aacute;lido.");
	}	
	
	// Verificar os campos comuns aos dois tipos de agendamento
	if (!isset($_POST["vlparaar"]) || !isset($_POST["flgtipin"]) || !isset($_POST["dtiniaar"]) ||
		!isset($_POST["dtdiaaar"]) || !isset($_POST["qtmesaar"])) {	
		exibeErro("Par&acirc;metros incorretos.");
	}

	$vlparaar = $_POST["vlparaar"];	
	$flgtipin = $_POST["flgtipin"];
	$dtiniaar = $_POST["dtiniaar"];
	$dtdiaaar = $_POST["dtdiaaar"];
	$qtmesaar = $_POST["qtmesaar"];
	
	// Verifica se o valor de agendamento � um inteiro v�lido
	if (!validaDecimal($vlparaar)) {
		exibeErro("Valor do agendamento inv&aacute;lido.");
	}

	// Verifica se a car�ncia � um inteiro
	if (!validaInteiro($flgtipin) || $flgtipin < 0 || $flgtipin > 1) {
		exibeErro("Car&ecirc;ncia inv&aacute;lida.");
	}	
	
	if($flgtipin == 0){ // Tipo de car�ncia UNICA
		// Verifica se a data de resgate � v�lida
		if (!validaData($dtiniaar)) {
			exibeErro("Data inv&aacute;lida.");
		}else{
			$qtmesaar = 1;
		}
	} else { // Tipo de car�ncia MENSAL
		if (!validaInteiro($dtdiaaar)) {
			exibeErro("Dia inv&aacute;lida.");
		}
		
		if($dtdiaaar < 0 || $dtdiaaar > 28){
			exibeErro("Agendamento permitido apenas at&eacute; o dia 28 de cada m&ecirc;s!");
		}
		
		if (!validaInteiro($qtmesaar)) {
			exibeErro("Quantidade de meses inv&aacute;lido.");
		}
	}
	
	//Se o tipo de agendamento eh por aplicacao, valida os campos especificos
	if ($flgtipar == 0) {
		if (!isset($_POST["qtdiacar"]) || !isset($_POST["dtvencto"]) || !isset($_POST["qtdiaven"])) {	
			exibeErro("Par&acirc;metros incorretos.");
		}

		$qtdiacar = $_POST["qtdiacar"];	
		$dtvencto = $_POST["dtvencto"];
		$qtdiaven = $_POST["qtdiaven"];	
	
		if (!validaInteiro($qtdiacar)) {
			exibeErro("Car&ecirc;ncia inv&aacute;lida.");
		}

		if (!validaData($dtvencto)) {
			exibeErro("Data de vencimento inv&aacute;lida.");
		}

		if (!validaInteiro($qtdiaven)) {
			exibeErro("Quantidade de dias de vencimento inv&aacute;lido.");
		}
		
	} else {
		// Criar as variaveis sem valor quando agendamento de resgate
		$qtdiacar = 0;
		$dtvencto = null;
		$qtdiaven = 0;
	}
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
?>