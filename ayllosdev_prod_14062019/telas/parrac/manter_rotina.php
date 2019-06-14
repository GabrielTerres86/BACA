<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Jonata Cardoso (RKAM)       
 * DATA CRIAÇÃO : 10/12/2014
 * OBJETIVO     : Rotina para alteracao, exclusao e inclusao da tela PARMCR
 * --------------
 * ALTERAÇÕES   : 
 */
?> 

<?	
	session_cache_limiter("private");
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();			
	
	// Recebe os parametros
	$cdcooper      = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0  ; 
	$cddopcao      = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$operacao      = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ; 
	$nrseqvac      = (isset($_POST['nrseqvac'])) ? $_POST['nrseqvac'] : 0  ; 
	$nrseqqac      = (isset($_POST['nrseqqac'])) ? $_POST['nrseqqac'] : 0  ; 
	$nrseqiac      = (isset($_POST['nrseqiac'])) ? $_POST['nrseqiac'] : 0  ;
	$dsversao      = (isset($_POST['dsversao'])) ? $_POST['dsversao'] : '' ; 
	$dtinivig      = (isset($_POST['dtinivig'])) ? $_POST['dtinivig'] : '' ; 
	$dsmensag      = (isset($_POST['dsmensag'])) ? $_POST['dsmensag'] : '' ; 
	$inmensag      = (isset($_POST['inmensag'])) ? $_POST['inmensag'] : 0 ; 
	$instatus      = (isset($_POST['instatus'])) ? $_POST['instatus'] : 0 ; 
	$vlparam2      = (isset($_POST['vlparam2'])) ? $_POST['vlparam2'] : '' ; 
	$vlparam1      = (isset($_POST['vlparam1'])) ? $_POST['vlparam1'] : '' ; 
	$inparece      = (isset($_POST['inparece'])) ? $_POST['inparece'] : '' ; 
	
	$dsversao = retiraAcentos($dsversao);
	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$new_operacao = '';
	
	// Setar a rotina a chamar no Oracle
	if (in_array($operacao,array("I_crapvac_3","A_crapvac_3","E_crapvac_2"))) {
		$strnomacao = 'CRAPVAC'; 
		$new_operacao = 'C1';
	}
	else
	if (in_array($operacao,array("I_crapqac_2","A_crapqac_2"))) {
		$strnomacao = 'CRAPQAC'; 
		$new_operacao = '';
	}
	else
	if ($operacao == 'D_crapvac_3' ) {
		$strnomacao = 'COPIAR_VERSAO_CRAPVAC'; 
		$new_operacao = 'C1';
	}
	else
	if ($operacao == 'D_crapvac_6') {
		$strnomacao = 'CRIA_VERSAO_CRAPVAC'; 
		$new_operacao = 'C1';
	}
	else
	if ($operacao == 'V_questionario') {
		$strnomacao = 'VALIDA_QUESTIONARIO'; 
	}
	else
	if ($operacao == 'A_parecer_2') {
		$strnomacao = 'DESABILITA_PARECER_RATING';
		$new_operacao = 'C1'; 
	}
	
	$inmensag = ($inmensag == '') ? 1 : $inmensag;
		
	// Montar o xml para requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "    <cdcopdst>".$cdcooper."</cdcopdst>";
	$xml .= "    <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xml .= "    <cdoperad>".$glbvars['cdoperad']."</cdoperad>";
	$xml .= "    <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "    <nrseqvac>".$nrseqvac."</nrseqvac>";
	$xml .= "    <nrseqqac>".$nrseqqac."</nrseqqac>";
	$xml .= "    <dsversao>".$dsversao."</dsversao>";
	$xml .= "    <dtinivig>".$dtinivig."</dtinivig>";
	$xml .= "    <dsmensag>".$dsmensag."</dsmensag>";
	$xml .= "    <inmensag>".$inmensag."</inmensag>";
	$xml .= "    <instatus>".$instatus."</instatus>";
	$xml .= "    <vlparam2>".$vlparam2."</vlparam2>";
	$xml .= "    <vlparam1>".$vlparam1."</vlparam1>";
	$xml .= "    <nrordper>".$nrordper."</nrordper>";
	$xml .= "    <nrseqiac>".$nrseqiac."</nrseqiac>";
	$xml .= "    <inpessoa>".$inpessoa."</inpessoa>";
	$xml .= "    <inparece>".$inparece."</inparece>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
 
	$xmlResult = mensageria($xml, "PARRAC", $strnomacao, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
	$xml_dados = simplexml_load_string($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
 	if ($xml_dados->Erro->Registro->dscritic != "") {
	
		if (in_array($operacao,array('A_crapvac_3','D_crapvac_3','D_crapvac_6','I_crapvac_3'))) {
			$metodo = "blockBackground(parseInt($('#divRotina').css('z-index')));";		
		} else {
			$metodo = "";
		}
	
	    exibirErro('error',str_replace('"',"'",$xml_dados->Erro->Registro->dscritic),'Alerta - Ayllos',$metodo,false);	
    }
	
	$dsdmensa = '';
	
	if ($cddopcao == 'E' && $operacao != 'A_crapqac_2')
		$dsdmensa = 'Exclus&atilde;o ';
	else	
	if ($operacao == 'D_crapvac_3' || $operacao == 'D_crapvac_6')
		$dsdmensa = 'Duplica&ccedil;&atilde;o ';
		
	if ($dsdmensa != '' || $operacao == 'A_crapvac_3' || $operacao == 'I_crapvac_3') {
	
		echo "fechaOpcao();";
		
		if ($dsdmensa != '') {
			$dsdmensa .= 'efetuada com sucesso!';		
			exibirErro('inform',$dsdmensa,'Alerta - Ayllos','unblockBackground();',false);
		}
		
	}
	
	if ($xml_dados->nrseqvac != '') {
		$nrseqvac = $xml_dados->nrseqvac;
	} else {
		$nrseqvac = 0;
	}	
		
	if ($new_operacao == 'C1') {
		echo "controlaOperacao('$new_operacao','$nrseqvac');";
	}
	
	if ($operacao == 'I_crapvac_3') {
		echo "cddopcao = 'A';";
	}
	
	if ($operacao == 'A_crapqac_3' || $operacao == 'A_crapqac_2') {
		echo "cddopcao = 'C';";
	}
	
	if ($operacao == 'V_questionario') {
				
		$metodo = '';
		$msg = array();
		$mensagem = '';
		
		if (count($xml_dados->dscritic) == 0) {
			$mensagem = "Questionario validado com sucesso.";
		}
		else {
			for ($i=0; $i < count($xml_dados->dscritic); $i++) {
				$mensagem .= $xml_dados->dscritic[$i] . '</br>';
			}
		}
		
		$msg[] = $mensagem;
		
		$stringArrayMsg = implode("|", $msg);
		
		echo 'exibirMensagens(\''.$stringArrayMsg.'\',\''.$metodo.'\');';
	}
	
?>