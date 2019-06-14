<? 
/*!
 * FONTE        : tab_dados.php
 * CRIAÇÃO      : Guilherme / SUPERO
 * DATA CRIAÇÃO : 26/03/2013
 * OBJETIVO     : Tabela que apresenta a consulta da LOGACE
 * --------------
 * ALTERAÇÕES   :
 *
 * --------------
 */
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<div id="tabDetalhes">
	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Codigo'); ?></th>
					<th><? echo utf8ToHtml('Operador');  ?></th>
					<th><? echo utf8ToHtml('Qtd Acessos');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? 
				for ($i = 0; $i < $qtDetalhes; $i++) {
				$dscooper = getByTagName($detalhes[0]->tags,'dscooper');
				$dsdatela = getByTagName($detalhes[0]->tags,'dsdatela');
				$dsorigem = getByTagName($detalhes[0]->tags,'dsorigem');
				?>
					<tr>
						<td><span><? echo getByTagName($detalhes[$i]->tags,'cdoperad'); ?></span>
								  <? echo getByTagName($detalhes[$i]->tags,'cdoperad'); ?>
						</td>
						<td><span><? echo getByTagName($detalhes[$i]->tags,'nmoperad'); ?></span>
								  <? echo getByTagName($detalhes[$i]->tags,'nmoperad'); ?>
						</td>
						<td><span><? echo getByTagName($detalhes[$i]->tags,'qtdacess'); ?></span>
								  <? echo getByTagName($detalhes[$i]->tags,'qtdacess'); ?>
						</td>
					</tr>
				<? } ?>
				<tr>
					<input type="hidden" id="dscooper" name="dscooper" value="<? echo $dscooper ?>" />								  
					<input type="hidden" id="dsdatela" name="dsdatela" value="<? echo $dsdatela ?>" />								  
					<input type="hidden" id="dsorigem" name="dsorigem" value="<? echo $dsorigem ?>" />								  
				</tr>
			</tbody>
		</table>
	</div>	

    <div id="divPesquisaRodape" class="divPesquisaRodape">
        <table>	
            <tr>
                <td>
<?                      if (isset($qtregdet) and $qtregdet == 0) $nrinidet = 0;

                        // Se a paginação não está na primeira, exibe botão voltar
                        if ($nrinidet > 1) { 
                            ?> <a class='paginacaoAntDet'><<< Anterior</a> <? 
                        } else {
                            ?> &nbsp; <?
                        }
                    ?>
                </td>
                <td>
                    <?
                        if (isset($nrinidet)) { 
                            ?> Exibindo <? echo $nrinidet; ?> at&eacute; <? if (($nrinidet + $nrregdet) > $qtregdet) { echo $qtregdet; } else { echo ($nrinidet + $nrregdet - 1); } ?> de <? echo $qtregdet; ?><?
                        }
                    ?>
                </td>
                <td>
                    <?
                        // Se a paginação não está na &uacute;ltima página, exibe botão proximo
                        if ($qtregdet > ($nrinidet + $nrregdet - 1)) {
                            ?> <a class='paginacaoProxDet'>Pr&oacute;ximo >>></a> <?
                        } else {
                            ?> &nbsp; <?
                        }
                    ?>			
                </td>
            </tr>
        </table>
    </div>
</div>
<div id="linha1">
    <ul class="complemento">
        <li><? echo utf8ToHtml('Cooperativa:'); ?></li>
        <li id="dscooper"></li>
		<li><? echo utf8ToHtml('Tela:'); ?></li>
		<li id="dsdatela"></li>
		<li><? echo utf8ToHtml('Origem Acesso:'); ?></li>
		<li id="dsorigem"></li>
	</ul>
</div>
<br style="clear:both" />
<div id="divBotoes2">
	<a href="#" class="botao" id="btVoltar"  onClick="btnVoltar2(); return false;">Voltar</a>
</div>
<script type="text/javascript">
	$('a.paginacaoAntDet').unbind('click').bind('click', function() {
        executaPesquisaDetalhe(<? echo "'".($nrinidet - $nrregdet)."','".$nrregdet."'"; ?>);
	});
	$('a.paginacaoProxDet').unbind('click').bind('click', function() {
		executaPesquisaDetalhe(<? echo "'".($nrinidet + $nrregdet)."','".$nrregdet."'"; ?>);
	});	
	
	$('#divPesquisaRodape','#tabDetalhes').formataRodapePesquisa();
</script>