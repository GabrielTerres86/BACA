<?php
/* 
 * FONTE        : tabela_distribuicao_grupos.php
 * CRIAÇÃO      : Mateus Zimmermann - Mouts
 * DATA CRIAÇÃO : Setembro/2018
 * OBJETIVO     : Tabela lista agencias
 */
 
 
 session_start();
 require_once('../../includes/config.php');
 require_once('../../includes/funcoes.php');
 require_once('../../includes/controla_secao.php');		
 require_once('../../class/xmlfile.php');
 isPostMethod();	

?>

<form id="frmListaAgencias" name="frmListaAgencias" class="formulario">

	<fieldset id="fsetListaAgencias" name="fsetListaAgencias" style="padding:0px; margin:0px; padding-bottom:10px;">

			<div class="divRegistros">
				<table>
					<thead>
						<tr>
							<th>PA</th>
							<th>Qt. Cooperados</th>
							<th>Grupo</th>
							<th>Div. Cooperados</th>
							<th>Delegados</th>
							<th>Com. Cooperativo</th>
						</tr>
					</thead>
					<tbody>
						<?php
						foreach($agencias as $agencia){
							?>
								<tr>
									<td><span><? echo getByTagName($agencia->tags,'cdagenci'); ?></span> <? echo getByTagName($agencia->tags,'cdagenci'); ?> </td>
									<td class="tdQtMembros"><span><? echo getByTagName($agencia->tags,'contador'); ?></span> <? echo getByTagName($agencia->tags,'contador'); ?> </td>
									<td><span><? echo getByTagName($agencia->tags,'qtdgrupo'); ?></span> <input type="text" id="qtdgrupo" value="<? echo getByTagName($agencia->tags,'qtdgrupo'); ?>" /> </td>
									<td class="tdQtTotal"><span></span></td>
									<td><span><? echo getByTagName($agencia->tags,'delegado'); ?></span> <? echo getByTagName($agencia->tags,'delegado'); ?> </td>
									<td><span><? echo getByTagName($agencia->tags,'comitedu'); ?></span> <? echo getByTagName($agencia->tags,'comitedu'); ?> </td>

									<input type="hidden" id="cdagenci" value="<? echo getByTagName($agencia->tags,'cdagenci'); ?>" />

								</tr>
							<?php
						}
						?>
					</tbody>
				</table>
			</div>
	</fieldset> 

</form>

<div id="divBotoesListaAgencias" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:block;' >

	<a href="#" class="botao" id="btVoltar" onClick="consultaDistribuicaoGrupos(); return false;">Voltar</a>
	<a href="#" class="botao" id="btConfirmar" onClick="confirmaValidaDistribui(); return false;">Confirmar</a>

</div>

<script type="text/javascript">	
	formataTabelaListaAgencias();
</script>