<?php 
/*!
 * FONTE        : gera_relatorios.php
 * CRIAÇÃO      : David Kruger        
 * DATA CRIAÇÃO : 28/02/2013
 * OBJETIVO     : Rotina para geração de relatorios da tela RELSEG.
 * --------------
 * ALTERAÇÕES   : 25/07/2013 - Correção da exibição da mensagem de erros. (Carlos)
				: 18/02/2014 - Exportação em .txt para Tp.Relat 5 (Lucas)
 * -------------- 
 */
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Inicializa
	$retornoAposErro = '';
	
	
	// Recebe a operação que está sendo realizada
	$cddopcao      = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
    $tprelato      = (isset($_POST['tprelato'])) ? $_POST['tprelato'] : 0  ;
	$telcdage      = (isset($_POST['telcdage'])) ? $_POST['telcdage'] : 0  ; 	
	$dtiniper      = (isset($_POST['dtiniper'])) ? $_POST['dtiniper'] : 0  ;
	$dtfimper      = (isset($_POST['dtfimper'])) ? $_POST['dtfimper'] : 0  ;
	$inexprel      = (isset($_POST['inexprel'])) ? $_POST['inexprel'] : 0  ;
    $tpseguro      = (isset($_POST['tpseguro'])) ? $_POST['tpseguro'] : 2  ;
    $tpstaseg      = (isset($_POST['tpstaseg'])) ? $_POST['tpstaseg'] : 'A';
	
	$retornoAposErro = 'focaCampoErro(\'telcdage\', \'frmRel\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		echo "<script>alert('".$msgError."');</script>";
	}
	
    if ($tprelato <> 6){
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
        $xml .= '   <Cabecalho>';
        $xml .= '       <Bo>b1wgen0045.p</Bo>';
        $xml .= '       <Proc>inicia-relatorio</Proc>';
        $xml .= '   </Cabecalho>';
        $xml .= '   <Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
        $xml .= '       <cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
        $xml .= '       <nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
        $xml .= '       <cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
        $xml .= '       <nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
        $xml .= '       <idorigem>'.$glbvars['idorigem'].'</idorigem>';
        $xml .= '       <dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
        $xml .= '       <tprelato>'.$tprelato.'</tprelato>';
        $xml .= '       <telcdage>'.$telcdage.'</telcdage>';
        $xml .= '       <dtiniper>'.$dtiniper.'</dtiniper>';
        $xml .= '       <dtfimper>'.$dtfimper.'</dtfimper>';
        $xml .= '       <inexprel>'.$inexprel.'</inexprel>';
        $xml .= '   </Dados>';
	$xml .= '</Root>';
	
    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		if ( !empty($nmdcampo) ) { $mtdErro = $mtdErro . " $('#".$nmdcampo."').focus();";  } ?>
		<script language="javascript">
			alert("<?php echo $msgErro ?>");
		</script><?php
		exit();
	}	

	$nmarqpdf = $xmlObjeto->roottag->tags[0]->attributes["NMARQPDF"];
    }
    else {  // Se for 6 - Seguro Auto Sicredi
        // Montar o xml de Requisicao
        $xml .= "<Root>";
        $xml .= " <Dados>";
        $xml .= "   <tpseguro>".$tpseguro."</tpseguro>";
        $xml .= "   <tpstaseg>".$tpstaseg."</tpstaseg>";
        $xml .= " </Dados>";
        $xml .= "</Root>";

        // craprdr / crapaca
        $xmlResult = mensageria($xml, "RELSEG", "EXPSEGAUTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
        $xmlObjeto = getObjectXML($xmlResult);
        
        // Se ocorrer um erro, mostra crítica
        if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
            exibeErro($xmlObjeto->roottag->tags[0]->cdata);
        }

        //Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
        $nmarqpdf = $xmlObjeto->roottag->cdata;
        $inexprel = 1; // tprelato 6 é sempre 2 (TXT/CSV)
    }


	
	function visualizaTXT($nmarquiv) {
		global $glbvars;
		$nmarqpdf  = "/var/www/ayllos/documentos/".$glbvars["dsdircop"]."/temp/".$nmarquiv;

		if (!file_exists($nmarqpdf) || !is_file($nmarqpdf)) {			
			?><script language="javascript">alert('Arquivo TXT nao foi gerado.<?php echo $nmarqpdf ?>');</script><?php
			return false;
		}
		
		$fp = fopen($nmarqpdf,"r");
		$strPDF = fread($fp,filesize($nmarqpdf));
		fclose($fp);

		unlink($nmarqpdf);	
		
		$navegador = CheckNavigator();
		
		if ($navegador['navegador'] != 'chrome') {		
			header('Content-Type: application/x-download');			
			header('Content-disposition: attachment; filename="'.$nmarquiv.'"');				
		} else { 
			header('Content-Type: application/txt');			
			header('Content-disposition: inline; filename="'.$nmarquiv.'"');
		}			
		
		header("Expires: 0"); 
		header("Cache-Control: no-cache");
		header('Cache-Control: private, max-age=0, must-revalidate');
		header("Pragma: public");
		
		echo $strPDF;	
	}
	
	if ($inexprel == 1){
		// Chama função para mostrar PDF do impresso gerado no browser
		visualizaPDF($nmarqpdf);
	} else {
		visualizaTXT($nmarqpdf);	
	}	
	
?>