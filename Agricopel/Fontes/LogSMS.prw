#include 'protheus.ch'
#include 'totvs.ch'
#include 'rwmake.ch'
#include 'tbiconn.ch'
#include 'fileio.ch'


/*/{Protheus.doc} LogSMS
(long_description)
@author    Pedro.Souza
@since     15/09/2020
@version   ${version}
@example
(examples)
@see Classe para tratar caracteres especiais em strings, substituindo um determinado caracter por outro ou um espaço em branco,
de acordo com os parametros informado em MM_CLNCHAR
/*/
class LogSMS
    Data cFileName        As String
    Method new(cPrefixo) constructor
    Method getFileName()
    Method setFileName(cFileName)
    Method eraseLog()
    Method saveMsg(cMsg)
    Method readLog()
endclass

/*/{Protheus.doc} new
Metodo construtor
@author    Pedro.Souza
@since     15/09/2020
@version   ${version}
@param  cPrefixo, caracter, opcional prefixo do nome do arquivo (padrão err_)
@example
(examples)
@see (links_or_references)
/*/
Method New(cPrefixo) class LogSMS
    Default cPrefixo := "log_"
    ::cFileName := "\tmp\sms\"+cPrefixo+dtos(date())+"_"+strtran(time(),":","")+"_"+cValToChar(ThreadId())+".txt"
return self

/*/{Protheus.doc} getFileName
Metodo que retorna o nome do arquivo de log
@author    Pedro.Souza
@since     15/09/2020
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
Method getFileName() class LogSMS
return ::cFileName

/*/{Protheus.doc} setFileName
Metodo que salva o nome do arquivo de log
@author    Pedro.Souza
@since     15/09/2020
@version   ${version}
@param  cFileName, caracter, nome do arquivo
@example
(examples)
@see (links_or_references)
/*/
Method setFileName(cFileName) class LogSMS
    Local nA:= 0
    Local lDir:= .T.
    Local aFolder:= {}
    Local cDir:= "\"
    Default cFileName:= ::cFileName
    
    aFolder:= StrTokArr(cFileName, "\")

    For nA:=1 to Len(aFolder)-1 //última posição é o nome do arquivo.
        cDir+= aFolder[nA]+'\'
        If !ExistDir(cDir)
           If MakeDir(cDir) <> 0
            lDir:=.F.
            Exit
           Endif
        Endif

    Next    
    If lDir    
        ::cFileName := cFileName
    Endif
return ::cFileName


/*/{Protheus.doc} eraseLog
Metodo que apaga o arquivo de log
@author    Pedro.Souza
@since     15/09/2020
@version 1.0
@example
/*/
Method eraseLog() class LogSMS
    if file(::cFileName)
        ferase(::cFileName)
    Endif
Return self


/*/{Protheus.doc} saveMsg
Metodo que salva a mensagem no arquivo de log
@author    Pedro.Souza
@since     15/09/2020
@param  cMsg, caracter, mensagem para salvar no arquivo de log
@version 1.0
@example
/*/
Method saveMsg(cMsg) class LogSMS
    Local nLaco  := 1
    Local nHdl   := -1
    Default cMsg:= ""

    // Tenta criar / abrir o arquivo para o log
    while nLaco <= 5 .and. nHdl < 0
        If !File(::cFileName)
            nHdl := FCreate(::cFileName)
        Else
            nHdl := FOpen(::cFileName, FO_READWRITE)
        Endif
        nLaco++
    enddo
    if nHdl >= 0
        FSeek(nHdl,0,FS_END)
        FWrite(nHdl,time()+" "+cMsg+CRLF)
        FClose(nHdl)
    Endif
return self


/*/{Protheus.doc} readLog
Metodo que retorna um array das mensagens do log
@author    Pedro.Souza
@since     17/09/2020
@param  cMsg, caracter, mensagem para salvar no arquivo de log
@version 1.0
@example
/*/
Method readLog() class LogSMS
    Local aLinhas := {}
    Local nHandle
    Local cLine
    BEGIN SEQUENCE
        if file(::cFileName)
            nHandle := FT_FUse(::cFileName)
            if nHandle = -1
                conout("Problema ao ler o arquivo de log. "+::cFileName+". Erro:"+cValToChar(ferror())+CRLF)
                break
            endif
            // posiciona na primeira linha
            ft_fgotop()
            While !FT_FEOF()
                cLine := FT_FReadLn()
                aadd(aLinhas, cLine)
                FT_FSKIP()
            End
            // Fecha o Arquivo
            FT_FUSE()
        endif   // if file(::cFileName)
    RECOVER
//        cRet := "Erro"
    END SEQUENCE
return aLinhas
