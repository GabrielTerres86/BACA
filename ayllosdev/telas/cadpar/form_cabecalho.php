<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Daniel Zimmermann         
 * DATA CRIAÇÃO : 06/03/2013
 * OBJETIVO     : Cabecalho para a tela CADPAR
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 * 24/03/2015 - Adicionado campo Produto. (Jorge/Rodrigo - SD 229250)
 */
	
	session_start();
	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
?>

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" >
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao" style="width: 460px;">
					<option value="C"><? echo utf8ToHtml('C - Consultar Par&acirc;metro') ?></option> 
					<option value="A"><? echo utf8ToHtml('A - Alterar Par&acirc;metro') ?></option>
					<option value="E"><? echo utf8ToHtml('E - Excluir Par&acirc;metro') ?></option>
					<option value="I"><? echo utf8ToHtml('I - Incluir Par&acirc;metro') ?></option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
		<tr>
			<td>
				<label for="cdpartar"><? echo utf8ToHtml('C&oacute;digo:') ?></label>
				<input type="text" id="cdpartar" name="cdpartar" value="<? echo $cdpartar == 0 ? '' : $cdpartar ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
			</td>
		</tr>
		<tr>
			<td>
				<label for="nmpartar"><? echo utf8ToHtml('Nome do par&acirc;metro:') ?></label>
				<input type="text" class="campo" name="nmpartar" id="nmpartar"  value="<? echo utf8ToHtml($nmpartar); ?>" /> 
			</td>
		</tr>
        <tr>		
			<td>
				<label for="tpdedado"><? echo utf8ToHtml('Tipo de dado:') ?></label>
				<select id="tpdedado" name="tpdedado" style="width: 260px;">
					<option value="1"><? echo utf8ToHtml('1 - INTEIRO') ?> </option> 
					<option value="2"><? echo utf8ToHtml('2 - TEXTO') ?> </option>
					<option value="3"><? echo utf8ToHtml('3 - VALOR') ?> </option>
					<option value="4"><? echo utf8ToHtml('4 - DATA') ?> </option>
				</select>
			</td>
		</tr>
		<tr>
			<td>
				<label for="dsprodut"><? echo utf8ToHtml('Produto:') ?></label>
				<input type="hidden" id="cdprodut" name="cdprodut" value="<? echo $cdprodut; ?>" />	
				<input type="text" id="dsprodut" name="dsprodut" value="<? echo $dsprodut; ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(3);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
			</td>
		</tr>
	</table>
	<br style="clear:both" />
</form>