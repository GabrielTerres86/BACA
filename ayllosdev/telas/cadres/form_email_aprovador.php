<? 
/*!
 * FONTE        : form_email_aprovador.php
 * CRIACAO      : Andre Clemer - Supero
 * DATA CRIACAO : 13/09/2018
 * OBJETIVO     : Formulario para inclusao/edicao de email dos aprovadores
 *
 * ALTERACOES   : 
 *
 */	
?>
<div id="divEmailAprovador" class="divPesquisa" style="z-index:102">
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
			<td align="center">
				<table border="0" cellpadding="0" cellspacing="0" width="500">
					<tr>
						<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="11"><img src="<? echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
									<td class="txtBrancoBold ponteiroDrag" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><span class="tituloJanelaPesquisa">E-mail do Aprovador</span></td>
									<td width="12" id="tdTitTela" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a class="fecharPesquisa" onclick="fechaRotina($('#divEmailAprovador'));exibeRotina($('#divRotina'));blockBackground(parseInt($('#divRotina').css('z-index')));return false;"><img src="<? echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
                                                    <form name="frmEmailAprovador" id="frmEmailAprovador" class="formulario">
                                                        <input type="hidden" id="cdalcada" value="" />
                                                        <input type="hidden" id="cdaprovador" value="" />
                                                        <input type="hidden" id="cdmetodo" value="I" />

                                                        <label style="font-weight: normal;width:120px">Nome: </label>
                                                        <label id="lbnome" style="margin-left: 2px;">&nbsp;</label>
                                                        <hr style="background-color:#ddd; height:1px; clear:both">
                                                        <label for="dsemail" style="width:120px">E-mail:</label>
                                                        <input type="email" name="dsemail" id="dsemail" class="campo email" autocomplete="off" style="width:240px" />
                                                        <br clear="both" />
                                                        <div id="divBotoes" style="margin-bottom: 10px;">
                                                            <a href="#" class="botao" id="btConfirmarEmail" onclick="PopupAprovadores.onClick_Confirmar();">Confirmar</a>
                                                            <a href="#" class="botao" id="btVoltar" onclick="PopupAprovadores.onClick_Voltar();">Voltar</a>
                                                        </div>
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