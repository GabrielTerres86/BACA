<?
/*!
 * FONTE        : form_dados.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Maio/2015
 * OBJETIVO     : Mostrar tela ESTFOL
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

session_start();
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");
isPostMethod();

require_once("../../class/xmlfile.php");

$cdempres   	= (isset($_POST['cdempres'])) ? $_POST['cdempres'] : '' ;
$dtsolest		= (isset($_POST['dtsolest'])) ? $_POST['dtsolest'] : '' ;
$vlestour   	= (isset($_POST['vlestour'])) ? $_POST['vlestour'] : '' ;
$cdeftpag   	= (isset($_POST['cdeftpag'])) ? $_POST['cdeftpag'] : '' ;
$dsjustif   	= (isset($_POST['dsjustif'])) ? $_POST['dsjustif'] : '' ;

/* Monta mensagem dinamica para enviar e-mail
   Esse campo pode ser editado pelo Usuario
*/

$msg="";
$rodapeMsg="Atenciosamente,
Sistema AILOS";

if($cdeftpag==4){$msg="aprovado e os pagamentos de Folha serão efetuados.";}
if($cdeftpag==3){$msg="reprovado e os pagamentos de Folha não serão efetuados.

 Lembramos que você poderá aprovar os pagamentos novamente, mas deverá ter saldo e/ou limite de crédito suficiente em sua conta corrente.";}

/* Mensagem escrita dinamicamento. Os espacamentos sao usados da exibir a mensagem de forma adequada */
$msgJustificativa = "Informamos que o estouro de sua conta no valor de R$ $vlestour foi $msg



$rodapeMsg";

?>
<form id="frmDados" name="frmDados" class="formulario" onSubmit="return false;" style="display:block">

	<br style="clear:both" />

	<input type="hidden" id="cdempres" name="cdempres" value="<? echo $cdempres; ?>" />
    <input type="hidden" id="dtsolest" name="dtsolest" value="<? echo $dtsolest; ?>" />
	<input type="hidden" id="cdeftpag" name="cdeftpag" value="<? echo $cdeftpag; ?>" />

	<label for="dsjustif"><? echo utf8ToHtml('Por Favor, informe a justificativa para a opera&ccedil;&atilde;o (Obrigat&oacute;rio):')?></label>
	<br style="clear:both" />
	<textarea name="dsjustif" placeholder="Digite sua justificativa..." id="dsjustif" style="overflow:auto;font-size:11px;border:1px solid #777;background-color:#fff;color:#111;"></textarea>

	<br style="clear:both" />

	<fieldset style="width:445px;height:180px;margin: 20px auto;">

	    <legend><b><? echo utf8ToHtml('E-mail de alerta ao cooperado') ?></b></legend>

		<br style="clear:both" />

		<label for="dsmsgeml"><? echo utf8ToHtml('Mensagem sugerida (Voc&ecirc; pode alter&aacute-lo):')?></label>
		<br style="clear:both" />		
		<textarea name="dsmsgeml" id="dsmsgeml" placeholder="Digite o corpo do e-mail..." style="overflow:auto;font-size:11px;border:1px solid #777;background-color:#fff;color:#111;"><? echo $msgJustificativa; ?></textarea>

	</fieldset>

	<div id="divBotoes">
		<input type="image" src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onClick="aprovaReprovaEstouro(<? echo $cdeftpag;?>);"/>
		<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"   onClick="encerraRotina(true);return false;"/>
	</div>

</form>

<script type="text/javascript">
	// Bloqueia o conteudo em volta da divRotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
</script>