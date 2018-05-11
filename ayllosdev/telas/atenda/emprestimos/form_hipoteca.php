<? 
/*!
 * FONTE        : form_hipoteca.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 18/04/2011 
 * OBJETIVO     : Formulário da rotina Emprestimos da tela ATENDA
 *
 * ALTERACOES   : 000: [05/09/2012] Mudar para layout padrao (Gabriel) 
                  001: [12/11/2014] Projeto consultas automatizadas (Jonata-RKAM). 
				  002: [25/01/2016] Alterar a chamada do botao Salvar. (James)
				  003: [21/06/2017] Alterar a chamada do botão Continuar no caso de operacao C_HIPOTECA. (Mateus - MOUTS)
 */	
 ?>

<form name="frmHipoteca" id="frmHipoteca" class="formulario">	

	<fieldset>
		<legend><? echo utf8ToHtml('Dados para a  H I P O T E C A') ?></legend>

		<input id="nrctremp" name="nrctremp" type="hidden" value="" />
		
		<label id="lsbemfin"></label>
		<br />
			
		<label for="dscatbem">Categoria:</label>
		<select name="dscatbem" id="dscatbem"></select>
					
		<label for="vlmerbem">Valor de Mercado:</label>
		<input name="vlmerbem" id="vlmerbem" type="text" value="" />
		<br />
		
		<label for="dsbemfin">Descricao:</label>
		<input name="dsbemfin" id="dsbemfin" type="text" value="" />
		<br />
		
		<label for="dscorbem">Endereco:</label>
		<input name="dscorbem" id="dscorbem" type="text" value="" />
		<br />
	</fieldset>
		
</form>

<div id="divBotoes">
	<? if ( $operacao == 'A_HIPOTECA' ) { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('A_INICIO'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="validaHipoteca('atualizaArray(\'A_HIPOTECA\');','A_HIPOTECA'); return false;">Continuar</a>
	<? } else if ($operacao == 'AI_HIPOTECA') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('A_INICIO'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="validaHipoteca('insereHipoteca(\'A_HIPOTECA\',\'A_DEMONSTRATIVO_EMPRESTIMO\');','A_HIPOTECA'); return false;">Continuar</a>
	<? } else if ($operacao == 'C_HIPOTECA') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao(''); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="controlaOperacao('C_HIPOTECA'); return false;">Continuar</a>
	<? } else if ($operacao == 'E_HIPOTECA') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao(''); return false;">Voltar</a>
	<? } else if ($operacao == 'I_HIPOTECA') { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('I_INICIO'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="validaHipoteca('insereHipoteca(\'I_HIPOTECA\',\'I_DEMONSTRATIVO_EMPRESTIMO\');','I_HIPOTECA'); return false;">Continuar</a>
	<? } else if ( $operacao == 'IA_HIPOTECA' ) { ?>
		<a href="#" class="botao" id="btVoltar" onClick="controlaOperacao('I_INICIO'); return false;">Voltar</a>
		<a href="#" class="botao" id="btSalvar" onClick="validaHipoteca('atualizaArray(\'I_HIPOTECA\');','I_HIPOTECA'); return false;">Continuar</a>
	<? }?>
</div>

<script>

	highlightObjFocus($('#frmHipoteca'));

</script>