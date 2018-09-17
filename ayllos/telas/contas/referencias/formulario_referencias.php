<? 
/*!
 * FONTE        : formulario_referencias.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 28/04/2010 
 * OBJETIVO     : Formulário da rotina REFERÊNCIAS da tela de CONTAS
 * ALTERAÇÃO    : Adicionado pesquisa CEP. ( Rodolpho/Rogérius. (DB1) ).
 */	
?>

<form name="frmReferencias" id="frmReferencias" class="formulario">
	
	<fieldset>
		<legend><? echo utf8ToHtml('Referência') ?></legend>			
	
		<label for="nrdctato"><? echo utf8ToHtml('Conta/dv:') ?></label>
		<input name="nrdctato" id="nrdctato" type="text" value="<? echo getByTagName($registro,'nrdctato') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		
		<label for="nmdavali"><? echo utf8ToHtml('Nome:') ?></label>
		<input name="nmdavali" id="nmdavali" type="text" value="<? echo getByTagName($registro,'nmdavali') ?>" />
		<br />
		
		<label for="nmextemp"><? echo utf8ToHtml('Empresa:') ?></label>
		<input name="nmextemp" id="nmextemp" type="text" value="<? echo getByTagName($registro,'nmextemp') ?>" />
		
		<label for="dsproftl"><? echo utf8ToHtml('Cargo:') ?></label>
		<input name="dsproftl" id="dsproftl" type="text" value="<? echo getByTagName($registro,'dsproftl') ?>" />
		<br />
		
		<label for="cddbanco"><? echo utf8ToHtml('Banco:') ?></label>
		<input name="cddbanco" id="cddbanco" type="text" value="<? echo getByTagName($registro,'cddbanco') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="nmdbanco" id="nmdbanco" type="text" value="<? echo getByTagName($registro,'nmdbanco') ?>" />
		<br />

		<label for="cdageban"><? echo utf8ToHtml('Agência:') ?></label>
		<input name="cdageban" id="cdageban" type="text" value="<? echo getByTagName($registro,'cdageban') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
		<input name="nmageban" id="nmageban" type="text" value="<? echo getByTagName($registro,'nmageban') ?>" />			
	</fieldset>	
	
	<fieldset>
		<legend><? echo utf8ToHtml('Endereço') ?></legend>			

		<label for="nrcepend"><? echo utf8ToHtml('CEP:') ?></label>
		<input name="nrcepend" id="nrcepend" type="text" value="<? echo getByTagName($registro,'nrcepend') ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>

		<label for="dsendere"><? echo utf8ToHtml('End.:') ?></label>
		<input name="dsendere" id="dsendere" type="text" value="<? echo getByTagName($registro,'dsendere') ?>" />		
		<br />

		<label for="nrendere"><? echo utf8ToHtml('Nro.:') ?></label>
		<input name="nrendere" id="nrendere" type="text" value="<? echo getByTagName($registro,'nrendere') ?>" />

		<label for="complend"><? echo utf8ToHtml('Comple.:') ?></label>
		<input name="complend" id="complend" type="text" value="<? echo getByTagName($registro,'complend') ?>" />
		<br />

		<label for="nrcxapst"><? echo utf8ToHtml('Cx.Postal:') ?></label>
		<input name="nrcxapst" id="nrcxapst" type="text" value="<? echo getByTagName($registro,'nrcxapst') ?>" />		

		<label for="nmbairro"><? echo utf8ToHtml('Bairro:') ?></label>
		<input name="nmbairro" id="nmbairro" type="text" value="<? echo getByTagName($registro,'nmbairro') ?>" />								
		<br />	

		<label for="cdufende"><? echo utf8ToHtml('U.F.:') ?></label>
		<? echo selectEstado('cdufende', getByTagName($registro,'cdufende'), 1); ?>	

		<label for="nmcidade"><? echo utf8ToHtml('Cidade:') ?></label>
		<input name="nmcidade" id="nmcidade" type="text"  value="<? echo getByTagName($registro,'nmcidade') ?>" />

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
	<? if ( $operacao == 'CA' ) { ?>
		<input type="image" id="btVoltar"  src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao('AC');" />		
		<input type="image" id="btSalvar"  src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('AV');" />
	<? } else if ( ($operacao == 'CI') || ($operacao == 'CB') ) { ?>
		<input type="image" id="btVoltar"  src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao('IC');" />		
		<input type="image" id="btLimpar"  src="<?php echo $UrlImagens; ?>botoes/limpar.gif" onClick="btLimpar();" />
		<input type="image" id="btSalvar"  src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('IV');" />
	<? } else if ( $operacao == 'CC' ) { ?>
		<input type="image" id="btVoltar"  src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao('');" />		
	<? } ?>
</div>