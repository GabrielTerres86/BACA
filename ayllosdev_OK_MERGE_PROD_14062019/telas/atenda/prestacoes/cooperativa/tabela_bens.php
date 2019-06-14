<? 
/*!
 * FONTE        : tabela_bens.php
 * CRIAÇÃO      : André Socoloski - DB1
 * DATA CRIAÇÃO : 29/03/2011 
 * OBJETIVO     : Tabela que apresenta os bens do titular selecionado
 */	
?>

<div id="divProcBensTabela">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th>Descri&ccedil;&atilde;o do Bem</th>
					<th>% sem &Ocirc;nus </th>
					<th>Nr. Parc.</th>
					<th>Vl. Parcela</th>
					<th>Vl. Bem</th>
				</tr>			
			</thead>
			<tbody>
				<!--Monta tabela dinamicamente-->
			</tbody>
		</table>
	</div>	
	<div id="divBotoes">
		<? if ( $operacao == 'C_BENS_ASSOC' ) { ?>
			<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"    onClick="controlaOperacao('C_NOVA_PROP_V'); return false;" />
			<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="fechaBens(); return false;" />
		<?}?>
	</div>
</div> 	