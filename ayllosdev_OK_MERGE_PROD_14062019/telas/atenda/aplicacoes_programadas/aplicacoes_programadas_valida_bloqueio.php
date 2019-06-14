<?php 
	//**************************************************************************//
	//*** Fonte: aplicacoes_programadas_valida_bloqueio.php                  ***//
	//*** Autor: Supero                                                      ***//
	//*** Data : Maio/2018                     Última Alteração: 27/07/2018  ***//
	//***                                                                    ***//
	//*** Objetivo  : Validar bloqueio de poupança programada (SM404)        ***//	
	//***                                                                    ***//	 
	//*** Alterações: 27/07/2018 - Derivação para Aplicação Programada       ***//
	//***                          (Proj. 411.2 - CIS Corporate)             ***// 
	//***																     ***//	
	//**************************************************************************//

	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"G")) <> "") { exibeErro($msgError); }	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nrctrrpp"])) {		
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$nrctrrpp = $_POST["nrctrrpp"];
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) { exibeErro("Conta/dv inv&aacute;lida. Conta: " . $nrdconta); }	
	
	// Verifica se o número da aplicação é um inteiro válido
	if (!validaInteiro($nrctrrpp)) { exibeErro("N&uacute;mero de contrato inv&aacute;lido.");	}	
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>"; // Código da cooperativa
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>"; // Número da Conta
	$xml .= "   <nraplica>".$nrctrrpp."</nraplica>"; // Número do Contrato
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
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
?>
