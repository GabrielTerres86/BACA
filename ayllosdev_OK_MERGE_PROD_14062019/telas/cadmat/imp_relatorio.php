<?
/*!
 * FONTE        : imp_relatorio.php
 * CRIA��O      : Lucas Reinert
 * DATA CRIA��O : 06/10/2017
 * OBJETIVO     : Arquivo de entrada para impress�o da tela CADMAT
 *
 * ALTERACOES   : 
 */	 
?>

<?	
	session_cache_limiter('private');
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/dompdf/dompdf_config.inc.php');		
	require_once('../../class/xmlfile.php');
?>

<?	
	// Recebendo valores da SESS�O
	$cdcooper = $glbvars['cdcooper'];
	$cdagenci = $glbvars['cdagenci'];
	$nrdcaixa = $glbvars['nrdcaixa'];
	$cdoperad = $glbvars['cdoperad'];
	$nmdatela = $glbvars['nmdatela'];
	$idorigem = $glbvars['idorigem'];
	
	// Recebendo valores via GET
	$nrdconta = $_GET['nrdconta'];
		
	// Gerando uma chave do formul�rio
	$impchave = $nrdconta.$cdoperad;
	setcookie('impchave', $impchave, time()+60 );
	
	// Monta o xml de requisi��o
	$xmlSetPesquisa  = "";
	$xmlSetPesquisa .= "<Root>";
	$xmlSetPesquisa .= "	<Cabecalho>";
	$xmlSetPesquisa .= "		<Bo>b1wgen0052.p</Bo>";
	$xmlSetPesquisa .= "		<Proc>busca_impressao</Proc>";
	$xmlSetPesquisa .= "	</Cabecalho>";
	$xmlSetPesquisa .= "	<Dados>";
	$xmlSetPesquisa .= "        <cdcooper>".$cdcooper."</cdcooper>";
	$xmlSetPesquisa .= "		<cdagenci>".$cdagenci."</cdagenci>";
	$xmlSetPesquisa .= "		<nrdcaixa>".$nrdcaixa."</nrdcaixa>";
	$xmlSetPesquisa .= "		<cdoperad>".$cdoperad."</cdoperad>";
	$xmlSetPesquisa .= "		<nmdatela>".$nmdatela."</nmdatela>";	
	$xmlSetPesquisa .= "		<idorigem>".$idorigem."</idorigem>";	
	$xmlSetPesquisa .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetPesquisa .= "		<idseqttl>1</idseqttl>";
	$xmlSetPesquisa .= "	</Dados>";
	$xmlSetPesquisa .= "</Root>";		
	
	// Pega informa��es retornada do PROGRESS
	$xmlResult  = getDataXML($xmlSetPesquisa);	
	$xmlObjeto  = getObjectXML($xmlResult);		
	
	// Guarda as informa��es em uma vari�vel GLOBAL
	$GLOBALS['xmlObjeto'] = $xmlObjeto;
	
	$inpessoa = getByTagName($xmlObjeto->roottag->tags[0]->tags[0]->tags,'inpessoa');
	
	$navegador = CheckNavigator();
	$tipo = $navegador['navegador'] == 'chrome' ? 0 : 1;
	
	// Definindo par�metro para o m�todo "stream"
	$opcoes['Attachment'   ] = $tipo; 
	$opcoes['Accept-Ranges'] = 0;
	$opcoes['compress'     ] = 0;	
	
	$GLOBALS['totalLinha'] 	= 81;
	$GLOBALS['numLinha']	= 0;
	$GLOBALS['numPagina'] 	= 1;
	
	$GLOBALS['flagRepete'] = false;
	$GLOBALS['tprelato'] = '';

	// Gera o relat�rio em PDF atrav�s do DOMPDF
	$dompdf = new DOMPDF();	
	
	if ( $inpessoa == '1' ) {
		$dompdf->load_html_file( './imp_relatorio_pf_html.php' );
	} else {
		$dompdf->load_html_file( './imp_relatorio_pj_html.php' );
	}
	
	$dompdf->set_paper('a4');
	$dompdf->render();
	$dompdf->stream('relatorio_'.$impchave.'.pdf', $opcoes );
?>