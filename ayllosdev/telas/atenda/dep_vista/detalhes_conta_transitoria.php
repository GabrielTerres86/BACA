<?php
/*!
 * FONTE        : detalhes_atraso.php
 * CRIAÇÃO      : Marcel Kohls (AMCom)
 * DATA CRIAÇÃO : 15/03/2018
 * OBJETIVO     : Exibe detalhes dos valores de atraso
 */

session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');

// Monta o xml de requisiусo
$xmlCreditosRecebidos  = "";
$xmlCreditosRecebidos .= "<Root>";
$xmlCreditosRecebidos .= "   <Dados>";
$xmlCreditosRecebidos .= "	   <nrdconta>".$_POST["nrdconta"]."</nrdconta>";
$xmlCreditosRecebidos .= "   </Dados>";
$xmlCreditosRecebidos .= "</Root>";

// Executa script para envio do XML
$xmlResult = mensageria($xmlCreditosRecebidos, "TELA_ATENDA_DEPOSVIS", "BUSCA_SALDOS_DEVEDORES", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

// Cria objeto para classe de tratamento de XML
$xmlObjCreditos = getObjectXML($xmlResult);

// Se ocorrer um erro, mostra crьtica
if (strtoupper($xmlObjCreditos->roottag->tags[0]->name) == "ERRO") {
	exibirErro('error',$xmlObjCreditos->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))');
}

$registros = $xmlObjCreditos->roottag;

$saldoDevedorAte59 = $registros->tags[0]->tags[0]->cdata;
$saldoDevedorMais60 = $registros->tags[0]->tags[1]->cdata;
$iofDebitar = $registros->tags[0]->tags[2]->cdata;
$saldoDevedorTotal = $registros->tags[0]->tags[3]->cdata;
?>

<table id="tdImp"cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">
			<table border="0" cellpadding="0" cellspacing="0" width="650">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Detalhes da Conta <?php echo utf8ToHtml('Transitória'); ?></td>
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
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px 2px 8px;">
									<div id="divConteudoOpcao">
										<form action="" method="post" name="frmDadosDetalhesAtraso" id="frmDadosDetalhesAtraso" class="formulario" >
											<fieldset>
												<div id="divTabContraOrdens">
													<div class="divRegistros">
														<table>
															<thead>
																<tr>
																	<th><? echo utf8ToHtml('Data'); ?></th>
																	<th><? echo utf8ToHtml('Histórico');  ?></th>
																	<th><? echo utf8ToHtml('Docmto');  ?></th>
																	<th><? echo utf8ToHtml('D/C');  ?></th>
																	<th><? echo utf8ToHtml('Valor');  ?></th>
																	<th><? echo utf8ToHtml('Saldo');  ?></th>
																</tr>
															</thead>
															<tbody>
																<tr>
																	<td><span>Teste</span>
																		Teste
																	</td>
																	<td><span>Teste</span>
																		Teste
																	</td>
																	<td><span>Teste</span>
																		Teste
																	</td>
																	<td><span>Teste</span>
																		Teste
																	</td>
																	<td><span>Teste</span>
																		Teste
																	</td>
																	<td><span>Teste</span>
																		Teste
																	</td>
																</tr>
																<tr>
																	<td><span>Teste</span>
																		Teste
																	</td>
																	<td><span>Teste</span>
																		Teste
																	</td>
																	<td><span>Teste</span>
																		Teste
																	</td>
																	<td><span>Teste</span>
																		Teste
																	</td>
																	<td><span>Teste</span>
																		Teste
																	</td>
																	<td><span>Teste</span>
																		Teste
																	</td>
																</tr>
															</tbody>
														</table>
													</div>
												</div>
											</fieldset>
										</form>
										<div id="divBotoes">
											<a href="#" class="botao" id="btDetVoltar" onClick="fechaRotina($('#divUsoGenerico'),divRotina);">Pagamento de Empr&eacute;stimo</a>
											<a href="#" class="botao" id="btDetVoltar" onClick="fechaRotina($('#divUsoGenerico'),divRotina);">Libera&ccedil;&atilde;o de Saque</a>
											<a href="#" class="botao" id="btDetVoltar" onClick="mostraPagamentoPrejuzCC();">Pagamento Preju&iacute;zo c/c</a>
											<a href="#" class="botao" id="btDetVoltar" onClick="fechaRotina($('#divUsoGenerico'),divRotina);">Imprimir Extrato</a>
											</br></br>
											<a href="#" class="botao" id="btDetVoltar" onClick="fechaRotina($('#divUsoGenerico'),divRotina);">Voltar</a>
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

<script type="text/javascript">
	// Formata layout
	formataLancamentosCT();

	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conte&uacute;do que est&aacute; &aacute;tras do div da rotina
	blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
