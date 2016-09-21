<?
/*!
 * FONTE        : form_dados.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Maio/2015
 * OBJETIVO     : Mostrar tela CONFOL
 * --------------
 * ALTERAÇÕES   : 23/11/2015 - Ajustado exibicao dos campos
					           (Andre Santos - SUPERO)
 * --------------
 */

session_start();
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");
isPostMethod();

require_once("../../class/xmlfile.php");

$indrowid    = (isset($_POST['indrowid'])) ? $_POST['indrowid'] : '' ;
$regCdcontar = $_POST["regCdcontar"];
$regDscontar = $_POST["regDscontar"];
$regVltarid0 = ($_POST['indrowid']!="") ? $_POST["regVltarid0"] : "0,00";
$regVltarid1 = ($_POST['indrowid']!="") ? $_POST["regVltarid1"] : "0,00";
$regVltarid2 = ($_POST['indrowid']!="") ? $_POST["regVltarid2"] : "0,00";

?>
<form id="frmDados" name="frmDados" class="formulario" onSubmit="return false;" style="display:block">

	<br style="clear:both" />

	<input type="hidden" id="indrowid" name="indrowid" value="<? echo $indrowid; ?>" />

	<label for="cdcontar"><? echo utf8ToHtml('Conv&ecirc;nio:') ?></label>
	<input id="cdcontar" name="cdcontar" type="text" value="<? echo $regCdcontar; ?>" disabled />
	<input id="dscontar" name="dscontar" type="text" value="<? echo $regDscontar; ?>" />

	<br style="clear:both" />
	
	<fieldset style="width:445px;height:120px;margin: 20px auto;">
	
	    <legend><b><? echo utf8ToHtml('Tarifa cfme D&eacute;bito:') ?></b></legend>
		
		<br style="clear:both" />
	
		<label for="vltarid0"><? echo utf8ToHtml('D0:') ?></label>
		<input id="vltarid0" name="vltarid0" type="text" autocomplete="no" onBlur="if (this.value=='') {this.value = '0,00';}" value="<? echo ($regVltarid0=="ERRO") ? "0,00" : $regVltarid0; ?>" />
		
		<br style="clear:both" />
		
		<label for="vltarid1"><? echo utf8ToHtml('D-1:') ?></label>
		<input id="vltarid1" name="vltarid1" type="text" autocomplete="no" onBlur="if (this.value=='') {this.value = '0,00';}" value="<? echo ($regVltarid1=="ERRO") ? "0,00" : $regVltarid1; ?>" />
		
		<br style="clear:both" />
		
		<label for="vltarid2"><? echo utf8ToHtml('D-2:') ?></label>
		<input id="vltarid2" name="vltarid2" type="text" autocomplete="no" onBlur="if (this.value=='') {this.value = '0,00';}" value="<? echo ($regVltarid2=="ERRO") ? "0,00" : $regVltarid2; ?>" />
	</fieldset>

	<div id="divBotoes">
		<input type="image" src="<?php echo $UrlImagens; ?>botoes/ok.gif"     onClick="gravarConvenio();return false;"/>
		<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="encerraRotina(true);return false;"/>
	</div>

</form>

<script type="text/javascript">
	// Bloqueia o conteudo em volta da divRotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
</script>