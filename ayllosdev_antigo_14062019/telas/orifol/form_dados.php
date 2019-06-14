<?
/*!
 * FONTE        : form_dados.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Maio/2015
 * OBJETIVO     : Mostrar tela ORIFOL
 * --------------
 * ALTERAÇÕES   : 09/09/2015 - Retirada a opção N da coluna 'Permite varias no mês' (Vanessa)
 * --------------
 */

session_start();
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");
require_once("../../includes/controla_secao.php");
isPostMethod();

require_once("../../class/xmlfile.php");

$indrowid   	= (isset($_POST['indrowid'])) ? $_POST['indrowid'] : '' ;
$regCdorigem    = (isset($_POST['regCdorigem'])) ? $_POST['regCdorigem'] : '' ;
$regDsorigem    = (isset($_POST['regDsorigem'])) ? $_POST['regDsorigem'] : '' ;
$regIdvarmes    = (isset($_POST['regIdvarmes'])) ? $_POST['regIdvarmes'] : '' ;
$regCdhisdeb    = (isset($_POST['regCdhisdeb'])) ? $_POST['regCdhisdeb'] : '' ;
$regCdhiscre    = (isset($_POST['regCdhiscre'])) ? $_POST['regCdhiscre'] : '' ;
$regCdhsdbcp    = (isset($_POST['regCdhsdbcp'])) ? $_POST['regCdhsdbcp'] : '' ;
$regCdhscrcp    = (isset($_POST['regCdhscrcp'])) ? $_POST['regCdhscrcp'] : '' ;
$regFldebfol    = (isset($_POST['regFldebfol'])) ? $_POST['regFldebfol'] : '' ;

?>
<form id="frmDados" name="frmDados" class="formulario" onSubmit="return false;" style="display:block">

	<br style="clear:both" />

	<input type="hidden" id="indrowid" name="indrowid" value="<? echo $indrowid; ?>" />

	<label for="cdoriflh"><? echo utf8ToHtml('Origem:') ?></label>
	<input id="cdoriflh" name="cdoriflh" type="text" value="<? echo $regCdorigem; ?>" <? echo $indrowid !='' ? 'disabled' : '' ?>/>
	
	<br style="clear:both" />
	
	<label for="dsoriflh"><? echo utf8ToHtml('Descri&ccedil;&atilde;o:') ?></label>
	<input id="dsoriflh" name="dsoriflh" type="text" value="<? echo $regDsorigem; ?>" />

	<br style="clear:both" />

	<label for="idvarmes"><? echo utf8ToHtml('Permite v&aacute;rios no m&ecirc;s:') ?></label>
	<select id="idvarmes" name="idvarmes">
		<option value="S" <? echo $regIdvarmes == 'S' ? 'selected' : '' ?> ><? echo utf8ToHtml('Sim') ?></option>
		<option value="A" <? echo $regIdvarmes == 'A' ? 'selected' : '' ?> ><? echo utf8ToHtml('Sim, mas com alerta') ?></option>		
	</select>

	<br style="clear:both" />
	
	<label for="fldebfol"><? echo utf8ToHtml('Verifica d&eacute;bitos vinc. a folha:') ?></label>
	<select id="fldebfol" name="fldebfol">
		<option value="S" <? echo $regFldebfol == 'S' ? 'selected' : '' ?> ><? echo utf8ToHtml('Sim') ?></option>
		<option value="N" <? echo $regFldebfol == 'N' ? 'selected' : '' ?> ><? echo utf8ToHtml('N&atilde;o') ?></option>
	</select>

	<br style="clear:both" />
	<br style="clear:both" />
	<br style="clear:both" />

	<pre><b>Hist&oacute;ricos p/ Empresas:                    Hist&oacute;ricos p/ Cooperativas:</b></pre>
	
	<br style="clear:both" />

	<label for="cdhisdeb"><? echo utf8ToHtml('D&eacute;bito:') ?></label>
	<input id="cdhisdeb" name="cdhisdeb" type="text" autocomplete="no" value="<? echo $regCdhisdeb ?>" />
	
	<label for="cdhsdbcp"><? echo utf8ToHtml('D&eacute;bito:') ?></label>
	<input id="cdhsdbcp" name="cdhsdbcp" type="text" value="<? echo $regCdhsdbcp ?>" />
	
	<br style="clear:both" />
	
	<label for="cdhiscre"><? echo utf8ToHtml('Cr&eacute;dito:') ?></label>
	<input id="cdhiscre" name="cdhiscre" type="text" autocomplete="no" value="<? echo $regCdhiscre ?>" />
	
	<label for="cdhscrcp"><? echo utf8ToHtml('Cr&eacute;dito:') ?></label>
	<input id="cdhscrcp" name="cdhscrcp" type="text" value="<? echo $regCdhscrcp ?>" />

	<br style="clear:both" />
	<br style="clear:both" />

	<div id="divBotoes">
		<input type="image" src="<?php echo $UrlImagens; ?>botoes/ok.gif"     onClick="gravarPagamento();return false;"/>
		<input type="image" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="encerraRotina(true);return false;"/>
	</div>

</form>

<script type="text/javascript">
	// Bloqueia o conteudo em volta da divRotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
</script>