<?
/*!
 * FONTE        : form_prmdpv.php
 * CRIA��O      : Lucas Moreira
 * DATA CRIA��O : 04/09/2015
 * OBJETIVO     : Formulario para tela PRMDPV
 * --------------
 * ALTERA��ES   : 
 * --------------
 */
 ?>

<div id="divPrmdpv" name="divPrmdpv">
	<form id="frmGravaCusto" name="frmGravaCusto" class="formulario" onSubmit="return false;">
		<fieldset>
			<legend><?php echo $acao?> de Custo Bilhete por Exerc�cio</legend>
			<table width="100%">
				<tr>		
					<td width="60px">
						<label for="exercicio"><? echo utf8ToHtml('Exerc&iacute;cio:') ?></label>	
					</td>
					<td>
						<input name="exercicio" type="text" <?php echo $acao != 'Inclus�o' ? 'readonly' : '' ?> id="exercicio" class='campo' value="<?php echo $exercicio ?>" />
					</td>
				</tr>
				<tr>		
					<td width="60px">
						<label for="integral"><? echo utf8ToHtml('Integral:') ?></label>
					</td>
					<td>
						<input name="integral" type="text"  id="integral" class='campo' value="<?php echo $integral ?>" />
					</td>
				</tr>
				<tr>		
					<td width="60px">
						<label for="parcelado"><? echo utf8ToHtml('Parcelado:') ?></label>
					</td>
					<td>
						<input name="parcelado" type="text"  id="parcelado" class='campo' value="<?php echo $parcelado ?>" />
					</td>
				</tr>
			</table>
		</fieldset>
		
		<div id="divBotoes" style="margin-top:5px; margin-bottom :10px;">
			<a href="#" class="botao" id="btVoltar"  onclick="controlaOperacao('BC');">Voltar</a>
			<a href="#" class="botao" id="btGravar"  onClick="controlaOperacao('GC');">Gravar</a>
		</div>
	</form>
</div>