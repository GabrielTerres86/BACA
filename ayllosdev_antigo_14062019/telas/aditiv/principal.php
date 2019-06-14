<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 30/09/2011
 * OBJETIVO     : Capturar dados para tela ADITIV
 * --------------
 * ALTERAÇÕES   : 01/11/2017 - Passagem do tpctrato. (Jaison/Marcos Martini - PRJ404)
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
	$nrdconta 			= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
	$nrctremp 			= (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : 0  ;
	$nraditiv 			= (isset($_POST['nraditiv'])) ? $_POST['nraditiv'] : 0  ;
	$dtmvtolx 			= (isset($_POST['dtmvtolx'])) ? $_POST['dtmvtolx'] : '' ;
	$cdaditiv 			= (isset($_POST['cdaditiv'])) ? $_POST['cdaditiv'] : 0  ;
	$tpctrato           = (isset($_POST['tpctrato'])) ? $_POST['tpctrato'] : 0  ;
	$nriniseq 			= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0  ;
	$nrregist 			= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0  ;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	// Se conta informada não for um número inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Aimaro','',false);
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0115.p</Bo>";
	$xml .= "        <Proc>Busca_Dados</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<dtmvtopr>'.$glbvars['dtmvtopr'].'</dtmvtopr>';
	$xml .= '		<inproces>'.$glbvars['inproces'].'</inproces>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';	
	$xml .= '		<nrctremp>'.$nrctremp.'</nrctremp>';	
	$xml .= '		<dtmvtolx>'.$dtmvtolx.'</dtmvtolx>';	
	$xml .= '		<nraditiv>'.$nraditiv.'</nraditiv>';	
	$xml .= '		<cdaditiv>'.$cdaditiv.'</cdaditiv>';	
	$xml .= '		<tpctrato>'.$tpctrato.'</tpctrato>';
	$xml .= '		<nriniseq>'.$nriniseq.'</nriniseq>';	
	$xml .= '		<nrregist>'.$nrregist.'</nrregist>';	
	$xml .= "  </Dados>";
	$xml .= "</Root>";	
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult 	= getDataXML($xml);
	$xmlObjeto 	= getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;								
		exibirErro('error',$msgErro,'Alerta - Aimaro','',false);
	} 

	$qtregist   = $xmlObjeto->roottag->tags[0]->attributes['QTREGIST'];
	$registros 	= $xmlObjeto->roottag->tags[0]->tags;
	
	include('form_cabecalho.php');
	include('tab_aditiv.php');
	
?>
<script type='text/javascript'>
	cddopcao = 'V';
	atualizaSeletor();
	formataCabecalho();
	formataTabela();
	controlaLayout();
</script>

