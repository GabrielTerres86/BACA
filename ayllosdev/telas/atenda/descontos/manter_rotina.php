<?
/*!
 * FONTE        : manter_rotina.php 
 * CRIAÇÃO      : Alex Sandro (GFT)
 * DATA CRIAÇÃO : 15/02/2018
 * OBJETIVO     : Descrição da rotina
 * --------------
 * ALTERAÇÕES   :
 * --------------

 */
?>

<?

    session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();

	// parâmetos do POST em variáveis
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ;
	$nrctrlim = (isset($_POST['nrctrlim'])) ? $_POST['nrctrlim'] : '' ;
	$insitlim = (isset($_POST['insitlim'])) ? $_POST['insitlim'] : '' ;
	$dssitest = (isset($_POST['dssitest'])) ? $_POST['dssitest'] : '' ;
	$insitapr = (isset($_POST['insitapr'])) ? $_POST['insitapr'] : '' ;
	
	if ($operacao == 'ENVIAR_ANALISE' ) {
		
		$xml = "<Root>";
	    $xml .= " <Dados>";
	    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	    $xml .= "   <nrctrlim>".$nrctrlim."</nrctrlim>";
	    $xml .= "	<dtmovito>".$glbvars["dtmvtolt"]."</dtmovito>";
	    $xml .= "   <tpenvest>I</tpenvest>"; // Tipo de envio para esteira I - Inclusao (Emprestimo)
	    $xml .= " </Dados>";
	    $xml .= "</Root>";


	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","ENVIAR_ESTEIRA_DESCT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	    $xmlObj = getObjectXML($xmlResult);

	    //print_r($xmlObj);

		if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO'){		   
           echo 'showError("error","'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'","Alerta - Ayllos","bloqueiaFundo(divRotina);carregaLimitesTitulos();");';           
           exit;
		}
		
		/*
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	    	$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		    if ($msgErro == "") {
		        $msgErro = $xmlObj->roottag->tags[0]->cdata;
		       
		    }
		     $nmdcampo = $xmlObj->roottag->tags[0]->attributes['NMDCAMPO'];
		    exibeErroNew($msgErro,$nmdcampo);
		    exit();
		}
		*/
		
		//$registros = $xmlObj->roottag->tags[0]->tags;

		echo 'showError("inform","Análise enviada com sucesso!","Alerta - Ayllos","bloqueiaFundo(divRotina);");';
        exit;

	}else if ($operacao == 'ENVIAR_ESTEIRA' ) {

		$xml = "<Root>";
	    $xml .= " <Dados>";
	    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	    $xml .= "   <nrctrlim>".$nrctrlim."</nrctrlim>";
	    $xml .= " </Dados>";
	    $xml .= "</Root>";

	    // FAZER O INSERT CRAPRDR e CRAPACA
	    $xmlResult = mensageria($xml,"XXXXX","XXXXX", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	    $xmlObj = getObjectXML($xmlResult);

	    // Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO') {
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$metodoErro,false);
		}

		$registros = $xmlObj->roottag->tags[0]->tags;

		exit;
		
	}else if ($operacao == 'CONFIMAR_NOVO_LIMITE' ) {

		$xml = "<Root>";
	    $xml .= " <Dados>";
	    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	    $xml .= "   <nrctrlim>".$nrctrlim."</nrctrlim>";
	    $xml .= "   <insitlim>".$insitlim."</insitlim>";
	    $xml .= "   <dssitest>".$dssitest."</dssitest>";
	    $xml .= "   <insitapr>".$insitapr."</insitapr>";
	    $xml .= " </Dados>";
	    $xml .= "</Root>";


	    // FAZER O INSERT CRAPRDR e CRAPACA
	    $xmlResult = mensageria($xml,"XXXXX","XXXXX", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	    $xmlObj = getObjectXML($xmlResult);


	    // Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO') {
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$metodoErro,false);
		}

		$registros = $xmlObj->roottag->tags[0]->tags;
		exit;
		
	}


	function exibeErroNew($msgErro,$nmdcampo) {
	    echo 'hideMsgAguardo();';
	    if ($nmdcampo <> ""){
	        $nmdcampo = '$(\'#'.$nmdcampo.'\', \'#frmTab052\').focus();';
	    }
	    $msgErro = str_replace('"','',$msgErro);
	    $msgErro = preg_replace('/\s/',' ',$msgErro);
	    
	    echo 'showError("error","' .$msgErro. '","Alerta - Ayllos","liberaCampos(); '.$nmdcampo.'");'; 
	    exit();
	}

?>