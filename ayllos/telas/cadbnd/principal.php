<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : Maio/2013
 * OBJETIVO     : Capturar dados para tela CADBND
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
	
	$mtdErro  = "$('#nrdconta','#frmCab').focus();";	
	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
    $cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Cadbnd','',false);
	}
	
	// Se conta informada não for um número inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Cadbnd','',false);
	
		// Monta o xml de requisição
		$xml  = '';
		$xml .= '<Root>';
		$xml .= '	<Cabecalho>';
		$xml .= '		<Bo>b1wgen0147.p</Bo>';
		$xml .= '		<Proc>busca_dados</Proc>';
		$xml .= '	</Cabecalho>';
		$xml .= '	<Dados>';
		$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
		$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
		$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
		$xml .= '	</Dados>';
		$xml .= '</Root>';
		
		// Executa script para envio do XML e cria objeto para classe de tratamento de XML
		$xmlResult 	= getDataXML($xml);
		$xmlObjeto 	= getObjectXML($xmlResult);		

		// Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
			$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[5]->cdata;								
			exibirErro('error',$msgErro,'Alerta - Cadbnd',$mtdErro,false);
			
	}
			
	$nmprimtl 	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[2]->cdata;
	$nrcpfcgc 	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[3]->cdata;
		
	include('form_cabecalho.php');	
	
?>

<script type='text/javascript'>
	
	// Alimenta as variáveis globais
		
	nrdconta = '<? echo $nrdconta; ?>';
	cddopcao = '<? echo $cddopcao; ?>';
	
	<?php
		echo '$("#nrdconta","#frmCab").val("'.$nrdconta.'").formataDado("INTEGER","zzzz.zzz-z","",false);';		
		echo '$("#cddopcao","#frmCab").val("'.$cddopcao.'");';
	?>
</script>

