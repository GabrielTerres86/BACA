<? 
/*!
 * FONTE        : busca_dados.php
 * CRIAÇÃO      : Douglas Quisinski
 * DATA CRIAÇÃO : 15/04/2016
 * OBJETIVO     : Rotina para buscar dados dos horarios de pagamento - PARHPG
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 *
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

	$cdcooper = (isset($_POST["cdcooper"])) ? $_POST["cdcooper"] : '';
	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "    <cdcooper>".$cdcooper."</cdcooper>";
	$xml .= "    <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_PARHPG", "BUSCA_HORARIOS_PARHPG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}

	$horarios = $xmlObj->roottag->tags[0]->tags;
	echo '$("#hrsicini","#frmHorarios").val("'.getByTagName($horarios,'hrsicini').'");';
	echo '$("#hrsicfim","#frmHorarios").val("'.getByTagName($horarios,'hrsicfim').'");';
	echo '$("#hrtitini","#frmHorarios").val("'.getByTagName($horarios,'hrtitini').'");';
	echo '$("#hrtitfim","#frmHorarios").val("'.getByTagName($horarios,'hrtitfim').'");';
	echo '$("#hrnetini","#frmHorarios").val("'.getByTagName($horarios,'hrnetini').'");';
	echo '$("#hrnetfim","#frmHorarios").val("'.getByTagName($horarios,'hrnetfim').'");';
	echo '$("#hrtaaini","#frmHorarios").val("'.getByTagName($horarios,'hrtaaini').'");';
	echo '$("#hrtaafim","#frmHorarios").val("'.getByTagName($horarios,'hrtaafim').'");';
	echo '$("#hrgpsini","#frmHorarios").val("'.getByTagName($horarios,'hrgpsini').'");';
	echo '$("#hrgpsfim","#frmHorarios").val("'.getByTagName($horarios,'hrgpsfim').'");';
	echo '$("#hrsiccan","#frmHorarios").val("'.getByTagName($horarios,'hrsiccan').'");';
	echo '$("#hrtitcan","#frmHorarios").val("'.getByTagName($horarios,'hrtitcan').'");';
	echo '$("#hrnetcan","#frmHorarios").val("'.getByTagName($horarios,'hrnetcan').'");';
	echo '$("#hrtaacan","#frmHorarios").val("'.getByTagName($horarios,'hrtaacan').'");';
	echo '$("#hrvlbini","#frmHorarios").val("'.getByTagName($horarios,'hrvlbini').'");';
	echo '$("#hrvlbfim","#frmHorarios").val("'.getByTagName($horarios,'hrvlbfim').'");';
	echo '$("#hrdiuini","#frmHorarios").val("'.getByTagName($horarios,'hrdiuini').'");';
	echo '$("#hrdiufim","#frmHorarios").val("'.getByTagName($horarios,'hrdiufim').'");';
	echo '$("#hrnotini","#frmHorarios").val("'.getByTagName($horarios,'hrnotini').'");';
	echo '$("#hrnotfim","#frmHorarios").val("'.getByTagName($horarios,'hrnotfim').'");';
	
	echo 'liberaCamposAtualizar();';
?>