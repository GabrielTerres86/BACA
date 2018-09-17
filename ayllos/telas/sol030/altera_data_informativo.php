<? 
/*!
 * FONTE        : altera_data_informativo.php
 * CRIA��O      : Lucas Lombardi
 * DATA CRIA��O : 10/08/2016
 * OBJETIVO     : Rotina para altera��o da data informativo da tela IMPPRE
 * --------------
 * ALTERA��ES   : 
 * -------------- 
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	$dtapinco = (isset($_POST['dtapinco'])) ? $_POST['dtapinco'] : '';
	
	// Carrega permiss�es do operador
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