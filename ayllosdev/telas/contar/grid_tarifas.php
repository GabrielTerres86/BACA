<div class="divRegistros">
	<table class="tituloRegistros">
		<thead>
			<?php
			// cobranca
			if ($cddgrupo == 3) {
			?>
			<tr><th>Grupo</th>
				<th>C&oacute;digo</th>
				<th>Descri&ccedil;&atilde;o</th>
				<th>Conv&ecirc;nio</th>
				<th>Sit.Conv.</th>
				<th>Hist&oacute;rico</th>
				<th>Dt. Vig&ecirc;ncia</th>
				<th>Valor Inicial</th>
				<th>Valor Final</th>				
				<th>Valor</th>
				<th>Perc</th>				
				<th>Vlr. M&iacute;n.</th>
				<th>Vlr. M&aacute;x.</th>
			</tr>
			<?php
			} else {
			?>
			<tr><th>Grupo</th>
				<th>C&oacute;digo</th>
				<th>Descri&ccedil;&atilde;o</th>
				<th>Hist&oacute;rico</th>
				<th>Dt. Vig&ecirc;ncia</th>
				<th>Valor Inicial</th>
				<th>Valor Final</th>				
				<th>Valor</th>
				<th>Perc</th>				
				<th>Vlr. M&iacute;n.</th>
				<th>Vlr. M&aacute;x.</th>
			</tr>
			<?php } ?>
		</thead>
		<tbody>
			<?php
            foreach ($registros as $r) {
                $rDsdgrupo  = getByTagName($r->tags,"dsdgrupo");
                $rCdtarifa  = getByTagName($r->tags,"cdtarifa");
                $rDstarifa  = getByTagName($r->tags,"dstarifa");
                $rDshistor  = getByTagName($r->tags,"dshistor");
                $rDtvigenc  = getByTagName($r->tags,"dtvigenc");
                $rVltarifa  = getByTagName($r->tags,"vltarifa");
                $rCdoperad  = getByTagName($r->tags,"cdoperad");
				$rVlinifvl  = getByTagName($r->tags,"vlinifvl");
				$rVlfinfvl  = getByTagName($r->tags,"vlfinfvl");
				$rVlpertar  = getByTagName($r->tags,"vlpertar");
                $rVlmintar  = getByTagName($r->tags,"vlmintar");
                $rVlmaxtar  = getByTagName($r->tags,"vlmaxtar");

				// cobranca
				$rNrconven  = getByTagName($r->tags,"nrconven");
                $rFlgativo  = getByTagName($r->tags,"flgativo");

				// cobranca
				if ($cddgrupo == 3) {
				?>
				<tr>
					<td width="110"><?php echo $rDsdgrupo; ?></td>
					<td width="50"><?php echo $rCdtarifa; ?></td>
					<td width="185"><?php echo $rDstarifa; ?></td>
					<td width="60"><?php echo $rNrconven; ?></td>
					<td width="50"><?php echo ( ( $rFlgativo ) ? 'Ativo' : 'Inativo' ); ?></td>
					<td width="145"><?php echo $rDshistor; ?></td>
					<td width="60"><?php echo $rDtvigenc; ?></td>
					<td width="60"><?php echo $rVlinifvl; ?></td>
					<td width="80"><?php echo $rVlfinfvl; ?></td>
					<td width="35"><?php echo $rVltarifa; ?></td>
					<td width="35"><?php echo $rVlpertar; ?></td>
					<td width="40"><?php echo $rVlmintar; ?></td>
					<td><?php echo $rVlmaxtar; ?></td>
				</tr>
				<?php
					} else {
				?>
				<tr>
					<td width="120"><?php echo $rDsdgrupo; ?></td>
					<td width="50"><?php echo $rCdtarifa; ?></td>
					<td width="200"><?php echo $rDstarifa; ?></td>
					<td width="160"><?php echo $rDshistor; ?></td>
					<td width="70"><?php echo $rDtvigenc; ?></td>
					<td width="65"><?php echo $rVlinifvl; ?></td>
					<td width="80"><?php echo $rVlfinfvl; ?></td>
					<td width="60"><?php echo $rVltarifa; ?></td>
					<td width="50"><?php echo $rVlpertar; ?></td>
					<td width="55"><?php echo $rVlmintar; ?></td>
					<td><?php echo $rVlmaxtar; ?></td>
				</tr>
				<?php
            	}
            }
            ?>
		</tbody>
	</table>
	<hr style="background-color:#666; height:1px;" />
</div>
<div id="divPesquisaRodape" class="divPesquisaRodape">
	<table>
		<tr>
			<td>
				<?
					// Se a paginacao nao esta na primeira, exibe botao voltar
					if ($nriniseq > 1) {
						?> <a onclick="grid.carregar('<?php echo $nrregist; ?>', '<?php echo ($nriniseq - $nrregist); ?>'); return false;"><<< Anterior</a> <? 
					} else {
						?> &nbsp; <?
					}
				?>
			</td>
			<td>
				Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
			</td>
			<td>
				<?
					// Se a paginacao nao esta na ultima pagina, exibe botao proximo
					if ($qtregist > ($nriniseq + $nrregist - 1)) {
						?> <a onclick="grid.carregar('<?php echo $nrregist; ?>', '<?php echo ($nriniseq + $nrregist); ?>'); return false;">Pr&oacute;ximo >>></a> <?
					} else { 
						?> &nbsp; <?
					}
				?>			
			</td>
		</tr>
	</table>
</div>
<div id="divBotoes" style="margin-bottom: 10px;">
	<a href="#" class="botao" id="btVoltar" onclick="grid.onClick_Voltar(); return false;">Voltar</a>
</div>
<script>
	hideMsgAguardo();
</script>