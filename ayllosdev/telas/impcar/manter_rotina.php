<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : 23/03/2016
 * OBJETIVO     : Rotina para importacao dos arquivos do bancoob
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

	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}	
	
	// Monta o xml de requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";			
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "IMPCAR", "IMPCAR_IMPORTAR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos',"estadoInicial();",false);
	}
	echo "hideMsgAguardo();";
	echo 'showError("inform","Aguarde o termino da importa&ccedil;&atilde;o!","Alerta - Ayllos","fechaRotina($(\'#divRotina\'));eventTipoOpcao();");';
?>