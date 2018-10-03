<? 
/*!
 * FONTE        : imprimir_termo.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 20/07/2015
 * OBJETIVO     : Impressao de Termos
 * --------------
 * ALTERAÇÕES   :  
 * -------------- 
 */
?> 

<?	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	isPostMethod();
	require_once('../../class/xmlfile.php');
	
	// Recebe a operação que está sendo realizada
	$cdempres = (isset($_POST['cdempres']))   ? $_POST['cdempres']   : '';
	$indtermo = (isset($_POST['indtermo']))   ? $_POST['indtermo']   : 0 ;
	$lisconta = (isset($_POST['lisconta']))   ? $_POST['lisconta']   : 0 ;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0166.p</Bo>";
	$xml .= "        <Proc>Impresao_Termo_Servico</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';			
	$xml .= '       <cdempres>'.$cdempres.'</cdempres>';		
	$xml .= '       <indtermo>'.$indtermo.'</indtermo>';	
	$xml .= '       <lisconta>'.$lisconta.'</lisconta>';
	$xml .= "  </Dados>";
	$xml .= "</Root>";	

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	$xmlObj = getObjectXML($xmlResult);

	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibeErro($msg);
	}

	// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObj->roottag->tags[0]->attributes["NMARQPDF"];

	if ($indtermo == 0) {
		$msgTermo = "Ades&atilde;o";
	}else{
		$msgTermo = "Cancelamento";
	}
	
    // Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
    
	function exibeErro($msgErro) {
		echo '<script>alert("'.$msgErro.'");</script>';
		exit();
	}
?>