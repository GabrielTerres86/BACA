<?
/*!
 * FONTE        	: tabela_vinculacoes.php
 * CRIAÇÃO      	: André Clemer - Supero
 * DATA CRIAÇÃO 	: Agosto/2018
 * OBJETIVO     	: Form da tela CADIDR
 * ÚLTIMA ALTERAÇÃO : --/--/----
 * --------------
 * ALTERAÇÕES   	: 
 * --------------
 */ 
?>

<div class="divRegistros" >
	<table class="tituloRegistros" style="table-layout: fixed;">
		<thead>
			<tr><th>C&oacute;digo</th>
				<th>Vincula&ccedil;&atilde;o</th>
				<th>Ativo</th>
				<th>&nbsp;</th>
			</tr>			
		</thead>
		<tbody>
			<?php
			foreach($registros as $indicador) {
				// Recebo todos valores em variáveis
				$idvinculacao = getByTagName($indicador->tags,'idvinculacao');
				$nmvinculacao = getByTagName($indicador->tags,'nmvinculacao');
				$flgativo = getByTagName($indicador->tags,'flgativo');
			?>
			<tr>
				<td width="50"><?php echo $idvinculacao;?></td>
				<td width="320"><?php echo $nmvinculacao;?></td>
				<td width="50"><?php echo $flgativo;?></td>
				<td>&nbsp;</td>
				<td style="display:none">
					<input type="hidden" id="idvinculacao" value="<? echo $idvinculacao ?>" />
					<input type="hidden" id="nmvinculacao" value="<? echo $nmvinculacao ?>" />
					<input type="hidden" id="flgativo" value="<? echo ($flgativo == 'Sim') ? '1' : '0'; ?>" />
				</td>
			</tr>
			<?php 
			}
			?>			
		</tbody>		
	</table>	
</div>
