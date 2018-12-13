<?php

/* 
 * FONTE        : tabela_distribuicao_grupos.php
 * CRIAÇÃO      : Mateus Zimmermann - Mouts
 * DATA CRIAÇÃO : Setembro/2018
 * OBJETIVO     : Tabela da opção "G"
 */
 
 
 session_start();
 require_once('../../includes/config.php');
 require_once('../../includes/funcoes.php');
 require_once('../../includes/controla_secao.php');		
 require_once('../../class/xmlfile.php');
 isPostMethod();

?>

<form id="frmDistribuicaoGrupos" name="frmDistribuicaoGrupos" class="formulario">

	<fieldset id="fsetDistribuicaoGrupos" name="fsetDistribuicaoGrupos" style="padding:0px; margin:0px; padding-bottom:10px;">

			<div class="divRegistros">
				<table>
					<thead>
						<tr>
							<th id="thMarcarDesmarcarTodos"><input id="cbMarcarDesmarcarTodos" type="checkbox" /></th>
							<th>PA</th>
							<th>Grupos</th>
							<th>Qt. Cooperados</th>
							<th>Div. Cooperados</th>
							<th>Delegados</th>
							<th>Com. Cooperativo</th>
							<th>Status</th>
						</tr>
					</thead>
					<tbody>
						<?php
						foreach($agencias as $agencia){
							$divCooperados = ceil(getByTagName($agencia->tags,'contador')/getByTagName($agencia->tags,'nrdgrupo'));
							?>
								<tr>
									<td><input id="redistribuir" type="checkbox" <? echo getByTagName($agencia->tags,'contador') == 0 ? 'disabled' : '' ?>/></td>
									<td><span><? echo getByTagName($agencia->tags,'cdagenci'); ?></span> <? echo getByTagName($agencia->tags,'cdagenci'); ?> </td>
									<td><span><? echo getByTagName($agencia->tags,'nrdgrupo'); ?></span> <? echo getByTagName($agencia->tags,'nrdgrupo'); ?> </td>
									<td><span><? echo getByTagName($agencia->tags,'contador'); ?></span> <? echo getByTagName($agencia->tags,'contador'); ?> </td>
									<td><span><? echo getByTagName($agencia->tags,'contador'); ?></span> <? if ($divCooperados > 0) { echo $divCooperados; } ?> </td>
									<td><span><? echo getByTagName($agencia->tags,'delegado'); ?></span> <? echo getByTagName($agencia->tags,'delegado'); ?> </td>
									<td><span><? echo getByTagName($agencia->tags,'comitedu'); ?></span> <? echo getByTagName($agencia->tags,'comitedu'); ?> </td>
									<td><span><? echo getByTagName($agencia->tags,'status'); ?></span> <? echo getByTagName($agencia->tags,'status'); ?> </td>

									<input type="hidden" id="cdagenci" value="<? echo getByTagName($agencia->tags,'cdagenci'); ?>" />

								</tr>
							<?php
						}
						?>
					</tbody>
				</table>
			</div>
	</fieldset>

	<div id="divTabelaAgenciaSelecionada"></div>

</form>

<div id="divBotoesDistribuicaoGrupos" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:block;' >

	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1'); return false;">Voltar</a>
	<a href="#" class="botao" id="btAlterar" onClick="consultaListaAgencias(); return false;">Alterar</a>
	<a href="#" class="botao" id="btDstTodos" onClick="consultaDistribuirTodos(); return false;">Distribuir Todos</a>

</div>

<script type="text/javascript">	
	formataTabelaDistribuicaoGrupos();	
</script>