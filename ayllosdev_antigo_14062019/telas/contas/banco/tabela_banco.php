<? 
/*!
 * FONTE        : tabela_bens.php
 * CRIAÇÃO      : Rodolpho Telmo - DB1 Informatica
 * DATA CRIAÇÃO : 03/03/2010 
 * OBJETIVO     : Tabela que apresenda os bens do titular selecionado
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [05/05/2010] Rodolpho Telmo (DB1) : Adaptação da tela ao "tableSorter"
 * 002: [05/08/2015] Gabriel (RKAM)       : Reformulacao Cadastral.
 */	
?>

<div class="divRegistros">
	<table>
		<thead>
			<tr><th>Banco</th>
				<th>Opera&ccedil;&atilde;o</th>
				<th>Valor (R$)</th>
				<th>Garantia</th>
				<th>Vencto.</th></tr>			
		</thead>
		<tbody>
			<? foreach( $registros as $banco ) {?>
				<tr><td><span><? echo getByTagName($banco->tags,'cddbanco') ?></span>
						<? echo getByTagName($banco->tags,'cddbanco') ?>
						<input type="hidden" id="nrdlinha" name="nrdlinha" value="<? echo getByTagName($banco->tags,'nrdlinha') ?>" /></td>
					<td><? echo stringTabela(getByTagName($banco->tags,'dstipope'),17,'maiuscula') ?></td>
					<td><span><? echo str_replace(',','.',getByTagName($banco->tags,'vlropera')) ?></span>
					    <? echo number_format(str_replace(',','.',getByTagName($banco->tags,'vlropera')),2,',','.') ?></td>
					<td><? echo stringTabela(getByTagName($banco->tags,'garantia'),17,'maiuscula') ?></td>
					<td><? echo getByTagName($banco->tags,'dsvencto') ?></td></tr>				
			<? } ?>			
		</tbody>		
	</table>
</div>

<div class="divFinanc">
	<? $banco = $registros[0]->tags; ?>
	<label for="dtaltjfn">Dados Banco => Alterado:</label>
	<input name="dtaltjfn" id="dtaltjfn" type="text" value="<? echo getByTagName($banco,'dtaltjfn') ?>" />
	
	<label for="cdoperad">Operador:</label>
	<input name="cdoperad" id="cdoperad" type="text" value="<? echo getByTagName($banco,'cdoperad') ?>" />
	<input name="nmoperad" id="nmoperad" type="text" value="<? echo getByTagName($banco,'nmoperad') ?>" />
</div>

<div id="divBotoes">
	<? if ($flgcadas == 'M' ) { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="voltarRotina();" />
	<? } else { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina(divRotina);" />
	<? } ?>
	<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif" onClick="controlaOperacao('TA')" />
	<input type="image" id="btExcluir" src="<? echo $UrlImagens; ?>botoes/excluir.gif" onClick="controlaOperacao('TE')" />
	<input type="image" id="btIncluir" src="<? echo $UrlImagens; ?>botoes/incluir.gif" onClick="controlaOperacao('TI')" />		
    <input type="image" id="btContinuar" src="<? echo $UrlImagens; ?>botoes/continuar.gif" onClick="proximaRotina();" />
</div>