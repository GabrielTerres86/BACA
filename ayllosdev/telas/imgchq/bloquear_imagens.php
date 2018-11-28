<? 
/*!
 * FONTE        : bloquear_imagens.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 01/06/2018
 * OBJETIVO     : Rotina para bloquear imagens de cheques
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
	require_once('../../class/xmlfile.php');
	isPostMethod();		
		
	// Recebe a operação que está sendo realizada
	$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : '' ;
	$dtcompen = (isset($_POST['dtcompen'])) ? $_POST['dtcompen'] : '' ;
	$cdbanchq = (isset($_POST['cdbanchq'])) ? $_POST['cdbanchq'] : '' ;
	$cdagechq = (isset($_POST['cdagechq'])) ? $_POST['cdagechq'] : '' ;
	$nrctachq = (isset($_POST['nrctachq'])) ? $_POST['nrctachq'] : '' ;
	$nrcheque = (isset($_POST['nrcheque'])) ? $_POST['nrcheque'] : '' ;
	$tpremess = (isset($_POST['tpremess'])) ? $_POST['tpremess'] : '' ;
	$flgblqim = (isset($_POST['flgblqim'])) ? $_POST['flgblqim'] : '' ;
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
	$xml .= "   <dtmvtolt>".$dtcompen."</dtmvtolt>";
	$xml .= "   <cdbanchq>".$cdbanchq."</cdbanchq>";
	$xml .= "   <cdagechq>".$cdagechq."</cdagechq>";
	$xml .= "   <nrctachq>".$nrctachq."</nrctachq>";
	$xml .= "   <nrcheque>".$nrcheque."</nrcheque>";
	$xml .= "   <tpremess>".$tpremess."</tpremess>";
	$xml .= "   <flgblqim>".$flgblqim."</flgblqim>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "CHEQ0002", "BLOQUEAR_IMAGENS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"],
		$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','unblockBackground();',false);
	}

?>