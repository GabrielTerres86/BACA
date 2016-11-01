<? 
/*!
 * FONTE        : carrega_atribuicao_detalhamento.php
 * CRIAÇÃO      : Tiago Machado Flor         
 * DATA CRIAÇÃO : 07/03/2013 
 * OBJETIVO     : Rotina para efetuar a carga de atribuicao detalhamento na tela CADTAR
 * --------------
 * ALTERAÇÕES   : 02/08/2013 - Incluso coluna convenio (Daniel).
 *			      21/08/2013 - Incluso novo parametro cdtipcat (Daniel).		
 *
 *				  14/08/2015 - Inclusao da nova coluna "Operador" no Detalhamento de Tarifas
 * 							   Projeto 218 - Melhorias em Tarifas (Carlos Rafael Tanholi) 
 *
 *                26/11/2015 - Ajustado para buscar os convenios de folha de pagamento
 *                             (Andre Santos - SUPERO)
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
	$cdfaixav		= (isset($_POST['cdfaixav'])) ? $_POST['cdfaixav'] : 0  ; 	
	$flgtodos		= (isset($_POST['flgtodos'])) ? $_POST['flgtodos'] : 'FALSE'  ; 
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$cdtipcat		= (isset($_POST['cdtipcat'])) ? $_POST['cdtipcat'] : 0  ;

	// Dependendo da operação, chamo uma procedure diferente
	$procedure = 'carrega-atribuicao-detalhamento';
	
	$retornoAposErro = 'focaCampoErro(\'cdfaixav\', \'frmDetalhaTarifa\');';
	
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
	$xml .= '		<cdfaixav>'.$cdfaixav.'</cdfaixav>';
    $xml .= '		<cdtipcat>'.$cdtipcat.'</cdtipcat>';	
	$xml .= '		<flgtodos>'.$flgtodos.'</flgtodos>';	
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
	
	$atribdet = $xmlObjeto->roottag->tags[0]->tags; 
	
	echo '	<div class="divRegistros" style="height: 105px">';
	echo '		<table>';
	echo '			<thead>';
	echo '				<tr>';	
	echo '					<th>'.utf8ToHtml('Cooperativa').'</th>';
	echo '					<th>'.utf8ToHtml('Conv&ecirc;nio').'</th>';
	echo '					<th>'.utf8ToHtml('Linha de Credito').'</th>';
	echo '					<th>'.utf8ToHtml('Divulga&ccedil;ao').'</th>';
	echo '					<th>'.utf8ToHtml('Inicio Vigencia').'</th>';
	echo '					<th>'.utf8ToHtml('Valor').'</th>';
	echo '					<th>'.utf8ToHtml('Custo').'</th>';
	echo '					<th>'.utf8ToHtml('Operador').'</th>';
	echo '				</tr>';
	echo '			</thead>';
	echo '			<tbody>';	
	

	foreach( $atribdet as $r ) { 	
		echo '<tr>';
		echo	"<td id='cdcooper'><span>".getByTagName($r->tags,'cdcooper')."</span>";
		echo                 getByTagName($r->tags,'nmrescop');
		echo		'<input type="hidden" id="tabnmrescop" name="tabnmrescop" value=' .getByTagName($r->tags,'nmrescop'). '>'; 	
		echo		'<input type="hidden" id="tabcdfvlcop" name="tabcdfvlcop" value=' .getByTagName($r->tags,'cdfvlcop'). '>'; 
		echo    '</td>';
		echo	"<td id='nrconven'>";
		echo                 getByTagName($r->tags,'nrconven');
		echo		'<input type="hidden" id="tabdsconven" name="tabdsconven" value="' .getByTagName($r->tags,'dsconven'). '">'; 
		echo		'<input type="hidden" id="tabnrconven" name="tabnrconven" value=' .getByTagName($r->tags,'nrconven'). '>'; 	
		echo	'</td>';
		echo	"<td id='cdlcremp'>";
		echo                 getByTagName($r->tags,'cdlcremp');
		echo		'<input type="hidden" id="tabdslcremp" name="tabdslcremp" value=' .getByTagName($r->tags,'dslcremp'). '>'; 
		echo		'<input type="hidden" id="tabcdlcremp" name="tabcdlcremp" value=' .getByTagName($r->tags,'cdlcremp'). '>'; 	
		echo	'</td>';
		echo	"<td id='dtdivulg'><span>".getByTagName($r->tags,'dtdivulg')."</span>";
		echo                 getByTagName($r->tags,'dtdivulg'); 
		echo	'</td>';
		echo	"<td id='dtvigenc'><span>".getByTagName($r->tags,'dtvigenc')."</span>";
        echo                 getByTagName($r->tags,'dtvigenc');
		echo	'</td>';
		echo	"<td id='vltarifa'><span>".converteFloat(getByTagName($r->tags,'vltarifa'),'MOEDA')."</span>";
        echo                 formataMoeda(getByTagName($r->tags,'vltarifa'));
		echo	'</td>';
		echo	"<td id='vlrepass'><span>".converteFloat(getByTagName($r->tags,'vlrepass'),'MOEDA')."</span>";
        echo                 formataMoeda(getByTagName($r->tags,'vlrepass'));
		echo	'</td>';		
		echo	'</td>';
		echo	"<td id='nmoperad'>";
        echo                 getByTagName($r->tags,'nmoperad');
		echo	'</td>';		
		echo '</tr>';
	} 	
			
	echo '			</tbody>';
	echo '		</table>';
	echo '	</div>';

	echo '<div id="divBotoesDetalhaTarifa" style="text-align:center; display:block">';
	echo '<br style="clear:both" />';
	echo 	'<a href="#" class="botao" id="btIncluir"   onclick="mostraAtribuicaoDetalhamento(\'I\'); return false;" style="margin-left:115px">Incluir</a>';
	echo 	'<a href="#" class="botao" id="btAlterar"   onClick="mostraAtribuicaoDetalhamento(\'A\'); return false;">Alterar</a>';
	echo 	'<a href="#" class="botao" id="btExcluir"   onClick="excluirDetAtribuicao()">Excluir</a>';
	if ( $glbvars['cdcooper'] == 3) {
		echo 	'<a href="#" class="botao" id="btReplicar"  onClick="mostraAtribuicaoDetalhamento(\'R\'); return false;">Replicar</a>';		
	}
	echo 	'<label class="txtNormalBold" style="margin-left:20px;margin-right:3px;" for="flgtodos">Lista Todos?:</label>';
	echo 	'<input type="checkbox" id="flgtodos" name="flgtodos" value="<? echo $flgtodos <> \'TRUE\' ? \'FALSE\' : \'TRUE\' ?>" />';	
	echo '<br style="clear:both" />';
	echo '</div>';	

?>
