<?php
	/*!
	* FONTE        : form_cadastrar_desenvolvedor.php
	* CRIAÇÃO      : Andrey Formigari
	* DATA CRIAÇÃO : Abril/2019
	* OBJETIVO     : Mostrar rotina para Cadastrar Desenvolvedor.
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
                                <td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">CADASTRO DE DESENVOLVEDOR</td>
                                <td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divRotina'));exibeRotina($('#divPesquisa')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
                                            <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0" class="txtNormalBold">Dados</td>
                                            <td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="8" height="21" id="imgAbaDir0"></td>
                                            <td width="1"></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
                                    
									<form name="iframeCadastroDesenvolvedor" id="iframeCadastroDesenvolvedor" action="/telas/caddes/caddes_plataforma_api.php?keyrand=<?php echo mt_rand();?>" target="iframe-cadastro-desenvolvedor" method="post">
										<input type="hidden" name="cddopcao" value="I">
										<input type="hidden" name="redirect" value="script_ajax">
										<input type="hidden" name="sidlogin" value="<?=$_POST['sidlogin'];?>">
										<input type="hidden" name="isPlataformaAPI" value="1">
									</form>
									
									<iframe onload="$('#iframe-cadastro-desenvolvedor').contents().find('body').css('overflow', 'hidden');" name="iframe-cadastro-desenvolvedor" id="iframe-cadastro-desenvolvedor" src="" width="100%" height="380px" frameborder="0" />
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
	
	$('#iframeCadastroDesenvolvedor').attr('src', '/telas/caddes/caddes_plataforma_api.php?keyrand=<?php echo mt_rand();?>').submit();
</script>