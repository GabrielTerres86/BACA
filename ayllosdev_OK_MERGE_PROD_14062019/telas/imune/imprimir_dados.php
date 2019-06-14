<? 
/*!
 * FONTE        : IMUNE.php
 * CRIAÇÃO      : André Santos / SUPERO
 * DATA CRIAÇÃO : 23/08/2013
 * OBJETIVO     : Requisição de Impressão da tela IMUNE
 * --------------
 * ALTERAÇÕES   : 31/10/2013 - Incluir campo $cddopcao como POST (Lucas R.)
 *					   
 * --------------
 */
?>

<?	
    session_cache_limiter("private");
    session_start();
    
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	    
    // Verifica se tela foi chamada pelo método POST
	isPostMethod();		

    // Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
    
	// Inicializa
	$retornoAposErro = '';
	
	// Recebe a operação que está sendo realizada
	$tprelimt		= (isset($_POST['tprelimt'])) ? $_POST['tprelimt'] : 1 ;
    $cdagenci		= (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0 ;
	$dtrefini		= (isset($_POST['dtrefini'])) ? $_POST['dtrefini'] : '' ;
    $dtreffim		= (isset($_POST['dtreffim'])) ? $_POST['dtreffim'] : '' ;
    $cdsitcad		= (isset($_POST['cdsitcad'])) ? $_POST['cdsitcad'] : 9; // 9 - TODOS 
	$cddopcao       = $_POST['cddopcao'];	
    
    $retornoAposErro = 'focaCampoErro(\'cdsitcad\', \'frmCabImp\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0159.p</Bo>';
	$xml .= '		<Proc>gera_impressao</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<dtmvtopr>'.$glbvars['dtmvtopr'].'</dtmvtopr>';
    $xml .= '		<tprelimt>'.$tprelimt.'</tprelimt>';
    $xml .= '		<cdagenci>'.$cdagenci.'</cdagenci>';
    $xml .= '		<dtrefini>'.$dtrefini.'</dtrefini>';
    $xml .= '		<dtreffim>'.$dtreffim.'</dtreffim>';
    $xml .= '		<cdsitcad>'.$cdsitcad.'</cdsitcad>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

    // ----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	// ----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
    
    // Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
    $nmarqpdf = $xmlObjeto->roottag->tags[0]->attributes["NMARQPDF"];

    // Chama função para mostrar PDF do impresso gerado no browser	 
    visualizaPDF($nmarqpdf);
?>