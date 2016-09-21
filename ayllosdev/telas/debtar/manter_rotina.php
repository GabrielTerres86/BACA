<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Tiago Machado Flor
 * DATA CRIAÇÃO : 03/03/2015
 * OBJETIVO     : Rotina para geração de relatorios tarifas pendentes.
 * --------------
 * ALTERAÇÕES   : 
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
	
	// Recebe a operação que está sendo realizada
	$tprelato      = (isset($_POST['tprelato1'])) ? $_POST['tprelato1'] : '' ; 
	$cdhistor	   = (isset($_POST['cdhistor1'])) ? $_POST['cdhistor1'] : 0  ; 	
	$cddgrupo	   = (isset($_POST['cddgrupo1'])) ? $_POST['cddgrupo1'] : 0  ; 	
	$cdsubgru	   = (isset($_POST['cdsubgru1'])) ? $_POST['cdsubgru1'] : 0  ; 	
	$cdhisest      = (isset($_POST['cdhisest1'])) ? $_POST['cdhisest1'] : 0  ; 
	$cdmotest      = (isset($_POST['cdmotest1'])) ? $_POST['cdmotest1'] : 0  ; 
	$cdcoptel      = (isset($_POST['cdcooper1'])) ? $_POST['cdcooper1'] : 0  ; 
	$cdagetel      = (isset($_POST['cdagenci1'])) ? $_POST['cdagenci1'] : 0  ; 
	$inpessoa      = (isset($_POST['inpessoa1'])) ? $_POST['inpessoa1'] : 0  ; 
	$nrdconta      = (isset($_POST['nrdconta1'])) ? $_POST['nrdconta1'] : 0  ; 	
	$nmarqpdf      = (isset($_POST['nmarqpdf1'])) ? $_POST['nmarqpdf1'] : ''  ; 	
	$dtinicio      = (isset($_POST['dtinicio'])) ? $_POST['dtinicio'] : '' ;
	$dtafinal      = (isset($_POST['dtafinal'])) ? $_POST['dtafinal'] : '' ;
	$cddopcao	   = 'E';

	// Inicializa
	$procedure 		= '';
	$retornoAposErro= '';
	
	$nmendter = session_id();
	$retornoAposErro = 'focaCampoErro(\'dtafinal\', \'frmRel\');';
	
	$cddopcao = 'E';

	//$nmarqpdf = "crrl698.pdf";
	
	//Chama função para mostrar PDF do impresso gerado no browser	 
	visualizaPDF($nmarqpdf);	
	
	// Função para exibir erros na tela através de javascript
    function exibeErro($msgErro) { 
	  echo '<script>alert("'.$msgErro.'");</script>';	
	  exit();
    }
	
?>