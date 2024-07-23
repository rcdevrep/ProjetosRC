#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "FILEIO.CH"

/*---------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+------------------+---------------------------------------------------------+
!Descricao         !Arquivo com Funcoes Genericas utilizadas em todo sistema.!
+------------------+---------------------------------------------------------+
!Autor             ! Gruppe - Felipe José Limas                              !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 07/2020                                                 !
+------------------+--------------------------------------------------------*/
User Function AGR05A02()

Return()

/*---------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+------------------+---------------------------------------------------------+
!Descricao         !Programa para Gravar arquivo de Log.                     !
+------------------+---------------------------------------------------------+
!Autor             ! Gruppe - Guilherme Peron Heidemann                      !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 07/2020                                                 !
+------------------+--------------------------------------------------------*/
User Function AGR05A2G(cDirLog,cArqLog)

Local   i    := 0
Private cLog := cDirLog+cArqLog //arquivo de log

//Cria diretório caso não exista
If !existDir(cDirLog)
	MakeDir(cDirLog)
EndIf

// verifica e cria o arquivo
If File(cLog)
	nHLog := FOpen(cLog,FO_READWRITE+FO_SHARED)
Else
	nHLog := MSFCREATE(cLog)   // nRet:= FCreate(cLog)
EndIf

If nHLog < 0
	MsgStop("Erro ao criar o arquivo de log ["+cLog+"]!","Log")
	Return()
EndIf

// percorre o array para gravar o log
For i := 1 To Len(aLog)
	FSeek(nHLog, 0, FS_END) // Posiciona no fim do arquivo
	FWrite(nHLog,aLog[i])
Next i

FClose(nHLog)

Return()

/*---------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+------------------+---------------------------------------------------------+
!Descricao         !Programa para adicionar arquivo de Log para posterior    !
!                  !gravação do mesmo.Deve ser criado a varável              !
!                  !Private aLog := {} na rotina que irá chamar o incremento !
!                  !do Log                                                   !
+------------------+---------------------------------------------------------+
!Autor             ! Gruppe - Guilherme Peron Heidemann                      !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 07/2020                                                 !
+------------------+--------------------------------------------------------*/
User Function AGR05A2H(cMsg)
aAdd(aLog,cMsg)
Return()

/*---------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+------------------+---------------------------------------------------------+
!Descricao         ! Funcao que executa Query passada como parametro e       !
!                  ! retorna o conteudo em um array.                         !
+------------------+---------------------------------------------------------+
!Autor             ! Gruppe - Felipe José Limas                              !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 07/2020                                                 !
+------------------+--------------------------------------------------------*/
User Function AGR05A2S(cQuery)

Local aRet    := {}
Local aRet1   := {}
Local nRegAtu := 0
Local x       := 0
Local _cAlias := GetNextAlias()

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),_cAlias,.T.,.T.)

(_cAlias)->(dbgotop())

aRet1   := Array(Fcount())
nRegAtu := 1

While !(_cAlias)->(Eof())
	
	For x:=1 To Fcount()
		aRet1[x] := FieldGet(x)
	Next
	Aadd(aRet,aclone(aRet1))
	
	(_cAlias)->(dbSkip())
	nRegAtu += 1
Enddo

If Select(_cAlias) <> 0
	(_cAlias)->(dbCloseArea())
EndIf

Return(aRet)

/*---------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+------------------+---------------------------------------------------------+
!Descricao         ! Funcao que executa Query passada como parametro e       !
!                  ! retorna o conteudo do campo CAMPO.                      !
+------------------+---------------------------------------------------------+
!Autor             ! Gruppe - Felipe José Limas                              !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 07/2020                                                 !
+------------------+--------------------------------------------------------*/
User Function AGR05A2V(mvQuery)
Local cAliasX := Alias()
Local aAreaAtu := GetArea()
Local cCampo := ""

If Select("QRYTMP") <> 0
	QRYTMP->(DbCloseArea())
EndIf
TcQuery mvQuery New Alias "QRYTMP"

DbSelectArea("QRYTMP")
QRYTMP->(DbGoTop())

// define campo de retorno
cCampo := QRYTMP->(FieldName(1))
// conteudo do retorno
xRetorno := QRYTMP->(&cCampo)

// fecha query
QRYTMP->(DbCloseArea())

If !Empty(cAliasX)
	DbSelectArea(cAliasX)
	RestArea(aAreaAtu)
EndIf

Return(xRetorno)

/*---------------------------------------------------------------------------+
!                             FICHA TECNICA DO PROGRAMA                      !
+------------------+---------------------------------------------------------+
!Descricao         ! 1. Monta Grupo de Perguntas (SX1)                       !
+------------------+---------------------------------------------------------+
!Autor             ! Gruppe - Felipe José Limas                              !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 07/2020                                                 !
+------------------+--------------------------------------------------------*/
/*User Function AGR05A2F(mvPerg,vList,lDel)
Local aArea := GetArea()
Local cSeq := "1"
Local _Lin := 0
Local nAdic := 0
Local nTamOrd := Len(SX1->X1_ORDEM)
Local cOrdPerg := ""
Local cCpoTmp := ""
Local _LisOpc

// abre arquivo de perguntas
DBSelectArea("SX1")
SX1->( DBSetOrder(1) )

// padroniza tamanho do cPerg
mvPerg := PadR(mvPerg,Len(SX1->X1_GRUPO))

//verifica se deve recriar as perguntas
If lDel
	SX1->( DBSeek(mvPerg) )
	//Apaga todo o grupo de Perguntas
	While SX1->( !Eof() ) .and. SX1->X1_GRUPO == mvPerg
		RecLock("SX1",.F.)
		SX1->( DbDelete() )
		MsUnLock("SX1")
		SX1->(DbSkip())
	EndDo
EndIf

// verifica se todas os parametros existem
For _Lin := 1 to Len(vList)
	// cria a variavel Ordem
	cOrdPerg := StrZero(_Lin,nTamOrd)
	
	// pesquisa pelo parametro
	SX1->( DBSeek(mvPerg+cOrdPerg) )
	
	// operacao (alteracao ou inclusao)
	RecLock("SX1",SX1->(Eof()))
	SX1->X1_GRUPO	:= mvPerg
	SX1->X1_ORDEM	:= cOrdPerg
	SX1->X1_PERGUNT	:= vList[_Lin,1]
	SX1->X1_PERSPA	:= vList[_Lin,1]
	SX1->X1_PERENG	:= vList[_Lin,1]
	SX1->X1_VARIAVL	:= "mv_ch" + cSeq
	SX1->X1_TIPO	:= vList[_Lin,2]
	SX1->X1_TAMANHO	:= vList[_Lin,3]
	SX1->X1_DECIMAL	:= vList[_Lin,4]
	SX1->X1_GSC		:= vList[_Lin,5]
	//Lista de Opções
	If vList[_Lin,5] = "C"
		For _LisOpc := 1 to Len(vList[_Lin,6])
			cCpoTmp := "X1_DEF" + StrZero(_LisOpc,2)
			SX1->&cCpoTmp := vList[_Lin,6,_LisOpc]
		Next _LisOpc
	Else
		SX1->X1_F3 := vList[_Lin,7]
	EndIf
	SX1->X1_PICTURE	:= vList[_Lin,8]
	SX1->X1_VAR01   := "mv_par" + StrZero(_Lin,2)
	
	// verifica se tem informacoes de campos adicionais
	If (Len(vList[_Lin])==8).and.(ValType(vList[_Lin,8])=="A")
		// grava informacoes adicionais
		For nAdic := 1 to Len(vList[_Lin,8])
			// grava campo
			SX1->&(vList[_Lin,8][nAdic,1]) := vList[_Lin,8][nAdic,2]
		Next nAdic
	EndIf
	
	SX1->(MsUnlock())
	
	//Atualiza Seq
	cSeq := Soma1(cSeq)
Next _Lin

// restaura area inicial
RestArea(aArea)

Return()
*/
