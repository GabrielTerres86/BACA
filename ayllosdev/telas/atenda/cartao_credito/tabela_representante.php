<? 
/*!
 * FONTE        : tabela_representante.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : 13/10/2015
 * OBJETIVO     : Formulario para selecionar o representante
 * ALTERACOES   : 
 */ 
?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td>
			<table border="0" cellpadding="0" cellspacing="0" width="500">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">REPRESENTANTES</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico'),divRotina);"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela">	
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
										<form name="frmDadosRepresentante" id="frmDadosRepresentante" class="formulario">	
											<fieldset>
												<legend>Seleção de Representantes</legend>												
												
												<div id="divSelecaoAvalista" class="divRegistros">
													<table class="tituloRegistros">
														<thead>
															<tr>
																<th></th>
																<th style="text-align:left;">Documento</th>
																<th style="text-align:left;">Nome</th>
															</tr>
														</thead>
														<tbody>
											  		 <? 
														$indice = 0;
														foreach($avalistas as $avalista){
														
															if (getByTagName($avalista->tags,'nrcpfcgc') > 0) {
														?>
																<tr>
																	<td style="width:5px;">
																		<input type="checkbox" name="nrseqavl[]" id="nrseqavl<?= $indice ?>" value="<?= getByTagName($avalista->tags,'nrcpfcgc') ?>">
																	</td>
																	<td><span><?= getByTagName($avalista->tags,'nrcpfcgc'); ?></span>
																			  <?= formatar(getByTagName($avalista->tags,'nrcpfcgc'),'cpf',true) ?>
																	</td>
																	<td><span><?= getByTagName($avalista->tags,'nmdavali'); ?></span>
																			  <?= getByTagName($avalista->tags,'nmdavali'); ?>
																	</td>
																</tr>
																
														<?  	$indice++;
															}
														}  ?>
														</tbody>
													</table>
												</div>
											</fieldset>
										</form>											
										<div id="divBotoes">
											<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"    onClick="fechaRotina($('#divUsoGenerico'),divRotina);return false;" />
											<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/concluir.gif" onClick="fechaRotina($('#divUsoGenerico'),divRotina); validarNovoCartao(); return false;" />
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