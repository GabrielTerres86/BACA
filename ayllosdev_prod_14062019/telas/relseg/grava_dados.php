<? 
/*!
 * FONTE        : grava_dados.php
 * CRIAÇÃO      : David Kruger        
 * DATA CRIAÇÃO : 26/02/2013
 * OBJETIVO     : Rotina para gravação dos valores de parâmetros dos seguros da tela RELSEG
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
	$retornoAposErro = '';
	
	
	// Recebe a operação que está sendo realizada
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$vlrdecom1		= (isset($_POST['vlrdecom1'])) ? $_POST['vlrdecom1'] : 0  ; 	
	$vlrdecom2		= (isset($_POST['vlrdecom2'])) ? $_POST['vlrdecom2'] : 0  ; 	
	$vlrdecom3      = (isset($_POST['vlrdecom3'])) ? $_POST['vlrdecom3'] : 0  ;
	$vlrdeiof1      = (isset($_POST['vlrdeiof1'])) ? $_POST['vlrdeiof1'] :''  ;
	$vlrdeiof2      = (isset($_POST['vlrdeiof2'])) ? $_POST['vlrdeiof2'] : 0  ;
	$vlrdeiof3      = (isset($_POST['vlrdeiof3'])) ? $_POST['vlrdeiof3'] : 0  ;
	$recid1     	= (isset($_POST['recid1'])) ? $_POST['recid1'] : 0  ;
	$recid2	        = (isset($_POST['recid2'])) ? $_POST['recid2'] : 0  ;
	$recid3         = (isset($_POST['recid3'])) ? $_POST['recid3'] : 0  ;
	$vlrapoli       = (isset($_POST['vlrapoli'])) ? $_POST['vlrapoli'] : 0  ;
	
    
	if($cddopcao == 'A'){ 
	    validaDados();
	}
	
	$retornoAposErro = 'focaCampoErro(\'vlrdecom1\', \'frmSeg\');';
	
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0045.p</Bo>';
	$xml .= '		<Proc>proc_grava_dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<vlrdecom1>'.$vlrdecom1.'</vlrdecom1>';
	$xml .= '		<vlrdecom2>'.$vlrdecom2.'</vlrdecom2>';
	$xml .= '		<vlrdecom3>'.$vlrdecom3.'</vlrdecom3>';
	$xml .= '		<vlrdeiof1>'.$vlrdeiof1.'</vlrdeiof1>';
	$xml .= '		<vlrdeiof2>'.$vlrdeiof2.'</vlrdeiof2>';
	$xml .= '		<vlrdeiof3>'.$vlrdeiof3.'</vlrdeiof3>';
	$xml .= '		<recid1>'.$recid1.'</recid1>';
	$xml .= '		<recid2>'.$recid2.'</recid2>';
	$xml .= '		<recid3>'.$recid3.'</recid3>';
	$xml .= '		<vlrapoli>'.$vlrapoli.'</vlrapoli>';
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
	
	echo "hideMsgAguardo();";
	echo "estadoInicial();";
	
	function validaDados() {
	
		echo '$("input,select","#frmSeg").removeClass("campoErro");';			

		// Número da agencia.
		if ( (!validaDecimal($GLOBALS['vlrdecom1'])) || ($GLOBALS['vlrdecom1'] == '' ) ) exibirErro('error','Aten&#231;&#227;o! O campo deve ser preenchido.','Alerta - Ayllos','bloqueiaFundo($(\'#divTela\'),\'vlrdecom1\',\'frmSeg\');',false);
		if ( (!validaDecimal($GLOBALS['vlrdecom2'])) || ($GLOBALS['vlrdecom2'] == '' ) ) exibirErro('error','Aten&#231;&#227;o! O campo deve ser preenchido.','Alerta - Ayllos','bloqueiaFundo($(\'#divTela\'),\'vlrdecom2\',\'frmSeg\');',false);
		if ( (!validaDecimal($GLOBALS['vlrdecom3'])) || ($GLOBALS['vlrdecom3'] == '' ) ) exibirErro('error','Aten&#231;&#227;o! O campo deve ser preenchido.','Alerta - Ayllos','bloqueiaFundo($(\'#divTela\'),\'vlrdecom3\',\'frmSeg\');',false);
		
		if ( (!validaDecimal($GLOBALS['vlrdeiof1'])) || ($GLOBALS['vlrdeiof1'] == '' ) ) exibirErro('error','Aten&#231;&#227;o! O campo deve ser preenchido.','Alerta - Ayllos','bloqueiaFundo($(\'#divTela\'),\'vlrdeiof1\',\'frmSeg\');',false);
		if ( (!validaDecimal($GLOBALS['vlrdeiof2'])) || ($GLOBALS['vlrdeiof2'] == '' ) ) exibirErro('error','Aten&#231;&#227;o! O campo deve ser preenchido.','Alerta - Ayllos','bloqueiaFundo($(\'#divTela\'),\'vlrdeiof2\',\'frmSeg\');',false);
		if ( (!validaDecimal($GLOBALS['vlrdeiof3'])) || ($GLOBALS['vlrdeiof3'] == '' ) ) exibirErro('error','Aten&#231;&#227;o! O campo deve ser preenchido.','Alerta - Ayllos','bloqueiaFundo($(\'#divTela\'),\'vlrdeiof3\',\'frmSeg\');',false);
		
		if ( (!validaDecimal($GLOBALS['vlrapoli'])) || ($GLOBALS['vlrapoli'] == '' ) ) exibirErro('error','Aten&#231;&#227;o! O campo deve ser preenchido.','Alerta - Ayllos','bloqueiaFundo($(\'#divTela\'),\'vlrapoli\',\'frmSeg\');',false);
		
		
	}
	
	
?>