<?php 
/*************************************************************************
Fonte: upload_file_ted.php
Autor: Anderson Schloegel - Mouts - PJ500
Data : Maio/2019                 

Objetivo  : importa arquivo para o servidor. Baseado no arquivo upload_file_conta.php que foi 
			baseado no gnuclient_upload_file.php porem, sem fazer uso do shell_exec
			e sem necessidade de um servico no lado do Ayllos  para monitorar ebaixar o arquivo
			(copia do upload_file mas com formatacao do nome do arquivo com a conta).

Alterações: 24/06/2019 - Ajuste no fclose para fechar a variavel/arquivo correto - PRJ 500 (Mateus Z / Mouts)

***********************************************************************/
//$Arq deve ser passado com o caminho do arquivo    * caminho/arquivo
//$dirArqDne deve ser passado o caminho             * arquivo
//$filename deve ser passado o nome do arquivo      * caminho

/* Chaves para critografia */
$key="50983417512346753284723840854609576043576094576059437609";
$iv="12345678";

/* Formatação do codigo da Cooperativa */
if (!function_exists('formataCdcooper')) {
    function formataCdcooper($cdcooper){
        while(strlen($cdcooper) < 3){
            $cdcooper = "0".$cdcooper;
        };
        return $cdcooper;
    }
}

/* Leitura do conteudo do arquivo pra variavel */
$wArq=fopen($Arq,"r+");
$conteudo=fread($wArq,filesize($Arq));
fclose($wArq);

/* Montagem do nome do arquivo, incluindo o codigo da cooperativa em seu início */
$NomeArq    = formataCdcooper($glbvars["cdcooper"]).".".$nrdconta.".".$filename;
$NomeArq    = preg_replace("/\s/","",$NomeArq);

/* Criptografa o conteudo do arquivo */
$encriptado = cecredCript($conteudo);

/* Geração do arquivo criptografado para o caminho solicitado */
$caminho = $dirArqDne;
$fp=fopen ($caminho.$NomeArq, "w+");
fwrite($fp,$encriptado);
fclose($fp);

?>
