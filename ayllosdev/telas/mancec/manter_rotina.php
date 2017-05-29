<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 18/10/2016
 * OBJETIVO     : Rotina para manter as operações da tela MANCEC
 * --------------
 * ALTERAÇÕES   :  
 * -------------- 
 */
?> 

<?
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

// Recebe a operação que está sendo realizada
$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
$cdcmpchq = (isset($_POST['cdcmpchq'])) ? $_POST['cdcmpchq'] : 0;
$cdbanchq = (isset($_POST['cdbanchq'])) ? $_POST['cdbanchq'] : 0;
$cdagechq = (isset($_POST['cdagechq'])) ? $_POST['cdagechq'] : 0;
$nrctachq = (isset($_POST['nrctachq'])) ? $_POST['nrctachq'] : 0;
$nmemichq = (isset($_POST['nmemichq'])) ? $_POST['nmemichq'] : '';
$nrcpfchq = (isset($_POST['nrcpfchq'])) ? $_POST['nrcpfchq'] : 0;


	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>" . $cddopcao . "</cddopcao>";
	$xml .= "   <cdcmpchq>" . $cdcmpchq . "</cdcmpchq>";
	$xml .= "   <cdbanchq>" . $cdbanchq . "</cdbanchq>";
	$xml .= "   <cdagechq>" . $cdagechq . "</cdagechq>";
	$xml .= "   <nrctachq>" . $nrctachq . "</nrctachq>";
	$xml .= "   <nmemichq>" . $nmemichq . "</nmemichq>";
	$xml .= "   <nrcpfchq>" . $nrcpfchq . "</nrcpfchq>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_MANCEC", "MANCEC_GRAVAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
		}

		exibeErroNew($msgErro);
		exit();
	} 
	
	if ( $cddopcao == 'A' ){
		echo 'showError("inform","Emitente Alterado com Sucesso.","Notifica&ccedil;&atilde;o - Ayllos","estadoInicial();");';		
	}
	
	if ( $cddopcao == 'E' ){
		echo 'showError("inform","Emitente Excluido com Sucesso.","Notifica&ccedil;&atilde;o - Ayllos","estadoInicial();");';		
	}
	
	if ( $cddopcao == 'I' ){
		echo 'showError("inform","Emitente Incluso com Sucesso.","Notifica&ccedil;&atilde;o - Ayllos","estadoInicial();");';		
	}
	
	function exibeErroNew($msgErro) {
      echo 'hideMsgAguardo();';
      echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
      exit();
	}
?>