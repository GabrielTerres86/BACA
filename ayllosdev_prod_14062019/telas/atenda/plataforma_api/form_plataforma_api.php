<?php
/*!
* FONTE        : form_plataforma_api.php
* CRIAÇÃO      : André Clemer
* DATA CRIAÇÃO : Fevereiro/2019
* OBJETIVO     : Mostrar formulário do serviço da API.
* --------------
* ALTERAÇÕES   :
* --------------
*/
session_start();

// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
require_once("../../../includes/config.php");
require_once("../../../includes/funcoes.php");
require_once("../../../includes/controla_secao.php");

// Verifica se tela foi chamada pelo metodo POST
isPostMethod();

$cddopcao             = ((!empty($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C');
$cdproduto         	  = ((!empty($_POST['cdproduto'])) ? $_POST['cdproduto'] : '');
$convenio_ativo    	  = ((!empty($_POST['convenio_ativo'])) ? $_POST['convenio_ativo'] : 0);
$dtadesao          	  = $glbvars['dtmvtolt'];
$idsituacao_adesao 	  = $_POST['idsituacao_adesao'];
$servicosIds       	  = ((!empty($_POST['servicosIds'])) ? explode(',', $_POST['servicosIds']) : array());
$produtos_disponiveis = ((!empty($_POST['produtos_disponiveis'])) ? explode(',', $_POST['produtos_disponiveis']) : array());
$servicos_disponiveis = ((!empty($_POST['servicos_disponiveis'])) ? explode(',', $_POST['servicos_disponiveis']) : array());
$idservico_api        = ((!empty($_POST['idservico_api'])) ? $_POST['idservico_api'] : 0);
$idservico_api     	  = (($cddopcao == 'I') ? 0 : $idservico_api);

// Classe para leitura do xml de retorno
require_once("../../../class/xmlfile.php");

if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao,false)) <> "") {
    exit('hideMsgAguardo();showError("error","'.$msgError.'","Alerta - Aimaro","exibeRotina($(\'#divRotina\'));");');
}

?>
<style>
#divFinalidades div.divRegistros, #divDesenvolvedores div.divRegistros {
    height: auto;
    max-height: 150px;
}
</style>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
    <tr>
        <td align="center">		
            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                                <td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">PLATAFORMA APIs</td>
                                <td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico'));exibeRotina($('#divRotina'));controlaOperacao('P');return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
                                <td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
                            </tr>
                        </table>     
                    </td> 
                </tr>    
                <tr>
                    <td class="tdConteudoTela" align="center">	
                        <table width="100%"  border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td>
                                    <table border="background-color: #F4F3F0;" cellspacing="0" cellpadding="0" >
                                        <tr>
                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="8" height="21" id="imgAbaEsq0"></td>
                                            <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0" class="txtNormalBold"><? echo utf8ToHtml('Principal');?></td>
                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="8" height="21" id="imgAbaDir0"></td>
                                            <td width="1"></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                                    <form action="" method="post" name="frmInclusao" id="frmInclusao" class="formulario">
                                        <input type="hidden" id="cddesenvolvedor" name="cddesenvolvedor" value="" />
                                        <input type="hidden" id="nrdocumento" name="nrdocumento" value="" />
                                        <input type="hidden" id="dsempresa" name="dsempresa" value="" />
                                        <input type="hidden" id="nrtelefone" name="nrtelefone" value="" />
                                        <input type="hidden" id="dscontato" name="dscontato" value="" />
                                        <input type="hidden" id="dsemail" name="dsemail" value="" />
	
										<div id="divDados" class="clsCampos">
										
                                            <div id="divCabecalho">
                                                <fieldset style="padding: 5px">
                                                    <legend><? echo utf8ToHtml('Incluir Serviço API');?></legend>
                                                    
                                                    <label for="servico" class="clsCampos" style="width: 80px;"><? echo utf8ToHtml('Produto:');?></label>
                                                    <select id="servico" class="campo" name="servico" style="width: 420px;" onchange="onChangeServico();">
                                                    <?php
                                                    $xml = new XmlMensageria();
                                                    $xml->add('dsproduto','');
                                                    
                                                    $xmlResult = mensageria($xml, "TELA_CADAPI", "CONSULTA_PRODUTOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
                                                    $xmlObj = getObjectXML($xmlResult);
													
                                                    if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
                                                        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata | $xmlObj->roottag->tags[0]->cdata;
														exibirErro('error',$msgErro,'Alerta - Aimaro','',false);
                                                    }

                                                    $registros = $xmlObj->roottag->tags[0]->tags;
													
                                                    foreach ($registros as $r) {
                                                        $_cdproduto = getByTagName($r->tags,"cdproduto");
                                                        $_dsproduto = getByTagName($r->tags,"dsproduto");

                                                        if (!in_array($_cdproduto, $produtos_disponiveis) && $cddopcao == 'I') { continue; }
                                                    ?>
                                                    <option value="<?php echo $_cdproduto; ?>" <?php echo ( ($cdproduto == $_cdproduto) ? 'selected': '' ); ?>><?php echo $_cdproduto, ' - ', $_dsproduto; ?></option> 
                                                    <? } ?>
                                                    </select>

                                                    <label for="situacao" class="clsCampos" style="width: 100px;"><? echo utf8ToHtml('Situação:');?></label>
                                                    <select id="situacao" class="campo" name="situacao" style="width: 80px;">
                                                        <option value="1" <?php echo ( ($idsituacao_adesao || $idsituacao_adesao === '' || $cddopcao == "I") ? 'selected': '' ); ?>>Ativo</option>
														<option value="0" <?php echo ( (!$idsituacao_adesao && $cddopcao != "I") ? 'selected': '' ); ?>>Inativo</option>
                                                    </select>
                                                    
                                                    <br style="clear:both"/>
													
													<label for="servico_api" class="clsCampos" style="width: 80px"><? echo utf8ToHtml('Serviço API:');?></label>
                                                    <select id="servico_api" class="campo" name="servico_api" style="width: 420px;"></select>
                                                    <label for="dtadesao" class="clsCampos" style="width: 100px;"><? echo utf8ToHtml('Adesão:');?></label>
                                                    <input type="text" class="campo campoTelaSemBorda" id="dtadesao" name="dtadesao" style="width: 80px;" disabled readonly value="<? echo $dtadesao; ?>" />
                                                    
													<input type="hidden" name="convenio_ativo" id="convenio_ativo" value="<?php echo $convenio_ativo; ?>" />
													
                                                </fieldset>

                                                <div id="divBotoes" style="padding-top:0;<? echo (($cddopcao == 'C') ? 'display:none' : ''); ?>">
                                                    <input id="btContinuar" type="button" class="botao" value="Continuar" onclick="controlaLayout('FI');" />
                                                    <input id="btVoltar" type="button" class="botao" value="Voltar" onclick="fechaRotina($('#divUsoGenerico'));exibeRotina($('#divRotina'));controlaOperacao('P');return false;"/>
                                                </div>
                                            </div>

                                            <!-- grid_finalidades.php -->
                                            <div id="divFinalidades" style="display:none"></div>

                                            <!-- grid_desenvolvedores.php -->
                                            <div id="divDesenvolvedores" style="display:none"></div>
											
											<!-- tipo_autorizacao_form.php -->
                                            <div id="divTipoAutoriazacao" style="display:none"></div>
											
										</div>
									</form>

                                    <? if ($cddopcao != 'C') { ?>
									<div id="divBotoes" style="padding: 5px;display:none">	
										<a class="botao" id="btConfirmar" href="#" onclick="confirmaCredenciasAcesso(false)">Confirmar</a>
										<a class="botao" id="btVoltar" href="#" onclick="fechaRotina($('#divUsoGenerico'));exibeRotina($('#divRotina')); return false;">Voltar</a>
                                    </div>
                                    <? } ?>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
<?
	$registros = $xmlObj->roottag->tags[0];
	$count = 0;
	$array = array();
	foreach ($registros as $r) {

		foreach ($registros->tags[$count]->tags as $s){

			$_idservico = trim(getByTagName($s->tags,"idservico_api"));
			$_dsservico = utf8_encode(getByTagName($s->tags,"dsservico_api"));
			$_cdproduto = trim(getByTagName($s->tags,"cdproduto"));

			if (!$_idservico) { continue; }
			if (!in_array($_idservico, $servicos_disponiveis) && $cddopcao == 'I') { continue; }

			$array[$_cdproduto][count($array[$_cdproduto])] = array("idservico" => $_idservico, "dsservico" => $_dsservico);
		}
		$count++;
	} 
	$explode = json_encode($array);
?>
<script type="text/javascript">
	hideMsgAguardo();
	blockBackground(parseInt($("#divUsoGenerico").css("z-index")));
    layoutPadrao();
    <?php if ($cddopcao == 'C' || $cddopcao == 'A') { ?>
        controlaLayout('FI');
    <?php } else { ?>
        controlaLayout('F');
    <?php } ?>
	
	var jsonServicos = <? echo $explode; ?>;
	
	function onChangeServico(){
		var produtoSelecionado = $('#servico option:selected').val();
		
		$('#servico_api').html("");
		
		for(var i = 0;i < jsonServicos[produtoSelecionado].length;i++){
			$('#servico_api').append('<option value="'+jsonServicos[produtoSelecionado][i].idservico+'">'+jsonServicos[produtoSelecionado][i].dsservico+'</option>');
		}
		
		$('#servico_api option[value="<? echo $idservico_api; ?>"]').attr('selected', 'selected');
	}
	onChangeServico();
</script>