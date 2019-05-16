<?php
/*!
 * FONTE        : detalhar_desenvolvedor.php
 * CRIAÇÃO      : Andrey Formigari - Supero
 * DATA CRIAÇÃO : 05/03/2019
 * OBJETIVO     : Rotina para buscar informações do desenvolvedor
 * --------------
 * ALTERAÇÕES   : 
 * -------------- 
 */

session_start();
require_once('../../../includes/config.php');
require_once('../../../includes/funcoes.php');
require_once('../../../includes/controla_secao.php');
require_once('../../../class/xmlfile.php');
isPostMethod();

// Recebe a operação que está sendo realizada
$cddesen = (!empty($_POST['cddesen'])) ? $_POST['cddesen'] : '';

if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A',false)) <> '') {
	exibirErro('error',$msgError,'Alerta - Aimaro','fechaRotina($(\'#divRotina\'));exibeRotina($(\'#divUsoGenerico\'));$(\'#divRotina\').removeClass(\'detailDesen\');',false);
}

$cddesenvolvedor = ((isset($_POST['cddesen'])) ? $_POST['cddesen'] : 0);

$xml = "<Root>";
$xml .= " <Dados>";
$xml .= "   <cddesenvolvedor>".$cddesenvolvedor."</cddesenvolvedor>";
$xml .= " </Dados>";
$xml .= "</Root>";

$xmlResult = mensageria($xml, "CADDES", "CONSULTA_DESENVOLVEDOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObj = getObjectXML($xmlResult);

if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
    $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    if ($msgErro == "") {
        $msgErro = $xmlObj->roottag->tags[0]->cdata;
    }
    if ($cddesenvolvedor) exibirErro('error',utf8_encode(str_replace('"', "'", $msgErro)),'Alerta - Aimaro','$(\'#cddesen\').val(\'\').focus();',false);
}

$desenvolvedor = $xmlObj->roottag->tags[0]->tags[0];

$cddesenvolvedor = getByTagName($desenvolvedor->tags, "cddesenvolvedor");
$inpessoa = getByTagName($desenvolvedor->tags, "inpessoa");
$nrdocumento = getByTagName($desenvolvedor->tags, "nrdocumento");
$dsnome = getByTagName($desenvolvedor->tags, "dsnome");
$nrcep_endereco = getByTagName($desenvolvedor->tags, "nrcep_endereco");
$dsendereco = getByTagName($desenvolvedor->tags, "dsendereco");
$nrendereco = getByTagName($desenvolvedor->tags, "nrendereco");
$dscomplemento = getByTagName($desenvolvedor->tags, "dscomplemento");
$dsbairro = getByTagName($desenvolvedor->tags, "dsbairro");
$dscidade = getByTagName($desenvolvedor->tags, "dscidade");
$dsunidade_federacao = getByTagName($desenvolvedor->tags, "dsunidade_federacao");
$dsemail = getByTagName($desenvolvedor->tags, "dsemail");
$nrddd_celular = getByTagName($desenvolvedor->tags, "nrddd_celular");
$nrtelefone_celular = getByTagName($desenvolvedor->tags, "nrtelefone_celular");
$dscontato_celular = getByTagName($desenvolvedor->tags, "dscontato_celular");
$nrddd_comercial = getByTagName($desenvolvedor->tags, "nrddd_comercial");
$nrtelefone_comercial = getByTagName($desenvolvedor->tags, "nrtelefone_comercial");
$dscontato_comercial = getByTagName($desenvolvedor->tags, "dscontato_comercial");
$dsfrase = getByTagName($desenvolvedor->tags, "dsfrase_desenvolvedor");
$dsusuario_portal = getByTagName($desenvolvedor->tags, "dsusuario_portal");
$dschave = getByTagName($desenvolvedor->tags, "dschave");
?>
<table cellpadding="0" cellspacing="0" border="0" width="700">
    <tr>
        <td align="center">		
            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                                <td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('INFORMAÇÕES DO DESENVOLVEDOR');?></td>
                                <td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divRotina'));exibeRotina($('#divUsoGenerico'));$('#divRotina').removeClass('detailDesen');return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
                                <td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
                            </tr>
                        </table>     
                    </td> 
                </tr>    
                <tr>
                    <td class="tdConteudoTela" align="center">	
                        <table width="100%"  border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td style="border: 1px solid #F4F3F0;">
                                    <table border="background-color: #F4F3F0;" cellspacing="0" cellpadding="0" >
                                        <tr>
                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="8" height="21" id="imgAbaEsq0"></td>
                                            <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0" class="txtNormalBold"><? echo utf8ToHtml('Desenvolvedor');?></td>
                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="8" height="21" id="imgAbaDir0"></td>
                                            <td width="1"></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                                    <form method="post" name="frmCadastroDesenvolvedor" id="frmCadastroDesenvolvedor" class="formulario">
										<div id="divDados" class="clsCampos">
										
											<fieldset style="padding: 5px">
												<legend><? echo utf8ToHtml('Informações do Desenvolvedor');?></legend>
												
												<label for="cddesen" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('Código:');?></label>
												<input type="text" class="campo inteiro" id="cddesen" name="cddesen" style="width: 75px;" value="<?=$cddesenvolvedor?>" onkeydown="onKeyDownBuscaDesenvolvedor(event);" />
												
												<br style="clear:both"/>
												
												<label for="inpessoa" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('Tipo de Pessoa:');?></label>
												<input type="radio" class="radio" id="inpessoa_f" name="inpessoa" value="1"<?=(($inpessoa==1)?' checked':'')?> /> <label for="inpessoa_f" style="margin-right: 10px;font-weight: 100;margin: 1px 8px 0 0;"><? echo utf8ToHtml('Física');?></label>
												<input type="radio" class="radio" id="inpessoa_j" name="inpessoa" value="2"<?=(($inpessoa==2)?' checked':'')?> /> <label for="inpessoa_j" style="font-weight: 100;margin: 1px 0 0 1px;"><? echo utf8ToHtml('Jurídica');?></label>
												
												<br style="clear:both"/>
												
												<label for="cpf_cnpj" class="clsCampos" style="width: 145px;"><?=(($inpessoa==2)?'CNPJ':(($inpessoa==1)?'CPF':'CPF/CNPJ'))?>:</label>
												<input type="text" onfocusout="$(this).removeClass('campoFocusIn');" class="campo<?=(($inpessoa==1)?' cpf': (($inpessoa==2)?' cnpj':''))?>" id="cpf_cnpj" name="cpf_cnpj" style="width: 135px;" value="<?=$nrdocumento?>" />
												
												<br style="clear:both"/>
												
												<label for="dsempresa" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('Empresa:');?></label>
												<input type="text" class="campo" id="dsempresa" name="dsempresa" style="width: 446px;" value="<?=$dsnome?>" maxlength="100" />
												
												<br style="clear:both"/>
												
												<label for="nrcep" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('CEP:');?></label>
												<input type="text" class="cep pesquisa campo" id="nrcep" name="nrcep" style="width: 100px;" value="<?=((!$nrcep_endereco) ? '' : formataCep($nrcep_endereco))?>" />
												
												<br style="clear:both"/>
												
												<label for="dsendereco" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('Endereço:');?></label>
												<input type="text" class="campo" id="dsendereco" name="dsendereco" style="width: 337px;" value="<?=$dsendereco?>" maxlength="50" />
												
												<label for="nrendereco" class="clsCampos" style="width: 45px;"><? echo utf8ToHtml('N°:');?></label>
												<input type="text" class="campo inteiro" id="nrendereco" name="nrendereco" style="width: 60px;" value="<?=$nrendereco?>" maxlength="10" />
												
												<br style="clear:both"/>
												
												<label for="dscomplemento" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('Complemento:');?></label>
												<input type="text" class="campo" id="dscomplemento" name="dscomplemento" style="width: 337px;" value="<?=$dscomplemento?>" maxlength="50" />
												
												<label for="dsuf" class="clsCampos" style="width: 45px;"><? echo utf8ToHtml('UF:');?></label>
												<? echo selectEstado('dsuf', $dsunidade_federacao, 1) ?>
												
												<br style="clear:both"/>
												
												<label for="dscidade" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('Cidade:');?></label>
												<input type="text" class="campo" id="dscidade" name="dscidade" style="width: 189px;" value="<?=$dscidade?>" maxlength="50" />
												
												<label for="dsbairro" class="clsCampos" style="width: 65px;"><? echo utf8ToHtml('Bairro:');?></label>
												<input type="text" class="campo" id="dsbairro" name="dsbairro" style="width: 189px;" value="<?=$dsbairro?>" maxlength="40" />
												
												<br style="clear:both"/>
												
												<label for="dsemail" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('E-mail:');?></label>
												<input type="text" class="campo" id="dsemail" name="dsemail" style="width: 446px;" value="<?=$dsemail?>" maxlength="100" />
												
												<br style="clear:both"/>
												
												<label for="nrddd_celular" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('Telefone Celular:');?></label>
												<input type="text" class="campo inteiro" id="nrddd_celular" name="nrddd_celular" style="width: 30px;" maxlength="2" value="<?=$nrddd_celular?>" />
												<input type="text" class="campo inteiro" id="nrtelcelular" name="nrtelcelular" style="width: 120px;" maxlength="10" value="<?=$nrtelefone_celular?>" />
												
												<label for="dscontatocel" class="clsCampos" style="width: 70px;"><? echo utf8ToHtml('Contato:');?></label>
												<input type="text" class="campo" id="dscontatocel" name="dscontatocel" style="width: 220px;" value="<?=$dscontato_celular?>" maxlength="30" />
												
												<br style="clear:both"/>
												
												<label for="nrddd_comercial" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('Telefone Comercial:');?></label>
												<input type="text" class="campo inteiro" id="nrddd_comercial" name="nrddd_comercial" style="width: 30px;" maxlength="2" value="<?=$nrddd_comercial?>" />
												<input type="text" class="campo inteiro" id="nrtelcomercial" name="nrtelcomercial" style="width: 120px;" maxlength="10" value="<?=$nrtelefone_comercial?>" />
												
												<label for="dscontatocom" class="clsCampos" style="width: 70px;"><? echo utf8ToHtml('Contato:');?></label>
												<input type="text" class="campo" id="dscontatocom" name="dscontatocom" style="width: 220px;" value="<?=$dscontato_comercial?>" maxlength="30" />
											</fieldset>
										
										</div>
									</form>

									<div id="divBotoes" style="padding: 5px">	
										<a class="botao" id="btVoltar" href="#" onclick="fechaRotina($('#divRotina'));exibeRotina($('#divUsoGenerico'));$('#divRotina').removeClass('detailDesen');return false;">Voltar</a>
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
<script>
	$('input, select', '#frmCadastroDesenvolvedor').attr('disabled', 'disabled').addClass('campoTelaSemBorda');
	$('#inpessoa_f, #inpessoa_j', '#frmCadastroDesenvolvedor').removeClass('campoTelaSemBorda');
</script>