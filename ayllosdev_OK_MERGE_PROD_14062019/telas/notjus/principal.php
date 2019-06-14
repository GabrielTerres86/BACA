<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : David Kruger
 * DATA CRIAÇÃO : 23/01/2013
 * OBJETIVO     : Capturar dados para tela NOTJUS
 * --------------
 * ALTERAÇÕES   : 19/11/2013 - Ajustes para homologação (Adriano)
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
	$nrdconta 			= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
	$cddopcao 			= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : ''  ;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Se conta informada não for um número inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Ayllos','',false);
	
	// Monta o xml de requisição
	$xmlBuscaAssociao  = '';
	$xmlBuscaAssociao .= '<Root>';
	$xmlBuscaAssociao .= '	<Cabecalho>';
	$xmlBuscaAssociao .= '		<Bo>b1wgen0146.p</Bo>';
	$xmlBuscaAssociao .= '		<Proc>busca_associado</Proc>';
	$xmlBuscaAssociao .= '	</Cabecalho>';
	$xmlBuscaAssociao .= '	<Dados>';
	$xmlBuscaAssociao .= '      <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xmlBuscaAssociao .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xmlBuscaAssociao .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xmlBuscaAssociao .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xmlBuscaAssociao .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xmlBuscaAssociao .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xmlBuscaAssociao .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xmlBuscaAssociao .= '		<cddopcao>'.$glbvars['cddopcao'].'</cddopcao>';	
	$xmlBuscaAssociao .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xmlBuscaAssociao .= '	</Dados>';
	$xmlBuscaAssociao .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResultBuscaAssociado = getDataXML($xmlBuscaAssociao);
	$xmlObjetoBuscaAssociado = getObjectXML($xmlResultBuscaAssociado);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjetoBuscaAssociado->roottag->tags[0]->name) == 'ERRO') {	
		
		$msgErro  = $xmlObjetoBuscaAssociado->roottag->tags[0]->tags[0]->tags[4]->cdata;								
		$nmdcampo = $xmlObjetoBuscaAssociado->roottag->tags[0]->attributes["NMDCAMPO"];	
				
		if(empty ($nmdcampo)){ 
			$nmdcampo = "nrdconta";
		}
		
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'input\',\'#divTela\').removeClass(\'campoErro\');unblockBackground(); focaCampoErro(\'#'.$nmdcampo.'\',\'divTela\');',false);		
		
	} 

	$nmprimtl = $xmlObjetoBuscaAssociado->roottag->tags[0]->attributes['NMPRIMTL'];
		
	
	// Monta o xml para buscar os estouros da conta
	$xmlBuscaEstouro  = '';
	$xmlBuscaEstouro .= '<Root>';
	$xmlBuscaEstouro .= '	<Cabecalho>';
	$xmlBuscaEstouro .= '		<Bo>b1wgen0146.p</Bo>';
	$xmlBuscaEstouro .= '		<Proc>busca_estouro</Proc>';
	$xmlBuscaEstouro .= '	</Cabecalho>';
	$xmlBuscaEstouro .= '	<Dados>';
	$xmlBuscaEstouro .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xmlBuscaEstouro .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xmlBuscaEstouro .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xmlBuscaEstouro .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xmlBuscaEstouro .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xmlBuscaEstouro .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xmlBuscaEstouro .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xmlBuscaEstouro .= '		<cddopcao>'.$cddopcao.'</cddopcao>';	
	$xmlBuscaEstouro .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xmlBuscaEstouro .= '	</Dados>';
	$xmlBuscaEstouro .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResultBuscaEstouro = getDataXML($xmlBuscaEstouro);
	$xmlObjetoBuscaEstouro = getObjectXML($xmlResultBuscaEstouro);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjetoBuscaEstouro->roottag->tags[0]->name) == 'ERRO') {	
				
		$msgErro  = $xmlObjetoBuscaEstouro->roottag->tags[0]->tags[0]->tags[4]->cdata;								
		$nmdcampo = $xmlObjetoBuscaEstouro->roottag->tags[0]->attributes["NMDCAMPO"];	
				
		if(empty ($nmdcampo)){ 
			$nmdcampo = "nrdconta";
		}
		
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'input\',\'#divTela\').removeClass(\'campoErro\');unblockBackground(); focaCampoErro(\'#'.$nmdcampo.'\',\'divTela\');',false);		
				
	} 

	$registros = $xmlObjetoBuscaEstouro->roottag->tags[0]->tags;

	include('tab_notjus.php');
	
?>

<script type="text/javascript">

	formataTabela();
	$('#nmprimtl','#frmCab').val('<? echo $nmprimtl ?>');
	$('#divDetalhes').css('display','block');
	$('div','#divDetalhes').css('display','block');
	$('#btVoltar','#divBotoes').focus();
		
</script>