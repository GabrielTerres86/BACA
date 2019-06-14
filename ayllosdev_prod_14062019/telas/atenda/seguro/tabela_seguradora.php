<? 
/*!
 * FONTE        : tabela_seguradora.php
 * CRIAÇÃO      : Marcelo Leandro Pereira
 * DATA CRIAÇÃO : 31/09/2011
 * OBJETIVO     : Tabela que apresenta os seguros
 * --------------
 * ALTERAÇÕES   : Michel M Candido
 * DATA CRIAÇÃO : 19/09/2011
 * --------------
 * ALTERACOES   : 20/11/2013 - Incluido chamada da function atualizaSeguradora
							   ao clicar em uma seguradora na tabela da divSeguradoras.
							   (Reinert)
 */
 ?>
<div id="divSeguradoras" class="divRegistros">
	<table>
		<thead>
			<tr>
				<th><? echo utf8ToHtml('Código');?></th>
				<th><? echo utf8ToHtml('Descrição');?></th>
			</tr>
		</thead>		
		<tbody>
			<?
				foreach( $seguradoras as $seguradora ) {
				?>
				<tr onclick="atualizaSeguradora('<? echo getByTagName($seguradora->tags,'nmsegura'); ?>', <? echo getByTagName($seguradora->tags,'cdsegura'); ?>);">
					<td>
						<? echo getByTagName($seguradora->tags,'cdsegura'); ?>
						<input type="hidden" id="cdsegura" name="cdsegura" value="<? echo getByTagName($seguradora->tags,'cdsegura'); ?>" />
						<input type="hidden" id="nmsegura" name="nmsegura" value="<? echo getByTagName($seguradora->tags,'nmsegura'); ?>" />
					</td>					
					<td><? echo getByTagName($seguradora->tags,'nmsegura'); ?></td>
				</tr>
			<? } ?>
		</tbody>
	</table>
</div>
<div id="divBotoes">
	<input type="image" class="rotulo" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif" onClick="controlaOperacao('I'); return false;" />
	<input type="image" class="rotulo" id="btContinuar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="controlaOperacao('I_CASA');" />
</div>
<script type="text/javascript">
	hideMsgAguardo();
	controlaPesquisas('SEGUR');
</script>