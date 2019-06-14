<?php
	/*!
	 * FONTE        : form_consultar.php
	 * CRIAÇÃO      : Kelvin Souza Ott
	 * DATA CRIAÇÃO : 13/05/2016
	 * OBJETIVO     : Formulario para consultar as nacionalidades
	 * --------------
	 * ALTERAÇÕES   : 
	 * --------------
	 */
	 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');		
	isPostMethod();	
	
?>
<form id="frmConsultar" name="frmConsultar" class="formulario" style="display:block;">
	<fieldset id="fsetFiltroNacionalidade" name="fsetFiltroNacionalidade" style="padding:0px; margin:0px; padding-bottom:10px;">	
		<legend>Filtro</legend>
		
		<table width="100%">
			<tr>
				<td>
					<label for="dsnacion"><? echo utf8ToHtml("Nacionalidade.:"); ?></label>
					<input name="dsnacion" id="dsnacion" type="text" maxlength="25" value="">					
				</td>
			</tr>
		</table>
		
	</fieldset>
	<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btnConcluir" name="btnConcluir" style = "text-align:right;">Concluir</a>
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar(); return false;">Voltar</a>
	</div>
</form>