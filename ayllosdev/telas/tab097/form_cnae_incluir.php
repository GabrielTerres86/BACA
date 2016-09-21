<?
/*!
 * FONTE        	: form_cnae_incluir.php
 * CRIAÇÃO      	: Jaison Fernando
 * DATA CRIAÇÃO 	: Novembro/2015
 * OBJETIVO     	: Form para a tela TAB097
 * ÚLTIMA ALTERAÇÃO : --/--/----
 * --------------
 * ALTERAÇÕES   	: 
 * --------------
 */ 
    session_start();

    // Includes para controle da session, variáveis globais de controle, e biblioteca de funções

    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');	
    require_once('../../class/xmlfile.php');

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'I',false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}
?>

<script type="text/javascript" src="../../includes/pesquisa/pesquisa.js"></script>

<script type="text/javascript">
    $('#cdcnae','#frmCNAE').css('width', '80px').addClass('inteiro');
    $('#dscnae','#frmCNAE').css('width', '345px').desabilitaCampo();
</script>

<table id="telaDetalhamento"cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="550">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Informe o CNAE</td>
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
                                        <form name="frmCNAE" id="frmCNAE" class="formulario" onsubmit="javascript:confirmaInclusao(); return false;">
                                            <table>
                                            <tr>
                                                <td>
                                                    <label for="cdcnae"><? echo utf8ToHtml('C&oacute;digo:') ?></label>
                                                    <input type="text" class="campo" name="cdcnae" id="cdcnae" />	
                                                    <a style="padding: 3px 0 0 3px;" href="#" onClick="mostraPesquisaCNAE();return false;"><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>				
                                                    <input type="text" class="campo" name="dscnae" id="dscnae" />
                                                </td>
                                            </tr>
                                            </table>
                                        </form>
                                        <div id="divBotoes">
                                            <a href="#" class="botao" id="btCNAEVoltar" onClick="fechaRotina($('#divRotina')); return false;">Voltar</a>
                                            <a href="#" class="botao" id="btCNAEIncluir" onClick="confirmaInclusao();">Incluir</a>
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