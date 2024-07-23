#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA030TOK  ºAutor  ³Jaime Wikanski      º Data ³  22/08/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de entrada na confirmacao da gravacao do cadastro de  º±±
±±º          ³clientes                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Shell                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function Nx030tok()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lReturn	:= .T.
Local cQuery	:= ""
Local cSequen	:= ""
Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())
Local lAltera	:= SuperGetMv("ES_PTOSETO",,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se foi selecionada a tabela de precos de acordo com   ³
//³ o grupo que o cliente pertence                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Inclui .or. Altera
	If Empty(M->A1_GRPVEN)
		Aviso("Inconsistencia","Selecione o grupo ao qual o cliente pertence.",{"Ok"},,OemtoAnsi("Atenção:"))
		lReturn := .F.
	Else
		If Posicione("ACY",1,xFilial("ACY")+M->A1_GRPVEN,"ACY_TABPRC") == "S" .and. Empty(M->A1_TABELA)
			Aviso("Inconsistencia","O grupo "+M->A1_GRPVEN+" necessita da seleção da tabela de preços para esse cliente.",{"Ok"},,OemtoAnsi("Atenção:"))
			lReturn := .F.		
		Endif
	Endif      
	
	If lAltera
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe o registro na roteirizacao                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Inclui .or. Altera
			DbSelectArea("DA7")
			DbSetOrder(2)
			//DA7_FILIAL+DA7_CLIENT+DA7_LOJA+DA7_PERCUR+DA7_ROTA
			If DbSeek(xFilial("DA7")+M->A1_COD+M->A1_LOJA,.F.)
				While !EOF() .and. DA7->DA7_FILIAL+DA7->DA7_CLIENT+DA7->DA7_LOJA == xFilial("DA7")+M->A1_COD+M->A1_LOJA
					RecLock("DA7",.F.)
					DbDelete()
					MsUnlock()
					DbSelectArea("DA7")
					DbSkip()
				Enddo
			Endif
        
			If !Empty(M->A1_ROTA)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Retorna a ultima sequencia                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQuery := " SELECT ISNULL(MAX(DA7_SEQUEN),'000000') AS DA7_SEQUEN"
				cQuery += " FROM "+RetSqlName("DA7")+" DA7 (NOLOCK)"
				cQuery += " WHERE DA7_FILIAL = '"+xFilial("DA7")+"'"		
				cQuery += " AND DA7_PERCUR = '"+M->A1_ZONA+"'"
				cQuery += " AND DA7_ROTA = '"+M->A1_ZONA+"'"
				cQuery += " AND D_E_L_E_T_ <> '*'"
				If Select("DA7TMP") > 0
					DbSelectArea("DA7TMP")
					DbCloseArea()
				Endif
				TcQuery cQuery New Alias "DA7TMP"
				DbSelectArea("DA7TMP")
				DbGoTop()
				cSequen := Soma1(DA7TMP->DA7_SEQUEN,6)
				If Select("DA7TMP") > 0
					DbSelectArea("DA7TMP")
					DbCloseArea()
				Endif
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava a amarracao                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("DA7")
				RecLock("DA7",.T.)
				DA7->DA7_FILIAL 	:= xFilial("DA7")
				DA7->DA7_PERCUR 	:= M->A1_ZONA
				DA7->DA7_ROTA   	:= M->A1_ZONA
				DA7->DA7_SEQUEN 	:= cSequen
				DA7->DA7_CLIENT 	:= M->A1_COD
				DA7->DA7_LOJA		:= M->A1_LOJA
				MsUnlock()    
			Endif
		EndIf
	Endif	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida a codificacao do cliente                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Inclui
	DbSelectArea("SA1")
	DbSetOrder(1)
	If DbSeek(xFilial("SA1")+M->A1_COD+M->A1_LOJA,.f.)
		/*
		While DbSeek(xFilial("SA1")+M->A1_COD+M->A1_LOJA,.f.)                                                                   
			M->A1_COD 	:= U_RetCodCli("A1_COD",M->A1_CGC)
			M->A1_LOJA 	:= U_RetCodCli("A1_LOJA",M->A1_CGC)
		Enddo
		*/
		Aviso("Informação","A codificação do cliente "+M->A1_COD+"-"+M->A1_LOJA+" já existe no cadastro. Digite o CNPJ/CPF do cliente novamente para gerar uma nova codificação.",{"Continuar"},,"Atenção:")
		lReturn	:= .F.
		SysRefresh()
	Endif
Endif 
                 
// Ponto de entrada para customização Agricopel - Thiago SLA - 22/03/2016
If lReturn .AND. (ExistBlock("M030TOK"))
      lReturn := ExecBlock("M030TOK")
EndIf	

RestArea(aAreaSA1)
RestArea(aArea)

Return(lReturn)