<? 
/*!
 * FONTE        : formulario_contatos.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 10/05/2010 
 * OBJETIVO     : Formulário da rotina CONTATOS da tela de CONTAS
 * ALTERAÇÃO    : Adicionado pesquisa CEP. ( Rodolpho/Rogérius. (DB1) ).
 
                  31/08/2015 - Reformulacao cadastral (Gabriel-RKAM)
 */	
?>

<form name="frmContatos" id="frmContatos" class="formulario">
	
	<fieldset>
		<legend><? echo utf8ToHtml('Contato') ?></legend>			
	
		<label for="nrdctato"><? echo utf8ToHtml('Conta/dv:') ?></label>
		<input name="nrdctato" id="nrdctato" type="text" value="<? echo getByTagName($registro,'nrdctato') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		
		<label for="nmdavali"><? echo utf8ToHtml('Nome:') ?></label>
		<input name="nmdavali" id="nmdavali" type="text" value="<? echo getByTagName($registro,'nmdavali') ?>" />
		<br />
	</fieldset>	
	

	<fieldset>
		<legend><? echo utf8ToHtml('Forma de Contato') ?></legend>					
		
		<label for="nrtelefo"><? echo utf8ToHtml('Telefone:') ?></label>
		<input name="nrtelefo" id="nrtelefo" type="text" value="<? echo getByTagName($registro,'nrtelefo') ?>" />
		
		<label for="dsdemail"><? echo utf8ToHtml('E-Mail:') ?></label>
		<input name="dsdemail" id="dsdemail" type="text" value="<? echo getByTagName($registro,'dsdemail') ?>" />
	</fieldset>	
	
</form>

<div id="divBotoes">
	<? if ( $operacao == 'TA' ) { ?>
		<input type="image" id="btVoltar"  src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacaoContatos('');" />		
		<input type="image" id="btSalvar"  src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacaoContatos('AV');" />
	<? } else if ( ($operacao == 'TI') || ($operacao == 'TB') ) { ?>
		<input type="image" id="btVoltar"  src="<?php echo $UrlImagens; ?>botoes/voltar.gif"	onClick="controlaOperacaoContatos('');" />		
		<input type="image" id="btLimpar"  src="<?php echo $UrlImagens; ?>botoes/limpar.gif"	onClick="btLimpar()" 	  />		
		<input type="image" id="btSalvar"  src="<?php echo $UrlImagens; ?>botoes/concluir.gif"	onClick="controlaOperacaoContatos('IV');" />
	<? } else if ( $operacao == 'TC' ) { ?>
		<input type="image" id="btVoltar"  src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacaoContatos('');" />		
	<? } ?>
</div>