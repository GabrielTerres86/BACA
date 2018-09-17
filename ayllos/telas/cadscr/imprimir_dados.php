<?
/*!
 * FONTE        : imprimir_dados.php						Último ajuste: 08/12/2015
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 19/10/2015
 * OBJETIVO     : Gera Arquivo da tela CADSCR.	
 * --------------
 * ALTERAÇÕES   : 08/12/2015 - Ajustes de homologação referente a conversão efetuada pela DB1
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
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : '';
	$dtsolici = (isset($_POST["dtsolici"])) ? $_POST["dtsolici"] : '';
	$dtrefere = (isset($_POST["dtrefere"])) ? $_POST["dtrefere"] : '';
	$cdhistor = (isset($_POST["cdhistor"])) ? $_POST["cdhistor"] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<dtsolici>".$dtsolici."</dtsolici>";	
	$xml .= "		<dtrefere>".$dtrefere."</dtrefere>";
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<cdhistor>".$cdhistor."</cdhistor>";
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";	
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "CADSCR", "GERAARQUIVOSCR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
		
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}
			
	$registros = $xmlObjeto->roottag->tags[0]->tags;
	
	$dsdirscr = "Arquivo gerado em: ". getByTagName($registros,'dsdirscr');
				
	exibirErro('inform',$dsdirscr,'Alerta - Ayllos','estadoInicial();',false);	
		
?>


