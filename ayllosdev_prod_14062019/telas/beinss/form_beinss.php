<? 
 /*!
 * FONTE        : form_beinss.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 31/05/2011 
 * OBJETIVO     : Formulário de exibição
 * --------------
 * ALTERAÇÕES   : 18/12/2012 - Alteracao layout tela, alterado botoes tipo tag input para tag a (Daniel).
 *                12/08/2013 - Alteração da sigla PAC para PA. (Carlos)
 * --------------
 */	
?>

<form name="frmBeinss" id="frmBeinss" class="formulario">	
	
	<fieldset> 
	<label for="nrprocur">NB/NIT:</label>
	<input type="text" id="nrprocur" name="nrprocur" />

	<label for="nrcpfcgc">CPF:</label>
	<input type="text" id="nrcpfcgc" name="nrcpfcgc" />

	<label for="cdagenci">PA:</label>
	<input type="text" id="cdagenci" name="cdagenci" />
	<a style="margin-top:5px"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
	<input type="text" id="nmresage" name="nmresage" />
	
	<label for="nmrecben">Nome:</label>
	<input type="text" id="nmrecben" name="nmrecben" />
	<a href="#" id="btOk" class="botao">OK</a>
	
	<br style="clear:both" />	
	</fieldset>
	
	<fieldset>
		<legend><? echo utf8ToHtml('Dados do Beneficiário') ?></legend>

		<label for="dtnasben"><? echo utf8ToHtml('Data nasc.:') ?></label>
		<input name="dtnasben" id="dtnasben" type="text" />

		<label for="nmmaeben"><? echo utf8ToHtml('Nome Mãe:') ?></label>
		<input name="nmmaeben" id="nmmaeben" type="text" />
		
		<br />
		
		<label for="dsendben"><? echo utf8ToHtml('Endereço:') ?></label>
		<input name="dsendben" id="dsendben" type="text" />

		<br />
		
		<label for="nmbairro"><? echo utf8ToHtml('Bairro:') ?></label>
		<input name="nmbairro" id="nmbairro" type="text" />

		<label for="nrcepend"><? echo utf8ToHtml('Cep:') ?></label>
		<input name="nrcepend" id="nrcepend" type="text" />

		<label for="dtatuend"><? echo utf8ToHtml('Últ. atual. end.:') ?></label>
		<input name="dtatuend" id="dtatuend" type="text" />
		
	</fieldset>		
			
</form>

<div id="divTabBeneficiarios"></div>

<div id="divBotoes">	
	<a href="#" class="botao" id="btVoltar" onClick="controlaLayout('1'); return false;" >Voltar</a>
</div>
