<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 16/02/2011
 * OBJETIVO     : Capturar dados para tela ANOTA
 * --------------
 * ALTERAÇÕES   : 29/11/2016 - P341-Automatização BACENJUD - Removido DSDEPART do XML pois 
 *                             o mesmo não é utilizado na BO (Renato Darosci)
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
	
	$mtdErro  = "$('#nrdconta','#frmCabAnota').focus();";	
	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
	$nrseqdig = (isset($_POST['nrseqdig'])) ? $_POST['nrseqdig'] : 0  ;
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;
	
	switch($operacao) {
		case ''  : $cddopcao = 'C'; break;
		case 'FC': $cddopcao = 'C'; break;		
		case 'FA': $cddopcao = 'A'; break;
		case 'TA': $cddopcao = 'A'; break;
		case 'FI': $cddopcao = 'I'; break;
		case 'TI': $cddopcao = 'I'; break;
		case 'FE': $cddopcao = 'E'; break;
		case 'TE': $cddopcao = 'E'; break;
		default  : $cddopcao = 'C'; break;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Anota','',false);
	}
	
	// Se conta informada não for um número inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Anota','',false);
	
	if ($operacao != '') {	
		// Monta o xml de requisição
		$xmlAnota  = '';
		$xmlAnota .= '<Root>';
		$xmlAnota .= '	<Cabecalho>';
		$xmlAnota .= '		<Bo>b1wgen0085.p</Bo>';
		$xmlAnota .= '		<Proc>busca_dados</Proc>';
		$xmlAnota .= '	</Cabecalho>';
		$xmlAnota .= '	<Dados>';
		$xmlAnota .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
		$xmlAnota .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
		$xmlAnota .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
		$xmlAnota .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
		$xmlAnota .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
		$xmlAnota .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
		$xmlAnota .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
		$xmlAnota .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
		$xmlAnota .= '		<nrseqdig>'.$nrseqdig.'</nrseqdig>';
		$xmlAnota .= '	</Dados>';
		$xmlAnota .= '</Root>';
		
		// Executa script para envio do XML e cria objeto para classe de tratamento de XML
		$xmlResult 	= getDataXML($xmlAnota);
		$xmlObjeto 	= getObjectXML($xmlResult);		

		// Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
			$operacao = '';
			$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;								
			exibirErro('error',$msgErro,'Alerta - Anota',$mtdErro,false);
		} 
		
		$associado = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
		$registros = $xmlObjeto->roottag->tags[1]->tags;
						
	} 
	
	include('form_cabecalho.php');	
	
	if(in_array($operacao,array('TA','TE','TI'))) {
		include('form_anota.php');	
	
	} else if(in_array($operacao,array('FI','FC','FA','FE',''))) {
		include('tab_anota.php');
	}else if($operacao == 'TC') {
		include('form_visualiza.php');
	}
	
?>
<form action="<?php echo $UrlSite; ?>telas/anota/imprimir_dados.php" name="frmImprimir" id="frmImprimir" method="post">
<input type="hidden" name="nrdconta" id="nrdconta" value="">
<input type="hidden" name="nrseqdig" id="nrseqdig" value="">
<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
</form>

<script type='text/javascript'>
	
	// Alimenta as variáveis globais
	operacao = '<? echo $operacao; ?>';
	nrdconta = '<? echo $nrdconta; ?>';
	
	controlaLayout();
	controlaFoco();	
	
</script>
