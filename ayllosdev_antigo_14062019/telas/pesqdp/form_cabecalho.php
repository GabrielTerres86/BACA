<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 29/11/2011
 * OBJETIVO     : Cabeçalho para a tela PESQDP
 * --------------
 * ALTERAÇÕES   : 24/06/2014 - Incluido opcão "D - Devolvidos". (Reinert)
 *				  14/08/2015 - Removidos todos os campos da tela menos os campos
 *							   Data do Deposito e Valor do cheque. Adicionado novos campos
 *							   para filtro, numero de conta e numero de cheque, conforme
 *							   solicitado na melhoria 300189 (Kelvin).
 *							   
 * --------------
 */

?>

<form id="frmCab" name="frmCab" class="formulario cabecalho">

	<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
				
	<label for="cddopcao" align="center"><? echo utf8ToHtml('Opção:') ?></label>
	<select id="cddopcao" name="cddopcao" align="center">	
		<option value="C" selected > C - Consulta </option>		
		<option value="R" > R - Relatorio </option>
		<option value="D" > D - Devolvidos </option>
	</select>
	
	<a href="#" class="botao" id="btnOK" >OK</a>
	
	<br style="clear:both" />
	
</form>

<form id="frmConsulta" name="frmConsulta" class="formulario">
	<fieldset id="fsetConsulta" name="fsetConsulta" style="padding:0px; margin:0px; padding-bottom:10px;">
		<legend>Consulta</legend>
		<table>
			<tr>
				<td>
					<label for="dtmvtola"><? echo utf8ToHtml('Data do Deposito:') ?></label>
					<input id="dtmvtola" name="dtmvtola" type="text"/>	
					<br style="clear:both"> 					
					<label for="vlcheque"><? echo utf8ToHtml('Valor do cheque:') ?></label>
					<input id="vlcheque" name="vlcheque" type="text"/>
				</td>
				<td style="width:250px;">
					<label for="nrdconta"><? echo utf8ToHtml('Conta/DV:') ?></label>
					<input id="nrdconta" name="nrdconta" type="text"/>
					<br style="clear:both"> 					
					<label for="nrcheque"><? echo utf8ToHtml('Nr. Cheque:') ?></label>
					<input id="nrcheque" name="nrcheque" type="text" maxlength="10"/>
				</td>
			</tr>
		
		</table>
		<input type="hidden" name="hdnrcheque" id="hdnrcheque">
		<input type="hidden" name="hdnrdconta" id="hdnrdconta">
	</fieldset>	
</form>

<form id="frmRelatorio" name="frmRelatorio" class="formulario">
	<fieldset id="fsetRelatorio" name="fsetRelatorio" style="padding:0px; margin:0px; padding-bottom:10px;">
	<legend> <? echo utf8ToHtml('Relatório'); ?> </legend>		
					
		<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
		
		<label for="dtmvtini"><? echo utf8ToHtml('Data inicial:') ?></label>
		<input id="dtmvtini" name="dtmvtini" type="text"/>
		
		<label for="dtmvtfim"><? echo utf8ToHtml('Data final:') ?></label>
		<input id="dtmvtfim" name="dtmvtfim" type="text"/>
		
		<label for="cdbccxlt"><? echo utf8ToHtml('Captura:') ?></label>
		<select id="cdbccxlt" name="cdbccxlt">	
			<option value="0" selected >TODOS</option>		
			<option value="1" >CAIXA</option>
			<option value="2" >CUSTODIA</option>
			<option value="3" >DESCONTO</option>
			<option value="4" >LANCHQ</option>
		</select>

		<label for="tpdsaida"><? echo utf8ToHtml('Saida:') ?></label>
		<select id="tpdsaida" name="tpdsaida">	
			<option value="P" selected > .PDF </option>		
			<option value="T" > .TXT </option>				
		</select>
		
		<br style="clear:both" />
	</fieldset>
</form>

<form id="frmDevolvidos" name="frmDevolvidos" class="formulario">
	<fieldset id="fsetDevolvidos" name="fsetDevolvidos" style="padding:0px; margin:0px; padding-bottom:10px;">
	<legend>Devolvidos</legend>
		<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
		<label for="dtdevolu"><? echo utf8ToHtml('Data de Devolução:') ?></label>
		<input id="dtdevolu" name="dtdevolu" type="text"/>
		
		<br style="clear:both" />
	</fieldset>
</form>

