<?php
/*
Autor: Bruno Luiz Katzjarowski - Mout's
Data: 10/11/2018;
Ultima alteração:

Alterações:
*/
?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
    <tr>
        <td align="center">		
            <table border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                    <td>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td width="11">
                                    <img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21">
                                </td>
                                <td id="<?php echo $labelRot; ?>" class="txtBrancoBold ponteiroDrag SetFoco" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">
                                    LOGSPB
                                </td>
                                <td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">
                                    <a href="#" onClick="fechaRotina($('#divRotina')); return false;">
                                        <img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0">
                                    </a>
                                </td>
                                <td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
                            </tr>
                        </table>     
                    </td> 
                </tr>    
                <tr>
                    <td class="tdConteudoTela" align="center">	
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td>
                                    <table border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td>
                                                <img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0">
                                                </td>
                                            <td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0">
                                                <a href="#" id="linkAba0" class="txtNormalBold">Detalhes da Mensagem</a>
                                            </td>

                                            <td>
                                                <img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0">
                                            </td>
                                            <td width="1"></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px; width:950px; ">
                                    <div id="divConteudoOpcao">
                                        <?php 
                                            include('detalhes_consulta_cm.php');
                                            include('detalhes_consulta_s.php');
                                            include('envio_relatorio_email.php');
                                        ?>

                                        <div class="Botoes botoesLogspb" id='divBotoesModal'>
                                            <div id="divBotaoOk">
                                                <a href="#" class="botao" id="btFechaConsulta">Voltar</a>
                                                <a href="#" class="botao" id="btEnviarEmail" style='display: none;'>Enviar</a>
                                            </div>
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