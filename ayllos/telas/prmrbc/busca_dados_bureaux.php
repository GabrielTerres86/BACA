<?
/*!
 * FONTE        : busca_dados_bureaux.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Janeiro/2015
 * OBJETIVO     : Rotina para buscar os dados PRMRBC
 * --------------
 * ALTERAÇÕES   : 23/03/2016 - Inclusão do campo idenvseg conforme solicitado no 
 *                             chamado 412682. (Kelvin)
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

	$idtpreme = (isset($_POST['idtpreme'])) ? $_POST['idtpreme'] : ''  ;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'I')) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<idtpreme>'.$idtpreme.'</idtpreme>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "PRMRBC", "CONSBUR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',"",false);
	}

	// Recebendo os valores atraves de atriburos da TAG
	$idtpreme    = $xmlObjeto->roottag->tags[0]->attributes['IDTPREME'];
	$flgativo    = $xmlObjeto->roottag->tags[0]->attributes['FLGATIVO'];
	$idenvseg    = $xmlObjeto->roottag->tags[0]->attributes['IDENVSEG'];
	$flremseq    = $xmlObjeto->roottag->tags[0]->attributes['FLREMSEQ'];
	$dsfnchrm    = $xmlObjeto->roottag->tags[0]->attributes['DSFNCHRM'];
	$idtpenvi    = $xmlObjeto->roottag->tags[0]->attributes['IDTPENVI'];
	$dsdirenv    = $xmlObjeto->roottag->tags[0]->attributes['DSDIRENV'];
	$dsfnburm    = $xmlObjeto->roottag->tags[0]->attributes['DSFNBURM'];
	$dssitftp    = $xmlObjeto->roottag->tags[0]->attributes['DSSITFTP'];
	$dsusrftp    = $xmlObjeto->roottag->tags[0]->attributes['DSUSRFTP'];
	$dspwdftp    = $xmlObjeto->roottag->tags[0]->attributes['DSPWDFTP'];
	$dsdreftp    = $xmlObjeto->roottag->tags[0]->attributes['DSDREFTP'];
	$dsdrencd    = $xmlObjeto->roottag->tags[0]->attributes['DSDRENCD'];
	$dsdrevcd    = $xmlObjeto->roottag->tags[0]->attributes['DSDREVCD'];
	$dsfnrnen    = $xmlObjeto->roottag->tags[0]->attributes['DSFNRNEN'];
	$idopreto    = $xmlObjeto->roottag->tags[0]->attributes['IDOPRETO'];
	$qthorret    = $xmlObjeto->roottag->tags[0]->attributes['QTHORRET'];
	$dsdrrftp    = $xmlObjeto->roottag->tags[0]->attributes['DSDRRFTP'];
	$dsdrrecd    = $xmlObjeto->roottag->tags[0]->attributes['DSDRRECD'];
	$dsdrrtcd    = $xmlObjeto->roottag->tags[0]->attributes['DSDRRTCD'];
    $dsdirret    = $xmlObjeto->roottag->tags[0]->attributes['DSDIRRET'];
	$dsfnrndv    = $xmlObjeto->roottag->tags[0]->attributes['DSFNRNDV'];
	$dsfnburt    = $xmlObjeto->roottag->tags[0]->attributes['DSFNBURT'];
	$dsfnchrt    = $xmlObjeto->roottag->tags[0]->attributes['DSFNCHRT'];
	$idtpsoli    = $xmlObjeto->roottag->tags[0]->attributes['IDTPSOLI'];
	$hrinterv    = $xmlObjeto->roottag->tags[0]->attributes['HRINTERV'];
    


	// Exibe os valores na tela
	echo "cIdtpreme.val('".$idtpreme."');";
	echo "cFlgativo.val('".$flgativo."');";
	echo "cIdenvseg.val('".$idenvseg."');";
	echo "cFlremseq.val('".$flremseq."');";
	echo "cDsfnchrm.val('".$dsfnchrm."');";
	echo "cIdtpenvi.val('".$idtpenvi."');";
	echo "cDsdirenv.val('".$dsdirenv."');";
	echo "cDsfnburm.val('".$dsfnburm."');";
	echo "cDssitftp.val('".$dssitftp."');";
	echo "cDsusrftp.val('".$dsusrftp."');";
	echo "cDspwdftp.val('".$dspwdftp."');";
	echo "cDsdreftp.val('".$dsdreftp."');";
	echo "cDsdrencd.val('".$dsdrencd."');";
	echo "cDsdrevcd.val('".$dsdrevcd."');";
	echo "cDsfnrnen.val('".$dsfnrnen."');";
	echo "cIdopreto.val('".$idopreto."');";
	echo "cQthorret.val('".$qthorret."');";
	echo "cDsdrrftp.val('".$dsdrrftp."');";
	echo "cDsdrrecd.val('".$dsdrrecd."');";
	echo "cDsdrrtcd.val('".$dsdrrtcd."');";
	echo "cDsdirret.val('".$dsdirret."');";
	echo "cDsfnrndv.val('".$dsfnrndv."');";
	echo "cDsfnburt.val('".$dsfnburt."');";
	echo "cDsfnchrt.val('".$dsfnchrt."');";
	echo "cIdtpsoli.val('".$idtpsoli."');";
	echo "cHrinterv.val('".$hrinterv."');";

	if ($idtpenvi == "F" && $idopreto != "S") {
		echo "$('#divFtpEnvio').css({'display':'block'});";
		echo "$('#divFtpRetorno').css({'display':'block'});";
	}else
	if ($idtpenvi == "C" && $idopreto != "S") {
		echo "$('#divCdEnvio').css({'display':'block'});";
		echo "$('#divCdRetorno').css({'display':'block'});";
	}else
	if ($idtpenvi == "F" && $idopreto == "S") {
		echo "$('#divFtpEnvio').css({'display':'block'});";
		echo "$('#divFtpRetorno').css({'display':'block'});";
		echo "$('#divRetornoArq').css({'display':'none'});";
		echo "$('#divFtpRetorno').css({'display':'none'});";
		echo "$('#divCdRetorno').css({'display':'none'});";
	}else
	if ($idtpenvi == "C" && $idopreto == "S") {
		echo "$('#divCdEnvio').css({'display':'block'});";
		echo "$('#divCdRetorno').css({'display':'block'});";
		echo "$('#divRetornoArq').css({'display':'none'});";
		echo "$('#divFtpRetorno').css({'display':'none'});";
		echo "$('#divCdRetorno').css({'display':'none'});";
	}
?>