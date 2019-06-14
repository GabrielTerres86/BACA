<? 
/*!
 * FONTE        : tabela_bens.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 15/09/2010 
 * OBJETIVO     : Tabela que apresenta os bens do titular selecionado
 * 
 * ALTERACOES   : 001: [05/09/2012] Mudar para layout padrao (Gabriel)
 				  002: [24/10/2018] Forçar pular tabela de bens (Bruno luiz K. - Mout's - PRJ 438)
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
			<a href="#" class="botao" id="btSalvar"  onClick="fechaBens(); return false;">Continuar</a>
		<?}else if ( $operacao == 'A_BENS_ASSOC' || 'A_BENS_TITULAR' ) { ?>
			<a href="#" class="botao" id="btSalvar"  onClick="<?php echo ($qtavalis == 2 && $nomeAcaoCall == 'A_AVALISTA' && $nrAvalistaSalvo < 2 ? 'gravaAvalista();' : 'fechaBens();'); ?> return false;">Continuar</a>
			<a href="#" class="botao" id="btAlterar" onClick="controlaOperacaoBens('BF'); return false;">Alterar</a>
			<a href="#" class="botao" id="btExcluir" onClick="controlaOperacaoBens('E'); return false;">Excluir</a>
			<a href="#" class="botao" id="btIncluir" onClick="controlaOperacaoBens('BI'); return false;">Incluir</a>
		<?}else {?>
			<a href="#" class="botao" id="btVoltar"  onClick="fechaBens(); return false;">Voltar</a>
			<a href="#" class="botao" id="btAlterar" onClick="controlaOperacaoBens('BF'); return false;">Alterar</a>
			<a href="#" class="botao" id="btExcluir" onClick="controlaOperacaoBens('E'); return false;">Excluir</a>
			<a href="#" class="botao" id="btIncluir" onClick="controlaOperacaoBens('BI'); return false;">Incluir</a>			
		<?}?>
	</div>
</div> 	

<script type='text/javascript'>
	<?php

		if($qtavalis == 2 && $nomeAcaoCall == 'A_AVALISTA' && $nrAvalistaSalvo < 2)
			echo 'gravaAvalista();';
		else
			echo "fechaBens();";

	?>
</script>