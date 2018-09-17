<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Henrique
 * DATA CRIAÇÃO : Agosto/2011
 * OBJETIVO     : Cabeçalho para a tela CADDNE
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */ 
?>

<form id="frmCaddne" name="frmCaddne" class="formulario" style="display:none;">	
	
	<input type="hidden" id='nrcepend' name='nrcepend'></input>
	
	<label for='nmreslog'> Logradouro:</label>
	<input id="nmreslog" name="nmreslog" alt="Nome completo do logradouro.">
	
	<br style="clear:both" />	
	
	<label for='nmresbai'> Bairro:</label>
	<input id="nmresbai" name="nmresbai" alt="Nome do bairro.">
	
	<br style="clear:both" />
	
	<label for='nmrescid'> Cidade:</label>
	<input id="nmrescid" name="nmrescid" alt="Nome da cidade.">
	
	<label for='cduflogr'> Estado:</label>
	<input id="cduflogr" name="cduflogr" alt="Sigla do estado.">
	
	<label for='dstiplog'> Tipo:</label>
	<input id="dstiplog" name="dstiplog" alt="Tipo de logradouro (Ex: Rua, Avenida, Rodovia, etc).">
	
	<br style="clear:both" />	
	
	<label for='dscmplog'> Complemento:</label>
	<input id="dscmplog" name="dscmplog" alt="Informa&ccedil;&otilde;es complementares do logradouro.">
	
	<br style="clear:both" />

	<label for='dsoricad'> Cad. Origem:</label>
	<input id="dsoricad" name="dsoricad" alt="Origem do cadastro.">
	
	<br style="clear:both" />
	
	<input type="hidden" id='idoricad' name='idoricad'></input>
	<input type="hidden" id='nrdrowid' name='nrdrowid'></input>
</form>