<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 27/12/2011
 * OBJETIVO     : Capturar dados para tela CADSPC
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

	// Recebe o POST
	$cddopcao 			= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$nrcpfcgc 			= (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : 0  ;
	$nrdconta 			= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
	$tpidenti 			= (isset($_POST['tpidenti'])) ? $_POST['tpidenti'] : 0  ;
	$nrctremp 			= (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0  ;
	$tpctrdev 			= (isset($_POST['tpctrdev'])) ? $_POST['tpctrdev'] : 0  ;
	$nrdrowid 			= (isset($_POST['nrdrowid'])) ? $_POST['nrdrowid'] : 0  ;
	$nrregist 			= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0  ;
	$nriniseq 			= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0  ;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0133.p</Bo>';
	$xml .= '		<Proc>Busca_Dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<cdprogra>CADSPC</cdprogra>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<tpidenti>'.$tpidenti.'</tpidenti>';
	$xml .= '		<nrctremp>'.$nrctremp.'</nrctremp>';
	$xml .= '		<tpctrdev>'.$tpctrdev.'</tpctrdev>';
	$xml .= '		<nrdrowid>'.$nrdrowid.'</nrdrowid>';
	$xml .= '		<nrregist>'.$nrregist.'</nrregist>';
	$xml .= '		<nriniseq>'.$nriniseq.'</nriniseq>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult 	= getDataXML($xml);
	$xmlObjeto 	= getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		if (!empty($nmdcampo)) { $retornoAposErro = $retornoAposErro . " $('#".$nmdcampo."','#frmDevedor').focus();"; }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	} 

	$registro 	= $xmlObjeto->roottag->tags[0]->tags;
	$qtregist	= $xmlObjeto->roottag->tags[0]->attributes['QTREGIST'];

	include('form_cabecalho.php');
	include('form_devedor.php');
	include('form_opcao_c.php');
	include('form_cadspc.php');
	include('div_botoes.php'); 	
?>

<script>
controlaLayout();
</script>