<?php
/*!
 * FONTE        : busca_dados.php
 * CRIAÇÃO      : Daniel Zimmermann         
 * DATA CRIAÇÃO : 26/02/2013 
 * OBJETIVO     : Rotina para buscar grupo na tela CADGRU
 * --------------
 * ALTERAÇÕES   : 05/12/2016 - P341-Automatização BACENJUD - Alterar a passagem da descrição do 
 *                             departamento como parametros e passar o o código (Renato Darosci)
 * -------------- 
 */

    session_start();

	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');

	isPostMethod();		

    $cddopcao = $_POST['cddopcao'];

    // Monta o xml de requisição
	$xml = "<Root>";
    $xml .= " <Dados>";
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
	
	echo '<fieldset style="clear: both; border: 1px solid rgb(119, 119, 119); margin: 3px 0px; padding: 10px 3px 5px;">';
	echo '  <legend style="font-size: 11px; color: rgb(119, 119, 119); margin-left: 5px; padding: 0px 2px;">'.utf8ToHtml('Prioridades dos Programas').'</legend>';
	echo '	<div class="divRegistros">';
	echo '		<table>';
	echo '			<thead>';
	echo '				<tr>';	
	echo '					<th>Prioridade</th>';	
    echo '					<th>' . utf8ToHtml('Descrição do Programa') . '</th>';
    echo '					<th>Ativo</th>';
    echo '					<th>Debita<br>Sem saldo</th>';
    echo '					<th>' . utf8ToHtml('Débito<br>parcial') . '</th>';
    echo '					<th>' . utf8ToHtml('Repescagem<br>Qtd. dias') . '</th>';
    echo '					<th>' . utf8ToHtml('Horários de<br>Processamento') . '</th>';
	echo '				</tr>';
	echo '			</thead>';
	echo '			<tbody>';
	
	foreach ($processos as $processo) { 	
        $prioridade = getByTagName($processo->tags, 'nrprioridade');
		$ativo = $prioridade != '' ? 'S' : 'N';
        $listaHorarios = '';
        $horarios = $processo->tags[6]->tags;

        foreach($horarios as $horario) {
            $listaHorarios .= (!empty($listaHorarios) ? '<br>' : '') . getByTagName($horario->tags, 'dhprocessamento') . 
                "&nbsp;&nbsp;<img style=\"cursor: pointer;\" title=\"" . utf8ToHtml('excluir horário') . 
                "\" src=\"../../../imagens/geral/excluir.gif\" onclick=\"excluirHorarioProc('" . 
                getByTagName($processo->tags, 'cdprocesso') . "'," . getByTagName($horario->tags, 'idhora_processamento') . ");\">";
        }

        if ($ativo == 'S') {
            $listaHorarios .= (!empty($listaHorarios) ? '<br>' : '') . '<button style="font-size: 10px; margin: 4px; padding: 2px; border: 1px solid grey;" onclick="adicionarHorarioProc(\'' . 
                getByTagName($processo->tags, 'cdprocesso') . '\')">Adicionar</button>';
        }
		
		$indeb_sem_saldo = getByTagName($processo->tags, 'indeb_sem_saldo') == 'S' ? 'Sim' : 'Não';
		$indeb_parcial = getByTagName($processo->tags, 'indeb_parcial') == 'S' ? 'Sim' : 'Não';
		
        $max_prioridade = getByTagName($xmlObjeto->roottag->tags, 'max_prioridade');
		
		echo "<tr>";	
		echo	"<td style=\"vertical-align: middle; text-align: left;\"><input type=\"hidden\" name=\"nrprioridade\" value=\"" . $prioridade . "\">" . $prioridade . 
            "&nbsp;&nbsp;<div style=\"float: right; right: 0; position: relative; width: 40px; text-align: left;
            \">";
        if ($ativo == 'S') {
            $margin = '';

            if ($prioridade > 1) {
                echo "<img style=\"cursor: pointer;\" src=\"../../../imagens/geral/sweetie-16-arrow-up.png\" title=\"subir\" onclick=\"redefinirPrioridade('" . 
                getByTagName($processo->tags, 'cdprocesso') . "'," . ($prioridade - 1) . ");\">&nbsp;";
            }
            else {
                echo  "&nbsp;";
                $margin = 'margin-left: 16px;';
            }
            
            if ($prioridade < $max_prioridade) {
                echo "<img style=\"cursor: pointer; $margin\" src=\"../../../imagens/geral/sweetie-16-arrow-down.png\" title=\"descer\" onclick=\"redefinirPrioridade('" . 
                getByTagName($processo->tags, 'cdprocesso') . "'," . ($prioridade + 1) . ");\">&nbsp;";
            }
        }
        echo "</div></td>" ;
        echo	"<td style=\"vertical-align: middle;\">" . getByTagName($processo->tags, 'dsprocesso') . "</td>" ;
        echo	"<td style=\"vertical-align: middle;\">"; 
        echo        "<select class=\"campo\" name=\"ativar\" onchange=\"alternarAtivo('" . getByTagName($processo->tags, 'cdprocesso') . "','" . 
            getByTagName($processo->tags, 'dsprocesso') . "','" . $ativo . "');\"><option value=\"S\" " . ($ativo == 'S' ? ' selected' : '') . 
                       ">Sim</option><option value=\"N\" ". ($ativo == 'N' ? 'selected' : '') . ">" . utf8ToHtml('Não') . "</option></select>"; 
        echo "  </td>" ;
        echo    "<td style=\"vertical-align: middle;\">" . utf8ToHtml($indeb_sem_saldo) . "</td>";
        echo    "<td style=\"vertical-align: middle;\">" . utf8ToHtml($indeb_parcial) . "</td>";
        echo	"<td style=\"vertical-align: middle;\">" . getByTagName($processo->tags, 'qtdias_repescagem') . "</td>" ;
        echo    "<td style=\"vertical-align: middle;\">" . $listaHorarios . "<td>";
		echo "</tr>";
	} 	
	
	echo '			</tbody>';
	echo '		</table>';
	echo '	</div>';
	echo '</fieldset>';
