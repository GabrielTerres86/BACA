<?php 

	//************************************************************************//
	//*** Fonte: resgate_valida_limite_operador.php                        ***//
	//*** Autor: Tiago                                                     ***//
	//*** Data : Junho/2015                   �ltima Altera��o: 03/06/2015 ***//
	//***                                                                  ***//
	//*** Objetivo  : Validar limite de resgate d           ***//	
	//***                                                                  ***//	 
	//*** Altera��es:                                                      ***//
	//***																   ***//	
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R")) <> "") {
		exibeErro($msgError);		
	}	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["vlresgat"]) || !isset($_POST["cdopera2"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nrdconta = $_POST["nrdconta"];
	$vlresgat = $_POST["vlresgat"];
	$cdopera2 = (isset($_POST['cdopera2'])) ? $_POST['cdopera2'] : $glbvars["cdoperad"];
	
	if(trim($cdopera2) == ''){
		$cdopera2 = $glbvars["cdoperad"];
	}
	
	$cddsenha = (isset($_POST['cddsenha'])) ? $_POST['cddsenha'] : '';
	$flgsenha = ($cdopera2 != $glbvars["cdoperad"]) ? '1' : '0';	
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}	
	
	// Verifica se o valor de resgate � um inteiro v�lido
	if (!validaDecimal($vlresgat)) {
		exibeErro("Valor do resgate inv&aacute;lido.");
	}

	$vlresgat = str_replace(',','.',str_replace('.','',$vlresgat));
	

	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>"; // N�mero da Conta	
	$xml .= "   <vlrrsgat>".$vlresgat."</vlrrsgat>"; // Valor do Resgate (Valor informado em tela)
	$xml .= "   <cdopera2>".$cdopera2."</cdopera2>"; // Operador
	$xml .= "   <cddsenha>".$cddsenha."</cddsenha>"; // Senha
	$xml .= "   <flgsenha>".$flgsenha."</flgsenha>"; // Flag validar senha
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "ATENDA", "VALLIMOPE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
					
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		echo 'flgerror = true;';
		exibeErro($msgErro);			
		exit();
	}
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 		
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
	
?>