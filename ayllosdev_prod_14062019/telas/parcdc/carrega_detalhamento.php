<? 
/*!
 * FONTE        : carrega_detalhamento.php
 * CRIAÇÃO      : Diego Simas 
 * DATA CRIAÇÃO : 30/04/2018 
 * OBJETIVO     : Rotina para listar detalhamentos do cadastro de tarifas
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
	
	// Inicializa
	$retornoAposErro= '';
	
	// Recebe a operação que está sendo realizada
	$cddopcao		= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ; 
	$idcomissao		= (isset($_POST['idcomissao'])) ? $_POST['idcomissao'] : 0  ; 	
    $tpvalor		= (isset($_POST['tpvalor'])) ? $_POST['tpvalor'] : 0  ; 	
    $nmrotina       = isset($_POST["nmrotina"]) ? $_POST["nmrotina"] : $glbvars["nmrotina"];
    

	$retornoAposErro = 'focaCampoErro(\'idcomissao\', \'frmComissao\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$nmrotina,$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','btnVoltarComissao();',true);
	}

	// Monta o xml de requisicao
    $xml  = "<Root>";
    $xml .= " <Dados>";
    $xml .= "  <idcomissao>".$idcomissao."</idcomissao>";            
    $xml .= " </Dados>";
    $xml .= "</Root>";
    
    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
    $xmlResult = mensageria($xml, "TELA_PARCDC", "LISTAR_DETALHAMENTOS_CDC", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
    $xmlObjeto = getObjectXML($xmlResult);
    $detalhes = $xmlObjeto->roottag->tags[2]->tags;	

    echo '<fieldset style="clear: both; border: 1px solid rgb(119, 119, 119); margin: 3px 0px; padding: 10px 3px 5px;">';
	echo '  <legend style="font-size: 11px; color: rgb(119, 119, 119); margin-left: 5px; padding: 0px 2px;">'.utf8ToHtml('Detalhamentos').'</legend>';
	echo '	<div class="divRegistros">';
	echo '		<table>';
	echo '			<thead>';
	echo '				<tr>';	
	echo '					<th>'.utf8ToHtml('Faixa').'</th>';
	echo '					<th>'.utf8ToHtml('Valor Inicial').'</th>';
	echo '					<th>'.utf8ToHtml('Valor Final').'</th>';
    if ($tpvalor == 2 ){
        echo '					<th>'.utf8ToHtml('Perc. Comiss&atilde;o').'</th>';        
    }else{
	    echo '					<th>'.utf8ToHtml('Valor Comiss&atilde;o').'</th>';
    }
	echo '				</tr>';
	echo '			</thead>';
	echo '			<tbody>';	
	
	foreach( $detalhes as $detalhe ) { 	
	    echo "<tr>";
		echo	"<td id='codfaixa'><span>".getByTagName($detalhe->tags, 'faixa')."</span>";
		echo                 getByTagName($detalhe->tags, 'faixa');
		echo    "</td>";
		echo	"<td id='vlinicial'><span>".converteFloat(getByTagName($detalhe->tags, 'vlinicial'),'MOEDA')."</span>";
		echo                 formataMoeda(getByTagName($detalhe->tags, 'vlinicial')); 
		echo	"</td>";
		echo	"<td id='vlfinal'><span>".converteFloat(getByTagName($detalhe->tags, 'vlfinal'),'MOEDA')."</span>";
        echo                 formataMoeda(getByTagName($detalhe->tags, 'vlfinal'));
		echo	"</td>";
        echo	"<td id='vlcomiss_aux'><span>".converteFloat(getByTagName($detalhe->tags, 'vlcomiss'),'MOEDA')."</span>";
        echo                 formataMoeda(getByTagName($detalhe->tags, 'vlcomiss'));
        if ($tpvalor == 2 ){
            echo "%";                
        }
		echo	"</td>";			
		echo "</tr>";
	} 	
			
	echo '			</tbody>';
	echo '		</table>';
	echo '	</div>';
	echo '</fieldset>';

	echo '<div id="divBotoesDetalha" style="margin-top:5px; margin-bottom :10px; text-align:center;">';
    echo '	<a href="#" class="botao" id="btIncluir" onClick="mostraDetalhamentoComissao(\'I\'); return false;">&nbsp;Incluir&nbsp;</a>';
    echo '	<a href="#" class="botao" id="btAlterar" onClick="mostraDetalhamentoComissao(\'A\'); return false;">&nbsp;Alterar&nbsp;</a>';
    echo '	<a href="#" class="botao" id="btExcluir" onClick="excluirDetalhamento(); return false;">&nbsp;Excluir&nbsp;</a>';
    echo '</div>';	


?>
