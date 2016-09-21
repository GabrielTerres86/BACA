<form id="frmDados" name="frmDados" class="formulario">
	<div id="divDados" name="divDados" style="display: none;" > 
		<fieldset>
			<legend>&nbsp;Dados do Servi&ccedil;o Cooperativo&nbsp;</legend>
				<br/>
				<label for="cdpacote"><?php echo utf8ToHtml('C&oacute;digo:') ?></label>	
				<!-- <input name="cdpacote" type="text"  id="cdpacote" class="inteiro" maxlength="10" onBLur="buscaInformacoesPacote();"/> -->
				<input name="cdpacote" type="text"  id="cdpacote" class="inteiro" maxlength="10" />
				<!-- LUPA -->
				<div id="divLupa" name="divLupa">
					<a href="#" onClick="controlaPesquisaPacote();" >
						<img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0" />
					</a>
				</div>
				<input name="dspacote" type="text"  class id="dspacote" maxlength="50" readonly />
				<br/>
				<label for="tppessoa"><?php echo utf8ToHtml('Tipo de Pessoa:') ?></label>	
				<select id="tppessoa" name="tppessoa" disabled>
					<option value="0"></option>
					<option value="1">Pessoa F&iacute;sica</option>
					<option value="2">Pessoa Jur&iacute;dica</option>
				</select>
				<br/>
				<label for="cdtarifa_lancamento"><?php echo utf8ToHtml('Tarifa Lan&ccedil;amento:') ?></label>	
				<input name="cdtarifa_lancamento" type="text"  id="cdtarifa_lancamento" class="inteiro" maxlength="10" readonly />
				<!-- LUPA -->
				<div id="divLupaTarifa" name="divLupaTarifa">
					<a href="#" onClick="controlaPesquisaTarifa();" >
						<img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0" />
					</a>
				</div>
				<input name="dstarifa" type="text"  id="dstarifa" maxlength="50" readonly />
				<br/>
				<label for="dtcancelamento"><?php echo utf8ToHtml('Data Cancelamento:') ?></label>	
				<input name="dtcancelamento" type="text"  id="dtcancelamento" class="inteiro" readonly />					
			</fieldset>	
		<br style="clear:both" />
	</div>
	<div id="divDadosIncluir" name="divDadosIncluir" style="display: none;" > 
		<fieldset>
			<legend>&nbsp;Dados do Serviço Cooperativo</legend>
				<label for="cdpacoteInc"><?php echo utf8ToHtml('C&oacute;digo:') ?></label>	
				<input name="cdpacoteInc" type="text"  id="cdpacoteInc" class="inteiro" maxlength="10" />
				<br />
				<label for="dspacoteInc"><?php echo utf8ToHtml('Descri&ccedil;&atilde;o:') ?></label>	
				<input name="dspacoteInc" type="text"  id="dspacoteInc" maxlength="50" class="alphanum" />
				<br/>
				<label for="tppessoaInc"><?php echo utf8ToHtml('Tipo de Pessoa:') ?></label>	
				<select id="tppessoaInc" name="tppessoaInc" onChange="limpaTarifa();" >
					<option value="0"></option>
					<option value="1">Pessoa F&iacute;sica</option>
					<option value="2">Pessoa Jur&iacute;dica</option>
				</select>
				<br/>
				<label for="cdtarifa_lancamentoInc"><?php echo utf8ToHtml('Tarifa Lan&ccedil;amento:') ?></label>	
				<input name="cdtarifa_lancamentoInc" type="text"  id="cdtarifa_lancamentoInc" class="inteiro" maxlength="10" onBlur="carregaTarifa();"/>
				<!-- LUPA -->
				<a href="#" onClick="controlaPesquisaTarifa();" >
					<img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" width="14" height="14" border="0" />
				</a>
				<input name="dstarifaInc" type="text"  id="dstarifaInc" maxlength="50" readonly onKeyPress="return false;" onKeyDown="return false;" />	
		</fieldset>	
		<br style="clear:both" />
	</div>
</form>
