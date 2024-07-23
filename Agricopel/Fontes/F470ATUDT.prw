#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �F470ATUDT �Autor  �Microsiga           � Data �  10/22/04   ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function F470ATUDT()

	Local cArqCNB := mv_par01
	Local nTamDet := 202
	Local nHldBco
	Local nLidos
	Local nTamArq
	Local cNumMov

	//�������������������������������Ŀ
	//� L� arquivo enviado pelo banco �
	//���������������������������������
	nHdlBco := FOPEN(cArqCNB,0+64)
	nLidos  := 0

	FSEEK(nHdlBco,0,0)
	nTamArq := FSEEK(nHdlBco,0,2)
	FSEEK(nHdlBco,0,0)

	While nLidos <= nTamArq

		xBuffer:=Space(nTamDet)
		FREAD(nHdlBco,@xBuffer,nTamDet)

		// Lancamentos
		IF SubStr(xBuffer,1,1) == "1"
			cNumMov := Substr(xBuffer,075,006)
			IF AllTrim(cNumMov)==AllTrim(TRB->NUMMOV)
		   		//Chamado: 54826 - Gravar historico conforme arquivo
				If alltrim(FUNNAME()) == 'AGR123'  
					Reclock('SE5',.F.)
						Replace SE5->E5_HISTOR  WITH Substr(xBuffer,106,30)
					SE5->(Msunlock())
				Else
					Replace NEWSE5->E5_HISTOR  WITH Substr(xBuffer,106,30)
				Endif
			Endif
		Endif
		nLidos += nTamDet
	Enddo

	//�������������������������������Ŀ
	//� Fecha arquivo do Banco        �
	//���������������������������������
	Fclose(nHdlBco)
Return .T.