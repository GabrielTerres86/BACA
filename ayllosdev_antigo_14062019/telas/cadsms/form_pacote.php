<?php

/* !
 * FONTE        : consulta_menus.php
 * CRIAÇÃO      : Ricardo Linhares
 * DATA CRIAÇÃO : 22/02/2017
 * OBJETIVO     : Rotina para busca de valor de tarifa
 */
?>

<?php

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');

isPostMethod();

$idpacote = (isset($_POST['idpacote'])) ? $_POST['idpacote'] : 1;
$cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 3;

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <idpacote>".$idpacote."</idpacote>";
$xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CADSMS", "CONSULTAR_PACOTE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }

    exibirErro('error',"Erro ao consultar pacote",'Alerta - Ayllos','',false);

} else {

    $registro = $xmlObj->roottag->tags[0];

    $dspacote =  getByTagName($registro->tags,'dspacote');
    $cdtarifa =  getByTagName($registro->tags,'cdtarifa');
    $cdtarifa = getByTagName($registro->tags,'cdtarifa');
    $perdesconto = getByTagName($registro->tags,'perdesconto');
    $qtdsms = getByTagName($registro->tags,'qtdsms');
    $flgstatus = getByTagName($registro->tags,'flgstatus');
    $dspessoa = getByTagName($registro->tags,'dspessoa');
    $vlsms =   getByTagName($registro->tags,'vlsms');
    $vlsmsad =   getByTagName($registro->tags,'vlsmsad');
    $vlpacote =  getByTagName($registro->tags,'vlpacote');
    $dhultima_atu = getByTagName($registro->tags,'dhultima_atu');
    $cdoperad = getByTagName($registro->tags,'cdoperad');
}

?>

<style>
    .labelFormPacote {
        width:150px;
    }

	.registroinput {
		width: 115px;
	}

</style>

<script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>

<table id="telaDetalhamento"cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">
			<table border="0" cellpadding="0" cellspacing="0" width="585">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Detalhamento de Tarifas</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
                                        <form id="frmPacote" name="frmPacote" class="formulario" style="display:block;">

                                            <label for="idpacote" class="labelFormPacote"><? echo utf8ToHtml('Código:') ?></label>
                                            <input name="idpacote" id="idpacote" class="registroinput" type="text" style="margin-right: 5px" value=<? echo utf8ToHtml($idpacote) ?> />

                                            <label for="flgstatus" class="labelFormPacote"><? echo utf8ToHtml('Status do Pacote:') ?></label>
                                            <select id="flgstatus" name="flgstatus" style="width:115px" >
                                                <option value="1" <? echo $flgstatus == '1' ? 'selected' : '' ?>>Ativo</option>
                                                <option value="0" <? echo $flgstatus == '0' ? 'selected' : '' ?>>Inativo</option>
                                            </select>

                                            <br style="clear:both" />

                                            <label for="dspacote" class="labelFormPacote"><? echo utf8ToHtml('Descrição:') ?></label>
                                            <input name="dspacote" id="dspacote" style='width:388px' maxlength="30" type="text" style="margin-right: 5px" value="<? echo $dspacote ?>" />

                                            <br style="clear:both" />

                                            <label for="cdtarifa" class="labelFormPacote"><? echo utf8ToHtml('Código do Tarifa:') ?></label>
                                            <input name="cdtarifa" id="cdtarifa" class="registroinput" type="text" style="margin-right: 5px;" value=<? echo utf8ToHtml($cdtarifa) ?> />

                                            <label for="perdesconto" class="labelFormPacote"><? echo utf8ToHtml('% de Desconto:') ?></label>
                                            <input name="perdesconto" id="perdesconto" class="registroinput" type="text"  style="margin-right: 5px;" value=<? echo utf8ToHtml($perdesconto) ?> />

                                            <br style="clear:both" />

                                            <label for="qtdsms" class="labelFormPacote"><? echo utf8ToHtml('Quantidade de SMSs:') ?></label>
                                            <input name="qtdsms" id="qtdsms" class="registroinput" type="text" style="margin-right: 5px;" value=<? echo utf8ToHtml($qtdsms) ?> />

                                            <label for="vlsms" class="labelFormPacote"><? echo utf8ToHtml('Valor da SMS do Pacote:') ?></label>
                                            <input name="vlsms" id="vlsms" class="registroinput" type="text" style="margin-right: 5px;" value=<? echo utf8ToHtml($vlsms) ?> />

                                            <br style="clear:both" />

                                            <label for="vlsmsad" class="labelFormPacote"><? echo utf8ToHtml('Valor da SMS/Adicional:') ?></label>
                                            <input name="vlsmsad" id="vlsmsad" class="registroinput" type="text" style="margin-right: 5px;" value=<? echo utf8ToHtml($vlsmsad) ?> />

                                            <label for="dspessoa" class="labelFormPacote"><? echo utf8ToHtml('Tipo de Conta:') ?></label>
                                            <input name="dspessoa" id="dspessoa" class="registroinput" type="text" style="margin-right: 5px;" value="<? echo $dspessoa ?>" />

                                            <br style="clear:both" />

                                            <label for="vlpacote" class="labelFormPacote"><? echo utf8ToHtml('Valor do Pacote:') ?></label>
                                            <input name="vlpacote" id="vlpacote" class="registroinput" type="text" style="margin-right: 5px;" value=<? echo utf8ToHtml($vlpacote) ?> />

                                            <label for="dhultima_atu" style="width:32px;"><? echo utf8ToHtml('Data:') ?></label>
                                            <input name="dhultima_atu" id="dhultima_atu" type="text" style="margin-right: 5px; width:75px;" value="<? echo utf8ToHtml($dhultima_atu) ?>" />

                                            <label for="cdoperad" style="width:64px;"><? echo utf8ToHtml('Operador:') ?></label>
                                            <input name="cdoperad" id="cdoperad" type="text" style="margin-right: 5px; width:87px;" value=<? echo utf8ToHtml($cdoperad) ?> />

                                            <br style="clear:both" />

                                            <hr style="background-color:#666; height:1px;" />

                                            <div id="divBotoes" style="margin-bottom: 10px;">
                                                <a href="#" class="botao" id="btPopupVoltar" onClick="fechaRotina($('#divRotina'));">Voltar</a>
                                                <a href="#" class="botao" id="btPopupAlterar" onClick="PopupPacote.onClick_Alterar();">Alterar</a>
                                            </div>

                                        </form>
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
