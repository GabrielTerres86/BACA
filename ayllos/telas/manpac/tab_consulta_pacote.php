<?php
	/*!
	 * FONTE        : tab_consulta_consulta.php
	 * CRIAÇÃO      : Jean Michel        
	 * DATA CRIAÇÃO : 15/03/2016
	 * OBJETIVO     : Table de consulta de dados da tela MANPAC
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
	$contador = 0;
?>
<!-- DIV COM INFORMACOES DOS PACOTES DE TARIFAS -->
<div id="divDadosConsulta" name="divDadosConsulta" > 
	<br />
	<label for="tituloConsulta">Servi&ccedil;os Cooperativos:</label>
	<div id="Pacotes">
		<div class="divRegistros">		
			<table class="tituloRegistros" id="tablePacote">
				<thead>
					<tr>
						<th><?php echo utf8ToHtml('C&oacute;digo'); ?></th>
						<th><?php echo utf8ToHtml('Descri&ccedil;&atilde;o'); ?></th>
						<th><?php echo utf8ToHtml('Tipo de Pessoa'); ?></th>
						<th><?php echo utf8ToHtml('Situa&ccedil;&atilde;o'); ?></th>
						<th><?php echo utf8ToHtml('Valor'); ?></th>
					</tr>
				</thead>
				<tbody>				
					<?php
						if($qtdregist > 0){
							foreach ($pacotes as $pacote) { 
								if($contador == 0){
									$registroTar = $pacote->tags[0]->cdata;
								}
							?>
								<tr onclick="mostraTarifas(<?php echo($pacote->tags[0]->cdata); ?>);">
									<td>
										<?php echo($pacote->tags[0]->cdata); ?>
									</td>
									<td>
										<?php echo str_replace('.',',',$pacote->tags[1]->cdata); ?>
									</td>
									<td>
										<?php echo str_replace('.',',',$pacote->tags[2]->cdata); ?>
									</td>
									<td>
										<?php echo str_replace('.',',',$pacote->tags[3]->cdata); ?>
									</td>
									<td>
										<?php echo str_replace('.',',',$pacote->tags[4]->cdata); ?>
									</td>
								</tr>
							<?php 
								$contador = $contador + 1;
							}							
						}else{
						?>
							<tr>
								<td colspan="5">
									<b>N&atilde;o h&aacute; registros cadastrados</b>
								</td>
							</tr>
						<?php
							}	
						?>
				</tbody>
			</table>
		</div>
	</div>
</div>

<script>
	mostraTarifas(<?php echo $registroTar; ?>);
</script>
