<? 
/*!
 * FONTE        : zoom_plano.php
 * CRIAÇÃO      : Marcelo Leandro Pereira
 * DATA CRIAÇÃO : 28/09/2011
 * OBJETIVO     : Zoom que lista os planos
 *
 */
 ?> 
 
<?
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");	
?>

<table id="altera"cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="228px">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Pesquisa</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico'),divRotina);"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick=<?php echo "acessaOpcaoAba(".count($opcoesTela).",0,'".$opcoesTela[0]."');"; ?> class="txtNormalBold">Principal</a></td>
																																					
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divZoomPlano">
										<div id="divRegistros" class="divRegistros">
											<table>
												<thead>
													<tr>
														<th>Plano</th>
														<th>Moradia</th>
														<th><? echo utf8ToHtml('Ocupação');?></th>
													</tr>
												</thead>
												<tbody>
													<?
														foreach( $planos as $plano ) {
														?>
														<tr>
															<td><? echo getByTagName($plano->tags,'tpplaseg'); ?></td>
															<td><? echo getByTagName($plano->tags,'dsmorada'); ?></td>
															<td><? echo getByTagName($plano->tags,'dsocupac'); ?></td>
														</tr>
													<? } ?>
												</tbody>
											</table>
										</div>
										<div id="camposZoom">
											<fieldset>
											
												<form name="frmZoom" id="frmZoom" class="formulario">	
													<label for="vlplaseg"><? echo utf8toHtml('Prêmio:'); ?></label>
													<input name="vlplaseg" id="vlplaseg" type="text" value="" />

													<label for="flgunica">Tipo Parcela:</label>
													<input name="flgunica" id="flgunica" type="text" value="" />
													
													<label for="qtmaxpar"><? echo utf8toHtml('Quantidade máxima de parcelas:'); ?></label>
													<input name="qtmaxpar" id="qtmaxpar" type="text" value="" />

													<label for="mmpripag"><? echo utf8toHtml('Meses carência primeiro pagamento:'); ?></label>
													<input name="mmpripag" id="mmpripag" type="text" value="" />

													<label for="qtdiacar"><? echo utf8toHtml('Dias carência primeiro pagamento:'); ?></label>
													<input name="qtdiacar" id="qtdiacar" type="text" value="" />

													<label for="ddmaxpag"><? echo utf8toHtml('Debitar parcela até dia:'); ?></label>
													<input name="ddmaxpag" id="ddmaxpag" type="text" value="" />
												</form>
											
											</fieldset>
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