<? 
/*!
 * FONTE        : tab_registros.php						Última alteração: 15/06/2017
 * CRIAÇÃO      : Jonata - Mouts
 * DATA CRIAÇÃO : Maio/2017
 * OBJETIVO     : Tabela que apresenta os parametros da tela PARRGP
 * --------------
 * ALTERAÇÕES   : 15/06/2017 - Ajuste para incluir a coluna Tipoo de garantia (Jonata - RKAM).
                    
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
						<th>C&oacute;digo</th>
						<th>Produto</th>
						<th>Destino</th>
						<th>Importa Arquivo</th>
						<th>Tipo de Garantia</th>
					</tr>
				</thead>
				<tbody>
					<? foreach( $registros as $result ) {    ?>
						<tr>	
							<td><span><? echo getByTagName($result->tags,'idproduto'); ?></span> <? echo getByTagName($result->tags,'idproduto'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'dsproduto'); ?></span> <? echo getByTagName($result->tags,'dsproduto'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'dscdestino'); ?></span> <? echo getByTagName($result->tags,'dscdestino'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'tparquivo'); ?></span><? echo getByTagName($result->tags,'tparquivo'); ?> </td>
							<td><span><? echo getByTagName($result->tags,'dsgarantia'); ?></span><? echo getByTagName($result->tags,'dsgarantia'); ?> </td>
														
							<input type="hidden" id="aux_idproduto" name="aux_idproduto" value="<? echo getByTagName($result->tags,'idproduto'); ?>" />
							<input type="hidden" id="aux_dsproduto" name="aux_dsproduto" value="<? echo getByTagName($result->tags,'dsproduto'); ?>" />
							<input type="hidden" id="aux_tpdestino" name="aux_tpdestino" value="<? echo getByTagName($result->tags,'tpdestino'); ?>" />
							<input type="hidden" id="aux_tparquivo" name="aux_tparquivo" value="<? echo getByTagName($result->tags,'tparquivo'); ?>" />
							<input type="hidden" id="aux_idgarantia" name="aux_idgarantia" value="<? echo getByTagName($result->tags,'idgarantia'); ?>" />
							<input type="hidden" id="aux_iddominio_idgarantia" name="aux_iddominio_idgarantia" value="<? echo getByTagName($result->tags,'iddominio_idgarantia'); ?>" />
							<input type="hidden" id="aux_dsgarantia" name="aux_dsgarantia" value="<? echo getByTagName($result->tags,'dsgarantia'); ?>" />
							<input type="hidden" id="aux_idmodalidade" name="aux_idmodalidade" value="<? echo getByTagName($result->tags,'idmodalidade'); ?>" />
							<input type="hidden" id="aux_iddominio_idmodalidade" name="aux_iddominio_idmodalidade" value="<? echo getByTagName($result->tags,'iddominio_idmodalidade'); ?>" />
							<input type="hidden" id="aux_dsmodalidade" name="aux_dsmodalidade" value="<? echo getByTagName($result->tags,'dsmodalidade'); ?>" />
							<input type="hidden" id="aux_idconta_cosif" name="aux_idconta_cosif" value="<? echo getByTagName($result->tags,'idconta_cosif'); ?>" />
							<input type="hidden" id="aux_iddominio_idconta_cosif" name="aux_iddominio_idconta_cosif" value="<? echo getByTagName($result->tags,'iddominio_idconta_cosif'); ?>" />
							<input type="hidden" id="aux_dsconta_cosif" name="aux_dsconta_cosif" value="<? echo getByTagName($result->tags,'dsconta_cosif'); ?>" />
							<input type="hidden" id="aux_idorigem_recurso" name="aux_idorigem_recurso" value="<? echo getByTagName($result->tags,'idorigem_recurso'); ?>" />
							<input type="hidden" id="aux_iddominio_idorigem_recurso" name="aux_iddominio_idorigem_recurso" value="<? echo getByTagName($result->tags,'iddominio_idorigem_recurso'); ?>" />
							<input type="hidden" id="aux_dsorigem_recurso" name="aux_dsorigem_recurso" value="<? echo getByTagName($result->tags,'dsorigem_recurso'); ?>" />
							<input type="hidden" id="aux_idindexador" name="aux_idindexador" value="<? echo getByTagName($result->tags,'idindexador'); ?>" />
							<input type="hidden" id="aux_iddominio_idindexador" name="aux_iddominio_idindexador" value="<? echo getByTagName($result->tags,'iddominio_idindexador'); ?>" />
							<input type="hidden" id="aux_dsindexador" name="aux_dsindexador" value="<? echo getByTagName($result->tags,'dsindexador'); ?>" />
							<input type="hidden" id="aux_perindexador" name="aux_perindexador" value="<?php echo getByTagName($result->tags,'perindexador');?>" >
							<input type="hidden" id="aux_idvariacao_cambial" name="aux_idvariacao_cambial" value="<? echo getByTagName($result->tags,'idvariacao_cambial');  ?>" />
							<input type="hidden" id="aux_iddominio_idvariacao_cambial" name="aux_iddominio_idvariacao_cambial" value="<? echo getByTagName($result->tags,'iddominio_idvariacao_cambial');  ?>" />
							<input type="hidden" id="aux_dsvariacao_cambial" name="aux_dsvariacao_cambial" value="<? echo getByTagName($result->tags,'dsvariacao_cambial');  ?>" />
							<input type="hidden" id="aux_idnat_operacao" name="aux_idnat_operacao" value="<? echo getByTagName($result->tags,'idnat_operacao'); ?>" />
							<input type="hidden" id="aux_iddominio_idnat_operacao" name="aux_iddominio_idnat_operacao" value="<? echo getByTagName($result->tags,'iddominio_idnat_operacao'); ?>" />
							<input type="hidden" id="aux_dsnat_operacao" name="aux_dsnat_operacao" value="<? echo getByTagName($result->tags,'dsnat_operacao'); ?>" />
							<input type="hidden" id="aux_idcaract_especial" name="aux_idcaract_especial" value="<? echo getByTagName($result->tags,'idcaract_especial'); ?>" />
							<input type="hidden" id="aux_iddominio_idcaract_especial" name="aux_iddominio_idcaract_especial" value="<? echo getByTagName($result->tags,'iddominio_idcaract_especial'); ?>" />
							<input type="hidden" id="aux_dscaract_especial" name="aux_dscaract_especial" value="<? echo getByTagName($result->tags,'dscaract_especial'); ?>" />
							<input type="hidden" id="aux_idorigem_cep" name="aux_idorigem_cep" value="<? echo getByTagName($result->tags,'idorigem_cep'); ?>" />
							<input type="hidden" id="aux_flpermite_saida_operacao" name="aux_flpermite_saida_operacao" value="<? echo getByTagName($result->tags,'flpermite_saida_operacao'); ?>" />
							<input type="hidden" id="aux_flpermite_fluxo_financeiro" name="aux_flpermite_fluxo_financeiro" value="<? echo getByTagName($result->tags,'flpermite_fluxo_financeiro'); ?>" />
							<input type="hidden" id="aux_flreaprov_mensal" name="aux_flreaprov_mensal" value="<? echo getByTagName($result->tags,'flreaprov_mensal'); ?>" />
							<input type="hidden" id="aux_vltaxa_juros" name="aux_vltaxa_juros" value="<? echo getByTagName($result->tags,'vltaxa_juros'); ?>" />
							<input type="hidden" id="aux_cdclassifica_operacao" name="aux_cdclassifica_operacao" value="<? echo getByTagName($result->tags,'cdclassifica_operacao'); ?>" />
							
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
	
</form>

<div id="divBotoesProdutos" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:block;' >
																			
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('1'); return false;">Voltar</a>																																							
	<a href="#" class="botao" id="btProsseguir">Prosseguir</a>	
																				
</div>

<?php include('form_detalhes.php'); ?>

<script type="text/javascript">
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		principal(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		principal(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});		
	
	$('#divRegistrosRodape','#divDetalhes').formataRodapePesquisa();
	formataTabelaParametros();
				
</script>