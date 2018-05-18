<?
/*!
 * FONTE        : manter_rotina_webservice.php
 * CRIAÇÃO      : Anderson Fossa
 * DATA CRIAÇÃO : 11/05/2018
 * OBJETIVO     : Manter as configuracao de webservice Bancoob
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
	
	if(isset($_POST['cddopcao'])){
		$sOpcao = $_POST['cddopcao'];		
	}
	if(isset($_POST['cdcooper'])){
		$iCdcooper = $_POST['cdcooper'];
	}
	
	function exibeErroNew($msgErro) {
		echo 'hideMsgAguardo();';
		echo 'showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");';
		exit();
	}

	if( (!isset($_POST['cddopcao'])) || ($sOpcao <> 'C' and $sOpcao <> 'A')){
		$msgErro = 'Opcao invalida';
		exibeErroNew($msgErro);
		exit();
	}
		
	if (!is_numeric($iCdcooper)){
		$msgErro = 'Parametros invalidos';
		exibeErroNew($msgErro);
		exit();
	}

	$sRetorno = '';
	if ($sOpcao == 'C'){
		$xml = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cdcooper>$iCdcooper</cdcooper>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "ARQBCB", "ARQBCB_CONSULTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);
		
		//echo '/*'.$xmlResult.'*/';

		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			if ($msgErro == "") {
				$msgErro = $xmlObj->roottag->tags[0]->cdata;
			}

			exibeErroNew($msgErro);
			exit();
		}

		$registros = $xmlObj->roottag->tags[0]->tags;
		$iConfig = getByTagName($registros,'flctgbcb');
        
		$sRetorno = '$("#flctgbcb").val("'. $iConfig .'");';
				
	} else if ($sOpcao == 'A') {
		
		if( (!isset($_POST['flctgbcb'])) || (!is_numeric($_POST['flctgbcb']))){
			$msgErro = 'Parametro de configuracao invalido';
			exibeErroNew($msgErro);
			exit();
		}
		$flctgbcb = $_POST['flctgbcb'];
		
		$xml = "<Root>";
		$xml .= " <Dados>";
		$xml .= "   <cdcooper>$iCdcooper</cdcooper>";
		$xml .= "   <flctgbcb>$flctgbcb</flctgbcb>";
		$xml .= " </Dados>";
		$xml .= "</Root>";

		$xmlResult = mensageria($xml, "ARQBCB", "ARQBCB_MANTEM", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);
		
		echo '/*'.$xml.'*/';

		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			if ($msgErro == "") {
				$msgErro = $xmlObj->roottag->tags[0]->cdata;
			}

			exibeErroNew($msgErro);
			exit();
		}
				
		$sRetorno = 'showError("inform", "Configuracao alterada com sucesso.", "Alerta - Ayllos", "estadoInicial();");';
		
	} else {
		$msgErro = 'Opcao invalida';
		exibeErroNew($msgErro);
		exit();
	}
	
	
	echo 'hideMsgAguardo();';
	echo $sRetorno;
	
?>