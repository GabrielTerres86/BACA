<? 
/*!
 * FONTE        : replica_cooperativas.php
 * CRIAÇÃO      : Tiago Machado Flor         
 * DATA CRIAÇÃO : 07/03/2013 
 * OBJETIVO     : Rotina para replicacao cooperativas CADPAR
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
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$cdtarifa		= (isset($_POST['cdtarifa'])) ? $_POST['cdtarifa'] : 0  ; 	

	// Dependendo da operação, chamo uma procedure diferente
	$procedure = 'lista-fvl';
	
	$retornoAposErro = 'focaCampoErro(\'cdtarifa\', \'frmCab\');';
	
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
	$xml .= '		<cdtarifa>'.$cdtarifa.'</cdtarifa>';	
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
	
	$faixavalores = $xmlObjeto->roottag->tags[0]->tags; 


	foreach( $faixavalores as $r ) { 	
		echo "<tr>"
		echo	"<td><span>".getByTagName($r->tags,'cdfaixav')."</span>";
		echo                 getByTagName($r->tags,'cdfaixav');
		echo    "</td>";
		echo	"<td><span>".converteFloat(getByTagName($r->tags,'vlinifvl'),'MOEDA')."</span>";
		echo                 formataMoeda(getByTagName($r->tags,'vlinifvl')); 
		echo	"</td>";
		echo	"<td><span>".converteFloat(getByTagName($r->tags,'vlfinvl'),'MOEDA')."</span>";
        echo                 formataMoeda(getByTagName($r->tags,'vlfinvl'));
		echo	"</td>";
		echo	"<td><span>".getByTagName($r->tags,'cdhistor')."</span>";
		echo                 getByTagName($r->tags,'cdhistor'); 
		echo    "</td>";
		echo	"<td><span>".getByTagName($r->tags,'cdhisest')."</span>";
		echo                 getByTagName($r->tags,'cdhisest');
		echo    "</td>";
		echo "</tr>";
	} 	
			
?>
