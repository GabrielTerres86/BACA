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
			<tr><th>C&oacute;digo</th>
				<th>Indicador</th>
				<th>Ativo</th>
				<th>Tipo</th>
			</tr>			
		</thead>
		<tbody>
			<?php
			foreach($registros as $indicador) {
				// Recebo todos valores em vari�veis
				$idindicador = getByTagName($indicador->tags,'idindicador');
				$nmindicador = getByTagName($indicador->tags,'nmindicador');
				$dsindicador = getByTagName($indicador->tags,'dsindicador');
				$flgativo = getByTagName($indicador->tags,'flgativo');
				$tpindicador = getByTagName($indicador->tags,'tpindicador');				
				
			?>
			<tr>				
				<td width="50"><?php echo $idindicador;?></td>
				<td width="320"><?php echo $nmindicador;?></td>
				<td width="50"><?php echo $flgativo;?></td>
				<td><?php echo $tpindicador;?></td>				
				<td style="display:none">
					<input type="hidden" id="dsindicador" value="<? echo $dsindicador ?>" />
					<input type="hidden" id="idindicador" value="<? echo $idindicador ?>" />
					<input type="hidden" id="nmindicador" value="<? echo $nmindicador ?>" />
					<input type="hidden" id="flgativo" value="<? echo ($flgativo == 'Sim') ? '1' : '0'; ?>" />
					<input type="hidden" id="tpindicador" value="<? echo $tpindicador ?>" />
				</td>
			</tr>
			<?php 
			}
			?>			
		</tbody>		
	</table>	
</div>

<div id="divDescIndica">
	<table>
		<tr>
			<td style="padding-bottom: 60px;" ><label for="dsindica" class="rotulo txtNormalBold">Descri&ccedil;&atilde;o:</label></td>
			<td colspan="3" align="left">			
				<textarea name="dsindica" id="dsindica" maxlength="400" class="campo" style="width: 494px; height: 80px; margin-left: 3px; margin-top: 10px; margin-bottom: 10px;" disabled ></textarea>
			</td>
		</tr>
	</table>
</div>
