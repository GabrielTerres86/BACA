<? 
/*!
 * FONTE        : form_bndes.php
 * CRIAÇÃO      : Lucas R
 * DATA CRIAÇÃO : Maio/2013 
 * OBJETIVO     : Forumlário de dados de Prestações do BNDES
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
 
session_start();
require_once('../../../../includes/config.php');
require_once('../../../../includes/funcoes.php');		
require_once('../../../../includes/controla_secao.php');
require_once('../../../../class/xmlfile.php');
isPostMethod();
?>	

<form name="frmDadosBndes" id="frmDadosBndes" class="formulario" >

	<input id="nrctremp" name="nrctremp" type="hidden" value="" />

	<fieldset>
		<legend>Empréstimos BNDES</legend>

		<label for="dsdprodu">Produto:</label>
		<input name="dsdprodu" id="dsdprodu" type="text" value="" />
		
		<label for="vlropepr">Emprestado:</label>
		<input name="vlropepr" id="vlropepr" type="text" value="" />
		<br />
		
		<label for="nrctremp">Contrato:</label>
		<input name="nrctremp" id="nrctremp" type="text" value="" />
		
		<label for="vlparepr">Prestação:</label>
		<input name="vlparepr" id="vlparepr" type="text" value="" />
		<br />		
			
		<label for="qtdmesca">Carência:</label>
		<input name="qtdmesca" id="qtdmesca" type="text" value="" />
		
		<label for="vlsdeved">Saldo:</label>
		<input name="vlsdeved" id="vlsdeved" type="text" value="" />
		<br />
		
		<label for="percaren">Periodicidade:</label>
		<input name="percaren" id="percaren" type="text" value="" />	
		
		<label for="dtinictr">Dt. Contrato:</label>
		<input name="dtinictr" id="dtinictr" type="text" value="" />
		<br />
		
		<label for="qtparctr">Parcelas:</label>
		<input name="qtparctr" id="qtparctr" type="text" value="" />
		
		<label for="dtpricar">Dt. 1ª Carência:</label>
		<input name="dtpricar" id="dtpricar" type="text" value="" />
		<br />
		
		<label for="perparce">Periodicidade:</label>
		<input name="perparce" id="perparce" type="text" value="" />		
				
		<label for="dtlibera">Dt. Liberação:</label>
		<input name="dtlibera" id="dtlibera" type="text" value="" />
		
		<br />	
		<label for="dtpripag">Dt. 1ª Parcela:</label>
		<input name="dtpripag" id="dtpripag" type="text" value="" />
		<br />
		
	</fieldset>
</form>	

<div id="divBotoes">
	<input id="btVoltar" type="image" onclick="controlaOperacao();" src="<? echo $UrlImagens; ?>botoes/voltar.gif">
</div>
			
