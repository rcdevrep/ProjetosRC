#Include "Totvs.ch"
#Include "RESTFul.ch"
#Include "TopConn.ch"


WSRESTFUL IntegEQM DESCRIPTION 'Integra��o EQM x Protheus'
    //Atributos
    WSDATA id         AS STRING
    WSDATA updated_at AS STRING
    WSDATA limit      AS INTEGER
    WSDATA page       AS INTEGER
 
    //M�todos
    WSMETHOD GET    ID     DESCRIPTION 'Retorna o registro pesquisado' WSSYNTAX '/IntegEQM/get_id?{id}'                       PATH 'get_id'        PRODUCES APPLICATION_JSON
    WSMETHOD GET    ALL    DESCRIPTION 'Retorna todos os registros'    WSSYNTAX '/IntegEQM/get_all?{updated_at, limit, page}' PATH 'get_all'       PRODUCES APPLICATION_JSON
    WSMETHOD POST   NEW    DESCRIPTION 'Inclus�o de registro'          WSSYNTAX '/IntegEQM/new'                               PATH 'new'           PRODUCES APPLICATION_JSON
    WSMETHOD PUT    UPDATE DESCRIPTION 'Atualiza��o de registro'       WSSYNTAX '/IntegEQM/update'                            PATH 'update'        PRODUCES APPLICATION_JSON
    WSMETHOD DELETE ERASE  DESCRIPTION 'Exclus�o de registro'          WSSYNTAX '/IntegEQM/erase'                             PATH 'erase'         PRODUCES APPLICATION_JSON
END WSRESTFUL


WSMETHOD GET ID WSRECEIVE id WSSERVICE IntegEQM
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cAliasWS   := 'SC0'


    If Empty(::id)
        //SetRestFault(500, 'Falha ao consultar o registro') //caso queira usar esse comando, voc� n�o poder� usar outros retornos, como os abaixo
        Self:setStatus(500) 
        jResponse['errorId']  := 'ID001'
        jResponse['error']    := 'ID vazio'
        jResponse['solution'] := 'Informe o ID'
    Else
        DbSelectArea(cAliasWS)
        (cAliasWS)->(DbSetOrder(1))

        //Se n�o encontrar o registro
        If ! (cAliasWS)->(MsSeek(FWxFilial(cAliasWS) + ::id))
            //SetRestFault(500, 'Falha ao consultar ID') //caso queira usar esse comando, voc� n�o poder� usar outros retornos, como os abaixo
            Self:setStatus(500) 
            jResponse['errorId']  := 'ID002'
            jResponse['error']    := 'ID n�o encontrado'
            jResponse['solution'] := 'C�digo ID n�o encontrado na tabela ' + cAliasWS
        Else
            //Define o retorno
            jResponse['tipo'] := (cAliasWS)->C0_TIPO 
            jResponse['docres'] := (cAliasWS)->C0_DOCRES 
            jResponse['solicit'] := (cAliasWS)->C0_SOLICIT 
            jResponse['filial'] := (cAliasWS)->C0_FILIAL 
            jResponse['produto'] := (cAliasWS)->C0_PRODUTO 
            jResponse['local'] := (cAliasWS)->C0_LOCAL 
            jResponse['emissao'] := (cAliasWS)->C0_EMISSAO 
            jResponse['obs'] := (cAliasWS)->C0_OBS 
            jResponse['qtdped'] := (cAliasWS)->C0_QTDPED 
            jResponse['qtdorig'] := (cAliasWS)->Co_QTDORIG 
        EndIf
    EndIf

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(EncodeUTF8(jResponse:toJSON()))
Return lRet


WSMETHOD GET ALL WSRECEIVE updated_at, limit, page WSSERVICE IntegEQM
    Local lRet       := .T.
    Local jResponse  := JsonObject():New()
    Local cQueryTab  := ''
    Local nTamanho   := 10
    Local nTotal     := 0
    Local nPags      := 0
    Local nPagina    := 0
    Local nAtual     := 0
    Local oRegistro
    Local cAliasWS   := 'SC0'

    //Efetua a busca dos registros
    cQueryTab := " SELECT " + CRLF
    cQueryTab += "     TAB.R_E_C_N_O_ AS TABREC " + CRLF
    cQueryTab += " FROM " + CRLF
    cQueryTab += "     " + RetSQLName(cAliasWS) + " TAB " + CRLF
    cQueryTab += " WHERE " + CRLF
    cQueryTab += "     TAB.D_E_L_E_T_ = '' " + CRLF
    
    //Abaixo esta sendo feito o filtro com o campo de log de altera��o (LGA), por�m desde Maio de 2023, pode apresentar diverg�ncias
    // ent�o voc� pode substituir o campo 'C0_USERLGA' por S_T_A_M_P_, I_N_S_D_T_ ou outro campo de data da tabela
    If ! Empty(::updated_at)
        cQueryTab += "     AND ((CASE WHEN SUBSTRING(C0_USERLGA, 03, 1) != ' ' THEN " + CRLF
        cQueryTab += "        CONVERT(VARCHAR,DATEADD(DAY,((ASCII(SUBSTRING(C0_USERLGA,12,1)) - 50) * 100 + (ASCII(SUBSTRING(C0_USERLGA,16,1)) - 50)),'19960101'),112) " + CRLF
        cQueryTab += "        ELSE '' " + CRLF
        cQueryTab += "     END) >= '" + StrTran(::updated_at, '-', '') + "') " + CRLF
    EndIf
    cQueryTab += " ORDER BY " + CRLF
    cQueryTab += "     TABREC " + CRLF
    TCQuery cQueryTab New Alias 'QRY_TAB'

    //Se n�o encontrar registros
    If QRY_TAB->(EoF())
        //SetRestFault(500, 'Falha ao consultar registros') //caso queira usar esse comando, voc� n�o poder� usar outros retornos, como os abaixo
        Self:setStatus(500) 
        jResponse['errorId']  := 'ALL003'
        jResponse['error']    := 'Registro(s) n�o encontrado(s)'
        jResponse['solution'] := 'A consulta de registros n�o retornou nenhuma informa��o'
    Else
        jResponse['objects'] := {}

        //Conta o total de registros
        Count To nTotal
        QRY_TAB->(DbGoTop())

        //O tamanho do retorno, ser� o limit, se ele estiver definido
        If ! Empty(::limit)
            nTamanho := ::limit
        EndIf

        //Pegando total de p�ginas
        nPags := NoRound(nTotal / nTamanho, 0)
        nPags += Iif(nTotal % nTamanho != 0, 1, 0)
        
        //Se vier p�gina
        If ! Empty(::page)
            nPagina := ::page
        EndIf

        //Se a p�gina vier zerada ou negativa ou for maior que o m�ximo, ser� 1 
        If nPagina <= 0 .Or. nPagina > nPags
            nPagina := 1
        EndIf

        //Se a p�gina for diferente de 1, pula os registros
        If nPagina != 1
            QRY_TAB->(DbSkip((nPagina-1) * nTamanho))
        EndIf

        //Adiciona os dados para a meta
        jJsonMeta := JsonObject():New()
        jJsonMeta['total']         := nTotal
        jJsonMeta['current_page']  := nPagina
        jJsonMeta['total_page']    := nPags
        jJsonMeta['total_items']   := nTamanho
        jResponse['meta'] := jJsonMeta

        //Percorre os registros
        While ! QRY_TAB->(EoF())
            nAtual++
            
            //Se ultrapassar o limite, encerra o la�o
            If nAtual > nTamanho
                Exit
            EndIf

            //Posiciona o registro e adiciona no retorno
            DbSelectArea(cAliasWS)
            (cAliasWS)->(DbGoTo(QRY_TAB->TABREC))
            
            oRegistro := JsonObject():New()
            oRegistro['tipo'] := (cAliasWS)->C0_TIPO 
            oRegistro['docres'] := (cAliasWS)->C0_DOCRES 
            oRegistro['solicit'] := (cAliasWS)->C0_SOLICIT 
            oRegistro['filial'] := (cAliasWS)->C0_FILIAL 
            oRegistro['produto'] := (cAliasWS)->C0_PRODUTO 
            oRegistro['local'] := (cAliasWS)->C0_LOCAL 
            oRegistro['emissao'] := (cAliasWS)->C0_EMISSAO 
            oRegistro['obs'] := (cAliasWS)->C0_OBS 
            oRegistro['qtdped'] := (cAliasWS)->C0_QTDPED 
            oRegistro['qtdorig'] := (cAliasWS)->Co_QTDORIG 
            aAdd(jResponse['objects'], oRegistro)

            QRY_TAB->(DbSkip())
        EndDo
    EndIf
    QRY_TAB->(DbCloseArea())

    //Define o retorno
    Self:SetContentType('application/json')
    Self:SetResponse(EncodeUTF8(jResponse:toJSON()))
Return lRet


WSMETHOD POST NEW WSRECEIVE WSSERVICE IntegEQM
    Local lRet              := .T.
    Local aDados            := {}
    Local jJson             := Nil
    Local cJson             := Self:GetContent()
    Local cError            := ''
    Local nLinha            := 0
    Local cDirLog           := '\x_logs\'
    Local cArqLog           := ''
    Local cErrorLog         := ''
    Local aLogAuto          := {}
    Local nCampo            := 0
    Local jResponse         := JsonObject():New()
    Local cAliasWS          := 'SC0'
    Private lMsErroAuto     := .F.
    Private lMsHelpAuto     := .T.
    Private lAutoErrNoFile  := .T.
 
    //Se n�o existir a pasta de logs, cria
    IF ! ExistDir(cDirLog)
        MakeDir(cDirLog)
    EndIF    

    //Definindo o conte�do como JSON, e pegando o content e dando um parse para ver se a estrutura est� ok
    Self:SetContentType('application/json')
    jJson  := JsonObject():New()
    cError := jJson:FromJson(cJson)
 
    //Se tiver algum erro no Parse, encerra a execu��o
    IF ! Empty(cError)
        //SetRestFault(500, 'Falha ao obter JSON') //caso queira usar esse comando, voc� n�o poder� usar outros retornos, como os abaixo
        Self:setStatus(500) 
        jResponse['errorId']  := 'NEW004'
        jResponse['error']    := 'Parse do JSON'
        jResponse['solution'] := 'Erro ao fazer o Parse do JSON'

    Else
		DbSelectArea(cAliasWS)
       
		//Adiciona os dados do ExecAuto
		aAdd(aDados, {'C0_TIPO',   jJson:GetJsonObject('tipo'),   Nil})
		aAdd(aDados, {'C0_DOCRES',   jJson:GetJsonObject('docres'),   Nil})
		aAdd(aDados, {'C0_SOLICIT',   jJson:GetJsonObject('solicit'),   Nil})
		aAdd(aDados, {'C0_FILIAL',   jJson:GetJsonObject('filial'),   Nil})
		aAdd(aDados, {'C0_PRODUTO',   jJson:GetJsonObject('produto'),   Nil})
		aAdd(aDados, {'C0_LOCAL',   jJson:GetJsonObject('local'),   Nil})
		aAdd(aDados, {'C0_EMISSAO',   jJson:GetJsonObject('emissao'),   Nil})
		aAdd(aDados, {'C0_OBS',   jJson:GetJsonObject('obs'),   Nil})
		aAdd(aDados, {'C0_QTDPED',   jJson:GetJsonObject('qtdped'),   Nil})
		aAdd(aDados, {'Co_QTDORIG',   jJson:GetJsonObject('qtdorig'),   Nil})
		
		//Percorre os dados do execauto
		For nCampo := 1 To Len(aDados)
			//Se o campo for data, retira os hifens e faz a convers�o
			If GetSX3Cache(aDados[nCampo][1], 'X3_TIPO') == 'D'
				aDados[nCampo][2] := StrTran(aDados[nCampo][2], '-', '')
				aDados[nCampo][2] := sToD(aDados[nCampo][2])
			EndIf
		Next

		//Chama a inclus�o autom�tica
		MsExecAuto({|x, y| A430Reserv(x, y)}, aDados, 3)

		//Se houve erro, gera um arquivo de log dentro do diret�rio da protheus data
		If lMsErroAuto
			//Monta o texto do Error Log que ser� salvo
			cErrorLog   := ''
			aLogAuto    := GetAutoGrLog()
			For nLinha := 1 To Len(aLogAuto)
				cErrorLog += aLogAuto[nLinha] + CRLF
			Next nLinha

			//Grava o arquivo de log
			cArqLog := 'IntegEQM_New_' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.log'
			MemoWrite(cDirLog + cArqLog, cErrorLog)

			//Define o retorno para o WebService
			//SetRestFault(500, cErrorLog) //caso queira usar esse comando, voc� n�o poder� usar outros retornos, como os abaixo
           Self:setStatus(500) 
			jResponse['errorId']  := 'NEW005'
			jResponse['error']    := 'Erro na inclus�o do registro'
			jResponse['solution'] := 'Nao foi possivel incluir o registro, foi gerado um arquivo de log em ' + cDirLog + cArqLog + ' '
			lRet := .F.

		//Sen�o, define o retorno
		Else
			jResponse['note']     := 'Registro incluido com sucesso'
		EndIf

    EndIf

    //Define o retorno
    Self:SetResponse(EncodeUTF8(jResponse:toJSON()))
Return lRet


WSMETHOD PUT UPDATE WSRECEIVE id WSSERVICE IntegEQM
    Local lRet              := .T.
    Local aDados            := {}
    Local jJson             := Nil
    Local cJson             := Self:GetContent()
    Local cError            := ''
    Local nLinha            := 0
    Local cDirLog           := '\x_logs\'
    Local cArqLog           := ''
    Local cErrorLog         := ''
    Local aLogAuto          := {}
    Local nCampo            := 0
    Local jResponse         := JsonObject():New()
    Local cAliasWS          := 'SC0'
    Private lMsErroAuto     := .F.
    Private lMsHelpAuto     := .T.
    Private lAutoErrNoFile  := .T.

    //Se n�o existir a pasta de logs, cria
    IF ! ExistDir(cDirLog)
        MakeDir(cDirLog)
    EndIF    

    //Definindo o conte�do como JSON, e pegando o content e dando um parse para ver se a estrutura est� ok
    Self:SetContentType('application/json')
    jJson  := JsonObject():New()
    cError := jJson:FromJson(cJson)

    //Se o id estiver vazio
    If Empty(::id)
        //SetRestFault(500, 'Falha ao consultar o registro') //caso queira usar esse comando, voc� n�o poder� usar outros retornos, como os abaixo
        Self:setStatus(500) 
        jResponse['errorId']  := 'UPD006'
        jResponse['error']    := 'ID vazio'
        jResponse['solution'] := 'Informe o ID'
    Else
        DbSelectArea(cAliasWS)
        (cAliasWS)->(DbSetOrder(1))

        //Se n�o encontrar o registro
        If ! (cAliasWS)->(MsSeek(FWxFilial(cAliasWS) + ::id))
            //SetRestFault(500, 'Falha ao consultar ID') //caso queira usar esse comando, voc� n�o poder� usar outros retornos, como os abaixo
            Self:setStatus(500) 
            jResponse['errorId']  := 'UPD007'
            jResponse['error']    := 'ID n�o encontrado'
            jResponse['solution'] := 'C�digo ID n�o encontrado na tabela ' + cAliasWS
        Else
 
            //Se tiver algum erro no Parse, encerra a execu��o
            If ! Empty(cError)
                //SetRestFault(500, 'Falha ao obter JSON') //caso queira usar esse comando, voc� n�o poder� usar outros retornos, como os abaixo
                Self:setStatus(500) 
                jResponse['errorId']  := 'UPD008'
                jResponse['error']    := 'Parse do JSON'
                jResponse['solution'] := 'Erro ao fazer o Parse do JSON'

            Else
		         DbSelectArea(cAliasWS)
                
		         //Adiciona os dados do ExecAuto
		         aAdd(aDados, {'C0_TIPO',   jJson:GetJsonObject('tipo'),   Nil})
		         aAdd(aDados, {'C0_DOCRES',   jJson:GetJsonObject('docres'),   Nil})
		         aAdd(aDados, {'C0_SOLICIT',   jJson:GetJsonObject('solicit'),   Nil})
		         aAdd(aDados, {'C0_FILIAL',   jJson:GetJsonObject('filial'),   Nil})
		         aAdd(aDados, {'C0_PRODUTO',   jJson:GetJsonObject('produto'),   Nil})
		         aAdd(aDados, {'C0_LOCAL',   jJson:GetJsonObject('local'),   Nil})
		         aAdd(aDados, {'C0_EMISSAO',   jJson:GetJsonObject('emissao'),   Nil})
		         aAdd(aDados, {'C0_OBS',   jJson:GetJsonObject('obs'),   Nil})
		         aAdd(aDados, {'C0_QTDPED',   jJson:GetJsonObject('qtdped'),   Nil})
		         aAdd(aDados, {'Co_QTDORIG',   jJson:GetJsonObject('qtdorig'),   Nil})
		         
		         //Percorre os dados do execauto
		         For nCampo := 1 To Len(aDados)
		         	//Se o campo for data, retira os hifens e faz a convers�o
		         	If GetSX3Cache(aDados[nCampo][1], 'X3_TIPO') == 'D'
		         		aDados[nCampo][2] := StrTran(aDados[nCampo][2], '-', '')
		         		aDados[nCampo][2] := sToD(aDados[nCampo][2])
		         	EndIf
		         Next

		         //Chama a atualiza��o autom�tica
		         MsExecAuto({|x, y| A430Reserv(x, y)}, aDados, 4)

		         //Se houve erro, gera um arquivo de log dentro do diret�rio da protheus data
		         If lMsErroAuto
		         	//Monta o texto do Error Log que ser� salvo
		         	cErrorLog   := ''
		         	aLogAuto    := GetAutoGrLog()
		         	For nLinha := 1 To Len(aLogAuto)
		         		cErrorLog += aLogAuto[nLinha] + CRLF
		         	Next nLinha

		            //Grava o arquivo de log
		            cArqLog := 'IntegEQM_New_' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.log'
		            MemoWrite(cDirLog + cArqLog, cErrorLog)

		            //Define o retorno para o WebService
		            //SetRestFault(500, cErrorLog) //caso queira usar esse comando, voc� n�o poder� usar outros retornos, como os abaixo
		            Self:setStatus(500) 
		            jResponse['errorId']  := 'UPD009'
		            jResponse['error']    := 'Erro na atualiza��o do registro'
		            jResponse['solution'] := 'Nao foi possivel incluir o registro, foi gerado um arquivo de log em ' + cDirLog + cArqLog + ' '
		            lRet := .F.

		         //Sen�o, define o retorno
		         Else
		         	jResponse['note']     := 'Registro incluido com sucesso'
		         EndIf

		     EndIf
		 EndIf
    EndIf

    //Define o retorno
    Self:SetResponse(EncodeUTF8(jResponse:toJSON()))
Return lRet


WSMETHOD DELETE ERASE WSRECEIVE id WSSERVICE IntegEQM
    Local lRet              := .T.
    Local aDados            := {}
    Local jJson             := Nil
    Local cJson             := Self:GetContent()
    Local cError            := ''
    Local nLinha            := 0
    Local cDirLog           := '\x_logs\'
    Local cArqLog           := ''
    Local cErrorLog         := ''
    Local aLogAuto          := {}
    Local nCampo            := 0
    Local jResponse         := JsonObject():New()
    Local cAliasWS          := 'SC0'
    Private lMsErroAuto     := .F.
    Private lMsHelpAuto     := .T.
    Private lAutoErrNoFile  := .T.

    //Se n�o existir a pasta de logs, cria
    IF ! ExistDir(cDirLog)
        MakeDir(cDirLog)
    EndIF    

    //Definindo o conte�do como JSON, e pegando o content e dando um parse para ver se a estrutura est� ok
    Self:SetContentType('application/json')
    jJson  := JsonObject():New()
    cError := jJson:FromJson(cJson)

    //Se o id estiver vazio
    If Empty(::id)
        //SetRestFault(500, 'Falha ao consultar o registro') //caso queira usar esse comando, voc� n�o poder� usar outros retornos, como os abaixo
        Self:setStatus(500) 
        jResponse['errorId']  := 'DEL010'
        jResponse['error']    := 'ID vazio'
        jResponse['solution'] := 'Informe o ID'
    Else
        DbSelectArea(cAliasWS)
        (cAliasWS)->(DbSetOrder(1))

        //Se n�o encontrar o registro
        If ! (cAliasWS)->(MsSeek(FWxFilial(cAliasWS) + ::id))
            //SetRestFault(500, 'Falha ao consultar ID') //caso queira usar esse comando, voc� n�o poder� usar outros retornos, como os abaixo
            Self:setStatus(500) 
            jResponse['errorId']  := 'DEL011'
            jResponse['error']    := 'ID n�o encontrado'
            jResponse['solution'] := 'C�digo ID n�o encontrado na tabela ' + cAliasWS
        Else
 
            //Se tiver algum erro no Parse, encerra a execu��o
            If ! Empty(cError)
                //SetRestFault(500, 'Falha ao obter JSON') //caso queira usar esse comando, voc� n�o poder� usar outros retornos, como os abaixo
                Self:setStatus(500) 
                jResponse['errorId']  := 'DEL012'
                jResponse['error']    := 'Parse do JSON'
                jResponse['solution'] := 'Erro ao fazer o Parse do JSON'

            Else
		         DbSelectArea(cAliasWS)
                
		         //Adiciona os dados do ExecAuto
		         aAdd(aDados, {'C0_TIPO',   jJson:GetJsonObject('tipo'),   Nil})
		         aAdd(aDados, {'C0_DOCRES',   jJson:GetJsonObject('docres'),   Nil})
		         aAdd(aDados, {'C0_SOLICIT',   jJson:GetJsonObject('solicit'),   Nil})
		         aAdd(aDados, {'C0_FILIAL',   jJson:GetJsonObject('filial'),   Nil})
		         aAdd(aDados, {'C0_PRODUTO',   jJson:GetJsonObject('produto'),   Nil})
		         aAdd(aDados, {'C0_LOCAL',   jJson:GetJsonObject('local'),   Nil})
		         aAdd(aDados, {'C0_EMISSAO',   jJson:GetJsonObject('emissao'),   Nil})
		         aAdd(aDados, {'C0_OBS',   jJson:GetJsonObject('obs'),   Nil})
		         aAdd(aDados, {'C0_QTDPED',   jJson:GetJsonObject('qtdped'),   Nil})
		         aAdd(aDados, {'Co_QTDORIG',   jJson:GetJsonObject('qtdorig'),   Nil})
		         
		         //Percorre os dados do execauto
		         For nCampo := 1 To Len(aDados)
		         	//Se o campo for data, retira os hifens e faz a convers�o
		         	If GetSX3Cache(aDados[nCampo][1], 'X3_TIPO') == 'D'
		         		aDados[nCampo][2] := StrTran(aDados[nCampo][2], '-', '')
		         		aDados[nCampo][2] := sToD(aDados[nCampo][2])
		         	EndIf
		         Next

		         //Chama a exclus�o autom�tica
		         MsExecAuto({|x, y| A430Reserv(x, y)}, aDados, 5)

		         //Se houve erro, gera um arquivo de log dentro do diret�rio da protheus data
		         If lMsErroAuto
		         	//Monta o texto do Error Log que ser� salvo
		         	cErrorLog   := ''
		         	aLogAuto    := GetAutoGrLog()
		         	For nLinha := 1 To Len(aLogAuto)
		         		cErrorLog += aLogAuto[nLinha] + CRLF
		         	Next nLinha

		            //Grava o arquivo de log
		            cArqLog := 'IntegEQM_New_' + dToS(Date()) + '_' + StrTran(Time(), ':', '-') + '.log'
		            MemoWrite(cDirLog + cArqLog, cErrorLog)

		            //Define o retorno para o WebService
		            //SetRestFault(500, cErrorLog) //caso queira usar esse comando, voc� n�o poder� usar outros retornos, como os abaixo
		            Self:setStatus(500) 
		            jResponse['errorId']  := 'DEL013'
		            jResponse['error']    := 'Erro na exclus�o do registro'
		            jResponse['solution'] := 'Nao foi possivel incluir o registro, foi gerado um arquivo de log em ' + cDirLog + cArqLog + ' '
		            lRet := .F.

		         //Sen�o, define o retorno
		         Else
		         	jResponse['note']     := 'Registro incluido com sucesso'
		         EndIf

		     EndIf
		 EndIf
    EndIf

    //Define o retorno
    Self:SetResponse(EncodeUTF8(jResponse:toJSON()))
Return lRet
