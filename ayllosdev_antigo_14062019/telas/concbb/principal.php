<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 19/08/2011 
 * OBJETIVO     : Rotina para manter as operações da tela CONCBB
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
	$procedure		= '';
	
	// Recebe a operação que está sendo realizada
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$dtmvtolx       = (isset($_POST['dtmvtolx'])) ? $_POST['dtmvtolx'] : '';
	$cdagencx       = (isset($_POST['cdagencx'])) ? $_POST['cdagencx'] : 0 ;
	$nrdcaixx       = (isset($_POST['nrdcaixx'])) ? $_POST['nrdcaixx'] : 0 ;
	$inss           = (isset($_POST['inss'])) 	  ? $_POST['inss'] 	   : '';
	$valorpag	    = (isset($_POST['valorpag'])) ? $_POST['valorpag'] : 0 ;
	$flggeren		= (isset($_POST['flggeren'])) ? $_POST['flggeren'] : '';
	$nrregist		= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 0 ; 
	$nriniseq		= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 0 ; 

	switch( $cddopcao ) {
		case 'T': $procedure = 'Busca_Movimento'; 	break;
		default : $procedure = 'Busca_Dados'; 		break;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0108.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<dtmvtolx>'.$dtmvtolx.'</dtmvtolx>';
	$xml .= '		<cdagencx>'.$cdagencx.'</cdagencx>';
	$xml .= '		<nrdcaixx>'.$nrdcaixx.'</nrdcaixx>';
	$xml .= '		<inss>'.$inss.'</inss>';
	$xml .= '		<valorpag>'.$valorpag.'</valorpag>';
	$xml .= '		<flggeren>'.$flggeren.'</flggeren>';
	$xml .= '		<nrregist>'.$nrregist.'</nrregist>';
	$xml .= '		<nriniseq>'.$nriniseq.'</nriniseq>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	$flag			= '';
	$concbb 		= $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	$movimento 		= $xmlObjeto->roottag->tags[1]->tags;
	$mensagem 		= $xmlObjeto->roottag->tags[1]->tags;
	$qtregist		= $xmlObjeto->roottag->tags[1]->attributes['QTREGIST'];
	
	include('form_cabecalho.php');
	
	if ( $cddopcao == 'C') {
		include("form_concbb.php");
		$qtdinhei	= getByTagName($concbb,'qtdinhei');
		$qtcheque	= getByTagName($concbb,'qtcheque');
		$qtinss		= getByTagName($concbb,'qtinss');
		$flag 		= ( $qtdinhei == '0' and $qtcheque == '0' and $qtinss == '0' ) ? 'N' : 'S';
		
	} else if ( $cddopcao == 'T' ) {
		$mrsgetor 	= $xmlObjeto->roottag->tags[0]->attributes['MRSGETOR'];
		$msgprint 	= $xmlObjeto->roottag->tags[0]->attributes['MSGPRINT'];
	
		include("form_concbb.php");
		include("mensagem.php");
	
		$flag 		= count($mensagem) > 0 ? 'S' : 'N';
		
	} else if ( $cddopcao == 'D' || $cddopcao == 'V' ) {
		include("tab_concbb.php");
	}

	include("btn_concbb.php");

?>

<script>
	var flag 	= '<? echo $flag ?>';
	msgprint 	= '<? echo $msgprint ?>';
	mrsgetor	= '<? echo $mrsgetor ?>';
	controlaLayout(flag);
</script>
