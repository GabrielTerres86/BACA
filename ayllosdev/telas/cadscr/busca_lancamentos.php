<?
/*!
 * FONTE        : busca_lancamentos.php									�ltimo ajuste: 08/12/2015
 * CRIA��O      : J�ssica - DB1
 * DATA CRIA��O : 09/10/2015
 * OBJETIVO     : Rotina para buscar os dados dos lancamentos scr da tela CADSCR
 * --------------
 * ALTERA��ES   : 08/12/2015 - Ajustes de homologa��o referente a convers�o efetuada pela DB1
							  (Adriano).
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

	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	$operacao = (isset($_POST["operacao"])) ? $_POST["operacao"] : '';
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : '';
	$dtsolici = (isset($_POST["dtsolici"])) ? $_POST["dtsolici"] : '';
	$dtrefere = (isset($_POST["dtrefere"])) ? $_POST["dtrefere"] : '';
	$cdhistor = (isset($_POST["cdhistor"])) ? $_POST["cdhistor"] : '';
	$nrregist = (isset($_POST["nrregist"])) ? $_POST["nrregist"] : 30;
	$nriniseq = (isset($_POST["nriniseq"])) ? $_POST["nriniseq"] : 1;
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisi��o
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<dtsolici>".$dtsolici."</dtsolici>";
	$xml .= "		<dtrefere>".$dtrefere."</dtrefere>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<cdhistor>".$cdhistor."</cdhistor>";
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "		<flgvalid>1</flgvalid>";
	$xml .= "		<nrregist>".$nrregist."</nrregist>";
	$xml .= "		<nriniseq>".$nriniseq."</nriniseq>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "CADSCR", "BUSCALANCAMENTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','btnVoltar();');
	}
		
	$registros = $xmlObjeto->roottag->tags;
	$qtregist  = $xmlObjeto->roottag->attributes["QTREGIST"];
	
	include('tab_lancamento_grava.php');
?>