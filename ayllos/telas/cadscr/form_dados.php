<?
	/*!
	 * FONTE        : form_dados.php							Último ajuste: 08/12/2015
	 * CRIAÇÃO      : Jéssica - DB1
	 * DATA CRIAÇÃO : Outubro/2015
	 * OBJETIVO     : Mostrar tela CADSCR
	 * --------------
	 * ALTERAÇÕES   : 08/12/2015 - Ajustes de homologação referente a conversão efetuada pela DB1
								  (Adriano).
	 * --------------
	 */

	session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	isPostMethod();

	require_once("../../class/xmlfile.php");

	$regCdhistor = $_POST["regCdhistor"];
	$regDshistor = $_POST["regDshistor"];
	$regDstphist = $_POST["regDstphist"];
	$regVllanmto = $_POST["regVllanmto"];

?>

<form id="frmDados" name="frmDados" class="formulario" onSubmit="return false;" style="display:none">
		
	<fieldset style="width:445px;height:130px;margin: 20px auto;">
	
	   	<legend>Informa&ccedil;&otilde;es</legend>
		
		<label for="cdhistor"><? echo utf8ToHtml('Hist&oacute;rico:') ?></label>
		<input id="cdhistor" name="cdhistor" type="text" value="<? echo utf8ToHtml($regCdhistor); ?>" />
		
		<br style="clear:both" />
		
		<label for="dshistor"><? echo utf8ToHtml('Descri&ccedil;&atilde;o:') ?></label>
		<input id="dshistor" name="dshistor" type="text" autocomplete="no" value="<? echo $regDshistor; ?>" />
		
		<br style="clear:both" />
		
		<label for="dstphist"><? echo utf8ToHtml('Tipo:') ?></label>
		<input id="dstphist" name="dstphist" type="text" autocomplete="no" value="<? echo $regDstphist; ?>" />
		
		<br style="clear:both" />
		
		<label for="vllanmto"><? echo utf8ToHtml('Valor:') ?></label>
		<input id="vllanmto" name="vllanmto" type="text" autocomplete="no" value="<? echo number_format(str_replace(",",".",$regVllanmto),2,",","."); ?>" />

	</fieldset>

</form>

<div id="divBotoesInclui" style='text-align:center; margin-bottom: 10px; display:block;'>

	<a href="#" class="botao" id="btVoltar" onClick="encerraRotina(true);return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar" onClick="showConfirmacao('Deseja confirmar a opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','gravaLancamento();','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));','sim.gif','nao.gif');">Concluir</a>
	
</div>

<script type="text/javascript">
	// Bloqueia o conteudo em volta da divRotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
	$('#frmDados').css('display','block');
</script>