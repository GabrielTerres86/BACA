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
	$tpctrlim = (isset($_POST['nrctrlim'])) ? $_POST['tpctrlim'] : '' ;
	$idcobope = (isset($_POST['idcobope'])) ? $_POST['idcobope'] : '' ;
	$cdageori = (isset($_POST['cdageori'])) ? $_POST['cdageori'] : '' ;


	if ($operacao == 'ENVIAR_ANALISE' ) {

		$xml = "<Root>";
	    $xml .= " <Dados>";
	    $xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	    $xml .= "   <nrctrlim>".$nrctrlim."</nrctrlim>";
	    $xml .= "   <tpctrlim>".$tpctrlim."</tpctrlim>";
	    $xml .= "   <idcobope>".$idcobope."</idcobope>";
	    $xml .= "   <cdageori>".$cdageori."</cdageori>";
	    $xml .= "	<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	    $xml .= "   <tpenvest>I</tpenvest>"; // Tipo de envio para esteira I - Inclusao (Emprestimo)
	    $xml .= " </Dados>";
	    $xml .= "</Root>";

	    $xmlResult = mensageria($xml,"TELA_ATENDA_DESCTO","ENVIAR_ESTEIRA_DESCT", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	    $xmlObj = getObjectXML($xmlResult);



	    // Se ocorrer um erro, mostra mensagem
	    /*
		if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO') {
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$metodoErro,false);
		*/
		

		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	    	$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		    if ($msgErro == "") {
		        $msgErro = $xmlObj->roottag->tags[0]->cdata;
		       
		    }
		     $nmdcampo = $xmlObj->roottag->tags[0]->attributes['NMDCAMPO'];
		    exibeErroNew($msgErro,$nmdcampo);
		    exit();
		}

		$registros = $xmlObj->roottag->tags[0]->tags;
		



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
	    /*
		if (strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO') {
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$metodoErro,false);
		*/


	    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	    	$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		    if ($msgErro == "") {
		        $msgErro = $xmlObj->roottag->tags[0]->cdata;
		       
		    }
		     $nmdcampo = $xmlObj->roottag->tags[0]->attributes['NMDCAMPO'];
		    exibeErroNew($msgErro,$nmdcampo);
		    exit();
		}

		$registros = $xmlObj->roottag->tags[0]->tags;

	    
		
	}


?>