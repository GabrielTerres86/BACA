//SIMAS

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
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Portabilidade</td>
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

                                        <div id="divBotoes">
                                            <a href="#" class="botao" id="btPortAprovar" onClick="controlaOperacao('PORTAB_APRV');">Aprovar Portabilidade</a>
                                            <a href="#" class="botao" id="btPortExtrato" onClick="controlaOperacao('PORTAB_EXTR');">Imprimir Extrato</a>
                                            <a href="#" class="botao" id="btndossie" onClick="dossieDigdoc(6);return false;">Dossi&ecirc; DigiDOC</a>
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
// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conte√∫do que est√° √°tras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>