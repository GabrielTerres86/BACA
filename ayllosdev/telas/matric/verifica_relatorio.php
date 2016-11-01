<?
/*!
 * FONTE        : verifica_relatorio.php
 * CRIA��O      : Gabriel Capoia (DB1)
 * DATA CRIA��O : 06/08/2010
 * OBJETIVO     : Verifica possibilidade de imprimir relatorio da tela MATRIC para uma determinada conta
 * --------------
 * ALTERA��ES   : 28/10/2015 - Reformulacao cadastral (Gabriel-RKAM)
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
	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'R';
	
	// Se conta informada n�o for um n�mero inteiro v�lido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv�lida.','Alerta - Matric','',false);
	
	// Monta o xml de requisi��o
	$xmlMatric  = '';
	$xmlMatric .= '<Root>';
	$xmlMatric .= '	<Cabecalho>';
	$xmlMatric .= '		<Bo>b1wgen0052.p</Bo>';
	$xmlMatric .= '		<Proc>busca_dados</Proc>';
	$xmlMatric .= '	</Cabecalho>';
	$xmlMatric .= '	<Dados>';
	$xmlMatric .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xmlMatric .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xmlMatric .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xmlMatric .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xmlMatric .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xmlMatric .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xmlMatric .= '		<dsdepart>'.$glbvars['dsdepart'].'</dsdepart>';		
	$xmlMatric .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xmlMatric .= '		<cddopcao>R</cddopcao>';
	$xmlMatric .= '		<idseqttl>1</idseqttl>';
	$xmlMatric .= '	</Dados>';
	$xmlMatric .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult 	= getDataXML($xmlMatric);
	$xmlObjeto 	= getObjectXML($xmlResult);
	
	$metodo = ($cddopcao == 'CI') ? 'efetuar_consultas();' : 'unblockBackground();';
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') 
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Matric',$metodo,false);
?>