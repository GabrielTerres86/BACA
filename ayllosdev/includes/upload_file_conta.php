<?php 
/*************************************************************************
Fonte: upload_file_conta.php
Autor: Tiago
Data : Novembro/2017                   Última Alteração:

Objetivo  : importa arquivo para o servidor. Baseado no gnuclient_upload_file.php porem, sem fazer uso do shell_exec
			e sem necessidade de um servico no lado do Ayllos  para monitorar ebaixar o arquivo
			(copia do upload_file mas com formatacao do nome do arquivo com a conta).

Alterações: 

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
fclose($Arq);

/* Montagem do nome do arquivo, incluindo o codigo da cooperativa em seu início */
//$NomeArq    = formataCdcooper($glbvars["cdcooper"]).".0.".$filename;
$NomeArq    = formataCdcooper($glbvars["cdcooper"]).".".$nrdconta.".".$filename;
$NomeArq    = preg_replace("/\s/","",$NomeArq);

/* Criptografa o conteudo do arquivo */
//print_r($key);
//print_r("#############SEPARA################");
$encriptado = cecredCript($conteudo);
//print_r($key);
//print_r("#############SEPARA################");
//print_r($conteudo);
//print_r("#############SEPARA################");
//print_r($encriptado);
//print_r("#############SEPARA################");
//$criptado = cecredDecript($encriptado);
//print_r($criptado);


/* Geração do arquivo criptografado para o caminho solicitado */
$caminho = $dirArqDne;
$fp=fopen ($caminho.$NomeArq, "w+");
fwrite($fp,$encriptado);
fclose($fp);

?>
