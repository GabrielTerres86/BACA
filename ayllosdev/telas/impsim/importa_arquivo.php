<? 
/*!
 * FONTE        : importa_arquivo.php
 * CRIAÇÃO      : Diogo Carlassara (Mout´S)
 * DATA CRIAÇÃO : 14/09/2017
 * OBJETIVO     : Rotina para importar arquivo do simples nacional
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

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'I')) <> ''){
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}

    $nomeArquivo = (isset($_POST['nome_arquivo'])) ? $_POST['nome_arquivo'] : 0;
	
	$xml  = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nome_arquivo>".$nomeArquivo."</nome_arquivo>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_IMPSIM", "IMPSIM_IMPORTA_ARQUIVO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;

		if ($msgErro == "") {
			$msgErro = $xmlObj->roottag->tags[0]->cdata;
		}
        exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();', false);
	}
	else{
	    exibirErro("inform","Operacao executada com sucesso!","Alerta - Ayllos","estadoInicial();", false);
    }
?>