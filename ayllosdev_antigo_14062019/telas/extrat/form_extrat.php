<?php
 /*!
 * FONTE        : form_extrat.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 01/08/2011 
 * OBJETIVO     : Formulário de exibição do EXTRAT
 * --------------
 * ALTERAÇÕES   : 15/08/2013 - Alteração da sigla PAC para PA (Carlos).
	*				  19/09/2013 - Implementada opcao AC da tela EXTRAT (Tiago).
	*				  03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 */	

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<form name="frmExtrat" id="frmExtrat" class="formulario" >	

	<fieldset>
	
		<legend>Dados do Extrato</legend>	

		<label for="nmprimtl">T&iacute;tular:</label>
		<input name="nmprimtl" id="nmprimtl" type="text" value="<?php echo getByTagName($dados,'nmprimtl'); ?>" />
		
		<label for="vllimcre">Limite Cr&eacute;dito:</label>
		<input name="vllimcre" id="vllimcre" type="text" value="<?php echo formataMoeda(getByTagName($dados,'vllimcre')); ?>" />
		
		<label for="cdagenc1">PA:</label>
		<input name="cdagenc1" id="cdagenc1" type="text" value="<?php echo getByTagName($dados,'cdagenci'); ?>" />
		
		<input type="hidden" id="cddopcao1" name="cddopcao1" />	
		<input type="hidden" id="nmarquiv1" name="nmarquiv1" />	
		<input type="hidden" id="nrdconta1" name="nrdconta1" />	
		<input type="hidden" id="dtinimov1" name="dtinimov1" />	
		<input type="hidden" id="dtfimmov1" name="dtfimmov1" />	
		<input type="hidden" id="nriniseq1" name="nriniseq1" />	
		<input type="hidden" id="nrregist1" name="nrregist1" />
		<input type="hidden" id="listachq1" name="listachq"  />

	</fieldset>		
	
</form>

