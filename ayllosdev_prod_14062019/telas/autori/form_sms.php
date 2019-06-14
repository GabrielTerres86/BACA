<? 
 /*!
 * FONTE        : form_sms.php
 * CRIAÇÃO      : Dioathan
 * DATA CRIAÇÃO : 20/04/2016
 * OBJETIVO     : Formulário de cadastro de telefone para envio de SMS
 * --------------
 * ALTERAÇÕES   : 
 */	
?>

<form name="frmSms" id="frmSms" class="formulario">	

	<fieldset>
		<legend><? echo utf8ToHtml('Telefone para envio de SMS') ?></legend>
		
		<label for="nrdddtfc">DDD:</label>
		<input name="nrdddtfc" id="nrdddtfc" type="text" value="<? echo getByTagName($registro,'nrdddtfc') ?>" />
		
		<label for="nrtelefo">Celular:</label>
		<input name="nrtelefo" id="nrtelefo" type="text" value="<? echo getByTagName($registro,'nrtelefo') ?>" />
		
	</fieldset>
	
	<fieldset>
		<legend><? echo utf8ToHtml('Mensagem') ?></legend>
		
		<p>
			<? echo str_replace('#','<br/><br/>',getByTagName($registro,'dsmsgsms')) ?>
		</p>
		
	</fieldset>
			
</form>

<div id="divBotoes">
	<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao(''); return false;">Cancelar</a>
	<? if (getByTagName($registro,'nrtelefo') != '') { ?>
		<a href="#" class="botao" id="btExcluir" onClick="confirmaExclusaoSMS(); return false;">Excluir</a>
	<? } ?>
	<a href="#" class="botao" id="btSalvar" onClick="controlaOperacao('S2'); return false;">Concluir</a>
</div>