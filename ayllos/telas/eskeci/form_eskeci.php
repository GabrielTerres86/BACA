<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Henrique
 * DATA CRIAÇÃO : 27/06/2011
 * OBJETIVO     : Cabeçalho para a tela ESKECI
 * --------------
 * ALTERAÇÕES   : 18/09/2012 - Inclusão do fieldset com titulo (Lucas R.)
 *
 *				  27/07/2015 - Removido o campo Limite. (James)	
 * --------------
 */ 
?>

<form id="frmEskeci" name="frmEskeci" class="formulario">	
	
	<fieldset>
	<legend><? echo utf8ToHtml('Dados do Cart&atilde;o') ?></legend>
	
	<label for='nrdconta'> Conta/DV:</label>
	<input type="text" id="nrdconta" name="nrdconta" />
	
	<label for='nrdctitg'> Conta/ITG:</label>
	<input type="text" id="nrdctitg" name="nrdctitg" />

	<br style="clear:both" />	
	
	<label for='nmprimtl'> Titular da Conta:</label>
	<input type="text" id="nmprimtl" name="nmprimtl" />	
	
	<br style="clear:both" />	
	
	<label for='nmtitcrd'> Titular da Cart&atilde;o:</label>
	<input type="text" id="nmtitcrd" name="nmtitcrd" />	

	<br style="clear:both" />	
	<br style="clear:both" />
	
	<label for='dtemscar'>  Emitido em:</label>
	<input type="text" id="dtemscar" name="dtemscar" />			
	
	<label for='dtvalcar'> V&aacute;lido at&eacute;:</label>
	<input type="text" id="dtvalcar" name="dtvalcar" />			
	
	<br style="clear:both" />
	<br style="clear:both" />
	
	<label for='nrsennov'> Nova Senha:</label>
	<input type="password" id="nrsennov" name="nrsennov" alt="Digite a nova senha" />			
	
	<label for='nrsencon'> Confirme a Nova Senha:</label>
	<input type="password" id="nrsencon" name="nrsencon" alt="Confirme a senha" />			
	</fieldset>

	<br style="clear:both" />	
	
</form>