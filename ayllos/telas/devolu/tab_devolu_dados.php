<?php
/*! 
 * FONTE        : tab_devolu_dados.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 25/09/2013
 * OBJETIVO     : Tabela - tela DEVOLU
 * --------------
 * ALTERAÇÕES   : 12/07/2016 #451040 Formatar número do cheque (Carlos)
 *
 *				  19/08/2016 - Ajustes referentes a Melhoria 69 - Devolucao Automatica de Cheques (Lucas Ranghetti #484923)
 * --------------
 */
?>

<?
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();
?>

<fieldset id="Informacoes">

<div id="tabDevoluDados" style="display:none" >
	<input type="hidden" name="hdnCooper" id="hdnCooper" value="<?php echo($glbvars["cdcooper"]); ?>" />
	<input type="hidden" name="hdnServSM" id="hdnServSM" value="<?php echo($GEDServidor); ?>" />
	<div class="divRegistros">
		<table class="tituloRegistros">
			<thead>
					<th><? echo utf8ToHtml('Bco');      ?></th>
					<th><? echo utf8ToHtml('Age');      ?></th>
					<th><? echo utf8ToHtml('Conta/dv'); ?></th>
					<th><? echo utf8ToHtml('Cheque');   ?></th>
					<th><? echo utf8ToHtml('Valor');    ?></th>
					<th><? echo utf8ToHtml('Alinea');   ?></th>
					<th><? echo utf8ToHtml('Situação'); ?></th>
					<th><? echo utf8ToHtml('Operador'); ?></th>
					
					<th><? echo utf8ToHtml('Aplicação'); ?></th>
					<th><? echo utf8ToHtml('Contato');   ?></th>
					<th><? echo utf8ToHtml('Imagem');    ?></th>
					<th><? echo utf8ToHtml('Assinatura');?></th>
				</tr>
			</thead>
			<tbody>
				<? $cont_id = 0;
				for ($i = 0; $i < count($devolucoes); $i++) {
				?>
					<tr>
						<input type="hidden" id="cdbccxlt" name="cdbccxlt" value="<? echo getByTagName($devolucoes[$i]->tags,'cdbccxlt'); ?>" /> 
						<input type="hidden" id="dtliquid" name="dtliquid" value="<? echo getByTagName($devolucoes[$i]->tags,'dtliquid'); ?>" /> 
						<input type="hidden" id="cdagechq" name="cdagechq" value="<? echo getByTagName($devolucoes[$i]->tags,'cdagechq'); ?>" /> 
						<input type="hidden" id="nrdconta" name="nrdconta" value="<? echo getByTagName($devolucoes[$i]->tags,'nrdconta'); ?>" /> 
						<input type="hidden" id="nrctachq" name="nrctachq" value="<? echo getByTagName($devolucoes[$i]->tags,'nrctachq'); ?>" /> 
						<input type="hidden" id="nrcheque" name="nrcheque" value="<? echo getByTagName($devolucoes[$i]->tags,'nrcheque'); ?>" /> 
						<input type="hidden" id="vllanmto" name="vllanmto" value="<? echo getByTagName($devolucoes[$i]->tags,'vllanmto'); ?>" /> 
						<input type="hidden" id="cdalinea" name="cdalinea" value="<? echo getByTagName($devolucoes[$i]->tags,'cdalinea'); ?>" /> 
					
						<td><span><? echo getByTagName($devolucoes[$i]->tags,'cdbccxlt'); ?></span>
								  <? echo getByTagName($devolucoes[$i]->tags,'cdbccxlt'); ?>
						</td>
						<td><span><? echo getByTagName($devolucoes[$i]->tags,'cdagechq'); ?></span>
								  <? echo getByTagName($devolucoes[$i]->tags,'cdagechq'); ?>
						</td>
						<td><span><? echo formataContaDV(getByTagName($devolucoes[$i]->tags,'nrdconta')); ?></span>
								  <? echo formataContaDV(getByTagName($devolucoes[$i]->tags,'nrdconta')); ?>
						</td>
						<td><span><? echo formataContaDVsimples(getByTagName($devolucoes[$i]->tags,'nrcheque')); ?></span>
								  <? echo formataContaDVsimples(getByTagName($devolucoes[$i]->tags,'nrcheque')); ?>
						</td>

						<td><span><? echo getByTagName($devolucoes[$i]->tags,'vllanmto'); ?></span>
								  <? echo formataMoeda(getByTagName($devolucoes[$i]->tags,'vllanmto')); ?>
						</td>
						
						<td><span><? echo getByTagName($devolucoes[$i]->tags,'cdalinea'); ?></span>
								  <? echo getByTagName($devolucoes[$i]->tags,'cdalinea'); ?>
						</td>
						<td><span><? echo getByTagName($devolucoes[$i]->tags,'dssituac');?></span>
								  <? echo getByTagName($devolucoes[$i]->tags,'dssituac'); ?>
						</td>
						<td><span><? echo getByTagName($devolucoes[$i]->tags,'nmoperad'); ?></span>
								  <? echo getByTagName($devolucoes[$i]->tags,'nmoperad'); ?>
						</td>
						<td id="dsaplica"  title="<? echo "Total Aplic.: ".formataMoeda(getByTagName($devolucoes[$i]->tags,'vlaplica'))."&#013;Total Poup.: ".formataMoeda(getByTagName($devolucoes[$i]->tags,'vlsldprp')); ?>">
										   <span><?echo getByTagName($devolucoes[$i]->tags,'dsaplica'); ?></span>
												 <?echo getByTagName($devolucoes[$i]->tags,'dsaplica'); ?>
						  <input type="hidden" id="vlaplica" name="tabvlaplica" value="<? echo getByTagName($devolucoes[$i]->tags,'vlaplica'); ?>" /> 
						  <input type="hidden" id="vlsldprp" name="tabvlsldprp" value="<? echo getByTagName($devolucoes[$i]->tags,'vlsldprp'); ?>" /> 
						</td>
						<td id="contato">
							<a href="#" onClick="mostraContatos();"><img src="<?php echo $UrlImagens; ?>geral/telefone.png" width="15" height="15" border="0"></a>
						</td>
						<td id="imagcheq">
							<a href="#" onClick="consultaCheque('<? echo getByTagName($devolucoes[$i]->tags,'cdagechq'); ?>','<? echo getByTagName($devolucoes[$i]->tags,'nrdconta'); ?>','<? echo getByTagName($devolucoes[$i]->tags,'nrcheque'); ?>');">
							    <img src="<?php echo $UrlImagens; ?>geral/documento.png" width="15" height="15" border="0">
							</a>
						</td>
						<td> 
							<a href="http://<?php echo $GEDServidor;?>/smartshare/Clientes/ViewerExterno.aspx?pkey=8O3ky&conta=<?php echo formataContaDVsimples(getByTagName($devolucoes[$i]->tags,'nrdconta')); ?>&cooperativa=<?php echo $glbvars["cdcooper"]; ?>" target="_blank">
							<img src="<?php echo $UrlImagens; ?>geral/editar.png" width="15" height="15" border="0"></a>
						</td>
						
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
</div>

</fieldset>

<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {

		BuscaDevolu(<? echo ($nriniseq - $nrregist)?>,<?php echo $nrregist?>);

	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		BuscaDevolu(<? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);
		
	});		
	
	$('#divRegistrosRodape','#tabDevoluDados').formataRodapePesquisa();
	
//	formataFormularios();
//	controlaLayout("1");		
			
</script>