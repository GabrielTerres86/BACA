<? 
/*!
 * FONTE        : form_detalhes.php						Última alteração:  
 * CRIAÇÃO      : Jonata - RKAM
 * DATA CRIAÇÃO : Maio/2017
 * OBJETIVO     : Apresenta o form com as informações do movimento da tela MOVRGP
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

<form id="frmDetalhes" name="frmDetalhes" class="formulario" style="display:none;">

	<fieldset id="fsetDetalhes" name="fsetDetalhes" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Detalhes"; ?></legend>
		
		<input type="hidden" id="idproduto" name="idproduto" value="<?echo getByTagName($registro->tags,'idproduto');?>"/>
		<input type="hidden" id="idmovto_risco" name="idmovto_risco" value="<?echo getByTagName($registro->tags,'idmovto_risco');?>"/>
		<input type="hidden" id="flpermite_fluxo_financeiro" name="flpermite_fluxo_financeiro" value="<?echo $flpermite_fluxo_financeiro;?>" />
		<input type="hidden" id="flpermite_saida_operacao" name="flpermite_saida_operacao" value="<?echo $flpermite_saida_operacao;?>"/>
		<input type="hidden" id="cdclassificacao_produto" name="cdclassificacao_produto" value="<?echo $cdclassificacao_produto;?>"/>
		
		
		<label for="cdcopsel"><? echo utf8ToHtml('Coop.:') ?></label>
		<input type="text" id="cdcopsel" name="cdcopsel" value="<?echo getByTagName($registro->tags,'cdcooper');?>"/>
		
		<br />
		
		<label for="dtrefere"><? echo utf8ToHtml('Dt. Ref.:') ?></label>
		<input type="text" id="dtrefere" name="dtrefere" value="<?echo getByTagName($registro->tags,'dtbase');?>"/>
		
		<br />
		
		<label for="dsproduto"><? echo utf8ToHtml('Produto:') ?></label>
		<input type="text" id="dsproduto" name="dsproduto" value="<?echo getByTagName($registro->tags,'dsproduto');?>"/>
		
		<br />
		
		<label for="nrdconta"><? echo utf8ToHtml('Conta:') ?></label>
		<input type="text" id="nrdconta" name="nrdconta" value="<?echo getByTagName($registro->tags,'nrdconta');?>"/>
		<a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
		<input type="text" id="nmprimtl" name="nmprimtl" value="<?echo getByTagName($registro->tags,'nmprimtl');?>"/>
		
		<br />

		<label for="nrcpfcgc"><? echo utf8ToHtml('CPF/CNPJ:') ?></label>
		<input type="text" id="nrcpfcgc" name="nrcpfcgc" value="<?echo getByTagName($registro->tags,'nrcpfcgc');?>"/>
		
		<br />

		<label for="nrctremp"><? echo utf8ToHtml('Contrato:') ?></label>
		<input type="text" id="nrctremp" name="nrctremp" value="<?echo getByTagName($registro->tags,'nrctremp');?>"/>
		
		<br />
		
		<label for="idgarantia"><? echo utf8ToHtml('Garantia:') ?></label>
		<input type="text" id="idgarantia" name="idgarantia" value="<?echo getByTagName($registro->tags,'idgarantia');?>"/>
		<a style="padding: 3px 0 0 3px;" href="#"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
		<input type="text" id="dsgarantia" name="dsgarantia" value="<?echo getByTagName($registro->tags,'dsgarantia');?>"/>
		<input type="hidden" id="iddominio_idgarantia" name="iddominio_idgarantia" value="<?echo getByTagName($registro->tags,'iddominio_idgarantia');?>"/>
		
		<br />
		
		<label for="idorigem_recurso"><? echo utf8ToHtml('Origem Recurso:') ?></label>
		<input type="text" id="idorigem_recurso" name="idorigem_recurso" value="<?echo getByTagName($registro->tags,'idorigem_recurso');?>"/>
		<a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
		<input type="text" id="dsorigem_recurso" name="dsorigem_recurso" value="<?echo getByTagName($registro->tags,'dsorigem_recurso');?>"/>
		<input type="hidden" id="iddominio_idorigem_recurso" name="iddominio_idorigem_recurso" value="<?echo getByTagName($registro->tags,'iddominio_idorigem_recurso');?>"/>
		
		<br />
		
		<label for="idindexador"><? echo utf8ToHtml('Indexador:') ?></label>
		<input type="text" id="idindexador" name="idindexador" value="<?echo getByTagName($registro->tags,'idindexador');?>"/>
		<a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
		<input type="text" id="dsindexador" name="dsindexador" value="<?echo getByTagName($registro->tags,'dsindexador');?>"/>
		<input type="hidden" id="iddominio_idindexador" name="iddominio_idindexador" value="<?echo getByTagName($registro->tags,'iddominio_idindexador');?>"/>
		
		<br />
		
		<label for="perindexador"><? echo utf8ToHtml('Perc. Indexador:') ?></label>
		<input type="text" id="perindexador" name="perindexador" value="<?echo getByTagName($registro->tags,'perindexador');?>"/>
		
		<br />
		
		<label for="vltaxa_juros"><? echo utf8ToHtml('Taxa de Juros (a.a):') ?></label>
		<input type="text" id="vltaxa_juros" name="vltaxa_juros" value="<?echo getByTagName($registro->tags,'vltaxa_juros');?>"/>
		
		<br />
		
		<label for="dtlib_operacao"><? echo utf8ToHtml('Dt. Lib. Op.:') ?></label>
		<input type="text" id="dtlib_operacao" name="dtlib_operacao" value="<?echo getByTagName($registro->tags,'dtlib_operacao');?>"/>
		
		<br />
		
		<label for="vloperacao"><? echo utf8ToHtml('Valor operação:') ?></label>
		<input type="text" id="vloperacao" name="vloperacao" value="<?echo getByTagName($registro->tags,'vloperacao');?>"/>
		
		<br />
		
		<label for="idnat_operacao"><? echo utf8ToHtml('Natureza Operação:') ?></label>
		<input type="text" id="idnat_operacao" name="idnat_operacao"value="<?echo getByTagName($registro->tags,'idnat_operacao');?> "/>
		<a style="padding: 3px 0 0 3px;" href="#" ><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>			
		<input type="text" id="dsnat_operacao" name="dsnat_operacao" value="<?echo getByTagName($registro->tags,'dsnat_operacao');?>"/>
		<input type="hidden" id="iddominio_idnat_operacao" name="iddominio_idnat_operacao" value="<?echo getByTagName($registro->tags,'iddominio_idnat_operacao');?>"/>
		
		<br />
		
		<label for="dtvenc_operacao"><? echo utf8ToHtml('Dt. Venc. Op.:') ?></label>
		<input type="text" id="dtvenc_operacao" name="dtvenc_operacao" value="<?echo getByTagName($registro->tags,'dtvenc_operacao');?>"/>
		
		<br />
		
		<label for="cdclassifica_operacao"><? echo utf8ToHtml('ClassOp:') ?></label>
		<select id="cdclassifica_operacao" name="cdclassifica_operacao" >
			<option value="AA" selected>AA</option>
			<option value="A">A</option>
			<option value="B">B</option>
			<option value="C">C</option>
			<option value="D">D</option>
			<option value="E">E</option>
			<option value="F">F</option>
			<option value="G">G</option>
			<option value="H">H</option>
			<option value="HH">HH</option>
		</select>
		
		<br />
		
		<label for="qtdparcelas"><? echo utf8ToHtml('Qtd. Parcelas:') ?></label>
		<input type="text" id="qtdparcelas" name="qtdparcelas" value="<?echo getByTagName($registro->tags,'qtdparcelas');?>"/>
		
		<br />
		
		<label for="vlparcela"><? echo utf8ToHtml('Vlr. Parcela:') ?></label>
		<input type="text" id="vlparcela" name="vlparcela" value="<?echo getByTagName($registro->tags,'vlparcela');?>"/>
		
		<br />
		
		<label for="dtproxima_parcela"><? echo utf8ToHtml('Dt. Prox. Parcela:') ?></label>
		<input type="text" id="dtproxima_parcela" name="dtproxima_parcela" value="<?echo getByTagName($registro->tags,'dtproxima_parcela');?>"/>
		
		<br />
		
		<label for="vlsaldo_pendente"><? echo utf8ToHtml('Saldo Pendente:') ?></label>
		<input type="text" id="vlsaldo_pendente" name="vlsaldo_pendente" value="<?echo getByTagName($registro->tags,'vlsaldo_pendente');?>"/>
		
		<br />
		
		<label for="flsaida_operacao"><? echo utf8ToHtml('Saída:') ?></label>
		<input type="checkbox" id="flsaida_operacao" name="flsaida_operacao" />
		
		
		<br style="clear:both" />
		
	</fieldset>
	
</form>

<div id="divBotoesDetalhes" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
																			
	<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); return false;">Voltar</a>																																							
	
	<?php if($cddopcao == 'A'){?>
	
		<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','alterarMovimento();','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));$(\'#btVoltar\',\'#divBotoesDetalhes\').focus();','sim.gif','nao.gif');return false;">Concluir</a>	
			
	<?php }else if($cddopcao == 'I'){?>

		<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','incluirMovimento();','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));$(\'#btVoltar\',\'#divBotoesDetalhes\').focus();','sim.gif','nao.gif');return false;">Concluir</a>	
		
	<?php }?>
	
</div>

<script type="text/javascript">
	
    <?IF(getByTagName($registro->tags,'flsaida_operacao') == '1' ){?>	
	
		$('#flsaida_operacao','#fsetDetalhes').prop("checked",true); 
		
	<?}else{?>
	
		$('#flsaida_operacao','#fsetDetalhes').prop("checked",false);
		
	<?}?>
	
	<?if($cdclassificacao_produto == 'AA'){?>
		$('#cdclassifica_operacao','#fsetDetalhes').prop('selected',true).val('<? echo $cdclassificacao_produto;?>');
	<?}else{?>
		$('#cdclassifica_operacao','#fsetDetalhes').prop('selected',true).val('<? echo getByTagName($registro->tags,'cdclassifica_operacao');?>');
	<?}?>
	
	if ('<?echo $cddopcao;?>' == 'I'){
		
		$('#cdcopsel','#fsetDetalhes').val($('#cdcopsel option:selected','#frmFiltroCoop').text());
		$('#dtrefere','#fsetDetalhes').val($('#dtrefere','#frmFiltroCoop').val());
		$('#dsproduto','#fsetDetalhes').val($('#cdproduto option:selected','#frmFiltroProduto').text());
	
	}
	
	$('#divRotina').css({'width':'820px'});
	$('#divRotina').centralizaRotinaH();
	exibeRotina($('#divRotina'));
	hideMsgAguardo();
	bloqueiaFundo($('#divRotina'));
	formataDetalhes();
	
</script>
 