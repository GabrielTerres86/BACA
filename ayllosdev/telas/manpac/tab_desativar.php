<?php
	/*!
	 * FONTE        : tab_desativar.php
	 * CRIAÇÃO      : Jean Michel        
	 * DATA CRIAÇÃO : 16/03/2016
	 * OBJETIVO     : Table de consulta de dados tarifas para desativar pacote
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
		<table class="tituloRegistros" id="tablePacoteDesativar">
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
									<?php echo($registro->tags[1]->cdata); ?>
								</td>
								<td>
									<?php echo str_replace('.',',',$registro->tags[2]->cdata); ?>
								</td>
								<td>
									<?php echo str_replace('.',',',$registro->tags[3]->cdata); ?>
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
<script>
	<?php 
		if($flgcooper == 0){
			echo 'cBtnConcluir.html("Concluir");';
			echo 'aux_manpac = 7;';	
		}else{
			echo 'cBtnConcluir.html("Prosseguir");';
			echo 'aux_manpac = 2;';	
		}
	?>
	cCdpacote.desabilitaCampo();
	cBtnConcluir.focus();
</script>
