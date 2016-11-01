<? 
/*!
 * FONTE        : tab_atualizar_plano.php
 * CRIAÇÃO      : Adriano Marchi				Última alteração: 
 * DATA CRIAÇÃO : 21/12/2015
 * OBJETIVO     : Tabela que apresenta as seguradoras
 * --------------
 * ALTERAÇÕES   : 09/03/2016 - Ajuste feito para que operadores do departamento COORD.PRODUTOS
							   tenham permições para alterar e incluir conforme solicitado no
							   chamado 399940 (Kelvin).
 * --------------
 */	
 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
?>
<div id="divTabAtualizarPlano">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Plano'); ?></th>
					<th><? echo utf8ToHtml('D&eacute;bito'); ?></th>
					<th><? echo utf8ToHtml('Anterior'); ?></th>
					<th><? echo utf8ToHtml('Atual'); ?></th>
					<th><? echo utf8ToHtml('Conta'); ?></th>
					<th><? echo utf8ToHtml('Movto'); ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				if ( count($registros) == 0 ) {
					$i = 0;
					// Monta uma coluna mesclada com a quantidade de colunas que seria exibida
					?> <tr>
							<td colspan="6" style="width: 80px; text-align: center;">
								<input type="hidden" id="conteudo" name="conteudo" value="<? echo $i; ?>" />
								<b>Nenhum registro encontrado.</b>
							</td>
						</tr>							
				<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
				} else {
					foreach($registros as $values){ ?>
					<tr>
						<td><span><? echo getByTagName($values->tags, 'tpplaseg'); ?></span>
							      <? echo getByTagName($values->tags, 'tpplaseg'); ?>
						</td>
						<td><span><? echo getByTagName($values->tags, 'dtdebito');?></span>
							      <? echo getByTagName($values->tags, 'dtdebito');?>
						</td>
						<td><span><? echo converteFloat(getByTagName($values->tags, 'vlpreseg'),'MOEDA');?></span>
							      <? echo formataMoeda(getByTagName($values->tags, 'vlpreseg'));?>
						</td>
						<td><span><? echo converteFloat(getByTagName($values->tags, 'vlatual'),'MOEDA');?></span>
							      <? echo formataMoeda(getByTagName($values->tags, 'vlatual'));?>
						</td>
						<td><span><? echo getByTagName($values->tags, 'nrdconta');?></span>
							      <? echo formataNumericos('zzzz.zzz-9',getByTagName($values->tags,'nrdconta'),'.-') ?>
						</td>
						<td><span><? echo getByTagName($values->tags, 'dtmvtolt');?></span>
							      <? echo getByTagName($values->tags, 'dtmvtolt');?>
						</td>
					</tr>
				<? }
			}?>	
			</tbody>
		</table>
	</div>	
	<div id="divRegistrosRodape" class="divRegistrosRodape">
		<table>	
			<tr>
				<td>
					<? if (isset($qtregist) and $qtregist == 0){ $nriniseq = 0;} ?>
					<? if ($nriniseq > 1){ ?>
						   <a class="paginacaoAnt"><<< Anterior</a>
					<? }else{ ?>
							&nbsp;
					<? } ?>
				</td>
				<td>
					<? if (isset($nriniseq)) { ?>
						   Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
						<? } ?>
					/ Total: <? echo number_format(str_replace(",",".",$vlrtotal ),2,",","."); ?>
				</td>
				<td>
					<? if($qtregist > ($nriniseq + $nrregist - 1)) { ?>
						  <a class="paginacaoProx">Pr&oacute;ximo >>></a>
					<? }else{ ?>
							&nbsp;
					<? } ?>
				</td>
			</tr>
		</table>
	</div>	
	
</div>

<script text="text/javascript">

	formataTabAtualizar();
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		atualizarPercentual(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		atualizarPercentual(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});		
	
	$('#divRegistrosRodape','#divTabela').formataRodapePesquisa();
	
	$('#divTabela').css('display','block');
	$('#btSalvar','#divBotoes').show();
	
</script>