<? 
/*!
 * FONTE        : formulario_emails.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 17/05/2010 
 * OBJETIVO     : Formulário da rotina E-MAILS da tela de CONTAS
 */	
?>

<form name="frmEmails" id="frmEmails" class="formulario">	

	<input id="nrdrowid" name="nrdrowid" type="hidden" value="<? echo getByTagName($registro,'nrdrowid') ?>" />
	
	<label for="dsdemail">E-Mail:</label>
	<input name="dsdemail" id="dsdemail" type="text" value="<? echo getByTagName($registro,'dsdemail') ?>" />
	<br />
	
	<label for="secpscto">Setor:</label>
	<input name="secpscto" id="secpscto" type="text" value="<? echo getByTagName($registro,'secpscto') ?>" />
	<br />
	
	<label for="nmpescto">Nome Contato:</label>
	<input name="nmpescto" id="nmpescto" type="text" value="<? echo getByTagName($registro,'nmpescto') ?>" />
	<br />

	<?php if ($inpessoa == 1) { ?>
		<label for="dssituac"><? echo utf8ToHtml('Situação:'); ?></label>
		<input name="dssituac" id="dssituac" type="text"  value="<? echo getByTagName($registro,'dssituac') ?>" />

		<label for="dsdcanal"><? echo utf8ToHtml('Canal:'); ?></label>
		<input name="dsdcanal" id="dsdcanal" type="text"  value="<? echo getByTagName($registro,'dsdcanal') ?>" />

		<label for="dtrevisa"><? echo utf8ToHtml('Data revisão:'); ?></label>
		<input name="dtrevisa" id="dtrevisa" type="text"  value="<? echo getByTagName($registro,'dtrevisa') ?>" />
	<?php } ?>
	
</form>

<div id="divBotoes">
	<? if ( $operacao == 'TA' ) { ?>
		<input type="image" id="btVoltar"  src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao('AT');" />		
		<input type="image" id="btSalvar"  src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('AV');" />
	<? } else if ($operacao == 'TI') { ?>
		<input type="image" id="btVoltar"  src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao('IT');" />		
		<input type="image" id="btSalvar"  src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('IV');" />
	<? } else if ($operacao == 'CF') { ?>
		<input type="image" id="btVoltar"  src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao();" />		
	<? } ?>
</div>