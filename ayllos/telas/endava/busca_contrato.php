<? 
/*!
 * FONTE        : busca_contrato.php
 * CRIAÇÃO      : Jéssica (DB1)
 * DATA CRIAÇÃO : 30/10/2013
 * OBJETIVO     : Rotina para buscar contratos - ENDAVA
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 *
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
	$procedure 		= '';
	
	$tpctrato	= (isset($_POST['tpctrato'])) ? $_POST['tpctrato'] : 0;
	$pro_cpfcgc	= (isset($_POST['pro_cpfcgc'])) ? $_POST['pro_cpfcgc'] : 0;
	$nrregist	= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0;
	$nriniseq	= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0;	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'C')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
		
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0164.p</Bo>';
	$xml .= '		<Proc>busca_crapavt</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '       <tpctrato>'.$tpctrato.'</tpctrato>';
	$xml .= '       <pro_cpfcgc>'.$pro_cpfcgc.'</pro_cpfcgc>';
	$xml .= '       <idorigem>5</idorigem>';
	$xml .= '       <nrregist>'.$nrregist.'</nrregist>';
	$xml .= '       <nriniseq>'.$nriniseq.'</nriniseq>';
	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
			
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
		
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','cPro_cpfcgc.focus()',false);
	}
	
	$registros = $xmlObj->roottag->tags[0]->tags;
	
	
	// Quantidade total de contratos na pesquisa
	$qtregist = $xmlObj->roottag->tags[0]->attributes["QTREGIST"];
	include('tab_endava.php');
?>
<script>

	
	if(cCddopcao.val() == "A"){	
     	cdImgLupa.css({'display':'block'});
	   
		cPro_cpfcgc.desabilitaCampo();
		cNrfonres.focus();
		
	}

</script>