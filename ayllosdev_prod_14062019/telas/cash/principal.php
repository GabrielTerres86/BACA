<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 11/11/2011
 * OBJETIVO     : Capturar dados para tela CASH
 * --------------
 * ALTERAÇÕES   : 30/11/2016 - P341-Automatização BACENJUD - Alterado para passar como parametro o  
 *                             código do departamento ao invés da descrição (Renato Darosci - Supero)
 *
 *                03/07/2018 - sctask0014656 agora é possível alterar o nome do TAA na
 *                             opção A. Registro de alteração do nome no log da tela 
 *                             (Carlos)
 * -------------- 
 */ 
	session_start();	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		


	// Recebe o POST
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;	
	$nrterfin = (isset($_POST['nrterfin'])) ? $_POST['nrterfin'] : 0  ;	
	$dsterfin = (isset($_POST['dsterfin'])) ? $_POST['dsterfin'] : '' ;	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0123.p</Bo>';
	$xml .= '		<Proc>Busca_Dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<cdprogra>'.$glbvars['cdprogra'].'</cdprogra>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<dtmvtopr>'.$glbvars['dtmvtopr'].'</dtmvtopr>';	
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<cddepart>'.$glbvars['cddepart'].'</cddepart>';	
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<nrterfin>'.$nrterfin.'</nrterfin>';
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

	$terminal 	= $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	$nrdlacre 	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[15]->tags;
	$qtnotcas 	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[16]->tags;
	$vlnotcas 	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[17]->tags;
	$vltotcas 	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[18]->tags;
	$dsterfin   = $cddopcao == 'I' ? $dsterfin : getByTagName($terminal,'dsterfin');
	
  $nmterfin   = getByTagName($terminal,'nmterfin');
	
	include('form_cabecalho.php');
	include('form_cash.php');
	
?>

<script>
controlaLayout('<? echo $operacao ?>');
</script>