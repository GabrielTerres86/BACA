<?php 
	
	//*******************************************************************************************************************//
	//*** Fonte: consulta_cheque.php                                                                                  ***//
	//*** Autor: Fabrício                                                                                             ***//
	//*** Data : Junho/2012                   Última Alteração: 12/05/2015                                            ***//
	//***                                                                                                             ***//
	//*** Objetivo  : Consultar se o cheque ja foi compensado.                                                        ***//
	//***            												                                                  ***//	
	//***                                                                                                             ***//	 
	//*** Alterações: 30/07/2012 - Adicionado verificacao de existencia                                               ***//
	//***                          da geracao da imagem .gif (Jorge)                                                  ***//
	//***                          									                                                  ***//
	//***             20/08/2012 - Tratamento para TD 90, 94 e 95 (Ze)                                                ***//
	//***																											  ***//
	//***             09/10/2014 - #200504 Tratamento incorporações concredi e credimilsul (Carlos)                   ***//
	//***																											  ***//
	//***             12/05/2015 - Ajuste controle de apagar arquivos no temp e geracao de pdf. (Jorge/Elton) - SD 283911//
	//*******************************************************************************************************************//
	
	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
		
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");		
		
	$gerarpdf = $_POST["gerarpdf"];
	
	if ($gerarpdf == "false") {
		
		if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
			exibeErro($msgError);		
		}
		
		$cdcooper = $_POST["cdcooper"];
		$dtcompen = $_POST["dtcompen"];
		$cdcmpchq = $_POST["cdcmpchq"];
		$cdbanchq = $_POST["cdbanchq"];
		$cdagechq = $_POST["cdagechq"];
		$nrctachq = $_POST["nrctachq"];
		$nrcheque = $_POST["nrcheque"];
		$tpremess = $_POST["tpremess"];		
		
		// Monta o xml de requisição
		$xmlConsultaCheque  = "";
		$xmlConsultaCheque .= "<Root>";
		$xmlConsultaCheque .= "	<Cabecalho>";
		$xmlConsultaCheque .= "		<Bo>b1wgen0040.p</Bo>";
		$xmlConsultaCheque .= "		<Proc>consulta-cheque-compensado</Proc>";
		$xmlConsultaCheque .= "	</Cabecalho>";
		$xmlConsultaCheque .= "	<Dados>";
		$xmlConsultaCheque .= "		<cdcooper>".$cdcooper."</cdcooper>";
		$xmlConsultaCheque .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
		$xmlConsultaCheque .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
		$xmlConsultaCheque .= "		<dtcompen>".$dtcompen."</dtcompen>";
		$xmlConsultaCheque .= "		<cdcmpchq>".$cdcmpchq."</cdcmpchq>";
		$xmlConsultaCheque .= "		<cdbanchq>".$cdbanchq."</cdbanchq>";
		$xmlConsultaCheque .= "		<cdagechq>".$cdagechq."</cdagechq>";
		$xmlConsultaCheque .= "		<nrctachq>".$nrctachq."</nrctachq>";
		$xmlConsultaCheque .= "		<nrcheque>".$nrcheque."</nrcheque>";
		$xmlConsultaCheque .= "		<tpremess>".$tpremess."</tpremess>";
		$xmlConsultaCheque .= "	</Dados>";
		$xmlConsultaCheque .= "</Root>";
		
		// Executa script para envio do XML
		$xmlResult = getDataXML($xmlConsultaCheque);			
					
		// Cria objeto para classe de tratamento de XML
		$xmlObjCheque = getObjectXML($xmlResult);
	
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObjCheque->roottag->tags[0]->name) == "ERRO") {
			exibeErro($xmlObjCheque->roottag->tags[0]->tags[0]->tags[4]->cdata);
		}	

		$dsdocmc7   = $xmlObjCheque->roottag->tags[0]->attributes["DSDOCMC7"];
		$cdagechq   = $xmlObjCheque->roottag->tags[0]->attributes["CDAGECHQ"];
		$nmrescop   = $xmlObjCheque->roottag->tags[0]->attributes["NMRESCOP"];
		$cdcmpchq   = $xmlObjCheque->roottag->tags[0]->attributes["CDCMPCHQ"];
		$cdtpddoc   = $xmlObjCheque->roottag->tags[0]->attributes["CDTPDDOC"];
		
		if ($dsdocmc7 == ""){
		    echo "bGerarPdf.hide();";
			exibeErro("Cheque n&atilde;o encontrado!");
		}
		
		if ($cdtpddoc == "90" || $cdtpddoc == "94" || $cdtpddoc == "95"){
		    echo "bGerarPdf.hide();";
			exibeErro("Cheque compensado apenas pelo arquivo l&oacute;gico, n&atilde;o h&aacute; imagem!");
		}
		
		$DATA = split('/', $dtcompen);
		$DATA = $DATA[2].'-'.$DATA[1].'-'.$DATA[0];

		$AGENCIAC = str_pad($cdagechq, 4, '0', STR_PAD_LEFT);
		
		$REMESSA = $tpremess == "N" ? "nr" : "sr";
		
		$dsdocmc7 = str_replace(":", "", str_replace(">", "", str_replace("<", "", $dsdocmc7)));
		
		$dirdestino = "/var/www/ayllos/documentos/" . $glbvars["dsdircop"]. "/temp/";
			
		// buscar imagem no servidor (frente do cheque)
		$find = "http://imagenscheque.cecred.coop.br/imagem/085/".$DATA."/".$AGENCIAC."/".$REMESSA."/".$dsdocmc7."F.TIF";
		
		$ch = curl_init($find);
		
		$tifF = $dirdestino . $dsdocmc7 . "F.TIF";
		
		$fp = fopen($tifF, "w");		
		curl_setopt($ch, CURLOPT_FILE, $fp);
		curl_setopt($ch, CURLOPT_HEADER, 0);
		curl_exec($ch);
		
		$info = curl_getinfo($ch);

		if  ($info['size_download'] <= 8000) {

		
		        if ($cdcooper == 1) {				
					if ($cdagechq == 101) {
					    $cdagechq = 103;
					}
				}
				else {				
					if ($cdagechq == 112) {
					    $cdagechq = 114;
					}
				}
		
			//#200504 Tratamento incorporação 
			//Se não encontrou o cheque, verificar se é cheque da concredi ou credimilsul
			if ($tpremess == "N" && ($cdcooper == 1 || $cdcooper == 13)) {
				if ($cdcooper == 1) {				
					if ($cdagechq == 101) {
					    $cdagechq = 103;
					}
				}
				else {				
					if ($cdagechq == 112) {
					    $cdagechq = 114;
					}
				}

				$AGENCIAC = str_pad($cdagechq, 4, '0', STR_PAD_LEFT);
				// buscar imagem no servidor (frente do cheque)
				$find     = "http://imagenscheque.cecred.coop.br/imagem/085/".$DATA."/".$AGENCIAC."/".
				            $REMESSA."/".$dsdocmc7."F.TIF";
							
				$ch       = curl_init($find);
				$tifF     = $dirdestino . $dsdocmc7 . "F.TIF";
				$fp       = fopen($tifF, "w");
				curl_setopt($ch, CURLOPT_FILE, $fp);
				curl_setopt($ch, CURLOPT_HEADER, 0);
				curl_exec($ch);
				$info     = curl_getinfo($ch);
				
				if ($info['size_download'] <= 8000){
					curl_close($ch);
					fclose($fp);
					unlink($tifF);
					echo "bGerarPdf.hide();";
					exibeErro("Cheque n&atilde;o encontrado!");
				}
			}
			else {				
				curl_close($ch);
				fclose($fp);
				unlink($tifF);
				echo "bGerarPdf.hide();";
				exibeErro("Cheque n&atilde;o encontrado!");
			}
		}		
		
		curl_close($ch);
		fclose($fp);
		
		$srcF = str_replace(".TIF", ".gif", $tifF);	
		shell_exec("convert " . $tifF . " " . $srcF);	
		
		unlink($tifF);
		
		if(!file_exists($srcF)){
			echo "bGerarPdf.hide();";
			exibeErro("Cheque n&atilde;o encontrado!");
		}
		
		// buscar imagem no servidor (verso do cheque)
		$find = "http://imagenscheque.cecred.coop.br/imagem/085/".$DATA."/".$AGENCIAC."/".$REMESSA."/".$dsdocmc7."V.TIF";
		
		$ch = curl_init($find);
		
		$tifV = $dirdestino . $dsdocmc7 . "V.TIF";
		
		$fp = fopen($tifV, "w");
		curl_setopt($ch, CURLOPT_FILE, $fp);
		curl_setopt($ch, CURLOPT_HEADER, 0);		
		curl_exec($ch);
		curl_close($ch);
		fclose($fp);		
		
		$srcV = str_replace(".TIF", ".gif", $tifV);	
		shell_exec("convert " . $tifV . " " . $srcV);
		
		unlink($tifV);
	
		if(!file_exists($srcV)){
			echo "bGerarPdf.hide();";
			exibeErro("Cheque n&atilde;o encontrado!");
		}
		
		//mostra botao de gerar pdf se chegar ateh aki
		echo "bGerarPdf.show('slow');";
		
		?>

		nmrescop = '<? echo $nmrescop; ?>';
		tremessa = '<? echo $REMESSA;  ?>';
		compechq = '<? echo $cdcmpchq; ?>';
		bancochq = '<? echo $cdbanchq; ?>';
		agencchq = '<? echo $AGENCIAC; ?>';
		contachq = '<? echo $nrctachq; ?>';
		numerchq = '<? echo $nrcheque; ?>';
		datacomp = '<? echo $dtcompen; ?>';
		lstCmc7  = new Array();
		lstCmc7[0] = '<? echo $srcF; ?>';
		lstCmc7[1] = '<? echo $srcV; ?>';
		
		var strHTML = "";

		strHTML +='		<a href="#" title="Baixar arquivo original" onclick="preBaixaArquivo(\'F\');"><img onload="limpaChequeTemp(\'imgchqF\',\'<?php echo $srcF?>\',\'<?php echo $srcV?>\');" src="preview.php?keyrand=<?php echo mt_rand(); ?>&sidlogin=<?php echo base64_encode($glbvars["sidlogin"]); ?>&src=<?php echo $srcF?>" border="0" width="800"  id="imgchqF"></a>';
		strHTML +='		<br/>';
		strHTML +='		<a href="#" title="Baixar arquivo original" onclick="preBaixaArquivo(\'V\');"><img onload="limpaChequeTemp(\'imgchqV\',\'<?php echo $srcF?>\',\'<?php echo $srcV?>\');" src="preview.php?keyrand=<?php echo mt_rand(); ?>&sidlogin=<?php echo base64_encode($glbvars["sidlogin"]); ?>&src=<?php echo $srcV?>" border="0" width="800"  id="imgchqV"></a>';
		
		<?
		echo 'gravaLog("'.$dsdocmc7.'","'.$nrctachq.'");';
		echo "$('#divImagem').html(strHTML);";	
		echo "$('#divImagem').css({'display':'block'});";
		echo "setTimeout(function(){gerarPDF();},500);"; //ira gerar pdf apenas quando variavel flgerpdf = true, hack para ie
	    echo "setTimeout(function(){baixarArquivo('".mt_rand()."','".base64_encode($glbvars["sidlogin"])."','".$srcF."','".$srcV."');},500);";
		echo 'hideMsgAguardo();';
	} else {		
		
		$nmrescop = $_POST["nmrescop"];
		$tpremess = $_POST["tpremess"];
		$cdcmpchq = $_POST["cdcmpchq"];
		$cdbanchq = $_POST["cdbanchq"];
		$cdagechq = $_POST["cdagechq"];
		$nrctachq = $_POST["nrctachq"];
		$nrcheque = $_POST["nrcheque"];
		$dsdocmc7 = $_POST["dsdocmc7"];
		$dtcompen = $_POST["dtcompen"];
		
		$lstcmc7[0] = substr($dsdocmc7, 0, strpos($dsdocmc7, ","));
		$lstcmc7[1] = substr($dsdocmc7, strpos($dsdocmc7, ",") + 1, strlen($dsdocmc7) - strpos($dsdocmc7, ","));
		
		include ('pdf.php');
		
	}	
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos");';
		exit();
	}
	
?>
