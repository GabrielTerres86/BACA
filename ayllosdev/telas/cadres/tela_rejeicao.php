<? 
/*!
 * FONTE        : tela_rejeicao.php
 * CRIACAO      : Andre Clemer - Supero
 * DATA CRIACAO : 31/07/2018
 * OBJETIVO     : Tela para rejeição, aberta a partir de outras telas
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

// Recebe a operação que está sendo realizada
$cdcooper = (!empty($_POST['cdcooper'])) ? $_POST['cdcooper'] : $glbvars['cdcooper'];
$idrecipr = (!empty($_POST['idrecipr'])) ? $_POST['idrecipr'] : '7925'; //debug @TODO: buscar variavel
$cdalcada = (!empty($_POST['cdalcada'])) ? $_POST['cdalcada'] : '';

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
	exibeErroNew($msgError);
}

function exibeErroNew($msgErro) {
    exit('hideMsgAguardo();showError("error","' . $msgErro . '","Alerta - Ayllos","desbloqueia()");');
}
?>
<table id="telaRejeicao" cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">
			<table border="0" cellpadding="0" cellspacing="0" width="500">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<? echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><span class="tituloJanelaPesquisa">Rejei&ccedil;&atilde;o</span></td>
								<td width="12" id="tdTitTela" background="<? echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a class="fecharPesquisa" onclick="fechaRotina($('#telaRejeicao'));return false;"><img src="<? echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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

												<!-- CABECALHO DO RESULTADO DA CONSULTA -->
												<div id="divCabecalhoAprovacao" class="divCabecalhoPesquisa">
													<table width="100%" border="0" cellpadding="0" cellspacing="0">
														<thead>
															<tr>
																<td width="70%" style="font-size:11px;">Informe o motivo</td>
																<td width="30%" style="font-size:11px;">Usu&aacute;rio</td>
															</tr>
														</thead>
													</table>
												</div>

												<!-- DIV DO RESULTADO DA CONSULTA -->
												<div id="divResultadoAprovacao" class="divResultadoPesquisa" style="height:auto">
													<table width="100%" border="0" cellpadding="0" cellspacing="0">
														<tbody>
															<tr>
																<td width="70%" style="font-size:11px">
                                                                    <textarea id="dsjustificativa" class="textarea" style="height:60px;width:100%"></textarea>
                                                                </td>
																<td width="30%" style="padding:2px 4px;height:25px;font-size:11px">
                                                                    <?php echo $glbvars["nmoperad"]; ?>
                                                                </td>
															</tr>
														</tbody>
													</table>
												</div>

												<div id="divBotoes" style="margin-bottom: 10px;">
													<a href="#" class="botao" id="btPopupVoltar" onclick="fechaRotina($('#telaRejeicao'));">Voltar</a>
													<a href="#" class="botaoDesativado" id="btPopupRejeitar" onclick="rejeitarContrato(<?php echo $cdcooper; ?>,<?php echo $cdalcada; ?>,<?php echo $idrecipr; ?>)">Enviar</a>
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
<script>
	hideMsgAguardo();
	// exibe tela de aprovação
	$('#telaRejeicao').css('visibility','visible').setCenterPosition();

	// bloqueia div "pai"
	blockBackground(parseInt($("#divRotina").css("z-index")));

    var cJustificativa = $('#dsjustificativa', '#telaRejeicao');

    cJustificativa.unbind('input enter').bind('input enter', function (){

        var justific = $(this).val();

        if (justific && justific.trim()) {
            $('#btPopupRejeitar').trocaClass('botaoDesativado','botao').css('cursor','default').attr("onclick","rejeitarContrato(<?php echo $cdcooper; ?>,<?php echo $cdalcada; ?>,<?php echo $idrecipr; ?>);");
        } else {
            $('#btPopupRejeitar').trocaClass('botao','botaoDesativado').css('cursor','default').attr("onclick","return false;");
        }
    });
	
	// zebradoLinhaTabela($('#divResultadoAprovacao > table > tbody > tr'));

	function rejeitarContrato(cdcooper, cdalcada, idrecipr) {

        var justific = cJustificativa.val();

        if (justific && justific.trim() == '') {
            showError("error", "Campo justificativa n&atilde;o pode estar vazio.", "Alerta - Ayllos", "");
            return;
        }

		$.ajax({
			type: "POST",
			dataType: 'html',
			url: UrlSite + "telas/cadres/atualizar_contrato.php",
			data: {
				cddopcao: 'R',
				cdcooper: cdcooper,
				cdalcada: cdalcada,
				idrecipr: idrecipr,
				justific: justific,
				redirect: "script_ajax" // Tipo de retorno do ajax
			},
			error: function (objAjax, responseError, objExcept) {
				hideMsgAguardo();
				showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + objExcept.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
			},
			beforeSend: function () {
				showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
			},
			success: function (response) {
				eval(response);
				/*$('#divUsoGenerico').html(response);
				exibeRotina($('#divUsoGenerico'));*/
			}
		});
	}
</script>
