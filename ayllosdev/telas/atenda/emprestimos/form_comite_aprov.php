<? 
 /*!
 * FONTE        : form_comite_aprov.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 18/04/2011 
 * OBJETIVO     : Formulário da rotina Emprestimos da tela ATENDA
 *
 * ALTERACOES   : 001: [05/09/2012] Mudar para layout padrao (Gabriel)
 * 				  002: [12/09/2012] Permitir ate 760 caracteres no campo de observacao (Gabriel).
 *				  003: [14/10/2013] Ajuste para fechar corretamente a tag textarea (Adriano);
 *				  004: [24/12/2013] Alterado fluxo de botao continuar quando operacao for "C_COMITE_APROV", de "C_DADOS_PROP" para "".  (Jorge)				  
 *                005: [07/01/2015] Projeto Microcredito (Jonata-RKAM).
 */	
?>

<form name="frmComiteAprov" id="frmComiteAprov" class="formulario">	

	<input id="nrctremp" name="nrctremp" type="hidden" value="" />
		
	<fieldset>
		<legend><? echo utf8ToHtml('Comitê de Aprovação') ?></legend>
		
		<textarea name="dsobscmt" id="dsobscmt" ></textarea> 
			
	</fieldset>
	
	<fieldset>
		<legend><? echo utf8ToHtml('Observações') ?></legend>
		
		<textarea name="dsobserv" id="dsobserv" value=""></textarea>
							
	</fieldset>
			
			
</form>

<div id="divBotoes">
	<? if ( $operacao == 'A_COMITE_APROV' ) { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('A_INICIO'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="verificaObs('A_ALIENACAO'); return false;">Continuar</a> 
	<? } else if ($operacao == 'C_COMITE_APROV') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('CF'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="microcredito('C'); return false;">Continuar</a>
	<? } else if ($operacao == 'E_COMITE_APROV') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao(''); return false;">Voltar</a>
	<? } else if ($operacao == 'I_COMITE_APROV') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('I_INICIO'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="verificaObs('I_ALIENACAO'); return false;">Continuar</a>
	<? } ?>
</div>