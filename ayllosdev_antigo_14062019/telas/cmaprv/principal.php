<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 30/09/2011
 * OBJETIVO     : Capturar dados para tela CMAPRV
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
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$cdagenc1 = (isset($_POST['cdagenc1'])) ? $_POST['cdagenc1'] : 0  ;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
	$dtpropos = (isset($_POST['dtpropos'])) ? $_POST['dtpropos'] : '' ;
	$dtaprova = (isset($_POST['dtaprova'])) ? $_POST['dtaprova'] : '' ;
	$dtaprfim = (isset($_POST['dtaprfim'])) ? $_POST['dtaprfim'] : '' ;
	$aprovad1 = (isset($_POST['aprovad1'])) ? $_POST['aprovad1'] : 0  ;
	$aprovad2 = (isset($_POST['aprovad2'])) ? $_POST['aprovad2'] : 0  ;
	$cdopeapv = (isset($_POST['cdopeapv'])) ? $_POST['cdopeapv'] : '' ;
	$nriniseq = (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0  ;
	$nrregist = (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0  ;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Se conta informada não for um número inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Ayllos','',false);
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0114.p</Bo>';
	$xml .= '		<Proc>Busca_Dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<cdagenc1>'.$cdagenc1.'</cdagenc1>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<dtpropos>'.$dtpropos.'</dtpropos>';
	$xml .= '		<dtaprova>'.$dtaprova.'</dtaprova>';
	$xml .= '		<dtaprfim>'.$dtaprfim.'</dtaprfim>';
	$xml .= '		<aprovad1>'.$aprovad1.'</aprovad1>';
	$xml .= '		<aprovad2>'.$aprovad2.'</aprovad2>';
	$xml .= '		<cdopeapv>'.$cdopeapv.'</cdopeapv>';
	$xml .= '		<nriniseq>'.$nriniseq.'</nriniseq>';
	$xml .= '		<nrregist>'.$nrregist.'</nrregist>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult 	= getDataXML($xml);
	$xmlObjeto 	= getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;								
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	} 

	$registros 	= $xmlObjeto->roottag->tags[0]->tags;
	$qtregist	= $xmlObjeto->roottag->tags[0]->attributes['QTREGIST'];
	
	include('form_cabecalho.php');	
	include('tab_cmaprv.php');
	include('form_cmaprv.php');
	
?>
<script type='text/javascript'>	
	atualizaSeletor();	
	formataCabecalho();
	formataDados('<?php echo $qtregist ?>');
	formataTabela();
</script>

