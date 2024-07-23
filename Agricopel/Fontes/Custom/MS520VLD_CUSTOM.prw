#include 'Protheus.ch'
#include 'Topconn.ch'
#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MS520VLD  ºAutor  ³Leandro F Silveira  º Data ³ 11/01/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada chamado antes da exclusao da nota fiscal  º±±
±±º          ³ de saida.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MS520VLD()

Local lRet      := .T.
Local cMsg      := ""
Local nAnoSF2   := 0
Local nMesSF2   := 0
Local nMesAtual := 0
Local nAnoAtual := 0
Local cCodUsuar := ""
Local _cUserExc := ""

_cUserExc :=  SuperGetMv("MV_XEXCNF", ,"000000")

Conout("INICIO PE - SF2520E")

_aAreaAtu   := GetArea()
_aAreaSD2   := SD2->(GetArea())
_aAreaSF2   := SF2->(GetArea())
_aAreaSE1   := SE1->(GetArea())
_aAreaSF4   := SF4->(GetArea())
_aAreaSB1   := SB1->(GetArea())

If SM0->M0_CODIGO == "33"

	_cPrefixo   := SuperGetMv("MV_ZPRESER", ,"IS")
	_cBanco     := SuperGetMv("MV_ZBANSER", ,"CX1")
	cMotBx      := AllTrim(GetNewPar("MV_ZPLBXMB", "NOR"))

	SD2->(DbSetOrder(3))
	SD2->(DbGoTop())
	If SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
		//If Alltrim(SD2->D2_ORIGLAN) = "LF"
			//RecLock("SD2",.F.)
			//SD2->D2_ORIGLAN := ""
			//SD2->(MsUnlock())
			SE1->( DbGoTop() )
			SE1->(DBSETORDER(2))//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			If(SE1->( DbSeek( XFILIAL('SE1') + SF2->F2_CLIENTE+SF2->F2_LOJA + Padr(_cPrefixo,TamSx3("E1_PREFIXO")[1]) + Padr(SF2->F2_DOC,TamSx3("E1_NUM")[1]) + Padr("",TamSx3("E1_PARCELA")[1]) + Padr("BOL",TamSx3("E1_TIPO")[1]) )))
				aBaixa := {}
				If !Empty(_cBanco)
					SA6->(dbSetOrder(1))//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
					SA6->(dbGoTop())
					If SA6->(dbSeek(xFilial("SA6") + _cBanco))
						//Baixar titulos
						aBaixa := {{"E1_FILIAL" , SE1->E1_FILIAL                        , Nil     },;
						{"E1_PREFIXO"   , SE1->E1_PREFIXO                               , Nil     },;
						{"E1_NUM"       , SE1->E1_NUM                                   , Nil     },;
						{"E1_CLIENTE"   , SE1->E1_CLIENTE                               , Nil     },;
						{"E1_LOJA"      , SE1->E1_LOJA                                  , Nil     },;
						{"E1_TIPO"      , SE1->E1_TIPO                                  , Nil     },;
						{"E1_PARCELA"   , SE1->E1_PARCELA                               , Nil     },;
						{"AUTMOTBX"     , cMotBx                                        , Nil     },;
						{"AUTBANCO"     , PadR(SA6->A6_COD,TamSx3("E5_BANCO")[1])       , Nil     },;
						{"AUTAGENCIA"   , PadR(SA6->A6_AGENCIA,TamSx3("E5_AGENCIA")[1]) , Nil     },;
						{"AUTCONTA"     , PadR(SA6->A6_NUMCON,TamSx3("E5_CONTA")[1])    , Nil     },;
						{"AUTDTBAIXA"   , SF2->F2_EMISSAO                               , Nil     },;
						{"AUTDTCREDITO" , SF2->F2_EMISSAO                               , Nil     },;
						{"AUTHIST"      , "Baixa automatica rotina AGR05A01."           , Nil     },;
						{"AUTJUROS"     , 0                                             , Nil, .T.},;
						{"AUTVALREC"    , SE1->E1_VALOR                                 , Nil     }}
						lMsErroAuto := .F.
						MSExecAuto({|x, y| Fina070(x, y)}, aBaixa, 6)
						If !(lMsErroAuto)
							While (SE1->E1_PREFIXO == Padr(_cPrefixo,TamSx3("E1_PREFIXO")[1])) .And. (SE1->E1_NUM == Padr(SF2->F2_DOC,TamSx3("E1_NUM")[1])) .And. (SE1->E1_CLIENTE == SA1->A1_COD) .And. (SE1->E1_LOJA == SA1->A1_LOJA) .And. (!SE1->(Eof()))
								//Alterando origem do titulo para vincular a nota fiscal.
								RecLock("SE1")
								SE1->(dbDelete())
								SE1->(MsUnLock())
								SE1->(DbSkip())
							EndDo
						EndIf
					EndIf
				EndIf
			EndIf
		//EndIf
	EndIf
EndIf

If (cEmpAnt <> '20' .AND. cEmpAnt <> '21' .AND. cEmpAnt <> '51' .AND. cEmpAnt <> '44')
	If (SF2->F2_ESPECIE <> 'CTE' .AND. SF2->F2_ESPECIE <> 'NFS' .AND. SF2->F2_ESPECIE <> 'NFPS')

		nAnoSF2   := Year(SF2->F2_EMISSAO)
		nMesSF2   := Month(SF2->F2_EMISSAO)
		nAnoAtual := Year(Date())
		nMesAtual := Month(Date())

		If (nMesSF2 <> nMesAtual .OR. nAnoSF2 <> nAnoAtual)

			cMsg := "Não foi possível excluir a nota fiscal, pois a mesma foi faturada em um mês/ano diferente da data atual." + CHR(13)
			cMsg += "Nota Fiscal: " + SF2->F2_DOC + CHR(13)
			cMsg += "Data de emissão: " + DTOC(SF2->F2_EMISSAO) + CHR(13)
			cMsg += "Espécie: " + SF2->F2_ESPECIE

			cCodUsuar := RetCodUsr()

			If  cCodUsuar $ _cUserExc //(cCodUsuar == "000000" .Or. cCodUsuar == "000296" .Or. cCodUsuar == "000018" .Or. cCodUsuar == "000017") // SE FOR USUÁRIO ADMIN OU VANDERLEIA OU ELIANE chamado 61624 | ADICIONADO USUÁRIO DO ALEXANDRE chamado 437340
				cMsg += CHR(13) + CHR(13) + "Deseja excluir mesmo assim?"
				lRet := MsgYesNo(cMsg)
			Else
				cMsg += CHR(13) + CHR(13) + "  MV_XEXCNF - Para excluir a nota, entrar em contato com a contabilidade."
				Alert(cMsg)
				lRet := .F.
			EndIf
		Endif
	Endif
Endif

//Impede a Exclusão do Doc quando a NCF estiver baixada
If SF2->F2_TIPO == 'D' .AND. U_XAG0053V(SF2->F2_FILIAL)
	lRet := U_XAG0053E(.F.)
Endif


//Restaura Area Inicial
RestArea(_aAreaSB1)
RestArea(_aAreaSF4)
RestArea(_aAreaSE1)
RestArea(_aAreaSF2)
RestArea(_aAreaSD2)
RestArea(_aAreaAtu)

Conout("FIM PE - SF2520E")

Return(lRet)
