<? 
 /*!
 * FONTE        : form_comite_aprov.php
 * CRIAÇÃO      : André Socoloski - DB1
 * DATA CRIAÇÃO : 29/03/2011 
 * OBJETIVO     : Formulário da rotina Prestações da tela ATENDA
 * ALTERACAO    : 
 *
 * 001 [08/04/2014] Alterado fluxo de botao voltar e continuar. (Jorge)
 * 002 [07/06/2018] - P410 - Incluido tela de resumo da contratação + declaração isenção imóvel - Arins/Martini - Envolti
 */	
?>

<form name="frmComiteAprov" id="frmComiteAprov" class="formulario">	

	<input id="nrctremp" name="nrctremp" type="hidden" value="" />
		
	<fieldset>
		<legend><? echo utf8ToHtml('Comitê de Aprovação') ?></legend>
		
		<textarea name="dsobscmt" id="dsobscmt" value="" /> 
			
	</fieldset>
	
	<fieldset>
		<legend><? echo utf8ToHtml('Observações') ?></legend>
		
		<textarea name="dsobserv" id="dsobserv" value="" />
							
	</fieldset>
			
			
</form>

<div id="divBotoes">
	<? if ($operacao == 'C_COMITE_APROV') { ?>
		<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="controlaOperacao('C_PROT_CRED'); return false;" />
		<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaOperacao('C_DEMONSTRATIVO_EMPRESTIMO'); return false;" />
	<? } ?>
</div>
