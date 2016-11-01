<?
/*!
 * FONTE        : form_cab_geral.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Janeiro/2014
 * OBJETIVO     : Mostrar tela PRMRBC
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
<form id="frmGeral" name="frmGeral" class="formulario" onSubmit="return false;" style="display:none">

	<div id="divGeral" style="display:none">

		<fieldset>

			<legend>Geral</legend>

			<br style="clear:both" />

			<label for="hrdenvio"><? echo utf8ToHtml('Hor&aacute;rio Envio:')?></label>
			<input id="hrdenvio" name="hrdenvio" type="text" value=""></input>

			<label for="hrdreton"><? echo utf8ToHtml('Hor&aacute;rio Retorno:')?></label>
			<input id="hrdreton" name="hrdreton" type="text" value=""></input>
			
			<br style="clear:both" />
			<br style="clear:both" />

			<label for="hrdencer"><? echo utf8ToHtml('Hor&aacute;rio Devolu&ccedil;&atilde;o:')?></label>
			<input id="hrdencer" name="hrdencer" type="text" value=""></input>
			
			<label for="hrdencmx"><? echo utf8ToHtml('as&nbsp;')?></label>
			<input id="hrdencmx" name="hrdencmx" type="text" value=""></input>

			<br style="clear:both" />
			<br style="clear:both" />

			<label for="dsdirarq"><? echo utf8ToHtml('Diret&oacute;rio tempor&aacute;rio de trabalho com os arquivos:')?></label>
			<input id="dsdirarq" name="dsdirarq" type="text" value=""></input>
			
			<br style="clear:both" />
			<br style="clear:both" />

			<label for="desemail"><? echo utf8ToHtml('E-mail para recebimento de alertas no  processo (Separar por ",")&nbsp;')?></label>
			<textarea name="desemail" id="desemail" rows="5" cols="100" style="font-size:11px;border:1px solid #777;background-color:#fff;color:#111;"></textarea>

		</fieldset>
	</div>
	
    <br style="clear:both" />
</form>