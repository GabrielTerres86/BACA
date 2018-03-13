<?php

    //************************************************************************//
    //*** Fonte: login_sistemas.php                                        ***//
    //*** Autor: David                                                     ***//
    //*** Data : Agosto/2007                  Última Alteração: 15/01/2018 ***//
    //***                                                                  ***//
    //*** Objetivo  : Efetuar login nos sistemas da Cecred (Ayllos e       ***//
    //***             Relacionamento).                                     ***//
    //***                                                                  ***//
    //*** Alterações: 21/02/2011 - Alterar acesso ao ambiente de producao  ***//
    //***                          X desenvolvimento (David)               ***//
    //***                                                                  ***//
    //***             08/08/2011 - Alterar chamada do progrid              ***//
    //***                                                                  ***//
    //***             03/08/2015 - Alterar acesso ao ambiente do pkgdesen  ***//
    //***                          (James)                                 ***//
    //***                                                                  ***//
    //***             30/07/2015 - NOVO PORTAL - Removida validação de     ***//
    //***                          Expiração de Senha baseada no           ***//
    //***                          mtccshadowlastchange (Guilherme/SUPERO) ***//
    //***                                                                  ***//
    //***             25/11/2016 - Gravar log de acesso quando o ambiente  ***//
    //***                          for "LIBERA" (Guilherme/SUPERO)         ***//
    //***                                                                  ***//
    //***             31/01/2017 - Alterado para gravar o log em tabela    ***//
    //***                          (Guilherme/SUPERO)                      ***//
    //***                                                                  ***//
    //***             15/01/2018 - #787877 Login LDAP alterado da intranet ***//
    //***                          para o ayllos (Carlos)                  ***//
    //************************************************************************//

    session_start();

    require_once("includes/ldap/config.php");
    require_once("includes/ldap/funcoes.php");
    require_once("Connections/ldapAD_AyllosWEB.php");
    require_once("includes/ldap/ldapAD_funcoes.php");
    require_once("class/protect.php");

    $DES_LOGIN  = "";

    //function grava_log($msg_log) {
    function grava_log($tip_trans,$origem,$des_trans,$flg_erro) {
/*
TIP_TRANSACAO       varchar(15)     -- Tipo de Mensagem - Chave de Acesso
DAT_TRANSACAO       date            -- Data da Transacao
HOR_TRANSACAO       time            -- Hora da Transacao
SEQ_TRANSACAO       int(10)         -- Sequencial da Transacao, conforme TIP_TRANSACAO e DAT_TRANSACAO
DES_ORIGEM          varchar(50)     -- Origem da Transacao
DES_TRANSACAO       varchar(200)    -- Descrição da Transacao
FLG_ERR_TRANSACAO   tinyint(1)      -- Indicar se o log é de erro ou nao

ix_1 [TIP_TRANSACAO]
ix_2 [TIP_TRANSACAO,DAT_TRANSACAO,SEQ_TRANSACAO]
ix_1 [DAT_TRANSACAO]
*/
        global $intranet;

        $TIP_TRANSACAO      = $tip_trans;
        $DAT_TRANSACAO      = date('Y-m-d');
        $HOR_TRANSACAO      = date('G:i:s');
        $DES_ORIGEM         = $origem;
        $DES_TRANSACAO      = $des_trans;
        $FLG_ERR_TRANSACAO  = $flg_erro;

        $NRSEQTRANS = 1;
        $SQL = "SELECT IFNULL(MAX(SEQ_TRANSACAO),0) NRSEQTRANS FROM log_transacao WHERE TIP_TRANSACAO='$TIP_TRANSACAO' AND DAT_TRANSACAO='$DAT_TRANSACAO'";
        $rsNextSeq = $intranet->Execute($SQL) or die($intranet->ErrorMsg());
        if ( isset($rsNextSeq) && !$rsNextSeq->EOF ) {
            $NRSEQTRANS = $rsNextSeq->Fields('NRSEQTRANS') + 1;
        }

        $SEQ_TRANSACAO      = $NRSEQTRANS;

        $SQL = "INSERT INTO log_transacao (
                  TIP_TRANSACAO
                 ,DAT_TRANSACAO
                 ,HOR_TRANSACAO
                 ,SEQ_TRANSACAO
                 ,DES_ORIGEM
                 ,DES_TRANSACAO
                 ,FLG_ERR_TRANSACAO
                )
                VALUES(
                  '$TIP_TRANSACAO'
                 ,'$DAT_TRANSACAO'
                 ,'$HOR_TRANSACAO'
                 ,'$SEQ_TRANSACAO'
                 ,'$DES_ORIGEM'
                 ,'$DES_TRANSACAO'
                 ,'$FLG_ERR_TRANSACAO'
                )";
        $intranet->Execute($SQL) or die('<br/>Erro na Inclusao do LOG: ' . $SQL.'<br/>Erro: ' . $intranet->ErrorMsg());

/*      $log_file = '/var/www/intranet/logs/Acesso_Libera.log';

        $log_handle = fopen($log_file, 'a');
        fwrite($log_handle , "\r\n" . '['.date('Y-m-d G:i:s') . '] [' . $_SERVER['REMOTE_ADDR'] .'] - ' . $msg_log);
        fclose($log_handle);
*/
    }

    
    // Verificar se foi enviado alguma crítica
    if (isset($_POST["dsmsgerr"]) && trim($_POST["dsmsgerr"]) <> "") {
        $msgErro = $_POST["dsmsgerr"];
    }

    $subdominio = substr($_SERVER["SERVER_NAME"],0,strpos($_SERVER["SERVER_NAME"],"."));

    if (isset($_POST["DES_LOGIN"])) {
        // Validar variáveis enviadas pelo método POST
        $obProtect = new AntiInjection();

        $obProtect->isHTTP_REFERER(false);

        $obProtect->addParam("DES_LOGIN",1,0,30);
        $obProtect->addParam("DES_SENHA",1,0,30);
        $obProtect->addParam("IND_SISTEMA",1,0,1);
        $obProtect->addParam("id_ambiente",1,0,1);

        $obProtect->doProteger($_POST);

        $DES_LOGIN   = $_POST["DES_LOGIN"];
        $DES_SENHA   = $_POST["DES_SENHA"];
        $IND_SISTEMA = $_POST["IND_SISTEMA"];
        $id_ambiente = $_POST["id_ambiente"];

        // Obtem dados do usuário que estão armazenados no LDAP
        $mtccshadowflag = 1;

        $atributos = @ldapAD_getUsuario($dsAD,$DES_LOGIN);

        $mtccshadowflag       = $atributos[0]["mtccshadowflag"][0];
        $accountexpires       = $atributos[0]['accountexpires'][0];
        $mtccshadowlastchange = $atributos[0]["mtccshadowlastchange"][0];
        $mtccdiaacesso        = $atributos[0]["mtccdiaacesso"][0];
        $mtcchoraacesso       = $atributos[0]["mtcchoraacesso"][0];
        $gidnumber            = $atributos[0]["gidnumber"][0];
        $mtccsistema          = $atributos[0]["mtccsistema"][0];
        $mtccserver           = $atributos[0]["mtccserver"];
        $mtccacessoexporadico = $atributos[0]["mtccacessoexporadico"][0]; // Formato YYYYMMDDHHIIHHII

        if ($mtccshadowflag == 1) { // Usuário Bloqueado
            $msgErro = "Usuário não habilitado.";
        } elseif ($IND_SISTEMA == "1" && $mtccsistema <> "1" && $mtccsistema <> "3" && $mtccsistema <> "5" && $mtccsistema <> "7") { // Sem permissão para acesso ao Ayllos
            $msgErro = "Sem permissão para acesso ao Ayllos.";
        } elseif ($accountexpires>1 && ldap_date_diferenca(date("Y-m-d"), date('Y-m-d',time_AD2Unix($accountexpires)-1)) < 0) { //Verifica se a conta do usuário não expirou
          $msgErro = "O usuário expirou.";
        } elseif (!ldapAD_login($dsAD, $DES_LOGIN, $DES_SENHA)) {
            $msgErro = "Senha Inválida.";
        } else {
            // NOVO PORTAL - Removida validação de Expiração de Senha
            //$dias = ldap_date_diferenca(date("Y-m-d"),ldad_dia_data($mtccshadowlastchange));
            $dias = 999;  // NOVO PORTAL - Alterado número de dias para não expirar a senha

            if ($dias < 0) {
                $msgErro = "A senha expirou.";
            } else {
                if (date("Ymd") != substr($mtccacessoexporadico,0,8) || date("Hi") < substr($mtccacessoexporadico,8,4) || date("Hi") > substr($mtccacessoexporadico,12,4)) {
                    if ((strpos($mtccdiaacesso,date("w")) === false)) {
                        $msgErro = "Você não tem permissão para acessar a intranet ".getDiaSemana(date("d/m/Y"));
                    } elseif (date("Hi") < substr($mtcchoraacesso,0,4) || date("Hi") > substr($mtcchoraacesso,5,4)) { // Validacao horario de acesso
                        $msgErro = "Você não tem permissão para acessar a intranet neste horário - ".date("H:i");
                    }
                }

                if (!isset($msgErro)) {
                    $COD_COOPER = intval(substr($DES_LOGIN,1,3));
                    $subdominio = substr($_SERVER["SERVER_NAME"],0,strpos($_SERVER["SERVER_NAME"],"."));

                    switch ($IND_SISTEMA) {
                        case 1: {
                            if ($subdominio == "ayllos") {
                                $urlLogin = 'https://'.$subdominio.'.cecred.coop.br/';
                            } elseif ($subdominio == "ayllosdev2" || $subdominio == "ayllosdev3") {
                                $urlLogin = 'http://'.$subdominio.'.cecred.coop.br/';
                            } else {
                                if ($id_ambiente == 1) {
                                    $urlLogin =  'http://'.$DES_LOGIN.'.ayllosdev.cecred.coop.br/';
                                }else{
                                    $urlLogin =  "http://ayllosdev2.cecred.coop.br/";
                                }
                            }
                            break;
                        }
                        case 2: {
                            if ($COD_COOPER == 3) {
                                $COD_COOPER = 1;
                            }
                            if ($subdominio == "ayllos") {
                                    $urlLogin = "http://progrid.cecred.coop.br/cgi-bin/cgiip.exe/WService=ws_progrid/wpgd0001.htm";
                            } elseif ($subdominio == "ayllosdev2") {
                                    $urlLogin = "http://progriddev2.cecred.coop.br/cgi-bin/cgiip.exe/WService=ws_progrid/wpgd0001.htm";
                            } else {
                                     $urlLogin =  "http://progriddesen.cecred.coop.br/cgi-bin/cgiip.exe/WService=ws_progrid/wpgd0001.htm";
                                    //$urlLogin =  "http://progriddev2.cecred.coop.br/cgi-bin/cgiip.exe/WService=ws_progrid/wpgd0001.htm";
                            }
                            break;
                        }
                        default: {
                            $urlLogin = "";
                        }
                    }

                    // SE O ENDERECO FOR "LIBERA", GRAVA LOG
                    if (preg_match("/libera/i", trim($subdominio))) {
                        //grava_log('LOGIN: ' . $DES_LOGIN);
                        grava_log('ACES_LIBERA'
                                 ,'login_sistemas.php'
                                 ,$DES_LOGIN
                                 ,0);  // 1-Sim  0-Nao
                    }

                    ?>
                    <html>
                    <head>
                    <script type="text/javascript">
                    function redireciona() {
                        document.frmRedirect.submit();
                    }
                    </script>
                    </head>
                    <body onLoad="redireciona();">
                    <form name="frmRedirect" id="frmRedirect" action="<?php echo $urlLogin; ?>" method="post">
                    <input type="hidden" name="cdcooper" id="cdcooper" value="<?php echo $COD_COOPER; ?>">
                    <input type="hidden" name="gidnumber" id="gidnumber" value="<?php echo $gidnumber; ?>">
                    <?php for ($i = 0; $i < count($mtccserver); $i++) { ?>
                    <input type="hidden" name="mtccserver[]" id="mtccserver[]" value="<?php echo $mtccserver[$i]; ?>">
                    <?php } ?>
                    </form>
                    </body>
                    </html>
                    <?php

                    ldap_close($dsAD);// fecha conexao com AD
                    exit();
                }
            }
        }
    }

?>
<html>
<head>
<title>CECRED - Sistemas</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="css/conteudo.css" rel="stylesheet" type="text/css">
<script type="text/javascript">
function validaCampos() {
    var form = document.frmLogin;

    if (form.DES_LOGIN.value == "") {
        alert("Informe o Usuário!");
        return false;
    }

    if (form.DES_SENHA.value == "") {
        alert("Informe a Senha!");
        return false;
    }

    return true;
}
</script>
</head>
<body bgcolor="<?php echo $COR_FUNDO_PAGINA?>" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" onLoad="document.frmLogin.DES_LOGIN.focus();">
<form action="" method="post" name="frmLogin" id="frmLogin" onSubmit="return validaCampos();">
<table width="100%" height="100%"  border="0" align="center" cellpadding="0" cellspacing="0">
    <tr>
        <td align="center" valign="middle">
            <table width="460" border="0" align="center" cellpadding="0" cellspacing="0">
                <tr>
                    <td height="49" background="images/login/bg_login.gif" class="linBotton">
                        <table width="100%" height="49" border="0" cellpadding="0" cellspacing="0">
                            <tr>
                                <td width="10">&nbsp;</td>
                                <td width="230"><img src="images/admin/1.gif"></td>
                                <td valign="bottom"><img src="images/login/tit_login.gif" width="210" height="27"></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td height="170" valign="top" bgcolor="#CBD1C5">
                        <table width="100%"  border="0" cellspacing="0" cellpadding="0">
                            <tr class="txtNormal">
                                <td width="10">&nbsp;</td>
                                <td align="center">
                                    <?php if (isset($msgErro)) { ?>
                                    <br>
                                    <p class="txtNegrito"><strong><font color="#FF0000"><?php echo $msgErro; ?></font></strong></p>
                                    <?php } ?>
                                    <p>O acesso a este portal &eacute; restrito aos usu&aacute;rios cadastrados. Caso voc&ecirc; ainda n&atilde;o possua o seu login de acesso, entre em contato com o administrador da cooperativa.</p>
                                </td>
                                <td width="230" align="center" valign="top">
                                    <table width="210" border="0" cellpadding="0" cellspacing="1" bgcolor="#999999">
                                        <tr>
                                            <td bgcolor="#CCCCCC">
                                                <table width="100%" border="0" cellspacing="0" cellpadding="2">
                                                    <tr>
                                                        <td height="5" colspan="4"></td>
                                                    </tr>
                                                    <tr>
                                                        <td width="6" height="20">&nbsp;</td>
                                                        <td width="50" class="txtNormal"><strong>Usu&aacute;rio:</strong></td>
                                                        <td colspan="2"><input name="DES_LOGIN" type="text" class="Campo" id="DES_LOGIN" style="width: 130px;" maxlength="15" value="<?php echo $DES_LOGIN; ?>"></td>
                                                    </tr>
                                                    <tr>
                                                        <td height="20">&nbsp;</td>
                                                        <td class="txtNormal"><strong>Senha:</strong></td>
                                                        <td colspan="2"><input name="DES_SENHA" type="password" class="Campo" id="DES_SENHA" style="width: 130px;" maxlength="20"></td>
                                                    </tr>
                                                    <tr>
                                                        <td height="20">&nbsp;</td>
                                                        <td class="txtNormal"><strong>Sistema:</strong></td>
                                                        <td colspan="2">
                                                            <select name="IND_SISTEMA" class="Campo" id="IND_SISTEMA" style="width: 130px;">
                                                                <option value="1" selected>Ayllos</option>
                                                                <option value="2">Gestão de Eventos</option>
                                                            </select>
                                                        </td>
                                                    </tr>
                                                    <? if ($subdominio == 'intranetdev2') { ?>
                                                    <tr>
                                                        <td height="20">&nbsp;</td>
                                                        <td class="txtNormal"><strong>Ambiente:</strong></td>
                                                        <td colspan="2">
                                                            <select class="Campo" id="id_ambiente" name="id_ambiente" style="width: 130px;">
                                                                <option value="1" selected>Local</option>
                                                                <option value="2">Desenvolvimento</option>
                                                            </select>
                                                        </td>
                                                    </tr>
                                                    <? } ?>
                                                    <tr>
                                                        <td>&nbsp;</td>
                                                        <td class="txtNegrito">&nbsp;</td>
                                                        <td width="127" height="35" align="right"><input name="imageField" type="image" src="images/botoes/btn_entrar.gif" width="60" height="20" border="0"></td>
                                                        <td align="right">&nbsp;</td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
</form>
</body>
</html>

<?php
ldap_close($dsAD);// fecha conexao com AD
?>
