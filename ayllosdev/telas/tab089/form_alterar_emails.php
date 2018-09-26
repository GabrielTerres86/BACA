<?php
/*!
 * FONTE        : form_alterar_emails.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 24/08/2018
 * OBJETIVO     : Formulario de alteracao da Tela TAB089 aba Motivos
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */ 

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

?>

<form id="frmAlterarEmails" name="frmAlterarEmails" class="formulario">
	
	<fieldset style="margin-top: 10px">

		<legend> <? echo utf8ToHtml('Parâmetros do E-mail') ?> </legend>

		<label for="tpproduto">Tipo Produto:</label>
		<select name="tpproduto" id="tpproduto">
			<option value="1"><? echo utf8ToHtml('Empréstimos') ?></option>
			<option value="3"><? echo utf8ToHtml('Desconto Títulos - Limite') ?></option>
		</select>

		<br style="clear:both" />

		<label for="qt_periodicidade">Periodicidade:</label>
		<input type="text" id="qt_periodicidade"/>

		<br style="clear:both" />

		<label for="qt_envio">Quantidade Envios:</label>
		<input type="text" id="qt_envio"/>

		<br style="clear:both" />

		<label for="idativo">Ativo:</label>		
		<input type="checkbox" id="idativo" />

		<br style="clear:both" />
		
		<label for="ds_assunto">Assunto:</label>
		<input type="text" id="ds_assunto" />

		<br style="clear: both" />

		<label for="ds_corpo">Corpo do E-mail:</label>
		<textarea id="ds_corpo" name="ds_corpo"></textarea>
		
	</fieldset>
</form>

<div id="divBotoes" name="divBotoes" style="margin-bottom:5px">
	<a href="#" class="botao" id="btVoltar"  onClick="buscaEmails(); return false;">Voltar</a>
	<a href="#" class="botao" id="btProsseguir"  onClick="alteraEmail(); return false;">Concluir</a>
</div>
