<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Daniel Zimmermann
 * DATA CRIAÇÃO : 26/04/2013
 * OBJETIVO     : Rotina para manter as operações da tela ESTTAR
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
	$procedure 		= '';
	$retornoAposErro= '';
	
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';	
	
	// Recebe a operação que está sendo realizada
	$nrdconta       = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0 ;	
	$cddopcap		= (isset($_POST['cddopcap'])) ? $_POST['cddopcap'] : 0  ;	
	$lscdlant		= (isset($_POST['strCdlantar'])) ? $_POST['strCdlantar'] : '' ;
	$lscdmote		= (isset($_POST['strCdmotest'])) ? $_POST['strCdmotest'] : ''  ; 
	
	// Procedure a ser executada
	$procedure = 'estorno-baixa-tarifa';
	
	$retornoAposErro = 'focaCampoErro(\'nrdconta\', \'frmCab\');';
	
	$cddopcao = 'A';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0153.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
    $xml .= '		<inproces>'.$glbvars['inproces'].'</inproces>';		
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<cddopcap>'.$cddopcap.'</cddopcap>';
	$xml .= '		<lscdlant>'.$lscdlant.'</lscdlant>';
	$xml .= '		<lscdmote>'.$lscdmote.'</lscdmote>';
	$xml .= '		<flgerlog>YES</flgerlog>';
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
	
	echo 'showError("inform","Estorno/Baixa/Suspens&atilde;o efetuados com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';
	
			
?>
