<?
/*!
 * FONTE        	: tabela_cadidr.php
 * CRIA��O      	: Lucas Reinert
 * DATA CRIA��O 	: Fevereiro/2016
 * OBJETIVO     	: Form da tela CADIDR
 * �LTIMA ALTERA��O : --/--/----
 * --------------
 * ALTERA��ES   	: 
 * --------------
 */ 
?>

<div class="divRegistros" >
	<table class="tituloRegistros" style="table-layout: fixed;">
		<thead>
			<tr><th>Indicador</th>
				<th>&nbsp;</th>
				<th>Tipo</th>
				<th>Produto</th>
				<th>Tipo Pessoa</th>
				<th>Valor M&iacute;nimo</th>
				<th>Valor M&aacute;ximo</th>
				<th>% Score</th>
				<th>% Toler&acirc;ncia</th>
			</tr>			
		</thead>
		<tbody>
			<?php
			foreach($registros as $indicador) {
				// Recebo todos valores em vari�veis
				$idindicador = getByTagName($indicador->tags,'idindicador');
				$nmindicador = getByTagName($indicador->tags,'nmindicador');
				$tpindicador = getByTagName($indicador->tags,'tpindicador');				
				$cdproduto = getByTagName($indicador->tags,'cdproduto');
				$dsproduto = utf8ToHtml(getByTagName($indicador->tags,'dsproduto'));
				$inpessoa = getByTagName($indicador->tags,'inpessoa');
				$inpessoa2 = getByTagName($indicador->tags,'inpessoa2');
				$vlminimo = getByTagName($indicador->tags,'vlminimo');
				$vlmaximo = getByTagName($indicador->tags,'vlmaximo');
				$perscore = getByTagName($indicador->tags,'perscore');
				$pertolera = getByTagName($indicador->tags,'pertolera');
				$perpeso = getByTagName($indicador->tags,'vlpercentual_peso');
				$perdesc = getByTagName($indicador->tags,'vlpercentual_desconto');
				
			?>
			<tr>			
				<td width="60"><?php echo $idindicador;?></td>
				<td width="241"><?php echo $nmindicador;?></td>
				<td width="65"><?php echo $tpindicador;?></td>		
				<td width="135"><?php echo $dsproduto;?></td>
				<td width="54"><?php echo $inpessoa;?></td>
				<td width="60"><?php echo $vlminimo;?></td>
				<td width="60"><?php echo $vlmaximo;?></td>
				<td width="50"><?php echo $perscore;?></td>
				<td><?php echo $pertolera;?>
					<input type="hidden" id="idindicador" value="<? echo $idindicador; ?>" />
					<input type="hidden" id="nmindicador" value="<? echo $nmindicador; ?>" />
					<input type="hidden" id="tpindicador" value="<? echo $tpindicador; ?>" />
					<input type="hidden" id="cdproduto" value="<? echo $cdproduto; ?>" />
					<input type="hidden" id="dsproduto" value="<? echo $dsproduto; ?>" />
					<input type="hidden" id="inpessoa" value="<? echo $inpessoa; ?>" />
					<input type="hidden" id="inpessoa2" value="<? echo $inpessoa2; ?>" />
					<input type="hidden" id="vlminimo" value="<? echo $vlminimo; ?>" />
					<input type="hidden" id="vlmaximo" value="<? echo $vlmaximo; ?>" />
					<input type="hidden" id="perscore" value="<? echo $perscore; ?>" />
					<input type="hidden" id="pertolera" value="<? echo $pertolera; ?>" />
					<input type="hidden" id="perpeso" value="<? echo $perpeso; ?>" />
					<input type="hidden" id="perdesc" value="<? echo $perdesc; ?>" /></td>
			</tr>
			<?php 
			}
			?>			
		</tbody>		
	</table>	
</div>