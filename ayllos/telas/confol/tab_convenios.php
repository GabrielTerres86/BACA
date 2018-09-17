<? 
/*!
 * FONTE        : tab_convenios.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Maio/2015
 * OBJETIVO     : Tabela de Convenios Tarifados
 * --------------
 * ALTERAÇÕES   : 23/11/2015 - Ajustado colspan para exibir a linha quando não houver registros
                               (Andre Santos - SUPERO)
 * --------------
 */	
?>
<div id="tabConvenio" style="display:block">
	<div class="divRegistros">
        <table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Conv&ecirc;nio');  ?></th>
					<th><? echo utf8ToHtml('Descri&ccedil;&atilde;o');  ?></th>
					<th><? echo utf8ToHtml('D0');   ?></th>
					<th><? echo utf8ToHtml('D-1');  ?></th>
					<th><? echo utf8ToHtml('D-2');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				if ( count($convenios)-1 == 0 ) {
					$i = 0;
					// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
					?> <tr>
							<td colspan="6">
								<input type="hidden" id="conteudo" name="conteudo" value="<? echo $i; ?>" />
								<b>N&atilde;o h&aacute; registros de conv&ecirc;nios tarif&aacute;rios cadastrados.</b>
							</td>
						</tr>							
				<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
				} else {
					for ($i = 1; $i < count($convenios); $i++) {
					?>
						<tr>
							<td><input type="hidden" id="conteudo" name="conteudo" value="<? echo 1; ?>" />
							    <input type="hidden" id="indrowid" name="indrowid" value="<? echo getByTagName($convenios[$i]->tags,'indrowid') ?>" />
								<input type="hidden" id="cdcontar" name="cdcontar" value="<? echo getByTagName($convenios[$i]->tags,'cdcontar') ?>" />
								<input type="hidden" id="dscontar" name="dscontar" value="<? echo getByTagName($convenios[$i]->tags,'dscontar') ?>" />
								<input type="hidden" id="vltarid0" name="vltarid0" value="<? echo getByTagName($convenios[$i]->tags,'vltarid0') ?>" />
								<input type="hidden" id="vltarid1" name="vltarid1" value="<? echo getByTagName($convenios[$i]->tags,'vltarid1') ?>" />
								<input type="hidden" id="vltarid2" name="vltarid2" value="<? echo getByTagName($convenios[$i]->tags,'vltarid2') ?>" />
							    <span><? echo getByTagName($convenios[$i]->tags,'cdcontar'); ?></span>
									  <? echo getByTagName($convenios[$i]->tags,'cdcontar'); ?>
							</td>
							<td><span><? echo getByTagName($convenios[$i]->tags,'dscontar'); ?></span>
									  <? echo getByTagName($convenios[$i]->tags,'dscontar'); ?>
							</td>
							<td><span><? echo getByTagName($convenios[$i]->tags,'vltarid0'); ?></span>
									  <? echo getByTagName($convenios[$i]->tags,'vltarid0'); ?>
							</td>
							<td><span><? echo getByTagName($convenios[$i]->tags,'vltarid1'); ?></span>
									  <? echo getByTagName($convenios[$i]->tags,'vltarid1'); ?>
							</td>
							<td><span><? echo getByTagName($convenios[$i]->tags,'vltarid2'); ?></span>
									  <? echo getByTagName($convenios[$i]->tags,'vltarid2'); ?>
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