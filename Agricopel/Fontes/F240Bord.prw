#INCLUDE "TOTVS.CH"

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F240BORD  �Autor  �Osmar Schimitberger � Data �  05/10/2018 ���
�������������������������������������������������������������������������͹��
���          �Ponto de Entrada para Gravacao dos dados adicionais         ���
���          �ap�s a geracao de um border� de pagto.                      ���
���Retorno   �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Agricopel - MULTIPAG BRADESCO                              ���
���          �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
*/

User Function F240Bord()

	Local _aAreaSEA := SEA->(GetARea())
	Local _aAreaSE2 := SE2->(GetARea())
	Local _cNBor30  := soma1(cNumBor)
	Local aSEA      := {}
	Local lNewBord  := .F.
	Local cAliasSX6 := "SX6"
	Local X         := 0

	DbSelectArea("SEA")
	DbSetOrder(1)
	DbSeek(xFIlial("SEA")+cNumBor)

	While !SEA->(Eof()) .and. SEA->EA_NUMBOR == cNumBor

		aAdd(aSEA,{SEA->EA_NUMBOR,SEA->EA_PREFIXO,SEA->EA_NUM,SEA->EA_PARCELA,SEA->EA_TIPO,SEA->EA_FORNECE,SEA->EA_LOJA,SEA->EA_MODELO,SEA->EA_PORTADO})

		DbSelectArea("SEA")
		DbSkip()
	EndDo

	For X := 1 to Len(aSEA)

		If aSEA[X,8] == "31"
			//DADOS DO TITULO
			DbSelectArea("SE2")
			DbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
			If DbSeek(xFIlial("SE2")+aSEA[X,2]+aSEA[X,3]+aSEA[X,4]+aSEA[X,5]+aSEA[X,6]+aSEA[X,7])
				If SUBSTR(SE2->E2_CODBAR,1,3) == aSEA[X,9] //PAGTO BOLETO DO MESMO PORTADOR MUDA MODELO DE PAGTO
					lNewBord:= .T.
					RecLock("SE2",.F.)
					SE2->E2_NUMBOR := _cNBor30 //Muda Numero Bordero para gera��o correta da remessa do MULTIPAG
					MsUnlock()
					//DADOS DO BORDERO
					DbSelectArea("SEA")
					DbSetOrder(1) //EA_FILIAL+EA_NUMBOR+EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA
					If DbSeek(xFIlial("SEA")+aSEA[X,1]+aSEA[X,2]+aSEA[X,3]+aSEA[X,4]+aSEA[X,5]+aSEA[X,6]+aSEA[X,7])
						RecLock("SEA",.F.)
						SEA->EA_MODELO := "30"  //Boleto com liquidacao do proprio banco
						SEA->EA_NUMBOR := _cNBor30 //Muda Numero Bordero para gera��o correta da remessa do MULTIPAG
						MsUnlock()
					Endif
				Endif
			Endif
		Endif

	Next

	//��������������������������������������������������������������Ŀ
	//� Grava o numero do bordero atualizado                         �
	//� Utilize sempre GetMv para posicionar o SX6. N�o use SEEK !!! �
	//����������������������������������������������������������������
	If lNewBord

		DbSelectArea(cAliasSX6)
		GetMv("MV_NUMBORP")

		RecLock(cAliasSX6,.F.)
		(cAliasSX6)->(FieldPut((cAliasSX6)->(FieldPos("X6_CONTEUD")), _cNBor30))
		MsUnlock()

		MsgInfo("Gerado novo bordero "+_cNBor30+" -> para os Boletos do Bradesco - MODELO 30", "Geracao concluida")

	Endif

	SEA->(RestARea(_aAreaSEA))
	SE2->(RestARea(_aAreaSE2))

Return()