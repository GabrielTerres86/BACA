<?php
	 
 /************************************************************************
   Fonte: form_cabecalho.php
   Autor: Rogerius Militão - DB1
   Data : 29/06/2011                 Última Alteração: 00/00/0000

   Objetivo  : Anotações da tela ATENDA
			   
   Alterações: 
   09/08/2016 : Adicionado classes FirstAnota e LastAnota, necessarias para navegação - Evandro(RKAM)   
  ************************************************************************/
?>

<div id="divAnotacoes">
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="510">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">ANOTA&Ccedil;&Otilde;ES</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="encerraAnotacoes();return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr> 																						
				<tr>
					<td class="tdConteudoTela" align="center">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="2">
										<tr>
											<td align="center" valign="center">
												<form action="<?php echo $UrlSite;?>telas/atenda/imprimir_anotacoes.php" method="post" id="frmAnotacoes" name="frmAnotacoes">
												<input type="hidden" name="idimprim" id="idimprim" value="0">
												<input type="hidden" name="nrdconta" id="nrdconta">
												<input type="hidden" name="sidlogin" id="sidlogin" value="<?php echo $glbvars["sidlogin"]; ?>">
												<table width="100%" cellpadding="0" cellspacing="0" border="0">
													<tr>
														<td>																													
															<table cellpadding="0" cellspacing="0" border="0">
																<tr>
																	<td width="60" height="25" class="txtNormalBold">Conta/dv:&nbsp;</td>
                                          <td width="77">
                                            <input name="nroconta" type="text" class="campoTelaSemBorda" id="nroconta" style="width: 67px; text-align: right;">
                                          </td>
																	<td width="45" align="right" class="txtNormalBold">Titular:&nbsp;</td>
                                          <td>
                                            <input name="nmprimtl" type="text" class="campoTelaSemBorda" id="nmprimtl" style="width: 272px;">
                                          </td>
																</tr>
															</table>																																		
														</td>
													</tr>
													<tr>
														<td>
															<div id="divListaAnotacoes" style="overflow-y: scroll; overflow-x: hidden; height: 190px; width: 478;"></div>
														</td>
													</tr>
													<tr>
														<td height="8"></td>
													</tr>
													<tr>
														<td align="center">
															<table cellpadding="0" cellspacing="3" border="0">
																<tr>
                                          <td align="center">
                                            <input class="FirstAnota" type="image" src="<?php echo $UrlImagens; ?>botoes/imprimir.gif" onClick="imprimeAnotacoes();return false;">
                                          </td>
																	<td width="8"></td>
                                          <td align="center">
                                            <input class="LastAnota" type="image" src="<?php echo $UrlImagens; ?>botoes/sair.gif" onClick="encerraAnotacoes();return false;">
                                          </td>
																</tr>
															</table>
														</td>
													</tr>														
												</table>
												</form>
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