<?php 

	/************************************************************************
        Fonte: ocorrencias.php
    	Autor: Guilherme
	    Data : Fevereiro/2008                     Última Alterção: 29/10/2012

    	Objetivo  : Mostrar rotina de OCORRENCIAS da tela ATENDA

    	Alterações: 13/07/2011 - Alterado para layout padrão (Rogerius - DB1). 	
		
					29/10/2012 - Inclusão da opção "Grupo Economico" (Adriano)

	************************************************************************/
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	// Se par&acirc;metros necess&aacute;rios n&atilde;o foram informados
	if (!isset($_POST["nmdatela"]) || !isset($_POST["nmrotina"])) {
		echo 'hideMsgAguardo();';
		echo 'showError("error","Par&acirc;metros incorretos.","Alerta - Ayllos","");';
		exit();
	}	

	// Carrega permiss&otilde;es do operador
	include("../../../includes/carrega_permissoes.php");	
	
	setVarSession("opcoesTela",$opcoesTela);

?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table cellpadding="0" cellspacing="0" border="0" width="506">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">OCORR&Ecirc;NCIAS</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="encerraRotina(true);return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
									<table border="0" cellspacing="0" cellpadding="0">
										<tr>
           									<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold" onClick="acessaOpcaoAba(6,0,0);return false;">Principal</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>

                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq1"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen1"><a href="#" id="linkAba1" class="txtNormalBold" onClick="acessaOpcaoAba(6,1,1);return false;">Contra ordens</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir1"></td>
											<td width="1"></td>

                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq2"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen2"><a href="#" id="linkAba2" class="txtNormalBold" onClick="acessaOpcaoAba(6,2,2);return false;">Empr&eacute;stimos</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir2"></td>
											<td width="1"></td>

                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq3"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen3"><a href="#" id="linkAba3" class="txtNormalBold" onClick="acessaOpcaoAba(6,3,3);return false;">Preju&iacute;zos</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir3"></td>
											<td width="1"></td>

                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq4"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen4"><a href="#" id="linkAba4" class="txtNormalBold" onClick="acessaOpcaoAba(6,4,4);return false;">SPC</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir4"></td>
											<td width="1"></td>

                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq5"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen5"><a href="#" id="linkAba5" class="txtNormalBold" onClick="acessaOpcaoAba(6,5,5);return false;">Estouros</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir5"></td>
											<td width="1"></td>
											
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq5"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen5"><a href="#" id="linkAba5" class="txtNormalBold" onClick="acessaOpcaoAba(6,6,6);return false;">Grupo Economico</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir5"></td>
											<td width="1"></td>

                                        </tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudoOpcao" style="height:260px">&nbsp;</div>
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
// Mostra div da rotina
mostraRotina();

// Esconde mensagem de aguardo
hideMsgAguardo();

<?php
       echo "acessaOpcaoAba(1,0,0);";
?>
</script>	
