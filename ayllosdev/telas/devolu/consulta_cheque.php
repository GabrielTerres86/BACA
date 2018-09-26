<?php  
	
	/*******************************************************************************************************************
	 Fonte: consulta_cheque.php                                                                                  
	 Autor: Lucas Ranghetti                                                                                      
	 Data : Agosto/2016                   											Última Alteração: 00/00/0000
	                                                                                                             
	 Objetivo  : Consultar se o cheque ja foi compensado.                                                                                                
	                                                                                                              
	 Alterações:                                                												  
	*******************************************************************************************************************/
	
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
		
	$cdcooper = $_POST["cdcooper"];
	$dtcompen = $glbvars["dtmvtoan"];
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
	$xmlConsultaCheque .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlConsultaCheque .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlConsultaCheque .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlConsultaCheque .= "     <cdcopchq>".$glbvars["cdcooper"]."</cdcopchq>";
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
		exibeErro("Cheque n&atilde;o encontrado!");
	}
	
	if ($cdtpddoc == "90" || $cdtpddoc == "94" || $cdtpddoc == "95"){		
		exibeErro("Cheque compensado apenas pelo arquivo l&oacute;gico, n&atilde;o h&aacute; imagem!");
	}
	
	$DATA = split('/', $dtcompen);
	$DATA = $DATA[2].'-'.$DATA[1].'-'.$DATA[0];

	$AGENCIAC = str_pad($cdagechq, 4, '0', STR_PAD_LEFT);
	
	$REMESSA = $tpremess == "N" ? "nr" : "sr";
	
	$dsdocmc7 = str_replace(":", "", str_replace(">", "", str_replace("<", "", $dsdocmc7)));
	
	$dirdestino = "/var/www/ayllos/documentos/" . $glbvars["dsdircop"]. "/temp/";
		
	// buscar imagem no servidor (frente do cheque)
	//$find = "http://imagenscheque.cecred.coop.br/imagem/085/".$DATA."/".$AGENCIAC."/".$REMESSA."/".$dsdocmc7."F.TIF";
	
	/* ******  ENDEREÇO PARA BUSCAR AS IMAGENS NO SERVIDOR - CUIDADO AO ALTERAR E LIBERAR  *********** */
	//$urlOrigem = "http://imagenschequedev.cecred.coop.br"; // DESENV
	$urlOrigem = "http://imagenschequectb.cecred.coop.br";    // PRODUÇÃO
	/* ******  ENDEREÇO PARA BUSCAR AS IMAGENS NO SERVIDOR - CUIDADO AO ALTERAR E LIBERAR  *********** */

    // buscar imagem no servidor (frente do cheque)
    $find = $urlOrigem ."/imagem/085/".$DATA."/".$AGENCIAC."/".$REMESSA."/".$dsdocmc7."F.TIF";
	
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
	
		curl_close($ch);
		fclose($fp);
		unlink($tifF);
		exibeErro("Cheque n&atilde;o encontrado!");
	}
	
	curl_close($ch);
	fclose($fp);
	
	$srcF = str_replace(".TIF", ".gif", $tifF);	
	shell_exec("convert " . $tifF . " " . $srcF);	
	
	unlink($tifF);
	
	if(!file_exists($srcF)){
		exibeErro("Cheque n&atilde;o encontrado!");
	}
	
	// buscar imagem no servidor (verso do cheque)
	$find = $urlOrigem."/imagem/085/".$DATA."/".$AGENCIAC."/".$REMESSA."/".$dsdocmc7."V.TIF";
	
	
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
		exibeErro("Cheque n&atilde;o encontrado!");
	}
	
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

	strHTML +='		<a href="#" ><img onload="limpaChequeTemp(\'imgchqF\',\'<?php echo $srcF?>\',\'<?php echo $srcV?>\');" src="preview.php?keyrand=<?php echo mt_rand(); ?>&sidlogin=<?php echo base64_encode($glbvars["sidlogin"]); ?>&src=<?php echo $srcF?>" border="0" width="800"  id="imgchqF"></a>';
	strHTML +='		<br/>';
	strHTML +='		<a href="#" ><img onload="limpaChequeTemp(\'imgchqV\',\'<?php echo $srcF?>\',\'<?php echo $srcV?>\');" src="preview.php?keyrand=<?php echo mt_rand(); ?>&sidlogin=<?php echo base64_encode($glbvars["sidlogin"]); ?>&src=<?php echo $srcV?>" border="0" width="800"  id="imgchqV"></a>';
	
	<?
	//echo 'gravaLog("'.$dsdocmc7.'","'.$nrctachq.'");';
	echo "$('#divImagem').html(strHTML);";	
	echo "$('#divImagem').css({'display':'block'});";
	echo "$('#btFechaImagem','#divBotoes').show();";
	echo "setTimeout(function(){gerarPDF();},500);"; //ira gerar pdf apenas quando variavel flgerpdf = true, hack para ie
	echo "setTimeout(function(){baixarArquivo('".mt_rand()."','".base64_encode($glbvars["sidlogin"])."','".$srcF."','".$srcV."');},500);";
	echo 'hideMsgAguardo();'; 
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro");';
		exit();
	}
	
?>
