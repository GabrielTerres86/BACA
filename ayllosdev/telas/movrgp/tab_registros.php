<? 
/*!
 * FONTE        : tab_registros.php						Última alteração: 19/06/2017  
 * CRIAÇÃO      : Jonata - RKAM
 * DATA CRIAÇÃO : Maio/2017
 * OBJETIVO     : Tabela que apresenta os parametros da tela PARRGP
 * --------------
 * ALTERAÇÕES   : 19/06/2017 - Ajuste para incluir a coluna com a data de vencimento da operação (Jonata - RKAM). 
                    
 * --------------
 */ 

 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<form id="frmProdutos" name="frmProdutos" class="formulario">

	<fieldset id="fsetProdutos" name="fsetProdutos" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Produtos"; ?></legend>
		
		<div class="divRegistros">		
			<table>
				<thead>
					<tr>
						<th>Produto</th>
						<th>Conta</th>
						<th>Contrato</th>
						<th>Valor Opera&ccedil;&atilde;o</th>
						<th>Saldo</th>
						<th>Data Vencimento</th>
					</tr>
				</thead>
				<tbody>
					<? foreach( $produtos as $result ) {    ?>
						<tr>	
							<td><span><? echo getByTagName($result->tags,'dsproduto'); ?></span> <? echo getByTagName($result->tags,'dsproduto'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'nrdconta'); ?></span> <? echo getByTagName($result->tags,'nrdconta'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'nrctremp'); ?></span> <? echo getByTagName($result->tags,'nrctremp'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'vloperacao'); ?></span><? echo getByTagName($result->tags,'vloperacao'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'vlsaldo_pendente'); ?></span><? echo getByTagName($result->tags,'vlsaldo_pendente'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'dtvenc_operacao'); ?></span><? echo getByTagName($result->tags,'dtvenc_operacao'); ?> </td>
							
							<input type="hidden" id="aux_idmovto_risco" name="aux_idmovto_risco" value="<? echo getByTagName($result->tags,'idmovto_risco'); ?>" />
														
						</tr>	
					<? } ?>
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
	</fieldset>
	<fieldset id="fsetProdutosTotais" name="fsetProdutosTotais" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Totais"; ?></legend>
		
		<div class="divRegistros">		
			
			<label for="qtregist"><? echo utf8ToHtml('Quantidade de contratos:') ?></label>
			<input type="text" id="qtregist" name="qtregist"/>	
			
			<br />
			
			<label for="tot_vloperacao"><? echo utf8ToHtml('Valor Total da Operação:') ?></label>
			<input type="text" id="tot_vloperacao" name="tot_vloperacao"/>
			
			<br />
			
			<label for="tot_vlsaldo"><? echo utf8ToHtml('Valor Total do Saldo:') ?></label>
			<input type="text" id="tot_vlsaldo" name="tot_vlsaldo"/>			
			
			<br />
			
			<label for="vlsaldo_pendente_pf"><? echo utf8ToHtml('Valor Total do Saldo PF:') ?></label>
			<input type="text" id="vlsaldo_pendente_pf" name="vlsaldo_pendente_pf"/>
			
			<br />
			
			<label for="vlsaldo_pendente_pj"><? echo utf8ToHtml('Valor Total do Saldo PJ:') ?></label>
			<input type="text" id="vlsaldo_pendente_pj" name="vlsaldo_pendente_pj"/>
			
			<br style="clear:both" />
			
		</div>
		
	</fieldset>
</form>

<div id="divBotoesProdutos" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:block;' >
																			
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('3'); return false;">Voltar</a>																																							
	
	<?if($cddopcao == 'E'){
			
		if($qtregist > 0 ){?>
			<a href="#" class="botao" id="btConcluir">Concluir</a>	
		
		<?}
		
	}else if($cddopcao == 'A'){
		
		if($qtregist > 0 ){?>
			<a href="#" class="botao" id="btProsseguir">Prosseguir</a>	
		<?}
		
   }else if($cddopcao == 'I'){?>
		
		<a href="#" class="botao" id="btProsseguir" onClick="buscarDetalhesMovto(); return false;">Prosseguir</a>	
				
   <?}else{?>

		<a href="#" class="botao" id="btProsseguir">Prosseguir</a>	
		
   <?}?>
	   																			
</div>



<script type="text/javascript">
	
	formataFormProdutos();
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		carregaMovimentos(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		carregaMovimentos(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});		
	
	$('#divRegistrosRodape','#divProdutos').formataRodapePesquisa();
	$('#divBotoesFiltroProduto').css('display','none');
	$('input,select','#frmFiltroProduto').desabilitaCampo();
	$('#qtregist','#fsetProdutosTotais').val('<?echo $qtregist?>');
	$('#tot_vloperacao','#fsetProdutosTotais').val('<?echo getByTagName($totais->tags,'tot_vloperacao')?>');
	$('#tot_vlsaldo','#fsetProdutosTotais').val('<?echo getByTagName($totais->tags,'tot_vlsaldo')?>');
	$('#vlsaldo_pendente_pf','#fsetProdutosTotais').val('<?echo getByTagName($totais->tags,'vlsaldo_pendente_pf')?>');
	$('#vlsaldo_pendente_pj','#fsetProdutosTotais').val('<?echo getByTagName($totais->tags,'vlsaldo_pendente_pj')?>');
	
	formataTabelaProdutos();	
	
				
</script>