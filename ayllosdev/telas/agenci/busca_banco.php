<? 
/*!
 * FONTE        : busca_banco.php
 * CRIAÇÃO      : David Kruger        
 * DATA CRIAÇÃO : 04/02/2013
 * OBJETIVO     : Rotina para busca de bancos da tela AGENCI
 * --------------
 * ALTERAÇÕES   : 08/01/2014 - Ajustes para homolgação (Adriano).
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
	$cddbanco		= (isset($_POST['cddbanco'])) ? $_POST['cddbanco'] : 0  ; 	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0149.p</Bo>';
	$xml .= '		<Proc>busca-banco</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<cddepart>'.$glbvars['cddepart'].'</cddepart>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';	
	$xml .= '		<cddbanco>'.$cddbanco.'</cddbanco>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
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
		
		if ( !empty($nmdcampo) ) { $mtdErro = "$('input','#frmCab').removeClass('campoErro');focaCampoErro('".$nmdcampo."','frmCab');";  }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);
		
	}
	
	$banco = $xmlObjeto->roottag->tags[0]->tags;
	
	include("form_agencia.php");
	
?>

<script type="text/javascript">
	
	$('#cddbanco','#frmCab').val('<? echo $banco[0]->tags[0]->cdata; ?>');
	$('#nmextbcc','#frmCab').val('<? echo $banco[0]->tags[1]->cdata; ?>');
	
	formataAgencia();
	
	trocaBotao('btnAvancar()','btnVoltar(\'V1\')');
	$('#frmAgencia').css('display','block');
	$('#cdageban','#frmAgencia').habilitaCampo().focus();
	    	
</script>