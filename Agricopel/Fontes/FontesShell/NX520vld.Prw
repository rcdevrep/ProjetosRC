#include 'Protheus.ch'    
#include 'Topconn.ch'      
#include "rwmake.ch"
   


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MS520VLD  �Autor  �Leandro F Silveira  � Data � 11/01/2017 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada chamado antes da exclusao da nota fiscal  ���
���          � de saida.                                                  ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/



User Function NX520vld()
      
	Local lRet      := .T.
	Local cMsg      := ""
	Local nAnoSF2   := 0
	Local nMesSF2   := 0
	Local nMesAtual := 0
	Local nAnoAtual := 0
	Local cCodUsuar := " "
	Local _cUserExc := ""

	_cUserExc :=  SuperGetMv("MV_XEXCNF", ,"000000")

	If (cEmpAnt <> '20' .AND. cEmpAnt <> '21' .AND. cEmpAnt <> '51' .AND. cEmpAnt <> '44')
		If (SF2->F2_ESPECIE <> 'CTE' .AND. SF2->F2_ESPECIE <> 'NFS' .AND. SF2->F2_ESPECIE <> 'NFPS')

			nAnoSF2   := Year(SF2->F2_EMISSAO)
			nMesSF2   := Month(SF2->F2_EMISSAO)
			nAnoAtual := Year(Date())
			nMesAtual := Month(Date())

			If (nMesSF2 <> nMesAtual .OR. nAnoSF2 <> nAnoAtual)

				cMsg := "N�o foi poss�vel excluir a nota fiscal, pois a mesma foi faturada em um m�s/ano diferente da data atual." + CHR(13)
				cMsg += "Nota Fiscal: " + SF2->F2_DOC + CHR(13)
				cMsg += "Data de emiss�o: " + DTOC(SF2->F2_EMISSAO) + CHR(13)
				cMsg += "Esp�cie: " + SF2->F2_ESPECIE

				cCodUsuar := RetCodUsr()
			
				If cCodUsuar $ _cUserExc //(cCodUsuar == "000000" .Or. cCodUsuar == "000296" .Or. cCodUsuar == "000018" .Or. cCodUsuar == "000017") // SE FOR USU�RIO ADMIN OU VANDERLEIA OU ELIANE chamado 61624 | ADICIONADO USU�RIO DO ALEXANDRE chamado 437340
					cMsg += CHR(13) + CHR(13) + "Deseja excluir mesmo assim?"
					lRet := MsgYesNo(cMsg)
				Else
					cMsg += CHR(13) + CHR(13) + " MV_XEXCNF - Para excluir a nota, entrar em contato com a contabilidade."
					Alert(cMsg)
					lRet := .F.
				EndIf
			Endif
		Endif	
	Endif

	//Impede a Exclus�o do Doc quando a NCF estiver baixada
	If SF2->F2_TIPO == 'D' .AND. U_XAG0053V(SF2->F2_FILIAL)
		lRet := U_XAG0053E(.F.)
	Endif    

Return lRet
