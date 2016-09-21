<?php
/*!
 * FONTE        : form_dados.php
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 15/03/2016
 * OBJETIVO     : Formulario para a tela MANPAC
 * --------------
 * ALTERAÇÕES   : 
 *
 * --------------
 */

?>
<div id="divDados" name="divDados" style="display: none;" > 
	<fieldset id="fldPacote" class="fldPacote">
		<legend>&nbsp;Servi&ccedil;o Cooperativo Atual&nbsp;</legend>
			<label for="cdpacote"><?php echo utf8ToHtml('C&oacute;digo:') ?></label>	
			<!-- <input name="cdpacote" type="text"  id="cdpacote" class="inteiro" maxlength="10" onBlur="buscaInformacoesPacote(1);"/>-->
			<input name="cdpacote" type="text"  id="cdpacote" class="inteiro" maxlength="10" />	
			<!-- LUPA -->
			<div id="lupaCons">
				<a href="#" onClick="controlaPesquisaPacote();" >
					<img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0" />
				</a>
			</div>
			<input name="dspacote" type="text"  id="dspacote" maxlength="50" readonly />
			<br/>
			<div id="divNaoHabilitar" id="divNaoHabilitar">
				<label for="tppessoa"><?php echo utf8ToHtml('Tipo de Pessoa:') ?></label>	
				<select id="tppessoa" name="tppessoa" disabled>
					<option value="0"></option>
					<option value="1">Pessoa F&iacute;sica</option>
					<option value="2">Pessoa Jur&iacute;dica</option>
				</select>
				<br/>
				<label for="vlpacote"><?php echo utf8ToHtml('Valor:') ?></label>	
				<input name="vlpacote" id="vlpacote" type="text" class="inteiro" readonly />	
			</div>				
		</fieldset>	
	<br style="clear:both" />
</div>

<div id="divHabilitar" name="divHabilitar" style="display: none;" ></div>
