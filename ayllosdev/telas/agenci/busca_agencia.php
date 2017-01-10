<? 
/*!
 * FONTE        : busca_agencia.php
 * CRIAÇÃO      : David Kruger        
 * DATA CRIAÇÃO : 06/02/2013
 * OBJETIVO     : Rotina para busca de agencias da tela AGENCI
 * --------------
 * ALTERAÇÕES   : 08/01/2014 - Ajustes para homologação (Adriano).
 *
 *                29/11/2016 - P341-Automatização BACENJUD - Alterado para que 
 *                             seja enviado o cddepart, ao invés do dsdepart para 
 *                             a rotina b1wgen0149. (Renato Darosci - Supero)
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
	
	// Recebe a operação que está sendo realizada
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$cdageban		= (isset($_POST['cdageban'])) ? $_POST['cdageban'] : 0  ; 	
	$cddbanco		= (isset($_POST['cddbanco'])) ? $_POST['cddbanco'] : 0  ; 	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0149.p</Bo>';
	$xml .= '		<Proc>busca-agencia</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<cddepart>'.$glbvars['cddepart'].'</cddepart>';
	$xml .= '		<cdageban>'.$cdageban.'</cdageban>';	
	$xml .= '		<cddbanco>'.$cddbanco.'</cddbanco>';			
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
    $xml .= '		<nrregist>99999</nrregist>';
	$xml .= '		<nriniseq>1</nriniseq>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo = $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		
		if ( !empty($nmdcampo) ) { $mtdErro = "$('input','#frmAgencia').removeClass('campoErro');focaCampoErro('".$nmdcampo."','frmAgencia');";  }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);
		
	}
		
	$agencia = $xmlObjeto->roottag->tags[0]->tags[0];
	$feriados = $xmlObjeto->roottag->tags[1]->tags;	
	
	include('form_agencia.php');
	
		
	?>
	<script type="text/javascript">
		
		formataAgencia();
		
		if('<?echo $cddopcao;?>' == "I"){
			$('#cdageban','#frmAgencia').val('<?echo $cdageban; ?>');
		}else{
			$('#cdageban','#frmAgencia').val('<?echo getByTagName($agencia->tags,'cdageban'); ?>');
		}
		
		$('#dgagenci','#frmAgencia').val('<?echo getByTagName($agencia->tags,'dgagenci'); ?>');
		$('#nmageban','#frmAgencia').val('<?echo getByTagName($agencia->tags,'nmageban'); ?>');
		$('#cdsitagb','#frmAgencia').val('<?echo getByTagName($agencia->tags,'cdsitagb'); ?>');
		$('#cdcompen','#frmAgencia').val('<?echo getByTagName($agencia->tags,'cdcompen'); ?>');
		$('#nmcidade','#frmAgencia').val('<?echo getByTagName($agencia->tags,'nmcidade'); ?>');
		$('#cdufresd','#frmAgencia').val('<?echo getByTagName($agencia->tags,'cdufresd'); ?>');

		controlaCampos($('#cddopcao', '#frmCab').val());
		$('#frmAgencia').css('display','block');
		$('#dgagenci','#frmAgencia').focus();
		
	</script>
	
	<?
	if (count($feriados) > 0){

		include('tab_feriados.php');?>

		<script type="text/javascript">
			formataTabela();
	   </script> 
	   
	<?}	
	
?>


