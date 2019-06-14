<?
/*!
 * FONTE        : grava_dados_bureaux.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Janeiro/2015
 * OBJETIVO     : Rotina para gravar os dados PRMRBC
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

	// Recebe o POST
	$lstpreme    = (isset($_POST['lstpreme'])) ? $_POST['lstpreme'] : ' '  ;
	$idtpreme    = (isset($_POST['idtpreme'])) ? $_POST['idtpreme'] : ' '  ;
	$flgativo    = (isset($_POST['flgativo'])) ? $_POST['flgativo'] : ' '  ;
	$idenvseg    = (isset($_POST['idenvseg'])) ? $_POST['idenvseg'] : ' '  ;
	$flremseq    = (isset($_POST['flremseq'])) ? $_POST['flremseq'] : ' '  ;
    $idtpsoli    = (isset($_POST['idtpsoli'])) ? $_POST['idtpsoli'] : ' '  ;
	$dsfnchrm    = (isset($_POST['dsfnchrm'])) ? $_POST['dsfnchrm'] : ' '  ;
	$idtpenvi    = (isset($_POST['idtpenvi'])) ? $_POST['idtpenvi'] : ' '  ;
	$dsdirenv    = (isset($_POST['dsdirenv'])) ? $_POST['dsdirenv'] : ' '  ;
	$dsfnburm    = (isset($_POST['dsfnburm'])) ? $_POST['dsfnburm'] : ' '  ;
	$dssitftp    = (isset($_POST['dssitftp'])) ? $_POST['dssitftp'] : ' '  ;
	$dsusrftp    = (isset($_POST['dsusrftp'])) ? $_POST['dsusrftp'] : ' '  ;
	$dspwdftp    = (isset($_POST['dspwdftp'])) ? $_POST['dspwdftp'] : ' '  ;
	$dsdreftp    = (isset($_POST['dsdreftp'])) ? $_POST['dsdreftp'] : ' '  ;
	$dsdrencd    = (isset($_POST['dsdrencd'])) ? $_POST['dsdrencd'] : ' '  ;
	$dsdrevcd    = (isset($_POST['dsdrevcd'])) ? $_POST['dsdrevcd'] : ' '  ;
	$dsfnrnen    = (isset($_POST['dsfnrnen'])) ? $_POST['dsfnrnen'] : ' '  ;
	$idopreto    = (isset($_POST['idopreto'])) ? $_POST['idopreto'] : ' '  ;
	$qthorret    = (isset($_POST['qthorret'])) ? $_POST['qthorret'] : ' '  ;
    $hrinterv    = (isset($_POST['hrinterv'])) ? $_POST['hrinterv'] : ' '  ;
	$dsdrrftp    = (isset($_POST['dsdrrftp'])) ? $_POST['dsdrrftp'] : ' '  ;
	$dsdrrecd    = (isset($_POST['dsdrrecd'])) ? $_POST['dsdrrecd'] : ' '  ;
	$dsdrrtcd    = (isset($_POST['dsdrrtcd'])) ? $_POST['dsdrrtcd'] : ' '  ;
	$dsdirret    = (isset($_POST['dsdirret'])) ? $_POST['dsdirret'] : ' '  ;
	$dsfnrndv    = (isset($_POST['dsfnrndv'])) ? $_POST['dsfnrndv'] : ' '  ;
	$dsfnburt    = (isset($_POST['dsfnburt'])) ? $_POST['dsfnburt'] : ' '  ;
	$dsfnchrt    = (isset($_POST['dsfnchrt'])) ? $_POST['dsfnchrt'] : ' '  ;
	
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
	$xml .= '		<lstpreme>'.$lstpreme.'</lstpreme>';
	$xml .= '		<idtpreme>'.$idtpreme.'</idtpreme>';
	$xml .= '		<flgativo>'.$flgativo.'</flgativo>';
	$xml .= '		<idenvseg>'.$idenvseg.'</idenvseg>';	
	$xml .= '		<flremseq>'.$flremseq.'</flremseq>';
    $xml .= '       <idtpsoli>'.$idtpsoli.'</idtpsoli>';
	$xml .= '		<dsfnchrm>'.$dsfnchrm.'</dsfnchrm>';
	$xml .= '		<idtpenvi>'.$idtpenvi.'</idtpenvi>';
	$xml .= '		<dsdirenv>'.$dsdirenv.'</dsdirenv>';
	$xml .= '		<dsfnburm>'.$dsfnburm.'</dsfnburm>';
	$xml .= '		<dssitftp>'.$dssitftp.'</dssitftp>';
	$xml .= '		<dsusrftp>'.$dsusrftp.'</dsusrftp>';
	$xml .= '		<dspwdftp>'.$dspwdftp.'</dspwdftp>';
	$xml .= '		<dsdreftp>'.$dsdreftp.'</dsdreftp>';
	$xml .= '		<dsdrencd>'.$dsdrencd.'</dsdrencd>';
	$xml .= '		<dsdrevcd>'.$dsdrevcd.'</dsdrevcd>';
	$xml .= '		<dsfnrnen>'.$dsfnrnen.'</dsfnrnen>';
	$xml .= '		<idopreto>'.$idopreto.'</idopreto>';
	$xml .= '		<qthorret>'.$qthorret.'</qthorret>';
	$xml .= '		<hrinterv>'.$hrinterv.'</hrinterv>';
	$xml .= '		<dsdrrftp>'.$dsdrrftp.'</dsdrrftp>';
	$xml .= '		<dsdrrecd>'.$dsdrrecd.'</dsdrrecd>';
	$xml .= '		<dsdrrtcd>'.$dsdrrtcd.'</dsdrrtcd>';
	$xml .= '		<dsdirret>'.$dsdirret.'</dsdirret>';
	$xml .= '		<dsfnrndv>'.$dsfnrndv.'</dsfnrndv>';
	$xml .= '		<dsfnburt>'.$dsfnburt.'</dsfnburt>';
	$xml .= '		<dsfnchrt>'.$dsfnchrt.'</dsfnchrt>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "PRMRBC", "GPRMBUX", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$retornoAposErro = 'c'.ucfirst($xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO']).'.focus();';
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

?>