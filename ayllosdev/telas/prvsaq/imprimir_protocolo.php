<? 
/*!
 * FONTE        : imprimir_protocolo.php
 * CRIAÇÃO      : Andrey Formigari (Mouts)
 * DATA CRIAÇÃO : 09/12/2017
 * OBJETIVO     : Imprimir Protocolo
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	$nrPA 		 = (isset($_POST['nrPA'])) 		 ? $_POST['nrPA'] : 0 ;
	$dsprotocolo = (isset($_POST['dsprotocolo'])) ? $_POST['dsprotocolo'] : '' ;		
	$dtSaqPagto  = (isset($_POST['dtSaqPagto'])) ? $_POST['dtSaqPagto'] : 0 ;
	$hrSaqPagto  = (isset($_POST['hrSaqPagto'])) ? $_POST['hrSaqPagto'] : 0 ;
	$vlSaqPagto  = (isset($_POST['vlSaqPagto'])) ? $_POST['vlSaqPagto'] : 0 ;										
	$nrContTit   = (isset($_POST['nrContTit'])) ? $_POST['nrContTit'] : 0 ;
	$nrTit 		 = (isset($_POST['nrTit'])) 	 ? $_POST['nrTit'] : 0 ;
	$nrCpfCnpj   = (isset($_POST['nrCpfCnpj'])) ? $_POST['nrCpfCnpj'] : '' ;
	$nmSolic 	 = (isset($_POST['nmSolic'])) 	 ? $_POST['nmSolic'] : '' ;
	$nrCpfSacPag = (isset($_POST['nrCpfSacPag']))? $_POST['nrCpfSacPag'] : 0 ;
	$nmSacPag 	 = (isset($_POST['nmSacPag'])) 	 ? $_POST['nmSacPag'] : '' ;
	$nrPA 		 = (isset($_POST['nrPA'])) 		 ? $_POST['nrPA'] : 0 ;
	$txtFinPagto = (isset($_POST['txtFinPagto']))? $_POST['txtFinPagto'] : '' ;	

	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>" . $glbvars["cdcooper"] . "</cdcooper>";
	$xml .= "   <nrpa>" . $nrPA . "</nrpa>";		
	$xml .= "   <vlsaquepagto>" . $vlSaqPagto . "</vlsaquepagto>";
	$xml .= "   <nrconttit>" . $nrContTit . "</nrconttit>";
	$xml .= "   <dstitularidade>" . $nmSolic.' - '.$nrCpfCnpj. "</dstitularidade>";
	$xml .= "   <dssacador>" . $nmSacPag.' - '.$nrCpfSacPag. "</dssacador>";
	$xml .= "   <txtfinalidade>" . $txtFinPagto. "</txtfinalidade>";
	$xml .= "   <dsprotocolo>" . $dsprotocolo . "</dsprotocolo>";
	$xml .= "   <dtsaqpagto>" . $dtSaqPagto.' '.$hrSaqPagto. "</dtsaqpagto>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	//print_r($xml);	

	$xmlResult = mensageria($xml, "TELA_PRVSAQ", 'PRVSAQ_IMPRIMIR', $glbvars["cdcooper"], 1, 1, $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");		
	$xmlObj = getObjectXML($xmlResult);
	$xmlObj = simplexml_load_string($xmlResult);
	
	$pdfGerado = $nrPA . $nrContTit;
	$pdfGerado = "TELA_PRVSAQ_PROTOCOLO_" . $pdfGerado . ".pdf";

	visualizaPDF($pdfGerado);
?>