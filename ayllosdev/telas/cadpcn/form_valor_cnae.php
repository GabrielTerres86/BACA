<?php
/*!
 * FONTE        : form_valor_cnae.php
 * CRIAÇÃO      : Cristian Filipe Fernandes (GATI)
 * DATA CRIAÇÃO : 19/11/2013
 * OBJETIVO     : formulario para a tela CADSEG
 * --------------
 * ALTERAÇÕES   : 19/12/2013 - Alterado label do nrcgcseg de 'Numero do CGC:'
 *							   para 'Numero do CNPJ:'. (Reinert)
 *
 *				  23/01/2014 - Ajustes gerais para liberacao. (Jorge)
 * --------------
 */
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>


<div id="divCadpcn" name="divCadpcn">
	
	<form id="frmValorMaximoCnae" name="frmValorMaximoCnae" class="formulario" onSubmit="return false;" style="display:none">
	
	<!--<form id="frmCab" name="frmCab" class="formulario" style="display:none">-->
	
	<fieldset id='tabConteudo'>
			
	<legend>Valor m&aacute;ximo por CNAE</legend>
	<br />	

	<input name="dtcadass" id="dtcadass" type="hidden" class="alphanum" value="<? echo getByTagName() ?>" />
	
	<label for="cdcnae" class="rotulo rotulo-90">CNAE:</label>

	<input name="cdcnae" id="cdcnae" type="text" class="pesquisa" maxlength="15" value="<? echo getByTagName() ?>" />

	<a class="lupa" style="cursor: pointer;" onclick="controlaPesquisas();">
		<img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" />	
	</a>

	<input name="dscnae" id="dscnae" type="text" class="descricao" value="" />
	<br />	
	
	<label for="vlcnae" class="rotulo rotulo-90">Valor:</label>
	<input name="vlcnae" id="vlcnae" type="text" maxlength="15" value="<? echo $identificacao_cnae; ?>" />
	<br />

	<br clear="both" />

		</fieldset>
	</form>
	
		
</div>
