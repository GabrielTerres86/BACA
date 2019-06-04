<? 
/*!
 * FONTE        : popup_finalidade.php
 * CRIACAO      : Andre Clemer - Supero
 * DATA CRIACAO : 05/02/2019
 * OBJETIVO     : Formulario para inclusao/edicao de email dos aprovadores
 *
 * ALTERACOES   : 
 *
 */	

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

$modoAlteracao = ((!empty($_POST['modoAlteracao'])) ? $_POST['modoAlteracao'] : false);
?>
<div id="divPopup">
	<table cellpadding="0" cellspacing="0" border="0" width="100%">
		<tr>
			<td align="center">
				<table border="0" cellpadding="0" cellspacing="0" width="700">
					<tr>
						<td>
							<table width="100%" border="0" cellspacing="0" cellpadding="0">
								<tr>
									<td width="11"><img src="<? echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
									<td class="txtBrancoBold ponteiroDrag" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><span class="tituloJanelaPesquisa">Cadastro de Finalidade</span></td>
									<td width="12" id="tdTitTela" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a class="fecharPesquisa" onclick="popup.onClick_Voltar()"><img src="<? echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
													<br clear="both" />
                                                    <form name="frmFinalidade" id="frmFinalidade" class="formulario">
														<input type="hidden" id="cdfinalidade" name="cdfinalidade" value="" />
                                                        <label for="dsfinalidade" style="width:170px">Descri&ccedil;&atilde;o:</label>
                                                        <input type="text" name="dsfinalidade" id="dsfinalidade" class="campo" autocomplete="off" style="width:360px" maxlength="50" />
                                                        <br clear="both" />
                                                        <div id="divBotoes" style="margin-bottom: 10px;">
                                                            <a href="#" class="botao" id="btConfirmar" onclick="popup.onClick_Confirmar(<? echo $modoAlteracao; ?>, 0);">Confirmar</a>
                                                            <a href="#" class="botao" id="btVoltar" onclick="popup.onClick_Voltar()">Voltar</a>
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