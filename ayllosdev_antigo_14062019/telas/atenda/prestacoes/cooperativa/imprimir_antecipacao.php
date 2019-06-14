<? 
/*!
 * FONTE        : imprimir_antecipacao.php
 * CRIAÇÃO      : Daniel Zimmermann       
 * DATA CRIAÇÃO : 16/06/2014
 * OBJETIVO     : Rotina para geração de relatorios antecipacao prestacao.
 * --------------
 * ALTERAÇÕES   :  								    			
 * -------------- 
 */
?> 

<?	
	session_cache_limiter("private");
    session_start();
	require_once('../../../../includes/config.php');
	require_once('../../../../includes/funcoes.php');
	require_once('../../../../includes/controla_secao.php');
	require_once('../../../../class/xmlfile.php');
	isPostMethod();		
	
	/*
	// Recebe Parametros
	$nrdconta      = (isset($_POST['nrdconta']))  ? $_POST['nrdconta'] : 0 ; 
	$nrctremp	   = (isset($_POST['nrctremp']))  ? $_POST['nrctremp'] : 0  ; 	
	$lstdtpgto	   = (isset($_POST['lstdtpgto'])) ? $_POST['lstdtpgto'] : ''  ; 	
	$lstdtvcto	   = (isset($_POST['lstdtvcto'])) ? $_POST['lstdtvcto'] : ''  ; 	
	$lstparepr     = (isset($_POST['lstparepr'])) ? $_POST['lstparepr'] : ''  ; 
	$lstvlrpag     = (isset($_POST['lstvlrpag'])) ? $_POST['lstvlrpag'] : ''  ;
    $qtdregis	   = (isset($_POST['qtdregis']))  ? $_POST['qtdregis'] : 0  ; 	
*/
	$nrdconta = $_POST["nrdconta1"];	
	$nrctremp = $_POST["nrctremp1"];
	$qtdregis = $_POST["qtdregis1"];
	$lstdtpgto = $_POST["lstdtpgto1"];
	$lstdtvcto = $_POST["lstdtvcto1"];
	$lstparepr = $_POST["lstparepr1"];
	$lstvlrpag = $_POST["lstvlrpag1"];
	
	//$cddopcao	   = 'C';

	// Inicializa
	$retornoAposErro= '';
	
	$nmendter = session_id();
	/*
	$retornoAposErro = 'focaCampoErro(\'dtafinal\', \'frmRel\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	*/
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrctremp>".$nrctremp."</nrctremp>";
	$xml .= "   <qtdregis>".$qtdregis."</qtdregis>";
	$xml .= "   <lstdtpgto>".$lstdtpgto."</lstdtpgto>";
	$xml .= "   <lstdtvcto>".$lstdtvcto."</lstdtvcto>";
	$xml .= "   <lstparepr>".$lstparepr."</lstparepr>";
	$xml .= "   <lstvlrpag>".$lstvlrpag."</lstvlrpag>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	// craprdr / crapaca 
	$xmlResult = mensageria($xml, "ATENDA", "IMPANTEC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	/*
	echo '<pre>';
	print_r($xmlObjeto);
	echo '</pre>';
	*/
	
	// Se ocorrer um erro, mostra crítica
 	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
	    exibeErro($xmlObjeto->roottag->tags[0]->cdata);		 
    }

	//Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjeto->roottag->cdata;
	
	//Chama função para mostrar PDF do impresso gerado no browser	 
	visualizaPDF($nmarqpdf);	
	
	// Função para exibir erros na tela através de javascript
    function exibeErro($msgErro) { 
	  echo '<script>alert("'.$msgErro.'");</script>';	
	  exit();
    }
	

?>