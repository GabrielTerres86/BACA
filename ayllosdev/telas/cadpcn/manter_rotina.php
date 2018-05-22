<?php

/* !
 * FONTE        : manter_rotina.php
 * CRIACAO      : Luis Fernando - (GFT)
 * DATA CRIACAO : 19/05/2018
 * OBJETIVO     : Rotinas de ajax para a tela CADPCN
 * --------------
 */
session_start();	
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');		
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();	

$cdcnae = (isset($_POST['cdcnae'])) ? $_POST['cdcnae'] : '';
$vlmaximo = (isset($_POST['vlmaximo'])) ? $_POST['vlmaximo'] : '';
$form = (isset($_POST['frmOpcao'])) ? $_POST['frmOpcao'] : '';
$operacao = $_POST['operacao'];

// Função para exibir erros na tela atrav&eacute;s de javascript
function exibeErro($msgErro) { 
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","focaCampoErro(\"cdcnae\",\"frmValorMaximoCnae\");");setTimeout(function(){bloqueiaFundo($("#divError"))},5);';
	exit();
}

switch ($operacao){
	case 'CONSULTA_CNAE':
		if (!validaInteiro($cdcnae) || $cdcnae == 0) exibirErro('error','Informe o c&oacute;digo CNAE.','Alerta - Ayllos','$(\'#cdcnae\', \'#'.$form.'\').focus()',false);
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Dados>";
		$xml .= "		<cdcnae>".$cdcnae."</cdcnae>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		$xmlResult = mensageria($xml, "ZOOM0001", "BUSCA_CNAE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj 	= getClassXML($xmlResult);		
		$root = $xmlObj->roottag;
		// Se ocorrer um erro, mostra crítica
		if ($root->erro){
			exibeErro(htmlentities($root->erro->registro->dscritic));
			exit;
		} 
		$dados = $root->cnae->inf;
		if(!$dados->cdcnae || $dados->cdcnae==''){
			echo '$("#cdcnae").val("").focus();';
			echo '$("#dscnae").val("");';	
			echo '$("#vlcnae").val("");';	
			exibeErro("C&oacute;digo de CNAE inv&aacute;lido.");
			exit;
		}
		echo '$("#cdcnae").val("'.$dados->cdcnae.'");';
		echo '$("#dscnae").val("'.$dados->dscnae.'");';	
	break;
	case 'CONSULTA_VALOR_CNAE':
		if (!validaInteiro($cdcnae) || $cdcnae == 0) exibirErro('error','Informe o c&oacute;digo CNAE.','Alerta - Ayllos','$(\'#cdcnae\', \'#'.$form.'\').focus()',false);
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Dados>";
		$xml .= "		<cdcnae>".$cdcnae."</cdcnae>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		$xmlResult = mensageria($xml, "CADPCN", "CADPCN_BUSCAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj 	= getClassXML($xmlResult);		

		$root = $xmlObj->roottag;
		// Se ocorrer um erro, mostra crítica
		if ($root->erro){
			exibeErro(htmlentities($root->erro->registro->dscritic));
			exit;
		} 
		$dados = $root->dados->inf;
		echo '$("#cdcnae").val("'.$dados->cdcnae.'");';
		echo '$("#vlcnae").val("'.$dados->vlmaximo.'").focus();';
	break;
	default:
			exibirErro('error','Selecione a operacao','Alerta - Ayllos','',false);
	break;
}