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
			echo '$("#vlcnae").val("");';	
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
		$json = array();
		if ($root->erro){
			$json["vlcnae"] 	= "";
			$json["status"] 	= "erro";
			$json["mensagem"] 	= htmlentities($root->erro->registro->dscritic);
		} 
		else{
			$dados = $root->dados->inf;
			$json["cdcnae"] 	= $dados->cdcnae->cdata;
			$json["vlcnae"] 	= number_format($dados->vlmaximo->cdata+0, 2, ',', '.');
			$json["status"] 	= "sucesso";
		}
		echo json_encode($json);
	break;
	default:
			exibirErro('error','Selecione a operacao','Alerta - Ayllos','',false);
	break;
}