<?php
/*!
 * FONTE        : busca_dados.php
 * CRIAÇÃO      : Reginaldo Rubens da Silva (AMcom)
 * DATA CRIAÇÃO : Março/2018 
 * OBJETIVO     : Rotina para buscar dados dos horários cadastrados na tela PARDBT 
 *                (Parametrização do Debitador Único - Cadastro de Horários)
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

    $msgError = validaPermissao($glbvars["nmdatela"],$glbvars['nmrotina'],$cddopcao, false);

    if ($msgError != '') {
		exibirErro('error', utf8ToHtml('Acesso não permitido.'), 'Alerta - Ayllos', 'estadoInicial()', false);
	}	

    // Monta o xml de requisição
	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "DEBITADOR_UNICO", "DEBITADOR_HR_CONSULTAR", 
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
	
	$horarios = $xmlObjeto->roottag->tags[0]->tags;
    if ($cddopcao == 'A') { // Alteração
        echo '<p style="text-align: center; color: grey; padding:7px;">Clique sobre o hor&aacute;rio que deseja alterar.</p>';
    }
    else if ($cddopcao == 'E') { // Exclusão
        echo '<p style="text-align: center; color: grey; padding:7px;">Clique sobre o hor&aacute;rio que deseja excluir.</p>';
    }
	else if ($cddopcao == 'C') { //Consulta
        echo '<p style="text-align: center; color: grey; padding:7px;">Clique sobre o hor&aacute;rio para visualizar os programas agendados.</p>';
    }
	
	echo '	<div class="divRegistros">';
	echo '		<table>';
	echo '			<thead>';
	echo '				<tr>';	
	echo '					<th>'.utf8ToHtml('Horário').'</th>';	
	echo '				</tr>';
	echo '			</thead>';
	echo '			<tbody>';	
			
	foreach( $horarios as $horario ) { 	
		echo "<tr>";	
		echo	"<td style=\"text-align: center;\" id='dhprocessamento'><span>".getByTagName($horario->tags,'dhprocessamento')."</span>";
		echo    "            <input type=\"hidden\" name=\"idhora_processamento\" value=\"" . getByTagName($horario->tags,'idhora_processamento') ."\">";
		if ($cddopcao == 'C') {
			echo '<a href="javascript:" onclick="carregaProcessosHorario(' . getByTagName($horario->tags,'idhora_processamento') . ')">';
		}
		echo getByTagName($horario->tags,'dhprocessamento');
		if ($cddopcao == 'C') {
			echo '</a>';
		}
		echo    "</td>";
		echo "</tr>";
	} 	
			
	echo '			</tbody>';
	echo '		</table>';
	echo '	</div>';
?>
