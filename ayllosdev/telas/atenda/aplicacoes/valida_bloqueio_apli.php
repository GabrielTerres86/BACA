<?php 
	//************************************************************************//
	//*** Fonte: valida_bloqueio_apli.php                                  ***//
	//*** Autor: Supero                                                    ***//
	//*** Data : Maio/2018                     Última Alteração: 		   ***//
	//***                                                                  ***//
	//*** Objetivo  : Validar bloqueio de aplicação (SM404)                ***//	
	//***                                                                  ***//	 
	//*** Alterações: 													   ***//
	//***																   ***//	
	//************************************************************************//

	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");	
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R")) <> "") { exibeErro($msgError); }	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nrdconta"]) || !isset($_POST["nraplica"]) || !isset($_POST["tporigem"])) {		
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$nrdconta = $_POST["nrdconta"];
	$nraplica = $_POST["nraplica"];
	$tporigem = $_POST["tporigem"];
	
	if($tporigem == 1){
		// Verifica se número da conta é um inteiro válido
		if (!validaInteiro($nrdconta)) { exibeErro("Conta/dv inv&aacute;lida. Conta: " . $nrdconta); }	
		
		// Verifica se o número da aplicação é um inteiro válido
		if (!validaInteiro($nraplica)) { exibeErro("N&uacute;mero da aplica&ccedil;&atilde;o inv&aacute;lida.");	}	
		
		// Montar o xml de Requisicao
		$xml .= "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>"; // Código da cooperativa
		$xml .= "   <nrdconta>".$nrdconta."</nrdconta>"; // Número da Conta
		$xml .= "   <nraplica>".$nraplica."</nraplica>"; // Número da Aplicação
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
		// Se parâmetros necessários não foram informados
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
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
?>