<?php

/*
 * FONTE        : controleQualificacao.php
 * CRI«√O       : Diego Simas (AMcom)
 * DATA CRIA«√O : 17/01/2018
 * OBJETIVO     : Mostra a tela com par‚metros para controle da QualificaÁ„o da OperaÁ„o
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
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">QualificaÁ„o - Controle</td>
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

                                        <form name="frmNovaProp" id="frmNovaProp" class="formulario condensado">	

	                                        <input id="nrctremp" name="nrctremp" type="hidden" value="" />
	
	                                        <fieldset>
		                                        <legend><? echo utf8ToHtml('Alterar Qualifica&ccedil;&atilde;o da Opera&ccedil;&atilde;o') ?></legend>
                                                
                                                <label for="idquapro" style="width:180px">Qualifica&ccedil;&atilde;o Op.:</label>
                                                <input name="idquapro" id="idquapro" style="width:30px" type="text" value="" />
                                                <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
                                                <input name="dsquaprc" id="dsquaprc" style="width:90px" type="text" value="" />
                                                <br/>
                                                
                                                <label for="idquaprc" style="width:180px">Qualifica&ccedil;&atilde;o Op. Contr.:</label>
                                                <input name="idquaprc" id="idquaprc" style="width:30px" type="text" value="" />
                                                <a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif"></a>
                                                <input name="dsquaprc" id="dsquaprc" style="width:90px" type="text" value="" />
                                                <br/>
                                            </fieldset>
                                            <div id="divBotoes">
                                                <a href="#" class="botao" style="width:58px;" id="btAlterar" onClick="controlaOperacao('PORTAB_APRV');">Alterar</a>
                                                <a href="#" class="botao" style="width:65px;" id="btCancelar" onClick="controlaOperacao('PORTAB_EXTR');">Cancelar</a>                                                
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
<form name="frmImprimir" id="frmImprimir" style="display:none;">
    <input name="sidlogin" id="sidlogin" type="hidden"  />
	<input name="nmarquiv" id="nmarquiv" type="hidden"  />
	<input name="nrdconta" id="nrdconta" type="hidden"  />
	<input name="nrctremp" id="nrctremp" type="hidden"  />
</form>
<script type="text/javascript">
// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte√∫do que est√° √°tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>