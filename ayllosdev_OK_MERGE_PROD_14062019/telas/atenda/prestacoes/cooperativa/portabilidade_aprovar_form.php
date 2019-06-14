<?php
/*!
 * FONTE        : portabilidade_aprovar_form.php
 * CRIAÇÃO      : Jaison (CECRED)
 * DATA CRIAÇÃO : 28/05/2015
 * OBJETIVO     : Mostra a tela com o campo de numero da portabilidade
 * ALTERACOES   : 
 */	
	
session_start();
require_once('../../../../includes/config.php');
require_once('../../../../includes/funcoes.php');
require_once('../../../../includes/controla_secao.php');
require_once('../../../../class/xmlfile.php');
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
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Aprovar Portabilidade</td>
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
                                        <form name="frmPortAprv" id="frmPortAprv" class="formulario" onsubmit="javascript:aprovarPortabilidade(); return false;">
                                            <table>
                                            <tr>
                                                <td><? echo utf8ToHtml('Numero Portabilidade') ?>:</td>
                                                <td><input name="nrunico_portabilidade" id="nrunico_portabilidade" value="" /></td>
                                            </tr>
                                            </table>
                                        </form>
                                        <div id="divBotoes">
                                            <a href="#" class="botao" id="btPortAprovar" onClick="controlaOperacao('PORTAB_CRED');">Voltar</a>
                                            <a href="#" class="botao" id="btPortExtrato" onClick="aprovarPortabilidade();">Confirmar</a>
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
// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>