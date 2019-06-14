<?
/*!
 * FONTE        : imprime_ficha_cadastral.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 08/04/2010 
 * OBJETIVO     : Arquivo de entrada para impressão da Ficha Cadastral da rotina de CONTAS
 *                Imprime tanto Fichas Cadastrais de PF ou PJ
 *
 * ALTERACOES   : 12/07/2012 - Alterado parametro "Attachment" conforme for navegador (Jorge).
 *
 *                01/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                             pois a BO não utiliza o mesmo (Renato Darosci)
 *                09/10/2017 - P410-RF 52 / 62 - Impressão declaração optante simples nacional (Diogo - MoutS)
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
	$tpregist = (isset($_POST['tpregist'])) ? $_POST['tpregist'] : '';	
	$tpregtrb = (isset($_POST['tpregtrb'])) ? $_POST['tpregtrb'] : '';
	$impSoDeclaracao = (isset($_POST['imprimirsodeclaracaosn'])) ? $_POST['imprimirsodeclaracaosn'] : '0';	//vem de impressoes.js

	// Retirando caracteres do cpf e cnpj  
	$arrayRetirada = array('.','-');                                                        
	$nrdconta = str_replace($arrayRetirada,'',$nrdconta);
	// $tpregist = substr($inpessoa,0,1);
		
	// Gerando uma chave do formulário
	$impchave = $nrdconta.$idseqttl;
	setcookie('impchave', $impchave, time()+60 );	
	
	// Monta o xml de requisição
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
	
	// Pega informações retornada do PROGRESS
	$xmlResult  = getDataXML($xmlSetPesquisa);	
	$xmlObjeto  = getObjectXML($xmlResult);		

	// Guarda as informações em uma variável GLOBAL
	$GLOBALS['xmlObjeto'] = $xmlObjeto;
	
	$navegador = CheckNavigator();
	$tipo = $navegador['navegador'] == 'chrome' ? 0 : 1;
	
	// Definindo parâmetro para o método "stream"
	$opcoes['Attachment'   ] = $tipo;
	$opcoes['Accept-Ranges'] = 0;
	$opcoes['compress'     ] = 0;

	$GLOBALS['tprelato'] = 'ficha_cadastral';

	$nomeArquivoPDF = 'ficha_cadastral_'.$impchave;

	if (empty($tpregtrb)){
		$tpregtrb = getByTagName($xmlObjeto->roottag->tags[11]->tags[0]->tags,'tpregtrb');			
	}

	// Gera o relatório em PDF através do DOMPDF
	$dompdf = new DOMPDF();
	if ( $tpregist == '1' ) {
		$dompdf->load_html_file( './imp_fichacadastral_pf_html.php' );
	} else {
		//$dompdf->load_html_file( './imp_fichacadastral_pj_html.php' );
				
		$conteudo = "";
		if ($impSoDeclaracao){
			//Somente a declaração do simples nacional e o regime de tributação deve ser 1 ou 2 (simples nacional)
			if ($tpregtrb == '1'){
				$nomeArquivoPDF = 'declaracao_simples_'.$impchave;
				$conteudo .= file_get_contents('./imp_declaracao_simples.php');
			}
		}
		else{
			//Imprime a ficha e a declaração do simples nacional e o regime de tributação deve ser 1 ou 2 (simples nacional)
			$conteudo = file_get_contents('./imp_fichacadastral_pj_html.php');
		
			if ($tpregtrb == '1'){
				$conteudo .= '<div style="page-break-before: always;"></div>';
				$conteudo .= file_get_contents('./imp_declaracao_simples.php');
			}
		}
        
        $dompdf->load_html($conteudo);
	}
	$dompdf->set_paper('a4');
	$dompdf->render();
	$dompdf->stream($nomeArquivoPDF.'.pdf', $opcoes);	
?>