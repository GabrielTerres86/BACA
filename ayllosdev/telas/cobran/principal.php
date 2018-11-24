<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 19/01/2012
 * OBJETIVO     : Capturar dados para tela DESCTO
 * --------------
 * ALTERAÇÕES   :  16/11/2015 - Adicioando campo "somente crise" inestcri. (Jorge/Andrino)
 *
 *  		       30/12/2015 - Alterações Referente Projeto Negativação Serasa (Daniel)	
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
	$operacao 			= (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;
	$cddopcao 			= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$nrdconta			= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
	$nrdcontx			= (isset($_POST['nrdcontx'])) ? $_POST['nrdcontx'] : 0  ;
	$ininrdoc			= (isset($_POST['ininrdoc'])) ? $_POST['ininrdoc'] : 0  ;
	$fimnrdoc			= (isset($_POST['fimnrdoc'])) ? $_POST['fimnrdoc'] : 0  ;
	$nrinssac			= (isset($_POST['nrinssac'])) ? $_POST['nrinssac'] : 0  ;
	$nmprimtl			= (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : '' ;
	$nmprimtx			= (isset($_POST['nmprimtx'])) ? $_POST['nmprimtx'] : '' ;
    $indsitua			= (isset($_POST['indsitua'])) ? $_POST['indsitua'] : '' ;
	$numregis			= (isset($_POST['numregis'])) ? $_POST['numregis'] : 50 ;
	$iniseque			= (isset($_POST['iniseque'])) ? $_POST['iniseque'] : 1 ;
    $inidtven			= (validaData($_POST['inidtven'])) ? $_POST['inidtven'] : '' ;
    $fimdtven			= (validaData($_POST['fimdtven'])) ? $_POST['fimdtven'] : '' ;
    $inidtdpa			= (validaData($_POST['inidtdpa'])) ? $_POST['inidtdpa'] : '' ;
	$fimdtdpa 			= (validaData($_POST['fimdtdpa'])) ? $_POST['fimdtdpa'] : '' ;
	$inidtmvt 			= (validaData($_POST['inidtmvt'])) ? $_POST['inidtmvt'] : '' ;
	$fimdtmvt 			= (validaData($_POST['fimdtmvt'])) ? $_POST['fimdtmvt'] : '' ;
	$consulta 			= (isset($_POST['consulta'])) ? $_POST['consulta'] : 0  ;
	$tpconsul 			= (isset($_POST['tpconsul'])) ? $_POST['tpconsul'] : 0  ;
	$dsdoccop 			= (isset($_POST['dsdoccop'])) ? $_POST['dsdoccop'] : ''  ;
	$flgregis 			= (isset($_POST['flgregis'])) ? $_POST['flgregis'] : '' ;
	$inestcri 			= (isset($_POST['inestcri'])) ? $_POST['inestcri'] : '' ;
	$nriniseq 			= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 1  ;
	$nrregist 			= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 50  ;
	
	$inserasa 			= (isset($_POST['inserasa'])) ? $_POST['inserasa'] : ''  ;
	$ls_nrdoc 			= array();

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	switch( $operacao ) {
		case 'CB': $procedure = 'consulta-bloqueto'; 		break;
	}

	if ( $tpconsul == '1' or  $tpconsul == '2' ) {
		$fimnrdoc = $ininrdoc;	
	}
	
	if ( $consulta == '8' ) {
		$nrdconta = $nrdcontx;
	}

	function monta_xml($paginado) {
		global $procedure, $glbvars, $nrdconta, $ininrdoc, $fimnrdoc, $nrinssac, $nmprimtl, $indsitua,
			   $numregis, $iniseque, $inidtven, $fimdtven, $inidtdpa, $fimdtdpa, $inidtmvt, $fimdtmvt,
			   $consulta, $tpconsul, $dsdoccop, $flgregis, $inestcri, $nriniseq, $nrregist, $inserasa;

		// Monta o xml de requisição
		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Cabecalho>';
		$xml .= '		<Bo>b1wgen0010.p</Bo>';
		$xml .= '		<Proc>'.$procedure.'</Proc>';
		$xml .= '	</Cabecalho>';
		$xml .= '	<Dados>';
		$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
		$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
		$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
		$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
		$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
		$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
		$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
		$xml .= '		<ininrdoc>'.$ininrdoc.'</ininrdoc>';	
		$xml .= '		<fimnrdoc>'.$fimnrdoc.'</fimnrdoc>';	
		$xml .= '		<nrinssac>'.$nrinssac.'</nrinssac>';	
		$xml .= '		<nmprimtl>'.$nmprimtl.'</nmprimtl>';	
		$xml .= '		<indsitua>'.$indsitua.'</indsitua>';	
		$xml .= '		<numregis>'.$numregis.'</numregis>';	
		$xml .= '		<iniseque>'.$iniseque.'</iniseque>';	
		$xml .= '		<inidtven>'.$inidtven.'</inidtven>';	
		$xml .= '		<fimdtven>'.$fimdtven.'</fimdtven>';	
		$xml .= '		<inidtdpa>'.$inidtdpa.'</inidtdpa>';	
		$xml .= '		<fimdtdpa>'.$fimdtdpa.'</fimdtdpa>';
		$xml .= '		<inidtmvt>'.$inidtmvt.'</inidtmvt>';
		$xml .= '		<fimdtmvt>'.$fimdtmvt.'</fimdtmvt>';
		$xml .= '		<consulta>'.$consulta.'</consulta>';
		$xml .= '		<tpconsul>'.$tpconsul.'</tpconsul>';
		$xml .= '		<dsdoccop>'.$dsdoccop.'</dsdoccop>';
		$xml .= '		<flgregis>'.$flgregis.'</flgregis>';
		$xml .= '		<inestcri>'.$inestcri.'</inestcri>';
		if (!$paginado) {
			$xml .= '		<nriniseq>1</nriniseq>';
			$xml .= '		<nrregist>1000</nrregist>';
		} else {
			$xml .= '		<nriniseq>'.$nriniseq.'</nriniseq>';
			$xml .= '		<nrregist>'.$nrregist.'</nrregist>';
		}
		$xml .= '		<inserasa>'.$inserasa.'</inserasa>';
		$xml .= '	</Dados>';
		$xml .= '</Root>';

		return $xml;
	}

	// Monta o XML com paginação
	$xml = monta_xml(true);
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult 	= getDataXML($xml);
	$xmlObjeto 	= getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		if (!empty($nmdcampo)) { $retornoAposErro = $retornoAposErro . " $('#".$nmdcampo."','#frmOpcao').focus();"; }
		exibirErro('error',$msgErro,'Alerta - Aimaro',$retornoAposErro, false);
	} 

	$registro 	= $xmlObjeto->roottag->tags[0]->tags;
	$dados 		= $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	$qtregist	= $xmlObjeto->roottag->tags[0]->attributes['QTREGIST'];

	include('form_opcao_cabecalho.php');
	include('form_opcao_c.php');
	
	if ( $flgregis == 'no' ) {
		include('tab_sem_registro.php');
	} else if ( $flgregis == 'yes' ) {
		include('tab_com_registro.php');
	}
	
?>

<script>
	controlaOpcao();
</script>