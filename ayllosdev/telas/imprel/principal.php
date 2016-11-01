<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 24/08/2011
 * OBJETIVO     : Capturar dados para tela IMPREL
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
	$cddopcao	= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 0  ;
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],"C")) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0109.p</Bo>';
	$xml .= '		<Proc>Lista_Relatorios</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
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

	$registro = $xmlObjeto->roottag->tags[0]->tags;
	include('form_cabecalho.php');
	
?>

<script>
	formataCabecalho();
	controlaLayout();
</script>