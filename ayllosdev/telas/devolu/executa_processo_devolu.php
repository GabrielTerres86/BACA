<? 
/*!
 * FONTE        : DEVOLU.php
 * CRIA��O      : Andre Santos - SUPERO
 * DATA CRIA��O : 25/09/2013
 * OBJETIVO     : Requisi��o da tela DEVOLU
 * --------------
 * ALTERA��ES   :
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
    
    $cddevolu = (isset($_POST['cddevolu'])) ? $_POST['cddevolu'] : 0  ;
		
	$retornoAposErro = 'focaCampoErro(\'cddopcao\', \'frmBanco\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"S")) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

    // Monta o xml din�mico de acordo com a opera��o 
	$xml = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0175.p</Bo>';
	$xml .= '		<Proc>executa-processo-devolu</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<dtmvtoan>'.$glbvars['dtmvtoan'].'</dtmvtoan>';
	$xml .= '		<inproces>'.$glbvars['inproces'].'</inproces>';
	$xml .= '		<inrestar>'.$glbvars['inrestar'].'</inrestar>';
	$xml .= '		<dsrestar>'.$glbvars['dsrestar'].'</dsrestar>';
	$xml .= '		<nrctares>'.$glbvars['nrctares'].'</nrctares>';
	$xml .= '		<cdprogra>devolu</cdprogra>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<cddevolu>'.$cddevolu.'</cddevolu>';
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
?>

