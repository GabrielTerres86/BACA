<? 
/*!
 * FONTE        : form_opcao_i.php
 * CRIAÇÃO      : Helinton Steffens - (Supero)
 * DATA CRIAÇÃO : 13/03/2018 
 * OBJETIVO     : Formulario para conciliar uma ted.
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	include('form_cabecalho.php');
?>

<form id="frmOpcao" class="formulario" onSubmit="return false;">

	<div id="divFiltro">
		<div>
			<label for="inidtpro"><? echo utf8ToHtml('Data inicial');  ?>:</label>
			<input type="text" id="inidtpro" name="inidtpro" value="<?php echo $inidtpro ?>"/>

			<label for="fimdtpro"><? echo utf8ToHtml('Data fim:');  ?></label>
			<input type="text" id="fimdtpro" name="fimdtpro" value="<?php echo $fimdtpro ?>" />

			<label for="inivlpro"><? echo utf8ToHtml('Valor inicial');  ?>:</label>
			<input type="text" id="inivlpro" name="inivlpro" value="<?php echo $inivlpro ?>"/>

			<label for="fimvlpro"><? echo utf8ToHtml('Valor fim:');  ?></label>
			<input type="text" id="fimvlpro" name="fimvlpro" value="<?php echo $fimvlpro ?>" />
			<br style="clear:both" /> 
			<label for="indconci">Status da concilia&ccedil&atildeo:</label>
			<select id="indconci" name="indconci" onchange="tipoOptionT();">
				<option value="pedente"<?php echo $indconci == 'pedente' ? 'selected' : '' ?> ><? echo utf8ToHtml('Pendente') ?></option>
				<option value="conciliado" <?php echo $indconci == 'conciliado'  ? 'selected' : '' ?> ><? echo utf8ToHtml('Conciliado') ?></option>
			</select>
			<label for="dscartor"><? echo utf8ToHtml('Cart&oacuterio de origem');  ?>:</label>
			<input type="text" id="dscartor" name="dscartor" value="<?php echo $dscartor ?>"/>
		</div>
	</div>		
</form>


<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnContinuar(); return false;" ><? echo utf8ToHtml('AvanÃ§ar'); ?></a>
</div>





