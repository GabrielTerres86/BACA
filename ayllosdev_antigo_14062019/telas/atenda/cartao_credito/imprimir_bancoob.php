<?php


    session_cache_limiter("private");
	session_start();
    require_once('../../../includes/config.php');
    require_once('../../../includes/funcoes.php');
   // require_once('../../../includes/controla_secao.php');
    require_once('../../../class/xmlfile.php');
    isPostMethod();	
   
    $glbfields = array("nrdconta","nrctrcrd","cdcooper","cdagenci","nrdcaixa","idorigem","cdoperad","dsdircop");

    foreach( $glbfields as $key =>$value){
        if(!isset($_POST[$value])){
            ?>
                <script>
                    alert('Erro ao imprimir');
                    window.close();
                </script>
            <?
        }
    }

    $inpesoa = $_GET['inpessoa'];

	
    $nrdconta = $_POST['nrdconta'];
    $nrctrcrd = $_POST['nrctrcrd'];

    $glbvars['cdcooper'] = $_POST['cdcooper'];
    $glbvars['nrdcaixa'] = $_POST['nrdcaixa'];
    $glbvars['cdagenci'] = $_POST['cdagenci'];
    $glbvars['idorigem'] = $_POST['idorigem'];
    $glbvars['cdoperad'] = $_POST['cdoperad'];
    $glbvars['dsdircop'] = $_POST['dsdircop'];
	$nmArqui = $_POST['nmarqui'];
    $dsiduser = session_id();

	if(isset($nmArqui) && strlen($nmArqui) > 0){
		
		visualizaPDF($nmArqui);
		//visualizaPDF("pcc");
		return;
	}
    $xmlpdf .= "<Root>";
    $xmlpdf .= " <Dados>";
    $xmlpdf.= "   <nrdconta>". $nrdconta."</nrdconta>";
    $xmlpdf.= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
    $xmlpdf .= "  <dsiduser>".$dsiduser."</dsiduser>";
    $xmlpdf.= " </Dados>";
    $xmlpdf.= "</Root>";
    if($inpesoa ==1 )
        $xmlResult = mensageria($xmlpdf, "CCRD0008", "ATDA_CRD_CRED_IMPR_TERMO_ADESAO_PF", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    else
        $xmlResult = mensageria($xmlpdf, "CCRD0008", "ATDA_CRD_CRED_IMPR_TERMO_ADESAO_PJ", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObject = getObjectXML($xmlResult);
        if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
			$msg = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
			?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
			exit();
		}
        // Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
        $nmarqpdf = $xmlObject->roottag->tags[0]->tags[0]->cdata;
        // Chama função para mostrar PDF do impresso gerado no browser
		//echo $nmarqpdf ;
       visualizaPDF($nmarqpdf);
?>
