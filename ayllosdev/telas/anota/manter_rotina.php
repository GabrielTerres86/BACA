<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 17/02/2011 
 * OBJETIVO     : Rotina para manter (validar e alterar) as operações da tela ANOTA
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
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ; 
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;	
	$nrseqdig = (isset($_POST['nrseqdig'])) ? $_POST['nrseqdig'] : '' ; 
	$dsobserv = (isset($_POST['dsobserv'])) ? $_POST['dsobserv'] : '' ;
	$flgprior = (isset($_POST['flgprior'])) ? $_POST['flgprior'] : '' ;		
	
			
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = '';
	switch($operacao) {
		case 'AV': $procedure = 'valida_dados'; $cddopcao = 'A'; $mtdErro = 'unblockBackground();'; break;
		case 'VA': $procedure = 'grava_dados' ; $cddopcao = 'A'; $mtdErro = 'controlaOperacao(\'FA\');'; break;
		case 'IV': $procedure = 'valida_dados'; $cddopcao = 'I'; $mtdErro = 'unblockBackground();'; break;
		case 'VI': $procedure = 'grava_dados' ; $cddopcao = 'I'; $mtdErro = 'unblockBackground();'; break;
		case 'EV': $procedure = 'valida_dados'; $cddopcao = 'E'; $mtdErro = 'unblockBackground();'; break;
		case 'VE': $procedure = 'grava_dados' ; $cddopcao = 'E'; $mtdErro = 'unblockBackground();'; break;
		default:   $mtdErro   = 'controlaOperacao(\'\');'; return false;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Anota','',false);
	}
		
	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0085.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '       <nrdconta>'.$nrdconta.'</nrdconta>';    	
	$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';    	
	$xml .= '		<nrseqdig>'.$nrseqdig.'</nrseqdig>';    
	$xml .= '       <dsobserv>'.$dsobserv.'</dsobserv>';    
	$xml .= '       <flgprior>'.$flgprior.'</flgprior>';
	$xml .= '	</Dados>';                                  
	$xml .= '</Root>';                                      
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
	
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
				
		exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);
	}	
		
	$msg 		= Array();
	$msgRetorno = $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'];	
	$msgAlertas = $xmlObjeto->roottag->tags[1]->tags;

	// exibirErro('error','nrdconta= '.$nrdconta.' |operacao= '.$operacao.' |nrseqdig= '.$nrseqdig.' |dsobserv= '.$dsobserv.' |flgprior= '.$flgprior,'Alerta - Ayllos','',false);
		
	$msgAlertArray = Array();
	foreach( $msgAlertas as $alerta){
		$msgAlertArray[getByTagName($alerta->tags,'cdalerta')] = getByTagName($alerta->tags,'dsalerta');
	}
	
	$msgAlerta = implode( "|", $msgAlertArray);	
	
	if ($msgRetorno!='') $msg[] = $msgRetorno;
	if ($msgAlerta!='' ) $msg[] = $msgAlerta;
	
	$stringArrayMsg = implode( "|", $msg);	
	
	
	//----------------------------------------------------------------------------------------------------------------------------------
	// Controle verificação da revisão Cadastral
	//----------------------------------------------------------------------------------------------------------------------------------
	
	$msgAtCad = $xmlObjeto->roottag->tags[0]->attributes['MSGATCAD'];
	$msgRecad = $xmlObjeto->roottag->tags[0]->attributes['MSGRECAD'];
	
	$chaveAlt = $xmlObjeto->roottag->tags[0]->attributes['CHAVEALT'];
	$tpAtlCad = $xmlObjeto->roottag->tags[0]->attributes['TPATLCAD'];

	// Se é Validação
	if( in_array($operacao,array('AV','IV','EV')) ) {
		if( $operacao == 'AV' ) exibirConfirmacao($msgRetorno,'Confirmação - Ayllos','controlaOperacao(\'VA\')','unblockBackground();',false);		
		if( $operacao == 'IV' ) exibirConfirmacao($msgRetorno,'Confirmação - Ayllos','controlaOperacao(\'VI\')','unblockBackground();',false);		
		if( $operacao == 'EV' ) exibirConfirmacao($msgRetorno,'Confirmação - Ayllos','controlaOperacao(\'VE\')','unblockBackground();',false);
	
	// Se é Inclusão/Alteração/Exclusão
	} else {		
		
		// Verificar se existe "Verificação de Revisão Cadastral"
		if($msgAtCad!='') {					
			if( $operacao == 'VA' ) exibirConfirmacao($msgAtCad,'Confirmação - Ayllos','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0085.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FA\")\')',false);
			if( $operacao == 'VI' ) exibirConfirmacao($msgAtCad,'Confirmação - Ayllos','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0085.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FI\")\')',false);
			if( $operacao == 'VE' ) exibirConfirmacao($msgAtCad,'Confirmação - Ayllos','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0085.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FE\")\')',false);
		
		// Se não existe necessidade de Revisão Cadastral
		} else {				
			if($operacao=='VI') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FI\")\');';
		    if($operacao=='VA') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FA\")\');';
		    if($operacao=='VE') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FE\")\');';
			
		}
	}
			
	// Validações em PHP
	function validaDados(){
		
		$nomeForm = ( $GLOBALS['inpessoa'] == 1 ) ? 'frmFisico' : 'frmJuridico';
		
		echo '$("input,select","#'.$nomeForm.'").removeClass("campoErro");';
		
		//Nome do titular
		if ( $GLOBALS['nmprimtl'] == ''  ) {
			$msgErro = ( $GLOBALS['inpessoa'] == 1 ) ? 'Nome deve ser preenchido.' : 'Rasão social deve se preenchida.' ;
			exibirErro('error',$msgErro,'Alerta - Ayllos','focaCampoErro(\'nmprimtl\',\''.$nomeForm.'\');',false);
		}	
				
	}	
		
?>