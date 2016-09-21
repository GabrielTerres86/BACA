<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 24/08/2011 
 * OBJETIVO     : Rotina para manter as operações da tela EXTAPL
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
	$procedure 			= '';
	$retornoAposErro	= 'bloqueiaFundo( $(\'#divRotina\') );';
		
	// Recebe a operação que está sendo realizada
	$operacao			= (isset($_POST['operacao']))   ? $_POST['operacao']   : 0  ; 
	$cddopcao			= (isset($_POST['cddopcao']))   ? $_POST['cddopcao']   : 0  ; 
	$nrdconta			= (isset($_POST['nrdconta']))   ? $_POST['nrdconta']   : 0  ; 
	$idseqttl			= 1 ; 
	$descapli			= (isset($_POST['descapli']))   ? $_POST['descapli']   : '' ; 
	$tpaplica			= (isset($_POST['tpaplica']))   ? $_POST['tpaplica']   : '' ; 
	$nraplica			= (isset($_POST['nraplica']))   ? $_POST['nraplica']   : '' ; 
	$tpemiext			= (isset($_POST['tpemiext']))   ? $_POST['tpemiext']   : '' ; 

	switch($operacao) {
		case 'V': $procedure = 'Valida_Extapl';	break;
		case 'G': $procedure = 'Grava_Extapl'; 	break;
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
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
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<descapli>'.$descapli.'</descapli>';
	$xml .= '		<tpaplica>'.$tpaplica.'</tpaplica>';
	$xml .= '		<nraplica>'.$nraplica.'</nraplica>';
	$xml .= '		<tpemiext>'.$tpemiext.'</tpemiext>';
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

	$msgretor = $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'];
	
	if ( $operacao == 'V' ) {
		echo "manterRotina('G', '".$tpemiext."');";

	} else if ( !empty($msgretor) ) {
		exibirErro('inform',$msgretor,'Alerta - Ayllos','controlaOperacao();',false);

	} else {
	
		if ( $cddopcao == 'T' ) {
			echo "fechaRotina($('#divRotina'));";
		}
	
		echo "controlaOperacao();";

	}
?>