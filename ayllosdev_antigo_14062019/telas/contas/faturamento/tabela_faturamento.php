<? 
/*!
 * FONTE        : tabela_bens.php
 * CRIAÇÃO      : Rodolpho Telmo - DB1 Informatica
 * DATA CRIAÇÃO : 03/03/2010 
 * OBJETIVO     : Tabela que apresenda os bens do titular selecionado
 *
 * ALTERACOES   : 05/08/2015 - Reformulacao cadastral (Gabriel-RKAM)
 */
?>

<div class="divRegistros">
	<table>
		<thead>
			<tr><th><? echo utf8ToHtml(Mês);?></th>
				<th>Ano</th>
				<th>Faturamento</th></tr>			
		</thead>
		<tbody>
			<? foreach( $registros as $faturamento ) {
					if ( getByTagName($faturamento->tags,'mesftbru') != 0 && getByTagName($faturamento->tags,'anoftbru') != 0) {
			?>
				
				<tr><td><span><? echo getByTagName($faturamento->tags,'mesftbru') ?></span>
						<? echo getByTagName($faturamento->tags,'mesftbru') ?>						
						<input type="hidden" id="nrposext" name="nrposext" value="<? echo getByTagName($faturamento->tags,'nrposext') ?>" /></td>
					<td><? echo getByTagName($faturamento->tags,'anoftbru') ?></td>						
					<td><span><? echo str_replace(',','.',getByTagName($faturamento->tags,'vlrftbru')) ?></span>
						<? echo number_format(str_replace(',','.',getByTagName($faturamento->tags,'vlrftbru')),2,',','.') ?></td></tr>				
				<? } ?>
			 <?}?>			
		</tbody>
	</table>
</div>

<div class="divFinanc">
	<? $faturamento = $registros[0]->tags; ?>
	<label for="dtaltjfn">Alterado:</label>	
	<input name="dtaltjfn" id="dtaltjfn" type="text" value="<? echo getByTagName($faturamento,'dtaltjfn') ?>" />
	
	<label for="cdoperad">Operador:</label>
	<input name="cdoperad" id="cdoperad" type="text" value="<? echo getByTagName($faturamento,'cdoperad') ?>" />
	<input name="nmoperad" id="nmoperad" type="text" value="<? echo getByTagName($faturamento,'nmoperad') ?>" />
</div>

<div id="divBotoes">

	<? if ($flgcadas == 'M' ) { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="voltarRotina();" />
	<? } else { ?>
		<input type="image" id="btVoltar"  src="<? echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina(divRotina);"   />
	<? } ?>

	<input type="image" id="btAlterar" src="<? echo $UrlImagens; ?>botoes/alterar.gif" onClick="controlaOperacao('CA');" />
	<input type="image" id="btExcluir" src="<? echo $UrlImagens; ?>botoes/excluir.gif" onClick="controlaOperacao('CE');" />
	<input type="image" id="btIncluir" src="<? echo $UrlImagens; ?>botoes/incluir.gif" onClick="controlaOperacao('CI');" />	
	<input type="image" id="btContinuar"  src="<? echo $UrlImagens; ?>botoes/continuar.gif"  onClick="proximaRotina();"   />
	
</div>