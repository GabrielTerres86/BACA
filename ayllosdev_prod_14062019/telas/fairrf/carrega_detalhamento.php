<? 
/*!
 * FONTE        : carrega_detalhamento.php
 * CRIAÇÃO      : Dionathan Henchel
 * DATA CRIAÇÃO : 03/12/2015
 * OBJETIVO     : Rotina para buscar dados da tela FAIRRF
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
	// Recebe a operação que está sendo realizada
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : 0;

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <inpessoa>".$inpessoa."</inpessoa>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	// Chamada mensageria
    $xmlResult = mensageria($xml, "FAIRRF", "BUSCA_FAIXA_IRRF", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObj = getObjectXML($xmlResult);
	/*echo "<pre>";
	var_dump($xmlObj);
	echo "</pre>";
	return;*/
	
    // Tratamento de erro
    if (strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')) {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
		
        if ($msgErro == null || $msgErro == '') {
            $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
        }
        exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);

        exit();
    } else {
        $registros = $xmlObj->roottag->tags[0]->tags;
        $qtregist = $xmlObj->roottag->tags[1]->cdata;
    }
	
	echo '<fieldset style="clear: both; border: 1px solid rgb(119, 119, 119); margin: 3px 0px; padding: 10px 3px 5px;">';
	echo '  <legend style="font-size: 11px; color: rgb(119, 119, 119); margin-left: 5px; padding: 0px 2px;">'.utf8ToHtml('Detalhamentos').'</legend>';
	echo '	<div class="divRegistros">';
	echo '		<table>';
	echo '			<thead>';
	echo '				<tr>';	
	echo '					<th>'.utf8ToHtml('Faixa').'</th>';
	echo '					<th>'.utf8ToHtml('Valor Inicial').'</th>';
	echo '					<th>'.utf8ToHtml('Valor Final').'</th>';
	echo '					<th>'.utf8ToHtml('Percentual').'</th>';
	echo '					<th>'.utf8ToHtml('Dedução').'</th>';
	echo '				</tr>';
	echo '			</thead>';
	echo '			<tbody>';	
	
	
	foreach( $registros as $r ) {
		echo "<tr>";
		echo	"<td id='cdfaixa'><span>".getByTagName($r->tags,'cdfaixa')."</span>";
		echo                 getByTagName($r->tags,'cdfaixa');
		echo    "</td>";
		echo	"<td id='vlfaixa_inicial'><span>".converteFloat(getByTagName($r->tags,'vlfaixa_inicial'),'MOEDA')."</span>";
		echo                 formataMoeda(getByTagName($r->tags,'vlfaixa_inicial')); 
		echo	"</td>";
		echo	"<td id='vlfaixa_final'><span>".converteFloat(getByTagName($r->tags,'vlfaixa_final'),'MOEDA')."</span>";
        echo                 formataMoeda(getByTagName($r->tags,'vlfaixa_final'));
		echo	"</td>";
		echo	"<td id='vlpercentual_irrf'><span>".converteFloat(getByTagName($r->tags,'vlpercentual_irrf'),'MOEDA')."</span>";
        echo                 formataMoeda(getByTagName($r->tags,'vlpercentual_irrf'));
		echo	"</td>";
		echo	"<td id='vldeducao'><span>".converteFloat(getByTagName($r->tags,'vldeducao'),'MOEDA')."</span>";
        echo                 formataMoeda(getByTagName($r->tags,'vldeducao'));
		echo	"</td>";
		
		echo	"<td id='inpessoa' style=\"display:none\"><span>".getByTagName($r->tags,'inpessoa')."</span>";
		echo                 getByTagName($r->tags,'inpessoa');
		echo    "</td>";
		echo "</tr>";
	}
			
	echo '			</tbody>';
	echo '		</table>';
	echo '	</div>';
	echo '</fieldset>';

	echo '<div id="divBotoesDetalha" style="margin-top:5px; margin-bottom :10px; text-align:center;">';
	if ( $glbvars['cdcooper'] == 3) {
		
		if ($cddopcao == 'A') {
			echo '	<a href="#" class="botao" id="btIncluir" onClick="mostraDetalhamentoFaixa(\'I\'); return false;">&nbsp;Incluir&nbsp;</a>';
			echo '	<a href="#" class="botao" id="btAlterar" onClick="mostraDetalhamentoFaixa(\'A\'); return false;">&nbsp;Alterar&nbsp;</a>';
			echo '	<a href="#" class="botao" id="btExcluir" onClick="excluirDetalhamento(); return false;">&nbsp;Excluir&nbsp;</a>';
		}
		//echo '	<a href="#" class="botao" id="btConsultar" onClick="mostraDetalhamentoFaixa(\'X\');">Consultar</a>';
		
	} else {
		//echo '	<a href="#" class="botao" id="btConsultar" onClick="mostraDetalhamentoFaixa(\'X\');">Consultar</a>';
	}
	echo '</div>';
?>
