<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Tiago Machado         
 * DATA CRIAÇÃO : 26/02/2013
 * OBJETIVO     : Cabecalho para a tela CADINT
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" style="display:none">
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao" style="width: 460px;">
					<option value="C"><? echo utf8ToHtml('C - Consultar tipo de incid&ecirc;ncia') ?> </option> 
					<option value="A"><? echo utf8ToHtml('A - Alterar tipo de incid&ecirc;ncia') ?> </option>
					<option value="E"><? echo utf8ToHtml('E - Excluir tipo de incid&ecirc;ncia') ?> </option>
					<option value="I"><? echo utf8ToHtml('I - Incluir tipo de incid&ecirc;ncia') ?> </option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
        <tr>		
			<td>
				<label for="cdinctar"><? echo utf8ToHtml('C&oacute;digo:') ?></label>
				<input type="text" id="cdinctar" name="cdinctar" value="<? echo $cdinctar == 0 ? '' : $cdinctar ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa();return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
				<input type="text" class="campo alphanum" name="dsinctar" id="dsinctar"  value="<? echo $dsinctar; ?>" />
				<input type="checkbox" name="flgocorr" id="flgocorr" value="no"/> <label for="flgocorr" style="width:260px;text-align:left"> <? echo utf8ToHtml('Permite informar ocorr&ecirc;ncia') ?></label>
				<input type="checkbox" name="flgmotiv" id="flgmotiv" value="no"/> <label for="flgmotiv"> <? echo utf8ToHtml('Permite informar o motivo da ocorr&ecirc;ncia') ?> </label>
			</td>
		</tr>		
	</table>
</form>