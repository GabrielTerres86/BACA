<? 
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
	
	echo '<fieldset style="clear: both; border: 1px solid rgb(119, 119, 119); margin: 3px 0px; padding: 10px 3px 5px;">';
	echo '  <legend style="font-size: 11px; color: rgb(119, 119, 119); margin-left: 5px; padding: 0px 2px;">'.utf8ToHtml('Horários cadastrados').'</legend>';
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
		echo    "            <input type=\"hidden\" name=\"idhora_processamento\" value=\"" . getByTagName($horario->tags,'idhora_processamento') ."\">" . getByTagName($horario->tags,'dhprocessamento');
		echo    "</td>";
		echo "</tr>";
	} 	
			
	echo '			</tbody>';
	echo '		</table>';
	echo '	</div>';
	echo '</fieldset>';
?>
