<?php
	/*!
	* FONTE        : form_credencias_acesso.php
	* CRIAÇÃO      : Andrey Formigari
	* DATA CRIAÇÃO : Fevereiro/2019
	* OBJETIVO     : Mostrar rotina para Cadastrar Credenciais.
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

	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	$cddopcao   = ( ( !empty($_POST['cddopcao']) )   ? $_POST['cddopcao']   : '' );

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '')
		exit('hideMsgAguardo();showError("error","'.$msgError.'","Alerta - Aimaro","exibeRotina($(\'#divRotina\'));");');
?>
<table cellpadding="0" cellspacing="0" border="0" width="400">
    <tr>
        <td align="center">		
            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
                                <td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">CREDENCIAIS DE ACESSO</td>
                                <td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico'));exibeRotina($('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
                                            <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0" class="txtNormalBold">Principal</td>
                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="8" height="21" id="imgAbaDir0"></td>
                                            <td width="1"></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                                    <form action="" method="post" name="frmCredenciasAcesso" id="frmCredenciasAcesso" class="formulario">
	
										<div id="divDados" class="clsCampos">
										
											<fieldset style="padding: 5px">
												<legend>Senha API</legend>
												
												<label for="nv_senha" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('Nova Senha:');?></label>
												<input type="password" class="campo" id="nv_senha" name="nv_senha" style="width: 150px;" maxlength="25" autocomplete="off" />
												
												<br style="clear:both"/>
												
												<label for="cf_senha" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('Confirma Senha:');?></label>
												<input type="password" class="campo" id="cf_senha" name="cf_senha" style="width: 150px;" maxlength="25" autocomplete="off" />
												
												<br style="clear:both"/>
												
												<div id="divForcaSenha">
													<label for="cf_senha" class="clsCampos" style="width: 145px;"><? echo utf8ToHtml('Força da Senha:');?></label>
													<span class="frc_pw"><span class="frc_pw" style="color: #FF0000;padding: 5px;float: left;font-weight: bold;">Senha Muito Fraca</span></span>
												</div>
												
											</fieldset>
										
										</div>
									</form>

									<div id="divBotoes" style="padding: 5px">	
										<a class="botao" id="btConfirmar" href="#" onclick="confirmaCredenciasAcesso(false)">Confirmar</a>
										<a class="botao" id="btVoltar" href="#" onclick="fechaRotina($('#divUsoGenerico'));exibeRotina($('#divRotina'));controlaOperacao('P');return false;">Voltar</a>
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
	// Esconde mensagem de aguardo
	hideMsgAguardo();

	// Bloqueia conteúdo que está átras do div da rotina
	blockBackground(parseInt($("#divUsoGenerico").css("z-index")));
	
	$('#nv_senha', '#frmCredenciasAcesso').focus();
	
    $('#nv_senha', '#frmCredenciasAcesso').unbind('keyup').bind('keyup', function() {
        var value = $(this).val().trim();
		
		if (value.length < 10 && value.length != 0) return;
		
		var vr_idmaiusc, vr_dscrtasc, vr_idnumber, vr_idminusc, vr_idsimbol, vr_dscritic, vr_qtpontos = 0, vr_cssstyle;
		
		for (var vr_index = 0; vr_index < value.length;vr_index++){
	
			vr_dscrtasc = value.substr(vr_index, 1).charCodeAt(0);
	
			// Verifica se é caracter Maiúsculo
			if (vr_dscrtasc >= 65 && vr_dscrtasc <= 90){
				vr_idmaiusc = true;
				continue;
			}
	
			// Verifica se é caracter Minúsculo
			if (vr_dscrtasc >= 97 && vr_dscrtasc <= 122){
				vr_idminusc = true;
				continue;
			}
	
			// Verifica se é caracter Numérico
			if (vr_dscrtasc >= 48 && vr_dscrtasc <= 57){
				vr_idnumber = true;
				continue;
			}
	
			// Verificar se o caracter é um Símbolo esperado
			if ((vr_dscrtasc >= 32 && vr_dscrtasc <= 47) ||  //  !"#$%&'()*+,-./
				(vr_dscrtasc >= 58 && vr_dscrtasc <= 64) ||  // :;<=>?@
				(vr_dscrtasc >= 91 && vr_dscrtasc <= 96) ||  // [\]^_`
				(vr_dscrtasc >= 123 && vr_dscrtasc <= 126)){ //-- {|}~
				vr_idsimbol = true;
				continue;
			}
		}

		// VERIFICAR PONTUAÇÃO DA SENHA 
		// MAIÚSCULAS
		if (vr_idmaiusc){
			vr_qtpontos = vr_qtpontos + 1;
		}
		// MINÚSCULAS
		if (vr_idminusc){
			vr_qtpontos = vr_qtpontos + 1;
		}
		// NUMÉRICAS
		if (vr_idnumber){
			vr_qtpontos = vr_qtpontos + 1;
		};
		// SIMBOLOS
		if (vr_idsimbol){
			vr_qtpontos = vr_qtpontos + 1;
		}
		
		switch (vr_qtpontos){
			case 1:
				vr_dscritic = 'Senha Fraca';
				vr_cssstyle = "color: #FF0000;";
				break;
			case 2:
				vr_dscritic = '<? echo utf8ToHtml('Senha Média');?>';
				vr_cssstyle = "color: #FFBC00;";
				break;
			case 3:
				vr_dscritic = 'Senha Forte';
				vr_cssstyle = "color: #06A24C;";
				break;
			case 4:
				vr_dscritic = 'Senha Muito Forte';
				vr_cssstyle = "color: #009C1A;";
				break;
			default:
				vr_dscritic = 'Senha Muito Fraca';
				vr_cssstyle = "color: #FF0000;";
		}

		vr_cssstyle += 'padding: 5px;float: left;font-weight: bold;';

		//$('#divForcaSenha', '#frmCredenciasAcesso').show();
		$('.frc_pw', '#frmCredenciasAcesso').attr('style', vr_cssstyle).html(vr_dscritic);
    });
</script>