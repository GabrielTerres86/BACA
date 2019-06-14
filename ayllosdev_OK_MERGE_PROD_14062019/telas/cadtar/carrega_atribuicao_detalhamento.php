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
 *
 *				  11/07/2017 - Inclusao das novas colunas e campos "Tipo de tarifacao", "Percentual", "Valor Minimo" e 
 *                             "Valor Maximo" (Mateus - MoutS)
 * 
 *                25/06/2018 - Ajuste na chamada da funcao carregaAtribuicaoDetalhamento, para funcionar corretamente a paginação.
 *                             (Alcemir - Mout's) - INC0017668.
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

	$flgtodos 	= TRUE;
	$nrregist	= (isset($_POST['nrregist'])) ? $_POST['nrregist'] : 250;
	$nriniseq	= (isset($_POST['nriniseq'])) ? $_POST['nriniseq'] : 1;

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
	$xml .= '       <nrregist>'.$nrregist.'</nrregist>';
	$xml .= '       <nriniseq>'.$nriniseq.'</nriniseq>';	
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
	echo '		<table id="tituloRegistros">';
	echo '			<thead>';
	echo '				<tr>';	
	echo '					<th>'.utf8ToHtml('Cooperativa').'</th>';
	echo '					<th>'.utf8ToHtml('Conv&ecirc;nio').'</th>';
	echo '					<th>'.utf8ToHtml('Linha de Credito').'</th>';
	echo '					<th>'.utf8ToHtml('Divulga&ccedil;ao').'</th>';
	echo '					<th>'.utf8ToHtml('Inicio Vigencia').'</th>';
	echo '					<th>'.utf8ToHtml('Valor').'</th>';
	echo '					<th style="display: none">'.utf8ToHtml('Tipo de Tarifa').'</th>';
	echo '					<th>'.utf8ToHtml('Perc').'</th>';
	echo '					<th>'.utf8ToHtml('Vl.Min').'</th>';
	echo '					<th>'.utf8ToHtml('Vl.Max').'</th>';
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
		echo	"<td id='tpcobtar' style='display: none'><span>".getByTagName($r->tags,'tpcobtar')."</span>";
		echo	'</td>';
		echo	"<td id='vlpertar'><span>".converteFloat(getByTagName($r->tags,'vlpertar'),'MOEDA')."</span>";
        echo                 formataMoeda(getByTagName($r->tags,'vlpertar'));
		echo	'</td>';
		echo	"<td id='vlmintar'><span>".converteFloat(getByTagName($r->tags,'vlmintar'),'MOEDA')."</span>";
        echo                 formataMoeda(getByTagName($r->tags,'vlmintar'));
		echo	'</td>';
		echo	"<td id='vlmaxtar'><span>".converteFloat(getByTagName($r->tags,'vlmaxtar'),'MOEDA')."</span>";
        echo                 formataMoeda(getByTagName($r->tags,'vlmaxtar'));
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

	echo '  <div id="divPesquisaRodape" class="divPesquisaRodape">';
	echo '     <table>';	
	echo '       <tr>';
	echo '          <td>';

	$qtregist = $xmlObjeto->roottag->tags[0]->attributes["QTREGIST"];

	if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
	// Se a paginação não está na primeira, exibe botão voltar
	if ($nriniseq > 1) { 
		echo '<a class=\'paginacaoAnt\'><<< Anterior</a>';
	}

	echo '          </td>';
	echo '          <td>';

	if (isset($nriniseq)) { 
		if (($nriniseq + $nrregist) > $qtregist) { 
			echo 'Exibindo ' . $nriniseq . ' at&eacute; ' .  $qtregist . ' de ' .  $qtregist . '';	
		} else {  
			echo 'Exibindo ' . $nriniseq . ' at&eacute; ' .  ($nriniseq + $nrregist - 1) . ' de ' .  $qtregist . '';	
		} 
	}

	echo '          </td>';
	echo '          <td>';

	// Se a paginação não está na &uacute;ltima página, exibe botão proximo
	if ($qtregist > ($nriniseq + $nrregist - 1)) {
		echo '<a class=\'paginacaoProx\'>Pr&oacute;ximo >>></a>';
	}

	echo '        </td>';
	echo '      </tr>';
	echo '    </table>';
	echo '  </div>';

	echo '<div id="divBotoesDetalhaTarifa" style="text-align:center; display:block">';
	echo '<br style="clear:both" />';
	echo 	'<a href="#" class="botao" id="btIncluir"   onclick="mostraAtribuicaoDetalhamento(\'I\'); return false;">Incluir</a>';
	echo 	'<a href="#" class="botao" id="btAlterar"   onClick="mostraAtribuicaoDetalhamento(\'A\'); return false;">Alterar</a>';
	echo 	'<a href="#" class="botao" id="btExcluir"   onClick="excluirDetAtribuicao()">Excluir</a>';
	if ( $glbvars['cdcooper'] == 3) {
		echo 	'<a href="#" class="botao" id="btReplicar"  onClick="mostraAtribuicaoDetalhamento(\'R\'); return false;">Replicar</a>';		
	}
	//echo 	'<label class="txtNormalBold" style="margin-left:20px;margin-right:3px;" for="flgtodos">Lista Todos?:</label>';
	//echo 	'<input type="checkbox" id="flgtodos" name="flgtodos" value="<? echo $flgtodos <> \'TRUE\' ? \'FALSE\' : \'TRUE\' " />';
	echo '<br style="clear:both" />';
	echo '</div>';	

?>

<script type="text/javascript">
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		carregaAtribuicaoDetalhamento(<? echo "'".($nriniseq - $nrregist)."'"; ?>, <? echo "'".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {

		carregaAtribuicaoDetalhamento(<? echo "'".($nriniseq + $nrregist)."'"; ?>, <? echo "'".$nrregist."'"; ?>);
	});	
	
	$('#divPesquisaRodape', '#divTabDetalhamento').formataRodapePesquisa();
</script>