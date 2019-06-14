<?php 
	//**************************************************************************//
	//*** Fonte: aplicacoes_programadas_valida_bloqueio.php                  ***//
	//*** Autor: Supero                                                      ***//
	//*** Data : Maio/2018                     �ltima Altera��o: 27/07/2018  ***//
	//***                                                                    ***//
	//*** Objetivo  : Validar bloqueio de poupan�a programada (SM404)        ***//	
	//***                                                                    ***//	 
	//*** Altera��es: 27/07/2018 - Deriva��o para Aplica��o Programada       ***//
	//***                          (Proj. 411.2 - CIS Corporate)             ***// 
	//***																     ***//	
	//**************************************************************************//

	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"G")) <> "") { exibeErro($msgError); }	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"])) {		
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];
	
	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) { exibeErro("Conta/dv inv&aacute;lida. Conta: " . $nrdconta); }	
	
	// Verifica se o n�mero da aplica��o � um inteiro v�lido
	if (!validaInteiro($nrctrrpp)) { exibeErro("N&uacute;mero de contrato inv&aacute;lido.");	}	
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>"; // C�digo da cooperativa
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>"; // N�mero da Conta
	$xml .= "   <nraplica>".$nrctrrpp."</nraplica>"; // N�mero do Contrato
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "APLI0002", "VALIDA_BLOQUEIO_APLI", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibeErro($msgErro,$frm);			
		exit();
	}else{
		$bloqueado = $xmlObj->roottag->cdata;
		echo 'hideMsgAguardo();';
		if($bloqueado == '0'){
			echo 'validarResgate()';
		}else{
			echo "pedeSenhaCoordenador(2,'validarResgate();','divRotina','divRotina');";
		}
		//print_r($xmlObj);
		//var_dump($bloqueado);
	}
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
?>
