<?php
	/*!
	 * FONTE        : tab_habilitar.php
	 * CRIAÇÃO      : Jean Michel        
	 * DATA CRIAÇÃO : 16/03/2016
	 * OBJETIVO     : Table de consulta de dados tarifas para habilitar pacote
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

<!-- DIV COM INFORMACOES DOS PACOTES DE TARIFAS -->
<div id="divDadosConsulta" name="divDadosConsulta" style="display: none;" > 
	<label for="tituloConsulta">Servi&ccedil;os disponibilizados:</label>

	<div class="divRegistros">
		<table class="tituloRegistros" id="tablePacoteHabilitar">
			<thead>
				<tr>
					<th><?php echo utf8ToHtml('Tarifa'); ?></th>
					<th><?php echo utf8ToHtml('Descri&ccedil;&atilde;o'); ?></th>
					<th><?php echo utf8ToHtml('Qtd. Opera&ccedil;&otilde;es'); ?></th>
				</tr>
			</thead>
			<tbody>				
				<?php
					if($qtdregist > 0){
						foreach ($registros as $registro) { ?>
							<tr>
								<td>
									<?php echo($registro->tags[0]->cdata); ?>
								</td>
								<td>
									<?php echo str_replace('.',',',$registro->tags[1]->cdata); ?>
								</td>
								<td>
									<?php echo str_replace('.',',',$registro->tags[2]->cdata); ?>
								</td>
							</tr>
						<?php } 
					}else{
					?>
						<tr>
							<td colspan="3">
								<b>N&atilde;o h&aacute; registros cadastrados</b>
							</td>
						</tr>
					<?php
					}	
				?>
			</tbody>
		</table>
	</div>
	<br style="clear:both" />
</div>

<hr style="border-style: inset; border-width: 0.5px;">

<br/>
<div id="divDadosHabilitar" name="divDadosHabilitar">
	<fieldset>
	<legend>&nbsp;Dados do Servi&ccedil;o Cooperativo&nbsp;</legend>
		<br/>
		<label for="tppessoaHab"><?php echo utf8ToHtml('Tipo de Pessoa:') ?></label>	
		<input name="tppessoaHab" type="text" id="tppessoaHab" readonly value="<?php echo $dscpessoa; ?>" />
		<br/>
		<label for="cdtarifaHab"><?php echo utf8ToHtml('Tarifa:') ?></label>	
		<input name="cdtarifaHab" type="text" id="cdtarifaHab" readonly class="inteiro" value="<?php echo $cddtarifa; ?>" />
		<br/>
		<label for="vlpacoteHab"><?php echo utf8ToHtml('Valor:') ?></label>	
		<input name="vlpacoteHab" type="text" id="vlpacoteHab" class="inteiro" readonly value="<?php echo $vlrpacote; ?>" />
		<br/>
		<label for="dtvigencHab"><?php echo utf8ToHtml('Inicio da Vigência:') ?></label>	
		<input name="dtvigencHab" type="text" id="dtvigencHab" class="data" />
		<br/>		
	</fieldset>	
	<br style="clear:both" />
</dvi>
<script>
	$("#tppessoaHab").desabilitaCampo();
	$("#cdtarifaHab").desabilitaCampo();
	$("#vlpacoteHab").desabilitaCampo();
	$("#dtvigencHab").focus();
</script>
