<? 
/*!
 * FONTE        : autorizar_resgate.php
 * CRIAÇÃO      : Mateus Zimmermann (Mouts)
 * DATA CRIAÇÃO : 07/12/2017
 * OBJETIVO     : Formulario que apresenta as formas de autorizacao
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');	
require_once('../../class/xmlfile.php');
isPostMethod();

?>

<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Autorizar Resgate</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a onclick="fechaRotina(divRotina);"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center">	
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divAutorizar">	
										<form name="frmAutorizar" id="frmAutorizar" class="formulario">
											<input name="flgautoriza" id="flgAutorizaSenha" type="radio" onchange="alteraOpcaoAutorizar()" class="radio" value="senha" />
											<label for="flgAutorizaSenha" class="radio">Solicitar senha do cooperado</label>

											<div id="divAutSenha">
												<label for="dssencar">Senha:</label>
												<input type="password" id="dssencar" name="dssencar" />
											</div>

											<div id="divAutIB">
												<input name="flgautoriza" id="flgAutorizaIB" type="radio" onchange="alteraOpcaoAutorizar()" class="radio" value="ib" />
												<label for="flgAutorizaIB" class="radio"><? echo utf8ToHtml('Aprovação via Internet Banking') ?></label>
											</div>

											<input name="flgautoriza" id="flgAutorizaComprovante" type="radio" onchange="alteraOpcaoAutorizar()" class="radio" value="comprovante" />
											<label for="flgAutorizaComprovante" class="radio"><? echo utf8ToHtml('Imprimir autorização') ?></label>

											<div id="divNomeDoc">
												<label for="nomeresg">Nome:</label>
												<input type="text" id="nomeresg" name="nomeresg" />
												<label for="docuresg">CPF:</label>
												<input type="text" id="docuresg" name="docuresg" />
											</div>

											<br />
										</form>
										<div id="divBotoes" style="padding-bottom:10px">
											<a href="#" class="botao" id="btVoltar" onclick="fechaRotina(divRotina); return false;">Voltar</a>
											<a href="#" class="botao" id="btProsseguirAutorizacao" onclick="prosseguirAutorizacao(); return false;" >Prosseguir</a>
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