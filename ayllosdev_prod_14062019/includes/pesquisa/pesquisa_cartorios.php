<? 
/*!
 * FONTE        : pesquisa_cartorios.php
 * CRIAÇÃO      : Helinton Steffens (Supero)
 * DATA CRIAÇÃO : 20/03/2018 
 * OBJETIVO     : Formulário para pesquisar cartorios que pode ser chamado de diferentes pontos do sistema
 */	
?>

<div id="divPesquisaCartorios" class="divPesquisa">
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
			<td align="center">		
				<table border="0" cellpadding="0" cellspacing="0" width="500">
					<tr>
						<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="11"><img src="<? echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
									<td class="txtBrancoBold ponteiroDrag" style="text-transform: uppercase;" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><span class="tituloJanelaPesquisa">PESQUISA DE CARTORIOS</span></td>
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
										<table width="100%" border="0" cellpadding="0" cellspacing="0">
											<tr>
												<td align="center">												

													<!-- INICIO DO FORMULARIO -->
													<form name="frmPesquisaCartorios" id="frmPesquisaCartorios" class="formulario">														
														<input type="hidden" name="nriniseq" id="nriniseq" />
														
														<label for="cdpesqui" style="width:150px">Pesquisar por cartorios:</label>														
														<input type="radio" name="cdpesqui" id="titular" checked value="1" class="radio" /> 
														<label for="titular" class="radio">Nome do Cart&oacuterio</label> 														
														<input type="radio" name="cdpesqui" id="integra" value="2" class="radio" /> 
														<label for="integra" class="radio">Cidade</label>														
														<input type="radio" name="cdpesqui" id="cpfcnpj" value="3" class="radio" /> 
														<label for="integra" class="radio">CPF/CNPJ</label>														
														<br style="clear:both" />
														
														<label for="nmdbusca" style="width:150px">Nome a pesquisar:</label>
														<input type="text" name="nmdbusca" id="nmdbusca" class="campo alphanum" />
														<br style="clear:both" />

														<label for="nrcpfcgc" style="width:150px">CPF/CNPJ:&nbsp;</label>
														<input type="text" name="nrcpfcgc" id="nrcpfcgc" class="campo inteiro" maxlength="14" style="width:109;"/>
														
														<br style="clear:both" />

														<label for="cdcidade" style="width:150px">Cidade:</label>
														<input type="text" name="cdcidade" id="cdcidade" class="campo alphanum" maxlength="14" style="width:109;"/>
														
														<br style="clear:both" />
																											
													    <label for="tpdorgan" style="width:150px"> Organizar: </label>
														<select name="tpdorgan" id="tpdorgan" class="campo" style="width:109;" >
															<option value="1" selected> Nome </option>
														    <option value="2"> N&uacute;mero de CPF/CNPJ </option>
														</select>
														<br style="clear:both" />
														
														<label for="botao" style="width:150px"></label>
														<input type="image" src="<? echo $UrlImagens; ?>botoes/iniciar_pesquisa.gif" onClick="pesquisaCartorio(1);return false;">
														
														<br clear="both" />
													</form>																								

													<!-- CABEÇALHO DO RESULTADO DA CONSULTA -->
													<div id="divCabecalhoPesquisaCartorio" class="divCabecalhoPesquisa">
														<table>
															<thead>
																<tr> 
																	<td style="width:90px;text-align:center;font-size:11px;">CPF/CNPJ</td>
																	<td style="width:256px;font-size:11px;">Nome Pesquisado</td>
																	<td style="text-align:60px;font-size:11px;">Cidade</td>
																</tr>
															</thead>
														</table>
													</div>

													<!-- DIV DO RESULTADO DA CONSULTA -->
													<div id="divResultadoPesquisaCartorio" class="divResultadoPesquisa">
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