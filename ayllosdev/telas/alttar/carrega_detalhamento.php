<? 
/*!
 * FONTE        : carrega_detalhamento.php
 * CRIAÇÃO      : Jaison
 * DATA CRIAÇÃO : 03/09/2015
 * OBJETIVO     : Rotina para buscar dados da tela ALTTAR
 * --------------
 * ALTERAÇÕES   : 30/10/2017 - Adicionado os campos vlpertar, vlmaxtar, vlmintar 
 *							   e tpcobtar na tela. PRJ M150 (Mateus Z - Mouts)
 *
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
	$cddopcao       = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	$cdtarifa       = (isset($_POST['cdtarifa'])) ? $_POST['cdtarifa'] : 0  ;
    $cddgrupo       = (isset($_POST['cddgrupo'])) ? $_POST['cddgrupo'] : 0  ;
    $cdsubgru       = (isset($_POST['cdsubgru'])) ? $_POST['cdsubgru'] : 0  ;
    $cdcatego       = (isset($_POST['cdcatego'])) ? $_POST['cdcatego'] : 0  ;
    $cdlcremp       = (isset($_POST['cdlcremp'])) ? $_POST['cdlcremp'] : -1  ;
    $nrconven       = (isset($_POST['nrconven'])) ? $_POST['nrconven'] : 0  ;
    $dtdivulg       = (isset($_POST['dtdivulg'])) ? $_POST['dtdivulg'] : '' ;
    $dtvigenc       = (isset($_POST['dtvigenc'])) ? $_POST['dtvigenc'] : '' ;

	// Procedure a ser executada
	$procedure = 'lista-fvl-tarifa';
	
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
	$xml .= '		<cdsubgru>'.$cdsubgru.'</cdsubgru>';
    $xml .= '		<cdcatego>'.$cdcatego.'</cdcatego>';
    $xml .= '		<cdlcremp>'.$cdlcremp.'</cdlcremp>';
    $xml .= '		<nrconven>'.$nrconven.'</nrconven>';
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
    $arrfaixas = array();
	
    echo '<form name="frmAtribuicaoDetalhamento" id="frmAtribuicaoDetalhamento" onsubmit="return false;">';
    echo '<fieldset style="clear: both; border: 1px solid rgb(119, 119, 119); margin: 3px 0px; padding: 10px 3px 5px;">';
	echo '  <legend style="font-size: 11px; color: rgb(119, 119, 119); margin-left: 5px; padding: 0px 2px;">'.utf8ToHtml('Detalhamentos').'</legend>';
	echo '	<div id="divAtribuicaoDetalhamento" class="divRegistros">';
    echo '		<table>';
	echo '			<thead>';
	echo '				<tr>';	
	echo '					<th>&nbsp;</th>';
	echo '					<th>Valor Inicial</th>';
	echo '					<th>Valor Final</th>';
	echo '					<th>Tarifa atual</th>';
	echo '					<th>Nova tarifa</th>';
	echo '					<th>% Atual</th>';
	echo '					<th>Min. Atual</th>';
	echo '					<th>Max. Atual</th>';
	echo '					<th>% Novo</th>';
	echo '					<th>Min. Novo</th>';
	echo '					<th>Max. Novo</th>';
	echo '				</tr>';
	echo '			</thead>';
	echo '			<tbody>';

    $i = 0;
	foreach( $faixavalores as $r ) {
        $i++;
        $index = str_pad(getByTagName($r->tags,'cdtarifa'), 9, '0', STR_PAD_LEFT).str_pad(getByTagName($r->tags,'vlinifvl'), 22, '0', STR_PAD_LEFT);

        echo "<tr>";
		echo    "<td height='27'><span>".$index."</span>".getByTagName($r->tags,'cdtarifa')." ".getByTagName($r->tags,'dstarifa')."</td>";
		echo    "<td><input type='text' value='".formataMoeda(getByTagName($r->tags,'vlinifvl'))."' class='campo formatFieldOff' /></td>";
		echo    "<td><input type='text' value='".formataMoeda(getByTagName($r->tags,'vlfinfvl'))."' class='campo formatFieldOff' /></td>";
		echo    "<td><input type='text' value='".formataMoeda(getByTagName($r->tags,'vltarifa'))."' class='campo formatFieldOff tarifa' /></td>";
		echo    "<td>";
        echo        "<input type='text' id='vltarnew_".$i."' value='' class='campo formatFieldOn tarifa' onchange='limparCamposNovaTarifa(".$i.")' />";
        echo        "<input type='hidden' id='cdfaixav_".$i."' value='".getByTagName($r->tags,'cdfaixav')."' />";
        echo        "<input type='hidden' id='cdlcremp_".$i."' value='".getByTagName($r->tags,'cdlcremp')."' />";
        echo        "<input type='hidden' id='nrconven_".$i."' value='".getByTagName($r->tags,'nrconven')."' />";
        echo        "<input type='hidden' id='cdocorre_".$i."' value='".getByTagName($r->tags,'cdocorre')."' />";
        echo    "</td>";
        echo    "<td><input type='text' value='".formataMoeda(getByTagName($r->tags,'vlpertar'))."' class='campo formatFieldOff' /></td>";
        echo    "<td><input type='text' value='".formataMoeda(getByTagName($r->tags,'vlmintar'))."' class='campo formatFieldOff' /></td>";
        echo    "<td><input type='text' value='".formataMoeda(getByTagName($r->tags,'vlmaxtar'))."' class='campo formatFieldOff' /></td>";
        echo    "<td><input type='text' id='vlpercno_".$i."' class='campo formatFieldOn' onchange='limparCampoTarifaAtual(".$i.")' /></td>";
        echo    "<td><input type='text' id='vlminnov_".$i."' class='campo formatFieldOn' onchange='limparCampoTarifaAtual(".$i.")' /></td>";
        echo    "<td><input type='text' id='vlmaxnov_".$i."' class='campo formatFieldOn' onchange='limparCampoTarifaAtual(".$i.")' /></td>";
		echo "</tr>";
	}

	echo '			</tbody>';
    echo '		</table>';
	echo '      <input type="hidden" id="qtd_regs" value="'.$i.'" />';    
	echo '	</div>';
	echo '</fieldset>';
	echo '</form>';
    
    echo "<script>";
    echo "trocaBotao('Concluir')";
    echo "</script>";
?>
