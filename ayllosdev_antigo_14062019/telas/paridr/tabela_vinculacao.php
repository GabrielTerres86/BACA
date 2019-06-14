<?
/*!
 * FONTE        	: tabela_vinculacao.php
 * CRIAÇÃO      	: André Clemer - Supero
 * DATA CRIAÇÃO 	: Agosto/2018
 * OBJETIVO     	: Tabela de vinculações da tela CADIDR
 * ÚLTIMA ALTERAÇÃO : --/--/----
 * --------------
 * ALTERAÇÕES   	: 
 * --------------
 */ 
?>
<div class="divRegistros" >
	<table class="tituloRegistros" style="table-layout: fixed;">
		<thead>
			<tr><th>Vincula&ccedil;&atilde;o</th>
				<th>&nbsp;</th>
				<th>Produto</th>
				<th>Tipo Pessoa</th>
				<th>% Peso</th>
				<th>% Desconto</th>
			</tr>
		</thead>
		<tbody>
			<?php
			foreach($registros as $vinculacao) {
				// Recebo todos valores em variáveis
				$idvinculacao = getByTagName($vinculacao->tags,'idvinculacao');
				$nmvinculacao = getByTagName($vinculacao->tags,'nmvinculacao');
				$cdproduto = getByTagName($vinculacao->tags,'cdproduto');
				$dsproduto = utf8ToHtml(getByTagName($vinculacao->tags,'dsproduto'));
				$inpessoa = getByTagName($vinculacao->tags,'inpessoa');
				$inpessoa2 = getByTagName($vinculacao->tags,'inpessoa2');
				$perpeso = getByTagName($vinculacao->tags,'vlpercentual_peso');
				$perdesc = getByTagName($vinculacao->tags,'vlpercentual_desconto');
			?>
			<tr>
				<td width="90"><?php echo $idvinculacao;?></td>
				<td width="165"><?php echo $nmvinculacao;?></td>
				<td width="235"><?php echo $dsproduto;?></td>
				<td width="145"><?php echo $inpessoa;?></td>
				<td width="90"><?php echo $perpeso;?></td>
				<td><?php echo $perdesc;?>
					<input type="hidden" id="idvinculacao" value="<? echo $idvinculacao; ?>" />
					<input type="hidden" id="nmvinculacao" value="<? echo $nmvinculacao; ?>" />
					<input type="hidden" id="cdproduto" value="<? echo $cdproduto; ?>" />
					<input type="hidden" id="dsproduto" value="<? echo $dsproduto; ?>" />
					<input type="hidden" id="inpessoa" value="<? echo $inpessoa; ?>" />
					<input type="hidden" id="inpessoa2" value="<? echo $inpessoa2; ?>" />
					<input type="hidden" id="perpeso" value="<? echo $perpeso; ?>" />
					<input type="hidden" id="perdesc" value="<? echo $perdesc; ?>" /></td>
			</tr>
			<?php 
			}
			?>
		</tbody>		
	</table>	
</div>