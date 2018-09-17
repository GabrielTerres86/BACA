<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Rogerius Militão (DB1)
 * DATA CRIAÇÃO : 22/07/2011
 * OBJETIVO     : Cabeçalho para a tela ALIENA
 * --------------
 * ALTERAÇÕES   : 21/11/2012 - Mudanca layout da tela, alterado botões
 *				  do tipo tag <input> por tag <a>, (Daniel)
 * --------------
 */

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<table>
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Opção:') ?></label>
				<select id="cddopcao" name="cddopcao" style="width: 477px;">
					<option value="C"> C - Consultar situacao e vencimento. </option> 
					<option value="A"> A - Alterar situacao.</option>
					<option value="S"> S - Alterar data de vencimento.</option> 
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos(); $('#nrdconta','#frmCab').focus(); return false;" align="right">OK</a>
			</td>
		<tr>
			<td>
				<label for="nrdconta">Conta:</label>
				<input type="text" id="nrdconta" name="nrdconta" />
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisas(1);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
				
				<label for="nrctremp">Contrato:</label>
				<input type="text" id="nrctremp" name="nrctremp" />
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisas(2);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
				
				<label for="dtmvtolt">Data:</label>
				<input type="text" id="dtmvtolt" name="dtmvtolt" />
			</td>
		</tr>
		<tr>
			<td>
				<label for="nmprimtl">Titular:</label>
				<input name="nmprimtl" id="nmprimtl" type="text" />
			</td>
		</tr>
	</table>
	
	<!--- <br style="clear:both" /> -->	
	
</form>