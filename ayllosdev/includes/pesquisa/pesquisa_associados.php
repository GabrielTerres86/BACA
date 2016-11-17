<? 
/*!
 * FONTE        : pesquisa_associado.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 16/03/2010 
 * OBJETIVO     : Formulário para pesquisar associados que pode ser chamado de diferentes pontos do sistema
 
 ALTERACOES     : 05/11/2010 - Incluir campo tipo de organizacao , nome ou conta.
							   Incluir coluna com o PAC (Gabriel).	
				  24/10/2011 - Adicionado a opção de pesquisar o associado pelo CPF/CNPJ
								Rogerius Militão    (DB1)
			   
 
 */	
?>

<div id="divPesquisaAssociado" class="divPesquisa">
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
			<td align="center">		
				<table border="0" cellpadding="0" cellspacing="0" width="500">
					<tr>
						<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="11"><img src="<? echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
									<td class="txtBrancoBold ponteiroDrag" style="text-transform: uppercase;" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><span class="tituloJanelaPesquisa">PESQUISA DE ASSOCIADOS</span></td>
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
													<form name="frmPesquisaAssociado" id="frmPesquisaAssociado" class="formulario">														
														<input type="hidden" name="nriniseq" id="nriniseq" />
														
														<label for="cdpesqui">Pesquisar por:</label>														
														<input type="radio" name="cdpesqui" id="titular" checked value="1" class="radio" /> 
														<label for="titular" class="radio">Nome do Titular</label> 														
														<input type="radio" onkeydown="pesquisaAssociado_2_OnKeyDown()" name="cdpesqui" id="integra" value="2" class="radio" /> 
														<label for="integra" class="radio">Conta Integra&ccedil;&atilde;o</label>														
														<input type="radio" name="cdpesqui" id="cpfcnpj" value="3" class="radio" /> 
														<label for="integra" class="radio">CPF/CNPJ</label>														
														<br />
														
														<label for="nmdbusca">Nome a pesquisar:</label>
														<input type="text" name="nmdbusca" id="nmdbusca" class="campo alphanum" />
														<br />
														
														<label for="tpdapesq">Tipo Pesquisa:</label>
														<select name="tpdapesq" id="tpdapesq" class="campo" style="width:109;">
															<option value="0" selected>Titulares</option>
															<option value="1">C&ocirc;njuge</option>
															<option value="2">Pai</option>
															<option value="3">M&atilde;e</option>
															<option value="4">Pessoa Jur&iacute;dica</option>
														</select>
																							
														<label for="cdagpesq" style="width:auto;clear:none;margin-left:8px;">PAC</label>
														<input type="text" name="cdagpesq" id="cdagpesq" class="campo inteiro" />
														<br />
														
													    <label for="tpdorgan"> Organizar: </label>
														<select name="tpdorgan" id="tpdorgan" class="campo" style="width:109;" >
															<option value="1" selected> Nome </option>
														    <option value="2"> N&uacute;mero da conta </option>
														</select>
														
														<br />
														
														<label for="nrdctitg">Conta Integra&ccedil;&atilde;o:&nbsp;</label>
														<input type="text" name="nrdctitg" id="nrdctitg" class="campo inteiro" style="width:109;" />
														
														<br />
														
														<label for="nrcpfcgc">CPF/CNPJ:&nbsp;</label>
														<input type="text" name="nrcpfcgc" id="nrcpfcgc" class="campo inteiro" maxlength="14" style="width:109;"/>
														
														<br />
														
														<label for="botao"></label>
														<input type="image" src="<? echo $UrlImagens; ?>botoes/iniciar_pesquisa.gif" onClick="pesquisaAssociado(1);return false;">
														
														<br clear="both" />
													</form>																								

													<!-- CABEÇALHO DO RESULTADO DA CONSULTA -->
													<div id="divCabecalhoPesquisaAssociado" class="divCabecalhoPesquisa">
														<table>
															<thead>
																<tr>
																    <td style="width:30px;font-size:11px;">Pac</td>  
																	<td style="width:65px;text-align:center;font-size:11px;">Conta/dv</td>
																	<td style="width:256px;font-size:11px;">Nome Pesquisado</td>
																	<td style="text-align:60px;font-size:11px;">Conta/ITG</td>
																</tr>
															</thead>
														</table>
													</div>

													<!-- DIV DO RESULTADO DA CONSULTA -->
													<div id="divResultadoPesquisaAssociado" class="divResultadoPesquisa">
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