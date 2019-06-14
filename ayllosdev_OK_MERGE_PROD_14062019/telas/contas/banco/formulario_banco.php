<? 
/*!
 * FONTE        : formulario_banco.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : Abril/2010 
 * OBJETIVO     : Forumlário de dados de Banco para alteracao
 */	
?>	

<form name="frmDadosBancos" id="frmDadosBancos" class="formulario" >
	
	<input id="nrdlinha" name="nrdlinha" type="hidden" value="<? echo getByTagName($registro,'nrdlinha') ?>" />
	
	<label for="cddbanco">Banco:</label>
	<input name="cddbanco" id="cddbanco" type="text" class="codigo pesquisa" value="<? echo getByTagName($registro,'cddbanco') ?>" />
	<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
	<input name="dsdbanco" id="dsdbanco" type="text" class="descricao" value="<? echo getByTagName($registro,'dsdbanco') ?>" />
	<br />
	
	<label for="dstipope">Opera&ccedil;&atilde;o:</label>
	<input name="dstipope" id="dstipope" type="text" class="alphanum" maxlength="18" value="<? echo getByTagName($registro,'dstipope') ?>" />
	<br />
	
	<label for="vlropera">Valor ( R$ ):</label>
	<input name="vlropera" id="vlropera" type="text" class="moeda" maxlength="14" value="<? echo number_format(str_replace(',','.',getByTagName($registro,'vlropera')),2,',','.') ?>" />
	<br />
	
	<label for="garantia">Garantia:</label>
	<input name="garantia" id="garantia" type="text" class="alphanum" maxlength="18" value="<? echo getByTagName($registro,'garantia') ?>" />
	<br />
	
	<label for="dsvencto">Vencimento:</label>
	<input name="dsvencto" id="dsvencto" type="text" value="<? echo getByTagName($registro,'dsvencto') ?>" />
	<input name="venc" id="venc"  class="checkbox" type="checkbox" />
	<label for="venc" class="checkbox">V&aacute;rios</label>
	<br style="clear:both" />
	
</form>	
	
<div class="divFinanc">
	<label for="dtaltjfn">Dados Banco => Alterado:</label>
	<input name="dtaltjfn" id="dtaltjfn" type="text" value="<? echo getByTagName($registro,'dtaltjfn') ?>" />
	
	<label for="cdoperad">Operador:</label>
	<input name="cdoperad" id="cdoperad" type="text" value="<? echo getByTagName($registro,'cdoperad') ?>" />
	<input name="nmoperad" id="nmoperad" type="text" value="<? echo getByTagName($registro,'nmoperad') ?>" />
</div>
	
<div id="divBotoes">
	<? if ( $operacao == 'TA' ) { ?>
		<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="controlaOperacao('AT')" />
		<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('AV')" />	
	<? } else if ( $operacao == 'TI' ) { ?>
		<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/cancelar.gif" onClick="controlaOperacao('IT')" />
		<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('IV')" />	
	<? } ?>
</div>			
