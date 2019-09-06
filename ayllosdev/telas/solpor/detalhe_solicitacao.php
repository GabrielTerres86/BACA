<?php
/* !
 * FONTE        : detalhe_solicitacao.php
 * CRIAÇÃO      : Augusto - Supero
 * DATA CRIAÇÃO : 17/10/2018
 * OBJETIVO     : Janela de detalhe da solicitação
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */
session_start();

// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de funções
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");		
require_once("../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo m&eacute;todo POST
isPostMethod();	

// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");

$dsrowid = (!empty($_POST['dsrowid'])) ? $_POST['dsrowid'] : '';
$cddopcao = (!empty($_POST['cddopcao'])) ? $_POST['cddopcao'] : '';

function exibeErro($msgErro) {
	echo '<script type="text/javascript">';
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.addslashes($msgErro).'","Alerta - Aimaro","");';
	echo '</script>';
	exit();
}

$xml = new XmlMensageria();
$xml->add('dsrowid',$dsrowid);

$xmlResult = "";
if ($cddopcao == 'M' || $cddopcao == 'R') {
    $xmlResult = mensageria($xml, "SOLPOR", "DETALHE_PORTABILIDADE_RETORNO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
} else if($cddopcao == 'E') {
    $xmlResult = mensageria($xml, "SOLPOR", "DETALHE_PORTABILIDADE_ENVIO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
} else {
    exibeErro("Opção inválida.");
}
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
    exibeErro($msgErro);
}

$solicitacao = $xmlObj->roottag->tags[0]->tags[0]->tags;
$dtsolicitacao = getByTagName($solicitacao,"dtsolicitacao");
$nusolicitacao = getByTagName($solicitacao,"nusolicitacao");
$nrdconta = getByTagName($solicitacao,"nrdconta");
$nrcpfcgc = getByTagName($solicitacao,"nrcpfcgc");
$telefone = getByTagName($solicitacao,"telefone");
$email = getByTagName($solicitacao,"email");
$nmprimtl = getByTagName($solicitacao,"nmprimtl");
$nrcnpj_empregador = getByTagName($solicitacao,"nrcnpj_empregador");
$dsnome_empregador = getByTagName($solicitacao,"dsnome_empregador");
$banco = getByTagName($solicitacao,"banco");
$nrispb_banco_folha = getByTagName($solicitacao,"nrispb_banco_folha");
$nrcnpj_banco_folha = getByTagName($solicitacao,"nrcnpj_banco_folha");
$cdagencia_destinataria = getByTagName($solicitacao,"cdagencia_destinataria");
$nrdconta_destinataria = getByTagName($solicitacao,"nrdconta_destinataria");
$situacao = getByTagName($solicitacao,"situacao");
$dtretorno = getByTagName($solicitacao,"dtretorno");
$dtavaliacao = getByTagName($solicitacao,"dtavaliacao");
$motivo = getByTagName($solicitacao,"motivo");
$nrsolicitacao = getByTagName($solicitacao,"nrsolicitacao");
$tppessoa_empregador = getByTagName($solicitacao,"tppessoa_empregador");

?>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
    <tr>
        <td align="center">
            <table border="0" cellpadding="0" cellspacing="0" width="665">
                <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                                <td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">DETALHE</td>
                                <td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico'));return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
                                <td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td class="tdConteudoTela" align="center">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td>
                                    <table border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
                                            <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick="return false;" class="txtNormalBold">Principal</a></td>
                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
                                            <td width="1"></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                                    <div id="divCabecalho">
                                        <form class="formulario">
                                            <fieldset style="margin-top:10px">
                                                <legend>Portabilidade</legend>

                                                <label style="margin-left: 15px;width: 106px;">Data Solicita&ccedil;&atilde;o:</label>
                                                <input value="<?=$dtsolicitacao?>" type="text" class="campoTelaSemBorda" readonly disabled style="margin-right: 5px;">

                                                <label style="margin-left: 15px;width: 120px;">NU:</label>
                                                <input value="<?=$nusolicitacao?>" type="text" class="campoTelaSemBorda" style="width: 160px;" readonly disabled>

                                                <br style="clear:both" />

                                                <label style="margin-left: 15px;width: 105px;">Conta:</label>
                                                <input value="<?=$nrdconta?>" type="text" class="campoTelaSemBorda" readonly disabled style="width: 85px;margin-right: 5px;">

                                                <label style="margin-left: 15px;width: 50px;">CPF:</label>
                                                <input value="<?=$nrcpfcgc?>" type="text" class="campoTelaSemBorda" readonly disabled style="width: 100px;margin-right: 5px;">

                                                <label style="margin-left: 15px;">Telefone:</label>
                                                <input value="<?=$telefone?>" style="width: 112px;" type="text" class="campoTelaSemBorda" readonly disabled>

                                                <br style="clear:both" />

                                                <label style="margin-left: 15px;width: 105px;">E-mail:</label>
                                                <input value="<?=$email?>" type="text" class="campoTelaSemBorda" style="width: 446px;" readonly disabled>
                                                
                                                <br style="clear:both" />

                                                <label style="margin-left: 15px;width: 105px;">Nome:</label>
                                                <input value="<?=$nmprimtl?>" type="text" class="campoTelaSemBorda" style="width: 446px;" readonly disabled>
                                            </fieldset>

                                            <fieldset style="margin-top:10px">
                                                <legend>Empregador</legend>

												<label style="margin-left: 15px;width:105px" id="lbl_tppessoa_empregador" class="clsCampos">Tipo:</label>
												<input type="radio" style="margin-right: 5px" <?=($tppessoa_empregador == "1" ? "checked" : "")?> id="tppessoa_fisica" disabled readonly name="tppessoa_empregador" value="1"/> <label style="margin-right: 25px" for="tppessoa_fisica">F&iacute;sica</label>
												<input type="radio" style="margin-right: 5px" <?=($tppessoa_empregador == "2" ? "checked" : "")?> id="tppessoa_juridica" disabled readonly name="tppessoa_empregador" value="2"/> <label for="tppessoa_juridica">Jur&iacute;dica</label>

												<br style="clear:both"/>

                                                <label style="margin-left: 15px;width:105px"><?=($tppessoa_empregador == "1" ? "CPF" : "CNPJ")?>:</label>
                                                <input value="<?=$nrcnpj_empregador?>" type="text" class="campoTelaSemBorda" readonly disabled style="margin-right: 5px;width:120px">

                                                <label style="margin-left: 15px;">Nome:</label>
                                                <input value="<?=$dsnome_empregador?>" type="text" class="campoTelaSemBorda" style="width:267px" readonly disabled>
                                            </fieldset>

                                            <fieldset style="margin-top:10px">
                                                <legend>Banco</legend>

                                                <?php if ($cddopcao == 'E') { ?>
                                                    <label style="margin-left: 15px;width: 105px;">Banco Folha:</label>                                                
                                                    <input value="<?=$banco?>" type="text" class="campoTelaSemBorda" style="width: 446px;" readonly disabled>

                                                    <br style="clear:both" />

                                                    <label style="margin-left: 15px;width: 105px;">ISPB:</label>
                                                    <input value="<?=$nrispb_banco_folha?>" type="text" class="campoTelaSemBorda" readonly disabled style="margin-right: 5px;width: 80px;">


                                                    <label style="margin-left: 15px;">CNPJ:</label>
                                                    <input value="<?=$nrcnpj_banco_folha?>" type="text" class="campoTelaSemBorda" style="width: 130px;" readonly disabled>
                                                <?php } else { ?>
                                                    <label style="margin-left: 15px;width: 105px;">Banco Destino:</label>                                                
                                                    <input value="<?=$banco?>" type="text" class="campoTelaSemBorda" style="width: 446px;" readonly disabled>

                                                    <br style="clear:both" />

                                                    <label style="margin-left: 15px;width: 105px;">Ag&ecirc;ncia:</label>
                                                    <input value="<?=$cdagencia_destinataria?>" type="text" class="campoTelaSemBorda" readonly disabled style="margin-right: 5px;width: 50px;">


                                                    <label style="margin-left: 15px;width: 288px;">Conta:</label>
                                                    <input value="<?=$nrdconta_destinataria?>" type="text" class="campoTelaSemBorda" style="width: 85px;" readonly disabled>
                                                <?php } ?>

                                            </fieldset>

                                            <fieldset style="margin-top:10px">
                                                <legend>Status da Solicita&ccedil;&atilde;o</legend>

                                                <label style="margin-left: 15px;width: 105px;">Situa&ccedil;&atilde;o:</label>
                                                <input value="<?=$situacao?>" type="text" class="campoTelaSemBorda" readonly disabled style="margin-right: 5px;width: 145px;">

                                                <?php if ($cddopcao != 'E') { ?>
                                                    <br style="clear:both" />                                                
                                                    
                                                    <label style="margin-left: 15px;width: 105px;">Data Avalia&ccedil;&atilde;o:</label>
                                                    <input value="<?=$dtavaliacao?>" style="width: 145px;" type="text" class="campoTelaSemBorda" readonly disabled>
                                                    
                                                    <label style="margin-left: 15px; width: 118px;">Data Retorno:</label>
                                                    <input value="<?=$dtretorno?>" type="text" style="width: 165px;" class="campoTelaSemBorda" readonly disabled>
                                                <?php } else { ?>
                                                    <label style="margin-left: 15px; width: 113px;">Data Retorno:</label>
                                                    <input value="<?=$dtretorno?>" type="text" style="width: 165px;" class="campoTelaSemBorda" readonly disabled>
                                                <?php } ?>

                                                <br style="clear:both" />

                                                <label style="margin-left: 15px;width: 105px;">Motivo(s):</label>
                                                <textarea class="campoTelaSemBorda" readonly disabled style="width: 447px;height: 60px;margin-right: 52px;"><?=utf8_decode($motivo);?></textarea>

                                            </fieldset>
											
											<?php
												/*
												*** Busca dados da contestação
												*/
												
												if($cddopcao == 'E') {
												
													$nrdconta = preg_replace("/[^0-9]/", "", $nrdconta);
													
													$xml  = "<Root>";
													$xml .= " <Dados>";
													$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
													$xml .= "   <nrsolicitacao>".$nrsolicitacao."</nrsolicitacao>";
													$xml .= " </Dados>";
													$xml .= "</Root>";
													
													$xmlResult = mensageria($xml, "ATENDA", "BUSCA_DADOS_CONTESTACAO_ENVIA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
													$xmlObject = getObjectXML($xmlResult);
													
													if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
														$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
														exibirErro('error',$msgErro,'Alerta - Aimaro','acessaOpcaoAba(2,0,"0")', false);
													}
													
													$contestacao = $xmlObject->roottag->tags[0];
													
													$dssituacao = getByTagName($contestacao->tags,'dssituacao');
													$identificador = getByTagName($contestacao->tags,'identificador');
													$dtsolicita = getByTagName($contestacao->tags,'dtsolicita');
													$dtretorno = getByTagName($contestacao->tags,'dtretorno');
													$dsmotivo = getByTagName($contestacao->tags,'dsmotivo');
													$dsretornno = getByTagName($contestacao->tags,'dsretorno');
											?>
											
											<fieldset style="margin-top:10px">
												<legend>Status da Contesta&ccedil;&atilde;o</legend>
												<label style="margin-left: 15px;width: 105px;" for="dssituacao" class="clsCampos">Situa&ccedil;&atilde;o:</label>
												<input style="margin-right: 5px;width: 145px;" type="text" id="dssituacao" name="dssituacao" disabled readonly="readonly" class="campoTelaSemBorda" value="<?php echo $dssituacao; ?>" />

												<label style="margin-left: 15px;width: 115px;" for="nr_identificador" class="clsCampos">Identificador:</label>
												<input style="margin-right: 5px;width: 165px;" type="text" id="nr_identificador" name="nr_identificador" readonly="readonly" class="campoTelaSemBorda" value="<?php echo $identificador; ?>" />
												
												<br style="clear:both"/>
												
												<label style="margin-left: 15px;width: 105px;" for="dtsolicita" class="clsCampos">Data Solicita&ccedil;&atilde;o:</label>
												<input style="margin-right: 5px;width: 145px;" type="text" id="dtsolicita" name="dtsolicita" readonly="readonly" class="campoTelaSemBorda" value="<?php echo $dtsolicita; ?>" />
												
												<label style="margin-left: 15px;width: 115px;" for="dtretorno" class="clsCampos">Data Retorno:</label>
												<input style="margin-right: 5px;width: 165px;" type="text" id="dtretorno" name="dtretorno" readonly="readonly" class="campoTelaSemBorda" value="<?php echo $dtretorno; ?>" />
												
												<br style="clear:both"/>
												
												<label style="margin-left: 15px;width: 104px;" for="dsmotivo" class="clsCampos">Motivo:</label>
												<textarea style="width: 448px;height: 60px;margin-right: 47px;" id="dsmotivo" class="campoTelaSemBorda" readonly disabled><?=$dsmotivo?></textarea>
												
												<label style="margin-left: 15px;width: 104px;margin-top:5px;" for="dsretornno" class="clsCampos">Retorno:</label>
												<textarea style="width: 448px;height: 60px;margin-right: 47px;margin-top:5px;" id="dsretornno" class="campoTelaSemBorda" readonly disabled><?=$dsretornno?></textarea>
											</fieldset>
											
											<?php
												}else if ($cddopcao == 'M' || $cddopcao == 'R'){
											?>
											
											<?php
												/*
												*** Busca dados da contestação
												*/
												
												$xml  = "<Root>";
												$xml .= " <Dados>";
												$xml .= "   <nrnuportabilidade>".$nusolicitacao."</nrnuportabilidade>";
												$xml .= " </Dados>";
												$xml .= "</Root>";
												
												$xmlResult = mensageria($xml, "ATENDA", "BUSCA_DADOS_CONTESTACAO_RECEBE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
												$xmlObject = getObjectXML($xmlResult);
												
												if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
													$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
													exibirErro('error',$msgErro,'Alerta - Aimaro','acessaOpcaoAba(2,0,"0")', false);
												}
												
												$contestacao = $xmlObject->roottag->tags[0];
												
												$dssituacao = getByTagName($contestacao->tags,'dssituacao');
												$identificador = getByTagName($contestacao->tags,'identificador');
												$dtsolicita = getByTagName($contestacao->tags,'dtsolicita');
												$dtretorno = getByTagName($contestacao->tags,'dtretorno');
												$dsmotivo = getByTagName($contestacao->tags,'dsmotivo');
												$dsretornno = getByTagName($contestacao->tags,'dsretorno');
												
											?>
											
											<fieldset style="margin-top:10px">
												<legend>Status da Contesta&ccedil;&atilde;o</legend>
												<label style="margin-left: 15px;width: 105px;" for="dssituacao" class="clsCampos">Situa&ccedil;&atilde;o:</label>
												<input style="margin-right: 5px;width: 145px;" type="text" id="dssituacao" name="dssituacao" disabled readonly="readonly" class="campoTelaSemBorda" value="<?php echo $dssituacao; ?>" />

												<label style="margin-left: 15px;width: 115px;" for="nr_identificador" class="clsCampos">Identificador:</label>
												<input style="margin-right: 5px;width: 165px;" type="text" id="nr_identificador" name="nr_identificador" readonly="readonly" class="campoTelaSemBorda" value="<?php echo $identificador; ?>" />
												
												<br style="clear:both"/>
												
												<label style="margin-left: 15px;width: 105px;" for="dtsolicita" class="clsCampos">Data Solicita&ccedil;&atilde;o:</label>
												<input style="margin-right: 5px;width: 145px;" type="text" id="dtsolicita" name="dtsolicita" readonly="readonly" class="campoTelaSemBorda" value="<?php echo $dtsolicita; ?>" />
												
												<label style="margin-left: 15px;width: 115px;" for="dtretorno" class="clsCampos">Data Retorno:</label>
												<input style="margin-right: 5px;width: 165px;" type="text" id="dtretorno" name="dtretorno" readonly="readonly" class="campoTelaSemBorda" value="<?php echo $dtretorno; ?>" />
												
												<br style="clear:both"/>
												
												<label style="margin-left: 15px;width: 104px;" for="dsmotivo" class="clsCampos">Motivo:</label>
												<textarea style="width: 448px;height: 60px;margin-right: 47px;" id="dsmotivo" class="campoTelaSemBorda" readonly disabled><?=$dsmotivo?></textarea>
												
												<label style="margin-left: 15px;width: 104px;margin-top: 5px;" for="dsretornno" class="clsCampos">Retorno:</label>
												<textarea style="width: 448px;height: 60px;margin-right: 47px;margin-top: 5px;" id="dsretornno" class="campoTelaSemBorda" readonly disabled><?=$dsretornno?></textarea>
											</fieldset>
											
											<?php
												}
												
												if ($cddopcao == 'M' || $cddopcao == 'R'){
													
													/*
													*** Busca dados da regularização
													*/
													
													$xml  = "<Root>";
													$xml .= " <Dados>";
													$xml .= "   <nrnu_portabilidade>".$nusolicitacao."</nrnu_portabilidade>";
													$xml .= " </Dados>";
													$xml .= "</Root>";
													
													$xmlResult = mensageria($xml, "ATENDA", "BUSCA_DADOS_REGULARIZACAO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
													$xmlObject = getObjectXML($xmlResult);
													
													if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO"){
														$msgErro = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;
														exibirErro('error',$msgErro,'Alerta - Aimaro','acessaOpcaoAba(2,0,"0")', false);
													}
													
													$regularizacao = $xmlObject->roottag->tags[0];
													
													$dssituacao = getByTagName($regularizacao->tags,'dssituacao');
													$dsmotivo = getByTagName($regularizacao->tags,'dsmotivo');
													$dtregularizacao = getByTagName($regularizacao->tags,'dtregularizacao');
											?>
											
											<fieldset style="margin-top:10px">
												<legend>Status da Regulariza&ccedil;&atilde;o</legend>
												<label style="margin-left: 15px;width: 105px;" for="dssituacao" class="clsCampos">Situa&ccedil;&atilde;o:</label>
												<input style="margin-right: 5px;width: 145px;" type="text" id="dssituacao" name="dssituacao" disabled readonly="readonly" class="campoTelaSemBorda" value="<?=$dssituacao?>" />

												<label style="margin-left: 15px;width: 160px;" for="dt_regularizacao" class="clsCampos">Data:</label>
												<input style="margin-right: 5px;width: 120px;" type="text" id="dt_regularizacao" name="dt_regularizacao" readonly="readonly" class="campoTelaSemBorda" value="<?=$dtregularizacao?>" />
												
												<label style="margin-left: 15px;width: 105px;" for="dsmotivo" class="clsCampos">Motivo:</label>
												<textarea style="width: 448px;height: 60px;margin-right: 48px;" id="dsmotivo" class="campoTelaSemBorda" readonly disabled style="width: 513px;height: 60px;margin-right: 19px;"><?=$dsmotivo?></textarea>
											</fieldset>
											
											<?php
												}
											?>
											
                                        </form>
                                    </div>
                                    <div style="margin-top:8px">
                                        <table>
                                            <tr>
                                                <td width="70px" align="center"> <a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divUsoGenerico')); return false;">Voltar</a></td>
                                            </tr>
                                        </table>
                                    </div>
                                    <br>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>