<?php
/*!
 * FONTE        : form_admiss.php
 * CRIAÇÃO      : Lucas Lunelli         
 * DATA CRIAÇÃO : 06/02/2013
 * OBJETIVO     : Formulario de exibição de dados da tela ADMISS
 * --------------
 * ALTERAÇÕES   : 29/07/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 *				  
 * --------------
 */		

    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php'); 
    require_once('../../class/xmlfile.php');
    isPostMethod();
?>

<form id="frmDadosAdmiss" name="frmDadosAdmiss" class="formulario" onSubmit="return false;" style = "display:none;">
	<fieldset>
		<legend> <? echo utf8ToHtml('Valores') ?> </legend>
		<table width = "100%">
			<tr>
				<td>
					<label for="nrmatric">&Uacute;ltimo n&uacute;mero de matr&iacute;cula utilizado:</label>
					<input type="text" id="nrmatric" name="nrmatric" value="" />
				</td>
			</tr>
			<tr>
				<td>
					<label for="qtassmes">Quantidade de admiss&otilde;es no mes:</label>
					<input type="text" id="qtassmes" name="qtassmes" value="" />
				</td>
			</tr>
			<tr>
				<td>
					<label for="qtdslmes">Cooperados desligados no m&ecirc;s:</label>
					<input type="text" id="qtdslmes" name="qtdslmes" value="" />
				</td>
			</tr>
			<tr>
				<td>
					<label for="qtadmmes">Cooperados readmitidos no m&ecirc;s:</label>
					<input type="text" id="qtadmmes" name="qtadmmes" value="" />
				</td>
			</tr>
			<tr>
				<td>
					<label for="vlcapsub">Valor da subscri&ccedil;&atilde;o de capital:</label>
					<input type="text" id="vlcapsub" name="vlcapsub" value="" />
				</td>
			</tr>
			<tr>
				<td>
					<label for="vlcapini">Valor do capital m&iacute;nimo:</label>
					<input type="text" id="vlcapini" name="vlcapini" value="" />
				</td>
			</tr>
			<tr>
				<td>
					<label for="qtparcap">Quantidade m&aacute;xima de parcelamento mensal:</label>
					<input type="text" id="qtparcap" name="qtparcap" value="" />
				</td>
			</tr>
			<tr>
				<td>
					<label for="flgabcap"><? echo utf8ToHtml('Abonar CPMF sobre lancamentos do capital:') ?></label>
					<select id="flgabcap" name="flgabcap">
						<option value="YES">SIM</option> 
						<option value="NO">N&Atilde;O</option> 
					</select>
				</td>
			</tr>
			<tr>
				<td> &nbsp; </td>
			</tr>
		</table>
	</fieldset>	
</form>