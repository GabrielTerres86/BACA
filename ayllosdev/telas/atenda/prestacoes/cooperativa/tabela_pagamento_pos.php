<?
/*!
 * FONTE        : tabela_pagamento_pos.php
 * CRIACAO      : Jaison Fernando
 * DATA CRIACAO : 19/07/2017
 * OBJETIVO     : Tabela que apresenta as parcelas para antecipar o pagamento

   ALTERACOES   : 
 */
?>
<div id="divVlPagar "align="right">
	<form id="frmVlPagar" name="frmVlPagar">
		<label for="vlpagmto"><!--Valor a Pagar:-->&nbsp;</label><input type="hidden" id="vlpagmto" name="vlpagmto"/></br>
	</form>
</div>
<div id="divTabela">
	<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th> <input type="checkbox" id="'checkTodos" name="checkTodos"> </th>
    				<th><label for="nrparepr" class="txtNormalBold">Nr. Parc.</label></th>
					<th><label for="dtvencto" class="txtNormalBold">Dt. Venc.</label></th>
					<th><label for="vlparepr" class="txtNormalBold">Vl. Parc.</label></th>
					<th><label for="vlpagpar" class="txtNormalBold">Vl. Pago</label></th>
					<th><label for="vlmtapar" class="txtNormalBold">Multa</label></th>
					<th><label for="vlmrapar" class="txtNormalBold">Jr. Mora</label></th>
					<th><label for="vldespar" class="txtNormalBold">Desc.</label></th>
					<th><label for="vlatupar" class="txtNormalBold">Vl. Atual</label></th>
					<th style="width:96px;"><label for="vlpagpar" class="txtNormalBold" >Vl. a Pagar</label></th>
				</tr>
			</thead>
			<tbody>
				<?
					$parcela = 1;
					foreach($registros as $registro ) {

						$nrparepr = getByTagName($registro->tags,'nrparepr');
                        $dtvencto = getByTagName($registro->tags,'dtvencto');
						$vlparepr = getByTagName($registro->tags,'vlparepr');
                        $vlpagpar = getByTagName($registro->tags,'vlpagpar');
                        $vlmtapar = getByTagName($registro->tags,'vlmtapar');
                        $vlmrapar = getByTagName($registro->tags,'vlmrapar');
                        $vldescto = getByTagName($registro->tags,'vldescto');
						$vlatupar = getByTagName($registro->tags,'vlatupar');
						$insitpar = getByTagName($registro->tags,'insitpar'); // (1 - Em dia, 2 - Vencida, 3 - A Vencer)
				?>
					<tr>
						<td>
                            <?php
                                // Se NAO for antecipacao exibe campo de selecao
                                if ($insitpar <> 3) {
                                    ?><input type="checkbox" id="check_<? echo $nrparepr; ?>" vldescto="<? echo $vldescto; ?>" name="checkParcelas[]" /><?php
                                }
                            ?>
                        </td>
						<td><? echo $nrparepr; ?></td>
						<td><? echo $dtvencto; ?></td>
						<td><? echo $vlparepr; ?></td>
						<td><? echo $vlpagpar; ?></td>
						<td><? echo $vlmtapar; ?></td>
						<td><? echo $vlmrapar; ?></td>
						<td id="vldespar_<? echo $nrparepr; ?>">0,00</td>
						<td><? echo $vlatupar; ?></td>
						<td style="width:70px;"><input type="text" id="vlpagpar_<? echo $nrparepr; ?>" name="vlpagpar[]" size="10" onblur="verificaDescontoPos($(this),'<? echo $insitpar; ?>','<? echo $nrparepr; ?>','<? echo $dtvencto; ?>'); return false;" value="0,00" />
						<td style="width:10px;"><input type="image" id="btDesconto" src="<?php echo $UrlImagens; ?>geral/refresh.png" onClick="descontoPos('<? echo $nrparepr ?>','<? echo $vldescto; ?>'); return false;" /></td>

						<input type="hidden" id="vlmtapar_<? echo $nrparepr; ?>" name="vlmtapar[]" value="<? echo $vlmtapar; ?>">
						<input type="hidden" id="vlmrapar_<? echo $nrparepr; ?>" name="vlmrapar[]" value="<? echo $vlmrapar; ?>">
						<input type="hidden" id="vlatupar_<? echo $nrparepr; ?>" name="vlatupar[]" value="<? echo $vlatupar; ?>">
						<input type="hidden" id="cdcooper_<? echo $nrparepr; ?>" name="cdcooper[]" value="<? echo $glbvars["cdcooper"]; ?>">
						<input type="hidden" id="nrdconta_<? echo $nrparepr; ?>" name="nrdconta[]" value="<? echo $nrdconta; ?>">
						<input type="hidden" id="nrctremp_<? echo $nrparepr; ?>" name="nrctremp[]" value="<? echo $nrctremp; ?>">
						<input type="hidden" id="nrparepr_<? echo $nrparepr; ?>" name="nrparepr[]" value="<? echo $nrparepr; ?>">
						<input type="hidden" id="parcela_<?  echo $parcela ?>" name="parcela[]" value="<? echo $nrparepr; ?>">
						<input type="hidden" id="dtvencto_<? echo $nrparepr ?>" name="dtvencto[]" value="<? echo $dtvencto; ?>">
						<input type="hidden" id="vlpagan_<?  echo $nrparepr ?>" name="vlpagan[]" value="0,00">

					</td>
					</tr>
				<?
					$parcela++;
					}
				?>
			</tbody>
		</table>
	</div>
</div>
<div id="divVlParc " align="left" >
	<form id="frmVlParc" name="frmVlParc" >
		<label for="totatual">Total Valor Atual:</label><input type="text" id="totatual" name="totatual" value="" />
		<label for="totpagto">Total a Pagar:</label><input type="text" id="totpagto" name="totpagto"/><br /><br />
		<label for="pagtaval">Pagamento Aval:&nbsp;</label><input type="checkbox" name="pagtaval" id="pagtaval" />
	</form>
</div>
<div id="divBotoes">
	<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"    onClick="controlaOperacao(''); return false;" />
	<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="validaPagamentoPos(); return false;" />
</div>
<form class="formulario" id="frmAntecipapgto">
  <input type="hidden" id="glbdtmvtolt" name="glbdtmvtolt" value="<? echo $glbvars["dtmvtolt"] ?>" />
</form>
