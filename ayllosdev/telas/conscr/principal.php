<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 01/12/2011
 * OBJETIVO     : Capturar dados para tela CONSCR
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
    $tpconsul			= (isset($_POST['tpconsul'])) ? $_POST['tpconsul'] : 0  ;
	$nrdconta			= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
	$nrcpfcgc			= (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : 0  ;
	$cdagenci			= (isset($_POST['cdagenci'])) ? $_POST['cdagenci'] : 0  ;
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
	}
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0125.p</Bo>';
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
	$xml .= '		<tpconsul>'.$tpconsul.'</tpconsul>';
	$xml .= '		<nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult 	= getDataXML($xml);
	$xmlObjeto 	= getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;								
		exibirErro('error',$msgErro,'Alerta - Aimaro','',false);
	} 

	$registro 	= $xmlObjeto->roottag->tags[0]->tags;
	$contador 	= $xmlObjeto->roottag->tags[0]->attributes['CONTADOR'];
	
	// Verifica se voltou o numero do contrato
	include('form_cabecalho.php');
	include('tab_conscr.php');

?>

<script>
	nrdconta = '<?php echo getByTagName($registro[0]->tags,'nrdconta'); ?>';
	nrcpfcgc = '<?php echo getByTagName($registro[0]->tags,'nrcpfcgc'); ?>';
	nmprimtl = '<?php echo getByTagName($registro[0]->tags,'nmprimtl'); ?>';
	controlaLayout('<?php echo $contador ?>');
</script>