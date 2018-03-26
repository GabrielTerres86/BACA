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
			<table border="0" cellpadding="0" cellspacing="0" width="400">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Detalhes de Atraso / Preju&iacute;zo</td>
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
												<label for="vliofadb" class="rotulo"><? echo utf8ToHtml('IOF a debitar:') ?></label>
												<input name="vliofadb" id="vliofadb" type="text" class="campo" value="<?php echo $iofDebitar; ?>" />

												<label for="vlsddv59" class="rotulo"><? echo utf8ToHtml('Saldo devedor até 59 dias:') ?></label>
												<input name="vlsddv59" id="vlsddv59" type="text"  class="campo" value="<?php echo $saldoDevedorAte59; ?>" />

												<label for="vlsddv60" class="rotulo"><? echo utf8ToHtml('Saldo devedor juros + 60 dias:') ?></label>
												<input name="vlsddv60" id="vlsddv60" type="text"  class="campo" value="<?php echo $saldoDevedorMais60; ?>" />

												<label for="vlttifsd" class="rotulo"><? echo utf8ToHtml('Saldo devedor Total:') ?></label>
												<input name="vlttifsd" id="vlttifsd" type="text"  class="campo" value="<?php echo $saldoDevedorTotal; ?>" />
											</fieldset>
										</form>
                    <div id="divBotoes">
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
<form name="frmImprimir" id="frmImprimir" style="display:none;">
    <input name="sidlogin" id="sidlogin" type="hidden"  />
	<input name="nmarquiv" id="nmarquiv" type="hidden"  />
	<input name="nrdconta" id="nrdconta" type="hidden"  />
	<input name="nrctremp" id="nrctremp" type="hidden"  />
</form>
<script type="text/javascript">
controlaLayout('frmDadosDetalhesAtraso');
// Esconde mensagem de aguardo
//hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
//blockBackground(parseInt($("#divRotina").css("z-index")));
</script>
