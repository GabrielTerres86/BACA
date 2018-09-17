<? 
/*!
 * FONTE        : altera_data_informativo.php
 * CRIAÇÃO      : Lucas Lombardi
 * DATA CRIAÇÃO : 10/08/2016
 * OBJETIVO     : Rotina para alteração da data informativo da tela IMPPRE
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
	
	$dtapinco = (isset($_POST['dtapinco'])) ? $_POST['dtapinco'] : '';
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'I')) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','estadoInicial();',false);
	}
	
	// Monta o xml de requisicao
	$xml  = "";
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <dtapinco>".$dtapinco."</dtapinco>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "TELA_SOL030", "ALTERA_DATA_INFORM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
			$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		}
		exibirErro('error',htmlentities($msgErro),'Alerta - Ayllos',"",false);
	}
	$dados = $xmlObjeto->roottag->tags[0]->cdata;
	
	echo "estadoInicial();";
?>