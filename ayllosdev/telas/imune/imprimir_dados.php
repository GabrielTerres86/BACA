<? 
/*!
 * FONTE        : IMUNE.php
 * CRIA��O      : Andr� Santos / SUPERO
 * DATA CRIA��O : 23/08/2013
 * OBJETIVO     : Requisi��o de Impress�o da tela IMUNE
 * --------------
 * ALTERA��ES   : 31/10/2013 - Incluir campo $cddopcao como POST (Lucas R.)
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
	    
    // Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();		

    // Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
    
	// Inicializa
	$retornoAposErro = '';
	
	// Recebe a opera��o que est� sendo realizada
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

	// Monta o xml din�mico de acordo com a opera��o 
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
    
    // Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
    $nmarqpdf = $xmlObjeto->roottag->tags[0]->attributes["NMARQPDF"];

    // Chama fun��o para mostrar PDF do impresso gerado no browser	 
    visualizaPDF($nmarqpdf);
?>