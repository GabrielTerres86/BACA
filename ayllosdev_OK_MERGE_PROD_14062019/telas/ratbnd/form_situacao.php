<?
/*!
 * FONTE        : form_situacao.php
 * CRIA��O      : Andre Santos - SUPERO
 * DATA CRIA��O : 25/11/2013
 * OBJETIVO     : Formul�rio situa��o de risco - Tela RATBND
 * --------------
 * ALTERA��ES   :
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

<form id="frmSituacao" name="frmSituacao" class="formulario">
	<fieldset>
		<legend><b><? echo utf8ToHtml('Situa&ccedil;&atilde;o da Proposta') ?></b></legend>
		<br/>
		<label for="dssitcrt"><? echo utf8ToHtml('Situa&ccedil;&atilde;o:') ?></label>
		<input id="dssitcrt" name="dssitcrt" type="text" value="<? echo $dssitcrt;?>"/>
		<div id="divNumContrato" style="display:none">
			<label for="nvctrato"><? echo utf8ToHtml('Contrato:') ?></label>
			<input id="nvctrato" name="nvctrato" type="text" value="<? echo $nvctrato;?>"/>
		</div>
	</fieldset>
</form>