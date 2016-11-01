<? 
/*!
 * FONTE        : gera_impressao.php
 * CRIA��O      : Daniel Zimmermann       
 * DATA CRIA��O : 20/01/2013
 * OBJETIVO     : Rotina para geracao de impressao da tela ADMISS.
 * --------------
 * ALTERA��ES   : 							    			
 * -------------- 
 */
?> 

<?	
	session_cache_limiter("private");
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Recebe a opera��o que est� sendo realizada
	$cddopcao		= (isset($_POST['cddopcao1'])) ? $_POST['cddopcao1'] : '' ; 
	$numdopac		= (isset($_POST['numdopac1'])) ? $_POST['numdopac1'] : '' ; 	
	$dtdecons		= (isset($_POST['dtdecons1'])) ? $_POST['dtdecons1'] : '' ;
	$dtatecon		= (isset($_POST['dtatecon1'])) ? $_POST['dtatecon1'] : '' ;
	$cddopcao	    = 'N';

	// Inicializa
	$procedure 		= 'impressao-admiss';
	$retornoAposErro= '';
	
	$dsiduser 		= session_id();
	
	$retornoAposErro = 'focaCampoErro(\'numdopac\', \'frmImp\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Monta o xml din�mico de acordo com a opera��o 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0150.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<flgerlog>YES</flgerlog>';
	$xml .= '		<vlcapini>'.$vlcapini.'</vlcapini>';
	$xml .= '		<qtparcap>'.$qtparcap.'</qtparcap>';
	$xml .= '		<numdopac>'.$numdopac.'</numdopac>';
	$xml .= '		<vlcapsub>'.$vlcapsub.'</vlcapsub>';
	$xml .= '       <nrregist>'.$nrregist.'</nrregist>';
	$xml .= '       <nriniseq>'.$nriniseq.'</nriniseq>';
	$xml .= '		<flgabcap>'.$flgabcap.'</flgabcap>';
	$xml .= '		<dtdemiss>'.$dtdemiss.'</dtdemiss>';
	$xml .= '		<dtdecons>'.$dtdecons.'</dtdecons>';
	$xml .= '		<dtatecon>'.$dtatecon.'</dtatecon>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
    // Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	$xmlObjCarregaImpressao = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
 	if ($xmlObjCarregaImpressao->roottag->tags[0]->name == "ERRO") {
	    exibeErro($xmlObjCarregaImpressao->roottag->tags[0]->tags[0]->tags[4]->cdata);		 
    }
		
	//Obt�m nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjCarregaImpressao->roottag->tags[0]->attributes["NMARQPDF"];
	
	//Chama fun��o para mostrar PDF do impresso gerado no browser	 
	visualizaPDF($nmarqpdf);
	
	// Fun��o para exibir erros na tela atrav�s de javascript
    function exibeErro($msgErro) { 
	  echo '<script>alert("'.$msgErro.'");</script>';	
	  exit();
    }
	
?>