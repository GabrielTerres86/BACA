<? 
/*!
 * FONTE        : pesquisa_motivo_devdoc.php
 * CRIAÇÃO      : Jorge Hamaguchi
 * DATA CRIAÇÃO : Março/2014 
 * OBJETIVO     : Formulário para listagem de motivos de devolucao de documento.
 */	
?>

<div id="divPesquisa" class="divPesquisa">
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
			<td align="center">		
				<table border="0" cellpadding="0" cellspacing="0" width="500px">
					<tr>
						<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="11"><img src="<? echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
									<td class="txtBrancoBold ponteiroDrag" style="text-transform: uppercase;" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><span class="tituloJanelaPesquisa ponteiroDrag">Motivos Devolu&ccedil;&atilde;o de DOC</span></td>
									<td width="12" id="tdTitTela" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a class="fecharPesquisa"><img src="<? echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
									<td width="8"><img src="<? echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
								</tr>
							</table>     
						</td> 
					</tr> 																						
					<tr>
						<td class="tdConteudoTela" align="center">
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
										<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
											<tr>
												<td align="center" valign="center">												
													
													<div id="divCabecalhoPesquisaMotivo" class="divCabecalhoPesquisa">
														<table>
															<thead>
																<tr>
																    <td style="width:40px;font-size:11px;">C&oacute;digo</td>  
																	<td style="text-align:center;font-size:11px;">Descri&ccedil;&atilde;o</td>
																</tr>
															</thead>
														</table>
													</div>
													
													<div id="divResultadoPesquisaMotivo" class="divResultadoPesquisa">
													<? require_once("../../includes/pesquisa/realiza_pesquisa_motivo_devdoc.php"); ?>
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
			</td>
		</tr>
	</table>																			
</div>