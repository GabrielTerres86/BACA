create or replace and compile java source named "ListaArquivos" as
import java.io.File;

/**
 * Classe que vai receber a pasta e realizar pesquisa para listar todos os
 * arquivos contidos.
 * No final retorna string formatada por vírgulas dividindo o nome de todos os arquivos.
 * @author Petter Rafael - Supero Tecnologia
 * @since Maio/2013
 */
public class ListaArquivos {
    private static String arquivos;
    private static int tamPesq;

    /**
     * Método público para listar todos os arquivos de uma pasta informada.
     * É possível pesquisar por fragmentos do nome do arquivo, inclusive utilizando o caracter coringa %
     * @param path Path da pasta - inclusive - que será pesquisada
     * @param pesquisa String de pesquisa para fragmentos de nome
     * @return Retorna String formatada contendo os nomes dos arquivos
     */
    public static String listar(String path, String pesquisa){
        File pasta = new File(path);
        String[] pesquisar = null;
        boolean semBusca = false;
        boolean erros = false;

        arquivos = "";

        try{
            if(pesquisa != null){
                tamPesq = pesquisa.length();
                pesquisar = pesquisa.split("%");
            }else{
                tamPesq = 0;
            }

            for(File arq : pasta.listFiles()){
                semBusca = false;

                if(tamPesq > 0){
                    if(arq.isFile()){
                        for(String dado : pesquisar){
                            if(dado.length() > 0){
                                if(arq.getName().indexOf(dado) == -1){
                                    semBusca = true;
                                }else if(!pesquisa.substring(0, 1).equals("%") && !pesquisa.substring(0, 1).equals(arq.getName().substring(0, 1))){
                                    semBusca = true;
                                }else if(!pesquisa.substring(pesquisa.length() - 1, pesquisa.length()).equals("%")
                                        && !pesquisa.substring(pesquisa.length() - 1, pesquisa.length()).equals(arq.getName().substring(arq.getName().length() - 1, arq.getName().length()))){
                                    semBusca = true;
                                }
                            }
                        }

                        if(!semBusca){
                            if(arquivos.length() < 5){
                                arquivos = arquivos + arq.getName();
                            }else{
                                arquivos = arquivos + "," + arq.getName();
                            }
                        }
                    }
                }else{
                    if(arq.isFile()){
                        if(arquivos.length() < 5){
                            arquivos = arquivos + arq.getName();
                        }else{
                            arquivos = arquivos + "," + arq.getName();
                        }
                    }
                }
            }
        }catch(Exception ex){
            arquivos = "2-Erro: " + ex.toString();
            erros = true;
        }

        if(!erros){
            arquivos = "1-" + arquivos;
        }

        return arquivos;
    }
}
/
