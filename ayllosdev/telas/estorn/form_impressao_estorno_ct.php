<? 
/*!
 * FONTE        : form_impressao_estorno_ct.php
 * CRIAÇÃO      : Diego Simas (AMcom)
 * DATA CRIAÇÃO : 05/09/2018
 * OBJETIVO     : Formulário para impressão do relatório de estornos de prejuízo de conta corrente.
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
?>
<form id="frmImpressaoEstornoCT" name="frmImpressaoEstornoCT" class="formulario">
	<input type="hidden" id="sidlogin" name="sidlogin" />
	<div>
		<fieldset>	
			<legend>Filtros</legend>
			
			<label for="nrdconta"><?php echo utf8ToHtml('Conta/DV:') ?></label>
			<input type="text" id="nrdconta" name="nrdconta" class="conta" value=""/>
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>

			<br />
			
			<label for="dtiniest">Data Inicial: </label>			
			<input type="text" id="dtiniest" name="dtiniest" value=""/>
			
			<label for="dtfinest">Data Final: </label>			
			<input type="text" id="dtfinest" name="dtfinest" value=""/>
			
		</fieldset>	
	<div>
</form>