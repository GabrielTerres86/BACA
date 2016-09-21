<?
/*!
 * FONTE        : form_dados.php                         Última alteração: 29/10/2015
 * CRIAÇÃO      : Jéssica - DB1
 * DATA CRIAÇÃO : 19/10/2015
 * OBJETIVO     : Mostrar tela de dados da CADINF
 * --------------
 * ALTERAÇÕES   : 29/10/2015 - Ajustes de homologação refente a conversão realizada pela DB1
							   (Adriano).
 * --------------
 */

	session_start();
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	require_once("../../includes/controla_secao.php");
	isPostMethod();

	require_once("../../class/xmlfile.php");

	$nrdrowid    = (isset($_POST['nrdrowid'])) ? $_POST['nrdrowid'] : '' ;
	$regNmrelato = $_POST["regNmrelato"];
	$regDsfenvio = $_POST["regDsfenvio"];
	$regDsperiod = $_POST["regDsperiod"];
	$regFlgtitul = $_POST["regFlgtitul"];
	$regFlgobrig = $_POST["regFlgobrig"];
	$regCdrelato = $_POST["regCdrelato"];
	$regCdprogra = $_POST["regCdprogra"];
	$regCddfrenv = $_POST["regCddfrenv"];
	$regCdperiod = $_POST["regCdperiod"];
	$regTodosTit = $_POST["regTodosTit"];


?>
<form id="frmDados" name="frmDados" class="formulario" onSubmit="return false;" style="display:block">

	<input type="hidden" id="nrdrowid" name="nrdrowid" value="<? echo $nrdrowid; ?>" />
	
	<fieldset style="width:445px;height:170px;margin: 10px auto;">
	
	    <legend><b><? echo utf8ToHtml('Informativo e forma de envio') ?></b></legend>
		
		<br style="clear:both" />
	
		<label for="nmrelato"><? echo utf8ToHtml('Informativo:') ?></label>
		<input id="nmrelato" name="nmrelato" type="text" value="<? echo utf8ToHtml($regNmrelato); ?>" />
		
		<br style="clear:both" />
		
		<label for="dsfenvio"><? echo utf8ToHtml('Forma Envio:') ?></label>
		<input id="dsfenvio" name="dsfenvio" type="text" autocomplete="no" value="<? echo utf8ToHtml($regDsfenvio); ?>" />
		
		<br style="clear:both" />
		
		<label for="dsperiod"><? echo utf8ToHtml('Periodo:') ?></label>
		<input id="dsperiod" name="dsperiod" type="text" autocomplete="no" value="<? echo utf8ToHtml($regDsperiod); ?>" />
		
		<input id="cdrelato" name="cdrelato" type="hidden" autocomplete="no" value="<? echo $regCdrelato; ?>" />
		<input id="cdprogra" name="cdprogra" type="hidden" autocomplete="no" value="<? echo $regCdprogra; ?>" />
		<input id="cddfrenv" name="cddfrenv" type="hidden" autocomplete="no" value="<? echo $regCddfrenv; ?>" />
		<input id="cdperiod" name="cdperiod" type="hidden" autocomplete="no" value="<? echo $regCdperiod; ?>" />
		
		<br style="clear:both" />
		
				
		<label for="envcpttl"><? echo utf8ToHtml('Todos Titulares: ') ?></label>
		<select id="envcpttl" name="envcpttl" onchange="controlaTitular();">	
			<option value= 0 <?php echo ($regFlgtitul == 0) ? "selected":""; ?> ><? echo utf8ToHtml('Sim')?> </option>
			<option value= 1 <?php echo ($regFlgtitul == 1) ? "selected":""; ?> ><? echo utf8ToHtml('Nao')?> </option>
		</select>

		
		<br style="clear:both" />
		
		<label for="envcobrg"><? echo utf8ToHtml('Envio Obrigatorio:') ?></label>
		<select id="envcobrg" name="envcobrg">	
			<option value= 1 <?php echo ($regFlgobrig == 1) ? "selected":""; ?> ><? echo utf8ToHtml('Sim')?> </option>
			<option value= 0 <?php echo ($regFlgobrig == 0) ? "selected":""; ?> ><? echo utf8ToHtml('Nao')?> </option>
		</select>
		
	</fieldset>

</form>

<div id="divBotoesInclui" style="display:none;">
	
	<a href="#" class="botao" id="btVoltar"   onClick="encerraRotina(true);return false;">Voltar</a>
	<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','gravarInformativo();','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));','sim.gif','nao.gif');return false;">Concluir</a>
	
</div>

<script type="text/javascript">

	$('#divBotoesInclui').css({'display':'block','display':'inline'});
	$('#btVoltar','#divBotoesInclui').css({'display':'inline'});
	$('#btConcluir','#divBotoesInclui').css({'display':'inline'});
	
	// Bloqueia o conteudo em volta da divRotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
	
</script>