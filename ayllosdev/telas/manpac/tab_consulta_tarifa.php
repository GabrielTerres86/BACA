<?php
	/*!
	 * FONTE        : tab_consulta_tarifa.php
	 * CRIAÇÃO      : Jean Michel        
	 * DATA CRIAÇÃO : 28/03/2016
	 * OBJETIVO     : Table de consulta de dados de tarifas de acordo com o Pacote da tela MANPAC
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
<div id="pacotesTarifas" name="pacotesTarifas" >
	<br style="clear:both" />
	<label for="tituloConsulta">Servi&ccedil;os disponibilizados:</label>	
	<div class="divRegistros">
		<table class="tituloRegistros" id="tablePacoteTarifa">
			<thead>
				<tr>
					<th><?php echo utf8ToHtml('Tarifa'); ?></th>
					<th><?php echo utf8ToHtml('Descri&ccedil;&atilde;o'); ?></th>
					<th><?php echo utf8ToHtml('Qtd. Opera&ccedil;&otilde;es'); ?></th>
				</tr>
			</thead>
			<tbody>				
				<?php
					foreach ($tarifas as $tarifa) { 
				?>								
				<tr>
					<td>
						<?php echo($tarifa->tags[1]->cdata); ?>
					</td>
					<td>
						<?php echo($tarifa->tags[2]->cdata); ?>
					</td>
					<td>
						<?php echo($tarifa->tags[3]->cdata); ?>
					</td>
				</tr>
				<?php } ?> 
			</tbody>
		</table>
	</div>
</div>
<script>
	cBtnVoltar.focus();
</script>
