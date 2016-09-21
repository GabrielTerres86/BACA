<? 
/*!
 * FONTE        : tab_tipo2.1.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 20/10/2011 
 * OBJETIVO     : Tabela que apresenta os contrato
 * --------------
 * ALTERAÇÕES   : 22/11/2012 - Alterado botões do tipo tag <input> por
 *							   tag <a>, retirado função formatação 
 *							   mensagem (Daniel).
 * --------------
 */	
?>

<form id="frmTipo" name="frmTipo" class="formulario">

	<fieldset>
	<legend><? echo utf8ToHtml('2 - Deposito Vinculado - Aplicações') ?></legend>
	<label for="dtmvtolt"><? echo utf8ToHtml('Data Inclusão do Aditivo:') ?></label>
	<input type="text" id="dtmvtolt" name="dtmvtolt" value="<? echo getByTagName($dados,'dtmvtolt')?>" />

	<br style="clear:both" /><br />

	<label for="btaplic1"></label>
	<input id="btaplic1" name="btaplic1" type="button" value="P.PROG" onClick="mostraAplicacao('1'); return false;" />
	<label for="tpaplic1"></label>
	<input id="tpaplic1" name="tpaplic1" type="text" value="" />
	
	<br />
	
	<label for="btaplic3"></label>
	<input id="btaplic3" name="btaplic3" type="button" value="RDCA30" onClick="mostraAplicacao('3'); return false;" />
	<label for="tpaplic3"></label>
	<input id="tpaplic3" name="tpaplic3" type="text" value="" />

	<br />
	
	<label for="btaplic5"></label>
	<input id="btaplic5" name="btaplic5" type="button" value="RDC60" onClick="mostraAplicacao('5'); return false;" />
	<label for="tpaplic5"></label>
	<input id="tpaplic5" name="tpaplic5" type="text" value="" />
	
	<br />
	
	<label for="btaplic7"></label>
	<input id="btaplic7" name="btaplic7" type="button" value="RDCPRE" onClick="mostraAplicacao('7'); return false;" />
	<label for="tpaplic7"></label>
	<input id="tpaplic7" name="tpaplic7" type="text" value="" />

	<br />
	
	<label for="btaplic8"></label>
	<input id="btaplic8" name="btaplic8" type="button" value="RDCPOS" onClick="mostraAplicacao('8'); return false;" />
	<label for="tpaplic8"></label>
	<input id="tpaplic8" name="tpaplic8" type="text" value="" />

	</fieldset>

</form>

<div id="divBotoes" style="margin-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); return false;">Voltar</a>
</div>

<script>
formataTipo2();
</script>