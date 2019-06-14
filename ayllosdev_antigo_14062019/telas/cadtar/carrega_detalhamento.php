<? 
/*!
 * FONTE        : carrega_detalhamento.php
 * CRIAÇÃO      : Tiago Machado Flor         
 * DATA CRIAÇÃO : 07/03/2013 
 * OBJETIVO     : Rotina para buscar grupo tela CADTAR
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

	echo '<fieldset style="clear: both; border: 1px solid rgb(119, 119, 119); margin: 3px 0px; padding: 10px 3px 5px;">';
	echo '  <legend style="font-size: 11px; color: rgb(119, 119, 119); margin-left: 5px; padding: 0px 2px;">'.utf8ToHtml('Detalhamentos').'</legend>';
	echo '	<div class="divRegistros">';
	echo '		<table>';
	echo '			<thead>';
	echo '				<tr>';	
	echo '					<th>'.utf8ToHtml('Faixa').'</th>';
	echo '					<th>'.utf8ToHtml('Valor Inicial').'</th>';
	echo '					<th>'.utf8ToHtml('Valor Final').'</th>';
	echo '					<th>'.utf8ToHtml('Hist&oacute;rico lan&ccedil;amento').'</th>';
	echo '					<th>'.utf8ToHtml('Hist&oacute;rico estorno').'</th>';
	echo '				</tr>';
	echo '			</thead>';
	echo '			<tbody>';	
	
	
	foreach( $faixavalores as $r ) { 	
		echo "<tr>";
		echo	"<td id='cdfaixav'><span>".getByTagName($r->tags,'cdfaixav')."</span>";
		echo                 getByTagName($r->tags,'cdfaixav');
		echo    "</td>";
		echo	"<td id='vlinifvl'><span>".converteFloat(getByTagName($r->tags,'vlinifvl'),'MOEDA')."</span>";
		echo                 formataMoeda(getByTagName($r->tags,'vlinifvl')); 
		echo	"</td>";
		echo	"<td id='vlfinfvl'><span>".converteFloat(getByTagName($r->tags,'vlfinfvl'),'MOEDA')."</span>";
        echo                 formataMoeda(getByTagName($r->tags,'vlfinfvl'));
		echo	"</td>";
		echo	"<td id='cdhistor'><span>".getByTagName($r->tags,'cdhistor')."</span>";
		echo                 getByTagName($r->tags,'dshistor'); 
		echo		'<input type="hidden" id="tabdshistor" name="tabdshistor" value="' .getByTagName($r->tags,'dshistor'). '">'; 	
		echo    "</td>";
		echo	"<td id='cdhisest'><span>".getByTagName($r->tags,'cdhisest')."</span>";
		echo                 getByTagName($r->tags,'dshisest');
		echo		'<input type="hidden" id="tabdshisest" name="tabdshisest" value="' .getByTagName($r->tags,'dshisest'). '">'; 	
		echo    "</td>";
		echo "</tr>";
	} 	
			
	echo '			</tbody>';
	echo '		</table>';
	echo '	</div>';
	echo '</fieldset>';

	echo '<div id="divBotoesDetalha" style="margin-top:5px; margin-bottom :10px; text-align:center;">';
	if ( $glbvars['cdcooper'] == 3) {
		echo '	<a href="#" class="botao" id="btIncluir" onClick="mostraDetalhamentoTarifa(\'I\'); return false;">&nbsp;Incluir&nbsp;</a>';
		echo '	<a href="#" class="botao" id="btAlterar" onClick="mostraDetalhamentoTarifa(\'A\'); return false;">&nbsp;Alterar&nbsp;</a>';
		echo '	<a href="#" class="botao" id="btExcluir" onClick="excluirDetalhamento(); return false;">&nbsp;Excluir&nbsp;</a>';
		
		if ($cddopcao == 'C') {
			echo '	<a href="#" class="botao" id="btConsultar" onClick="mostraDetalhamentoTarifa(\'X\');">Consultar</a>';
		}
	} else {
		echo '	<a href="#" class="botao" id="btConsultar" onClick="mostraDetalhamentoTarifa(\'X\');">Consultar</a>';
	}
	echo '</div>';	

?>
