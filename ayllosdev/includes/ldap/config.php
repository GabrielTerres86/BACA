<?
$TIT_PAGINA = "CECRED - Intranet";
$COR_FUNDO_PAGINA  = "#DFE0D6";
$COD_CECRED = 1;
$COD_CECRED_LDAP = 3;
$DIVISOR = 1000;
//Caminho da raiz
$path_abs = $_SERVER['DOCUMENT_ROOT'];//"c:/inetpub/wwwroot";//$_SERVER['DOCUMENT_ROOT'];//;
//Caminho URL do sistema
#$path_url = 'http://'.$_SERVER['SERVER_NAME']; //"http://intranet.cecred.coop.br";
#$path_url = 'http://intranet.cecred.coop.br';
$path_url = 'http://intranetqa1.cecred.coop.br';
// Caminho do Editor
$path_url_editor = $path_url."/editor/";
// Caminho dos Documentos
$path_abs_documento = "/var/www/documentos";
//Caminho para chat
$path_chat = "/chat/";
//Caminho para upload dos bot�es do menu;
$path_upload_btn_menu = "/images/geral";
//Caminho para upload dos bot�es do menu;
$path_relatorio_importacao = "/relatorio/arquivos";
//Caminho para upload dos �cones dos intes;
$path_upload_ico_item = "/images/icones";
//Caminho para criar a pasta raiz de cada Cooperativa
$path_pasta_raiz = "/documentos";
//Caminho para criar a pasta raiz de cada Cooperativa
$path_email = "intranet@cecred.coop.br";
//Caminho para download de arquivos (se��o download)
$path_download = "/download/arquivos";
//Caminho para armazenar imagens das not�cias.
$image_upload_noticia = "/images/noticia";
//Caminho para download de arquivos (se��o not�cias)
$path_download_noticia = "/noticia/arquivos";
//Caminho para download de arquivos (se��o agenda)
$path_download_agenda = "/agenda/arquivos";
//Caminho para download de arquivos (se��o chat)
$path_download_chat = "/chat/arquivos";
//Caminho relativo da raiz.
$path_rel_intranet = "/";
//Caminho images
$path_image = "/images/";
//Caminho para download de cart�es de Assinatura
$path_cartao = "/cliente/cartaoassinatura/arquivos";
//Caminho para cria��o de pasta das se��es
$path_secao = "/secao";
//Extens�es de arquivos n�o permitidos
//$ext_arquivos = "ade;adp;bas;bat;chm;cmd;com;cpl;crt;exe;hlp;hta;inf;ins;isp;js;jse;lnk;mdb;mde;mp3;mpg;mpeg;msc;msi;msp;mst;pcd;pif;reg;scr;sct;shb;shs;vb;vbe;vbs;wmv;wsc;wsf;wsh";//separados por ";"/intranet
$ext_arquivos = "ade;adp;bas;bat;chm;cmd;com;cpl;crt;exe;hlp;hta;inf;ins;isp;js;jse;lnk;mdb;mde;mp3;mpg;mpeg;msc;msi;msp;mst;pcd;pif;reg;scr;sct;shb;shs;wmv;wsc;wsf;wsh";//separados por ";"/intranet
//vari�vel para controla a posi��o TOP das layers de ICONES
//vari�vel para controla a posi��o TOP das layers de ICONES
$pos_top_layer = "24px";
// Msg de erro de documentos
$path_msg_contato = "Entre em contato com o administrador do sistema";

// Configura��es de Clipping - Jonathan Precise 17/06/2009
//Caminho para armazenar imagens de clipping
$image_upload_clipping = '/images/clipping/';

// Configuracoes de Clip Flash (apresentacoes) - Jonathan Supero 25/04/2011
// caminho para armazenar arquivos do clipflash
$path_clipflash_arquivos = '/clipflash/arquivos/';
?>
