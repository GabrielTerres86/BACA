<? 
/*!
 * FONTE        : busca_contrato.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 08/03/2012 
 * OBJETIVO     : Rotina para busca dos contratos
 */
?>
 
<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	$retornoAposErro = '';
	
	// Guardo os parâmetos do POST em variáveis	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ;
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : 0 ;
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0 ;
	$tpidenti = (isset($_POST['tpidenti'])) ? $_POST['tpidenti'] : 0 ;
	$tpctrdev = (isset($_POST['tpctrdev'])) ? $_POST['tpctrdev'] : 0 ;
	$nrctaavl = (isset($_POST['nrctaavl'])) ? $_POST['nrctaavl'] : 0 ;
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0133.p</Bo>";
	$xml .= "        <Proc>Busca_Contratos</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<cdprogra>'.$glbvars['cdprogra'].'</cdprogra>';	
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';	
	$xml .= '		<nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
	$xml .= '		<nrctremp>'.$nrctremp.'</nrctremp>';
	$xml .= '		<tpidenti>'.$tpidenti.'</tpidenti>';
	$xml .= "		<tpctrdev>".$tpctrdev."</tpctrdev>";
	$xml .= "		<nrctaavl>".$nrctaavl."</nrctaavl>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";	
	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		$msgErro	= $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObj->roottag->tags[0]->attributes['NMDCAMPO'];
		if (!empty($nmdcampo)) { $retornoAposErro = $retornoAposErro . " $('#".$nmdcampo."','#frmCadSPC').focus();"; }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	$registros = $xmlObj->roottag->tags[0]->tags;
	include('tab_contrato.php');
							
?>