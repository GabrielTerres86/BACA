<? 
/*!
 * FONTE        : tab_contas_rateio_ted_capital.php						Última alteração:  
 * CRIAÇÃO      : Jonata - RKAM
 * DATA CRIAÇÃO : Agosto/2017
 * OBJETIVO     : Tabela que apresenta as contas de rateio TED capital - opção "G" da tela SOL030
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

<form id="frmContas" name="frmContas" class="formulario">

	<fieldset id="fsetContas" name="fsetContas" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Contas"; ?></legend>
		
		<div class="divRegistros">		
			<table>
				<thead>
					<tr>
					    <th>Conta</th>
						<th>Nome</th>
						<th>Valor</th>
					</tr>
				</thead>
				<tbody>
					<? for ($i = 0; $i < count($registros); $i++) {    ?>
					
						<tr>	
							<td><span><? echo formataContaDV(getByTagName($registros[$i]->tags,'nrdconta')); ?></span><? echo formataContaDV(getByTagName($registros[$i]->tags,'nrdconta')); ?>
							<td><span><? echo getByTagName($registros[$i]->tags,'nmprimtl'); ?></span> <? echo getByTagName($registros[$i]->tags,'nmprimtl'); ?> </td>
							<td><span><?php echo str_replace(",",".",getByTagName($registros[$i]->tags,'vldcotas')); ?></span><?php echo number_format(str_replace(",",".",getByTagName($registros[$i]->tags,'vldcotas')),2,",","."); ?>
									
							<input type="hidden" id="nrconta_dest" name="nrconta_dest" value="<?echo getByTagName($registros[$i]->tags,'nrconta_dest'); ?>"/>
							<input type="hidden" id="nrdigito_dest" name="nrconta_dest" value="<?echo getByTagName($registros[$i]->tags,'nrdigito_dest'); ?>"/>
							<input type="hidden" id="nmtitular_dest" name="nmtitular_dest" value="<?echo getByTagName($registros[$i]->tags,'nmtitular_dest'); ?>"/>
							<input type="hidden" id="nrcpfcgc_dest" name="nrcpfcgc_dest" value="<?echo getByTagName($registros[$i]->tags,'nrcpfcgc_dest'); ?>"/>
							<input type="hidden" id="cdbanco_dest" name="cdbanco_dest" value="<?echo getByTagName($registros[$i]->tags,'cdbanco_dest'); ?>"/>
							<input type="hidden" id="dsbanco_dest" name="dsbanco_dest" value="<?echo getByTagName($registros[$i]->tags,'dsbanco_dest'); ?>"/>
							<input type="hidden" id="cdagenci_dest" name="cdagenci_dest" value="<?echo getByTagName($registros[$i]->tags,'cdagenci_dest'); ?>"/>
							<input type="hidden" id="dsagenci_dest" name="dsagenci_dest" value="<?echo getByTagName($registros[$i]->tags,'dsagenci_dest'); ?>"/>
							<input type="hidden" id="insit_autoriza" name="insit_autoriza" value="<?echo getByTagName($registros[$i]->tags,'insit_autoriza'); ?>"/>							
							
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
						/ Total: <? echo number_format(str_replace(",",".",$vlrtotal),2,",","."); ?>
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
	
	<fieldset id="fsetDestino" name="fsetDestino" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Destino"; ?></legend>
		
		<label for="nrconta_dest"><? echo utf8ToHtml('Conta:') ?></label>
		<input type="text" id="nrconta_dest" name="nrconta_dest"/>
		<input type="text" id="nrdigito_dest" name="nrdigito_dest"/>
		
		<label for="nmtitular_dest"><? echo utf8ToHtml('Titular:') ?></label>
		<input type="text" id="nmtitular_dest" name="nmtitular_dest"/>
		
		<br style="clear:both" />
		
		<label for="nrcpfcgc_dest"><? echo utf8ToHtml('CPF/CNPJ:') ?></label>
		<input type="text" id="nrcpfcgc_dest" name="nrcpfcgc_dest"/>
		
		<label for="cdbanco_dest"><? echo utf8ToHtml('Banco:') ?></label>
		<input type="text" id="cdbanco_dest" name="cdbanco_dest"/>
		<input type="text" id="dsbanco_dest" name="dsbanco_dest"/>
		
		<br style="clear:both" />
		
		<label for="cdagenci_dest"><? echo utf8ToHtml('Ag&ecirc;ncia:') ?></label>
		<input type="text" id="cdagenci_dest" name="cdagenci_dest"/>
		<input type="text" id="dsagenci_dest" name="dsagenci_dest"/>

		<br style="clear:both" />
		
		<label for="insit_autoriza"><? echo utf8ToHtml('Situa&ccedil;&atilde;o:') ?></label>
		<input type="text" id="insit_autoriza" name="insit_autoriza"/>		
		
		<br style="clear:both" />
		
	</fieldset>
	
</form>

<div id="divBotoesContas" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:block;'>
																			
	<a href="#" class="botao" id="btVoltar" onClick="controlaVoltar('2'); return false;">Voltar</a>																																							
	<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'gerarTedRateioCapital();', '$(\'#btVoltar\',\'#divBotoesContas\').focus();', 'sim.gif', 'nao.gif');">Concluir</a>	
		   																			
</div>


<script type="text/javascript">
	
	$('a.paginacaoAnt','#frmContas').unbind('click').bind('click', function() {
		
		buscarContasRateioTedCapital('<? echo ($nriniseq - $nrregist)?>','<?php echo $nrregist?>');
		
    });

	$('a.paginacaoProx','#frmContas').unbind('click').bind('click', function() {
		
		buscarContasRateioTedCapital('<? echo ($nriniseq + $nrregist)?>','<?php echo $nrregist?>');
		
	});	

	$('#divRegistrosRodape','#frmContas').formataRodapePesquisa();
	$('#divDetalhes').css({'display':'block'});	
	
	formataFormContas();
	formataTabelaContasRateioTedCapital();		
				
</script>