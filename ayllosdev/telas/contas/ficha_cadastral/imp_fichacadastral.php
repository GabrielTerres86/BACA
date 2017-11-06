<?
/*!
 * FONTE        : imprime_ficha_cadastral.php
 * CRIA��O      : Rodolpho Telmo (DB1)
 * DATA CRIA��O : 08/04/2010 
 * OBJETIVO     : Arquivo de entrada para impress�o da Ficha Cadastral da rotina de CONTAS
 *                Imprime tanto Fichas Cadastrais de PF ou PJ
 *
 * ALTERACOES   : 12/07/2012 - Alterado parametro "Attachment" conforme for navegador (Jorge).
 *
 *                01/12/2016 - P341-Automatiza��o BACENJUD - Removido passagem do departamento como parametros
 *                             pois a BO n�o utiliza o mesmo (Renato Darosci)
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
	
	// Recebendo valores via POST
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$tpregist = (isset($_POST['tpregist'])) ? $_POST['tpregist'] : '';	
	
	// Retirando caracteres do cpf e cnpj  
	$arrayRetirada = array('.','-');                                                        
	$nrdconta = str_replace($arrayRetirada,'',$nrdconta);
	// $tpregist = substr($inpessoa,0,1);
		
	// Gerando uma chave do formul�rio
	$impchave = $nrdconta.$idseqttl;
	setcookie('impchave', $impchave, time()+60 );	
	
	// Monta o xml de requisi��o
	$xmlSetPesquisa  = '';
	$xmlSetPesquisa .= '<Root>';
	$xmlSetPesquisa .= '	<Cabecalho>';
	$xmlSetPesquisa .= '		<Bo>b1wgen0062.p</Bo>';
	$xmlSetPesquisa .= '		<Proc>busca_impressao</Proc>';
	$xmlSetPesquisa .= '	</Cabecalho>';
	$xmlSetPesquisa .= '	<Dados>';
	$xmlSetPesquisa .= '        <cdcooper>'.$cdcooper.'</cdcooper>';
	$xmlSetPesquisa .= '		<cdagenci>'.$cdagenci.'</cdagenci>';
	$xmlSetPesquisa .= '		<nrdcaixa>'.$nrdcaixa.'</nrdcaixa>';
	$xmlSetPesquisa .= '		<cdoperad>'.$cdoperad.'</cdoperad>';
	$xmlSetPesquisa .= '		<nmdatela>'.$nmdatela.'</nmdatela>';	
	$xmlSetPesquisa .= '		<idorigem>'.$idorigem.'</idorigem>';	
	$xmlSetPesquisa .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xmlSetPesquisa .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xmlSetPesquisa .= '	</Dados>';
	$xmlSetPesquisa .= '</Root>';		
	
	// Pega informa��es retornada do PROGRESS
	$xmlResult  = getDataXML($xmlSetPesquisa);	
	$xmlObjeto  = getObjectXML($xmlResult);		

	// Guarda as informa��es em uma vari�vel GLOBAL
	$GLOBALS['xmlObjeto'] = $xmlObjeto;
	
	$navegador = CheckNavigator();
	$tipo = $navegador['navegador'] == 'chrome' ? 0 : 1;
	
	// Definindo par�metro para o m�todo "stream"
	$opcoes['Attachment'   ] = $tipo;
	$opcoes['Accept-Ranges'] = 0;
	$opcoes['compress'     ] = 0;

	$GLOBALS['tprelato'] = 'ficha_cadastral';

	// Gera o relat�rio em PDF atrav�s do DOMPDF
	$dompdf = new DOMPDF();
	if ( $tpregist == '1' ) {
		$dompdf->load_html_file( './imp_fichacadastral_pf_html.php' );
	} else {
		$dompdf->load_html_file( './imp_fichacadastral_pj_html.php' );
	}
	$dompdf->set_paper('a4');
	$dompdf->render();
	$dompdf->stream('ficha_cadastral_'.$impchave.'.pdf', $opcoes );	
?>
