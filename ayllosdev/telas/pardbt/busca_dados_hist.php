<? 
/*!
 * FONTE        : busca_dados_hist.php
 * CRIAÇÃO      : Reginaldo Rubens da Silva (AMcom)
 * DATA CRIAÇÃO : março/2018 
 * OBJETIVO     : Rotina para buscar históricos das operações de parametrização do Debitador Único
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */

    session_start();

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');

	isPostMethod();		
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

    $origens = array(
        0 => 'Geral',
        1 => 'Cad. de Prioridades',
        2 => 'Cad. de Horários',
        3 => 'Exec. Emergencial'
    );

    $tporigem = $_POST['tporigem'];

    if (empty($tporigem)) {
        $tporigem = 0;
    }

    // Monta o xml de requisição
	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= "   <tporigem>" . $tporigem . "</tporigem>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "DEBITADOR_UNICO", "DEBITADOR_HIST_CONSULTAR", 
		$glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], 
		$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");    

	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	$historicos = $xmlObjeto->roottag->tags[0]->tags;
	
	echo '<fieldset style="clear: both; border: 1px solid rgb(119, 119, 119); margin: 3px 0px; padding: 10px 3px 5px;">';
	echo '  <legend style="font-size: 11px; color: rgb(119, 119, 119); margin-left: 5px; padding: 0px 2px;">'.utf8ToHtml('Histórico de operações - ' . $origens[$tporigem]).'</legend>';
	echo '	<div class="divRegistros">';
	echo '		<table>';
	echo '			<thead>';
	echo '				<tr>';	
	echo '					<th>'.utf8ToHtml('Data/Hora').'</th>';	
    echo '					<th>'.utf8ToHtml('Operador').'</th>';
    echo '					<th>'.utf8ToHtml('Operação').'</th>';	
    echo '					<th>'.utf8ToHtml('Parâmetros').'</th>';		
	echo '				</tr>';
	echo '			</thead>';
	echo '			<tbody>';	
			
	foreach( $historicos as $historico ) { 	
        $campo = getByTagName($historico->tags,'dscampo_alterado');
        $valor_anterior = getByTagName($historico->tags,'dsvalor_anterior');
        $valor_novo = getByTagName($historico->tags,'dsvalor_novo');
        $cdprocesso = getByTagName($historico->tags,'cdprocesso');
        $dsprocesso = getByTagName($historico->tags,'dsprocesso');

        $nomesCampos = array(
            'idhora_processamento' => 'Cód. Horário',
            'dhprocessamento' => 'Horário',
            'horario' => 'Horário',
            'nrprioridade' => 'Prioridade',
            'exec_emergencial' => 'Execução emergencial'
        );

        $tpoperacao = getByTagName($historico->tags,'tpoperacao');

        $parametros = utf8ToHtml($nomesCampos[trim($campo)]) . ': ';

        if ($tpoperacao == '1') {
            $parametros .= $valor_novo;

            if (!empty($cdprocesso)) {
                $parametros .= ' <div style="display: inline;" title="' . $dsprocesso . '"> (' . $cdprocesso . ')</div>';
            }
        }
        else if ($tpoperacao == '2') {
            $parametros .= ' de ' . ($valor_anterior != '' ? $valor_anterior : 'NULL') . ' para ' . ($valor_novo != '' ? $valor_novo : 'NULL');

            if (!empty($cdprocesso)) {
                $parametros .= ' <div style="display: inline;" title="' . $dsprocesso . '"> (' . $cdprocesso . ')</div>';
            }
        }
        else if ($tpoperacao == '3') {
            $parametros .= $valor_anterior;

            if (!empty($cdprocesso)) {
                $parametros .= ' <div style="display: inline;" title="' . $dsprocesso . '"> (' . $cdprocesso . ')</div>';
            }
        }
        else if ($tpoperacao == '4') {
            $parametros .= $cdprocesso;
        }

        $operador = getByTagName($historico->tags,'cdoperador') == 1 ? getByTagName($historico->tags,'nmoperad') : getByTagName($historico->tags,'cdoperador');

		echo "<tr>";	
		echo	"<td style=\"text-align: center;\">" . getByTagName($historico->tags,'dhoperacao') . "</td>";
        echo	"<td title=\"" . getByTagName($historico->tags,'nmoperad') . "\">" . $operador  . "</td>";
        echo	"<td>" . mb_strtoupper(getByTagName($historico->tags,'tipooperacao')) . "</td>";
        echo	"<td ";
        echo ">" . $parametros . "</td>";
		echo "</tr>";
	} 	

    if (count($historicos) == 0) {
        echo "<tr><td colspan=\"4\" style=\"text-align: center;\">Nenhuma opera&ccedil;&atilde;o encontrada</td></tr>";
    }
			
	echo '			</tbody>';
	echo '		</table>';
	echo '	</div>';
	echo '</fieldset>';
?>
