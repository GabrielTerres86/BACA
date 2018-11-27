<?php

/* 
 * FONTE        : tabela_distribuicao_grupos.php
 * CRIAÇÃO      : Mateus Zimmermann - Mouts
 * DATA CRIAÇÃO : Setembro/2018
 * OBJETIVO     : Tabela com informações da agencia selecionada
 */
 
 
 session_start();
 require_once('../../includes/config.php');
 require_once('../../includes/funcoes.php');
 require_once('../../includes/controla_secao.php');		
 require_once('../../class/xmlfile.php');
 isPostMethod();	

?>

<form id="frmAgenciaSelecionada" name="frmAgenciaSelecionada" class="formulario">

	<fieldset id="fsetAgenciaSelecionada" name="fsetAgenciaSelecionada" style="padding:0px; margin:0px; padding-bottom:10px;">

			<div class="divRegistros">
				<table>
					<thead>
						<tr>
							<th>PA</th>
							<th>Grupos</th>
							<th>Qt. Cooperados</th>
							<th>Delegados</th>
							<th>Com. Cooperativo</th>
						</tr>
					</thead>
					<tbody>
						<?php
						foreach($registros as $registro){
							?>
								<tr>

									<td><span><? echo getByTagName($registro->tags,'cdagenci'); ?></span> <? echo getByTagName($registro->tags,'cdagenci'); ?> </td>
									<td><span><? echo getByTagName($registro->tags,'nrdgrupo'); ?></span> <? echo getByTagName($registro->tags,'nrdgrupo'); ?> </td>
									<td><span><? echo getByTagName($registro->tags,'contador'); ?></span> <? echo getByTagName($registro->tags,'contador'); ?> </td>
									<td><span><? echo getByTagName($registro->tags,'delegado'); ?></span> <? echo getByTagName($registro->tags,'delegado'); ?> </td>
									<td><span><? echo getByTagName($registro->tags,'comitedu'); ?></span> <? echo getByTagName($registro->tags,'comitedu'); ?> </td>
								</tr>
							<?php
						}
						?>
					</tbody>
				</table>
			</div> <!-- FIM DIV REGISTROS -->
	</fieldset> <!-- FIM fieldSet Representacao Social -->
</form>

<script type="text/javascript">	
	formataTabelaAgenciaSelecionada();	
</script>