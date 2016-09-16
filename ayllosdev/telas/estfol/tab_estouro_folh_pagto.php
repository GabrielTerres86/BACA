<?
/*!
 * FONTE        : tab_estouro_folh_pagto.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Maio/2015
 * OBJETIVO     : Tabela Estouro de Folha de Pagamento
 * --------------
 * ALTERAÇÕES   : 20/11/2015 - Correção de colspan para correta exibicao
                               quando nao houver registro (Andre Santos - SUPERO)
 * --------------
 */
?>
<div id="tabEstouroFolha" style="display:block">
	<div class="divRegistros">
        <table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('PA');  ?></th>
					<th><? echo utf8ToHtml('Empresa');  ?></th>
					<th><? echo utf8ToHtml('Conta');  ?></th>
					<th><? echo utf8ToHtml('Solicitado &agrave;s');  ?></th>
					<th><? echo utf8ToHtml('Qtd Lancto');  ?></th>
					<th><? echo utf8ToHtml('Tot Pagto');  ?></th>
					<th><? echo utf8ToHtml('Tarifa');  ?></th>
					<th><? echo utf8ToHtml('Total Débito');  ?></th>
					<th><? echo utf8ToHtml('Valor Estouro');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				if ( count($estouroFolha) == 0 ) {
					$i = 0;
					// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
					?> <tr>
							<td colspan="9">
								<input type="hidden" id="conteudo" name="conteudo" value="<? echo $i; ?>" />
								<b>N&atilde;o h&aacute; registros de estouro de folha de pagamento.</b>
							</td>
						</tr>
				<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
				} else {
					for ($i = 0; $i < count($estouroFolha); $i++) {
					?>
						<tr>
							<td><input type="hidden" id="conteudo" name="conteudo" value="<? echo 1; ?>" />
								<input type="hidden" id="cdagenci" name="cdagenci" value="<? echo getByTagName($estouroFolha[$i]->tags,'cdagenci') ?>" />
								<input type="hidden" id="cdempres" name="cdempres" value="<? echo getByTagName($estouroFolha[$i]->tags,'cdempres') ?>" />
								<input type="hidden" id="nmresemp" name="nmresemp" value="<? echo getByTagName($estouroFolha[$i]->tags,'nmresemp') ?>" />
								<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo getByTagName($estouroFolha[$i]->tags,'nrdconta') ?>" />
								<input type="hidden" id="dtsolest" name="dtsolest" value="<? echo getByTagName($estouroFolha[$i]->tags,'dtsolest') ?>" />
								<input type="hidden" id="qtlctpag" name="qtlctpag" value="<? echo getByTagName($estouroFolha[$i]->tags,'qtlctpag') ?>" />
								<input type="hidden" id="vllctpag" name="vllctpag" value="<? echo getByTagName($estouroFolha[$i]->tags,'vllctpag') ?>" />
								<input type="hidden" id="vltarire" name="vltarire" value="<? echo getByTagName($estouroFolha[$i]->tags,'vltarire') ?>" />
								<input type="hidden" id="vltotdeb" name="vltotdeb" value="<? echo getByTagName($estouroFolha[$i]->tags,'vltotdeb') ?>" />
								<input type="hidden" id="vlestour" name="vlestour" value="<? echo getByTagName($estouroFolha[$i]->tags,'vlestour') ?>" />
							    <span><? echo getByTagName($estouroFolha[$i]->tags,'cdagenci'); ?></span>
									  <? echo getByTagName($estouroFolha[$i]->tags,'cdagenci'); ?> 
							</td>
							<td><span><? echo getByTagName($estouroFolha[$i]->tags,'cdempres'); ?> - <? echo getByTagName($estouroFolha[$i]->tags,'nmresemp'); ?></span>
									  <? echo getByTagName($estouroFolha[$i]->tags,'cdempres'); ?> - <? echo getByTagName($estouroFolha[$i]->tags,'nmresemp'); ?>
							</td>
							<td><span><? echo getByTagName($estouroFolha[$i]->tags,'nrdconta'); ?></span>
									  <? echo getByTagName($estouroFolha[$i]->tags,'nrdconta'); ?>
							</td>
							<td><span><? echo getByTagName($estouroFolha[$i]->tags,'dtsolest'); ?></span>
									  <? echo getByTagName($estouroFolha[$i]->tags,'dtsolest'); ?>
							</td>
							<td><span><? echo getByTagName($estouroFolha[$i]->tags,'qtlctpag'); ?></span>
									  <? echo getByTagName($estouroFolha[$i]->tags,'qtlctpag'); ?>
							</td>
							<td><span><? echo getByTagName($estouroFolha[$i]->tags,'vllctpag'); ?></span>
									  <? echo getByTagName($estouroFolha[$i]->tags,'vllctpag'); ?>
							</td>
							<td><span><? echo getByTagName($estouroFolha[$i]->tags,'vltarire'); ?></span>
									  <? echo getByTagName($estouroFolha[$i]->tags,'vltarire'); ?>
							</td>
							<td><span><? echo getByTagName($estouroFolha[$i]->tags,'vltotdeb'); ?></span>
									  <? echo getByTagName($estouroFolha[$i]->tags,'vltotdeb'); ?>
							</td>
							<td><span><? echo getByTagName($estouroFolha[$i]->tags,'vlestour'); ?></span>
									  <? echo getByTagName($estouroFolha[$i]->tags,'vlestour'); ?>
							</td>
						</tr>
					<? } ?>
			<? } ?>
			</tbody>
		</table>
	</div>
	<div id="divPesquisaRodape" class="divPesquisaRodape">
        <table>
            <tr>
                <td>
                    <?
                        if (isset($qtregist) and count($qtregist) == 0) $nriniseq = 0;
                        if ($nriniseq > 1) {
                            ?> <a class='paginacaoAnt'><<< Anterior</a> <?
                        } else {
                            ?> &nbsp; <?
                        }
                    ?>
                </td>
                <td>
                    <?
                        if ($nriniseq) {
                            ?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
                    <?  } ?>
                </td>
                <td>
                    <?
                        if ($qtregist > ($nriniseq + $nrregist - 1)) {
                            ?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
                        } else {
                            ?> &nbsp; <?
                        }
                    ?>
                </td>
            </tr>
        </table>
    </div>
</div>
<script type="text/javascript">
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();
</script>