<?php
/*!
 * FONTE        : form_cadastro.php
 * CRIAÇÃO      : Lucas Afonso
 * DATA CRIAÇÃO : 06/10/2017
 * OBJETIVO     : Formulario com os parametros
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */ 
?>

<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<form id="frmParametros" name="frmParametros" class="formulario condensado">
	<div id="divParametros" >

		<fieldset id="fsetParametrosGerais" name="fsetParametrosGerais" style="padding-bottom:10px;">
			
			<legend align="center">Par&acirc;metros Gerais</legend>

			<table width="100%">
				<tr>
					<td>
						<label for="inresgate_automatico"><? echo utf8ToHtml('Resgate Autom&aacute;tico?') ?></label>
						<input type="checkbox" id="inresgate_automatico" name="inresgate_automatico" onChange="verificaCampoQtDias(this)">
					</td>
				</tr>
				<tr>
					<td>
						<label for="qtdias_atraso_permitido"><? echo utf8ToHtml('Dias de atraso p/ resgate autom&aacute;tico:') ?></label>
						<input id="qtdias_atraso_permitido" name="qtdias_atraso_permitido" type="text"/>
					</td>
				</tr>
			</table>
		</fieldset>
	
		<fieldset id="fsetParametrosLinhasGenericas" name="fsetParametrosLinhasGenericas" style="padding-bottom:10px;">
			
			<legend align="center">Par&acirc;metros para Linhas Gen&eacute;ricas</legend>

			<table width="100%">
				<tr>
					<td>
						<label for="peminimo_cobertura"><? echo utf8ToHtml('% M&iacute;n Cobertura p/ Garantia:') ?></label>
						<input id="peminimo_cobertura" name="peminimo_cobertura" type="text"/> <label><? echo utf8ToHtml('&nbsp;%') ?></label>
					</td>
				</tr>
			</table>
		</fieldset>
	</div>
</form>