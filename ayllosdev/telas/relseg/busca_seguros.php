<? 
/*!
 * FONTE        : busca_seguros.php
 * CRIAÇÃO      : David Kruger        
 * DATA CRIAÇÃO : 25/02/2013
 * OBJETIVO     : Rotina para busca dados de seguros para tela RELSEG.
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
	
	// Inicializa
	$retornoAposErro= '';
	
	
	// Recebe a operação que está sendo realizada
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	
	
	$retornoAposErro = 'focaCampoErro(\'cddopcao\', \'frmCab\');';
	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0045.p</Bo>';
	$xml .= '		<Proc>busca_dados_seg</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';		
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';		
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	$recid1 = $xmlObjeto->roottag->tags[0]->attributes["RECID1"];
	$recid2 = $xmlObjeto->roottag->tags[0]->attributes["RECID2"];	
	$recid3 = $xmlObjeto->roottag->tags[0]->attributes["RECID3"];	
	
	$vlrapoli = $xmlObjeto->roottag->tags[0]->attributes["VLRAPOLI"];	
  
  	$vlrdecom1 = $xmlObjeto->roottag->tags[0]->attributes["VLRDECOM1"];	
    $vlrdecom2 = $xmlObjeto->roottag->tags[0]->attributes["VLRDECOM2"];	
	$vlrdecom3 = $xmlObjeto->roottag->tags[0]->attributes["VLRDECOM3"];	

    $vlrdeiof1 = $xmlObjeto->roottag->tags[0]->attributes["VLRDEIOF1"];	
	$vlrdeiof2 = $xmlObjeto->roottag->tags[0]->attributes["VLRDEIOF2"];	
	$vlrdeiof3 = $xmlObjeto->roottag->tags[0]->attributes["VLRDEIOF3"];	
 
	include("form_seguros.php");
	
?>

<script type="text/javascript">
	
	$('#recid1   ','#frmSeg').val('<? echo $recid1 ?>');
	$('#recid2   ','#frmSeg').val('<? echo $recid2 ?>');
	$('#recid3   ','#frmSeg').val('<? echo $recid3 ?>');
	$('#vlrapoli','#frmSeg').val('<? echo  $vlrapoli ?>');
	$('#vlrdecom1','#frmSeg').val('<? echo $vlrdecom1 ?>');
	$('#vlrdecom2','#frmSeg').val('<? echo $vlrdecom2 ?>');
	$('#vlrdecom3','#frmSeg').val('<? echo $vlrdecom3 ?>');
	$('#vlrdeiof1','#frmSeg').val('<? echo $vlrdeiof1 ?>');
	$('#vlrdeiof2','#frmSeg').val('<? echo $vlrdeiof2 ?>');
	$('#vlrdeiof3','#frmSeg').val('<? echo $vlrdeiof3 ?>');		
	
	formataSeguros();
	$('#frmSeg').css('display','block');
	
	trocaBotao();
	$('#divBotoes', '#divTela').css({'display':'block'});
	$('#btSalvar', '#divTela').css({'display':'none'});
	
	if ('<? echo $cddopcao; ?>' == 'A'){
	    
		controlaCampos('A');
	 
	}
	
</script>