<? 
/*!
 * FONTE        : importa_arquivo.php
 * CRIAÇÃO      : Jean Calao (Mout´S)
 * DATA CRIAÇÃO : 20/07/2017
 * OBJETIVO     : Rotina para importar arquivo com contas/contratos para forçar envio para prejuizo
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		

	/*if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'F')) <> ''){
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}
		*/
    $nrdconta = (isset($_POST['nmdarqui'])) ? $_POST['nmdarqui'] : 0;
	
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nmdarqui>".$nrdconta."</nmdarqui>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
    
	$xmlResult = mensageria($xml, "PREJU", "IMPORTA_ARQUIVO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	
		
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		if ($msgErro == "") {
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
		}
		exibeErroNew($msgErro);
	
	}
	exibirErro('inform','Operacao executada com sucesso...','Alerta - Ayllos','estadoInicial();');
	
function exibeErroNew($msgErro) {	
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","trocaBotao(\'estadoInicial()\',\'ajustaBotaoContinuar()\',\'Continuar\');$(\'#nrctremp\',\'#frmEstornoPrejuizo\').focus();");';
	exit();
}	
	
?>