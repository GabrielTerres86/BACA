<? 
/*!
 * FONTE        : carrega_processos.php
 * CRIAÇÃO      : Reginaldo Rubens da Silva (AMcom)      
 * DATA CRIAÇÃO : Março/2018
 * OBJETIVO     : Rotina para carregar processos que podem ser selecionados na 
 *                execução emergenial do Debitador Único
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */

    session_start();

	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( $glbvars['cddepart'] <> 20 && $cddopcao <> 'C' ) {
		$msgErro	= "Acesso n&atilde;o permitido.";
		exibirErro('error', $msgErro, 'Alerta - Ayllos','',false);
	}

	isPostMethod();		

    // Monta o xml de requisição
	$xml = "<Root>";
    $xml .= " <Dados>";
    $xml .= " </Dados>";
    $xml .= "</Root>";

    $xmlResult = mensageria($xml, "DEBITADOR_UNICO", "DEBITADOR_PR_RES_CONSULTAR", 
		$glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], 
		$glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");    


	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}
	
	$processos = $xmlObjeto->roottag->tags[0]->tags;

    
    echo '<p style="text-align: center; color: grey; padding:7px;">Selecione os processos que deseja executar emergencialmente.</p>';
    
	echo '	<div class="divRegistros">';
	echo '		<table>';
	echo '			<thead>';
	echo '				<tr>';	
	echo '					<th>Prioridade</th>';	
    echo '					<th>' . utf8ToHtml('Descrição do Programa') . '</th>';
    echo '					<th>Executar<input type="checkbox" id="execTodos" onclick="marcarExecutarTodos(event);"></th>';
	echo '				</tr>';
	echo '			</thead>';
	echo '			<tbody>';	
			
	foreach( $processos as $processo ) { 	
		echo "<tr>";	
		echo	"<td>" . getByTagName($processo->tags, 'nrprioridade') . "</td>";
        echo	"<td title=\"" . getByTagName($processo->tags, 'cdprocesso') . "\">" . getByTagName($processo->tags, 'dsprocesso') . "</td>";
		echo    "<td><input type=\"hidden\" value=\"" . getByTagName($processo->tags, 'cdprocesso') . "\"><input type=\"checkbox\" class=\"checkboxExecutar\" id=\"exec_" . getByTagName($processo->tags, 'cdprocesso') . "\"></td>";
		echo "</tr>";
	} 	
			
	echo '			</tbody>';
	echo '		</table>';
	echo '	</div>';
?>
