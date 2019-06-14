<? 
/*!
 * FONTE        : tabela_pagamento_avalista.php
 * CRIAÇÃO      : James Prust Junior
 * DATA CRIAÇÃO : 05/06/2014
 * OBJETIVO     : Formulario para selecionar o avalista para efetuar o pagamento das parcelas
 * ALTERACOES   : 
 */ 
?>
<table id="tbprestacoes" cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td>
			<table border="0" cellpadding="0" cellspacing="0" width="500">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">PRESTACOES</td>
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
										<form name="frmDadosPagAval" id="frmDadosPagAval" class="formulario">	
											<fieldset>
												<legend>Seleção de Avalista</legend>												
												
												<div id="divSelecaoAvalista" class="divRegistros" style="overflow-y: hidden;">
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
															foreach($avalistas as $avalista){
																$inpessoa = getByTagName($avalista->tags,'inpessoa');
																$nrcpfcgc = getByTagName($avalista->tags,'nrcpfcgc');
																$nrseqavl = getByTagName($avalista->tags,'nrseqavl');
																if ($inpessoa == 1){
																	$nrcpfcgc = formatar($nrcpfcgc,'cpf',true);
																}else if ($inpessoa == 2){
																	$nrcpfcgc = formatar($nrcpfcgc,'cnpj',true);
																}
														?>
															<tr>
																<td style="width:5px;"><input type="radio" name="nrseqavl" id="nrseqavl<?= $nrseqavl ?>" value="<?= $nrseqavl?>"></td>
																<td><span><?= getByTagName($avalista->tags,'nrcpfcgc'); ?></span>
																		  <?= $nrcpfcgc ?>
																</td>
																<td><span><?= getByTagName($avalista->tags,'nmdavali'); ?></span>
																	 	  <?= getByTagName($avalista->tags,'nmdavali'); ?>
																</td>
															</tr>
														<?  }  ?>
														</tbody>
													</table>
												</div>
												
												<div>
													<table cellspacing="0" cellpadding="0">
														<tr>
															<td><input type="checkbox" name="outrosAvalistas" id="outrosAvalistas"></td>
															<td><label for="outrosAvalistas">&nbsp;Outros Avalistas</label></td>
														</tr>
													</table>
												</div>
												
												<div id="divOutrosAvalistas">
													<table cellspacing="0" cellpadding="0">
														<tr>
															<td><input type="radio" name="nrseqavl" id="nrseqavl3" value="3"></td>
															<td width="50px"><label for="nrseqavl3">Aval 3</label></td>
															<td><input type="radio" name="nrseqavl" id="nrseqavl4" value="4"></td>
															<td width="50px"><label for="nrseqavl4">Aval 4</label></td>
															<td><input type="radio" name="nrseqavl" id="nrseqavl5" value="5"></td>
															<td><label for="nrseqavl5">Aval 5</label></td>
														</tr>
													</table>
												</div>
												
											</fieldset>
										</form>											
										<div id="divBotoes">
											<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"    onClick="fechaRotina($('#divUsoGenerico'),divRotina);return false;" />
											<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="geraPagamentos(); return false;" />
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