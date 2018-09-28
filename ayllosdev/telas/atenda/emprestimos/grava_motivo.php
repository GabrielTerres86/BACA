<? 
/*!
 * FONTE        : titulos_limite_grava_motivo.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : Agosto/2018
 * OBJETIVO     : Gravar motivo de anulação	             		        				   
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>

<?php 

	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");			  

	$nrdconta     = (isset($_POST['nrdconta'])) 	? $_POST['nrdconta'] 	 : 0 ;
	$nrctremp     = (isset($_POST['nrctremp'])) 	? $_POST['nrctremp'] 	 : 0 ;
	$cdmotivo     = (isset($_POST['cdmotivo'])) 	? $_POST['cdmotivo'] 	 : 0 ;
	$dsmotivo     = (isset($_POST['dsmotivo'])) 	? $_POST['dsmotivo'] 	 : '' ;
	$dsobservacao = (isset($_POST['dsobservacao'])) ? $_POST['dsobservacao'] : '' ;

	// Arrumar os acentos
	$dsmotivo = utf8_decode($dsmotivo);
	$dsobservacao = utf8_decode($dsobservacao);
	
	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		exibeErro("Conta/dv inv&aacute;lida.");
	}

	// Verifica se o número do contrato é um inteiro válido
	if (!validaInteiro($nrctremp)) {
		exibeErro("N&uacute;mero do contrato inv&aacute;lido.");
	}

	// Verifica se o preencheu o motivo
	if (!validaInteiro($cdmotivo) || $cdmotivo == 0) {
		exibeErro("Motivo inv&aacute;lido.");
	}

	// Montar o xml de Requisicao
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <tpproduto>1</tpproduto>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrctrato>".$nrctremp."</nrctrato>";
	$xml .= "   <tpctrlim></tpctrlim>";
	$xml .= "   <cdmotivo>".$cdmotivo."</cdmotivo>";
	$xml .= "   <dsmotivo>".$dsmotivo."</dsmotivo>";
	$xml .= "   <dsobservacao>".$dsobservacao."</dsobservacao>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "EMPR0001", "EMPR0001_GRAVA_MOTIVO_ANULACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);	
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 	
	
	$msgErro = 'Motivo salvo com sucesso.';
	exibirErro('inform',$msgErro,'Alerta - Aimaro','fechaMotivos();',false);
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}
		
	
?>
