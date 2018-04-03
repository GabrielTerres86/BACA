<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Lucas Lunelli         
 * DATA CRIAÇÃO : 17/01/2013 
 * OBJETIVO     : Rotina para manter as operações da tela BLQRGT
 * --------------
 * ALTERAÇÕES   : 28/10/2014 - Inclusão do parametro idtipapl (Jean Michel).
 *				  16/11/2017 - Tela remodelada para o projeto 404 (Lombardi).
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
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$nrdconta		= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ; 
	$tpaplica		= (isset($_POST['tpaplica'])) ? $_POST['tpaplica'] : 0  ; 
	$nraplica		= (isset($_POST['nraplica'])) ? $_POST['nraplica'] : 0  ; 
	$idtipapl		= (isset($_POST['idtipapl'])) ? $_POST['idtipapl'] : 'A'; 
	$nmprodut		= (isset($_POST['nmprodut'])) ? $_POST['nmprodut'] : '-'; 
	
	// Dependendo da operação, chamo uma procedure diferente
	switch($cddopcao) {
		case 'C': $procedure = 'busca-blqrgt';	  break;
		case 'B': $procedure = 'bloqueia-blqrgt'; break;
		case 'L': $procedure = 'libera-blqrgt';   break;
		case 'V': $procedure = 'valida-conta';    break;
	}
	
	if ($cddopcao == "V")
		$retornoAposErro = 'focaCampoErro(\'nrdconta\', \'frmCab\');';
	else{
		if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
			exibirErro('error',$msgError,'Alerta - Ayllos','',false);
		}
		
		$retornoAposErro = 'focaCampoErro(\'nraplica\', \'frmCab\');';
	}		

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0148.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<tpaplica>'.$tpaplica.'</tpaplica>';
	$xml .= '		<nraplica>'.$nraplica.'</nraplica>';
	$xml .= '		<idtipapl>'.$idtipapl.'</idtipapl>';
	$xml .= '		<nmprodut>'.$nmprodut.'</nmprodut>';
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
	
	$flgstapl = $xmlObjeto->roottag->tags[0]->attributes["FLGSTAPL"];
	$dsdconta = $xmlObjeto->roottag->tags[0]->attributes["DSDCONTA"];
	
	if ($cddopcao == "C"){
		if ($flgstapl == "yes"){
			$msgalert = "Aplica&ccedil;&atilde;o Liberada.";
		} else {
			$msgalert = "Aplica&ccedil;&atilde;o Bloqueada.";
		}
		
		echo 'showError("inform","'.$msgalert.'","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}
	
	if ($cddopcao == "B"){
		echo 'showError("inform","Aplica&ccedil;&atilde;o Bloqueada com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));estadoInicial();");';		
	}
	
	if ($cddopcao == "L"){
		echo 'showError("inform","Aplica&ccedil;&atilde;o Liberada com sucesso.","Notifica&ccedil;&atilde;o - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));btnContinuar();");';		
	}
	
	if ($cddopcao == "V"){
		echo "$('#nmprimtl','#frmCab').val('$dsdconta');";
		echo "$('input,select', '#frmCab').removeClass('campoErro');";
		echo "LiberaCampos();";
		echo "hideMsgAguardo();";
	}
			
?>
