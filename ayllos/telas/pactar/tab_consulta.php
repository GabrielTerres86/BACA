<?php
	/*!
	 * FONTE        : tab_consulta.php
	 * CRIAÇÃO      : Jean Michel        
	 * DATA CRIAÇÃO : 03/03/2016
	 * OBJETIVO     : Table de consulta de dados da tela PACTAR
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
<div id="tabServicos">
	<div class="divRegistros">
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><?php echo utf8ToHtml('Servi&ccedil;os'); ?></th>
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
							</tr>
						<?php } 
					}else{
					?>
						<tr>
							<td colspan="2">
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
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

<script>
	cBtnVoltar.focus();
</script>
