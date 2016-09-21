<?php
/* * *********************************************************************

  Fonte: form_motivos.php
  Autor: Jonathan - RKAM
  Data : Marco/2016                       Última Alteração:

  Objetivo  : Mostrar tabela de motivos.

  Alterações: 
  

 * ********************************************************************* */

 session_start();
 require_once('../../includes/config.php');
 require_once('../../includes/funcoes.php');
 require_once('../../includes/controla_secao.php');		
 require_once('../../class/xmlfile.php');
 isPostMethod();	

?>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Motivos</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="$('#btVoltar','#divRotina').click();return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center">	
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td>
									<table border="0" cellspacing="0" cellpadding="0">
										<tr>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold">Principal</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudoOpcao">

										<form id="frmMotivos" name="frmMotivos" class="formulario">	

											<fieldset>

												<legend> <? echo utf8ToHtml('Motivos')?>  </legend>

													<div id="divRegistros" class="divRegistros">
		
														<table>
															<thead>
																<tr>
																	<th>C&oacute;digo</th>
																	<th>Motivos</th>
																	<th>Valor</th>
																	<th>Hist&oacute;rico</th>
																</tr>
															</thead>
															<tbody>

																<?php
																if ( count($motivos) == 0 ) {
																	$i = 0;
																								
																	?> <tr>			
																			<b>Nenhum motivo encontrado.</b>																			
																		</tr>							
																<?	// Caso a pesquisa retornou itens, exibílos em diversas linhas da tabela
																} else {
																	 for($i = 0; $i < count($motivos); $i++){?>
								
																		<script type="text/javascript">

																			var regMotivo = new Object();
																			regMotivo["cddbanco"] = "<? echo getByTagName($motivos[$i]->tags,'cddbanco'); ?>";	
																			regMotivo["cdocorre"] = "<? echo getByTagName($motivos[$i]->tags,'cdocorre'); ?>";
																			regMotivo["cdmotivo"] = "<? echo getByTagName($motivos[$i]->tags,'cdmotivo'); ?>";
																			regMotivo["vltarifa"] = "<? echo getByTagName($motivos[$i]->tags,'vltarifa'); ?>";
																			regMotivo["cdtarhis"] = "<? echo getByTagName($motivos[$i]->tags,'cdtarhis'); ?>";

																		</script>

																		<tr id="<? echo getByTagName($motivos[$i]->tags,'cdocorre').getByTagName($motivos[$i]->tags,'tpocorre').getByTagName($motivos[$i]->tags,'cdmotivo'); ?>">	
																			<td><span><? echo getByTagName($motivos[$i]->tags,'cdmotivo'); ?></span> <? echo getByTagName($motivos[$i]->tags,'cdmotivo'); ?> </td>
																			<td><span><? echo getByTagName($motivos[$i]->tags,'dsmotivo'); ?></span> <? echo getByTagName($motivos[$i]->tags,'dsmotivo'); ?> </td>	
																			<td><span><? echo getByTagName($motivos[$i]->tags,'vltarifa'); ?></span> <input type="text" id="vltarifa" name="vltarifa" value="<?php echo number_format(str_replace(",",".",getByTagName($motivos[$i]->tags,'vltarifa')),2,",",".");?>" /> </td>
																			<td><span><? echo getByTagName($motivos[$i]->tags,'cdtarhis'); ?></span> <input type="text" id="cdtarhis" name="cdtarhis" value="<?php echo getByTagName($motivos[$i]->tags,'cdtarhis');?>" /> </td>
							
																		</tr>

																		<script type="text/javascript">

																			motivo["<? echo getByTagName($motivos[$i]->tags,'cdocorre').getByTagName($motivos[$i]->tags,'tpocorre').getByTagName($motivos[$i]->tags,'cdmotivo'); ?>"] = regMotivo;
								
																		</script>

																	<?}?>

																<?}?>
																
															</tbody>	
														</table>
													</div>
													<div id="divRegistrosRodape" class="divRegistrosRodape">
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
									
																		$('#btConcluir','#divBotoesMotivos').css('display','none');									

																	  </script>

																<? }else{ ?>
																		<script type="text/javascript">
	
																			if('<?echo $cddopcao;?>' == 'A' || '<?echo $cddopcao;?>' == 'I'){
																				$('#btConcluir','#divBotoesMotivos').css('display','visible');
																			}else{

																				$('#btConcluir','#divBotoesMotivos').css('display','none');

																			}

																		</script>

																		&nbsp;
																<? } ?>
															</td>
														</tr>
													   </table>
													</div>
											</fieldset>
	
										</form>																			

										<div id="divBotoesMotivos" style="margin-top:5px; margin-bottom :10px; text-align: center;">	
	
											<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina'));return false;" >Voltar</a>
												
											<?php if(($cddopcao == 'A' || $cddopcao == 'I') && $i > 0){?>											
												<a href="#" class="botao" id="btConcluir"  onClick="controlaConcluirMotivo();return false;">Concluir</a>	
											<?}?>
										</div>
									
									</div>
								</td>
							</tr>
						</table>			    
					</td> 
				</tr>
			</table>
		</td>
	</tr>
</table>			

<script text="text/javascript">

	$('a.paginacaoAnt','#frmMotivos').unbind('click').bind('click', function() {
		
		buscaMotivos('<? echo ($nriniseq - $nrregist)?>','<?php echo $nrregist?>','<?php echo $cddbanco?>','<?php echo $cdocorre?>');
		
    });

	$('a.paginacaoProx','#frmMotivos').unbind('click').bind('click', function() {
		
		atualizaArrayMotivo();
		buscaMotivos('<? echo ($nriniseq + $nrregist)?>','<?php echo $nrregist?>','<?php echo $cddbanco?>','<?php echo $cdocorre?>');
		
	});	

	$('#divRegistrosRodape','#divRotina').formataRodapePesquisa();	
	
	formataTabelaMotivos();	
	exibeRotina($('#divRotina'));	
	
</script>
		