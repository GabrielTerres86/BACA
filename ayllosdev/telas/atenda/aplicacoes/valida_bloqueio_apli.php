<?php 
	//************************************************************************//
	//*** Fonte: valida_bloqueio_apli.php                                  ***//
	//*** Autor: Supero                                                    ***//
	//*** Data : Maio/2018                     �ltima Altera��o: 		   ***//
	//***                                                                  ***//
	//*** Objetivo  : Validar bloqueio de aplica��o (SM404)                ***//	
	//***                                                                  ***//	 
	//*** Altera��es: 													   ***//
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
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R")) <> "") { exibeErro($msgError); }	
	
	// Se par�metros necess�rios n�o foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nraplica"]) || !isset($_POST["tporigem"])) {		
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$nraplica = $_POST["nraplica"];
	$tporigem = $_POST["tporigem"];
	
	if($tporigem == 1){
		// Verifica se n�mero da conta � um inteiro v�lido
		if (!validaInteiro($nrdconta)) { exibeErro("Conta/dv inv&aacute;lida. Conta: " . $nrdconta); }	
		
		// Verifica se o n�mero da aplica��o � um inteiro v�lido
		if (!validaInteiro($nraplica)) { exibeErro("N&uacute;mero da aplica&ccedil;&atilde;o inv&aacute;lida.");	}	
		
		// Montar o xml de Requisicao
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>"; // C�digo da cooperativa
		$xml .= "   <nrdconta>".$nrdconta."</nrdconta>"; // N�mero da Conta
		$xml .= "   <nraplica>".$nraplica."</nraplica>"; // N�mero da Aplica��o
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
				echo 'cadastrarResgate("yes")';
			}else{
				if(isset($_SESSION['cdopelib'])){
					echo "cadastrarResgate('yes');";
				}else{
					echo "pedeSenhaCoordenador(2,'cadastrarResgate(\'yes\');','divRotina','divRotina');";
				}
				//echo "pedeSenhaCoordenador(2,'validaValorProdutoResgate(\\'cadastrarResgate(\\\\'yes\\\\');\\',\\'vlresgat\\',\\'frmResgate\\');,'divRotina','divRotina');'"
				//echo "pedeSenhaCoordenador(2,'cadastrarResgate(\"yes\");','divRotina','divRotina');";
			}
			//print_r($xmlObj);
			//var_dump($bloqueado);
		}
	}else{
		// Se par�metros necess�rios n�o foram informados
		if (!isset($_POST["cdoperad"]) || !isset($_POST["dtresgat"]) || !isset($_POST["flgctain"]) ||
			!isset($_POST["flmensag"]) || !isset($_POST["camposPc"]) || !isset($_POST["dadosPrc"]) ||
			!isset($_POST["formargt"]) || !isset($_POST["tdTotSel"])) {		
			exibeErro("Par&acirc;metros incorretos.");
		}
		
		$formargt = $_POST["formargt"];
		$flmensag = $_POST["flmensag"];
		$dtresgat = $_POST["dtresgat"];
		$flgctain = $_POST["flgctain"];
		
		echo "pedeSenhaCoordenador(2,'cadastrarVariosResgates(\"".$formargt."\", \"".$flmensag."\", \"".$nrdconta."\", \"".$dtresgat."\", \"".$flgctain."\", \"no\");','divRotina','divRotina');";
		//echo "pedeSenhaCoordenador(2,'cadastrarResgate(\"yes\");','divRotina','divRotina');";
	}
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
?>