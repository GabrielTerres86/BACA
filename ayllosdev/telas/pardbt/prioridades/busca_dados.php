<?php
/*!
 * FONTE        : busca_dados.php
 * CRIAÇÃO      : Reginaldo Rubens da Silva (AMcom)         
 * DATA CRIAÇÃO : 26/02/2013 
 * OBJETIVO     : Rotina para buscar dados dos programas com suas prioridades e  horários
 *                de execução (para a tela CONSULTAR do cadastro de prioridades da Parametrização
 *                do Debitador Único)
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */

    session_start();

	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');

	isPostMethod();		

    $cddopcao = $_POST['cddopcao'];
	$idhora_processamento = $_POST['idhora_processamento'];

    $msgError = validaPermissao($glbvars["nmdatela"],$glbvars['nmrotina'],$cddopcao, false);

    if ($msgError != '') {
		exibirErro('error', utf8ToHtml('Acesso não permitido.'), 'Alerta - Ayllos', 'estadoInicial()', false);
	}

	if (empty($idhora_processamento)) {
		$idhora_processamento = 0;
	}

    // Monta o xml de requisição
	$xml = "<Root>";
    $xml .= " <Dados>";
	$xml .= "   <idhora_processamento>" . $idhora_processamento . "</idhora_processamento>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "DEBITADOR_UNICO", "DEBITADOR_PR_COMP_CONSULTAR", 
		$glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], 
		$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");    

	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','unblockBackground()',false);
	}
	
	$processos = $xmlObjeto->roottag->tags[0]->tags;
	
	echo '	<div class="divRegistros">';
	echo '		<table>';
	echo '			<thead>';
	echo '				<tr>';	
	echo '					<th title="' . utf8ToHtml('Prioridade') . '">Priorid.</th>';	
    echo '					<th>' . utf8ToHtml('Programa') . '</th>';
    echo '					<th>Ativo</th>';
    echo '					<th title="' . utf8ToHtml('Debita sem saldo') . '">Deb.S/<br> saldo</th>';
    echo '					<th title="' . utf8ToHtml('Débito Parcial') . '">' . utf8ToHtml('Déb.<br>parc.') . '</th>';
    echo '					<th title="' . utf8ToHtml('Repescagem - quantidade de dias') . '">' . utf8ToHtml('Repes.') . '</th>';
	echo '					<th title="' . utf8ToHtml('Execução cadeia') . '">' . utf8ToHtml('Exec. Cadeia') . '</th>';
    echo '					<th title="' . utf8ToHtml('Controle da Quantidade de Execuções') . '">' . utf8ToHtml('Ctrl. Qtd. Execução') . '</th>';
    echo '					<th>' . utf8ToHtml('Horários de<br>Processamento') . '</th>';
	echo '				</tr>';
	echo '			</thead>';
	echo '			<tbody>';
	
	foreach ($processos as $processo) { 	
        $listaHorarios = '';
        $horarios = $processo->tags[8]->tags;

        foreach($horarios as $horario) {
            $listaHorarios .= (!empty($listaHorarios) ? '&nbsp;&nbsp;' : '') . getByTagName($horario->tags, 'dhprocessamento');
        }

		$ativo = getByTagName($processo->tags, 'nrprioridade') != '' ? 'Sim' : 'Não';

		$opcoesExecProg = array(
            '0' => array('Nenhum', 'Nenhum controle de execução'),
            '1' => array('Primeira', 'Controle na primeira execução'),
            '2' => array('Última', 'Controle na última execução'),
            '3' => array('Ambos', 'Controle na primeira e última execução')
        );
		
		$indeb_sem_saldo = getByTagName($processo->tags, 'indeb_sem_saldo') == 'S' ? 'Sim' : 'Não';
		$indeb_parcial = getByTagName($processo->tags, 'indeb_parcial') == 'S' ? 'Sim' : 'Não';
		$inexec_cadeia_noturna = getByTagName($processo->tags, 'inexec_cadeia_noturna') == 'S' ? 'Sim' : 'Não';
        $incontrole_exec_prog = utf8ToHtml($opcoesExecProg[getByTagName($processo->tags, 'incontrole_exec_prog')][0]);
        $titleIncontrole_exec_prog = utf8ToHtml($opcoesExecProg[getByTagName($processo->tags, 'incontrole_exec_prog')][1]);
		

		echo "<tr>";	
		echo	"<td style=\"vertical-align: middle;\">" . getByTagName($processo->tags, 'nrprioridade') . "</td>" ;
        echo	"<td style=\"vertical-align: middle; text-align: justify; overflow-x: hidden;\" title=\"" . getByTagName($processo->tags, 'cdprocesso') . "\">" . 
		        getByTagName($processo->tags, 'dsprocesso') . "</td>" ;
        echo	"<td style=\"vertical-align: middle;\">" . utf8ToHtml($ativo) . "</td>" ;
        echo    "<td style=\"vertical-align: middle;\">" . utf8ToHtml($indeb_sem_saldo) . "</td>";
        echo    "<td style=\"vertical-align: middle;\">" . utf8ToHtml($indeb_parcial) . "</td>";
        echo	"<td style=\"vertical-align: middle;\">" . getByTagName($processo->tags, 'qtdias_repescagem') . "</td>" ;
		 echo	"<td style=\"vertical-align: middle;\">" . utf8ToHtml($inexec_cadeia_noturna) . "</td>" ;
        echo	"<td style=\"vertical-align: middle;\" title=\"" . $titleIncontrole_exec_prog . "\">" . $incontrole_exec_prog . "</td>";
        echo    "<td style=\"vertical-align: middle; overflow-x: hidden; overflow-y: auto;\">" . $listaHorarios . "<td>";
		echo "</tr>";
	} 	
	
	echo '			</tbody>';
	echo '		</table>';
	echo '	</div>';
