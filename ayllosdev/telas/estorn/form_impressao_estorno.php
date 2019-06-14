<? 
/*!
 * FONTE        : form_impressao_estorno.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : 14/09/2015
 * OBJETIVO     : Formulario para impressao do Estorno
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
?>
<form id="frmImpressaoEstorno" name="frmImpressaoEstorno" class="formulario">
	<input type="hidden" id="sidlogin" name="sidlogin" />
	<div>
		<fieldset>	
			<legend>Filtros</legend>

			<label for="cdtpprod">Tipo:</label>
			<select id="cdtpprod" name="cdtpprod">
	   			<option value='1'>1 - Empr&eacute;stimo PP</option>
				<option value='2'>2 - Desconto de T&iacute;tulos</option>
    		</select>
			
			<label for="nrdconta"><?php echo utf8ToHtml('Conta/DV:') ?></label>
			<input type="text" id="nrdconta" name="nrdconta" class="conta" value=""/>
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>

			<label for="nrctremp"><?php echo utf8ToHtml('Contrato:') ?></label>
			<input type="text" id="nrctremp" name="nrctremp" value=""/>
			<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
			
			<br />
			
			<label for="dtiniest">Data Inicial: </label>			
			<input type="text" id="dtiniest" name="dtiniest" value=""/>
			
			<label for="dtfinest">Data Final: </label>			
			<input type="text" id="dtfinest" name="dtfinest" value=""/>
			
			<label for="cdagenci">PA: </label>			
			<input type="text" id="cdagenci" name="cdagenci" value=""/>
			
		</fieldset>	
	<div>
</form>