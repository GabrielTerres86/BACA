<? 
 /*!
 * FONTE        : form_periodo.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 01/05/2011 
 * OBJETIVO     : Formulário de exibição
 * --------------
 * ALTERAÇÕES   : 18/12/2012 - Alteracao layout tela, alterado botoes tipo tag input para tag a (Daniel).
 * --------------
 */	
?>

<form name="frmPeriodo" id="frmPeriodo" class="formulario">	

	<fieldset>
	
		<legend><? echo utf8ToHtml('Periodo') ?></legend>

		<label for="dtdinici"><? echo utf8ToHtml('Início:') ?></label>
		<input name="dtdinici" id="dtdinici" type="text" />

		<label for="dtdfinal"><? echo utf8ToHtml('Final:') ?></label>
		<input name="dtdfinal" id="dtdfinal" type="text" />
		<a href="#" class="botao" id="btSalvar" >OK</a>
		
	</fieldset>		

	<fieldset>
	
			<legend><? echo utf8ToHtml('Dados do Beneficiário') ?></legend>

			<label for="nrbenefi">NB:</label>
			<input type="text" id="nrbenefi" name="nrbenefi" />

			<label for="nrrecben">NIT:</label>
			<input type="text" id="nrrecben" name="nrrecben" />
			
			<br />
			
			<label for="nrcpfcgc">CPF:</label>
			<input type="text" id="nrcpfcgc" name="nrcpfcgc" />
			
			<label for="nmrecben">Nome:</label>
			<input type="text" id="nmrecben" name="nmrecben" />

	</fieldset>			
	
</form>

<div id="divTabBeneficios"></div>

<div id="divBotoes">	
	<a href="#" class="botao" id="btVoltar" onClick="controlaLayout('5'); return false;" >Voltar</a>
</div>
