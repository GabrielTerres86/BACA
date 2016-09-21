<? 
/*!
 * FONTE        : form_consulta_dados.php
 * CRIAÇÃO      : Lucas R.
 * DATA CRIAÇÃO : Junho/2013 
 * OBJETIVO     : Tabela com os dados do BLOQUEIO
 * --------------
 * ALTERAÇÕES   : 16/09/2014 - Adicionado coluna 'Bloq.' (Jorge/Gielow - SD 175038).
 * --------------
 */	
 ?>
 
<form id="frmConsultaDados" class="frmConsultaDados" name="frmConsultaDados">
<div class="divRegistros" >

   	<table>
		<thead>
		<tr><th>Conta/dv</th>
			<th>CPF/CNPJ</th>
			<th>Modalidade</th>
			<th>Valor</th>
			<th>Bloq.</th>
		</tr>			
		</thead>
		<tbody> 
			<? 
				$seq = 0;
				foreach( $dados as $banco) { 
				$mtdClick = "selecionaBloqueio('".$seq."');";
			?>
			    <tr onclick= "<? echo $mtdClick; ?>" onFocus="<? echo $mtdClick; ?>"> 
					<td id="nrdconta" ><span><?php echo formataContaDV(getByTagName($banco->tags,'NRDCONTA')); ?></span>
							<?php echo formataContaDV(getByTagName($banco->tags,'NRDCONTA')); ?>
					</td>
					<td id="nrcpfcgc"  ><span><?php echo getByTagName($banco->tags,'DSCPFCGC'); ?></span>
							<?php echo getByTagName($banco->tags,'DSCPFCGC'); ?>
					</td>
					<td id="dsmodali" ><span><?php echo getByTagName($banco->tags,'DSMODALI'); ?></span>
							<?php echo getByTagName($banco->tags,'DSMODALI'); ?>
					</td>
					<td id="vlbloque" ><span><?php echo number_format(str_replace(",",".",getByTagName($banco->tags,'VLBLOQUE')),2,",","."); ?></span>
							<?php echo number_format(str_replace(",",".",getByTagName($banco->tags,'VLBLOQUE')),2,",","."); ?>
					</td>		
					<td id="dsbloque" ><span><?php echo getByTagName($banco->tags,'DTBLQFIM'); ?></span>
							<?php echo getByTagName($banco->tags,'DTBLQFIM') != '' ? "N&atilde;o" : "Sim"; ?>
					</td>
				</tr>												
     	    <?  $seq = $seq + 1;
				} ?>			
		</tbody>		
	</table>
  </fieldset>
</form>
