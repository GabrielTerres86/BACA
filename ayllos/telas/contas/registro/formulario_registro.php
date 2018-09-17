<? 
/*!
 * FONTE        : formulario_registro.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 23/04/2010 
 * OBJETIVO     : Formulário da rotina REGISTRO da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 04/08/2015 - Reformulacao cadastral (Gabriel-RKAM)
 * --------------
 */	
?>

<div id="divRegistro">	
	<form name="frmRegistro" id="frmRegistro" class="formulario">
	
		<fieldset>
			<legend>Valores - R$</legend>			
		
			<label for="vlfatano">Faturamento Ano</label>
			<input name="vlfatano" id="vlfatano" type="text" value="<? echo number_format(str_replace(',','.',getByTagName($registro,'vlfatano')),2,',','.') ?>" />
			
			<label for="vlcaprea">Capital Realizado:</label>
			<input name="vlcaprea" id="vlcaprea" type="text" value="<? echo number_format(str_replace(',','.',getByTagName($registro,'vlcaprea')),2,',','.') ?>" />
		</fieldset>
		
		<fieldset>
			<legend>Registro</legend>			
			
			<label for="dtregemp">Data:</label>
			<input name="dtregemp" id="dtregemp" type="text" value="<? echo getByTagName($registro,'dtregemp') ?>" />
			
			<label for="nrregemp"><? echo utf8ToHtml('Número:') ?></label>
			<input name="nrregemp" id="nrregemp" type="text" value="<? echo getByTagName($registro,'nrregemp') ?>" />
			
			<label for="orregemp"><? echo utf8ToHtml('Orgão:') ?></label>
			<input name="orregemp" id="orregemp" type="text" value="<? echo getByTagName($registro,'orregemp') ?>" />
		</fieldset>
		
		<fieldset>
			<legend><? echo utf8ToHtml('Inscrição Municipal') ?></legend>					
			
			<label for="dtinsnum">Data:</label>
			<input name="dtinsnum" id="dtinsnum" type="text" value="<? echo getByTagName($registro,'dtinsnum') ?>" />
			
			<label for="nrinsmun"><? echo utf8ToHtml('Número:') ?></label>
			<input name="nrinsmun" id="nrinsmun" type="text" value="<? echo getByTagName($registro,'nrinsmun') ?>" />
		</fieldset>
		
		<fieldset>
			<legend><? echo utf8ToHtml('Inscrição Estatual') ?></legend>
			
			<label for="flgrefis">Optante REFIS:</label>
			<input name="flgrefis" id="flagsim" type="radio" class="radio" value="yes" <? if (getByTagName($registro,'flgrefis') == 'yes') { echo ' checked'; } ?> />
			<label for="flagsim" class="radio">Sim</label>
			<input name="flgrefis" id="flagnao" type="radio" class="radio" value="no" <? if (getByTagName($registro,'flgrefis') == 'no') { echo ' checked'; } ?> />
			<label for="flagnao" class="radio">N&atilde;o</label>			
			
			<label for="nrinsest"><? echo utf8ToHtml('Número:') ?></label>
			<input name="nrinsest" id="nrinsest" type="text" value="<? echo getByTagName($registro,'nrinsest') ?>" />
		</fieldset>
		
		<fieldset style="margin-bottom:0px;">
			<legend><? echo utf8ToHtml('Concentração Faturamento') ?></legend>
		
			<label for="perfatcl"><? echo utf8ToHtml('(%) único cliente:') ?></label> 
			<input name="perfatcl" id="perfatcl" type="text" value="<? echo getByTagName($registro,'perfatcl') ?>" />
				
			<label for="nrcdnire"><? echo utf8ToHtml('Número NIRE:') ?></label>
			<input name="nrcdnire" id="nrcdnire" type="text" value="<? echo getByTagName($registro,'nrcdnire') ?>" />
		</fieldset>
		
		<br style="clear:both" />
	</form>
	<div id="divBotoes">
		<? if ( in_array($operacao,array('AC','FA','')) ) { ?>	
			<input type="image" id="btVoltar"  src="<?php echo $UrlImagens; ?>botoes/voltar.gif"  onClick="fechaRotina(divRotina);"   />
			<input type="image" id="btAlterar" src="<?php echo $UrlImagens; ?>botoes/alterar.gif" onClick="controlaOperacao('CA');" />
		<? } else if ( $operacao == 'CA'  && $flgcadas != 'M') { ?>
			<input type="image" id="btVoltar"  src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao('AC');" />		
			<input type="image" id="btSalvar"  src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onClick="controlaOperacao('AV');" />
		<? } else { // Cadastro completo que vem da MATRIC ?>
			<input type="image" id="btVoltar"  src="<?php echo $UrlImagens; ?>botoes/voltar.gif"  onClick="voltarRotina();"   />
		<? } ?>
		<input type="image" id="btContinuar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaContinuar();" />
	</div>
</div>