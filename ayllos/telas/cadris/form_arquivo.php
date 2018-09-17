<? 
/*!
 * FONTE        : form_arquivo.php
 * CRIAÇÃO      : Heitor Schmitt (Mouts)
 * DATA CRIAÇÃO : 19/12/2017
 * OBJETIVO     : Formulario de importacao de arquivo.
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */	
?>
<form id="frmCadrisArquivo" name="frmCadrisArquivo" class="formulario">
	<div id="divArquivo">
		<label for="nmdarqui">Arquivo:</label>
		<input type="text" id="nmdarqui" name="nmdarqui" value='<? echo "/micros/".$glbvars["dsdircop"]."/risco/contas_risco.txt" ?>' />
		
		<br style="clear:both" />
		<br style="clear:both" />
		
		<fieldset>
		<div id="exemplo" style="height:80px">
		<label style="text-align:left">
			&nbsp;&nbsp;Formato do arquivo TXT exemplo:</br>
			&nbsp;&nbsp;Nº Coop;Nº Conta;Risco BC;Justificativa</br>
			&nbsp;&nbsp;<? echo $glbvars["cdcooper"] ?>;123456;H;Agravamento solicitado pelo BC
		</label>
		</div>
		</fieldset>
	</div>
</form>