<? 
/*!
 * FONTE        : pesquisa_endereco_associado.php
 * CRIAÇÃO      : Kelvin Souza Ott
 * DATA CRIAÇÃO : Setembro/2017
 * OBJETIVO     : Formulário para pesquisar endereços do associado
 */	
?>

<div id="divPesquisaEnderecoAssociado" class="divPesquisa" tabindex="0">
	<input type="hidden" name="idForm" id="idForm" value="" />
	<input type="hidden" name="camposOrigem" id="camposOrigem" value="" />
	<input type="hidden" name="nrcpfcgc" id="nrcpfcgc" value="" />
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
			<td align="center">		
				<table border="0" cellpadding="0" cellspacing="0" width="545px">
					<tr>
						<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="11"><img src="<? echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
									<td class="txtBrancoBold ponteiroDrag" style="text-transform: uppercase;" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><span class="tituloJanelaPesquisa ponteiroDrag"><? echo utf8ToHtml('Endereço Associado'); ?></span></td>
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
													<div id="divCabecalhoPesquisaEnderecoAssociado" class="divCabecalhoPesquisa">
														<table>
															<thead>
																<tr>
																<td style="width:54px; text-align:right;">CEP</td>
																<td style="width:174px; text-align:left;">Endere&ccedil;o</td>
																<td style="width:95px; text-align:left;">Bairro</td>
																<td style="width:94px; text-align:left;">Cidade</td>
																<td style="text-align:center;">UF</td>
																</tr>
															</thead>
														</table>
													</div>
													
													<!-- TABELA DE RESULTADO DA CONSULTA -->
													<!-- CONTEUDO MONTADO DINAMICAMENTE -->
													<div id="divResultadoPesquisaEnderecoAssociado" class="divResultadoPesquisa" style='height:184px'>
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


