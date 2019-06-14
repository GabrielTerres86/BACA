<? 
/*!
 * FONTE        : busca_uf_pa_ass.php
 * CRIAÇÃO      : Guilherme / SUPERO
 * DATA CRIAÇÃO : 02/01/2014
 * OBJETIVO     : Buscar a UF do PA do Associado
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?> 

<?	
    session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();		

	// Recebe a operação que está sendo realizada
	$nrdconta		= (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ; 

	// Dependendo da operação, chamo uma procedure diferente
	$procedure       = 'retorna_UF_PA_ASS';	
	$retornoAposErro = 'estadoInicial();';
	
	//if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
//		exibirErro('error',$msgError,'Alerta - Aimaro','',false);
//	}

	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0002.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';		
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro',$retornoAposErro,false);
	}

	$uflicenc = $xmlObjeto->roottag->tags[0]->attributes["UFLICENC"];	

	echo "$('#uflicenc','#frmTipo').val('$uflicenc');";

?>
