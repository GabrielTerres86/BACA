<?
/*!
 * FONTE        : tab_pagamento.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Maio/2015
 * OBJETIVO     : Tabela de Origens de Pagamento
 * --------------
 * ALTERAÇÕES   : 09/09/2015 - Retirada a opção N da coluna 'Permite varias no mês' (Vanessa)
 * --------------
 */
?>
<div id="tabPagamento" style="display:block">
	<table border="0" style="margin: 0px auto;">
		<tr>
			<td width="300px" align="right"><b>Hist&oacute;ricos p/ Empresas</b></td>
			<td width="170px" align="right"><b>Hist&oacute;ricos p/ Cooperativas</b></td>
		</tr>
	</table>
	<div class="divRegistros">
        <table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Origem');  ?></th>
					<th><? echo utf8ToHtml('Descri&ccedil;&atilde;o');  ?></th>
					<th><? echo utf8ToHtml('D&eacute;bito');  ?></th>
					<th><? echo utf8ToHtml('Cr&eacute;dito');  ?></th>
					<th><? echo utf8ToHtml('D&eacute;bito');  ?></th>
					<th><? echo utf8ToHtml('Cr&eacute;dito');  ?></th>
					<th><? echo utf8ToHtml('Permite<br /> varias no m&ecirc;s');  ?></th>
					<th><? echo utf8ToHtml('Verifica débitos vinc. a folha');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				if ( count($pagamento) == 0 ) {
					$i = 0;
					// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
					?> <tr>
							<td colspan="11" style="width: 80px; text-align: center;">
								<input type="hidden" id="conteudo" name="conteudo" value="<? echo $i; ?>" />
								<b>N&atilde;o foram encontrados registros de origens de pagamento.</b>
							</td>
						</tr>
				<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
				} else {
					for ($i = 0; $i < count($pagamento); $i++) {
					?>
						<tr>
							<td><input type="hidden" id="conteudo" name="conteudo" value="<? echo 1; ?>" />
							    <input type="hidden" id="indrowid" name="indrowid" value="<? echo getByTagName($pagamento[$i]->tags,'indrowid') ?>" />
								<input type="hidden" id="cdorigem" name="cdorigem" value="<? echo getByTagName($pagamento[$i]->tags,'cdorigem') ?>" />
								<input type="hidden" id="dsorigem" name="dsorigem" value="<? echo getByTagName($pagamento[$i]->tags,'dsorigem') ?>" />
								<input type="hidden" id="idvarmes" name="idvarmes" value="<? echo getByTagName($pagamento[$i]->tags,'idvarmes') ?>" />
								<input type="hidden" id="cdhisdeb" name="cdhisdeb" value="<? echo (getByTagName($pagamento[$i]->tags,'cdhisdeb')=="0") ? "" : getByTagName($pagamento[$i]->tags,'cdhisdeb')?>" />
								<input type="hidden" id="cdhiscre" name="cdhiscre" value="<? echo (getByTagName($pagamento[$i]->tags,'cdhiscre')=="0") ? "" : getByTagName($pagamento[$i]->tags,'cdhiscre')?>" />
								<input type="hidden" id="cdhsdbcp" name="cdhsdbcp" value="<? echo (getByTagName($pagamento[$i]->tags,'cdhsdbcp')=="0") ? "" : getByTagName($pagamento[$i]->tags,'cdhsdbcp')?>" />
								<input type="hidden" id="cdhscrcp" name="cdhscrcp" value="<? echo (getByTagName($pagamento[$i]->tags,'cdhscrcp')=="0") ? "" : getByTagName($pagamento[$i]->tags,'cdhscrcp')?>" />
								<input type="hidden" id="fldebfol" name="fldebfol" value="<? echo getByTagName($pagamento[$i]->tags,'fldebfol') ?>" />
							    <span><? echo getByTagName($pagamento[$i]->tags,'cdorigem'); ?></span>
									  <? echo getByTagName($pagamento[$i]->tags,'cdorigem'); ?>
							</td>
							<td><span><? echo getByTagName($pagamento[$i]->tags,'dsorigem'); ?></span>
									  <? echo getByTagName($pagamento[$i]->tags,'dsorigem'); ?>
							</td>
							<td><span><?  if (getByTagName($pagamento[$i]->tags,'cdhisdeb')=="0") {echo "-";} else {echo getByTagName($pagamento[$i]->tags,'cdhisdeb');} ?></span>
									  <?  if (getByTagName($pagamento[$i]->tags,'cdhisdeb')=="0") {echo "-";} else {echo getByTagName($pagamento[$i]->tags,'cdhisdeb');} ?>
							</td>
							<td><span><?  if (getByTagName($pagamento[$i]->tags,'cdhiscre')=="0") {echo "-";} else {echo getByTagName($pagamento[$i]->tags,'cdhiscre');} ?></span>
									  <?  if (getByTagName($pagamento[$i]->tags,'cdhiscre')=="0") {echo "-";} else {echo getByTagName($pagamento[$i]->tags,'cdhiscre');} ?>
							</td>
							<td><span><?  if (getByTagName($pagamento[$i]->tags,'cdhsdbcp')=="0") {echo "-";} else {echo getByTagName($pagamento[$i]->tags,'cdhsdbcp');} ?></span>
									  <?  if (getByTagName($pagamento[$i]->tags,'cdhsdbcp')=="0") {echo "-";} else {echo getByTagName($pagamento[$i]->tags,'cdhsdbcp');} ?>
							</td>
							<td><span><?  if (getByTagName($pagamento[$i]->tags,'cdhscrcp')=="0") {echo "-";} else {echo getByTagName($pagamento[$i]->tags,'cdhscrcp');} ?></span>
									  <?  if (getByTagName($pagamento[$i]->tags,'cdhscrcp')=="0") {echo "-";} else {echo getByTagName($pagamento[$i]->tags,'cdhscrcp');} ?>
							</td>
							<td><span><?  if (getByTagName($pagamento[$i]->tags,'idvarmes')=="S") { echo "Sim"; } else if(getByTagName($pagamento[$i]->tags,'idvarmes')=="A") { echo "Sim, mas com alerta"; }  ?></span>
									  <?  if (getByTagName($pagamento[$i]->tags,'idvarmes')=="S") { echo "Sim"; } else if(getByTagName($pagamento[$i]->tags,'idvarmes')=="A") { echo "Sim, mas com alerta"; } ?>
							</td>
							<td><span><? if (getByTagName($pagamento[$i]->tags,'fldebfol')=="S") { echo "Sim"; } else if(getByTagName($pagamento[$i]->tags,'fldebfol')=="N"){ echo "N&atilde;o"; } ?></span>
									  <? if (getByTagName($pagamento[$i]->tags,'fldebfol')=="S") { echo "Sim"; } else if(getByTagName($pagamento[$i]->tags,'fldebfol')=="N"){ echo "N&atilde;o"; } ?>
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