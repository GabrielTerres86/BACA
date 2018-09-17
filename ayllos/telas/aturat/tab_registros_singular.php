<?php 
/*!
 * FONTE        : tab_registros_singular.php
 * CRIAÇÃO      : Andrei - RKAM
 * DATA CRIAÇÃO : Maio/2016
 * OBJETIVO     : Tabela que apresenta a consulta de ratings da tela ATURAT para as singulares
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

<form id="frmRating" name="frmRating" class="formulario" style="display:none;">

	<fieldset id="fsetRating" name="fsetRating" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend>Ratings</legend>
		
		<div id="divRatings">

			<label for="nrtopico"><? echo utf8ToHtml('T&oacute;pico:') ?></label>
			<input id="nrtopico" name="nrtopico" type="text" ></input>
			<input id="dstopico" name="dstopico" type="text" ></input>
			
			<br /> 

			<label for="nritetop"><? echo utf8ToHtml('Item:') ?></label>
			<input id="nritetop" name="nritetop" type="text" ></input>
			<input id="dsseqite" name="dsseqite" type="text" ></input>
		
			<div id="divRegistros" class="divRegistros">
		
				<table>
					<thead>
						<tr>
							<th>Sequ&ecirc;ncia</th>
							<th>Descri&ccedil;&atilde;o</th>
							<th>Nota</th>
							<th>Ativo</th>
						</tr>
					</thead>
					<tbody>
						<? for($i = 0; $i < count($registros); $i++){
							
							for($j = 0; $j < count($registros[$i]->tags); $j++){?>
							
								<script type="text/javascript">

									var regRating = new Object();
									regRating["nrsequen"] = "<? echo str_replace('.','',getByTagName($registros[$i]->tags[$j]->tags,'nrsequen'));?>";	
									regRating["nrtopico"] = "<? echo getByTagName($registros[$i]->tags[$j]->tags,'nrtopico');?>";
									regRating["nritetop"] = "<? echo getByTagName($registros[$i]->tags[$j]->tags,'nritetop');?>";
									regRating["nrseqite"] = "<? echo getByTagName($registros[$i]->tags[$j]->tags,'nrseqite');?>";
                  regRating["reg_craprat"] = "<? echo getByTagName($registros[$i]->tags[$j]->tags,'reg_craprat');?>";
									regRating["reg_craprai"] = "<? echo getByTagName($registros[$i]->tags[$j]->tags,'reg_craprai');?>";
									regRating["reg_craprad"] = "<? echo getByTagName($registros[$i]->tags[$j]->tags,'reg_craprad');?>";

								</script>
							
								<tr id="<? echo str_replace('.','',getByTagName($registros[$i]->tags[$j]->tags,'nrsequen')); ?>">	
									<td><span><? echo getByTagName($registros[$i]->tags[$j]->tags,'nrsequen'); ?></span> <? echo getByTagName($registros[$i]->tags[$j]->tags,'nrsequen'); ?> </td>
									<td><span><? echo getByTagName($registros[$i]->tags[$j]->tags,'descricao'); ?></span> <? echo getByTagName($registros[$i]->tags[$j]->tags,'dsseqite'); ?> </td>
									<td><span><? echo getByTagName($registros[$i]->tags[$j]->tags,'nota'); ?></span> <? echo getByTagName($registros[$i]->tags[$j]->tags,'nota'); ?> </td>
									<td><span><? echo getByTagName($registros[$i]->tags[$j]->tags,'selecionado'); ?></span><input id="flgativo" name="flgativo<? echo getByTagName($registros[$i]->tags[$j]->tags,'nrtopico').getByTagName($registros[$i]->tags[$j]->tags,'nritetop'); ?>" type="radio" value="<? echo getByTagName($registros[$i]->tags[$j]->tags,'selecionado'); ?>" <? if(getByTagName($registros[$i]->tags[$j]->tags,'selecionado') == "1"){echo 'checked';}?> > </td>

									<input type="hidden" id="topico" name="topico" value="<? echo getByTagName($registros[$i]->tags[$j]->tags,'nrtopico'); ?>" />
									<input type="hidden" id="itetop" name="itetop" value="<? echo getByTagName($registros[$i]->tags[$j]->tags,'nritetop'); ?>.<? echo getByTagName($registros[$i]->tags[$j]->tags,'nrseqite'); ?>" />
									<input type="hidden" id="dsc_topico" name="dsc_topico" value="<? echo getByTagName($registros[$i]->tags[$j]->tags,'dstopico'); ?>" />
									<input type="hidden" id="dsc_itetop" name="dsc_itetop" value="<? echo getByTagName($registros[$i]->tags[$j]->tags,'dsitetop'); ?>" />
									<input type="hidden" id="reg_craptor" name="reg_craptor" value="<? echo getByTagName($registros[$i]->tags[$j]->tags,'reg_craptor'); ?>" />
									<input type="hidden" id="reg_crapitr" name="reg_crapitr" value="<? echo getByTagName($registros[$i]->tags[$j]->tags,'reg_crapitr'); ?>" />
									<input type="hidden" id="reg_crapsir" name="reg_crapsir" value="<? echo getByTagName($registros[$i]->tags[$j]->tags,'reg_crapsir'); ?>" />
						
								</tr>	
						 
									<script type="text/javascript">

									rating["<? echo str_replace('.','',getByTagName($registros[$i]->tags[$j]->tags,'nrsequen'));?>"] = regRating;
								
								</script>

						 <?} ?>

						 <tr class="pulaLinha"></tr>

						<?}?>	

					</tbody>	
				</table>
			</div>
			<div id="divPesquisaRodape" class="divPesquisaRodape">
				<table>	
					<tr>
						<td>
							<?if (isset($qtregist) and count($qtregist) == 0) $nriniseq = 0;
							if ($nriniseq > 1) {
								?> <a class='paginacaoAnt'><<< Anterior</a> <?
							} else {
								?> &nbsp; <?
							}?>
						</td>
						<td>
							<? if (isset($nriniseq)) { ?>
								   Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?>
								<? } ?>
						</td>
						<td>
							<? if($qtregist > ($nriniseq + $nrregist - 1)) { ?>
								  <a class="paginacaoProx">Pr&oacute;ximo >>></a>
								  
								  <script type="text/javascript">

                      $('#btConcluir','#divBotoesRatingSingular').css('display','none');

                  </script>

							<? }else{ ?>
									<script type="text/javascript">
											
                     $('#btConcluir','#divBotoesRatingSingular').css('display','visible');
                   
                  </script>

									&nbsp;
							<? } ?>
						</td>
					</tr>
				</table>
			</div>	
		</div>
	</fieldset>	

</form>

<div id="divBotoesRatingSingular" style='text-align:center; margin-bottom: 10px; margin-top: 10px; display:none;' >
	<a href="#" class="botao" id="btVoltar" onclick="controlaVoltar('2'); return false;">Voltar</a>               
  <a href="#" class="botao" id="btConcluir" onclick="showConfirmacao('Deseja concluir a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'controlaConcluirSingular(\'<?php echo $nrdconta;?>\',\'<?php echo $nrctrrat;?>\',\'<?php echo $tpctrrat;?>\',\'<?php echo $insitrat;?>\',\'<?php echo $dsdopera;?>\',\'<?php echo $indrisco;?>\',\'<?php echo $nrnotrat;?>\');', '$(\'#btVoltar\', \'#divBotoesRatingSingular\').focus();', 'sim.gif', 'nao.gif'); return false;">Concluir</a>
</div>

<script type="text/javascript">

  $('a.paginacaoAnt').unbind('click').bind('click', function() {
    buscaRatingSingular("<?php echo $nrdconta?>","<?php echo $nrctrrat?>","<?php echo $tpctrrat?>","<?php echo $insitrat?>","<?php echo $dsdopera?>","<?php echo $indrisco?>","<?php echo $nrnotrat?>", <? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?> );
  });

	$('a.paginacaoProx').unbind('click').bind('click', function() {
		
		atualizaSelecionado2();
		buscaRatingSingular("<?php echo $nrdconta?>","<?php echo $nrctrrat?>","<?php echo $tpctrrat?>","<?php echo $insitrat?>","<?php echo $dsdopera?>","<?php echo $indrisco?>","<?php echo $nrnotrat?>", <? echo ($nriniseq + $nrregist)?>,<?php echo $nrregist?>);

  });

  $('#divPesquisaRodape').formataRodapePesquisa();
  formataFormularioRatingSingular();
  formataTabelaRatingSingular();
  $('#divTabela').css('display','block');
  $('#divBotoesRatingSingular').css('display','block');
  $('#btVoltar','#divBotoesRatingSingular').css('visible');

  $('#frmRating').css('display', 'block');

</script>