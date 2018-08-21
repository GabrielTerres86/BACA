<?
/*!
 * FONTE        : pagamento_prejuizo.php
 * CRIAÇÃO      : Marcel Kohls (AMCom)
 * DATA CRIAÇÃO : 28/06/2018
 * OBJETIVO     : Tela para entrada de informacoes de pagamento de prejuizo de conta corrente.

   ALTERACOES   : 01/08/2018 - Ajuste nos campos do pagamento do prejuízo da conta transitória
			   		   		   PJ450 - Diego Simas - AMcom

			      20/08/2018 - Incluído campo Juros referente ao juros remuneratório da conta transitória.
				  		       PJ450 - Diego Simas - AMcom
 */
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');


	$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;

	$xml2  = "<Root>";
	$xml2 .= " <Dados>";
	$xml2 .= "   <cdcooper>".$cdcooper."</cdcooper>";
	$xml2 .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml2 .= " </Dados>";
	$xml2 .= "</Root>";

	$procedure2 = "BUSCA_VLRS_PGTO_PREJUZ_CC";

	$xmlResult = mensageria($xml2, "TELA_ATENDA_DEPOSVIS", $procedure2, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	$dadosPrejuCC = $xmlObjeto->roottag->tags[0]->tags;

?>
<table id="tdImp"cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">
			<table border="0" cellpadding="0" cellspacing="0" width="300">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><?php echo utf8ToHtml('Pagamento Prejuízo C/C'); ?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="mostraDetalhesCT();return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
									<div id="divPagPrejCC" align="left" >
										<form id="frmPagPrejCC" name="frmPagPrejCC" class="formulario">
											<table width="100%">
												<tr>
													<td><label for="vlsdprej">&nbsp;&nbsp;<?php echo utf8ToHtml('Saldo Devedor:') ?></label></td>
													<td><input type="text" id="vlsdprej" name="vlsdprej" value="<? echo getByTagName($dadosPrejuCC,'vlsdprej'); ?>" disabled readonly class="moeda campo campoTelaSemBorda" /></td>
												</tr>
												<tr>
													<td><label for="juremune">&nbsp;&nbsp;<?php echo utf8ToHtml('Juros:') ?></label></td>
													<td><input type="text" id="juremune" name="juremune" value="<? echo getByTagName($dadosPrejuCC,'juremune'); ?>" disabled readonly class="moeda campo campoTelaSemBorda" /></td>
												</tr>												
												<tr>
													<td><label for="vltotiof">&nbsp;&nbsp;<?php echo utf8ToHtml('IOF:') ?></label></td>
													<td><input type="text" id="vltotiof" name="vltotiof" value="<? echo getByTagName($dadosPrejuCC,'vltotiof') ?>" disabled readonly class="moeda campo campoTelaSemBorda" /></td>
												</tr>
												<tr>
													<td><label for="vlpagto">&nbsp;&nbsp;<?php echo utf8ToHtml('Valor:') ?></label></td>
													<td><input type="text" id="vlpagto" name="vlpagto" value="" onkeyup="calcularSaldo()" class="moeda campo" /></td>
												</tr>
												<tr>
													<td><label for="vlabono">&nbsp;&nbsp;<?php echo utf8ToHtml('Abono:') ?></label></td>
													<td><input type="text" id="vlabono" name="vlabono" value="" onkeyup="calcularSaldo()" class="moeda campo" /></td>
												</tr>
												<tr>
													<td><label for="vlsaldo">&nbsp;&nbsp;<?php echo utf8ToHtml('Saldo:') ?></label></td>
													<td><input type="text" id="vlsaldo" disabled  name="vlsaldo" value="" disabled readonly class="moeda campo campoTelaSemBorda" /></td>
												</tr>
											</table>
										</form>

										<div id="divBotoes">
											<input type="image" id="btVoltar" src="<?php echo $UrlImagens; ?>botoes/voltar.gif"    onClick="mostraDetalhesCT();return false;" />
											<input type="image" id="btSalvar" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="efetuaPagamentoPrejuizoCC();" />
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
	formataPagamentoPrejuzCC();
	calcularSaldo();
</script>
