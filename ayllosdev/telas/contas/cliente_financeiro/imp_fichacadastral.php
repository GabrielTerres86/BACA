<?
/*!
 * FONTE        : imp_fichacadastral.php
 * CRIA��O      : Rodolpho Telmo (DB1)
 * DATA CRIA��O : 08/04/2010 
 * OBJETIVO     : Respons�vel por chamar a classe DOMPDF que gera o PDF da Ficha cadastral
 *
 * ALTERACOES   : 12/07/2012 - Alterado parametro "Attachment" conforme for navegador (Jorge).
 */	 
?>

<?	
	session_cache_limiter('private');
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/dompdf/dompdf_config.inc.php');		
	require_once('../../../class/xmlfile.php');

	// Recebendo valores da SESS�O
	$cdcooper = $glbvars['cdcooper'];
	$cdagenci = $glbvars['cdagenci'];
	$nrdcaixa = $glbvars['nrdcaixa'];
	$cdoperad = $glbvars['cdoperad'];
	$nmdatela = $glbvars['nmdatela'];
	$idorigem = $glbvars['idorigem'];
    $dsdepart = $glbvars['dsdepart'];	

	// Recebendo valores via POST
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '';
	$tpregist = (isset($_POST['tpregist'])) ? $_POST['tpregist'] : '';
	$nrseqdig = (isset($_POST['nrseqdig'])) ? $_POST['nrseqdig'] : '';	
	$nrdrowid = (isset($_POST['nrdrowid'])) ? $_POST['nrdrowid'] : '';		
	
	// Retirando caracteres do CPF e CNPJ
	$arrayRetirada = array('.','-','/');                                                        
	$nrcpfcgc = str_replace($arrayRetirada,'',$nrcpfcgc);
	$nrdconta = str_replace($arrayRetirada,'',$nrdconta);
	
	// Gerando uma chave do formul�rio
	$impchave = $nrdconta.$idseqttl.$nrseqdig;
	setcookie('impchave', $impchave, time()+60 );	
	
	// Monta o XML de requisi��o
	$xmlSetPesquisa  = '';
	$xmlSetPesquisa .= '<Root>';
	$xmlSetPesquisa .= '	<Cabecalho>';
	$xmlSetPesquisa .= '		<Bo>b1wgen0061.p</Bo>';
	$xmlSetPesquisa .= '		<Proc>busca_impressao</Proc>';
	$xmlSetPesquisa .= '	</Cabecalho>';
	$xmlSetPesquisa .= '	<Dados>';
	$xmlSetPesquisa .= '        <cdcooper>'.$cdcooper.'</cdcooper>';
	$xmlSetPesquisa .= '		<cdagenci>'.$cdagenci.'</cdagenci>';
	$xmlSetPesquisa .= '		<nrdcaixa>'.$nrdcaixa.'</nrdcaixa>';
	$xmlSetPesquisa .= '		<cdoperad>'.$cdoperad.'</cdoperad>';
	$xmlSetPesquisa .= '		<nmdatela>'.$nmdatela.'</nmdatela>';	
	$xmlSetPesquisa .= '		<idorigem>'.$idorigem.'</idorigem>';	
	$xmlSetPesquisa .= '		<dsdepart>'.$dsdepart.'</dsdepart>';	
	$xmlSetPesquisa .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xmlSetPesquisa .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
    $xmlSetPesquisa .= '		<nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
	$xmlSetPesquisa .= '		<tpregist>'.$tpregist.'</tpregist>';
	$xmlSetPesquisa .= '		<nrseqdig>'.$nrseqdig.'</nrseqdig>';
	$xmlSetPesquisa .= '		<nrdrowid>'.$nrdrowid.'</nrdrowid>';
	$xmlSetPesquisa .= '	</Dados>';
	$xmlSetPesquisa .= '</Root>';
	
	// Pega informa��es retornada do PROGRESS
	$xmlResult  = getDataXML($xmlSetPesquisa);	
	$xmlObjeto  = getObjectXML($xmlResult);		
	$registros 	= $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	
	// Guarda as informa��es em uma vari�vel GLOBAL
	$GLOBALS['registros'] = $registros;	
	
	$navegador = CheckNavigator();
	$tipo = $navegador['navegador'] == 'chrome' ? 0 : 1;
	
	// Definindo par�metro para o m�todo "stream"
	$opcoes['Attachment'   ] = $tipo;
	$opcoes['Accept-Ranges'] = 0;
	$opcoes['compress'     ] = 0;	

	// Gera o relat�rio em PDF atrav�s do DOMPDF
	$dompdf = new DOMPDF();	
	$dompdf->load_html_file( './imp_fichacadastral_html.php' );
	$dompdf->set_paper('a4');
	$dompdf->render();
	$dompdf->stream('ficha_cadastral_'.$impchave.'.pdf', $opcoes );
?>