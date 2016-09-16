<? 
/*!
 * FONTE        : tabela_bens.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 15/09/2010 
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
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaBens();return false;" />
		<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif" onClick="controlaOperacaoBens('BF');" />
		<input type="image" id="btExcluir" src="<? echo $UrlImagens; ?>botoes/excluir.gif" onClick="controlaOperacaoBens('E');" />
		<input type="image" id="btIncluir" src="<? echo $UrlImagens; ?>botoes/incluir.gif" onClick="controlaOperacaoBens('BI');" />			
	</div>
</div> 	