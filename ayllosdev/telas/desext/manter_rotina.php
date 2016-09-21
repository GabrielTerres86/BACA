<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 28/07/2011 
 * OBJETIVO     : Rotina para manter as operações da tela DESEXT
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
	
	// Recebe a operação que está sendo realizada
	$operacao		= (isset($_POST['operacao'])) ? $_POST['operacao'] : 0  ; 
	$nrdconta		= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ; 
	$idseqttl		=  0; 
	$cdsecext		= (isset($_POST['cdsecext'])) ? $_POST['cdsecext'] : 0  ; 
	$tpextcta		= (isset($_POST['tpextcta'])) ? $_POST['tpextcta'] : 0  ; 
	$tpavsdeb		= (isset($_POST['tpavsdeb'])) ? $_POST['tpavsdeb'] : 0  ; 
	$nmprimtl		= (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : '' ; 

	// Dependendo da operação, chamo uma procedure diferente
	switch($operacao) {
		case 'V': $procedure = 'Valida_Desext'; 						 				break;
		case 'G': $procedure = 'Grava_Desext'; 	$retornoAposErro= 'estadoInicial();';	break;
		default:  $retornoAposErro   = 'estadoInicial();'; return false; break;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0103.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<cdsecext>'.$cdsecext.'</cdsecext>';
	$xml .= '		<tpextcta>'.$tpextcta.'</tpextcta>';
	$xml .= '		<tpavsdeb>'.$tpavsdeb.'</tpavsdeb>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		if (!empty($nmdcampo)) { $retornoAposErro = $retornoAposErro . " focaCampoErro('".$nmdcampo."','frmCab');"; }
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Retorno
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( $operacao == 'V' ) {
		echo "manterRotina('G');";
	} else if ( $operacao == 'G' ) {

		preencheArray();
	
		$msgAtCad = $xmlObjeto->roottag->tags[0]->attributes['MSGATCAD'];
		$chaveAlt = $xmlObjeto->roottag->tags[0]->attributes['CHAVEALT'];
		$tpAtlCad = $xmlObjeto->roottag->tags[0]->attributes['TPATLCAD'];
		
		if ( !empty($msgAtCad) ) {
			exibirConfirmacao($msgAtCad,'Confirmação - Ayllos','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0103.p\', \'\', \'montarTabela();\')','montarTabela();',false);
		} else {	
			echo "montarTabela();";
		}
	}

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Preenche o array
	//----------------------------------------------------------------------------------------------------------------------------------
	function preencheArray() {

		echo 'var aux = new Array();';
		echo 'var i = arrayDesext.length;';

		echo 'aux[\'nrdconta\'] = "<span>'.$GLOBALS['nrdconta'].'</span>'.formataContaDV($GLOBALS['nrdconta']).'";';
		echo 'aux[\'cdsecext\'] = "'.$GLOBALS['cdsecext'].'";';
		echo 'aux[\'tpextcta\'] = "'.$GLOBALS['tpextcta'].'";';
		echo 'aux[\'tpavsdeb\'] = "'.$GLOBALS['tpavsdeb'].'";';
		echo 'aux[\'nmprimtl\'] = "'.stringTabela($GLOBALS['nmprimtl'], 37, 'maiuscula').'";';

		// recebe
		echo 'arrayDesext[i] = aux;';
	
	}	
?>