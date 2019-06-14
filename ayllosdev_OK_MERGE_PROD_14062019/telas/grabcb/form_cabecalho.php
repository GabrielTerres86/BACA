<?
/*!
 * FONTE        : form_cabecalho.php
 * CRIAÇÃO      : Jean Michel         
 * DATA CRIAÇÃO : 09/04/2014
 * OBJETIVO     : Cabecalho para a tela GRABCB
 * PROJETO		: Projeto de Novos Cartões Bancoob
 * --------------
 * ALTERAÇÕES   : 02/07/2014 - ocultado campo PA (Lucas Lunelli)
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
			<td colspan="2"> 	
				<label for="cddopcao"><? echo utf8ToHtml('Op&ccedil;&atilde;o:') ?></label>
				<select id="cddopcao" name="cddopcao" onChange="mudaOpcao();">
					<option value="A" >A - Alterar Grupo de Afinidade</option>
					<option value="C" >C - Consultar Grupo de Afinidade</option>
					<option value="E" >E - Excluir Grupo de Afinidade</option>
					<option value="I" >I - Incluir Grupo de Afinidade</option>
				</select>
				<a href="#" class="botao" id="btnOK" name="btnOK" onClick="escolheOpcao(); return false;" style = "text-align:right;">OK</a>
			</td>
		</tr>
        <tr>		
			<td  colspan="2">
				<label for="cdgrafin"><? echo utf8ToHtml('C&oacute;digo:') ?></label>
				<input type="text" id="cdgrafin" name="cdgrafin" />
			</td>
		</tr>			
		<tr>		
			<td>
				<!--<div id="divCdcooper" name="divCdcooper">-->
					<label name="label_cdcooper" for="nmrescop">Cooperativa:</label>
					<input type="hidden" id="cdcopaux" name="cdcopaux" value="<? echo $cdcooper ?>" />
					<input type="text" id="nmrescop" name="nmrescop" value="<? echo $nmrescop ?>" />
					<a name="lupa_cdcooper" href="#" onclick="controlaPesquisas(1); return false;"  style="padding: 3px 0 0 3px;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
				<!--</div>-->
			</td>						
			<td>
				<label for="cdagenci">PA:</label>
				<input type="text" id="cdagenci" name="cdagenci" value="<? echo $cdagenci ?>" />
				<a href="#" onclick="controlaPesquisas(2); return false;" style="padding: 3px 0 0 3px; display: none;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
			</td>			
		</tr>		
		<tr>		
			<td colspan="2">
				<label for="slcadmin"><? echo utf8ToHtml('Administradora:') ?></label>
				<select id="slcadmin" name="slcadmin" >
					<option value="0" ></option>
				</select>
			</td>
		</tr>
	</table>
</form>