<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Tiago Machado Flor         
 * DATA CRIAÇÃO : 21/02/2013 
 * OBJETIVO     : Rotina para manter as operações da tela CADGRU
 * --------------
 * ALTERAÇÕES   : 21/09/2016 - Incluir tratamento para poder alterar a cooperativa cecred e 
 * --------------              escolher o programa "DEVOLUCAO DOC" - Melhoria 316 
 *                             (Lucas Ranghetti #525623)
 *  
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
	
	// Recebe a operação que está sendo realizada
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$cdcoopex		= (isset($_POST['cdcoopex'])) ? $_POST['cdcoopex'] : 0  ;
	$nmproces		= (isset($_POST['nmproces'])) ? $_POST['nmproces'] : 0  ;
	$flgativo		= (isset($_POST['flgativo'])) ? $_POST['flgativo'] : 'N';
	$ageinihr		= (isset($_POST['ageinihr'])) ? $_POST['ageinihr'] : 0  ;	
	$ageinimm		= (isset($_POST['ageinimm'])) ? $_POST['ageinimm'] : 0  ;
	$agefimhr		= (isset($_POST['agefimhr'])) ? $_POST['agefimhr'] : 0  ;
	$agefimmm		= (isset($_POST['agefimmm'])) ? $_POST['agefimmm'] : 0  ;

	// Dependendo da operação, chamo uma procedure diferente
	switch($cddopcao) {
		case 'A': $procedure = 'grava_dados';   break;
	}
	
	$retornoAposErro = 'focaCampoErro(\'cddgrupo\', \'frmCab\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0183.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<cdcoopex>'.$cdcoopex.'</cdcoopex>';
	$xml .= '		<nmproces>'.$nmproces.'</nmproces>';
	$xml .= '		<flgativo>'.$flgativo.'</flgativo>';	
	$xml .= '		<ageinihr>'.$ageinihr.'</ageinihr>';
	$xml .= '		<ageinimm>'.$ageinimm.'</ageinimm>';
	$xml .= '		<agefimhr>'.$agefimhr.'</agefimhr>';
	$xml .= '		<agefimmm>'.$agefimmm.'</agefimmm>';	
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
	
	if ($cddopcao == "A"){
		echo 'showError("inform","Processo alterado com sucesso.","Notifica&ccedil;&atilde;o - Ayllos"," carregaDetalhamento();unblockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));");';
	}
			
?>
