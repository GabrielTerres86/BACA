<? 
/*!
 * FONTE        : formulario_faturamento.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 23/04/2010 
 * OBJETIVO     : Forumlário de dados de Faturamento para alteracao
 */	
?>	
<? $faturamento = $registros[0]->tags; ?>
<form name="frmDadosFaturamento" id="frmDadosFaturamento" class="formulario" >
	<label for="mesftbru"><? echo utf8ToHtml(Mês);?></label>
	<input name="mesftbru" id="mesftbru" type="text" value="<? echo getByTagName($faturamento,'mesftbru'); ?>" />
	<br />
	
	<label for="anoftbru">Ano:</label>
	<input name="anoftbru" id="anoftbru" type="text" value="<? echo getByTagName($faturamento,'anoftbru'); ?>" />
	<br />
	
	<label for="vlrftbru">Faturamento :</label>
	<input name="vlrftbru" id="vlrftbru" type="text" value="<? echo number_format(str_replace(',','.',getByTagName($faturamento,'vlrftbru')),2,',','.'); ?>" />
	<br style="clear:both;"/>			
</form>

<div class="divFinanc">
	<label for="dtaltjfn">Alterado:</label>	
	<input name="dtaltjfn" id="dtaltjfn" type="text" value="<? echo getByTagName($faturamento,'dtaltjfn') ?>" />
	
	<label for="cdoperad">Operador:</label>
	<input name="cdoperad" id="cdoperad" type="text" value="<? echo getByTagName($faturamento,'cdoperad') ?>" />
	<input name="nmoperad" id="nmoperad" type="text" value="<? echo getByTagName($faturamento,'nmoperad') ?>" />
</div>
	
<div id="divBotoes">
	<? if ( $operacao == 'CA' ) { ?>
		<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="controlaOperacao('AC');return false;" />
		<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('AV');" />	
	<? } else if ( $operacao == 'CI' ) { ?>
		<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="controlaOperacao('IC');return false;" />
		<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('IV');" />	
	<? } ?>
</div>			
