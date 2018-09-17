<? 
/*!
 * FONTE        : form_consulta_dados.php
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : Junho/2013 
 * OBJETIVO     : Tabela com os dados do BLOQUEIO
 * --------------
 * ALTERAÇÕES   : 16/09/2014 - Adicionado coluna 'Bloq.' (Jorge/Gielow - SD 175038).
				: 29/09/2017 - Melhoria 460 (Andrey Formigari - Mouts)
 * --------------
 */	
 ?>
 
<form id="frmConsultaDados" class="formulario" name="frmConsultaDados">
	<fieldset>
		<legend>Filtro</legend>
		<div class="divRegistros">
			<table>
				<thead>
				<tr><th>Conta/dv</th>
					<th>CPF/CNPJ</th>
					<th>Modalidade</th>
					<th>Valor</th>
					<th>Bloq.</th>
					<th>Hr Bloq.</th>
					<th>Hr Desb.</th>
				</tr>			
				</thead>
				<tbody> 
					<? 
						$seq = 0;
						foreach( $dados as $banco) { 
						$mtdClick = "selecionaBloqueio('".$seq."', ".getByTagName($banco->tags,'IDMODALI').");";
					?>
						<tr class="tr_oficio ofi_<?=preg_replace("/[^0-9]/", "", getByTagName($banco->tags,'NMROFICI'))?>_<?php echo getByTagName($banco->tags,'NRDCONTA'); ?>" onclick= "<? echo $mtdClick; ?>" onFocus="<? echo $mtdClick; ?>"> 
							<td style="width: 79px;" id="nrdconta" ><span><?php echo formataContaDV(getByTagName($banco->tags,'NRDCONTA')); ?></span>
								<?php echo formataContaDV(getByTagName($banco->tags,'NRDCONTA')); ?>
							</td>
							<td style="width: 115px;" id="nrcpfcgc"  ><span><?php echo getByTagName($banco->tags,'DSCPFCGC'); ?></span>
								<?php echo getByTagName($banco->tags,'DSCPFCGC'); ?>
							</td>
							<td style="width: 124px;" id="dsmodali" ><span><?php echo getByTagName($banco->tags,'DSMODALI'); ?></span>
								<?php echo getByTagName($banco->tags,'DSMODALI'); ?>
							</td>
							<td style="width: 60px;" id="vlbloque" ><span><?php echo number_format(str_replace(",",".",getByTagName($banco->tags,'VLBLOQUE')),2,",","."); ?></span>
								<?php echo number_format(str_replace(",",".",getByTagName($banco->tags,'VLBLOQUE')),2,",","."); ?>
							</td>		
							<td style="width: 44px;" id="dsbloque" ><span><?php echo getByTagName($banco->tags,'DTBLQFIM'); ?></span>
								<?php echo getByTagName($banco->tags,'DTBLQFIM') != '' ? "N&atilde;o" : "Sim"; ?>
							</td>
							<td style="width: 46px" id="hrblqini">
								<span><?php echo ((!getByTagName($banco->tags,'DSBLQINI')) ? "" : getByTagName($banco->tags,'DSBLQINI')); ?></span>
								<?php echo ((!getByTagName($banco->tags,'DSBLQINI')) ? "<div style='visibility: hidden;'>00:00</div>" : getByTagName($banco->tags,'DSBLQINI')); ?>
							</td>
							<td id="hrblqfim">
								<span><?php echo ((!getByTagName($banco->tags,'DSBLQFIM')) ? "" : getByTagName($banco->tags,'DSBLQFIM')); ?></span>
								<?php echo ((!getByTagName($banco->tags,'DSBLQFIM')) ? "<div style='visibility: hidden;'>00:00</div>" : getByTagName($banco->tags,'DSBLQFIM')); ?>
							</td>
						</tr>												
					<?  $seq = $seq + 1;
						} ?>			
				</tbody>		
			</table>
		</div>
	</fieldset>
</form>