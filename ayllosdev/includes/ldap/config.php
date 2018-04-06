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
//Caminho para upload dos botões do menu;
$path_upload_btn_menu = "/images/geral";
//Caminho para upload dos botões do menu;
$path_relatorio_importacao = "/relatorio/arquivos";
//Caminho para upload dos ícones dos intes;
$path_upload_ico_item = "/images/icones";
//Caminho para criar a pasta raiz de cada Cooperativa
$path_pasta_raiz = "/documentos";
//Caminho para criar a pasta raiz de cada Cooperativa
$path_email = "intranet@cecred.coop.br";
//Caminho para download de arquivos (seção download)
$path_download = "/download/arquivos";
//Caminho para armazenar imagens das notícias.
$image_upload_noticia = "/images/noticia";
//Caminho para download de arquivos (seção notícias)
$path_download_noticia = "/noticia/arquivos";
//Caminho para download de arquivos (seção agenda)
$path_download_agenda = "/agenda/arquivos";
//Caminho para download de arquivos (seção chat)
$path_download_chat = "/chat/arquivos";
//Caminho relativo da raiz.
$path_rel_intranet = "/";
//Caminho images
$path_image = "/images/";
//Caminho para download de cartões de Assinatura
$path_cartao = "/cliente/cartaoassinatura/arquivos";
//Caminho para criação de pasta das seções
$path_secao = "/secao";
//Extensões de arquivos não permitidos
//$ext_arquivos = "ade;adp;bas;bat;chm;cmd;com;cpl;crt;exe;hlp;hta;inf;ins;isp;js;jse;lnk;mdb;mde;mp3;mpg;mpeg;msc;msi;msp;mst;pcd;pif;reg;scr;sct;shb;shs;vb;vbe;vbs;wmv;wsc;wsf;wsh";//separados por ";"/intranet
$ext_arquivos = "ade;adp;bas;bat;chm;cmd;com;cpl;crt;exe;hlp;hta;inf;ins;isp;js;jse;lnk;mdb;mde;mp3;mpg;mpeg;msc;msi;msp;mst;pcd;pif;reg;scr;sct;shb;shs;wmv;wsc;wsf;wsh";//separados por ";"/intranet
//variável para controla a posição TOP das layers de ICONES
//variável para controla a posição TOP das layers de ICONES
$pos_top_layer = "24px";
// Msg de erro de documentos
$path_msg_contato = "Entre em contato com o administrador do sistema";

// Configurações de Clipping - Jonathan Precise 17/06/2009
//Caminho para armazenar imagens de clipping
$image_upload_clipping = '/images/clipping/';

// Configuracoes de Clip Flash (apresentacoes) - Jonathan Supero 25/04/2011
// caminho para armazenar arquivos do clipflash
$path_clipflash_arquivos = '/clipflash/arquivos/';
?>
