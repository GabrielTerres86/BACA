<? 
/*!
 * FONTE        : tab_faturamento.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 23/04/2011 
 * OBJETIVO     : Tabela que apresenta os faturamentos
 *
 * ALTERACOES   : 001: [05/09/2012] Mudar para layout padrao (Gabriel) 
 */	
?>

<div id="divTabFaturamento">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr><th><? echo utf8ToHtml(Mês);?></th>
				<th>Ano</th>
				<th>Faturamento</th></tr>
			</thead>
			<tbody>
				<!--Monta tabela dinamicamente-->
			</tbody>
		</table>
	</div>	
	<div id="divBotoes">
		<? if ( $operacao == 'C_BENS_ASSOC' ) { ?>
			<a href="#" class="botao" id="btContinuar" onClick="fechaFaturamentos(); return false;">Continuar</a>
		<?}else if ( $operacao == 'A_BENS_ASSOC' ) { ?>
			<a href="#" class="botao" id="btContinuar" onClick="fechaFaturamentos(''); return false;">Continuar</a>
			<a href="#" class="botao" id="btAlterar"   onClick="controlaOperacaoFat('BF'); return false;">Alterar</a>
			<a href="#" class="botao" id="btExcluir"   onClick="controlaOperacaoFat('E'); return false;">Excluir</a>
			<a href="#" class="botao" id="btIncluir"   onClick="controlaOperacaoFat('BI'); return false;">Incluir</a>			
		<?}else{?>
			<a href="#" class="botao" id="btVoltar"  onClick="calculaMediaFat();fechaFaturamentos();return false;">Voltar</a>
			<a href="#" class="botao" id="btAlterar" onClick="controlaOperacaoFat('BF');">Alterar</a>
			<a href="#" class="botao" id="btExcluir" onClick="controlaOperacaoFat('E');">Excluir</a>
			<a href="#" class="botao" id="btIncluir" onClick="controlaOperacaoFat('BI');">Incluir</a>
		<?}?>
	</div>
</div> 	