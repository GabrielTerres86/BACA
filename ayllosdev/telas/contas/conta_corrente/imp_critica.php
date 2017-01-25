<?
/*!
 * FONTE        : imp_critica.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 17/05/2010 
 * OBJETIVO     : Responsável por chamar a classe DOMPDF que gera o PDF da Critica do Cadastro da rotina de Conta-Corrente
 *
 *  ALTERACOES   : 12/07/2012 - Alterado parametro "Attachment" conforme for navegador (Jorge).
 *
 *                 01/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                              pois a rotina busca_impressao não utiliza o mesmo (Renato Darosci)
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

	// Recebendo valores da SESSÃO
	$cdcooper = $glbvars['cdcooper'];
	$cdagenci = $glbvars['cdagenci'];
	$nrdcaixa = $glbvars['nrdcaixa'];
	$cdoperad = $glbvars['cdoperad'];
	$nmdatela = $glbvars['nmdatela'];
	$idorigem = $glbvars['idorigem'];

	// Recebendo valores via POST
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '';
	
	
	// Retirando caracteres da conta
	$arrayRetirada = array('.','-','/');                                                        
	$nrdconta = str_replace($arrayRetirada,'',$nrdconta);
	
	// Gerando uma chave do formulário
	$impchave = $nrdconta.$idseqttl;
	setcookie('impchave', $impchave, time()+60 );	
	
	// Monta o XML de requisição
	$xmlSetPesquisa  = '';
	$xmlSetPesquisa .= '<Root>';
	$xmlSetPesquisa .= '	<Cabecalho>';
	$xmlSetPesquisa .= '		<Bo>b1wgen0074.p</Bo>';
	$xmlSetPesquisa .= '		<Proc>critica_cadastro</Proc>';
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
	
		
	// Pega informações retornada do PROGRESS
	$xmlResult  = getDataXML($xmlSetPesquisa);	
	$xmlObjeto  = getObjectXML($xmlResult);		
	$registros 	= $xmlObjeto->roottag->tags;
	
	
	// Guarda as informações em uma variável GLOBAL
	$GLOBALS['registros'] = $registros;
	
	$navegador = CheckNavigator();
	$tipo = $navegador['navegador'] == 'chrome' ? 0 : 1;
	
	// Definindo parâmetro para o método "stream"
	$opcoes['Attachment'   ] = $tipo;
	$opcoes['Accept-Ranges'] = 0;
	$opcoes['compress'     ] = 0;

	$tpPes = ( $inpessoa == 1 ) ? 'pf' : 'pj';	

	// Gera o relatório em PDF através do DOMPDF
	$dompdf = new DOMPDF();	
	$dompdf->load_html_file( './imp_critica_'.$tpPes.'_html.php' );
	$dompdf->set_paper('a4');
	$dompdf->render();
	$dompdf->stream('critica_'.$impchave.'.pdf', $opcoes );
?>