<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Daniel Zimmermann         
 * DATA CRIAÇÃO : 08/03/2013
 * OBJETIVO     : Cabecalho para a tela CADMET
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

<form id="frmCab" name="frmCab" class="formulario cabecalho" onSubmit="return false;" >
	<table width="100%">
		<tr>		
			<td> 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao" style="width: 460px;">
					<option value="C"><? echo utf8ToHtml('C - Consultar Motivo de Estorno/Baixa de Tarifa') ?></option> 
					<option value="A"><? echo utf8ToHtml('A - Alterar Motivo de Estorno/Baixa de Tarifa') ?></option>
					<option value="E"><? echo utf8ToHtml('E - Excluir Motivo de Estorno/Baixa de Tarifa') ?></option>
					<option value="I"><? echo utf8ToHtml('I - Incluir Motivo de Estorno/Baixa de Tarifa') ?></option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="LiberaCampos(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
		<tr>
			<td>
				<label for="cdmotest"><? echo utf8ToHtml('C&oacute;digo:') ?></label>
				<input type="text" id="cdmotest" name="cdmotest" value="<? echo $cdmotest == 0 ? '' : $cdmotest ?>" />	
				<a style="padding: 3px 0 0 3px;" href="#" onClick="controlaPesquisa(1);return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>
			</td>
		</tr>
		<tr>
			<td>
				<label for="dsmotest"><? echo utf8ToHtml('Descri&ccedil;&atilde;o:') ?></label>
				<input type="text" class="campo alphanum" name="dsmotest" id="dsmotest"  value="<? echo $dsmotest; ?>" />
			</td>
		</tr>
        <tr>		
			<td>
				<label for="tpaplica"><? echo utf8ToHtml('Aplica&ccedil;&atilde;o:') ?></label>
				<select id="tpaplica" name="tpaplica" style="width: 260px;">
					<option value="1"><? echo utf8ToHtml('1 - ESTORNO') ?> </option> 
					<option value="2"><? echo utf8ToHtml('2 - BAIXA') ?> </option>
					<option value="3"><? echo utf8ToHtml('3 - AMBOS') ?> </option>
				</select>
			</td>
		</tr>		
	</table>
	<br style="clear:both" />
</form>